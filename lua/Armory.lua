Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/StunMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ParasiteMixin.lua")

class 'Armory' (ScriptActor)

Armory.kMapName = "armory"

Armory.kModelName = PrecacheAsset("models/marine/armory/armory.model")
local kAnimationGraph = PrecacheAsset("models/marine/armory/armory.animation_graph")

// Looping sound while using the armory
Armory.kResupplySound = PrecacheAsset("sound/NS2.fev/marine/structures/armory_resupply")

Armory.kArmoryBuyMenuUpgradesTexture = "ui/marine_buymenu_upgrades.dds"
Armory.kAttachPoint = "Root"

Armory.kAdvancedArmoryChildModel = PrecacheAsset("models/marine/advanced_armory/advanced_armory.model")
Armory.kAdvancedArmoryAnimationGraph = PrecacheAsset("models/marine/advanced_armory/advanced_armory.animation_graph")

Armory.kBuyMenuFlash = "ui/marine_buy.swf"
Armory.kBuyMenuTexture = "ui/marine_buymenu.dds"
Armory.kBuyMenuUpgradesTexture = "ui/marine_buymenu_upgrades.dds"
local kLoginAndResupplyTime = 0.3
Armory.kHealAmount = 25
Armory.kResupplyInterval = .8
gArmoryHealthHeight = 1.4
// Players can use menu and be supplied by armor inside this range
Armory.kResupplyUseRange = 2.5


Armory.kSentryGainXp =  0.06
//Armory.kSentryLoseXp = 0.06
Armory.kMaxLevel = 99

local kArmoryWeldGainXp =  0.45
local kArmoryScaleSize = 1.8


if Server then
    Script.Load("lua/Armory_Server.lua")
elseif Client then
    Script.Load("lua/Armory_Client.lua")
end

PrecacheAsset("models/marine/armory/health_indicator.surface_shader")
    
local networkVars =
{
    // How far out the arms are for animation (0-1)
    loggedInEast     = "boolean",
    loggedInNorth    = "boolean",
    loggedInSouth    = "boolean",
    loggedInWest     = "boolean",
    deployed         = "boolean",
   level = "float (0 to " .. Armory.kMaxLevel .. " by .1)",
   stunned = "boolean",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

function Armory:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, ParasiteMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end

    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    // False if the player that's logged into a side is only nearby, true if
    // the pressed their key to open the menu to buy something. A player
    // must use the armory once "logged in" to be able to buy anything.
    self.loginEastAmount = 0
    self.loginNorthAmount = 0
    self.loginWestAmount = 0
    self.loginSouthAmount = 0
    
    self.timeScannedEast = 0
    self.timeScannedNorth = 0
    self.timeScannedWest = 0
    self.timeScannedSouth = 0
    
    self.deployed = false
    self.level = 0
    self.stunned = false
end

// Check if friendly players are nearby and facing armory and heal/resupply them
local function LoginAndResupply(self)

    self:UpdateLoggedIn()
    
    // Make sure players are still close enough, alive, marines, etc.
    // Give health and ammo to nearby players.
    if GetIsUnitActive(self) then
        self:ResupplyPlayers()
    end
    
    return true
    
end

function Armory:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Armory.kModelName, kAnimationGraph)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)

    if Server then    
    
        self.loggedInArray = { false, false, false, false }
        
        // Use entityId as index, store time last resupplied
        self.resuppliedPlayers = { }

        self:AddTimedCallback(LoginAndResupply, kLoginAndResupplyTime)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, StunMixin)
    elseif Client then
    
        self:OnInitClient()        
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)
end
    function Armory:OnConstructionComplete()    
      local parent = self:GetParent()
       if parent then
         self:SetOrigin(self:GetOrigin() + Vector(0,1,0) )       
        end
         self:AddTimedCallback(Armory.SpawnWeapons, 8)
    end
function Armory:GetCanBeUsed(player, useSuccessTable)

    if player:isa("Exo") then
        useSuccessTable.useSuccess = false
    end
    
end

function Armory:GetCanBeUsedConstructed(byPlayer)
    return not byPlayer:isa("Exo")
end    
function Armory:GetMaxLevel()
return Armory.kMaxLevel
end
function Armory:GetAddXPAmount()
local bonus = self:GetLevel()/self:GetMaxLevel()
local experience = kArmoryWeldGainXp
      experience = ConditionalValue(self:GetIsSetup(), experience * 4, experience)
      experience = experience * bonus + experience
