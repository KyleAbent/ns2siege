Script.Load("lua/SiegeConvars.lua")
Script.Load("lua/Weapons/Marine/LayStructures.lua")
Script.Load("lua/SiegeMod/unstuck.lua")
Script.Load("lua/SiegeMod/FrontDoor.lua")
Script.Load("lua/SiegeMod/SideDoor.lua")
Script.Load("lua/SiegeMod/SiegeDoor.lua")
Script.Load("lua/SiegeMod/SizeTrigger.lua")
Script.Load("lua/SiegeMod/JetpackFuel.lua")
Script.Load("lua/ExtraEntitiesMod/PushTrigger.lua")
Script.Load("lua/ExtraEntitiesMod/GravityTrigger.lua")
Script.Load("lua/DoorMixin.lua")
Script.Load("lua/ExtraEntitiesMod/eem_ParticleEffect.lua")
Script.Load("lua/ExtraEntitiesMod/LogicWeldable.lua")
Script.Load("lua/ExtraEntitiesMod/TeleportTrigger.lua")
Script.Load("lua/SiegeMod/FuncDoor.lua")
//Script.Load("lua/ExtraEntitiesMod/FuncObstacle.lua")
Script.Load("lua/ExtraEntitiesMod/PushTrigger.lua")
Script.Load("lua/ExtraEntitiesMod/LogicTimer.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMultiplier.lua")
Script.Load("lua/ExtraEntitiesMod/LogicSwitch.lua")
Script.Load("lua/ExtraEntitiesMod/LogicFunction.lua")
//Script.Load("lua/ExtraEntitiesMod/LogicDialogue.lua")
Script.Load("lua/ExtraEntitiesMod/LogicCounter.lua")
Script.Load("lua/SiegeMod/LogicTrigger.lua")
Script.Load("lua/ExtraEntitiesMod/LogicLua.lua")
Script.Load("lua/ExtraEntitiesMod/LogicEmitter.lua")
Script.Load("lua/ExtraEntitiesMod/LogicEmitterDestroyer.lua")
Script.Load("lua/ExtraEntitiesMod/LogicListener.lua")
Script.Load("lua/ExtraEntitiesMod/LogicButton.lua")
Script.Load("lua/ExtraEntitiesMod/LogicWorldTooltip.lua")
Script.Load("lua/ExtraEntitiesMod/LogicGiveItem.lua")
Script.Load("lua/ExtraEntitiesMod/LogicReset.lua")
Script.Load("lua/SiegeMod/LogicBreakable.lua")
Script.Load("lua/ExtraEntitiesMod/LogicEventListener.lua")
Script.Load("lua/ExtraEntitiesMod/LogicCinematic.lua")
Script.Load("lua/ExtraEntitiesMod/LogicPowerPointListener.lua")
Script.Load("lua/ExtraEntitiesMod/GlobalEventListener.lua")
Script.Load("lua/ExtraEntitiesMod/eem_Utility.lua")
Script.Load("lua/ExtraEntitiesMod/FuncMoveable.lua")
Script.Load("lua/ExtraEntitiesMod/FuncPlatform.lua")
Script.Load("lua/ExtraEntitiesMod/FuncRotateable.lua")
Script.Load("lua/ExtraEntitiesMod/FuncTrain.lua")
Script.Load("lua/ExtraEntitiesMod/FuncTrainNoPushPull.lua")
Script.Load("lua/ExtraEntitiesMod/FuncTrainWaypoint.lua")


Script.Load("lua/ModularExo_Exo.lua")
Script.Load("lua/ModularExo_Marine.lua")
Script.Load("lua/ModularExo_PrototypeLab.lua")

Script.Load("lua/weapons/HeavyMachineGun.lua")
Script.Load("lua/CommTunnel.lua")



Script.Load("lua/ModularExo_Exo.lua")

Script.Load("lua/ModularExo_Marine.lua")
Script.Load("lua/ModularExo_PrototypeLab.lua")


Script.Load("lua/Weapons/Marine/ModularExo_ExoFlamer.lua")
Script.Load("lua/Weapons/Marine/ModularExo_ExoWelder.lua")

Script.Load("lua/Weapons/Marine/ModularExo_ExoWeaponHolder.lua")

Script.Load("lua/ModularExo_Data.lua")
//Script.Load("lua/ModularJetpack_Data.lua")

Script.Load("lua/ModularExo_NetworkMessages.lua")


function ModularExo_ConvertNetMessageToConfig(message)
    return {
        [kExoModuleSlots.PowerSupply] = message.powerModuleType    or kExoModuleTypes.None,
        [kExoModuleSlots.LeftArm    ] = message.leftArmModuleType  or kExoModuleTypes.None,
        [kExoModuleSlots.RightArm   ] = message.rightArmModuleType or kExoModuleTypes.None,
        [kExoModuleSlots.Armor      ] = message.armorModuleType    or kExoModuleTypes.None,
        [kExoModuleSlots.Utility    ] = message.utilityModuleType  or kExoModuleTypes.None,
    }
