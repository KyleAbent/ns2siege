// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Marine.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Player.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/Mixins/LadderMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/OrderSelfMixin.lua")
Script.Load("lua/MarineActionFinderMixin.lua")
Script.Load("lua/StunMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/GlowMixin.lua")
Script.Load("lua/SprintMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/ScoringMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
//Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/DisorientableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/WebableMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/PhaseGateUserMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/MarineVariantMixin.lua")
Script.Load("lua/MarineOutlineMixin.lua")

if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end

class 'Marine' (Player)

Marine.kMapName = "marine"

if Server then
    Script.Load("lua/Marine_Server.lua")
elseif Client then
    Script.Load("lua/Marine_Client.lua")
end

PrecacheAsset("models/marine/marine.surface_shader")
PrecacheAsset("models/marine/marine_noemissive.surface_shader")

Marine.kFlashlightSoundName = PrecacheAsset("sound/NS2.fev/common/light")
Marine.kGunPickupSound = PrecacheAsset("sound/NS2.fev/marine/common/pickup_gun")
Marine.kSpendResourcesSoundName = PrecacheAsset("sound/NS2.fev/marine/common/player_spend_nanites")
Marine.kChatSound = PrecacheAsset("sound/NS2.fev/marine/common/chat")
Marine.kSoldierLostAlertSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/soldier_lost")

Marine.activatedsound = PrecacheAsset("sound/siegeroom.fev/webactivate/activated")

Marine.kFlinchEffect = PrecacheAsset("cinematics/marine/hit.cinematic")
Marine.kFlinchBigEffect = PrecacheAsset("cinematics/marine/hit_big.cinematic")

Marine.kHitGroundStunnedSound = PrecacheAsset("sound/NS2.fev/marine/common/jump")
Marine.kSprintStart = PrecacheAsset("sound/NS2.fev/marine/common/sprint_start")
Marine.kSprintTiredEnd = PrecacheAsset("sound/NS2.fev/marine/common/sprint_tired")
//The longer running sound, sprint_start, would be ideally the sprint_end soudn instead. That is what is done here
Marine.kSprintStartFemale = PrecacheAsset("sound/NS2.fev/marine/common/sprint_tired_female")                                                                      
Marine.kSprintTiredEndFemale = PrecacheAsset("sound/NS2.fev/marine/common/sprint_start_female")

Marine.kEffectNode = "fxnode_playereffect"
Marine.kHealth = kMarineHealth
Marine.kBaseArmor = kMarineArmor
Marine.kArmorPerUpgradeLevel = kArmorPerUpgradeLevel
Marine.kMaxSprintFov = 95
// Player phase delay - players can only teleport this often
Marine.kPlayerPhaseDelay = 2

Marine.kWalkMaxSpeed = 5                // Four miles an hour = 6,437 meters/hour = 1.8 meters/second (increase for FPS tastes)
Marine.kRunMaxSpeed = 6.0               // 10 miles an hour = 16,093 meters/hour = 4.4 meters/second (increase for FPS tastes)
Marine.kRunInfestationMaxSpeed = 5.2    // 10 miles an hour = 16,093 meters/hour = 4.4 meters/second (increase for FPS tastes)

// How fast does our armor get repaired by welders
Marine.kArmorWeldRate = kMarineArmorWeldRate
Marine.kWeldedEffectsInterval = .5

Marine.kSpitSlowDuration = 3

Marine.kWalkBackwardSpeedScalar = 0.4

// start the get up animation after stun before giving back control
Marine.kGetUpAnimationLength = 0

// tracked per techId
Marine.kMarineAlertTimeout = 4

local kDropWeaponTimeLimit = 1
local kPickupWeaponTimeLimit = 1

Marine.kAcceleration = 100
Marine.kSprintAcceleration = 120 // 70
Marine.kSprintInfestationAcceleration = 60

Marine.kGroundFrictionForce = 16

Marine.kAirStrafeWeight = 2

PrecacheAsset("models/marine/rifle/rifle_shell_01.dds")
PrecacheAsset("models/marine/rifle/rifle_shell_01_normal.dds")
PrecacheAsset("models/marine/rifle/rifle_shell_01_spec.dds")
PrecacheAsset("models/marine/rifle/rifle_view_shell.model")
PrecacheAsset("models/marine/rifle/rifle_shell.model")
PrecacheAsset("models/marine/arms_lab/arms_lab_holo.model")
PrecacheAsset("models/effects/frag_metal_01.model")
PrecacheAsset("cinematics/vfx_materials/vfx_circuit_01.dds")
PrecacheAsset("materials/effects/nanoclone.dds")
PrecacheAsset("cinematics/vfx_materials/bugs.dds")
PrecacheAsset("cinematics/vfx_materials/refract_water_01_normal.dds")

local networkVars =
{      
    flashlightOn = "boolean",
    
    timeOfLastDrop = "private time",
    timeOfLastPickUpWeapon = "private time",
    
    flashlightLastFrame = "private boolean",
    
    timeLastSpitHit = "private time",
    lastSpitDirection = "private vector",
    
    ruptured = "boolean",
    interruptAim = "private boolean",
    poisoned = "boolean",
    catpackboost = "boolean",
    timeCatpackboost = "private time",
    weaponUpgradeLevel = "integer (0 to 3)",
    
    unitStatusPercentage = "private integer (0 to 100)",
    
    strafeJumped = "private compensated boolean",
    
    timeLastBeacon = "private time",
    spawnprotection = "boolean",
    modelsize = "float (0 to 10 by .1)",
   modelsize = "float (0 to 10 by .1)",
   minemode = "boolean",
   RTDinfiniteammomode = "boolean",
   hasjumppack = "boolean",
       lastjump  = "time",
   hasfirebullets = "boolean",
   hasreupply = "boolean",
      heavyarmor = "boolean",
   lastsupply = "time",
   suppliesleft = "float (0 to 5 by 1)",
   
    
}

AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(LadderMoveMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(GlowMixin, networkVars)
AddMixinNetworkVars(SprintMixin, networkVars)
AddMixinNetworkVars(OrderSelfMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
//AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(WebableMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(PhaseGateUserMixin, networkVars)
AddMixinNetworkVars(MarineVariantMixin, networkVars)
AddMixinNetworkVars(ScoringMixin, networkVars)

function Marine:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, LadderMoveMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, MarineActionFinderMixin)
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    //InitMixin(self, VortexAbleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, SelectableMixin)
    
    Player.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, PhaseGateUserMixin)
    InitMixin(self, PredictedProjectileShooterMixin)
    InitMixin(self, MarineVariantMixin)
    
    if Server then
    
        self.timePoisoned = 0
        self.poisoned = false
        
        // stores welder / builder progress
        self.unitStatusPercentage = 0
        self.timeLastUnitPercentageUpdate = 0

        
    elseif Client then
    
        self.flashlight = Client.CreateRenderLight()
        
        self.flashlight:SetType( RenderLight.Type_Spot )
        self.flashlight:SetColor( Color(.8, .8, 1) )
        self.flashlight:SetInnerCone( math.rad(30) )
        self.flashlight:SetOuterCone( math.rad(35) )
        self.flashlight:SetIntensity( 10 )
        self.flashlight:SetRadius( 15 ) 
        self.flashlight:SetGoboTexture("models/marine/male/flashlight.dds")
        
        self.flashlight:SetIsVisible(false)
        
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })

        InitMixin(self, DisorientableMixin)
        self:SetCameraDistance(0)
        
    end
    if not self:isa("JetpackMarine") then self.spawnprotection = true end
   self.modelsize = 1 
   self.minemode = false
   self.RTDinfiniteammomode = false
   self.hasjumppack = false
   self.lastjump = 0
   self.hasfirebullets = false
   self.hasreupply = false
   self.heavyarmor = false
   self.lastsupply = 0
   self.suppliesleft = 5