return  experience
end
function Armory:GetIsSetup()
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
function Armory:GetLevelPercentage()
return self.level / Armory.kMaxLevel * kArmoryScaleSize
end
/*
function Armory:GetAttachPointOriginHardcoded(attachPointName)
    return self:GetOrigin() + Vector(0,4,0)
end
*/
/*
function Armory:OnAttached(entity)
    entity:SetOrigin(self:GetOrigin() + Vector(0,1.5,0))
end
*/
/* Overboard
function Armory:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end
*/ 
function Armory:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, Armory.kMaxLevel - self.level)
        self.level = self.level + xpReward
       
        self:AdjustMaxHealth(kArmoryHealth * (self.level/Armory.kMaxLevel) + kArmoryHealth) 

      
    return xpReward
    
end
function Armory:GetIsStunAllowed()
    return self:GetLastStunTime() + 8 < Shared.GetTime() and not self.stunned and GetAreFrontDoorsOpen() //and not self:GetIsVortexed()
end
function Armory:LoseXP(amount)

        self.level = Clamp(self.level - amount, 0, 50)
        self:AdjustMaxHealth(kSentryHealth * (self.level/Armory.kMaxLevel) + kSentryHealth) 

      
    
end
function Armory:GetLevel()
        return Round(self.level, 2)
end

function Armory:GetTechIfResearched(buildId, researchId)

    local techTree = nil
    if Server then
        techTree = self:GetTeam():GetTechTree()
    else
        techTree = GetTechTree()
    end
    ASSERT(techTree ~= nil)
    
    // If we don't have the research, return it, otherwise return buildId
    local researchNode = techTree:GetTechNode(researchId)
    ASSERT(researchNode ~= nil)
    ASSERT(researchNode:GetIsResearch())
    return ConditionalValue(researchNode:GetResearched(), buildId, researchId)
    
end

