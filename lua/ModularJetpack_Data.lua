//Script.Load("lua/ModularExo_Balance.lua")

-- The categories of modules
kJetpackModuleCategories = enum{
    "PowerSupply",
    "Weapon",
    "Armor",
    "Damage",
    "Utility",
}
-- The slots that modules go in
kJetpackModuleSlots = enum{
    "PowerSupply",
    "RightArm",
    "LeftArm",
    "Armor",
    "Damage",
    "Utility",
}

-- Slot data
kJetpackModuleSlotsData = {
    [kJetpackModuleSlots.PowerSupply] = {
        category = kJetpackModuleCategories.PowerSupply,
        required = true,
    },
    [kJetpackModuleSlots.LeftArm] = {
        category = kJetpackModuleCategories.Weapon,
        required = true,
    },
    [kJetpackModuleSlots.RightArm] = {
        category = kJetpackModuleCategories.Weapon,
        required = true,
    },
    [kJetpackModuleSlots.Damage] = {
        category = kJetpackModuleCategories.Damage,
        required = false,
    },
    [kJetpackModuleSlots.Utility] = {
        category = kJetpackModuleCategories.Utility,
        required = false,
    },    [kJetpackModuleSlots.Armor] = {
        category = kJetpackModuleCategories.Armor,
        required = false,
    },

}

-- Module types
kJetpackModuleTypes = enum{
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
kJetpackModuleTypesData = {
    -- Power modules
    [kJetpackModuleTypes.Power1] = {
        category = kJetpackModuleCategories.PowerSupply,
        powerSupply = 0,
        resourceCost = 0,
        weight = 0,
    },
    /* [kJetpackModuleTypes.Power2] = {
        category = kJetpackModuleCategories.PowerSupply,
        powerSupply = 45,
        resourceCost = 45,
        weight = 0,
    },
    [kJetpackModuleTypes.Power3] = {
        category = kJetpackModuleCategories.PowerSupply,
        powerSupply = 60,
        resourceCost = 65,
        weight = 0,
    },*/
    -- Weapon modules
	[kJetpackModuleTypes.Claw] = {
        category = kJetpackModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = 10,
        mapName = Claw.kMapName,
        armType = kExoArmTypes.Claw,
        weight = 0.01,
    },
    [kJetpackModuleTypes.Welder] = {
        category = kJetpackModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = 15,
        mapName = ExoWelder.kMapName,
        armType = kExoArmTypes.Railgun,
        weight = 0.05,
    }, 
    [kJetpackModuleTypes.Railgun] = {
        category = kJetpackModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = 16,
        mapName = Railgun.kMapName,
        armType = kExoArmTypes.Railgun,
        weight = 0.08,
    }, 
	[kJetpackModuleTypes.Minigun] = {
        category = kJetpackModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = 20,
        mapName = Minigun.kMapName,
        armType = kExoArmTypes.Minigun,
        weight = 0.11,
    },
    [kJetpackModuleTypes.Flamethrower] = {
        category = kJetpackModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = 20,
        mapName = ExoFlamer.kMapName,
        armType = kExoArmTypes.Railgun,
        weight = 0.11,
    },
    
    -- Damage modules (unused)
    [kJetpackModuleTypes.Damage1] = {
        category = kJetpackModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
        weight = 0,
    },
	[kJetpackModuleTypes.Damage2] = {
        category = kJetpackModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
        weight = 0,
    },
	[kJetpackModuleTypes.Damage3] = {
        category = kJetpackModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
        weight = 0,
    },
    
    -- Utility modules
    [kJetpackModuleTypes.PhaseGate] = {
        category = kJetpackModuleCategories.Utility,
        powerCost = 0,
		resourceCost = 10,
        weight = 0.02,
    },
	[kJetpackModuleTypes.Armor1] = {
        category = kJetpackModuleCategories.Utility,
        powerCost = 0,
		resourceCost = 15,
		armorBonus = 100,
        weight = 0.04,    
    },  
     [kJetpackModuleTypes.Nano] = {
        category = kJetpackModuleCategories.Utility,
        powerCost = 0,
		resourceCost = 10,
        weight = 0.02,
    },
[kJetpackModuleTypes.None] = { },
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