end

local function UpdateNanoArmor(self)
    self.hasNanoArmor = false // self:GetWeapon(Welder.kMapName)
    return true
end
function Marine:GetHasMineMode()
return self.minemode
end
function Marine:GetCanJump()
    return not self:GetIsWebbed() and ( self:GetIsOnGround() or self:GetIsOnLadder() )
end
/*
function Marine:ToggleTaunt(duration)
self.istaunting = true
self.isMoveBlocked = true
self:SetCameraDistance(3)
self:AddTimedCallback(function()  self.istaunting = false self.isMoveBlocked = false self:SetCameraDistance(0) end, duration)
end
*/
function Marine:OnInitialized()

    // work around to prevent the spin effect at the infantry portal spawned from
    // local player should not see the holo marine model
    if Client and Client.GetIsControllingPlayer() then
    
        local ips = GetEntitiesForTeamWithinRange("InfantryPortal", self:GetTeamNumber(), self:GetOrigin(), 1)
        if #ips > 0 then
            Shared.SortEntitiesByDistance(self:GetOrigin(), ips)
            ips[1]:PreventSpinEffect(0.2)
        end
        
    end
    
    // These mixins must be called before SetModel because SetModel eventually
    // calls into OnUpdatePoseParameters() which calls into these mixins.
    // Yay for convoluted class hierarchies!!!
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })
    InitMixin(self, OrderSelfMixin, { kPriorityAttackTargets = { "Harvester" } })
    InitMixin(self, StunMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, GlowMixin)
    InitMixin(self, SprintMixin)
    InitMixin(self, WeldableMixin)
    
    // SetModel must be called before Player.OnInitialized is called so the attach points in
    // the Marine are valid to attach weapons to. This is far too subtle...
    self:SetModel(self:GetVariantModel(), MarineVariantMixin.kMarineAnimationGraph)
    
    Player.OnInitialized(self)
    
    // Calculate max and starting armor differently
    self.armor = 0
    
    if Server then
    
        //self.armor = self:GetArmorAmount()
       // self.maxArmor = self.armor
       
        self:SetArmorAmount()
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, InfestationTrackerMixin)
        self.timeRuptured = 0
        self.interruptStartTime = 0
        self.timeLastPoisonDamage = 0
        
        self.lastPoisonAttackerId = Entity.invalidId
        
        self:AddTimedCallback(UpdateNanoArmor, 1)
        if self:GetIsAlive() and self:GetTeamNumber() == 1 and not self:isa("JetpackMarine") then
       self:AddTimedCallback(function()  self:ActivateNanoShield() end, 0.06)
       self:AddTimedCallback(function()  self.spawnprotection = false end, kMarineRespawnProtection)
       end
    elseif Client then
    
        InitMixin(self, HiveVisionMixin)
        InitMixin(self, MarineOutlineMixin)
        
        self:AddHelpWidget("GUIMarineHealthRequestHelp", 2)
        self:AddHelpWidget("GUIMarineFlashlightHelp", 2)
        self:AddHelpWidget("GUIBuyShotgunHelp", 2)
        // No more auto weld orders.
        //self:AddHelpWidget("GUIMarineWeldHelp", 2)
        self:AddHelpWidget("GUIMapHelp", 1)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
        self.notifications = { }
        self.timeLastSpitHitEffect = 0
        
    end
    
    self.weaponDropTime = 0
    
    local viewAngles = self:GetViewAngles()
    self.lastYaw = viewAngles.yaw
    self.lastPitch = viewAngles.pitch
    
    // -1 = leftmost, +1 = right-most
    self.horizontalSwing = 0
    // -1 = up, +1 = down
    
    self.timeLastSpitHit = 0
    self.lastSpitDirection = Vector(0, 0, 0)
    self.timeOfLastDrop = 0
    self.timeOfLastPickUpWeapon = 0
    self.ruptured = false
    self.interruptAim = false
    self.catpackboost = false
    self.timeCatpackboost = 0
    
    self.flashlightLastFrame = false
    
