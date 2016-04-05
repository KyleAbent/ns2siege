// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\ConstructMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

PrecacheAsset("cinematics/vfx_materials/build.surface_shader")

ConstructMixin = CreateMixin( ConstructMixin )
ConstructMixin.type = "Construct"

local kBuildMaterial = PrecacheAsset("cinematics/vfx_materials/build.material")

local kBuildEffectsInterval = 1
local kDrifterBuildRate = 1

ConstructMixin.networkVars =
{
    // 0-1 scalar representing build completion time. Since we use this to blend
    // animations, it must be interpolated for the animations to appear smooth
    // on the client.
    buildFraction           = "interpolated float (0 to 1 by 0.01)",
    
    // true if structure finished building
    constructionComplete    = "boolean",

    // Show different material when under construction
    underConstruction       = "boolean",
    mainbattle = "boolean",
    
}

ConstructMixin.expectedMixins =
{
    Live = "ConstructMixin manipulates the health when construction progresses."
}

ConstructMixin.expectedCallbacks = 
{
   -- GetIsaCreditStructure = "derp"
}

ConstructMixin.optionalCallbacks = 
{
    OnConstruct = "Called whenever construction progress changes.",
    OnConstructionComplete = "Called whenever construction is completes.",
    GetCanBeUsedConstructed = "Return true when this entity has a use function when constructed.",
    GetAddConstructHealth = "Return false to prevent adding health when constructing."
    
}


function ConstructMixin:__initmixin()

    // used for client side building effect
    self.underConstruction = false
    
    self.timeLastConstruct = 0
    self.timeOfNextBuildWeldEffects = 0
    self.buildTime = 0
    self.buildFraction = 0
    self.timeOfLastHealSpray = 0
    
    // Structures start with a percentage of their full health and gain more as they're built.
    if self.startsBuilt then
        self:SetHealth( self:GetMaxHealth() )
        self:SetArmor( self:GetMaxArmor() )
    else
        self:SetHealth( self:GetMaxHealth() * kStartHealthScalar )
        self:SetArmor( self:GetMaxArmor() * kStartHealthScalar )
    end

    self:AddTimedCallback(ConstructMixin.OnConstructUpdate, 0)
    
    self.startsBuilt  = false
    self.mainbattle = false
    
end

local function CreateBuildEffect(self)

    if not self.buildMaterial then
        
        local model = self:GetRenderModel()
        if model then
        
            local material = Client.CreateRenderMaterial()
            material:SetMaterial(kBuildMaterial)
            model:AddMaterial(material)
            self.buildMaterial = material
        
        end
        
    end    
    
end

local function RemoveBuildEffect(self)

    if self.buildMaterial then
      
        local model = self:GetRenderModel()  
        local material = self.buildMaterial
        model:RemoveMaterial(material)
        Client.DestroyRenderMaterial(material)
        self.buildMaterial = nil
                    
    end            

end

if Server then
  
function ConstructMixin:OnConstructUpdate(deltaTime)
        
    local effectTimeout = Shared.GetTime() - self.timeLastConstruct > 0.65
    self.underConstruction = not self:GetIsBuilt() and not effectTimeout
    
    // Only Alien structures auto build.
    // Update build fraction every tick to be smooth.
    if not self:GetIsBuilt() and GetIsAlienUnit(self) then

        if not self.GetCanAutoBuild or self:GetCanAutoBuild() then
        
            local multiplier = self.hasDrifterEnzyme and kDrifterBuildRate or kAutoBuildRate
            multiplier = multiplier * ( (HasMixin(self, "Catalyst") and self:GetIsCatalysted()) and kNutrientMistAutobuildMultiplier or 1 )
            self:Construct(deltaTime * multiplier)
            
        end
    
    end
    
    if self.timeDrifterConstructEnds then
        
        if self.timeDrifterConstructEnds <= Shared.GetTime() then
        
            self.hasDrifterEnzyme = false
            self.timeDrifterConstructEnds = nil
            
        end
        
    end

    // respect the cheat here; sometimes the cheat breaks due to things relying on it NOT being built until after a frame
    if GetGamerules():GetAutobuild() then
        self:SetConstructionComplete()
    end
    
    if self.underConstruction or not self.constructionComplete then
        return kUpdateIntervalFull
    end
    
    // stop running once we are fully constructed
    return false
    
end

end // Server

if Client then

function ConstructMixin:OnConstructUpdate(deltaTime)

    if GetIsMarineUnit(self) then
        if self.underConstruction then
            CreateBuildEffect(self)
        else
            RemoveBuildEffect(self)
        end
        if self.underConstruction or not self.constructionComplete then
            return kUpdateIntervalLow
        end
    end
    
    return false
    
end

end  // Client

