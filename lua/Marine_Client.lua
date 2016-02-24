// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Marine_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Marine.k2DHUDFlash = "ui/marine_hud_2d.swf"
Marine.kBuyMenuTexture = "ui/marine_buymenu.dds"
Marine.kBuyMenuUpgradesTexture = "ui/marine_buymenu_upgrades.dds"
Marine.kBuyMenuiconsTexture = "ui/marine_buy_icons.dds"

Marine.kInfestationFootstepCinematic = PrecacheAsset("cinematics/marine/infestation_footstep.cinematic")
Marine.kSpitHitCinematic = PrecacheAsset("cinematics/marine/spit_hit_1p.cinematic")

PrecacheAsset("cinematics/vfx_materials/rupture.surface_shader")
PrecacheAsset("cinematics/vfx_materials/marine_highlight.surface_shader")
local kRuptureMaterial = PrecacheAsset("cinematics/vfx_materials/rupture.material")
local kHighlightMaterial = PrecacheAsset("cinematics/vfx_materials/marine_highlight.material")

Marine.kSpitHitEffectDuration = 1

local kSensorBlipSize = 25

function Marine:GetHealthbarOffset()
    return 1.2
end

function MarineUI_GetHasArmsLab()

    local player = Client.GetLocalPlayer()
    
    if player then
        return GetHasTech(player, kTechId.ArmsLab)
    end
    
    return false
    
end

function PlayerUI_GetSensorBlipInfo()

    PROFILE("PlayerUI_GetSensorBlipInfo")
    
    local player = Client.GetLocalPlayer()
    local blips = {}
    
    if player then
    
        local eyePos = player:GetEyePos()
        for index, blip in ientitylist(Shared.GetEntitiesWithClassname("SensorBlip")) do
        
            local blipOrigin = blip:GetOrigin()
            local blipEntId = blip.entId
            local blipName = ""
            
            // Lookup more recent position of blip
            local blipEntity = Shared.GetEntity(blipEntId)
            
            // Do not display a blip for the local player.
            if blipEntity ~= player then

                if blipEntity then
                
                    if blipEntity:isa("Player") then
                        blipName = Scoreboard_GetPlayerData(blipEntity:GetClientIndex(), kScoreboardDataIndexName)
                    elseif blipEntity.GetTechId then
                        blipName = GetDisplayNameForTechId(blipEntity:GetTechId())
                    end
                    
                end
                
                if not blipName then
                    blipName = ""
                end
                
                // Get direction to blip. If off-screen, don't render. Bad values are generated if 
                // Client.WorldToScreen is called on a point behind the camera.
                local normToEntityVec = GetNormalizedVector(blipOrigin - eyePos)
                local normViewVec = player:GetViewAngles():GetCoords().zAxis
               
                local dotProduct = normToEntityVec:DotProduct(normViewVec)
                if dotProduct > 0 then
                
                    // Get distance to blip and determine radius
                    local distance = (eyePos - blipOrigin):GetLength()
                    local drawRadius = kSensorBlipSize/distance
                    
                    // Compute screen xy to draw blip
                    local screenPos = Client.WorldToScreen(blipOrigin)

                    /*
                    local trace = Shared.TraceRay(eyePos, blipOrigin, CollisionRep.LOS, PhysicsMask.Bullets, EntityFilterTwo(player, entity))                               
                    local obstructed = ((trace.fraction ~= 1) and ((trace.entity == nil) or trace.entity:isa("Door"))) 
                    
                    if not obstructed and entity and not entity:GetIsVisible() then
                        obstructed = true
                    end
                    */
                    
                    // Add to array (update numElementsPerBlip in GUISensorBlips:UpdateBlipList)
                    table.insert(blips, screenPos.x)
                    table.insert(blips, screenPos.y)
                    table.insert(blips, drawRadius)
                    table.insert(blips, true)
                    table.insert(blips, blipName)

                end
                
            end
            
        end
    
    end
    
    return blips
    
end

function Marine:UnitStatusPercentage()
    return self.unitStatusPercentage
end

local function TriggerSpitHitEffect(coords)

    local spitCinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
    spitCinematic:SetCinematic(Marine.kSpitHitCinematic)
    spitCinematic:SetRepeatStyle(Cinematic.Repeat_None)
    spitCinematic:SetCoords(coords)
    
end

local function UpdatePoisonedEffect(self)

    local feedbackUI = ClientUI.GetScript("GUIPoisonedFeedback")
    if self.poisoned and self:GetIsAlive() and feedbackUI and not feedbackUI:GetIsAnimating() then
        feedbackUI:TriggerPoisonEffect()
    end
    
end

function Marine:UpdateClientEffects(deltaTime, isLocal)
    
    Player.UpdateClientEffects(self, deltaTime, isLocal)
    
    if isLocal then
    