end

local blockBlackArmor = false
if Server then
    Event.Hook("Console_blockblackarmor", function() if Shared.GetCheatsEnabled() then blockBlackArmor = not blockBlackArmor end end)
end
function Marine:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and self.spawnprotection then 
    
        damageTable.damage = 0
        
    end

end
function Marine:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self.modelsize
	local hmgscale = self.heavyarmor and 1.3 or 1
        coords.xAxis = (coords.xAxis * scale) * hmgscale
        coords.yAxis = (coords.yAxis * scale) 
        coords.zAxis = (coords.zAxis * scale) * hmgscale
    return coords
end
function Marine:SetArmorAmount()
    local newMaxArmor = (Marine.kBaseArmor + self:GetArmorLevel() * Marine.kArmorPerUpgradeLevel) + ConditionalValue(self.heavyarmor, 30, 0)
    self:AdjustMaxArmor(newMaxArmor)
   // Print("armor is %s", newMaxArmor)
end
function Marine:GetArmorLevel()

    local armorLevel = 0
    local techTree = self:GetTechTree()

    if techTree then
    
        local armor3Node = techTree:GetTechNode(kTechId.Armor3)
        local armor2Node = techTree:GetTechNode(kTechId.Armor2)
        local armor1Node = techTree:GetTechNode(kTechId.Armor1)
    
        if armor3Node and armor3Node:GetResearched() then
            armorLevel = 3
        elseif armor2Node and armor2Node:GetResearched()  then
            armorLevel = 2
        elseif armor1Node and armor1Node:GetResearched()  then
            armorLevel = 1
        end
        
    end

    return armorLevel

end

function Marine:GetWeaponLevel()

    local weaponLevel = 0
    local techTree = self:GetTechTree()

    if techTree then
        
            local weapon3Node = techTree:GetTechNode(kTechId.Weapons3)
            local weapon2Node = techTree:GetTechNode(kTechId.Weapons2)
            local weapon1Node = techTree:GetTechNode(kTechId.Weapons1)
        
            if weapon3Node and weapon3Node:GetResearched() then
                weaponLevel = 3
            elseif weapon2Node and weapon2Node:GetResearched()  then
                weaponLevel = 2
            elseif weapon1Node and weapon1Node:GetResearched()  then
                weaponLevel = 1
            end
            
    end

    return weaponLevel

