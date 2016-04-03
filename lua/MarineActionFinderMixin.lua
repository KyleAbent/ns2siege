// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\MarineActionFinderMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

local kFindWeaponRange = 2
local kIconUpdateRate = 0.5

local function SortByValue(item1, item2)

    local cost1 = HasMixin(item1, "Tech") and LookupTechData(item1:GetTechId(), kTechDataCostKey, 0) or 0
    local cost2 = HasMixin(item2, "Tech") and LookupTechData(item2:GetTechId(), kTechDataCostKey, 0) or 0

    return cost1 > cost2

end
local function FindNearbyUse(self, toPosition)
    local nearbyUses = GetEntitiesWithMixinForTeamWithinRange("Construct", 1, toPosition, kFindWeaponRange)
    local closestUse = nil
    for i, nearbyUse in ipairs(nearbyUses) do
    
             if not nearbyUse:isa("ArmsLab") and not nearbyUse:isa("Extractor") and nearbyUse:GetIsBuilt() then
               closestUse = nearbyUse 
               break
             end
    end
    return closestUse

end
local function FindNearbyWeapon(self, toPosition)

    local nearbyWeapons = GetEntitiesWithMixinWithinRange("Pickupable", toPosition, kFindWeaponRange)
    table.sort(nearbyWeapons, SortByValue)
    
    local closestWeapon = nil
    local closestDistance = Math.infinity
    local cost = 1
    
    for i, nearbyWeapon in ipairs(nearbyWeapons) do
    
        if nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) then
        
            local nearbyWeaponDistance = (nearbyWeapon:GetOrigin() - toPosition):GetLengthSquared()
            local currentCost = HasMixin(nearbyWeapon, "Tech") and LookupTechData(nearbyWeapon:GetTechId(), kTechDataCostKey, 0) or 0

            if currentCost < cost then            
                break
                
            else    
            
                closestWeapon = nearbyWeapon
                closestDistance = nearbyWeaponDistance
                cost = currentCost
            
            end
            
        end
        
    end
    
    return closestWeapon

end

MarineActionFinderMixin = CreateMixin( MarineActionFinderMixin )
MarineActionFinderMixin.type = "MarineActionFinder"

MarineActionFinderMixin.expectedCallbacks =
{
    GetOrigin = "Returns the position of the Entity in world space"
}

function MarineActionFinderMixin:__initmixin()

    if Client and Client.GetLocalPlayer() == self then
    
        self.actionIconGUI = GetGUIManager():CreateGUIScript("GUIActionIcon")
        self.actionIconGUI:SetColor(kMarineFontColor)
        self.lastMarineActionFindTime = 0
        
    end
    
end

function MarineActionFinderMixin:OnDestroy()

    if Client and self.actionIconGUI then
    
        GetGUIManager():DestroyGUIScript(self.actionIconGUI)
        self.actionIconGUI = nil
        
    end
    
end

function MarineActionFinderMixin:GetNearbyPickupableWeapon()
    return FindNearbyWeapon(self, self:GetOrigin())
end

if Client then

    function MarineActionFinderMixin:OnProcessMove(input)
    
        PROFILE("MarineActionFinderMixin:OnProcessMove")
        
        local prediction = Shared.GetIsRunningPrediction()
        local now = Shared.GetTime()
        local enoughTimePassed = (now - self.lastMarineActionFindTime) >= kIconUpdateRate
        if not prediction and enoughTimePassed then
        
            self.lastMarineActionFindTime = now
            
            local success = false
            
            if self:GetIsAlive() and not GetIsVortexed(self) then
            
                local foundNearbyWeapon = FindNearbyWeapon(self, self:GetOrigin())
                local foundNearbyUse = FindNearbyUse(self, self:GetOrigin())
                if foundNearbyWeapon then
                    self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Drop"), foundNearbyWeapon:GetClassName(), nil)
                    success = true
                elseif foundNearbyUse then   
                     if foundNearbyUse:isa("Armory") or foundNearbyUse:isa("PrototypeLab") then
                     hintText = "Move Structure"
                     elseif foundNearbyUse:isa("ARC") then
                     hintText = "Equipt welder to move"
                     else
                     hintText = "(Setup)Equipt welder to move"
                     end
                    self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"),  nil, hintText, nil)
                    success = true
                else
                
                    local ent = self:PerformUseTrace()
                    if ent then
                    
                        if GetPlayerCanUseEntity(self, ent) and not self:GetIsUsing() then
                        
                            local hintText = nil
                            if ent:isa("MAC") then 
                                hintText = "Have MAC follow and weld YOU"
                            end
                            
                            self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"), nil, hintText, nil)
                            success = true
                            
                        end
                        
                    end
                    
                end
                
            end
            
            if not success then
                self.actionIconGUI:Hide()
            end
            
        end
        
    end
    
end