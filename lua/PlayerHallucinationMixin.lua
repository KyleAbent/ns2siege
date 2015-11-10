// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\PlayerHallucinationMixin.lua    
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

if Server then

    Script.Load("lua/bots/Bot.lua")

    PlayerHallucinationMixin = CreateMixin(PlayerHallucinationMixin)
    PlayerHallucinationMixin.type = "PlayerHallucination"
    
    PlayerHallucinationMixin.overrideFunctions =
    {
        "GetIsAllowedToBuy",
    }    
    
    function PlayerHallucinationMixin:ModifyHealingDone(health)
        return 0
    end    
    
    function PlayerHallucinationMixin:GetIsAllowedToBuy()
        return false   
    end 

    function PlayerHallucinationMixin:ComputeDamageAttackerOverrideMixin(attacker, damage, damageType, doer, hitPoint)   
        return 0
    end
    
    function PlayerHallucinationMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)
    
        local multiplier = 8
    
        if self:isa("Skulk") then
            multiplier = 6
    
        elseif self:isa("Fade") then        
            multiplier = 12

        elseif self:isa("Onos") then
            multiplier = 14
        end
    
        damageTable.damage = damageTable.damage * multiplier
        
    end

    function PlayerHallucinationMixin:OnUpdate(deltaTime)

        if not self:GetIsAlive() then
            return
        end

        // generate moves for the hallucination server side
        if not self.brain then
            
            // TODO: add brains for other life forms
            if self:isa("Skulk") then
                self.brain = SkulkBrain()
            
            elseif self:isa("Gorge") then
                self.brain = GorgeBrain()

            elseif self:isa("Lerk") then
                self.brain = LerkBrain()

            elseif self:isa("Fade") then
                self.brain = FadeBrain()
                
            elseif self:isa("Onos") then
                self.brain = OnosBrain()
            end
            
            self.brain:Initialize()
            
        end
        
        local move = Move()
        self:GetMotion():SetDesiredViewTarget(nil)
        self.brain:Update(self, move)
        
        local viewDir, moveDir, doJump = self:GetMotion():OnGenerateMove(self)

        move.yaw = GetYawFromVector(viewDir) - self:GetBaseViewAngles().yaw
        move.pitch = GetPitchFromVector(viewDir)

        moveDir.y = 0
        moveDir = moveDir:GetUnit()
        local zAxis = Vector(viewDir.x, 0, viewDir.z):GetUnit()
        local xAxis = zAxis:CrossProduct(Vector(0, -1, 0))
        local moveX = moveDir:DotProduct(xAxis)
        local moveZ = moveDir:DotProduct(zAxis)
        
        if moveX ~= 0 then
            moveX = GetSign(moveX)
        end
        
        if moveZ ~= 0 then
            moveZ = GetSign(moveZ)
        end
        
        move.move = Vector(moveX, 0, moveZ)

        if doJump then
            move.commands = AddMoveCommand(move.commands, Move.Jump)
        end
        
        move.time = deltaTime

        // do with that move now what a real player would do
        self:OnProcessMove(move)
        
        UpdateHallucinationLifeTime(self)

    end

    function PlayerHallucinationMixin:GetPlayer()
        return self
    end

    PlayerHallucinationMixin.GetMotion = PlayerBot.GetMotion
    PlayerHallucinationMixin.GetPlayerOrder = PlayerBot.GetPlayerOrder
    PlayerHallucinationMixin.GivePlayerOrder = PlayerBot.GivePlayerOrder
    PlayerHallucinationMixin.GetPlayerHasOrder = PlayerBot.GetPlayerHasOrder
    

end