end

function Marine:GetCanRepairOverride(target)
    return self:GetWeapon(Welder.kMapName) and HasMixin(target, "Weldable") and ( (target:isa("Marine") and target:GetArmor() < target:GetMaxArmor()) or (not target:isa("Marine") and target:GetHealthScalar() < 0.9) )
end

function Marine:GetSlowOnLand()
    return true
end
local kFindWeaponRange = 2
local kPickupWeaponTimeLimit = 1
// //All Credit to NS2+ for this - I want this feature without installing that mod. Sorry and thanks. All credit to you. I do not mean to steal
function Marine:FindNearbyAutoPickupWeapon()
		local toPosition = self:GetOrigin()
		local nearbyWeapons = GetEntitiesWithMixinWithinRange("Pickupable", toPosition, kFindWeaponRange)
		local closestWeapon = nil
		local closestDistance = Math.infinity
		
		local pickupPriority = { [kTechId.HeavyMachineGun] = 1, [kTechId.Shotgun] = 2, [kTechId.Flamethrower] = 3, [kTechId.GrenadeLauncher] = 4,  }
		
		
		local currentWeapon = self:GetWeaponInHUDSlot(1)
		local currentWeaponPriority = currentWeapon and pickupPriority[currentWeapon:GetTechId()] or 0
		local bestPriority = currentWeapon and currentWeaponPriority or -1
		
		for i, nearbyWeapon in ipairs(nearbyWeapons) do
		
			local pickupSlot = nearbyWeapon:isa("Weapon") and nearbyWeapon:GetHUDSlot()
			local isEmptySlot = (self:GetWeaponInHUDSlot(pickupSlot) == nil) or (self:GetWeaponInHUDSlot(pickupSlot):isa("Axe"))
		
			if nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) and isEmptySlot then
			
				local nearbyWeaponDistance = (nearbyWeapon:GetOrigin() - toPosition):GetLengthSquared()
				if nearbyWeaponDistance < closestDistance then
				
					closestWeapon = nearbyWeapon
					closestDistance = nearbyWeaponDistance
				
				end
				
			elseif nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) and pickupSlot == 1 and currentWeaponPriority < 1 then

				local techId = nearbyWeapon:GetTechId()
				local curPriority = pickupPriority[techId] or 0

				if curPriority > bestPriority then
					bestPriority = curPriority
					closestWeapon = nearbyWeapon
				end
			end
			
		end
		
		return closestWeapon
end
function Marine:GetArmorAmount(armorLevels)

    if not armorLevels then
    
        armorLevels = 0
    
        if GetHasTech(self, kTechId.Armor3, true) then
            armorLevels = 3
        elseif GetHasTech(self, kTechId.Armor2, true) then
            armorLevels = 2
        elseif GetHasTech(self, kTechId.Armor1, true) then
            armorLevels = 1
        end
    
    end

    
    return (Marine.kBaseArmor + armorLevels * Marine.kArmorPerUpgradeLevel) + ConditionalValue(self.heavyarmor, 30, 0)
    
end
function Marine:GetHasHMG()
        local weapon = self:GetWeaponInHUDSlot(1)
        local hmg = false
    if (weapon) then
        if (weapon:isa("HeavyMachineGun")) then
            hmg = true
        end
    end
    
    return hmg
end
function Marine:GetNanoShieldOffset()
    return Vector(0, -0.1, 0)
end

function Marine:OnDestroy()

    Player.OnDestroy(self)
    
    if Client then

        if self.ruptureMaterial then
        
            Client.DestroyRenderMaterial(self.ruptureMaterial)
            self.ruptureMaterial = nil
            
        end
        
        if self.flashlight ~= nil then
            Client.DestroyRenderLight(self.flashlight)
        end

    end
    
end