end

function ModularExo_ConvertConfigToNetMessage(config)
    return {
        powerModuleType    = config[kExoModuleSlots.PowerSupply] or kExoModuleTypes.None,
        leftArmModuleType  = config[kExoModuleSlots.LeftArm    ] or kExoModuleTypes.None,
        rightArmModuleType = config[kExoModuleSlots.RightArm   ] or kExoModuleTypes.None,
        armorModuleType    = config[kExoModuleSlots.Armor      ] or kExoModuleTypes.None,
        utilityModuleType  = config[kExoModuleSlots.Utility    ] or kExoModuleTypes.None,
    }
end

function ModularExo_GetIsConfigValid(config)
    local resourceCost = 0
    local powerCost = 0
    local powerSupply = nil -- We don't know yet
    local leftArmType = nil
    local rightArmType = nil
    for slotType, slotTypeData in pairs(kExoModuleSlotsData) do
        local moduleType = config[slotType]
        if moduleType == nil or moduleType == kExoModuleTypes.None then
            if slotTypeData.required then
                -- The config MUST give a module type for this slot type
                return false, "missing required slot" -- not a valid config
            else
                -- This slot type is optional, so it's OK to leave it out
            end
        else
            -- The config has module type for this slot type
            local moduleTypeData = kExoModuleTypesData[moduleType]
            if moduleTypeData == nil or moduleTypeData.category ~= slotTypeData.category then
                -- They have provided the wrong category of module type for this slot type
                -- For example, an armor module in a weapon slot
                return false, "wrong slot type" -- not a valid config
            end
			if moduleTypeData.resourceCost then
			        resourceCost = resourceCost + moduleTypeData.resourceCost
			end
            -- Here, we can safely assume that the type is right (else the above would have returned)
            if moduleTypeData.powerCost then
                -- This module type uses power
                powerCost = powerCost+moduleTypeData.powerCost
            elseif moduleTypeData.powerSupply then
                -- This module type supplies power
                if powerSupply ~= nil then
                    -- We've already seen a module that supplies power!
                    return false, "dual power supply"
                else
                    -- We know our power supply!
                    powerSupply = moduleTypeData.powerSupply
                    //resCost = moduleTypeData.resourceCost
                end
            end
            if slotType == kExoModuleSlots.LeftArm then
                leftArmType = moduleTypeData.armType
            elseif slotType == kExoModuleSlots.RightArm then
                rightArmType = moduleTypeData.armType
            end
        end
    end
    -- Ok, we've iterated over certain module types and it seems OK
    
    local exoTexturePath = nil
    local modelDataForRightArmType = kExoWeaponRightLeftComboModels[rightArmType]
    if not modelDataForRightArmType.isValid then
        -- This means we don't have model data for the situation where the arm type is on the right
        -- Which means, this isn't a valid config! (e.g: claw selected for right arm)
        return false, "bad model right"
    else
        local modelData = modelDataForRightArmType[leftArmType]
        if not modelData.isValid then
            -- The left arm type is not supported for the given right arm type
            return false, "bad model left"
        else
            -- This combo of right and left arm types is supported!
            exoTexturePath = modelData.imageTexturePath
        end
    end
    
    if powerCost > powerSupply then
        -- This config uses more power than the supply can handle!
        return false, "not enough power"
    end
    
    -- This config is valid
    -- Return true, to indicate that
    -- Also return the power supply and power cost, in case the GUI needs those values
    -- Also return the image texture path, in case the GUI needs that!
    return true, nil, resourceCost, powerSupply, powerCost, exoTexturePath
end

function ModularExo_GetConfigWeight(config)
    local weight = 0
    for slotType, slotTypeData in pairs(kExoModuleSlotsData) do
        local moduleType = config[slotType]
        if moduleType and moduleType ~= kExoModuleTypes.None then
            local moduleTypeData = kExoModuleTypesData[moduleType]
            if moduleTypeData then
                weight = weight+(moduleTypeData.weight or 0)
            end
        end
    end
    return weight
end

local function AddTechChanges(techData)				

	table.insert(techData, { 	[kTechDataId] = kTechId.ExoFlamer,
								[kTechDataMapName] = ExoFlamer.kMapName,
								[kTechDataDamageType] = kFlamethrowerDamageType})

	table.insert(techData, { 	[kTechDataId] = kTechId.ExoWelder,
								[kTechDataMapName] = ExoWelder.kMapName,
								[kTechDataDamageType] = kWelderDamageType})
								
	for index, record in ipairs(techData) do		
		if record[kTechDataId] == kTechId.ExosuitTech then
			record[kTechDataTooltipInfo] = "Also unlocks Dual-Exos"
		end
    end
end

local oldBuildTechData = BuildTechData
function BuildTechData()
	local techData = oldBuildTechData()
	AddTechChanges(techData)
	return techData
end