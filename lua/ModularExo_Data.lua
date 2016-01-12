//Script.Load("lua/ModularExo_Balance.lua")

-- The categories of modules
kExoModuleCategories = enum{
    "PowerSupply",
    "Weapon",
    "Armor",
    "Damage",
    "Utility",
}
-- The slots that modules go in
kExoModuleSlots = enum{
    "PowerSupply",
    "RightArm",
    "LeftArm",
    "Armor",
    "Damage",
    "Utility",
}

-- Slot data
kExoModuleSlotsData = {
    [kExoModuleSlots.PowerSupply] = {
        category = kExoModuleCategories.PowerSupply,
        required = true,
    },
    [kExoModuleSlots.LeftArm] = {
        category = kExoModuleCategories.Weapon,
        required = true,
    },
    [kExoModuleSlots.RightArm] = {
        category = kExoModuleCategories.Weapon,
        required = true,
    },
    [kExoModuleSlots.Damage] = {
        category = kExoModuleCategories.Damage,
        required = false,
    },
    [kExoModuleSlots.Utility] = {
        category = kExoModuleCategories.Utility,
        required = false,
    },    [kExoModuleSlots.Armor] = {
        category = kExoModuleCategories.Armor,
        required = false,
    },

}

-- Module types
kExoModuleTypes = enum{
    "None",
    "Power1",
    "Power2",
    "Power3",
    "Power4",
    "Power5",
    "Power6",
    "Claw",
    "Welder",
	"Railgun",
    "Minigun",
    "Flamethrower",
    "PhaseGate",    
    "Nano",   
	"Armor1",
    "Armor2",
    "Armor3",
    "Damage1",
    "Damage2",
    "Damage3",
}

-- Information to decide which model to use for weapon combos
kExoArmTypes = enum{
    "Claw",
    "Minigun",
    "Railgun",
}

-- Module type data
kExoModuleTypesData = {
    -- Power modules
    [kExoModuleTypes.Power1] = {
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 0,
        resourceCost = 0,
        weight = 0,
    },
    /* [kExoModuleTypes.Power2] = {
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 45,
        resourceCost = 45,
        weight = 0,
    },
    [kExoModuleTypes.Power3] = {
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 60,
        resourceCost = 65,
        weight = 0,
    },*/
    -- Weapon modules
	[kExoModuleTypes.Claw] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = 0,
        mapName = Claw.kMapName,
        armType = kExoArmTypes.Claw,
        weight = 0.01,
    },
    [kExoModuleTypes.Welder] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = 5,
        mapName = ExoWelder.kMapName,
        armType = kExoArmTypes.Railgun,
        weight = 0.05,
    }, 
    [kExoModuleTypes.Railgun] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = 5,
        mapName = Railgun.kMapName,
        armType = kExoArmTypes.Railgun,
        weight = 0.08,
    }, 
	[kExoModuleTypes.Minigun] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = 5,
        mapName = Minigun.kMapName,
        armType = kExoArmTypes.Minigun,
        weight = 0.11,
    },
    [kExoModuleTypes.Flamethrower] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = 5,
        mapName = ExoFlamer.kMapName,
        armType = kExoArmTypes.Railgun,
        weight = 0.11,
    },
    
    -- Damage modules (unused)
    [kExoModuleTypes.Damage1] = {
        category = kExoModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
        weight = 0,
    },
	[kExoModuleTypes.Damage2] = {
        category = kExoModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
        weight = 0,
    },
	[kExoModuleTypes.Damage3] = {
        category = kExoModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
        weight = 0,
    },
    
    -- Utility modules
    [kExoModuleTypes.PhaseGate] = {
        category = kExoModuleCategories.Utility,
        powerCost = 0,
		resourceCost = 5,
        weight = 0.02,
    },
	[kExoModuleTypes.Armor1] = {
        category = kExoModuleCategories.Utility,
        powerCost = 0,
		resourceCost = 5,
		armorBonus = 100,
        weight = 0.04,    
    },  
     [kExoModuleTypes.Nano] = {
        category = kExoModuleCategories.Utility,
        powerCost = 0,
		resourceCost = 5,
        weight = 0.02,
    },
[kExoModuleTypes.None] = { },
}

-- Model data for weapon combos (data[rightArmType][leftArmType])
kExoWeaponRightLeftComboModels = {
    [kExoArmTypes.Minigun] = {
        isValid = true,
        [kExoArmTypes.Minigun] = {
            isValid = true,
            worldModel = "models/marine/exosuit/exosuit_mm.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_mm.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_mm_view.model",
			viewAnimGraph = "models/marine/exosuit/exosuit_mm_view.animation_graph",
        },
        [kExoArmTypes.Railgun] = {
            isValid = false,
        },
        [kExoArmTypes.Claw] = {
            isValid = true,
            worldModel = "models/marine/exosuit/exosuit_cm.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_cm.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_cm_view.model",
			viewAnimGraph   = "models/marine/exosuit/exosuit_cm_view.animation_graph",
        },
    },
    [kExoArmTypes.Railgun] = {
        isValid = true,
        [kExoArmTypes.Minigun] = {
            isValid = false,
        },
        [kExoArmTypes.Railgun] = {
            isValid = true,
		    worldModel = "models/marine/exosuit/exosuit_rr.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_rr.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_rr_view.model",
			viewAnimGraph   = "models/marine/exosuit/exosuit_rr_view.animation_graph",
        },
        [kExoArmTypes.Claw] = {
            isValid = true,
            worldModel = "models/marine/exosuit/exosuit_cr.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_cr.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_cr_view.model",
			viewAnimGraph   = "models/marine/exosuit/exosuit_cr_view.animation_graph",
        },
    },
    [kExoArmTypes.Claw] = {
        isValid = false,
        [kExoArmTypes.Minigun] = {
            isValid = false,
        },
        [kExoArmTypes.Railgun] = {
            isValid = false,
        },
        [kExoArmTypes.Claw] = {
            isValid = true, -- if only :P
        },
    },
}