function Marine:HandleButtons(input)

    PROFILE("Marine:HandleButtons")
    
    Player.HandleButtons(self, input)
    
    if self:GetCanControl() then
    
        // Update sprinting state
        self:UpdateSprintingState(input)
        
        local flashlightPressed = bit.band(input.commands, Move.ToggleFlashlight) ~= 0
        if not self.flashlightLastFrame and flashlightPressed then
        
            self:SetFlashlightOn(not self:GetFlashlightOn())
            StartSoundEffectOnEntity(Marine.kFlashlightSoundName, self, 1, self)
            
        end
        self.flashlightLastFrame = flashlightPressed

		local autoPickup = self:FindNearbyAutoPickupWeapon() and bit.band(input.commands, Move.Drop) == 0
        if (bit.band(input.commands, Move.Drop) ~= 0 or autoPickup) then
        
            if Server then
            
                // First check for a nearby weapon to pickup.
                local nearbyDroppedWeapon = ConditionalValue(autoPickup, self:FindNearbyAutoPickupWeapon(), self:GetNearbyPickupableWeapon())

				// Make sure the weapon hasn't been destroyed when we do the autopickup
                if nearbyDroppedWeapon and nearbyDroppedWeapon:isa("Weapon") and not nearbyDroppedWeapon:GetIsDestroyed() then

					local lastActiveHUD = self:GetActiveWeapon() and self:GetActiveWeapon():GetHUDSlot() or -1
                
                    if self.lastDroppedWeapon ~= nearbyDroppedWeapon or Shared.GetTime() > self.timeOfLastPickUpWeapon + kPickupWeaponTimeLimit then
                    
                        if nearbyDroppedWeapon.GetReplacementWeaponMapName then
                        
                            local replacement = nearbyDroppedWeapon:GetReplacementWeaponMapName()
                            local toReplace = self:GetWeapon(replacement)
                            if toReplace then
                            
                                self:RemoveWeapon(toReplace)
                                self:SetArmorAmount()
                                DestroyEntity(toReplace)
                                
                            end
                            
                        end
                        
						local active = nearbyDroppedWeapon:GetHUDSlot() == 1 or bit.band(input.commands, Move.Drop) ~= 0
                        self:AddWeapon(nearbyDroppedWeapon, active)
                        self:SetArmorAmount()
                        StartSoundEffectAtOrigin(Marine.kGunPickupSound, self:GetOrigin())
						
						// Fixes problem where if a marine drops all weapons and picks a welder the axe remains active
						if not active and lastActiveHUD and lastActiveHUD > -1 then
							self:SetHUDSlotActive(lastActiveHUD)
						end
                        
						// Don't add the pickup delay to autopickedup weapons
						if not autoPickup then
							self.timeOfLastPickUpWeapon = Shared.GetTime()
						end
                        
                    end
                    
                else
                
					local activeWeapon = self:GetActiveWeapon()
					
					// No nearby weapon, drop our current weapon.
                    if self:Drop() then			
                        self:SetArmorAmount()			
						self.lastDroppedWeapon = activeWeapon                    
						self.timeOfLastPickUpWeapon = Shared.GetTime()
					end
					
					
                    
                end
                
            end
            
        end
        
    end
    
end

function Marine:SetFlashlightOn(state)
    self.flashlightOn = state
end
function Marine:GetFlashlightOn()
    return self.flashlightOn
end

function Marine:GetInventorySpeedScalar()
    return 1 - self:GetWeaponsWeight()
end

function Marine:GetCrouchSpeedScalar()
    return Player.kCrouchSpeedScalar
end

function Marine:ModifyGroundFraction(groundFraction)
    return groundFraction > 0 and 1 or 0
end
/*
function Marine:ModifyGravityForce(gravityTable)
      if self:GetIsOnGround() then
            gravityTable.gravity = Player.kGravity
      elseif self.gravity ~= 0 then
        gravityTable.gravity = self.gravity
       end
end
*/
function Marine:GetMaxSpeed(possible)
  // Marine.kRunMaxSpeed = Marine.kRunMaxSpeed * ConditionalValue(self.heavyarmor, Marine.kRunMaxSpeed * 1.3, 1)
  // Marine.kWalkMaxSpeed = Marine.kWalkMaxSpeed * ConditionalValue(self.heavyarmor, Marine.kWalkMaxSpeed * 1.3, 1)
  local heavyarmor = self.heavyarmor and 1.3 or 1
    if possible then
        return Marine.kRunMaxSpeed * heavyarmor
    end

    local sprintingScalar = self:GetSprintingScalar() * heavyarmor
    local maxSprintSpeed = Marine.kWalkMaxSpeed + (Marine.kRunMaxSpeed - Marine.kWalkMaxSpeed)*sprintingScalar
    local maxSpeed = ConditionalValue(self:GetIsSprinting(), maxSprintSpeed, Marine.kWalkMaxSpeed)
    
    // Take into account our weapon inventory and current weapon. Assumes a vanilla marine has a scalar of around .8.
    local inventorySpeedScalar = self:GetInventorySpeedScalar() + .17    
    local useModifier = self.isUsing and 0.5 or 1
    
    if self.catpackboost then
        maxSpeed = maxSpeed + kCatPackMoveAddSpeed
    end
    /*
    local size = self.modelsize
    if size > 1 then
    size = 1 
    end
    */
    return ( maxSpeed * self:GetSlowSpeedModifier() * inventorySpeedScalar  * useModifier ) //* size
    
end
function Marine:GetFootstepSpeedScalar()
    return Clamp(self:GetVelocityLength() / (Marine.kRunMaxSpeed * self:GetCatalystMoveSpeedModifier() * self:GetSlowSpeedModifier()), 0, 1)