function ConstructMixin:OnAdjustModelCoords(coords)

    if not self:GetIsBuilt() and self:GetTeamNumber() == 2 then
    	local scale = Clamp(self.buildFraction, .15, 1)
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
     end
   
    return coords
    
end

if Server then
    function ConstructMixin:TypesOfSelfInRoomNonCredit()
       local count = 0
       if ( self:GetIsBuilt() or self:isa("ArmsLab") ) and self:GetTeamNumber() == 1 and not self:isa("Dropship") and not self:isa("ARC") then count = count + 1 end 
        return count
    end
    function ConstructMixin:PreOnKill(attacker, doer, point, direction)
      if not self:isa("PowerPoint") and not self:isa("Extractor") then
                  local gameRules = GetGamerules()
              if gameRules then
              
                 local origin = self:GetOrigin()
                 if self:isa("ArmsLab") then
                   local nearestCC = GetNearest(origin, "CommandStation", 1)  
                   if nearestCC then 
                     origin = nearestCC:FindFreeSpace()
                     end
                  end
  
                 gameRules:DelayedAllowance(origin, self:TypesOfSelfInRoomNonCredit(), self:GetTechId(), self:GetMapName())
               end
       end
    end
    function ConstructMixin:OnKill()

        if not self:GetIsBuilt() then
        
            local techTree = self:GetTeam():GetTechTree()
            local techNode = techTree:GetTechNode(self:GetTechId())
            
            if techNode then
                techNode:SetResearchProgress(0.0)
                techTree:SetTechNodeChanged(techNode, "researchProgress = 1.0f")
            end 
            
        end
        
    end
    
end

function ConstructMixin:ModifyHeal(healTable)

    if not self:GetIsBuilt() then
    
        local maxFraction = kStartHealthScalar + (1 - kStartHealthScalar) * self.buildFraction    
        local maxHealth = self:GetMaxHealth() * maxFraction + self:GetMaxArmor() * maxFraction
        local health = self:GetHealth() + self:GetArmor()
        
        healTable.health = Clamp(maxHealth - health, 0, healTable.health) 
    
    end

end
function ConstructMixin:ResetConstructionStatus()

    self.buildTime = 0
    self.buildFraction = 0
    self.constructionComplete = false
    
end

function ConstructMixin:OnProcessMove(input)
    Log("%s: Called OnProcessMove???")
end

function ConstructMixin:OnUpdateAnimationInput(modelMixin)

    PROFILE("ConstructMixin:OnUpdateAnimationInput")    
    modelMixin:SetAnimationInput("built", self.constructionComplete)
    modelMixin:SetAnimationInput("active", self.constructionComplete) // TODO: remove this and adjust animation graphs
    
end

function ConstructMixin:OnUpdatePoseParameters()

    self:SetPoseParam("grow", self.buildFraction)
    
end    

/**
 * Add health to structure as it builds.
 */
local function AddBuildHealth(self, scalar)

    // Add health according to build time.
    if scalar > 0 then
    
        local maxHealth = self:GetMaxHealth()
        self:AddHealth(scalar * (1 - kStartHealthScalar) * maxHealth, false, false, true)
        
    end
    
end

/**
 * Add health to structure as it builds.
 */
local function AddBuildArmor(self, scalar)

    // Add health according to build time.
    if scalar > 0 then
    
        local maxArmor = self:GetMaxArmor()
        self:SetArmor(self:GetArmor() + scalar * (1 - kStartHealthScalar) * maxArmor, true)
        
    end
    
end

/**
 * Build structure by elapsedTime amount and play construction sounds. Pass custom construction sound if desired, 
 * otherwise use Gorge build sound or Marine sparking build sounds. Returns two values - whether the construct
 * action was successful and if enough time has elapsed so a construction AV effect should be played.
 */
