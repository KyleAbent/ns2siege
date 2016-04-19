Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/UpgradableMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/DissolveMixin.lua")

Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/IdleMixin.lua")

class 'Shift' (ScriptActor)

Shift.kMapName = "shift"

Shift.kModelName = PrecacheAsset("models/alien/shift/shift.model")

local kAnimationGraph = PrecacheAsset("models/alien/shift/shift.animation_graph")

Shift.kEchoTargetSound = PrecacheAsset("sound/NS2.fev/alien/structures/shift/energize")
Shift.kShiftEchoSound2D = PrecacheAsset("sound/NS2.fev/alien/structures/shift/energize_player")

Shift.kEnergizeSoundEffect = PrecacheAsset("sound/NS2.fev/alien/structures/shift/energize")
Shift.kEnergizeTargetSoundEffect = PrecacheAsset("sound/NS2.fev/alien/structures/shift/energize_player")
--Shift.kRecallSoundEffect = PrecacheAsset("sound/NS2.fev/alien/structures/shift/recall")


Shift.kEnergizeEffect = PrecacheAsset("cinematics/alien/shift/energize.cinematic")
Shift.kEnergizeSmallTargetEffect = PrecacheAsset("cinematics/alien/shift/energize_small.cinematic")
Shift.kEnergizeLargeTargetEffect = PrecacheAsset("cinematics/alien/shift/energize_large.cinematic")

Shift.kEchoMaxRange = 20

Shift.MaxLevel = 99
Shift.GainXP = 1

local kNumEggSpotsPerShift = 20

local kEchoCooldown = 1

local networkVars =
{
    moving = "boolean",
    level = "float (0 to " .. Shift.MaxLevel .. " by .1)",
     siegewall = "boolean", 
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)

function Shift:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, TeleportMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    
    
    if Server then
    
        InitMixin(self, InfestationTrackerMixin)
        
    elseif Client then
        InitMixin(self, CommanderGlowMixin)    
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
     self.level = 1
    self.siegewall = false
    
end

function Shift:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Shift.kModelName, kAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, RepositioningMixin)
        
        self:AddTimedCallback(Shift.EnergizeInRange, 1)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)

end

function Shift:EnergizeInRange()

    if self:GetIsBuilt() and not self:GetIsOnFire() then
    
        local energizeAbles = GetEntitiesWithMixinForTeamWithinRange("Energize", self:GetTeamNumber(), self:GetOrigin(), kEnergizeRange)
        
        
            if self.siegewall then 
               local siegeroom = self:GetSiegeRoomLocation()
              local entities = siegeroom:GetEntitiesInTrigger()
            if #entities ~= 0 then  
             for i = 1, #entities do
               local healable = entities[i]
                 if healable:GetIsAlive() and healable:isa("Player") and not healable:isa("Commander") then
                 table.insertunique(energizeAbles, healable)
                 end
              end
           end
          end 
    
        for _, entity in ipairs(energizeAbles) do
        
            if entity ~= self then
                entity:Energize(self)
                self:Enzymey(entity)
            end
            
        end
        
        
        
    
    end
    
    return self:GetIsAlive()
    
end
function Shift:GetSiegeRoomLocation()

            for index, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
              if  string.find(location.name, "siege") or string.find(location.name, "Siege") and not
                string.find(location.name, "Hall") and not string.find(location.name, "hall") then 
                  return location
                end 
              end
                
                
end
function Shift:Enzymey(entity)
                
                if entity:isa("Alien") then
                 local number = math.random(self.level, 100)
                 if number >= 99 then entity:TriggerEnzyme(4) end
                end
                
end
function Shift:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function Shift:GetReceivesStructuralDamage()
    return true
end

function Shift:PreventTurning()
    return true
end

function Shift:OverrideRepositioningSpeed()
    return kAlienStructureMoveSpeed * 2.5
end

function Shift:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player) 
    
    allowed = allowed and not self.echoActive and not self:GetIsOnFire()
    
    return allowed, canAfford
    
end


function Shift:GetCanReposition()
    return true
end

function Shift:GetTechButtons(techId)

    local techButtons
                

        techButtons = { kTechId.ShiftEnergize, kTechId.Move, kTechId.None, kTechId.None, 
                        kTechId.None, kTechId.None, kTechId.None, kTechId.RootMenu }   

        if self.moving then
            techButtons[2] = kTechId.Stop
        end            


    return techButtons   

end

function Shift:OnUpdateAnimationInput(modelMixin)

    PROFILE("Shift:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("moving", self.moving)
    
end

function Shift:GetMaxSpeed()
    return kAlienStructureMoveSpeed
end
function Shift:GetAddXPAmount()
return self:GetIsSetup() and Shift.GainXP * 4 or Shift.GainXP
end
function Shift:GetIsSetup()
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
function Shift:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, Shift.MaxLevel - self.level)
        self.level = self.level + xpReward
   
      
   // self:AdjustMaxHealth(kHydraHealth * (self.level/100) + kHydraHealth) 
   // self:AdjustMaxArmor(kHydraArmor * (self.level/100) + kHydraArmor)
    
    return xpReward
    
end
function Shift:GetLevel()
        return Round(self.level, 2)
end
  function Shift:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Level %s Shift"), self:GetLevel())
return unitName
end 
function Shift:OnUpdate(deltaTime)

    PROFILE("Shift:OnUpdate")

    ScriptActor.OnUpdate(self, deltaTime)
    UpdateAlienStructureMove(self, deltaTime)        

    if Server then
    
            if self.Levelslowly == nil or (Shared.GetTime() > self.Levelslowly + 4) then
            self:AddXP(Shift.GainXP * 4)
            self.Levelslowly = Shared.GetTime()
            end
    
    end
        
end

if Server then

    function Shift:OnTeleportEnd()
        self:ResetPathing()
    end

    function Shift:OnResearchComplete(researchId)

        -- Transform into mature shift
        if researchId == kTechId.EvolveEcho then
            self:GiveUpgrade(kTechId.ShiftEcho)
    elseif researchId == kTechId.Digest then
        self:TriggerEffects("digest", {effecthostcoords = self:GetCoords()} )
        self:Kill()
    end
        
    end

end

function GetShiftIsBuilt(techId, origin, normal, commander)

    -- check if there is a built command station in our team
    if not commander then
        return false
    end    
    
    local attachRange = LookupTechData(kTechId.ShiftHatch, kStructureAttachRange, 1)
    
    local shifts = GetEntitiesForTeamWithinRange("Shift", commander:GetTeamNumber(), origin, attachRange)
    for _, shift in ipairs(shifts) do
        
        if shift:GetIsBuilt() then
            return true
        end    
        
    end
    
    return false
    
end
function Shift:OnConstructionComplete()
         local commander = self:GetTeam():GetCommander()
       if commander ~= nil then
       commander:AddScore(1) 
       end
end

function Shift:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

Shared.LinkClassToMap("Shift", Shift.kMapName, networkVars)