end

// Maximum speed a player can move backwards
function Marine:GetMaxBackwardSpeedScalar()
    return Marine.kWalkBackwardSpeedScalar
end

function Marine:GetControllerPhysicsGroup()
    return PhysicsGroup.BigPlayerControllersGroup
end

function Marine:GetJumpHeight()
    return Player.kJumpHeight - Player.kJumpHeight * self.slowAmount * 0.8
end

function Marine:GetCanBeWeldedOverride()
    return self:GetArmor() < self:GetMaxArmor(), false
end

// Returns -1 to 1
function Marine:GetWeaponSwing()
    return self.horizontalSwing
end

function Marine:GetWeaponDropTime()
    return self.weaponDropTime
end

local marineTechButtons = { kTechId.Attack, kTechId.Move, kTechId.Defend, kTechId.Construct }
function Marine:GetTechButtons(techId)

    local techButtons = nil
    
    if techId == kTechId.RootMenu then
        techButtons = marineTechButtons
    end
    
    return techButtons
 
end
function Marine:GetHasRespawnProtection()
return self.spawnprotection
end
function Marine:GetChatSound()
    return Marine.kChatSound
end

function Marine:GetDeathMapName()
    return MarineSpectator.kMapName
end

// Returns the name of the primary weapon
function Marine:GetPlayerStatusDesc()

    local status = kPlayerStatus.Void
    
    if (self:GetIsAlive() == false) then
        return kPlayerStatus.Dead
    end
    
    local weapon = self:GetWeaponInHUDSlot(1)
    if (weapon) then
        if (weapon:isa("GrenadeLauncher")) then
            return kPlayerStatus.GrenadeLauncher
        elseif (weapon:isa("Rifle")) then
            return kPlayerStatus.Rifle
        elseif (weapon:isa("Shotgun")) then
            return kPlayerStatus.Shotgun
        elseif (weapon:isa("Flamethrower")) then
            return kPlayerStatus.Flamethrower
        end
    end
    
    return status
end

function Marine:GetCanDropWeapon(weapon, ignoreDropTimeLimit)

    if not weapon then
        weapon = self:GetActiveWeapon()
    end
    
    if weapon ~= nil and weapon.GetIsDroppable and weapon:GetIsDroppable() then
    
        // Don't drop weapons too fast.
        if ignoreDropTimeLimit or (Shared.GetTime() > (self.timeOfLastDrop + kDropWeaponTimeLimit)) then
            return true
        end
        
    end
    
    return false
    
end

function Marine:GetCanUseCatPack()

    local enoughTimePassed = self.timeCatpackboost + 6 < Shared.GetTime()
    return not self.catpackboost or enoughTimePassed
    
end

// Do basic prediction of the weapon drop on the client so that any client
// effects for the weapon can be dealt with.
function Marine:Drop(weapon, ignoreDropTimeLimit, ignoreReplacementWeapon)

    local activeWeapon = self:GetActiveWeapon()
    
    if not weapon then
        weapon = activeWeapon
    end
    
    if self:GetCanDropWeapon(weapon, ignoreDropTimeLimit) then
    
        if weapon == activeWeapon then
            self:SelectNextWeapon()
        end
        
        weapon:OnPrimaryAttackEnd(self)
        
        if Server then
        
            self:RemoveWeapon(weapon)
            
            local weaponSpawnCoords = self:GetAttachPointCoords(Weapon.kHumanAttachPoint)
            weapon:SetCoords(weaponSpawnCoords)
            
        end
        
        // Tell weapon not to be picked up again for a bit
        weapon:Dropped(self)
        
        // Set activity end so we can't drop like crazy
        self.timeOfLastDrop = Shared.GetTime() 
        
        if Server then
        
            if ignoreReplacementWeapon ~= true and weapon.GetReplacementWeaponMapName then
            
                self:GiveItem(weapon:GetReplacementWeaponMapName(), false)
                // the client expects the next weapon is going to be selected (does not know about the replacement).
                self:SelectNextWeaponInDirection(1)
                
            end
            
        end
        
        return true
        
    end
    
    return false
    
end

function Marine:OnStun()
   /*
    local activeWeapon = self:GetActiveWeapon()
    
    if activeWeapon then
        activeWeapon:OnHolster(self)
    end
    */
    
             if Server then
                local bonewall = CreateEntity(BoneWall.kMapName, self:GetOrigin(), 2)    
                bonewall.modelsize = 0.25 * self.modelsize
                bonewall:AdjustMaxHealth(160)
                StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, self)
                bonewall:SetLifeSpan(4)
        end