//        Client.SetMouseSensitivityScalar(ConditionalValue(self:GetIsStunned(), 0, 1))
        
        self:UpdateGhostModel()
        
        UpdatePoisonedEffect(self)
        
        local marineHUD = ClientUI.GetScript("Hud/Marine/GUIMarineHUD")
        if marineHUD then
            marineHUD:SetIsVisible(self:GetIsAlive())
        end
        
        if self.buyMenu then
        
            if not self:GetIsAlive() or not GetIsCloseToMenuStructure(self) then
                self:CloseMenu()
            end
        elseif self.creditMenu then
              if not self:GetIsAlive()  then
                self:CloseMenu()
              end
        end    
        
        if Player.screenEffects.disorient then
            Player.screenEffects.disorient:SetParameter("time", Client.GetTime())
        end
        

        local blurEnabled = self.buyMenu ~= nil or self.creditMenu ~= nil
        self:SetBlurEnabled(blurEnabled)
        
        // update spit hit effect
        if not Shared.GetIsRunningPrediction() then
        
            if self.timeLastSpitHit ~= self.timeLastSpitHitEffect then
            
                local viewAngle = self:GetViewAngles()
                local angleDirection = Angles(GetPitchFromVector(self.lastSpitDirection), GetYawFromVector(self.lastSpitDirection), 0)
                angleDirection.yaw = GetAnglesDifference(viewAngle.yaw, angleDirection.yaw)
                angleDirection.pitch = GetAnglesDifference(viewAngle.pitch, angleDirection.pitch)
                
                TriggerSpitHitEffect(angleDirection:GetCoords())
                
                local intensity = self.lastSpitDirection:DotProduct(self:GetViewCoords().zAxis)
                self.spitEffectIntensity = intensity
                self.timeLastSpitHitEffect = self.timeLastSpitHit
                
            end
            
        end
        
        local spitHitDuration = Shared.GetTime() - self.timeLastSpitHitEffect
        
        if Player.screenEffects.disorient and self.timeLastSpitHitEffect ~= 0 and spitHitDuration <= Marine.kSpitHitEffectDuration then
        
            Player.screenEffects.disorient:SetActive(true)
            local amount = (1 - ( spitHitDuration/Marine.kSpitHitEffectDuration) ) * 3.5 * self.spitEffectIntensity
            Player.screenEffects.disorient:SetParameter("amount", amount)
            
        end
        
    end
    
    if self._renderModel then

        if self.ruptured and not self.ruptureMaterial then

            local material = Client.CreateRenderMaterial()
            material:SetMaterial(kRuptureMaterial)

            local viewMaterial = Client.CreateRenderMaterial()
            viewMaterial:SetMaterial(kRuptureMaterial)
            
            self.ruptureEntities = {}
            self.ruptureMaterial = material
            self.ruptureMaterialViewMaterial = viewMaterial
            AddMaterialEffect(self, material, viewMaterial, self.ruptureEntities)
        
        elseif not self.ruptured and self.ruptureMaterial then

            RemoveMaterialEffect(self.ruptureEntities, self.ruptureMaterial, self.ruptureMaterialViewMaterial)
            Client.DestroyRenderMaterial(self.ruptureMaterial)
            Client.DestroyRenderMaterial(self.ruptureMaterialViewMaterial)
            self.ruptureMaterial = nil
            self.ruptureMaterialViewMaterial = nil
            self.ruptureEntities = nil
            
        end
        
    end
    
    
end

function Marine:OnUpdateRender()

    PROFILE("Marine:OnUpdateRender")
    
    Player.OnUpdateRender(self)
    
    local isLocal = self:GetIsLocalPlayer()
    
    // Synchronize the state of the light representing the flash light.
    self.flashlight:SetIsVisible(self.flashlightOn and (isLocal or self:GetIsVisible()) )
    
    if self.flashlightOn then
    
        local coords = Coords(self:GetViewCoords())
        coords.origin = coords.origin + coords.zAxis * 0.75
        
        self.flashlight:SetCoords(coords)
        
        // Only display atmospherics for third person players.
        local density = 0.2
        if isLocal and not self:GetIsThirdPerson() then
            density = 0
        end
        self.flashlight:SetAtmosphericDensity(density)
        
    end
    
    local localPlayer = Client.GetLocalPlayer()
    local showHighlight = localPlayer ~= nil and localPlayer:isa("Alien") and self:GetIsAlive()
    
    /* disabled for now
    local model = self:GetRenderModel()

    if model then
    
        if showHighlight and not self.marineHighlightMaterial then
            
            self.marineHighlightMaterial = AddMaterial(model, kHighlightMaterial)
            
        elseif not showHighlight and self.marineHighlightMaterial then
        
            RemoveMaterial(model, self.marineHighlightMaterial)
            self.marineHighlightMaterial = nil
        
        end
        
        if self.marineHighlightMaterial then
            self.marineHighlightMaterial:SetParameter("distance", (localPlayer:GetEyePos() - self:GetOrigin()):GetLength())
        end
    
    end
    */

end
function Marine:UpdateTimer()

