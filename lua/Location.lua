// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Location.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Represents a named location in a map, so players can see where they are.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Trigger.lua")

PrecacheAsset("materials/power/powered_decal.surface_shader")
local kPoweredDecalMaterial = PrecacheAsset("materials/power/powered_decal.material")
// local kUnpoweredDecalMaterial = PrecacheAsset("materials/power/unpowered_decal.material")

class 'Location' (Trigger)

Location.kMapName = "location"

local networkVars =
{
    showOnMinimap = "boolean",
   spawningcysts = "boolean",
   poweredatfrontopen = "private boolean",
}

Shared.PrecacheString("")

function Location:OnInitialized()

    Trigger.OnInitialized(self)
    
    // Precache name so we can use string index in entities
    Shared.PrecacheString(self.name)
    
    // Default to show.
    if self.showOnMinimap == nil then
        self.showOnMinimap = true
    end
    
    self:SetTriggerCollisionEnabled(true)
    
    self:SetPropagate(Entity.Propagate_Always)
    self.spawningcysts = false
    self.poweredatfrontopen = false
end

function Location:Reset()
    self.poweredatfrontopen = false
end    

function Location:OnDestroy()

    Trigger.OnDestroy(self)
    
    if Client then
        self:HidePowerStatus()
    end

end

function Location:GetShowOnMinimap()
    return self.showOnMinimap
end
if Server then
    function Location:GetCystsInLocation(location, powerpoint)
            local entities = GetEntitiesForTeamWithinRange("Cyst", 2, powerpoint:GetOrigin(), 24)
                local cysts = 0
            for i = 1, #entities do
            local entity = entities[i]
                if entity:isa("Cyst") and entity:GetLocationName() == location.name then 
                  cysts = cysts + 1
                end
            end
            return cysts
    end
    function Location:SetIsPoweredAtFrontOpen()
                         local entities = self:GetEntitiesInTrigger()
                     for i = 1, #entities do
                     local ent = entities[i]
                           if ent:isa("PowerPoint") then 
                              self.poweredatfrontopen = ent:GetIsBuilt() and not ent:GetIsDisabled()
                           end
                     end
    end
    function Location:RoomCurrentlyHasPower()
                         local entities = self:GetEntitiesInTrigger()
                     for i = 1, #entities do
                     local ent = entities[i]
                           if ent:isa("PowerPoint") then 
                              return ent:GetIsBuilt() and not ent:GetIsDisabled()
                           end
                     end
                     return false
    end
    function Location:GetHadPowerDuringSetup()
                  return self.poweredatfrontopen 
    end
    function Location:ReallySpawnCysts(powerpoint)
    --Kyle Abent :S
    -- 2.7 -- To replace comm cysts with automatic system based on where state of turf within dynamic playthrough lays(in theory)
    
                      local gameRules = GetGamerules()
            if gameRules then
                           gameRules:SpawnCystsAtLocation(self, powerpoint)  
            end
            
    end
    
        function Location:MakeSureRoomIsntEmpty()
                     local entities = self:GetEntitiesInTrigger()
                     for i = 1, #entities do
                     local ent = entities[i]
                     if ent:isa("Player") and ent:GetIsAlive() and not ent:isa("Commander") then return true end
                     end
                     return false
    end
    
    function Location:GetIsSetup()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and not gameRules:GetFrontDoorsOpen() then 
                   return true
               end
            end
        end
            return false
      end
    function Location:OnTriggerEntered(entity, triggerEnt)
        ASSERT(self == triggerEnt)
          if self:GetIsSetup() then
            if entity:GetTeamNumber() == 1 then
               local powerPoint = GetPowerPointForLocation(self.name)
                 if powerPoint ~= nil and not powerPoint:GetIsBuilt() then
                   powerPoint:SetConstructionComplete()
                 end
            end
          end
        if entity.SetLocationName then
            //Log("%s enter loc %s ('%s') from '%s'", entity, self, self:GetName(), entity:GetLocationName())
            // only if we have no location do we set the location here
            // otherwise we wait until we exit the location to set it
            if not entity:GetLocationEntity() then
                entity:SetLocationName(triggerEnt:GetName())
                entity:SetLocationEntity(self)
            end
        end
            
    end
    
    function Location:OnTriggerExited(entity, triggerEnt)
        ASSERT(self == triggerEnt)
        if entity.SetLocationName then
            local enteredLoc = GetLocationForPoint(entity:GetOrigin(), self)
            local name = enteredLoc and enteredLoc:GetName() or ""
            //Log("%s exited location %s('%s'), entered '%s'", entity, self, self:GetName(), name)
            entity:SetLocationName(name)
            entity:SetLocationEntity(enteredLoc)
        end            
    end
end

// used for marine commander to show/hide power status in a location
if Client then

    function Location:ShowPowerStatus(powered)

        if not self.powerDecal then
            self.materialLoaded = nil  
        end

        if powered then
        
            if self.materialLoaded ~= "powered" then
            
                if self.powerDecal then
                    Client.DestroyRenderDecal(self.powerDecal)
                    Client.DestroyRenderMaterial(self.powerMaterial)
                end
                
                self.powerDecal = Client.CreateRenderDecal()

                local material = Client.CreateRenderMaterial()
                material:SetMaterial(kPoweredDecalMaterial)
        
                self.powerDecal:SetMaterial(material)
                self.materialLoaded = "powered"
                self.powerMaterial = material
                
            end

        else
            
            if self.powerDecal then
                Client.DestroyRenderDecal(self.powerDecal)
                Client.DestroyRenderMaterial(self.powerMaterial)
                self.powerDecal = nil
                self.powerMaterial = nil
                self.materialLoaded = nil
            end
            
            /*
            
            if self.materialLoaded ~= "unpowered" then
            
                if self.powerDecal then
                    Client.DestroyRenderDecal(self.powerDecal)
                end
                
                self.powerDecal = Client.CreateRenderDecal()
        
                self.powerDecal:SetMaterial(kUnpoweredDecalMaterial) 
                self.materialLoaded = "unpowered"
            
            end
            
            */
            
        end
        
    end

    function Location:HidePowerStatus()

        if self.powerDecal then
            Client.DestroyRenderDecal(self.powerDecal)
            Client.DestroyRenderMaterial(self.powerMaterial)
            self.powerDecal = nil
            self.powerMaterial = nil
        end

    end
    
    function Location:OnUpdateRender()
    
        PROFILE("Location:OnUpdateRender")
        
        local player = Client.GetLocalPlayer()      

        local showPowerStatus = player and player.GetShowPowerIndicator and player:GetShowPowerIndicator()
        local powerPoint

        if showPowerStatus then
            powerPoint = GetPowerPointForLocation(self.name)
            showPowerStatus = powerPoint ~= nil   
        end  
        
        if showPowerStatus then
                
            self:ShowPowerStatus(powerPoint:GetIsPowering())
            if self.powerDecal then
            
                // TODO: Doesn't need to be updated every frame, only setup on creation.
            
                local coords = self:GetCoords()
                local extents = self.scale * 0.2395
                extents.y = 10
                coords.origin.y = powerPoint:GetOrigin().y - 2
                
                // Get the origin in the object space of the decal.
                local osOrigin = coords:GetInverse():TransformPoint( powerPoint:GetOrigin() )
                self.powerMaterial:SetParameter("osOrigin", osOrigin)

                self.powerDecal:SetCoords(coords)
                self.powerDecal:SetExtents(extents)
                
            end
            
        else
            self:HidePowerStatus()
        end   
        
    end
    
end

Shared.LinkClassToMap("Location", Location.kMapName, networkVars)