end
/*
function Marine:OnStunEnd()

    local activeWeapon = self:GetActiveWeapon()
    
    if activeWeapon then
        activeWeapon:OnDraw(self)
    end
    
end

function Marine:OnHitGroundStunned()

    if Server then
        StartSoundEffectOnEntity(Marine.kHitGroundStunnedSound, self)
    end
    
end
*/
function Marine:GetWeldPercentageOverride()
    return self:GetArmor() / self:GetMaxArmor()
end

function Marine:OnSpitHit(direction)

    if Server then
        self.timeLastSpitHit = Shared.GetTime()
        self.lastSpitDirection = direction  
    end

end


function Marine:GetIsTaunting()
   return self.istaunting
end
function Marine:OnUseTarget(target)

    local activeWeapon = self:GetActiveWeapon()

    if target and HasMixin(target, "Construct") and ( target:GetCanConstruct(self) or (target.CanBeWeldedByBuilder and target:CanBeWeldedByBuilder()) ) then
    
        if activeWeapon and activeWeapon:GetMapName() ~= Builder.kMapName then
            self:SetActiveWeapon(Builder.kMapName, true)
            self.weaponBeforeUse = activeWeapon:GetMapName()
        end
        
    else
        if activeWeapon and activeWeapon:GetMapName() == Builder.kMapName and self.weaponBeforeUse then
            self:SetActiveWeapon(self.weaponBeforeUse, true)
        end    
    end

end

function Marine:OnUseEnd() 

    local activeWeapon = self:GetActiveWeapon()

    if activeWeapon and activeWeapon:GetMapName() == Builder.kMapName and self.weaponBeforeUse then
        self:SetActiveWeapon(self.weaponBeforeUse)
    end

end

function Marine:OnUpdateAnimationInput(modelMixin)

    PROFILE("Marine:OnUpdateAnimationInput")
    
    Player.OnUpdateAnimationInput(self, modelMixin)
    
    local animationLength = modelMixin:isa("ViewModel") and 0 or 0.5
    
    if not self:GetIsJumping() and self:GetIsSprinting() then
        modelMixin:SetAnimationInput("move", "sprint")
    end
    
    if self:GetIsTaunting() then
    //   modelMixin:SetAnimationInput("taunting", true)
    end
    
    local activeWeapon = self:GetActiveWeapon()
    local catalystSpeed = 1
    
    if activeWeapon and activeWeapon.GetCatalystSpeedBase then
        catalystSpeed = activeWeapon:GetCatalystSpeedBase()
    end
    
    if self.catpackboost then
        catalystSpeed = kCatPackWeaponSpeed * catalystSpeed
    end
    
    
    modelMixin:SetAnimationInput("catalyst_speed", catalystSpeed)
    
    
end

function Marine:GetDeflectMove()
    return true
end    

function Marine:ModifyJumpLandSlowDown(slowdownScalar)

    if self.strafeJumped then
        slowdownScalar = 0.2 + slowdownScalar
    end
    
    return slowdownScalar

end

local kStrafeJumpForce = 1
local kStrafeJumpDelay = 0.7
function Marine:ModifyJump(input, velocity, jumpVelocity)
    /*
    local isStrafeJump = input.move.z == 0 and input.move.x ~= 0
    if isStrafeJump and self:GetTimeGroundTouched() + kStrafeJumpDelay < Shared.GetTime() then
    
        local strafeJumpDirection = GetNormalizedVector(self:GetViewCoords():TransformVector(input.move))
        jumpVelocity:Add(strafeJumpDirection * kStrafeJumpForce)
        jumpVelocity.y = jumpVelocity.y * 0.8
        self.strafeJumped = true
        
    else
        self.strafeJumped = false
    end
    
    jumpVelocity:Scale(self:GetSlowSpeedModifier())
    */
end

function Marine:OnJump()

    if self.strafeJumped then
        self:TriggerEffects("strafe_jump", {surface = self:GetMaterialBelowPlayer()})           
    end

    self:TriggerEffects("jump", {surface = self:GetMaterialBelowPlayer()})
    
end    

