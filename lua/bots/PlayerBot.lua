//=============================================================================
//
// lua\bots\PlayerBot.lua
//
// AI "bot" functions for goal setting and moving (used by Bot.lua).
//
// Created by Charlie Cleveland (charlie@unknownworlds.com)
// Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
//
// Updated by Dushan, Steve, 2013. The "brain" controls the higher level logic. A lot of this code is no longer used..
//
//=============================================================================

Script.Load("lua/bots/Bot.lua")
Script.Load("lua/bots/BotMotion.lua")
Script.Load("lua/bots/MarineBrain.lua")
Script.Load("lua/bots/SkulkBrain.lua")
Script.Load("lua/bots/GorgeBrain.lua")
Script.Load("lua/bots/LerkBrain.lua")
Script.Load("lua/bots/FadeBrain.lua")
Script.Load("lua/bots/OnosBrain.lua")

local kBotPersonalSettings = {
    { name = "Flayra", isMale = true },
    { name = "m4x0r", isMale = true },
    { name = "Ooghi", isMale = true },
    { name = "Breadman", isMale = true },
    { name = "Squeal Like a Pig", isMale = true },
    { name = "Chops", isMale = true },
    { name = "Numerik", isMale = true },
    { name = "SteveRock", isMale = true },
    { name = "Comprox", isMale = true },
    { name = "MonsieurEvil", isMale = true },
    { name = "Joev", isMale = true },
    { name = "puzl", isMale = true },
    { name = "Crispix", isMale = true },
    { name = "Kouji_San", isMale = true },
    { name = "TychoCelchuuu", isMale = true },
    { name = "Insane", isMale = true },
    { name = "CoolCookieCooks", isMale = true },
    { name = "devildog", isMale = true },
    { name = "tommyd", isMale = true },
    { name = "Relic25", isMale = true },
    { name = "Rantology", isMale = false },
    { name = "Bonkers", isMale = true },
    { name = "Strayan", isMale = true },
    { name = "Ashton M", isMale = true },
    { name = "McGlaspie", isMale = true },
    { name = "Darrin F.", isMale = true },
    { name = "GISP", isMale = true },
    { name = "Explosif.be", isMale = true },
    { name = "GeorgiCZ", isMale = true },
    { name = "Incredulous Dylan", isMale = true },
    { name = "Lachdanan", isMale = true },
    { name = "MGS-3", isMale = true },
    { name = "Mazza", isMale = true },
    { name = "Michael D.", isMale = true },
    { name = "OwNzOr", isMale = true },
    { name = "Patrick8675", isMale = true },
    { name = "KungFuDiscoMonkey", isMale = true },
    { name = "vartija", isMale = true },
    { name = "Railo", isMale = true },
    { name = "Brackhar", isMale = true },
    { name = "Zinkey", isMale = true },
    { name = "Steven G.", isMale = true },
    { name = "Tex", isMale = true },
    { name = "WDI", isMale = true },
    { name = "zaggynl", isMale = true },
    { name = "sewlek", isMale = true },
    { name = "Samusdroid", isMale = true },
    { name = "WasabiOne", isMale = true },
    { name = "Virsoul", isMale = true },
    { name = "Obraxis", isMale = true },
    { name = "ScardyBob", isMale = true },
    { name = "Matso", isMale = true },
    { name = "Ghoul", isMale = true },
    { name = "Mendasp", isMale = true },
    { name = "Zefram", isMale = true },
    { name = "Decoy", isMale = false },
	{ name = "Narfwak", isMale = true },
	{ name = "Zavaro", isMale = true },
	{ name = "remi.D", isMale = true },
	{ name = "BeigeAlert", isMale = true },
	{ name = "Ironhorse", isMale = true },
	{ name = "Asraniel", isMale = true },
	{ name = "moultano", isMale = true },
}

class 'PlayerBot' (Bot)

function PlayerBot:GetPlayerOrder()
    local order = nil
    local player = self:GetPlayer()
    if player and player.GetCurrentOrder then
        order = player:GetCurrentOrder()
    end
    return order
end

function PlayerBot:GivePlayerOrder(orderType, targetId, targetOrigin, orientation, clearExisting, insertFirst, giver)
    local player = self:GetPlayer()
    if player and player.GiveOrder then
        player:GiveOrder(orderType, targetId, targetOrigin, orientation, clearExisting, insertFirst, giver)
    end
end

function PlayerBot:GetPlayerHasOrder()
    local player = self:GetPlayer()
    if player and player.GetHasOrder then
        return player:GetHasOrder()
    end
    return false
end

function PlayerBot:GetNamePrefix()
    return "[BOT] "
end

