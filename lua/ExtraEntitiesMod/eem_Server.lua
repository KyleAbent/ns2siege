Script.Load("lua/ExtraEntitiesMod/eem_Shared.lua")



local function OnMessageExoModularBuy(client, message)
    local player = client:GetControllingPlayer()
    if player and player:GetIsAllowedToBuy() and player.ProcessExoModularBuyAction then
        player:ProcessExoModularBuyAction(message)
    end
end
Server.HookNetworkMessage("ExoModularBuy", OnMessageExoModularBuy)

function ModularExo_FindExoSpawnPoint(self)
    local maxAttempts = 20
    for index = 1, maxAttempts do
    
        -- Find open area nearby to place the big guy.

        local extents = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents)
        local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  

        local spawnPoint        
        local checkPoint = self:GetOrigin() + Vector(0, 0.02, 0)
        
        if GetHasRoomForCapsule(extents, checkPoint + Vector(0, extents.y, 0), CollisionRep.Move, PhysicsMask.Evolve, self) then
            spawnPoint = checkPoint
        else
            spawnPoint = GetRandomSpawnForCapsule(extents.y, extents.x, checkPoint, 0.5, 8, EntityFilterAll())
        end    
            

            return spawnPoint or self:GetOrigin()
    end
end

function ModularExo_HandleExoModularBuy(self, message)
    local exoConfig = ModularExo_ConvertNetMessageToConfig(message)
    
    local discount = 0
    if self:isa("Exo") then
        local isValid, badReason, resCost = ModularExo_GetIsConfigValid(ModularExo_ConvertNetMessageToConfig(self))
        discount = resCost
    end
    
    local isValid, badReason, resCost = ModularExo_GetIsConfigValid(exoConfig)
    resCost = resCost-discount
    //if resCost < 0 then
       // Print("Invalid exo config: no refunds!")
   // end
    if not isValid or resCost > self:GetResources() then
        Print("Invalid exo config: %s", badReason)
        return
    end
    self:AddResources(-resCost)
    
    local spawnPoint = ModularExo_FindExoSpawnPoint(self)
    if spawnPoint == nil then
        Print("Could not find exo spawnpoint")
        return
    end
    
    local weapons = self:GetWeapons()
    for i = 1, #weapons do            
        weapons[i]:SetParent(nil)            
    end
    local exoVariables = message
    
    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, exoVariables)     
    
    if not exo then
        Print("Could make replacement exo entity")
        return
    end
    if self:isa("Exo") then
        exo:SetMaxArmor(self:GetMaxArmor())
        exo:SetArmor(self:GetArmor())
    else
        exo.prevPlayerMapName = self:GetMapName()
        exo.prevPlayerHealth = self:GetHealth()
        exo.prevPlayerMaxArmor = self:GetMaxArmor()
        exo.prevPlayerArmor = self:GetArmor()
        for i = 1, #weapons do
            exo:StoreWeapon(weapons[i])
        end
    end
    
    exo:TriggerEffects("spawn_exo")
    
end
/*
local function OnMessageJetpackModularBuy(client, message)
    local player = client:GetControllingPlayer()
    if player and player:GetIsAllowedToBuy() and player.ProcessJetpackBuyAction then
        player:ProcessJetpackModularBuyAction(message)
    end
end

function ModularJetpack_HandleJetpackModularBuy(self, message)
    local exoConfig = ModularJetpac_ConvertNetMessageToConfig(message)
    
    local discount = 0
    if self:isa("Exo") then
        local isValid, badReason, resCost = ModularJetpac_GetIsConfigValid(ModularJetpac_ConvertNetMessageToConfig(self))
        discount = resCost
    end
    
    local isValid, badReason, resCost = ModularJetpac_GetIsConfigValid(exoConfig)
    resCost = resCost-discount
    //if resCost < 0 then
       // Print("Invalid exo config: no refunds!")
   // end
    if not isValid or resCost > self:GetResources() then
        Print("Invalid exo config: %s", badReason)
        return
    end
    self:AddResources(-resCost)
    
    local spawnPoint = ModularJetpac_FindExoSpawnPoint(self)
    if spawnPoint == nil then
        Print("Could not find exo spawnpoint")
        return
    end
    
    local weapons = self:GetWeapons()
    for i = 1, #weapons do            
        weapons[i]:SetParent(nil)            
    end
    local exoVariables = message
    
    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, exoVariables)     
    
    if not exo then
        Print("Could make replacement exo entity")
        return
    end
    if self:isa("Exo") then
        exo:SetMaxArmor(self:GetMaxArmor())
        exo:SetArmor(self:GetArmor())
    else
        exo.prevPlayerMapName = self:GetMapName()
        exo.prevPlayerHealth = self:GetHealth()
        exo.prevPlayerMaxArmor = self:GetMaxArmor()
        exo.prevPlayerArmor = self:GetArmor()
        for i = 1, #weapons do
            exo:StoreWeapon(weapons[i])
        end
    end
    
    exo:TriggerEffects("spawn_exo")
    
end
*/