function Marine:OnProcessMove(input)

    if self.catpackboost then
        self.catpackboost = Shared.GetTime() - self.timeCatpackboost < kCatPackDuration
    end
        ///Untested hotfix after 9.5 to disallow player gravity and dont push Y height vector for OP ness also with 12 instead of 15
    /// Jump Pack from NS1 // HL1 ? - Copied from Leap ! :P // Delay of usage 
    if self.hasjumppack then
       if Shared.GetTime() >  self.lastjump + 1.5 and bit.band(input.commands, Move.Jump) ~= 0 and bit.band(input.commands, Move.Crouch) ~= 0 then
       if self:GetGravity() ~= 0 then self:JumpPackNotGravity() end
       local range = 12
       local force = 12
       local velocity = self:GetVelocity() * 0.5
       local forwardVec = self:GetViewAngles():GetCoords().zAxis
       local newVelocity = velocity + GetNormalizedVectorXZ(forwardVec) * force
          //Jumping upward ruins it.
       // newVelocity.y = range * forwardVec.y + range * 0.5 + ConditionalValue(velocity.y < 0, velocity.y, 0)
        self:SetVelocity(  self:GetVelocity() + newVelocity )
        self.lastjump = Shared.GetTime()
        end
     end
     
     
    if Server then
    
         if self.hasreupply then
      if Shared.GetTime() >  self.lastsupply + 10 then
           if self.suppliesleft >= 1 then
            if self:GetHealth() <= 90 then 
             self:TriggerDropPack(self:GetOrigin(), kTechId.MedPack)
             end
             
             if self:GetWeaponInHUDSlot(1) and self:GetWeaponInHUDSlot(1):GetAmmoFraction() <= .5
             or self:GetWeaponInHUDSlot(2) and self:GetWeaponInHUDSlot(2):isa("Pistol") and self:GetWeaponInHUDSlot(2):GetAmmoFraction() <= .5                                 then
             self:TriggerDropPack(self:GetOrigin(), kTechId.AmmoPack) 
             end
             
       self.suppliesleft = self.suppliesleft - 1
       self.lastsupply = Shared.GetTime()
         end
     end
     end
     
        self.ruptured = Shared.GetTime() - self.timeRuptured < Rupture.kDuration
        self.interruptAim  = Shared.GetTime() - self.interruptStartTime < Gore.kAimInterruptDuration
        
        if self.unitStatusPercentage ~= 0 and self.timeLastUnitPercentageUpdate + 2 < Shared.GetTime() then
            self.unitStatusPercentage = 0
        end    
         
        if self.poisoned then
        
            if self:GetIsAlive() and self.timeLastPoisonDamage + 1 < Shared.GetTime() then
            
                local attacker = Shared.GetEntity(self.lastPoisonAttackerId)
            
                local currentHealth = self:GetHealth()
                local poisonDamage = kBitePoisonDamage
                
                // never kill the marine with poison only
                if currentHealth - poisonDamage < kPoisonDamageThreshhold then
                    poisonDamage = math.max(0, currentHealth - kPoisonDamageThreshhold)
                end
                
                local killedFromDamage, damageDone = self:DeductHealth(poisonDamage, attacker, nil, true)

                if attacker then
                
                    SendDamageMessage( attacker, self, damageDone, self:GetOrigin(), damageDone )
                
                end
            
                self.timeLastPoisonDamage = Shared.GetTime()   
                
            end
            
            if self.timePoisoned + kPoisonBiteDuration < Shared.GetTime() then
            
                self.timePoisoned = 0
                self.poisoned = false
                
            end
            
        end
        
        // check nano armor
        /*
        if not self:GetIsInCombat() and self.hasNanoArmor then            
            self:SetArmor(self:GetArmor() + input.time * kNanoArmorHealPerSecond, true)            
        end
        */
        
    end
    
    Player.OnProcessMove(self, input)
    
end

function Marine:GetCanSeeDamagedIcon(ofEntity)
    return HasMixin(ofEntity, "Weldable")
end

function Marine:GetMaxViewOffsetHeight()
local kViewOffsetHeight = 0.95 * 2 - 0.2
   // local size = self.modelsize
   // if size > 2 then
   // size = 2 
   // end
    
    return kViewOffsetHeight //* size
end
/*
function Marine:GetExtentsOverride()
local kXZExtents = 0.35
local kYExtents = 0.95
local crouchshrink = 0
i//f self.crouching then crouchshrink = 0.5 end
//if self.modelsize < 1 then
//crouchshrink = 0.5 * self.modelsize
  //  return Vector(kXZExtents * self.modelsize, (kYExtents * self.modelsize) - crouchshrink, kXZExtents * self.modelsize)
 //else
     return Vector(kXZExtents, kYExtents - crouchshrink, kXZExtents)
  // end
end
*/
function Marine:GetIsInterrupted()
    return self.interruptAim
end

function Marine:GetHasCatpackBoost()
    return self.catpackboost
end
function Marine:GetCanDoorInteract(inEntity)
return false
end
// dont allow marines to me chain stomped. this gives them breathing time and the onos needs to time the stomps instead of spamming
// and being able to permanently disable the marine
function Marine:GetIsStunAllowed()
    return self:GetLastStunTime() + 4 < Shared.GetTime() and not self.spawnprotection and (GetAreFrontDoorsOpen() or Shared.GetCheatsEnabled()) and self:GetIsOnGround()
end


Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)