GetGUIManager():DestroyGUIScriptSingle("GUIInsight_TopBar")
GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar")

end
function Marine:AddNotification(locationId, techId)

    local locationName = ""

    if locationId ~= 0 then
        locationName = Shared.GetString(locationId)
    end

    table.insert(self.notifications, { LocationName = locationName, TechId = techId })

end

// this function returns the oldest notification and clears it from the list
function Marine:GetAndClearNotification()

    local notification = nil

    if table.count(self.notifications) > 0 then
    
        notification = { LocationName = self.notifications[1].LocationName, TechId = self.notifications[1].TechId }
        table.remove(self.notifications, 1)
    
    end
    
    return notification

end

function Marine:TriggerFootstep()

    Player.TriggerFootstep(self)
    
    if self:GetGameEffectMask(kGameEffect.OnInfestation) and self:GetIsSprinting() and self == Client.GetLocalPlayer() and not self:GetIsThirdPerson() then
    
        local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
        cinematic:SetRepeatStyle(Cinematic.Repeat_None)
        cinematic:SetCinematic(Marine.kInfestationFootstepCinematic)
    
    end

end

gCurrentHostStructureId = Entity.invalidId

function MarineUI_SetHostStructure(structure)

    if structure then
        gCurrentHostStructureId = structure:GetId()
    end    

end

function MarineUI_GetCurrentHostStructure()

    if gCurrentHostStructureId and gCurrentHostStructureId ~= Entity.invalidId then
        return Shared.GetEntity(gCurrentHostStructureId)
    end

    return nil    

end
function Marine:Buy()

    // Don't allow display in the ready room, or as phantom
    if self:GetIsLocalPlayer() then
    
        // The Embryo cannot use the buy menu in any case.
        if self:GetTeamNumber() ~= 0  then
        
            if not self.creditMenu and not self.buyMenu then
            
                self.creditMenu = GetGUIManager():CreateGUIScript("GUIMarineCreditMenu")
                MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)
                
            else
                self:CloseMenu()
            end
            
        else
            self:PlayEvolveErrorSound()
        end
        
    end
    
end
// Bring up buy menu
function Marine:BuyMenu(structure)
    
    // Don't allow display in the ready room
    if self:GetTeamNumber() ~= 0 and Client.GetLocalPlayer() == self then
    
        if not self.buyMenu and not self.creditMenu then
        
            self.buyMenu = GetGUIManager():CreateGUIScript("GUIMarineBuyMenu")
            
            MarineUI_SetHostStructure(structure)
            
            if structure then
                self.buyMenu:SetHostStructure(structure)
            end
            
            self:TriggerEffects("marine_buy_menu_open")
            
        end
        
    end
    
end

function Marine:UpdateMisc(input)

    Player.UpdateMisc(self, input)
    
    if not Shared.GetIsRunningPrediction() then

        if input.move.x ~= 0 or input.move.z ~= 0 then

            self:CloseMenu()
            
        end
        
    end
    
end

// Give dynamic camera motion to the player
/*
function Marine:PlayerCameraCoordsAdjustment(cameraCoords) 

    if self:GetIsFirstPerson() then
        
        if self:GetIsStunned() then
            local attachPointOffset = self:GetAttachPointOrigin("Head") - cameraCoords.origin
            attachPointOffset.x = attachPointOffset.x * .5
            attachPointOffset.z = attachPointOffset.z * .5
            cameraCoords.origin = cameraCoords.origin + attachPointOffset
        end
    
    end
    
    return cameraCoords

end*/

function Marine:OnCountDown()

    Player.OnCountDown(self)
    
    local script = ClientUI.GetScript("Hud/Marine/GUIMarineHUD")
    if script then
        script:SetIsVisible(false)
    end
    
end

function Marine:OnCountDownEnd()

    Player.OnCountDownEnd(self)
    
    local script = ClientUI.GetScript("Hud/Marine/GUIMarineHUD")
    if script then
    
        script:SetIsVisible(true)
        script:TriggerInitAnimations()
        
    end
    
end

function Marine:OnOrderSelfComplete(orderType)
    self:TriggerEffects("complete_order")
end

function Marine:GetSpeedDebugSpecial()
    return self:GetSprintTime() / SprintMixin.kMaxSprintTime
end

function Marine:UpdateGhostModel()

    self.currentTechId = nil
    self.ghostStructureCoords = nil
    self.ghostStructureValid = false
    self.showGhostModel = false
    
    local weapon = self:GetActiveWeapon()

    if weapon then
        if weapon:isa("LayMines") or weapon:isa("LayStructures") then
        self.currentTechId = weapon:GetDropStructureId()
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
        end
    end

end

function Marine:GetShowGhostModel()
    return self.showGhostModel
end    

function Marine:GetGhostModelTechId()
    return self.currentTechId
end

function Marine:GetGhostModelCoords()
    return self.ghostStructureCoords
end

function Marine:GetIsPlacementValid()
    return self.ghostStructureValid
end