function ConstructMixin:Construct(elapsedTime, builder)

    local success = false
    local playAV = false
    
    if not self.constructionComplete and (not HasMixin(self, "Live") or self:GetIsAlive()) then
        
        if builder and builder.OnConstructTarget then
            builder:OnConstructTarget(self)
        end
        
        if Server then

            if not self.lastBuildFractionTechUpdate then
                self.lastBuildFractionTechUpdate = self.buildFraction
            end
            
            local techTree = self:GetTeam():GetTechTree()
            local techNode = techTree:GetTechNode(self:GetTechId())
            local modifier = (not self:isa("PowerPoint") and not self:isa("ARC") and self:GetTeamType() == kMarineTeamType and GetIsPointOnInfestation(self:GetOrigin())) and .3 or 1
            modifier = modifier * kDynamicBuildSpeed 
            modifier = modifier * ConditionalValue(self:SetupAdvantage(), 2, 1)
            modifier = modifier * ConditionalValue(self:GetTeamType() ~= kMarineTeamType and self:SiegeDisAdvantage(), 0.10, 1)
            modifier = modifier * ConditionalValue(self:GetTeamType() == kMarineTeamType and self:SiegeDisAdvantageMarine(), .5, 1)
            local startBuildFraction = self.buildFraction
            local newBuildTime = self.buildTime + elapsedTime * modifier
            local timeToComplete = self:GetTotalConstructionTime()            
            
            if newBuildTime >= timeToComplete then
            
                self:SetConstructionComplete(builder)
                
                if techNode then
                    techNode:SetResearchProgress(1.0)
                    techTree:SetTechNodeChanged(techNode, "researchProgress = 1.0f")
                end    
                
            else
            
                if self.buildTime <= self.timeOfNextBuildWeldEffects and newBuildTime >= self.timeOfNextBuildWeldEffects then
                
                    playAV = true
                    self.timeOfNextBuildWeldEffects = newBuildTime + kBuildEffectsInterval
                    
                end
                
                self.timeLastConstruct = Shared.GetTime()
                self.underConstruction = true
                
                self.buildTime = newBuildTime
                self.oldBuildFraction = self.buildFraction
                self.buildFraction = math.max(math.min((self.buildTime / timeToComplete), 1), 0)
                
                if techNode and (self.buildFraction - self.lastBuildFractionTechUpdate) >= 0.05 then
                
                    techNode:SetResearchProgress(self.buildFraction)
                    techTree:SetTechNodeChanged(techNode, string.format("researchProgress = %.2f", self.buildFraction))
                    self.lastBuildFractionTechUpdate = self.buildFraction
                    
                end
                
                if not self.GetAddConstructHealth or self:GetAddConstructHealth() then
                
                    local scalar = self.buildFraction - startBuildFraction
                    AddBuildHealth(self, scalar)
                    AddBuildArmor(self, scalar)
                
                end
                
                if self.oldBuildFraction ~= self.buildFraction then
                
                    if self.OnConstruct then
                        self:OnConstruct(builder, self.buildFraction, self.oldBuildFraction)
                    end
                    
                end
                
            end
        
        end
        
        success = true
        
    end
    
    if playAV then

        local builderClassName = builder and builder:GetClassName()    
        self:TriggerEffects("construct", {classname = self:GetClassName(), doer = builderClassName, isalien = GetIsAlienUnit(self)})
        
    end 
    
    return success, playAV
    
end
function ConstructMixin:SetupAdvantage()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetFrontDoorsOpen() then 
                   return false
               end
            end
        end
            return true
end
function ConstructMixin:SiegeDisAdvantage()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               local location = GetLocationForPoint(self:GetOrigin())
               local locationName = location and location:GetName() or ""
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   if string.find(locationName, "Siege") or string.find(locationName, "siege") then return true end
               end
            end
        end
            return false
end
function ConstructMixin:SiegeDisAdvantageMarine()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               local location = GetLocationForPoint(self:GetOrigin())
               local locationName = location and location:GetName() or ""
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   if not string.find(locationName, "Siege") and not string.find(locationName, "siege") then return true end
               end
            end
        end
            return false
end
function ConstructMixin:GetCanBeUsedConstructed(byPlayer)
    return false
end

function ConstructMixin:GetCanBeUsed(player, useSuccessTable)

    if self:GetIsBuilt() and not self:GetCanBeUsedConstructed(player) then
        useSuccessTable.useSuccess = false
    end
    
end

function ConstructMixin:SetConstructionComplete(builder)

    // Construction cannot resurrect the dead.
    if self:GetIsAlive() then
    
        local wasComplete = self.constructionComplete
        self.constructionComplete = true
        
        AddBuildHealth(self, 1 - self.buildFraction)
        AddBuildArmor(self, 1 - self.buildFraction)
        
        self.buildFraction = 1
        
        if wasComplete ~= self.constructionComplete then
            self:OnConstructionComplete(builder)
        end
        
    end
    
end


function ConstructMixin:GetCanConstruct(constructor)

    if self.GetCanConstructOverride then
        return self:GetCanConstructOverride(constructor)
    end
   /* 
    // Check if we're on infestation
    // Doing the origin-based check may be expensive, but this is only done sparsely. And better than tracking infestation all the time.
    if LookupTechData(self:GetTechId(), kTechDataNotOnInfestation) and GetIsPointOnInfestation(self:GetOrigin()) then
        return false
    end
    */
    return not self:GetIsBuilt() and GetAreFriends(self, constructor) and self:GetIsAlive() and
           (not constructor or constructor:isa("Marine") or constructor:isa("Gorge") or constructor:isa("MAC"))
    
end