function PlayerBot:UpdateNameAndGender()

    // Set name after a bit of time to simulate real players
    if self.botSetName == nil and math.random() < .2 then

        local player = self:GetPlayer()
        local name = player:GetName()
        local settings = kBotPersonalSettings[ math.random(1,#kBotPersonalSettings) ]

        self.botSetName = true
        
        name = self:GetNamePrefix()..TrimName(settings.name)
        player:SetName(name)

        // set gender
        self.client.variantData = {
            isMale = settings.isMale,
            marineVariant = kMarineVariant[kMarineVariant[math.random(1, #kMarineVariant)]],
            skulkVariant = kSkulkVariant[kSkulkVariant[math.random(1, #kSkulkVariant)]],
            gorgeVariant = kGorgeVariant[kGorgeVariant[math.random(1, #kGorgeVariant)]],
            lerkVariant = kLerkVariant[kLerkVariant[math.random(1, #kLerkVariant)]],
            fadeVariant = kFadeVariant[kFadeVariant[math.random(1, #kFadeVariant)]],
            onosVariant = kOnosVariant[kOnosVariant[math.random(1, #kOnosVariant)]],
            rifleVariant = kRifleVariant[kRifleVariant[math.random(1, #kRifleVariant)]],
            shotgunVariant = kShotgunVariant[kShotgunVariant[math.random(1, #kShotgunVariant)]],
            exoVariant = kExoVariant[kExoVariant[math.random(1, #kExoVariant)]],
            shoulderPadIndex = 0
        }
        self.client:GetControllingPlayer():OnClientUpdated(self.client)
        
    end
    
end

function PlayerBot:_LazilyInitBrain()

    if self.brain == nil then
        local player = self:GetPlayer()
        
        if player:isa("Marine") then
            self.brain = MarineBrain()
        elseif player:isa("Skulk") then
            self.brain = SkulkBrain()
        else
            // must be spectator - wait until we have joined a team
        end

        if self.brain ~= nil then
            self.brain:Initialize()
            self:GetPlayer().botBrain = self.brain
            self.aim = BotAim()
            self.aim:Initialize(self)
        end

    else

        // destroy brain if we are ready room
        if self:GetPlayer():isa("ReadyRoomPlayer") then
            self.brain = nil
            self:GetPlayer().botBrain = nil
        end

    end

end

/**
 * Responsible for generating the "input" for the bot. This is equivalent to
 * what a client sends across the network.
 */
function PlayerBot:GenerateMove()

    if gBotDebug:Get("spam") then
        Log("PlayerBot:GenerateMove")
    end

    self:_LazilyInitBrain()

    local move = Move()

    // Brain will modify move.commands and send desired motion to self.motion
    if self.brain ~= nil then

        // always clear view each frame
        self:GetMotion():SetDesiredViewTarget(nil)

        self.brain:Update(self,  move)

    end

    // Now do look/wasd

    local player = self:GetPlayer()
    if player ~= nil then

        local viewDir, moveDir, doJump = self:GetMotion():OnGenerateMove(player)

        move.yaw = GetYawFromVector(viewDir) - player:GetBaseViewAngles().yaw
        move.pitch = GetPitchFromVector(viewDir)

        moveDir.y = 0
        moveDir = moveDir:GetUnit()
        local zAxis = Vector(viewDir.x, 0, viewDir.z):GetUnit()
        local xAxis = zAxis:CrossProduct(Vector(0, -1, 0))
        local moveZ = moveDir:DotProduct(zAxis)
        local moveX = moveDir:DotProduct(xAxis)
        move.move = GetNormalizedVector(Vector(moveX, 0, moveZ))

        if doJump then
            move.commands = AddMoveCommand(move.commands, Move.Jump)
        end

    end
    
    return move

end

function PlayerBot:TriggerAlerts()

    local player = self:GetPlayer()
    
    local team = player:GetTeam()
    if player:isa("Marine") and team and team.TriggerAlert then
    
        local primaryWeapon = nil
        local weapons = player:GetHUDOrderedWeaponList()        
        if table.count(weapons) > 0 then
            primaryWeapon = weapons[1]
        end
        
        // Don't ask for stuff too often
        if not self.timeOfLastRequest or (Shared.GetTime() > self.timeOfLastRequest + 9) then
        
            // Ask for health if we need it
            if player:GetHealthScalar() < .4 and (math.random() < .3) then
            
                team:TriggerAlert(kTechId.MarineAlertNeedMedpack, player)
                self.timeOfLastRequest = Shared.GetTime()
                
            // Ask for ammo if we need it            
            elseif primaryWeapon and primaryWeapon:isa("ClipWeapon") and (primaryWeapon:GetAmmo() < primaryWeapon:GetMaxAmmo()*.4) and (math.random() < .25) then
            
                team:TriggerAlert(kTechId.MarineAlertNeedAmmo, player)
                self.timeOfLastRequest = Shared.GetTime()
                
            elseif (not self:GetPlayerHasOrder()) and (math.random() < .2) then
            
                team:TriggerAlert(kTechId.MarineAlertNeedOrder, player)
                self.timeOfLastRequest = Shared.GetTime()
                
            end
            
        end
        
    end
    
end

function PlayerBot:GetEngagementPointOverride()
    return self:GetModelOrigin()
end

function PlayerBot:GetMotion()

    if self.motion == nil then
        self.motion = BotMotion()
        self.motion:Initialize(self:GetPlayer())
    end

    return self.motion

end

function PlayerBot:OnThink()

    Bot.OnThink(self)

    local player = self:GetPlayer()

    if not self.initializedBot then
        self.prefersAxe = (math.random() < .5)
        self.inAttackRange = false
        self.initializedBot = true
    end
        
    self:UpdateNameAndGender()
    
end