function Armory:GetTechButtons(techId)

    local techButtons = nil

    techButtons = { kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
                    kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    
    return techButtons
    
end

function Armory:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    
   // if techId == kTechId.HeavyRifleTech then
  //      allowed = allowed and self:GetTechId() == kTechId.AdvancedArmory
  //  end
    
    return allowed, canAfford

end
function Armory:OverrideHintString( hintString, forEntity )
    
    if not GetAreEnemies(self, forEntity) then
        if self.healarmor then
            return string.format(Locale.ResolveString( "Heals Armor" ))
        end
    end

    return hintString
    
end
  function Armory:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Level %s Armory"), self:GetLevel())
return unitName
end  
function Armory:OnUpdatePoseParameters()

    if GetIsUnitActive(self) and self.deployed then
        
        if self.loginNorthAmount then
            self:SetPoseParam("log_n", self.loginNorthAmount)
        end
        
        if self.loginSouthAmount then
            self:SetPoseParam("log_s", self.loginSouthAmount)
        end
        
        if self.loginEastAmount then
            self:SetPoseParam("log_e", self.loginEastAmount)
        end
        
        if self.loginWestAmount then
            self:SetPoseParam("log_w", self.loginWestAmount)
        end
        
        if self.scannedParamValue then
        
            for extension, value in pairs(self.scannedParamValue) do
                self:SetPoseParam("scan_" .. extension, value)
            end
            
        end
        
    end
    
end

local function UpdateArmoryAnim(self, extension, loggedIn, scanTime, timePassed)

    local loggedInName = "log_" .. extension
    local loggedInParamValue = ConditionalValue(loggedIn, 1, 0)

    if extension == "n" then
        self.loginNorthAmount = Clamp(Slerp(self.loginNorthAmount, loggedInParamValue, timePassed * 2), 0, 1)
    elseif extension == "s" then
        self.loginSouthAmount = Clamp(Slerp(self.loginSouthAmount, loggedInParamValue, timePassed * 2), 0, 1)
    elseif extension == "e" then
        self.loginEastAmount = Clamp(Slerp(self.loginEastAmount, loggedInParamValue, timePassed * 2), 0, 1)
    elseif extension == "w" then
        self.loginWestAmount = Clamp(Slerp(self.loginWestAmount, loggedInParamValue, timePassed * 2), 0, 1)
    end
    
    local scannedName = "scan_" .. extension
    self.scannedParamValue = self.scannedParamValue or { }
    self.scannedParamValue[extension] = ConditionalValue(scanTime == 0 or (Shared.GetTime() > scanTime + 3), 0, 1)
    
end
function Armory:OnUpdateAnimationInput(modelMixin)


    modelMixin:SetAnimationInput("powered", true)


end
function Armory:OnUpdate(deltaTime)

    if Client then
        self:UpdateArmoryWarmUp()
    end
    
    if GetIsUnitActive(self) and self.deployed then
    
        // Set pose parameters according to if we're logged in or not
        UpdateArmoryAnim(self, "e", self.loggedInEast, self.timeScannedEast, deltaTime)
        UpdateArmoryAnim(self, "n", self.loggedInNorth, self.timeScannedNorth, deltaTime)
        UpdateArmoryAnim(self, "w", self.loggedInWest, self.timeScannedWest, deltaTime)
        UpdateArmoryAnim(self, "s", self.loggedInSouth, self.timeScannedSouth, deltaTime)
        
    end
    
    ScriptActor.OnUpdate(self, deltaTime)
    
end
function Armory:GetReceivesStructuralDamage()
    return true
end

function Armory:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function Armory:GetItemList(forPlayer)
    

    
        itemList = {   
            kTechId.LayMines,
            kTechId.HeavyMachineGun,
            kTechId.Shotgun,
            kTechId.Welder,
            kTechId.ClusterGrenade,
            kTechId.GasGrenade,
            kTechId.PulseGrenade,
            kTechId.GrenadeLauncher,
            kTechId.Flamethrower,
        }
 
      if not forPlayer.hasfirebullets then itemList[10] = kTechId.FireBullets end    
    return itemList
    
end

function Armory:GetHealthbarOffset()
    return gArmoryHealthHeight
end 
local kArmoryMinRange = 8
function GetArmoryRangeLimit(techId, origin, normal, commander)

    local armory = GetArmoryInRange(commander, origin)
    if armory then
    
        if (armory:GetOrigin() - origin):GetLength() < kArmoryMinRange then
            return false
        end

    end
return true
    
end
function GetofffComInRange(commander)

    local batteries = {}
    for _, battery in ipairs(GetEntitiesForTeam("OffCommandStation", commander:GetTeamNumber())) do
        batteries[battery] = 12
    end
    
    return batteries
    
end
function GetArmoryInRange(commander, origin)

local kClosestArmoryDistance = 99999
local closestarmory
    for _, armory in ipairs(GetEntitiesForTeam("Armory", commander:GetTeamNumber())) do
local dist = (armory:GetOrigin() - origin):GetLength()
        if dist < kClosestArmoryDistance then
            closestarmory = armory
kClosestArmoryDistance = dist
        end
    end
    
    return closestarmory
    
end
if Server then
    /* not used anymore since all animation are now client side
    function Armory:OnTag(tagName)
        if tagName == "deploy_end" then
            self.deployed = true
        end
    end
    */

end

Shared.LinkClassToMap("Armory", Armory.kMapName, networkVars)

class 'AdvancedArmory' (Armory)

AdvancedArmory.kMapName = "advancedarmory"

Shared.LinkClassToMap("AdvancedArmory", AdvancedArmory.kMapName, {})

class 'ArmoryAddon' (ScriptActor)

ArmoryAddon.kMapName = "ArmoryAddon"

local addonNetworkVars =
{
    // required for smoother raise animation
    creationTime = "float"
}
AddMixinNetworkVars(BaseModelMixin, addonNetworkVars) 
AddMixinNetworkVars(ClientModelMixin, addonNetworkVars)
AddMixinNetworkVars(TeamMixin, addonNetworkVars)

function ArmoryAddon:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, TeamMixin)
    
    if Server then
        self.creationTime = Shared.GetTime()
    end
    
    gArmoryHealthHeight = 1.7
    
end

function ArmoryAddon:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Armory.kAdvancedArmoryChildModel, Armory.kAdvancedArmoryAnimationGraph)
    
end

function ArmoryAddon:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    gArmoryHealthHeight = 1.4
    
end

function ArmoryAddon:OnUpdatePoseParameters()

    PROFILE("ArmoryAddon:OnUpdatePoseParameters")
    
    local researchProgress = Clamp((Shared.GetTime() - self.creationTime) / kAdvancedArmoryResearchTime, 0, 1)
    self:SetPoseParam("spawn", researchProgress)
    
end

function ArmoryAddon:OnUpdateAnimationInput(modelMixin)

    PROFILE("ArmoryAddon:OnUpdateAnimationInput")
    local parent = self:GetParent()
    if parent then
        modelMixin:SetAnimationInput("built", parent:GetTechId() == kTechId.AdvancedArmory)        
    end

end

function ArmoryAddon:OnGetIsVisible(visibleTable, viewerTeamNumber)

    local parent = self:GetParent()
    if parent then
        visibleTable.Visible = parent:GetIsVisible()
    end
    
end

Shared.LinkClassToMap("ArmoryAddon", ArmoryAddon.kMapName, addonNetworkVars)