function ConstructMixin:OnUse(player, elapsedTime, useSuccessTable)

    local used = false

    if not GetIsAlienUnit(self) and self:GetCanConstruct(player) then        

        // Always build by set amount of time, for AV reasons
        // Calling code will put weapon away we return true

        local success, playAV = self:Construct(player.buildspeed, player)
        
        if success then

            used = true
        
        end
                
    end
    
    useSuccessTable.useSuccess = useSuccessTable.useSuccess or used
    
end

function ConstructMixin:RefreshDrifterConstruct()

    self.timeDrifterConstructEnds = Shared.GetTime() + 0.3
    self.hasDrifterEnzyme = true

end

function ConstructMixin:OnHealSpray(gorge)

    if not gorge:isa("Gorge") then
        return
    end

    if GetIsAlienUnit(self) and GetAreFriends(self, gorge) and not self:GetIsBuilt() then
    
        local currentTime = Shared.GetTime()
        
        -- Multiple Gorges scale non-linearly 
        local timePassed = Clamp((currentTime - self.timeOfLastHealSpray), 0, kMaxBuildTimePerHealSpray)
        local constructTimeForSpray = math.min(kMinBuildTimePerHealSpray + timePassed, kMaxBuildTimePerHealSpray)

        --Print("added time: %.2f (time passed: %.2f)", constructTimeForSpray, timePassed)
        
        local success, playAV = self:Construct(constructTimeForSpray, gorge)
        
        self.timeOfLastHealSpray = currentTime
        
    end

end

function ConstructMixin:GetIsBuilt()
    return self.constructionComplete
end

function ConstructMixin:OnConstructionComplete(builder)

    local team = HasMixin(self, "Team") and self:GetTeam()
    
    if team then

        if self.GetCompleteAlertId then
            team:TriggerAlert(self:GetCompleteAlertId(), self)
            
        elseif GetIsMarineUnit(self) then

            if builder and builder:isa("MAC") then    
                team:TriggerAlert(kTechId.MACAlertConstructionComplete, self)
            else            
                team:TriggerAlert(kTechId.MarineAlertConstructionComplete, self)
            end
            
        end

        team:OnConstructionComplete(self)

    end     

    self:TriggerEffects("construction_complete")
    
end    
function ConstructMixin:GetIsSetup()
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
function ConstructMixin:GetBuiltFraction()
    return self.buildFraction
end
function ConstructMixin:GetTotalConstructionTime()      
      if self:isa("ARC") then return 24 end  --Cheap trick
             //Remember the dynamic mult of buildspeed is applying during after front and even greater bonus during setup
   local marineadvantage = 12

   
   if Server then
          local gameRules = GetGamerules()
            if gameRules then
                 if  gameRules:GetSiegeDoorsOpen() then
                    marineadvantage = self:GetTeamNumber() == 1 and 4 or 8
              --       if self:isa("Hive") then
              --        marineadvantage = marineadvantage * 4
              --       end
                 elseif gameRules:GetFrontDoorsOpen() then
                    marineadvantage = self:GetTeamNumber() == 1 and 8 or 12
                 else //setup
                  marineadvantage =  self:GetTeamNumber() == 1 and 4 or 8
                  
                            //Troll hive in marine base gamebreaking with eggs :P
                      if self:isa("Hive") and not self:IsInRangeOfHive() then
                      marineadvantage = 300
                     end
                     
                     
                  end
             end  
   end
   
   marineadvantage = self:isa("CommandStructure") and marineadvantage * 8 or marineadvantage
   marineadvantage = self:isa("Harvester") and  marineadvantage * 1.7 or marineadvantage
   

    return marineadvantage
    
end
function ConstructMixin:IsInRangeOfHive()
      local hives = GetEntitiesWithinRange("Hive", self:GetOrigin(), kARCRange)
   if #hives >=2 then return true end
   return false
end
if Server then

    function ConstructMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)
    
       
        if not self.mainbattle or ( self:GetIsSiege() and not string.find(self:GetLocationName(), "Siege") and not string.find(self:GetLocationName(), "siege") ) then 
         damageTable.damage = damageTable.damage * kMainRoomDamageMult
        end
        
    end
       function ConstructMixin:GetIsSiege()
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   return true
               end
            end
            return false
      end
    function ConstructMixin:Reset()

        if self.startsBuilt then
            self:SetConstructionComplete()
        end
        
    end

    function ConstructMixin:OnInitialized()

        self.startsBuilt = GetAndCheckBoolean(self.startsBuilt, "startsBuilt", false)

        if (self.startsBuilt and not self:GetIsBuilt()) then
            self:SetConstructionComplete()
        end
        
    end

end

function ConstructMixin:GetEffectParams(tableParams)

    tableParams[kEffectFilterBuilt] = self:GetIsBuilt()
        
end
