// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechData.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// A "database" of attributes for all units, abilities, structures, weapons, etc. in the game.
// Shared between client and server.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Set up structure data for easy use by Server.lua and model classes
// Store whatever data is necessary here and use LookupTechData to access
// Store any data that needs to used on both client and server here
// Lookup by key with LookupTechData()
kTechDataId                             = "id"
// Localizable string describing tech node
kTechDataDisplayName                    = "displayname"
// For alien traits and marine upgrades, these distinct character codes will be stored in sponitor's database
kTechDataSponitorCode                   = "sponitorchar"
// Include and set to false if not meant to display on commander UI "enables: "
kTechIDShowEnables                      = "showenables"
kTechDataMapName                        = "mapname"
kTechDataModel                          = "model"
// TeamResources, resources or energy
kTechDataCostKey                        = "costkey"
kTechDataBuildTime                      = "buildtime"
// If an entity has this field, it's treated as a research node instead of a build node
kTechDataResearchTimeKey                = "researchTime"
kTechDataMaxHealth                      = "maxhealth"
kTechDataMaxArmor                       = "maxarmor"
kTechDataDamageType                     = "damagetype"
// Class that structure must be placed on top of (resource towers on resource points)
// If adding more attach classes, add them to GetIsAttachment(). When attaching entities
// to this attach class, ignore class.
kStructureAttachClass                   = "attachclass"
// Structure must be placed within kStructureAttachRange of this class, but it isn't actually attached.
// This can be a table of strings as well. Near class must have the same team number.
kStructureBuildNearClass                = "buildnearclass"
// Structure attaches to wall/roof
kStructureBuildOnWall                   = "buildonwall"
// If specified along with attach class, this entity can only be built within this range of an attach class (infantry portal near Command Station)
// If specified, you must also specify the tech id of the attach class.
// This can be a table of ids as well.
kStructureAttachRange                   = "attachrange"
// If specified, this entity can only be built if there is a powered attach class within kStructureAttachRange.
kStructureAttachRequiresPower           = "attachrequirespower"
// If specified, draw a range indicator for the commander when selected.
kVisualRange                            = "visualrange"
// set to true when attach structure is not required but optional
kTechDataAttachOptional                   = "attachoptional"
// The tech id of the attach class 
kStructureAttachId                      = "attachid"
// If specified, this tech is an alien class that can be gestated into
kTechDataGestateName                    = "gestateclass"
// upgrade cost (life form specific)
kTechDataUpgradeCost                    = "upgradecost"
// If specified, how much time it takes to evolve into this class
kTechDataGestateTime                    = "gestatetime"
// If specified, object spawns this far off the ground
kTechDataSpawnHeightOffset              = "spawnheight"
// All player tech ids should have this, nothing else uses it. Pre-computed by looking at the min and max extents of the model, 
// adding their absolute values together and dividing by 2. 
kTechDataMaxExtents                     = "maxextents"
// Radius of a cylinder carved out of the navmesh when a structure with this tech id is placed
kTechDataObstacleRadius                 = "obstacleradius"
// If specified, is amount of energy structure starts with
kTechDataInitialEnergy                  = "initialenergy"
// If specified, is max energy structure can have
kTechDataMaxEnergy                      = "maxenergy"
// Menu priority. If more than one techId is specified for the same spot in a menu, use the one with the higher priority.
// If a tech doesn't specify a priority, treat as 0. If all priorities are tied, show none of them. This is how Starcraft works (see siege behavior).
kTechDataMenuPriority                   = "menupriority"
// if an alert with higher priority is trigger the interval should be ignored
kTechDataAlertPriority                  = "alertpriority"
// Indicates that the tech node is an upgrade of another tech node, so that the previous tech is still active (ie, if you upgrade a hive
// to an advanced hive, your team still has "hive" technology.
kTechDataUpgradeTech                    = "upgradetech"
// Set true if entity should be rotated before being placed
kTechDataSpecifyOrientation             = "specifyorientation"
// manipulate build coords in a custom function
kTechDataOverrideCoordsMethod           = "overridecoordsmethod"
// Point value for killing structure
kTechDataPointValue                     = "pointvalue"
// Set to false if not yet implemented, for displaying differently for not enabling
kTechDataImplemented                    = "implemented"
// Set to localizable string that will be added to end of description indicating date it went in. 
kTechDataNew                            = "new"
// For setting grow parameter on alien structures
kTechDataGrows                          = "grows"
// Commander hotkey. Not currently used.
kTechDataHotkey                         = "hotkey"
// Alert sound name
kTechDataAlertSound                     = "alertsound"
// Alert text for commander HUD
kTechDataAlertText                      = "alerttext"
// Alert type. These are the types in CommanderUI_GetDynamicMapBlips. "Request" alert types count as player alert requests and show up on the commander HUD as such.
kTechDataAlertType                      = "alerttype"
// Alert scope
kTechDataAlertTeam                      = "alertteam"
// Alert should ignore distance for triggering
kTechDataAlertIgnoreDistance            = "alertignoredistance"
// Alert should also trigger a team message.
kTechDataAlertSendTeamMessage           = "alertsendteammessage"
// Sound that plays for Comm and ordered players when given this order
kTechDataOrderSound                     = "ordersound"
// Don't send alert to originator of this alert 
kTechDataAlertOthersOnly                = "alertothers"
// Usage notes, caveats, etc. for use in commander tooltip (localizable)
kTechDataTooltipInfo                    = "tooltipinfo"
// Quite the same as tooltip, but shorter
kTechDataHint                           = "hintinfo"
// Indicate tech id that we're replicating
// Engagement distance - how close can unit get to it before it can repair or build it
kTechDataEngagementDistance             = "engagementdist"
// Can only be built on infestation
kTechDataRequiresInfestation            = "requiresinfestation"
// Cannot be built on infestation (cannot be specified with kTechDataRequiresInfestation)
kTechDataNotOnInfestation               = "notoninfestation"
// Special ghost-guide method. Called with commander as argument, returns a map of entities with ranges to lit up.
kTechDataGhostGuidesMethod               = "ghostguidesmethod"
// Special requirements for building. Called with techId, the origin and normal for building location and the commander. Returns true if the special requirement is met.
kTechDataBuildRequiresMethod            = "buildrequiresmethod"
// Allows dropping onto other entities
kTechDataAllowStacking                 = "allowstacking"
// will ignore other entities when searching for spawn position
kTechDataCollideWithWorldOnly          = "collidewithworldonly"
// ignore pathing mesh when placing entities
kTechDataIgnorePathingMesh     = "ignorepathing"
// used for gorgess
kTechDataMaxAmount = "maxstructureamount"
// requires power
kTechDataRequiresPower = "requirespower"
// for drawing ghost model, client
kTechDataGhostModelClass = "ghostmodelclass"
// for gorge build, can consume when dropping
kTechDataAllowConsumeDrop = "allowconsumedrop"
// only useable once every X seconds
kTechDataCooldown = "coldownduration"
// ignore any alert interval
kTechDataAlertIgnoreInterval = "ignorealertinterval"
// used for alien upgrades
kTechDataCategory = "techcategory"
// custom message displayed for the commander when build method failed
kTechDataBuildMethodFailedMessage = "commanderbuildmethodfailed"
kTechDataAbilityType = "abilitytype"
kTechDataSupply = "supply"
kTechDataSpawnBlock = "spawnblock"

kTechDataBioMass = "biomasslevel"

kTechDataShowOrderLine = "showorderline"

function BuildTechData()
    
    local techData = {
    
        // Orders
        { [kTechDataId] = kTechId.Move,                  [kTechDataDisplayName] = "MOVE", [kTechDataHotkey] = Move.M, [kTechDataTooltipInfo] = "MOVE_TOOLTIP", [kTechDataOrderSound] = MarineCommander.kMoveToWaypointSoundName},
        { [kTechDataId] = kTechId.Patrol,                [kTechDataDisplayName] = "PATROL", [kTechDataShowOrderLine] = true, [kTechDataHotkey] = Move.M, [kTechDataTooltipInfo] = "PATROL_TOOLTIP", [kTechDataOrderSound] = MarineCommander.kMoveToWaypointSoundName},
        { [kTechDataId] = kTechId.Attack,                [kTechDataDisplayName] = "ATTACK", [kTechDataHotkey] = Move.A, [kTechDataTooltipInfo] = "ATTACK_TOOLTIP", [kTechDataOrderSound] = MarineCommander.kAttackOrderSoundName},
        { [kTechDataId] = kTechId.Build,                 [kTechDataDisplayName] = "BUILD", [kTechDataTooltipInfo] = "BUILD_TOOLTIP"},
        { [kTechDataId] = kTechId.Construct,             [kTechDataDisplayName] = "CONSTRUCT", [kTechDataOrderSound] = MarineCommander.kBuildStructureSound},
        { [kTechDataId] = kTechId.AutoConstruct,         [kTechDataDisplayName] = "CONSTRUCT", [kTechDataOrderSound] = MarineCommander.kBuildStructureSound},
        { [kTechDataId] = kTechId.Grow,                  [kTechDataDisplayName] = "GROW", [kTechDataTooltipInfo] = "GROW_TOOLTIP" },
        { [kTechDataId] = kTechId.HoldPosition,          [kTechDataDisplayName] = "HOLD_POSITION" },
        { [kTechDataId] = kTechId.FollowAlien,           [kTechDataDisplayName] = "FOLLOW_NEAREST_ALIEN", [kTechDataTooltipInfo] = "FOLLOW_NEAREST_ALIEN_TOOLTIP" },
        { [kTechDataId] = kTechId.Follow,                [kTechDataDisplayName] = "FOLLOW" },
        { [kTechDataId] = kTechId.Cancel,                [kTechDataDisplayName] = "CANCEL", [kTechDataHotkey] = Move.ESC},
        { [kTechDataId] = kTechId.Weld,                  [kTechDataDisplayName] = "WELD", [kTechDataHotkey] = Move.W, [kTechDataTooltipInfo] = "WELD_TOOLTIP", [kTechDataOrderSound] = MarineCommander.kWeldOrderSound},
        { [kTechDataId] = kTechId.FollowAndWeld,         [kTechDataDisplayName] = "FOLLOWANDWELD", [kTechDataHotkey] = Move.W, [kTechDataTooltipInfo] = "FOLLOWANDWELD_TOOLTIP", [kTechDataOrderSound] = MarineCommander.kWeldOrderSound},
        { [kTechDataId] = kTechId.Stop,                  [kTechDataDisplayName] = "STOP", [kTechDataHotkey] = Move.S, [kTechDataTooltipInfo] = "STOP_TOOLTIP"},
        { [kTechDataId] = kTechId.SetRally,              [kTechDataDisplayName] = "SET_RALLY_POINT", [kTechDataHotkey] = Move.L, [kTechDataTooltipInfo] = "RALLY_POINT_TOOLTIP", [kTechDataShowOrderLine] = true,},
        { [kTechDataId] = kTechId.SetTarget,             [kTechDataDisplayName] = "SET_TARGET", [kTechDataHotkey] = Move.T, [kTechDataTooltipInfo] = "SET_TARGET_TOOLTIP"},
        
        { [kTechDataId] = kTechId.Welding,           [kTechDataDisplayName] = "WELDING", [kTechDataTooltipInfo] = "WELDING_TOOLTIP", },
        
        { [kTechDataId] = kTechId.AlienMove,             [kTechDataDisplayName] = "MOVE", [kTechDataHotkey] = Move.M, [kTechDataTooltipInfo] = "MOVE_TOOLTIP", [kTechDataOrderSound] = AlienCommander.kMoveToWaypointSoundName},
        { [kTechDataId] = kTechId.AlienAttack,           [kTechDataDisplayName] = "ATTACK", [kTechDataHotkey] = Move.A, [kTechDataTooltipInfo] = "ATTACK_TOOLTIP", [kTechDataOrderSound] = AlienCommander.kAttackOrderSoundName},
        { [kTechDataId] = kTechId.AlienConstruct,        [kTechDataDisplayName] = "CONSTRUCT", [kTechDataOrderSound] = AlienCommander.kBuildStructureSound},
        { [kTechDataId] = kTechId.Heal,                  [kTechDataDisplayName] = "HEAL", [kTechDataOrderSound] = AlienCommander.kHealTarget},
        { [kTechDataId] = kTechId.AutoHeal,              [kTechDataDisplayName] = "HEAL", [kTechDataOrderSound] = AlienCommander.kHealTarget},
        
        { [kTechDataId] = kTechId.SpawnMarine,       [kTechDataDisplayName] = "SPAWN_MARINE", [kTechDataTooltipInfo] = "SPAWN_MARINE_TOOLTIP", },
        { [kTechDataId] = kTechId.SpawnAlien,       [kTechDataDisplayName] = "SPAWN_ALIEN", [kTechDataTooltipInfo] = "SPAWN_ALIEN_TOOLTIP", },
        { [kTechDataId] = kTechId.CollectResources,       [kTechDataDisplayName] = "COLLECT_RESOURCES", [kTechDataTooltipInfo] = "COLLECT_RESOURCES_TOOLTIP", },
        { [kTechDataId] = kTechId.Detector,       [kTechDataDisplayName] = "DETECTOR", [kTechDataTooltipInfo] = "DETECTOR_TOOLTIP", },
        { [kTechDataId] = kTechId.TransformResources, [kTechDataResearchTimeKey] = kTransformResourcesTime, [kTechDataDisplayName] = "TRANSFORM_RESOURCES",   [kTechDataCostKey] = kTransformResourcesCost,   [kTechDataTooltipInfo] = "TRANSFORM_RESOURCES_TOOLTIP",},   

        // Ready room player is the default player, hence the ReadyRoomPlayer.kMapName
        { [kTechDataId] = kTechId.ReadyRoomPlayer,        [kTechDataDisplayName] = "READY_ROOM_PLAYER", [kTechDataMapName] = ReadyRoomPlayer.kMapName, [kTechDataModel] = MarineVariantMixin.kModelNames["male"]["green"], [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents) },
        { [kTechDataId] = kTechId.ReadyRoomEmbryo, [kTechDataMapName] = ReadyRoomEmbryo.kMapName, [kTechDataDisplayName] = "READY_ROOM_EMBRYO", [kTechDataModel] = MarineVariantMixin.kModelNames["male"]["green"], [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents) },
        { [kTechDataId] = kTechId.ReadyRoomExo, [kTechDataMapName] = ReadyRoomExo.kMapName, [kTechDataDisplayName] = "READY_ROOM_EXO", [kTechDataMaxExtents] = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents) },

        // Spectators classes.
        { [kTechDataId] = kTechId.Spectator,              [kTechDataModel] = "" },
        { [kTechDataId] = kTechId.AlienSpectator,         [kTechDataModel] = "" },
        
        // Marine classes
        { [kTechDataId] = kTechId.Marine,      [kTechDataDisplayName] = "MARINE", [kTechDataMapName] = Marine.kMapName, [kTechDataModel] = MarineVariantMixin.kModelNames["male"]["green"], [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents), [kTechDataMaxHealth] = Marine.kHealth, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataPointValue] = kMarinePointValue},
        { [kTechDataId] = kTechId.Exo,              [kTechDataDisplayName] = "EXOSUIT", [kTechDataTooltipInfo] = "EXOSUIT_TOOLTIP", [kTechDataMapName] = Exo.kMapName, [kTechDataMaxExtents] = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents), [kTechDataMaxHealth] = kExosuitHealth, [kTechDataEngagementDistance] = kExoEngagementDistance, [kTechDataPointValue] = kExosuitPointValue},
        { [kTechDataId] = kTechId.MarineCommander,     [kTechDataDisplayName] = "MARINE_COMMANDER", [kTechDataMapName] = MarineCommander.kMapName, [kTechDataModel] = ""},
        { [kTechDataId] = kTechId.JetpackMarine,   [kTechDataHint] = "JETPACK_HINT",    [kTechDataDisplayName] = "JETPACK", [kTechDataMapName] = JetpackMarine.kMapName, [kTechDataModel] = JetpackMarine.kModelName, [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents), [kTechDataMaxHealth] = JetpackMarine.kHealth, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataPointValue] = kMarinePointValue},
        
        // Marine orders
        { [kTechDataId] = kTechId.Defend,             [kTechDataDisplayName] = "DEFEND", [kTechDataOrderSound] = MarineCommander.kDefendTargetSound},

        // Menus
        { [kTechDataId] = kTechId.RootMenu,              [kTechDataDisplayName] = "SELECT", [kTechDataHotkey] = Move.B, [kTechDataTooltipInfo] = "SELECT_TOOLTIP"},
        { [kTechDataId] = kTechId.BuildMenu,             [kTechDataDisplayName] = "BUILD", [kTechDataHotkey] = Move.W, [kTechDataTooltipInfo] = "BUILD_TOOLTIP"},
        { [kTechDataId] = kTechId.AdvancedMenu,          [kTechDataDisplayName] = "ADVANCED", [kTechDataHotkey] = Move.E, [kTechDataTooltipInfo] = "ADVANCED_TOOLTIP"},
        { [kTechDataId] = kTechId.AssistMenu,            [kTechDataDisplayName] = "ASSIST", [kTechDataHotkey] = Move.R, [kTechDataTooltipInfo] = "ASSIST_TOOLTIP"},
        { [kTechDataId] = kTechId.MarkersMenu,           [kTechDataDisplayName] = "MARKERS", [kTechDataHotkey] = Move.M, [kTechDataTooltipInfo] = "PHEROMONE_TOOLTIP"},
        { [kTechDataId] = kTechId.UpgradesMenu,          [kTechDataDisplayName] = "UPGRADES", [kTechDataHotkey] = Move.U, [kTechDataTooltipInfo] = "TEAM_UPGRADES_TOOLTIP"},
        { [kTechDataId] = kTechId.WeaponsMenu,           [kTechDataDisplayName] = "WEAPONS_MENU", [kTechDataTooltipInfo] = "WEAPONS_MENU_TOOLTIP"},

        // Marine menus
        { [kTechDataId] = kTechId.RoboticsFactoryARCUpgradesMenu,            [kTechDataDisplayName] = "ARC_UPGRADES", [kTechDataHotkey] = Move.P},
        { [kTechDataId] = kTechId.RoboticsFactoryMACUpgradesMenu,            [kTechDataDisplayName] = "MAC_UPGRADES", [kTechDataHotkey] = Move.P},
        
        { [kTechDataId] = kTechId.TwoCommandStations, 
      [kTechDataDisplayName] = "TWO_COMMAND_STATIONS", 
     [kTechIDShowEnables] = false, [kTechDataTooltipInfo] = "TWO_COMMAND_STATIONS"},           
    
        { [kTechDataId] = kTechId.ThreeCommandStations, [kTechDataDisplayName] = "TWO_COMMAND_STATIONS", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] = "THREE_COMMAND_STATIONS"},               
        { [kTechDataId] = kTechId.TwoHives, [kTechDataDisplayName] = "TWO_HIVES", [kTechIDShowEnables] = false},               
        { [kTechDataId] = kTechId.ThreeHives, [kTechDataDisplayName] = "THREE_HIVES", [kTechIDShowEnables] = false},
        { [kTechDataId] = kTechId.FourHives, [kTechDataDisplayName] = "Four Hives", [kTechIDShowEnables] = false},
        
        { [kTechDataId] = kTechId.TwoWhips, [kTechDataDisplayName] = "TWO_WHIPS", [kTechIDShowEnables] = false},                
        { [kTechDataId] = kTechId.TwoCrags, [kTechDataDisplayName] = "TWO_CRAGS", [kTechIDShowEnables] = false},                
        { [kTechDataId] = kTechId.TwoShifts, [kTechDataDisplayName] = "TWO_SHIFTS", [kTechIDShowEnables] = false},                
        { [kTechDataId] = kTechId.TwoShades, [kTechDataDisplayName] = "TWO_SHADES", [kTechIDShowEnables] = false},                
        
        // Misc.
        { [kTechDataId] = kTechId.PowerPoint,    [kTechDataHint] = "POWERPOINT_HINT",        [kTechDataMapName] = PowerPoint.kMapName,            [kTechDataDisplayName] = "POWER_NODE",  [kTechDataCostKey] = 0,   [kTechDataMaxHealth] = kPowerPointHealth, [kTechDataMaxArmor] = kPowerPointArmor, [kTechDataBuildTime] = kPowerPointBuildTime, [kTechDataPointValue] = kPowerPointPointValue, [kTechDataTooltipInfo] = "POWERPOINT_TOOLTIP"},        
        { [kTechDataId] = kTechId.SocketPowerNode,    [kTechDataDisplayName] = "SOCKET_POWER_NODE", [kTechDataCostKey] = kPowerNodeCost, [kTechDataBuildTime] = 0.1, },

        { [kTechDataId] = kTechId.ResourcePoint,   [kTechDataHint] = "RESOURCE_NOZZLE_TOOLTIP",      [kTechDataMapName] = ResourcePoint.kPointMapName,    [kTechDataDisplayName] = "RESOURCE_NOZZLE", [kTechDataModel] = ResourcePoint.kModelName, [kTechDataObstacleRadius] = 1.0},
        { [kTechDataId] = kTechId.TechPoint,     [kTechDataHint] = "TECH_POINT_HINT",        [kTechDataTooltipInfo] = "TECH_POINT_TOOLTIP", [kTechDataMapName] = TechPoint.kMapName,             [kTechDataDisplayName] = "TECH_POINT", [kTechDataModel] = TechPoint.kModelName},
        { [kTechDataId] = kTechId.Door,                  [kTechDataDisplayName] = "DOOR", [kTechDataTooltipInfo] = "DOOR_TOOLTIP", [kTechDataMapName] = Door.kMapName, [kTechDataMaxHealth] = kDoorHealth, [kTechDataMaxArmor] = kDoorArmor, [kTechDataPointValue] = kDoorPointValue },
        
        /*
                { [kTechDataId] = kTechId.FuncDoor,    
              [kTechDataDisplayName] = "DOOR", 
       [kTechDataTooltipInfo] = "DOOR_TOOLTIP",
         [kTechDataMapName] = FuncDoor.kMapName, 
        [kTechDataMaxHealth] = kFuncDoorHealth, 
        [kTechDataMaxArmor] = 0, 
        [kTechDataPointValue] = 5 },
           */
     
        { [kTechDataId] = kTechId.DoorOpen,              [kTechDataDisplayName] = "OPEN_DOOR", [kTechDataHotkey] = Move.O, [kTechDataTooltipInfo] = "OPEN_DOOR_TOOLTIP"},
        { [kTechDataId] = kTechId.DoorClose,             [kTechDataDisplayName] = "CLOSE_DOOR", [kTechDataHotkey] = Move.C, [kTechDataTooltipInfo] = "CLOSE_DOOR_TOOLTIP"},
        { [kTechDataId] = kTechId.DoorLock,              [kTechDataDisplayName] = "LOCK_DOOR", [kTechDataHotkey] = Move.L, [kTechDataTooltipInfo] = "LOCKED_DOOR_TOOLTIP"},
        { [kTechDataId] = kTechId.DoorUnlock,            [kTechDataDisplayName] = "UNLOCK_DOOR", [kTechDataHotkey] = Move.U, [kTechDataTooltipInfo] = "UNLOCK_DOOR_TOOLTIP"},
        
        // Marine Commander abilities   
        { [kTechDataId] = kTechId.NanoShieldTech,  [kTechDataDisplayName] = "NANO_SHIELD_TECH", [kTechDataTooltipInfo] = "NANO_SHIELD_DEFENSE_TOOLTIP", [kTechDataCostKey] = kNanoShieldResearchCost, [kTechDataResearchTimeKey] = kNanoSnieldResearchTime },
 
        { [kTechDataId] = kTechId.PowerSurge,    [kTechDataCooldown] = kPowerSurgeCooldown,      [kTechDataAllowStacking] = true, [kTechDataIgnorePathingMesh] = true,  [kTechDataDisplayName] = "POWER_SURGE", [kTechDataCostKey] = kPowerSurgeCost, [kTechDataTooltipInfo] = "POWER_SURGE_TOOLTIP"},        
        { [kTechDataId] = kTechId.NanoShield,    [kTechDataCooldown] = kNanoShieldCooldown,      [kTechDataAllowStacking] = true, [kTechDataIgnorePathingMesh] = true, [kTechDataMapName] = NanoShield.kMapName,   [kTechDataDisplayName] = "NANO_SHIELD_DEFENSE", [kTechDataCostKey] = kNanoShieldCost, [kTechDataTooltipInfo] = "NANO_SHIELD_DEFENSE_TOOLTIP"},        
        { [kTechDataId] = kTechId.AmmoPack,       [kTechDataBuildRequiresMethod] = GetAmmoPackLimit,     [kTechDataBuildMethodFailedMessage] = "9 live ammopacks max",    [kTechDataAllowStacking] = true, [kTechDataIgnorePathingMesh] = true, [kTechDataMapName] = AmmoPack.kMapName,  [kTechDataDisplayName] = "AMMO_PACK",      [kTechDataCostKey] = kAmmoPackCost,            [kTechDataModel] = AmmoPack.kModelName, [kTechDataTooltipInfo] = "AMMO_PACK_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderDropSpawnHeight },
        { [kTechDataId] = kTechId.MedPack,   [kTechDataBuildRequiresMethod] = GetMedPackLimit,  [kTechDataBuildMethodFailedMessage] = "9 live medpacks max",  [kTechDataCooldown] = kMedPackCooldown,         [kTechDataAllowStacking] = true, [kTechDataIgnorePathingMesh] = true, [kTechDataMapName] = MedPack.kMapName,   [kTechDataDisplayName] = "MED_PACK",     [kTechDataCostKey] = kMedPackCost,             [kTechDataModel] = MedPack.kModelName,  [kTechDataTooltipInfo] = "MED_PACK_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderDropSpawnHeight},
        { [kTechDataId] = kTechId.CatPack,          [kTechDataBuildRequiresMethod] = GetCatPackLimit,   [kTechDataBuildMethodFailedMessage] = "9 live catpacks  max",    [kTechDataAllowStacking] = true, [kTechDataIgnorePathingMesh] = true, [kTechDataMapName] = CatPack.kMapName,   [kTechDataDisplayName] = "CAT_PACK",      [kTechDataCostKey] = kCatPackCost,             [kTechDataModel] = CatPack.kModelName,  [kTechDataTooltipInfo] = "CAT_PACK_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderDropSpawnHeight},
        { [kTechDataId] = kTechId.Scan,    [kTechDataAllowStacking] = true, [kTechDataCollideWithWorldOnly] = true, [kTechDataIgnorePathingMesh] = true, [kTechDataMapName] = Scan.kMapName,     [kTechDataDisplayName] = "SCAN",      [kTechDataHotkey] = Move.S,   [kTechDataCostKey] = kObservatoryScanCost, [kTechDataTooltipInfo] = "SCAN_TOOLTIP"},
        { [kTechDataId] = kTechId.SelectObservatory, [kTechIDShowEnables] = false, [kTechDataDisplayName] = "SELECT_OBSERVATORY", [kTechDataTooltipInfo] = "SELECT_NEAREST_OBSERVATORY" },   
        // Command station and its buildables
        { [kTechDataId] = kTechId.CommandStation, 
       [kTechDataIgnorePathingMesh] = false, ////////
        [kTechDataSpawnBlock] = true, 
       [kTechDataMaxExtents] = Vector(1.5, 1, 0.4),
             [kTechDataBuildRequiresMethod] = GetCCQualifications, 
         [kTechDataBuildMethodFailedMessage] = "3CCMax / Not Allowed To Build During SD",
         [kTechDataHint] = "COMMAND_STATION_HINT", 
          [kTechDataAllowStacking] = true,
          [kStructureAttachClass] = "TechPoint", 
        [kTechDataAttachOptional] = true, ///////////
        [kTechDataOverrideCoordsMethod] = OptionalAttachToFreeTechPoint, 
        [kTechDataGhostModelClass] = "MarineGhostModel",  
      [kTechDataMapName] = CommandStation.kMapName,  
       [kTechDataDisplayName] = "COMMAND_STATION", 
        [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation,   
       [kTechDataBuildTime] = kCommandStationBuildTime,
         [kTechDataCostKey] = kCommandStationCost, 
       [kTechDataModel] = CommandStation.kModelName, 
             [kTechDataMaxHealth] = kCommandStationHealth, 
      [kTechDataMaxArmor] = kCommandStationArmor,    
       [kTechDataSpawnHeightOffset] = 0, 
        [kTechDataEngagementDistance] = kCommandStationEngagementDistance, 
       [kTechDataInitialEnergy] = kCommandStationInitialEnergy,    
          [kTechDataMaxEnergy] = kCommandStationMaxEnergy, 
      [kTechDataPointValue] = kCommandStationPointValue, [kTechDataHotkey] = Move.C, [kTechDataTooltipInfo] = "COMMAND_STATION_TOOLTIP", [kTechDataObstacleRadius] = 2},       

        { [kTechDataId] = kTechId.Recycle,               [kTechDataDisplayName] = "RECYCLE", [kTechDataCostKey] = 0,    [kTechIDShowEnables] = false,       [kTechDataResearchTimeKey] = kRecycleTime, [kTechDataHotkey] = Move.R, [kTechDataTooltipInfo] =  "RECYCLE_TOOLTIP"},
        { [kTechDataId] = kTechId.MAC,    [kTechDataSupply] = kMACSupply,    [kTechDataHint] = "MAC_HINT",           [kTechDataMapName] = MAC.kMapName,                      [kTechDataDisplayName] = "MAC",  [kTechDataMaxHealth] = MAC.kHealth, [kTechDataMaxArmor] = MAC.kArmor, [kTechDataCostKey] = kMACCost, [kTechDataResearchTimeKey] = kMACBuildTime, [kTechDataModel] = MAC.kModelName, [kTechDataDamageType] = kMACAttackDamageType, [kTechDataInitialEnergy] = kMACInitialEnergy, [kTechDataMaxEnergy] = kMACMaxEnergy, [kTechDataMenuPriority] = 2, [kTechDataPointValue] = kMACPointValue, [kTechDataHotkey] = Move.M, [kTechDataTooltipInfo] = "MAC_TOOLTIP"},
        { [kTechDataId] = kTechId.CatPackTech, 
          [kTechDataCostKey] = kCatPackTechResearchCost,
          [kTechDataResearchTimeKey] = kCatPackTechResearchTime, 
      [kTechDataDisplayName] = "CAT_PACKS", 
    [kTechDataTooltipInfo] = "CAT_PACK_TECH_TOOLTIP"},
    
    
            { [kTechDataId] = kTechId.BluePrintTech, 
          [kTechDataCostKey] = kBluePrintTechResearchCost,
          [kTechDataResearchTimeKey] = kBluePrintTechResearchTime, 
      [kTechDataDisplayName] = "BluePrints", 
    [kTechDataTooltipInfo] = "Disables BluePrints. Have structures spawned in a non-blueprint state. Unless placed on Infestation. HOWEVER, 2x dmg against unbuilt structures."},



        // Marine base structures
        { [kTechDataId] = kTechId.Extractor, [kTechDataIgnorePathingMesh] = true, [kTechDataSpawnBlock] = true, [kTechDataHint] = "EXTRACTOR_HINT", [kTechDataCollideWithWorldOnly] = true, [kTechDataAllowStacking] = true,    [kTechDataGhostModelClass] = "MarineGhostModel", [kTechDataRequiresPower] = true,       [kTechDataMapName] = Extractor.kMapName,                [kTechDataDisplayName] = "EXTRACTOR",           [kTechDataCostKey] = kExtractorCost,       [kTechDataBuildTime] = kExtractorBuildTime, [kTechDataEngagementDistance] = kExtractorEngagementDistance, [kTechDataModel] = Extractor.kModelName,            [kTechDataMaxHealth] = kExtractorHealth, [kTechDataMaxArmor] = kExtractorArmor, [kStructureAttachClass] = "ResourcePoint", [kTechDataPointValue] = kExtractorPointValue, [kTechDataHotkey] = Move.E, [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation, [kTechDataTooltipInfo] =  "EXTRACTOR_TOOLTIP"},
        { [kTechDataId] = kTechId.ExtractorArmor, [kTechDataCostKey] = kExtractorArmorCost, [kTechDataResearchTimeKey] = kExtractorArmorResearchTime, [kTechDataDisplayName] = "EXTRACTOR_ARMOR", [kTechDataTooltipInfo] = "EXTRACTOR_ARMOR_TOOLTIP", },
     
      { [kTechDataId] = kTechId.InfantryPortal, 
       [kTechDataHint] = "INFANTRY_PORTAL_HINT", 
        [kTechDataSupply] = kInfantryPortalSupply, 
      [kTechDataGhostModelClass] = "MarineGhostModel", 
         [kTechDataRequiresPower] = true,
        [kTechDataGhostGuidesMethod] = GetInfantryPortalGhostGuides,
      [kTechDataBuildRequiresMethod] = GetCommandStationIsBuilt,  
        [kTechDataBuildMethodFailedMessage] = "6 ip max/2 per chair",  
       [kTechDataMapName] = InfantryPortal.kMapName,       
          [kTechDataDisplayName] = "INFANTRY_PORTAL",  
            [kTechDataCostKey] = kInfantryPortalCost, 
         [kTechDataBuildTime] = kInfantryPortalBuildTime, 
        [kTechDataMaxHealth] = kInfantryPortalHealth,
          [kTechDataMaxArmor] = kInfantryPortalArmor, 
          [kTechDataModel] = InfantryPortal.kModelName,
          [kStructureBuildNearClass] = "CommandStation", 
     [kStructureAttachId] = kTechId.CommandStation,
      [kStructureAttachRange] = kInfantryPortalAttachRange,
        [kTechDataEngagementDistance] = kInfantryPortalEngagementDistance,
        [kTechDataHotkey] = Move.P, [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation,
       [kTechDataTooltipInfo] = "INFANTRY_PORTAL_TOOLTIP"},
      
        { [kTechDataId] = kTechId.Armory,   
      //       [kTechDataBuildRequiresMethod] = GetArmoryRangeLimit,
    // [kTechDataBuildMethodFailedMessage] = "Please space distance between armories",
         [kTechDataSupply] = kArmorySupply,     
       [kTechDataHint] = "ARMORY_HINT", 
    [kTechDataGhostModelClass] = "MarineGhostModel",
       [kTechDataRequiresPower] = true,  
     [kTechDataMapName] = Armory.kMapName,  
       [kTechDataDisplayName] = "ARMORY",  
            [kTechDataCostKey] = kArmoryCost,  
            [kTechDataBuildTime] = kArmoryBuildTime, 
[kTechDataMaxHealth] = kArmoryHealth, 
[kTechDataMaxArmor] = kArmoryArmor, 
[kTechDataEngagementDistance] = kArmoryEngagementDistance, 
[kTechDataModel] = Armory.kModelName, 
[kTechDataPointValue] = kArmoryPointValue, 
[kTechDataInitialEnergy] = kArmoryInitialEnergy,  
 [kTechDataMaxEnergy] = kArmoryMaxEnergy, 
[kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation, 
[kTechDataTooltipInfo] = "ARMORY_TOOLTIP"},

        { [kTechDataId] = kTechId.ArmsLab,        [kTechDataHint] = "ARMSLAB_HINT", [kTechDataGhostModelClass] = "MarineGhostModel", [kTechDataRequiresPower] = true,       [kTechDataMapName] = ArmsLab.kMapName,                  [kTechDataDisplayName] = "ARMS_LAB",            [kTechDataCostKey] = kArmsLabCost,              [kTechDataBuildTime] = kArmsLabBuildTime, [kTechDataMaxHealth] = kArmsLabHealth, [kTechDataMaxArmor] = kArmsLabArmor, [kTechDataEngagementDistance] = kArmsLabEngagementDistance, [kTechDataModel] = ArmsLab.kModelName, [kTechDataPointValue] = kArmsLabPointValue, [kTechDataHotkey] = Move.A, [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation, [kTechDataTooltipInfo] = "ARMS_LAB_TOOLTIP", [kTechDataObstacleRadius] = 0.25},
    
        { [kTechDataId] = kTechId.Sentry, 
        [kTechDataSupply] = kSentrySupply, 
             [kTechDataBuildRequiresMethod] = GetCheckSentryLimit, 
        [kTechDataBuildMethodFailedMessage] = "COMMANDERERROR_TOO_MANY_SENTRIES",  
       [kTechDataHint] = "SENTRY_HINT", 
      [kTechDataGhostModelClass] = "MarineGhostModel",
        [kTechDataMapName] = Sentry.kMapName,  
         [kTechDataDisplayName] = "SENTRY_TURRET", 
           [kTechDataCostKey] = kSentryCost, 
         [kTechDataPointValue] = kSentryPointValue,
         [kTechDataModel] = Sentry.kModelName, 
           [kTechDataBuildTime] = kSentryBuildTime,
        [kTechDataMaxHealth] = kSentryHealth,  
       [kTechDataMaxArmor] = kSentryArmor, 
       [kTechDataDamageType] = kSentryAttackDamageType, 
         [kTechDataSpecifyOrientation] = false, 
      [kTechDataHotkey] = Move.S,
        [kTechDataInitialEnergy] = kSentryInitialEnergy,   
         [kTechDataMaxEnergy] = kSentryMaxEnergy, 
         [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation, 
        [kTechDataEngagementDistance] = kSentryEngagementDistance, 
        [kTechDataTooltipInfo] = "SENTRY_TOOLTIP", 
         [kTechDataObstacleRadius] = 0.25 },
         
        { [kTechDataId] = kTechId.SentryBattery,
          [kTechDataBuildRequiresMethod] = GetRoomHasNoSentryBattery, 
            [kTechDataBuildMethodFailedMessage] = "COMMANDERERROR_ONLY_ONE_BATTERY_PER_ROOM",
            [kTechDataHint] = "Backup Battery Provides power just as a power node would",
           [kTechDataGhostModelClass] = "MarineGhostModel", 
           [kTechDataMapName] = SentryBattery.kMapName,   
              [kTechDataDisplayName] = "Backup Battery",  
            [kTechDataCostKey] = kSentryBatteryCost,   
          [kTechDataPointValue] = kSentryBatteryPointValue, 
        [kTechDataModel] = SentryBattery.kModelName, 
          [kTechDataEngagementDistance] = 2,   
        [kTechDataBuildTime] = kSentryBatteryBuildTime, 
       [kTechDataMaxHealth] = kSentryBatteryHealth,  
        [kTechDataMaxArmor] = kSentryBatteryArmor,
        [kTechDataTooltipInfo] = "Backup Battery Provides power just as a power node would", 
        [kTechDataHotkey] = Move.S, 
      [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation, 
     [kVisualRange] = SentryBattery.kRange, [kTechDataObstacleRadius] = 0.25},

        // MACs 
        { [kTechDataId] = kTechId.MACEMP, 
        [kTechDataDisplayName] = "MAC_EMP", 
       [kTechDataTooltipInfo] = "MAC_EMP_TOOLTIP", 
            [kTechDataCooldown] = kMACEMpCoolDown, 
     [kTechDataCostKey] = kEMPCost },        
        { [kTechDataId] = kTechId.MACEMPTech,       [kTechDataDisplayName] = "MAC_EMP_RESEARCH", [kTechDataTooltipInfo] = "MAC_EMP_RESEARCH_TOOLTIP", [kTechDataCostKey] = kTechEMPResearchCost,             [kTechDataResearchTimeKey] = kTechEMPResearchTime, },
        { [kTechDataId] = kTechId.MACSpeedTech,     [kTechDataDisplayName] = "MAC_SPEED",  [kTechDataCostKey] = kTechMACSpeedResearchCost,  [kTechDataResearchTimeKey] = kTechMACSpeedResearchTime, [kTechDataHotkey] = Move.S, [kTechDataTooltipInfo] = "MAC_SPEED_TOOLTIP"},

        // Marine advanced structures
        { [kTechDataId] = kTechId.AdvancedArmory,
       [kTechDataHint] = "ADVANCED_ARMORY_HINT", 
        [kTechDataTooltipInfo] =  "ADVANCED_ARMORY_TOOLTIP", 
      [kTechDataGhostModelClass] = "MarineGhostModel",  
       [kTechIDShowEnables] = false,
        [kTechDataRequiresPower] = true,    
       [kTechDataMapName] = AdvancedArmory.kMapName,   
                 [kTechDataDisplayName] = "ADVANCED_ARMORY", 
         [kTechDataCostKey] = kAdvancedArmoryUpgradeCost,  
 [kTechDataModel] = Armory.kModelName,        
              [kTechDataMaxHealth] = kAdvancedArmoryHealth,  
 [kTechDataMaxArmor] = kAdvancedArmoryArmor, 
 [kTechDataEngagementDistance] = kArmoryEngagementDistance, 
 [kTechDataUpgradeTech] = kTechId.Armory, 
[kTechDataPointValue] = kAdvancedArmoryPointValue},


        { [kTechDataId] = kTechId.Observatory,  [kTechDataSupply] = kObservatorySupply, [kTechDataHint] = "OBSERVATORY_HINT", [kTechDataGhostModelClass] = "MarineGhostModel",  [kTechDataRequiresPower] = true,        [kTechDataMapName] = Observatory.kMapName,    [kTechDataDisplayName] = "OBSERVATORY",  [kVisualRange] = Observatory.kDetectionRange, [kTechDataCostKey] = kObservatoryCost,       [kTechDataModel] = Observatory.kModelName,            [kTechDataBuildTime] = kObservatoryBuildTime, [kTechDataMaxHealth] = kObservatoryHealth,   [kTechDataEngagementDistance] = kObservatoryEngagementDistance, [kTechDataMaxArmor] = kObservatoryArmor,   [kTechDataInitialEnergy] = kObservatoryInitialEnergy,      [kTechDataMaxEnergy] = kObservatoryMaxEnergy, [kTechDataPointValue] = kObservatoryPointValue, [kTechDataHotkey] = Move.O, [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation, [kTechDataTooltipInfo] = "OBSERVATORY_TOOLTIP", [kTechDataObstacleRadius] = 0.25},
        { [kTechDataId] = kTechId.DistressBeacon,  
          [kTechDataBuildTime] = 0.1,   
        [kTechDataDisplayName] = "DISTRESS_BEACON", 
         [kTechDataHotkey] = Move.B, [kTechDataCostKey] = kObservatoryDistressBeaconCost,
        [kTechDataTooltipInfo] =  "DISTRESS_BEACON_TOOLTIP"},
        
                { [kTechDataId] = kTechId.AdvancedBeacon,  
          [kTechDataBuildTime] = 0.1,   
        [kTechDataDisplayName] = "Advanced Beacon", 
         [kTechDataHotkey] = Move.B, 
       [kTechDataCostKey] = kAdvancedDistressBeaconCost,
       [kTechDataCooldown] = kAdvancedDistressBeaconCooldown,
        [kTechDataTooltipInfo] =  "Revives dead players as well."},
        
                        { [kTechDataId] = kTechId.LevelSentry,  
          [kTechDataBuildTime] = 0.1,   
        [kTechDataDisplayName] = "+5 Levels(UpTo)", 
         [kTechDataHotkey] = Move.B, 
       [kTechDataCostKey] = kLevelSentryCost,
       [kTechDataCooldown] = kLevelSentryCooldown,
        [kTechDataTooltipInfo] =  "Sentry Levels Adjust accuracy, damage, max health and max armor."},
        
                                { [kTechDataId] = kTechId.LevelIP,  
          [kTechDataBuildTime] = 0.1,   
        [kTechDataDisplayName] = "+5 Levels(UpTo)", 
         [kTechDataHotkey] = Move.B, 
       [kTechDataCostKey] = kLevelIPCost,
       [kTechDataCooldown] = kLevelIPCoolDown,
        [kTechDataTooltipInfo] =  "IP levels effect max health, max armor, respawn wave duration."},
        
        
                                { [kTechDataId] = kTechId.PGchannelOne,  
          [kTechDataBuildTime] = 0.1,   
        [kTechDataDisplayName] = "Channel 1", 
         [kTechDataHotkey] = Move.B, 
       [kTechDataCostKey] = 0,
       [kTechDataCooldown] = 1,
        [kTechDataTooltipInfo] =  "Change Frequencies"},
        
                                        { [kTechDataId] = kTechId.PGchannelTwo,  
          [kTechDataBuildTime] = 0.1,   
        [kTechDataDisplayName] = "Channel 2", 
         [kTechDataHotkey] = Move.B, 
       [kTechDataCostKey] = 0,
       [kTechDataCooldown] = 1,
        [kTechDataTooltipInfo] =  "Change Frequencies"},
        
                                                { [kTechDataId] = kTechId.PGchannelThree,  
          [kTechDataBuildTime] = 0.1,   
        [kTechDataDisplayName] = "Channel 3", 
         [kTechDataHotkey] = Move.B, 
       [kTechDataCostKey] = 0,
       [kTechDataCooldown] = 1,
        [kTechDataTooltipInfo] =  "Change Frequencies"},



        { [kTechDataId] = kTechId.RoboticsFactory,
      [kTechDataSupply] = kRoboticsFactorySupply,
  //   [kTechDataBuildRequiresMethod] = GetRoboticsRangeLimit,
      [kTechDataBuildMethodFailedMessage] = "Please space distance between robotics factories", 
     [kTechDataHint] = "ROBOTICS_FACTORY_HINT", 
     [kTechDataGhostModelClass] = "MarineGhostModel", 
     [kTechDataRequiresPower] = true,  
     [kTechDataDisplayName] = "ROBOTICS_FACTORY", 
    [kTechDataMapName] = RoboticsFactory.kMapName, 
   [kTechDataCostKey] = kRoboticsFactoryCost,  
       [kTechDataModel] = RoboticsFactory.kModelName,  
  [kTechDataEngagementDistance] = kRoboticsFactorEngagementDistance,
        [kTechDataSpecifyOrientation] = true,
   [kTechDataBuildTime] = kRoboticsFactoryBuildTime, 
   [kTechDataMaxHealth] = kRoboticsFactoryHealth,  
     [kTechDataMaxArmor] = kRoboticsFactoryArmor, 
   [kTechDataPointValue] = kRoboticsFactoryPointValue, 
   [kTechDataHotkey] = Move.R, 
  [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation, 
  [kTechDataTooltipInfo] = "ROBOTICS_FACTORY_TOOLTIP",
    [kTechDataObstacleRadius] = 2},        
    
        { [kTechDataId] = kTechId.UpgradeRoboticsFactory, [kTechDataDisplayName] = "UPGRADE_ROBOTICS_FACTORY", [kTechIDShowEnables] = false, [kTechDataCostKey] = kUpgradeRoboticsFactoryCost,   [kTechDataResearchTimeKey] = kUpgradeRoboticsFactoryTime, [kTechDataTooltipInfo] = "UPGRADE_ROBOTICS_FACTORY_TOOLTIP"},        
        { [kTechDataId] = kTechId.ARCRoboticsFactory, [kTechDataCostKey] = kRoboticsFactoryCost + kUpgradeRoboticsFactoryCost, [kTechDataHint] = "ARC_ROBOTICS_FACTORY_HINT", [kTechDataRequiresPower] = true,  [kTechIDShowEnables] = false,  [kTechDataDisplayName] = "ARC_ROBOTICS_FACTORY",  [kTechDataMapName] = ARCRoboticsFactory.kMapName, [kTechDataModel] = RoboticsFactory.kModelName,   [kTechDataEngagementDistance] = kRoboticsFactorEngagementDistance,        [kTechDataSpecifyOrientation] = true, [kTechDataBuildTime] = kRoboticsFactoryBuildTime, [kTechDataMaxHealth] = kARCRoboticsFactoryHealth,    [kTechDataMaxArmor] = kARCRoboticsFactoryArmor, [kTechDataPointValue] = kARCRoboticsFactoryPointValue, [kTechDataHotkey] = Move.R, [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation, [kTechDataTooltipInfo] = "ARC_ROBOTICS_FACTORY_TOOLTIP"},        

        { [kTechDataId] = kTechId.ARC, 
       [kTechDataSupply] = kARCSupply,
        [kTechDataHint] = "ARC_HINT",   
          [kTechDataDisplayName] = "ARC",   
                 // [kTechDataGhostModelClass] = "MarineGhostModel",  
       [kTechDataTooltipInfo] = "ARC_TOOLTIP", 
           [kTechDataBuildTime] = 8,
          // [kStructureBuildNearClass] = "ARCRoboticsFactory",
          // [kStructureAttachId] = kTechId.ARCRoboticsFactory,
          // [kTechDataGhostGuidesMethod] = GetArcGhostGuides,
          // [kStructureAttachRange] = 12,
    [kTechDataMapName] = ARC.kMapName,
     [kTechDataCostKey] = kARCCost,   
      [kTechDataDamageType] = kARCDamageType, 
     [kTechDataResearchTimeKey] = kARCBuildTime, 
    [kTechDataMaxHealth] = kARCHealth,
   [kTechDataEngagementDistance] = kARCEngagementDistance, 
     [kVisualRange] = ARC.kFireRange, 
    [kTechDataMaxArmor] = kARCArmor, 
    [kTechDataModel] = ARC.kModelName, 
    [kTechDataMaxHealth] = kARCHealth, 
   [kTechDataPointValue] = kARCPointValue, [kTechDataHotkey] = Move.T},
   
        { [kTechDataId] = kTechId.ARCSplashTech,        [kTechDataCostKey] = kARCSplashTechResearchCost,             [kTechDataResearchTimeKey] = kARCSplashTechResearchTime, [kTechDataDisplayName] = "ARC_SPLASH", [kTechDataImplemented] = false },
        { [kTechDataId] = kTechId.ARCArmorTech,         [kTechDataCostKey] = kARCArmorTechResearchCost,             [kTechDataResearchTimeKey] = kARCArmorTechResearchTime, [kTechDataDisplayName] = "ARC_ARMOR", [kTechDataImplemented] = false },
        
        // Upgrades
        { [kTechDataId] = kTechId.PhaseTech,    
          [kTechDataCostKey] = kPhaseTechResearchCost,  
               [kTechDataDisplayName] = "PHASE_TECH",
         [kTechDataResearchTimeKey] = kPhaseTechResearchTime, 
       [kTechDataTooltipInfo] = "PHASE_TECH_TOOLTIP" },
       
               { [kTechDataId] = kTechId.AdvancedBeaconTech,    
          [kTechDataCostKey] = kAdvancedBeaconTechResearchCost,  
               [kTechDataDisplayName] = "Advanced Beacon",
         [kTechDataResearchTimeKey] = kAdvancedBeaconTechResearchTime, 
       [kTechDataTooltipInfo] = "Unlocks Advanced Beacon, which ressurects dead players." },
       
        { [kTechDataId] = kTechId.PhaseGate, [kTechDataHint] = "PHASE_GATE_HINT", [kTechDataGhostModelClass] = "MarineGhostModel",   [kTechDataSupply] = kPhaseGateSupply, [kTechDataRequiresPower] = true,    [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation,    [kTechDataMapName] = PhaseGate.kMapName,                    [kTechDataDisplayName] = "PHASE_GATE",  [kTechDataCostKey] = kPhaseGateCost,       [kTechDataModel] = PhaseGate.kModelName, [kTechDataBuildTime] = kPhaseGateBuildTime, [kTechDataMaxHealth] = kPhaseGateHealth,   [kTechDataEngagementDistance] = kPhaseGateEngagementDistance, [kTechDataMaxArmor] = kPhaseGateArmor,   [kTechDataPointValue] = kPhaseGatePointValue, [kTechDataHotkey] = Move.P, [kTechDataSpecifyOrientation] = true, [kTechDataBuildRequiresMethod] = CheckSpaceForPhaseGate, [kTechDataTooltipInfo] = "PHASE_GATE_TOOLTIP", [kTechDataObstacleRadius] = 0.5},
   
      { [kTechDataId] = kTechId.AdvancedArmoryUpgrade,
        [kTechDataCostKey] = kAdvancedArmoryUpgradeCost,      
          [kTechDataResearchTimeKey] = kAdvancedArmoryResearchTime,
          [kTechDataHotkey] = Move.U, 
           [kTechDataDisplayName] = "ADVANCED_ARMORY_UPGRADE",
        [kTechDataTooltipInfo] =  "ADVANCED_ARMORY_TOOLTIP"},
        
        { [kTechDataId] = kTechId.PrototypeLab, [kTechDataHint] = "PROTOTYPE_LAB_HINT", [kTechDataGhostModelClass] = "MarineGhostModel",  [kTechDataRequiresPower] = true,  [kTechDataMapName] = PrototypeLab.kMapName,  [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation,   [kTechDataCostKey] = kPrototypeLabCost,                     [kTechDataResearchTimeKey] = kPrototypeLabBuildTime,       [kTechDataDisplayName] = "PROTOTYPE_LAB", [kTechDataModel] = PrototypeLab.kModelName, [kTechDataMaxHealth] = kPrototypeLabHealth, [kTechDataMaxArmor] = kPrototypeLabArmor, [kTechDataPointValue] = kPrototypeLabPointValue, [kTechDataTooltipInfo] = "PROTOTYPE_LAB_TOOLTIP", [kTechDataObstacleRadius] = 0.5},
       
        // Weapons
        
        { [kTechDataId] = kTechId.MinesTech,   [kTechDataCostKey] = kMineResearchCost, [kTechDataResearchTimeKey] = kMineResearchTime, [kTechDataDisplayName] = "MINES"},
        { [kTechDataId] = kTechId.LayMines,    [kTechDataMapName] = LayMines.kMapName,         [kTechDataPointValue] = kLayMinesPointValue,   [kTechDataMaxHealth] = kMarineWeaponHealth,   [kTechDataDisplayName] = "MINE",   [kTechDataModel] = Mine.kModelName,      [kTechDataCostKey] = kMineCost },
        { [kTechDataId] = kTechId.Mine,        [kTechDataMapName] = Mine.kMapName,             [kTechDataHint] = "MINE_HINT", [kTechDataDisplayName] = "MINE", [kTechDataEngagementDistance] = kMineDetonateRange, [kTechDataMaxHealth] = kMineHealth, [kTechDataTooltipInfo] = "MINE_TOOLTIP",  [kTechDataMaxArmor] = kMineArmor, [kTechDataModel] = Mine.kModelName, [kTechDataPointValue] = kMinePointValue, },

        { [kTechDataId] = kTechId.WelderTech,  [kTechDataCostKey] = kWelderTechResearchCost,     [kTechDataResearchTimeKey] = kWelderTechResearchTime, [kTechDataDisplayName] = "RESEARCH_WELDER", [kTechDataHotkey] = Move.F, [kTechDataTooltipInfo] =  "WELDER_TECH_TOOLTIP"},
        { [kTechDataId] = kTechId.Welder,     [kTechDataMaxHealth] = kMarineWeaponHealth,  [kTechDataMapName] = Welder.kMapName,                    [kTechDataDisplayName] = "WELDER",      [kTechDataModel] = Welder.kModelName, [kTechDataDamageType] = kWelderDamageType, [kTechDataCostKey] = kWelderCost  },
        
        { [kTechDataId] = kTechId.Claw,      [kTechDataMapName] = Claw.kMapName, [kTechDataDisplayName] = "CLAW",  [kTechDataDamageType] = kClawDamageType },

        { [kTechDataId] = kTechId.Rifle,      [kTechDataMaxHealth] = kMarineWeaponHealth, [kTechDataTooltipInfo] = "RIFLE_TOOLTIP",    [kTechDataMapName] = Rifle.kMapName,                    [kTechDataDisplayName] = "RIFLE",         [kTechDataModel] = RifleVariantMixin.kModelNames.rifle[RifleVariantMixin.kDefaultModelName], [kTechDataDamageType] = kRifleDamageType, [kTechDataCostKey] = kRifleCost, },
        { [kTechDataId] = kTechId.Pistol,     [kTechDataMaxHealth] = kMarineWeaponHealth,       [kTechDataMapName] = Pistol.kMapName,                   [kTechDataDisplayName] = "PISTOL",         [kTechDataModel] = Pistol.kModelName, [kTechDataDamageType] = kPistolDamageType, [kTechDataCostKey] = kPistolCost, [kTechDataTooltipInfo] = "PISTOL_TOOLTIP"},
        { [kTechDataId] = kTechId.Axe,                   [kTechDataMapName] = Axe.kMapName,                      [kTechDataDisplayName] = "SWITCH_AX",         [kTechDataModel] = Axe.kModelName, [kTechDataDamageType] = kAxeDamageType, [kTechDataCostKey] = kAxeCost, [kTechDataTooltipInfo] = "AXE_TOOLTIP"},
        { [kTechDataId] = kTechId.Shotgun,     [kTechDataMaxHealth] = kMarineWeaponHealth,    [kTechDataPointValue] = kShotgunPointValue,      [kTechDataMapName] = Shotgun.kMapName,                  [kTechDataDisplayName] = "SHOTGUN",             [kTechDataTooltipInfo] =  "SHOTGUN_TOOLTIP", [kTechDataModel] = Shotgun.kModelName, [kTechDataDamageType] = kShotgunDamageType, [kTechDataCostKey] = kShotgunCost, [kStructureAttachId] = kTechId.Armory, [kStructureAttachRange] = kArmoryWeaponAttachRange, [kStructureAttachRequiresPower] = true },
   
     { [kTechDataId] = kTechId.HeavyRifle,   
       [kTechDataMaxHealth] = kMarineWeaponHealth,
       [kTechDataTooltipInfo] = "Onifle", 
       [kTechDataPointValue] = kWeaponPointValue,   
        [kTechDataMapName] = HeavyRifle.kMapName,   
          [kTechDataDisplayName] = "Onifle",  
       [kTechDataDamageType] = kHeavyRifleDamageType, 
     [kTechDataCostKey] = kHeavyRifleCost, },
        [kTechDataModel] = HeavyRifle.kModelName, 
        
              
       { [kTechDataId] = kTechId.ExoNanoArmor,
        [kTechDataCostKey] = 5,
        [kTechDataDisplayName] = "Exo Regeneration Armor", 
        [kTechDataHotkey] = Move.Z, 
      [kTechDataTooltipInfo] = "Experiment for Exo Armor Regeneration"},
      
             { [kTechDataId] = kTechId.JumpPack,
        [kTechDataCostKey] = kJumpPackCost,
        [kTechDataDisplayName] = "Jump Pack", 
        [kTechDataHotkey] = Move.Z, 
      [kTechDataTooltipInfo] = "Mimics the NS1/HL1 JumpPack (With Attempted Balance Modifications WIP) - Press DUCK + Jump @ the same time to mindfuck the alien team."},

             { [kTechDataId] = kTechId.FireBullets,
        [kTechDataCostKey] = kJumpPackCost,
        [kTechDataDisplayName] = "Fire Bullets", 
        [kTechDataHotkey] = Move.Z, 
      [kTechDataTooltipInfo] = "Experiment: 10% Damage Bonus to Structures. .01 Energy Drain per bullet on Players. Sets Structures & Players On Fire"},


        // hand grenades

        { [kTechDataId] = kTechId.ClusterGrenade,  [kTechDataMapName] = ClusterGrenadeThrower.kMapName,   [kTechDataDisplayName] = "CLUSTER_GRENADE", [kTechDataTooltipInfo] =  "CLUSTER_GRENADE_TOOLTIP", [kTechDataCostKey] = kClusterGrenadeCost },
        { [kTechDataId] = kTechId.GasGrenade,  [kTechDataMapName] = GasGrenadeThrower.kMapName,   [kTechDataDisplayName] = "GAS_GRENADE", [kTechDataTooltipInfo] =  "GAS_GRENADE_TOOLTIP", [kTechDataCostKey] = kGasGrenadeCost },
        { [kTechDataId] = kTechId.PulseGrenade,  [kTechDataMapName] = PulseGrenadeThrower.kMapName,   [kTechDataDisplayName] = "PULSE_GRENADE", [kTechDataTooltipInfo] =  "PULSE_GRENADE_TOOLTIP", [kTechDataCostKey] = kPulseGrenadeCost },
 
        { [kTechDataId] = kTechId.ClusterGrenadeProjectile, [kTechDataDamageType] = kClusterGrenadeDamageType,  [kTechDataMapName] = ClusterGrenade.kMapName,   [kTechDataDisplayName] = "CLUSTER_GRENADE", [kTechDataTooltipInfo] =  "CLUSTER_GRENADE_TOOLTIP", [kTechDataDamageType] = kClusterGrenadeDamageType },
        { [kTechDataId] = kTechId.GasGrenadeProjectile, [kTechDataDamageType] = kNerveGasDamageType,  [kTechDataMapName] = GasGrenade.kMapName,   [kTechDataDisplayName] = "GAS_GRENADE", [kTechDataTooltipInfo] =  "GAS_GRENADE_TOOLTIP", [kTechDataDamageType] = kGasGrenadeDamageType },
        { [kTechDataId] = kTechId.PulseGrenadeProjectile,  [kTechDataDamageType] = kPulseGrenadeDamageType, [kTechDataMapName] = PulseGrenade.kMapName,   [kTechDataDisplayName] = "PULSE_GRENADE", [kTechDataTooltipInfo] =  "PULSE_GRENADE_TOOLTIP", [kTechDataDamageType] = kPulseGrenadeDamageType },

 
        // dropped by commander:
        
        { [kTechDataId] = kTechId.FlamethrowerTech,      [kTechDataCostKey] = kFlamethrowerTechResearchCost,     [kTechDataResearchTimeKey] = kFlamethrowerTechResearchTime, [kTechDataDisplayName] = "RESEARCH_FLAMETHROWERS", [kTechDataTooltipInfo] =  "FLAMETHROWER_TECH_TOOLTIP"},
        { [kTechDataId] = kTechId.FlamethrowerRangeTech,      [kTechDataCostKey] = kFlamethrowerRangeTechResearchCost,     [kTechDataResearchTimeKey] = kFlamethrowerRangeTechResearchTime, [kTechDataDisplayName] = "FLAMETHROWER_RANGE", [kTechDataTooltipInfo] =  "FLAMETHROWER_RANGE_TOOLTIP"},
        { [kTechDataId] = kTechId.Flamethrower,     [kTechDataMaxHealth] = kMarineWeaponHealth, [kTechDataPointValue] = kFlamethrowerPointValue,  [kTechDataMapName] = Flamethrower.kMapName,             [kTechDataDisplayName] = "FLAMETHROWER", [kTechDataTooltipInfo] = "FLAMETHROWER_TOOLTIP", [kTechDataModel] = Flamethrower.kModelName,  [kTechDataDamageType] = kFlamethrowerDamageType, [kTechDataCostKey] = kFlamethrowerCost, [kStructureAttachId] = kTechId.Armory, [kStructureAttachRange] = kArmoryWeaponAttachRange, [kStructureAttachRequiresPower] = true},
        { [kTechDataId] = kTechId.DualMinigunTech,   [kTechDataCostKey] = kDualMinigunTechResearchCost,      [kTechDataResearchTimeKey] = kDualRailgunTechResearchTime, [kTechDataDisplayName] = "RESEARCH_DUAL_EXOS", [kTechDataHotkey] = Move.D, [kTechDataTooltipInfo] = "DUAL_MINIGUN_TECH_TOOLTIP"},
        { [kTechDataId] = kTechId.ClawRailgunTech,   [kTechIDShowEnables] = false,    [kTechDataCostKey] = kClawRailgunTechResearchCost,      [kTechDataResearchTimeKey] = kClawMinigunTechResearchTime, [kTechDataDisplayName] = "RESEARCH_CLAW_RAILGUN", [kTechDataHotkey] = Move.D, [kTechDataTooltipInfo] = "CLAW_RAILGUN_TECH_TOOLTIP"},
        { [kTechDataId] = kTechId.DualRailgunTech,   [kTechIDShowEnables] = false,   [kTechDataCostKey] = kDualRailgunTechResearchCost,      [kTechDataResearchTimeKey] = kDualMinigunTechResearchTime, [kTechDataDisplayName] = "RESEARCH_DUAL_RAILGUNS", [kTechDataHotkey] = Move.D, [kTechDataTooltipInfo] = "DUAL_RAILGUN_TECH_TOOLTIP"},
        { [kTechDataId] = kTechId.Minigun,        [kTechDataPointValue] = kMinigunPointValue,       [kTechDataMapName] = Minigun.kMapName,                  [kTechDataDisplayName] = "MINIGUN", [kTechDataDamageType] = kMinigunDamageType, [kTechDataDisplayName] = "MINIGUN_CLAW_TOOLTIP", [kTechDataModel] = Minigun.kModelName},
        { [kTechDataId] = kTechId.Railgun,        [kTechDataPointValue] = kRailgunPointValue,       [kTechDataMapName] = Railgun.kMapName,                  [kTechDataDisplayName] = "RAILGUN", [kTechDataDamageType] = kRailgunDamageType, [kTechDataDisplayName] = "RAILGUN_CLAW_TOOLTIP", [kTechDataModel] = Railgun.kModelName},
        { [kTechDataId] = kTechId.GrenadeLauncher,    [kTechDataMaxHealth] = kMarineWeaponHealth,  [kTechDataPointValue] = kGrenadeLauncherPointValue, [kTechDataMapName] = GrenadeLauncher.kMapName,          [kTechDataDisplayName] = "GRENADE_LAUNCHER",  [kTechDataTooltipInfo] = "GRENADE_LAUNCHER_TOOLTIP",   [kTechDataModel] = GrenadeLauncher.kModelName,   [kTechDataDamageType] = kRifleDamageType,    [kTechDataCostKey] = kGrenadeLauncherCost, [kStructureAttachId] = kTechId.Armory, [kStructureAttachRange] = kArmoryWeaponAttachRange, [kStructureAttachRequiresPower] = true},

        { [kTechDataId] = kTechId.DropHeavyRifle, 
  [kTechDataMapName] = HeavyRifle.kMapName, 
[kTechDataDisplayName] = "Onifle",
 [kTechIDShowEnables] = false,
  [kTechDataTooltipInfo] =  "Because Testing", 
[kTechDataModel] = Rifle.kModelName, 
[kTechDataCostKey] = 20, 
[kStructureAttachId] = kTechId.Armory, 
[kStructureAttachRange] = kArmoryWeaponAttachRange, 
[kStructureAttachRequiresPower] = true },

        { [kTechDataId] = kTechId.DropShotgun,   
[kTechDataMapName] = Shotgun.kMapName, 
[kTechDataDisplayName] = "SHOTGUN",
 [kTechIDShowEnables] = false,  
[kTechDataTooltipInfo] =  "SHOTGUN_TOOLTIP", 
[kTechDataModel] = Shotgun.kModelName, 
[kTechDataCostKey] = kShotgunDropCost,
 [kStructureAttachId] = { kTechId.Armory, kTechId.AdvancedArmory }, 
[kStructureAttachRange] = kArmoryWeaponAttachRange,
 [kStructureAttachRequiresPower] = true },

        { [kTechDataId] = kTechId.DropWelder,    [kTechDataMapName] = Welder.kMapName, [kTechDataDisplayName] = "WELDER", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] =  "WELDER_TOOLTIP", [kTechDataModel] = Welder.kModelName, [kTechDataCostKey] = kWelderDropCost, [kStructureAttachId] = { kTechId.Armory, kTechId.AdvancedArmory }, [kStructureAttachRange] = kArmoryWeaponAttachRange, [kStructureAttachRequiresPower] = true },
        { [kTechDataId] = kTechId.DropMines,   [kTechDataMapName] = LayMines.kMapName, [kTechDataDisplayName] = "MINE", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] =  "MINE_TOOLTIP", [kTechDataModel] = Mine.kModelName, [kTechDataCostKey] = kDropMineCost, [kStructureAttachId] = { kTechId.Armory, kTechId.AdvancedArmory }, [kStructureAttachRange] = kArmoryWeaponAttachRange, [kStructureAttachRequiresPower] = true },
        { [kTechDataId] = kTechId.DropGrenadeLauncher,   [kTechDataMapName] = GrenadeLauncher.kMapName, [kTechIDShowEnables] = false, [kTechDataDisplayName] = "GRENADE_LAUNCHER", [kTechDataTooltipInfo] =  "GRENADE_LAUNCHER_TOOLTIP", [kTechDataModel] = GrenadeLauncher.kModelName, [kTechDataCostKey] = kGrenadeLauncherDropCost, [kStructureAttachId] = kTechId.Armory, [kStructureAttachRange] = kArmoryWeaponAttachRange, [kStructureAttachRequiresPower] = true },
        { [kTechDataId] = kTechId.DropFlamethrower,   [kTechDataMapName] = Flamethrower.kMapName, [kTechDataDisplayName] = "FLAMETHROWER", [kTechIDShowEnables] = false,  [kTechDataTooltipInfo] =  "FLAMETHROWER_TOOLTIP", [kTechDataModel] = Flamethrower.kModelName, [kTechDataCostKey] = kFlamethrowerDropCost, [kStructureAttachId] = kTechId.Armory, [kStructureAttachRange] = kArmoryWeaponAttachRange, [kStructureAttachRequiresPower] = true },
        { [kTechDataId] = kTechId.DropJetpack,   [kTechDataMapName] = Jetpack.kMapName, [kTechDataDisplayName] = "JETPACK", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] =  "JETPACK_TOOLTIP", [kTechDataModel] = Jetpack.kModelName, [kTechDataCostKey] = kJetpackDropCost, [kStructureAttachId] = kTechId.PrototypeLab, [kStructureAttachRange] = kArmoryWeaponAttachRange, [kStructureAttachRequiresPower] = true },
        { [kTechDataId] = kTechId.DropExosuit, [kTechDataBuildRequiresMethod] = GetExoLimit, [kTechDataBuildMethodFailedMessage] = "3 live exosuits max",   [kTechDataMapName] = Exosuit.kMapName, [kTechDataDisplayName] = "EXOSUIT", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] =  "EXOSUIT_TOOLTIP", [kTechDataModel] = Exosuit.kModelName, [kTechDataCostKey] = kExosuitDropCost, [kStructureAttachId] = kTechId.PrototypeLab, [kStructureAttachRange] = kArmoryWeaponAttachRange, [kStructureAttachRequiresPower] = true },
       
        // Armor and upgrades
        { [kTechDataId] = kTechId.Jetpack,   [kTechDataMapName] = Jetpack.kMapName,                   [kTechDataDisplayName] = "JETPACK", [kTechDataModel] = Jetpack.kModelName, [kTechDataCostKey] = kJetpackCost, [kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight },
        { [kTechDataId] = kTechId.JetpackTech,    [kTechDataCostKey] = kJetpackTechResearchCost,               [kTechDataResearchTimeKey] = kJetpackTechResearchTime,     [kTechDataDisplayName] = "JETPACK_TECH" },
        { [kTechDataId] = kTechId.JetpackFuelTech,       [kTechDataCostKey] = kJetpackFuelTechResearchCost,           [kTechDataResearchTimeKey] = kJetpackFuelTechResearchTime,     [kTechDataDisplayName] = "JETPACK_FUEL_TECH", [kTechDataHotkey] = Move.F, [kTechDataTooltipInfo] =  "JETPACK_FUEL_TOOLTIP"},
        { [kTechDataId] = kTechId.JetpackArmorTech,       [kTechDataCostKey] = kJetpackArmorTechResearchCost,         [kTechDataResearchTimeKey] = kJetpackArmorTechResearchTime,     [kTechDataDisplayName] = "JETPACK_ARMOR_TECH", [kTechDataImplemented] = false, [kTechDataHotkey] = Move.S, [kTechDataTooltipInfo] = "JETPACK_ARMOR_TOOLTIP"},

        
        { [kTechDataId] = kTechId.Exosuit,           [kTechDataDisplayName] = "EXOSUIT", [kTechDataMapName] = "exo",               [kTechDataCostKey] = kExosuitCost, [kTechDataHotkey] = Move.E, [kTechDataTooltipInfo] = "EXOSUIT_TECH_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},
        { [kTechDataId] = kTechId.DualMinigunExosuit,     [kTechIDShowEnables] = false,       [kTechDataDisplayName] = "DUALMINIGUN_EXOSUIT", [kTechDataMapName] = "exo",               [kTechDataCostKey] = kDualExosuitCost, [kTechDataHotkey] = Move.E, [kTechDataTooltipInfo] = "DUALMINIGUN_EXOSUIT_TECH_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},
        { [kTechDataId] = kTechId.ClawRailgunExosuit,     [kTechIDShowEnables] = false,       [kTechDataDisplayName] = "CLAWRAILGUN_EXOSUIT", [kTechDataMapName] = "exo",               [kTechDataCostKey] = kClawRailgunExosuitCost, [kTechDataHotkey] = Move.E, [kTechDataTooltipInfo] = "CLAWRAILGUN_EXOSUIT_TECH_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},
        { [kTechDataId] = kTechId.DualRailgunExosuit,     [kTechIDShowEnables] = false,       [kTechDataDisplayName] = "DUALRAILGUN_EXOSUIT", [kTechDataMapName] = "exo",               [kTechDataCostKey] = kDualRailgunExosuitCost, [kTechDataHotkey] = Move.E, [kTechDataTooltipInfo] = "DUALRAILGUN_EXOSUIT_TECH_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},
        { [kTechDataId] = kTechId.ExosuitTech,        [kTechDataDisplayName] = "RESEARCH_EXOSUITS", [kTechDataCostKey] = kExosuitTechResearchCost,  [kTechDataResearchTimeKey] = kExosuitTechResearchTime},
        { [kTechDataId] = kTechId.ExosuitLockdownTech,  [kTechDataCostKey] = kExosuitLockdownTechResearchCost,               [kTechDataResearchTimeKey] = kExosuitLockdownTechResearchTime,     [kTechDataDisplayName] = "EXOSUIT_LOCKDOWN_TECH", [kTechDataImplemented] = false, [kTechDataHotkey] = Move.L, [kTechDataTooltipInfo] = "EXOSUIT_LOCKDOWN_TOOLTIP"},
        { [kTechDataId] = kTechId.ExosuitUpgradeTech,  [kTechDataCostKey] = kExosuitUpgradeTechResearchCost,               [kTechDataResearchTimeKey] = kExosuitUpgradeTechResearchTime,     [kTechDataDisplayName] = "EXOSUIT_UPGRADE_TECH", [kTechDataImplemented] = false },
        { [kTechDataId] = kTechId.UpgradeToDualMinigun, [kTechIDShowEnables] = false, [kTechDataCostKey] = kUpgradeToDualMinigunCost,   [kTechDataDisplayName] = "DUALMINIGUN_EXOSUIT" },
        { [kTechDataId] = kTechId.UpgradeToDualRailgun, [kTechIDShowEnables] = false, [kTechDataCostKey] = kUpgradeToDualRailgunCost,   [kTechDataDisplayName] = "DUALRAILGUN_EXOSUIT" },
        
        // Armor research
        { [kTechDataId] = kTechId.Armor1,                [kTechDataCostKey] = kArmor1ResearchCost,                   [kTechDataResearchTimeKey] = kArmor1ResearchTime,     [kTechDataDisplayName] = "MARINE_ARMOR1",  [kTechDataTooltipInfo] = "MARINE_ARMOR1_TOOLTIP"},
        { [kTechDataId] = kTechId.Armor2,                [kTechDataCostKey] = kArmor2ResearchCost,                   [kTechDataResearchTimeKey] = kArmor2ResearchTime,     [kTechDataDisplayName] = "MARINE_ARMOR2",  [kTechDataTooltipInfo] = "MARINE_ARMOR2_TOOLTIP"},
        { [kTechDataId] = kTechId.Armor3,                [kTechDataCostKey] = kArmor3ResearchCost,                   [kTechDataResearchTimeKey] = kArmor3ResearchTime,     [kTechDataDisplayName] = "MARINE_ARMOR3",  [kTechDataTooltipInfo] = "MARINE_ARMOR3_TOOLTIP"},
        { [kTechDataId] = kTechId.NanoArmor,             [kTechDataCostKey] = kNanoArmorResearchCost,                [kTechDataResearchTimeKey] = kNanoArmorResearchTime,     [kTechDataDisplayName] = "NANO_ARMOR",  [kTechDataTooltipInfo] = "NANO_ARMOR_TOOLTIP"},

        // Weapons research
        { [kTechDataId] = kTechId.Weapons1,              [kTechDataCostKey] = kWeapons1ResearchCost,                 [kTechDataResearchTimeKey] = kWeapons1ResearchTime,     [kTechDataDisplayName] = "MARINE_WEAPONS1", [kTechDataHotkey] = Move.Z, [kTechDataTooltipInfo] = "MARINE_WEAPONS1_TOOLTIP"},
        { [kTechDataId] = kTechId.Weapons2,              [kTechDataCostKey] = kWeapons2ResearchCost,                 [kTechDataResearchTimeKey] = kWeapons2ResearchTime,     [kTechDataDisplayName] = "MARINE_WEAPONS2", [kTechDataHotkey] = Move.Z, [kTechDataTooltipInfo] = "MARINE_WEAPONS2_TOOLTIP"},
        { [kTechDataId] = kTechId.Weapons3,              [kTechDataCostKey] = kWeapons3ResearchCost,                 [kTechDataResearchTimeKey] = kWeapons3ResearchTime,     [kTechDataDisplayName] = "MARINE_WEAPONS3", [kTechDataHotkey] = Move.Z, [kTechDataTooltipInfo] = "MARINE_WEAPONS3_TOOLTIP"},



    
            { [kTechDataId] = kTechId.NutrientMist, 
        [kTechDataMapName] = NutrientMist.kMapName,
       [kTechDataAllowStacking] = true,
       [kTechDataIgnorePathingMesh] = true, 
       [kTechDataCollideWithWorldOnly] = true,
       [kTechDataRequiresInfestation] = true, 
       [kTechDataRequiresInfestation] = true, 
      [kTechDataDisplayName] = "NUTRIENT_MIST", 
        [kTechDataCostKey] = kNutrientMistCost, 
     [kTechDataCooldown] = kNutrientMistCooldown, 
      [kTechDataTooltipInfo] =  "NUTRIENT_MIST_TOOLTIP"},
      
      
                  { [kTechDataId] = kTechId.EtheralGate, 
        [kTechDataMapName] = EtherealGate.kMapName,
       [kTechDataAllowStacking] = true,
       [kTechDataIgnorePathingMesh] = true, 
       [kTechDataCollideWithWorldOnly] = true,
       [kTechDataRequiresInfestation] = true, 
      [kTechDataDisplayName] = "Etheral Gate", 
        [kTechDataCostKey] = 5, 
     [kTechDataCooldown] = 8, 
      [kTechDataTooltipInfo] =  "Kind of puts marines and structures in another dimension - making them useless - but also unable be damaged"},
      
            { [kTechDataId] = kTechId.ControlledHallucination,  
        [kTechDataMapName] = HallucinationExplosion.kMapName,      
       [kTechDataCostKey] = 5,      
            [kTechDataCooldown] = 30, 
       [kTechDataRequiresInfestation] = true,
        [kTechDataResearchTimeKey] = 10,     
     [kTechDataDisplayName] = "Controlled Hallucination",  
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = ""},
    
                { [kTechDataId] = kTechId.HallucinationExplosion,        
       [kTechDataCostKey] = 5,      
     [kTechDataDisplayName] = "BOOM!",  
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = ""},
    
    
                    { [kTechDataId] = kTechId.EggBeaconChoiceOne,        
       [kTechDataCostKey] = 50,      
       [kTechDataRequiresInfestation] = true,  
     [kTechDataDisplayName] = "Egg Beacon Tier 3",  
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = "Egg Beacon Tier #3 - Have Eggs Spawn DIRECTLY at the placed Egg Beacon for 30 seconds"},
    
            { [kTechDataId] = kTechId.SmellOrder,        
       [kTechDataCostKey] = 25,      
        [kTechDataResearchTimeKey] = 10,     
     [kTechDataDisplayName] = "Egg Beacon Tier 2",  
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = "Simply tells all newly spawned eggs after the Egg Beacon has been placed, to smell the move order once the new egg spawns. Where as without this, will not do."},
    
    
                    { [kTechDataId] = kTechId.EggBeaconChoiceTwo,        
       [kTechDataCostKey] = 15,      
       [kTechDataRequiresInfestation] = true,  
     [kTechDataDisplayName] = "Egg Beacon Tier 1",  
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = "Egg Beacon Tier #1 - Have Eggs MOVE NEAR the placed Egg Beacon for 30 seconds"},
    
    
                        { [kTechDataId] = kTechId.ControlledHallucinationTierOne,        
       [kTechDataCostKey] = 15,      
       [kTechDataRequiresInfestation] = true,  
     [kTechDataDisplayName] = "Controlled Hallucination Tier 1",  
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = "Controlled Hallucination Tier 1 - Onos - Double HP/Armor value of regular hallucination - Does not attack - Is manually controlled"},
    
                          { [kTechDataId] = kTechId.ControlledHallucinationTierTwo,        
       [kTechDataCostKey] = 25,      
       [kTechDataRequiresInfestation] = true,  
     [kTechDataDisplayName] = "Controlled Hallucination Tier 2",  
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = "Controlled Hallucination Tier 2 - Same as Tier 1 but with the addition of XENOCIDE"},  
    
                              { [kTechDataId] = kTechId.ControlledHallucinationTierThree,        
       [kTechDataCostKey] = 50,      
       [kTechDataRequiresInfestation] = true,  
     [kTechDataDisplayName] = "Controlled Hallucination Tier 3",  
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = "Controlled Hallucination Tier 3 - Same as Tier 2 but with the addition of attacking, and has half the health of an onos."},  
    
    
    
        { [kTechDataId] = kTechId.CragStackOne,        
       [kTechDataCostKey] = 15,      
        [kTechDataResearchTimeKey] = 5,     
     [kTechDataDisplayName] = "Crag Stack 1",  
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = "Heal Bonus = CragsInRange( (min 0 (max biomasslevel/4) ) / Stack Level(0-3)"},
    
        { [kTechDataId] = kTechId.CragStackTwo,          
      [kTechDataCostKey] = 25,      
          [kTechDataResearchTimeKey] = 15,   
      [kTechDataDisplayName] = "Crag Stack 2",
     [kTechDataHotkey] = Move.Z,
   [kTechDataTooltipInfo] = "Heal Bonus = = CragsInRange( (min 0 (max biomasslevel/4) ) / Stack Level(0-3)"},
   

        { [kTechDataId] = kTechId.CragStackThree,       
        [kTechDataCostKey] = 50,     
             [kTechDataResearchTimeKey] = 25,  
        [kTechDataDisplayName] = "Crag Stack 3", 
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = "Heal Bonus = CragsInRange( (min 0 (max biomasslevel/4) ) / Stack Level(0-3)"},
        
                { [kTechDataId] = kTechId.CragArcBonus,       
        [kTechDataCostKey] = kWeapons3ResearchCost,     
             [kTechDataResearchTimeKey] = kWeapons3ResearchTime,  
        [kTechDataDisplayName] = "CragHeal Arc Bonus", 
      [kTechDataHotkey] = Move.Z, 
    [kTechDataTooltipInfo] = "1 arc inside of the crag heal radius adds 25% heal amount to Crags and Hives only. This is meant for Siege or primary Crags following the team. Caps at 100% (Double)"},
    
        { [kTechDataId] = kTechId.RifleClip,
        [kTechDataCostKey] = kRifleClipCost,
        [kTechDataResearchTimeKey] = kRifleClipTime,     
        [kTechDataDisplayName] = "+25 rifle clip", 
        [kTechDataHotkey] = Move.Z, 
      [kTechDataTooltipInfo] = "+25 ammo for rifles"},
      
              { [kTechDataId] = kTechId.ArmoryArmor,
        [kTechDataCostKey] = kArmoryArmorCost,
        [kTechDataResearchTimeKey] = kArmoryArmorTime,     
        [kTechDataDisplayName] = "Heal Armor", 
        [kTechDataHotkey] = Move.Z, 
      [kTechDataTooltipInfo] = "Allows healing of player armor ontop of health"},
      
                    { [kTechDataId] = kTechId.ArmoryHealth,
        [kTechDataCostKey] = kArmoryArmorCost,
        [kTechDataResearchTimeKey] = kArmoryArmorTime,     
        [kTechDataDisplayName] = "Health Buff", 
        [kTechDataHotkey] = Move.Z, 
      [kTechDataTooltipInfo] = "Experiment to remove the health buff from AA and replace it with this own seperate research"},
      

      
      
      
                    { [kTechDataId] = kTechId.MacWeldMacs,
        [kTechDataCostKey] = kMacWeldMacsCost,
        [kTechDataResearchTimeKey] = kMacWeldMacsTime,     
        [kTechDataDisplayName] = "Macs Weld Eachother", 
        [kTechDataHotkey] = Move.Z, 
      [kTechDataTooltipInfo] = "Allows Macs to weld eachother."},
      
      
                            { [kTechDataId] = kTechId.MoveThroughLockedDoorOn,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Open locked doors",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "ENABLE walking through locked doors and temporarily opening them to get through"},
         
                                     { [kTechDataId] = kTechId.MoveThroughLockedDoorOff,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "DO NOT open locked doors",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "Disable the ability to move through locked doors by not opening them"},
         
               
                { [kTechDataId] = kTechId.MacSpawnOn,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Automatically spawn up to 8 macs for you",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "8 is currently the max amount to automatically spawn this way. Turning this on will automatically spawn up to this many for you"},
         
          { [kTechDataId] = kTechId.MacSpawnOff,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Disables automatic small mac spawning",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "For those who prefer micro-micro management"},
         
         { [kTechDataId] = kTechId.ArcSpawnOn,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Automatically spawn up to 12 arcs for you",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "12 is currently the max amount of commander arcs. Turning this on will automatically spawn up to this many for you"},
         
          { [kTechDataId] = kTechId.ArcSpawnOff,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Disables automatic arc spawning",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "For those who prefer micro-micro management"},
         
         
                  { [kTechDataId] = kTechId.InkTriggerOn,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Enable Ink Trigger",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "Click to Enable - Disables the normal manual ability to Ink in trade for automatic triggered Ink whenever a scan is detected in this shade radius if the cooldown is recharged"},
         
          { [kTechDataId] = kTechId.InkTriggerOff,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Disable Ink Trigger",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "Click to Disable - Disable Automatically trigger Ink whenever a scan is detected in this shade radius if the cooldown is recharged"},
         
      
      
        
        { [kTechDataId] = kTechId.ShotgunTech,           [kTechDataCostKey] = kShotgunTechResearchCost,           [kTechDataResearchTimeKey] = kShotgunTechResearchTime, [kTechDataDisplayName] = "RESEARCH_SHOTGUNS", [kTechDataTooltipInfo] =  "SHOTGUN_TECH_TOOLTIP"},
        { [kTechDataId] = kTechId.HeavyRifleTech,           [kTechDataCostKey] = kHeavyRifleTechResearchCost,        [kTechDataResearchTimeKey] = kHeavyRifleTechResearchTime, [kTechDataDisplayName] = "Research Onifle", [kTechDataTooltipInfo] =  "Pronounced oni-full ~ up to +20% dmg against Oni. Think of it as weapons 6 upgrade.. except marines must individually purchase the rifle for 10 res each time, but atleast it comes with +75 ammo"},
        { [kTechDataId] = kTechId.GrenadeLauncherTech,   [kTechDataCostKey] = kGrenadeLauncherTechResearchCost,   [kTechDataResearchTimeKey] = kGrenadeLauncherTechResearchTime, [kTechDataDisplayName] = "RESEARCH_GRENADE_LAUNCHERS", [kTechDataTooltipInfo] = "GRENADE_LAUNCHER_TECH_TOOLTIP"},
        { [kTechDataId] = kTechId.GrenadeTech,           [kTechDataCostKey] = kGrenadeTechResearchCost,           [kTechDataResearchTimeKey] = kGrenadeTechResearchTime, [kTechDataDisplayName] = "RESEARCH_GRENADES", [kTechDataTooltipInfo] = "GRENADES_TOOLTIP"},
        { [kTechDataId] = kTechId.AdvancedWeaponry,      [kTechDataCostKey] = kAdvancedWeaponryResearchCost,      [kTechDataResearchTimeKey] = kAdvancedWeaponryResearchTime, [kTechDataDisplayName] = "ADVANCED_WEAPONRY", [kTechDataHotkey] = Move.G, [kTechDataTooltipInfo] = "ADVANCED_WEAPONRY_TOOLTIP"},
        
        // ARC abilities
        { [kTechDataId] = kTechId.ARCDeploy, [kTechIDShowEnables] = false, [kTechDataResearchTimeKey] = kARCDeployTime, [kTechDataDisplayName] = "ARC_DEPLOY",                     [kTechDataMenuPriority] = 2, [kTechDataHotkey] = Move.D, [kTechDataTooltipInfo] = "ARC_DEPLOY_TOOLTIP"},
        { [kTechDataId] = kTechId.ARCUndeploy,  [kTechIDShowEnables] = false,  [kTechDataResearchTimeKey] = kARCUndeployTime, [kTechDataDisplayName] = "ARC_UNDEPLOY",                    [kTechDataMenuPriority] = 3, [kTechDataHotkey] = Move.D, [kTechDataTooltipInfo] = "ARC_UNDEPLOY_TOOLTIP"},

        // upgradeable life forms
        { [kTechDataId] = kTechId.LifeFormMenu,           [kTechDataDisplayName] = "BASIC_LIFE_FORMS", [kTechDataTooltipInfo] = "BASIC_LIFE_FORMS_TOOLTIP", },
        { [kTechDataId] = kTechId.SkulkMenu,              [kTechDataDisplayName] = "UPGRADE_SKULK",    [kTechDataTooltipInfo] = "UPGRADE_SKULK_TOOLTIP", },
        { [kTechDataId] = kTechId.GorgeMenu,              [kTechDataDisplayName] = "UPGRADE_GORGE",    [kTechDataTooltipInfo] = "UPGRADE_GORGE_TOOLTIP", },
        { [kTechDataId] = kTechId.LerkMenu,               [kTechDataDisplayName] = "UPGRADE_LERK",     [kTechDataTooltipInfo] = "UPGRADE_LERK_TOOLTIP", },
        { [kTechDataId] = kTechId.FadeMenu,               [kTechDataDisplayName] = "UPGRADE_FADE",     [kTechDataTooltipInfo] = "UPGRADE_FADE_TOOLTIP", },
        { [kTechDataId] = kTechId.OnosMenu,               [kTechDataDisplayName] = "UPGRADE_ONOS",     [kTechDataTooltipInfo] = "UPGRADE_ONOS_TOOLTIP", },
        
        { [kTechDataId] = kTechId.UpgradeSkulk,    [kTechDataCostKey] = kUpgradeSkulkResearchCost,    [kTechDataResearchTimeKey] = kUpgradeSkulkResearchTime,     [kTechDataDisplayName] = "UPGRADE_SKULK", [kTechDataTooltipInfo] = "UPGRADE_SKULK_TOOLTIP",    [kTechDataMenuPriority] = -1 },
        { [kTechDataId] = kTechId.UpgradeGorge,    [kTechDataCostKey] = kUpgradeGorgeResearchCost,    [kTechDataResearchTimeKey] = kUpgradeGorgeResearchTime,     [kTechDataDisplayName] = "UPGRADE_GORGE", [kTechDataTooltipInfo] = "UPGRADE_GORGE_TOOLTIP", [kTechDataMenuPriority] = -1},
        { [kTechDataId] = kTechId.UpgradeLerk,     [kTechDataCostKey] = kUpgradeLerkResearchCost,     [kTechDataResearchTimeKey] = kUpgradeLerkResearchTime,   [kTechDataDisplayName] = "UPGRADE_LERK", [kTechDataTooltipInfo] = "UPGRADE_LERK_TOOLTIP", [kTechDataMenuPriority] = -1},
        { [kTechDataId] = kTechId.UpgradeFade,     [kTechDataCostKey] = kUpgradeFadeResearchCost,     [kTechDataResearchTimeKey] = kUpgradeFadeResearchTime,    [kTechDataDisplayName] = "UPGRADE_FADE", [kTechDataTooltipInfo] = "UPGRADE_FADE_TOOLTIP", [kTechDataMenuPriority] = -1},
        { [kTechDataId] = kTechId.UpgradeOnos,     [kTechDataCostKey] = kUpgradeOnosResearchCost,     [kTechDataResearchTimeKey] = kUpgradeOnosResearchTime,    [kTechDataDisplayName] = "UPGRADE_ONOS", [kTechDataTooltipInfo] = "UPGRADE_ONOS_TOOLTIP", [kTechDataMenuPriority] = -1},

        // Alien abilities for damage types
        
        // tier 0
        { [kTechDataId] = kTechId.Bite,         [kTechDataMapName] = BiteLeap.kMapName,        [kTechDataDamageType] = kBiteDamageType,        [kTechDataDisplayName] = "BITE", [kTechDataTooltipInfo] = "BITE_TOOLTIP"},
        { [kTechDataId] = kTechId.Parasite,     [kTechDataMapName] = Parasite.kMapName,        [kTechDataDamageType] = kParasiteDamageType,    [kTechDataDisplayName] = "PARASITE", [kTechDataTooltipInfo] = "PARASITE_TOOLTIP"},
        { [kTechDataId] = kTechId.Spit,            [kTechDataMapName] = SpitSpray.kMapName,       [kTechDataDamageType] = kSpitDamageType,        [kTechDataDisplayName] = "SPIT", [kTechDataTooltipInfo] = "SPIT_TOOLTIP" },
        { [kTechDataId] = kTechId.BuildAbility,      [kTechDataMapName] = DropStructureAbility.kMapName,            [kTechDataDisplayName] = "BUILD_ABILITY", [kTechDataTooltipInfo] = "BUILD_ABILITY_TOOLTIP"},
        { [kTechDataId] = kTechId.Spray,             [kTechDataMapName] = SpitSpray.kMapName,       [kTechDataDamageType] = kHealsprayDamageType,   [kTechDataDisplayName] = "SPRAY", [kTechDataTooltipInfo] = "SPRAY_TOOLTIP"},
        { [kTechDataId] = kTechId.Swipe,          [kTechDataMapName] = SwipeBlink.kMapName,      [kTechDataDamageType] = kSwipeDamageType,       [kTechDataDisplayName] = "SWIPE_BLINK", [kTechDataTooltipInfo] = "SWIPE_TOOLTIP"},
        { [kTechDataId] = kTechId.Gore,           [kTechDataMapName] = Gore.kMapName,            [kTechDataDamageType] = kGoreDamageType,        [kTechDataDisplayName] = "GORE", [kTechDataTooltipInfo] = "GORE_TOOLTIP"},
        { [kTechDataId] = kTechId.LerkBite,           [kTechDataMapName] = LerkBite.kMapName,        [kTechDataDamageType] = kLerkBiteDamageType,    [kTechDataDisplayName] = "LERK_BITE", [kTechDataTooltipInfo] = "LERK_BITE_TOOLTIP"},
        { [kTechDataId] = kTechId.Spikes,        [kTechDataDisplayName] = "SPIKES", [kTechDataDamageType] = kSpikeDamageType, [kTechDataTooltipInfo] = "SPIKES_TOOLTIP"},
        { [kTechDataId] = kTechId.Blink,         [kTechDataDisplayName] = "BLINK",  [kTechDataTooltipInfo] = "BLINK_TOOLTIP"},  
        { [kTechDataId] = kTechId.BabblerAbility,    [kTechDataMapName] = BabblerAbility.kMapName,   [kTechDataDisplayName] = "BABBLER_ABILITY", [kTechDataTooltipInfo] = "BABBLER_ABILITY_TOOLTIP", },

        // tier 1
        { [kTechDataId] = kTechId.Umbra,          [kTechDataCategory] = kTechId.Lerk, [kTechDataMapName] = LerkUmbra.kMapName,       [kTechDataDisplayName] = "UMBRA", [kTechDataCostKey] = kUmbraResearchCost, [kTechDataResearchTimeKey] = kUmbraResearchTime, [kTechDataTooltipInfo] = "UMBRA_TOOLTIP"},
        { [kTechDataId] = kTechId.BileBomb,       [kTechDataCategory] = kTechId.Gorge,  [kTechDataMapName] = BileBomb.kMapName,        [kTechDataDamageType] = kBileBombDamageType,  [kTechDataDisplayName] = "BILEBOMB", [kTechDataCostKey] = kBileBombResearchCost, [kTechDataResearchTimeKey] = kBileBombResearchTime, [kTechDataTooltipInfo] = "BILEBOMB_TOOLTIP" },
        //{ [kTechDataId] = kTechId.ShadowStep,     [kTechDataCategory] = kTechId.Fade,   [kTechDataCostKey] = kShadowStepResearchCost, [kTechDataResearchTimeKey] = kShadowStepResearchTime,      [kTechDataDisplayName] = "SHADOWSTEP",  [kTechDataTooltipInfo] = "SHADOWSTEP_TOOLTIP"},  
        { [kTechDataId] = kTechId.MetabolizeEnergy,     [kTechDataCategory] = kTechId.Fade,   [kTechDataCostKey] = kMetabolizeEnergyResearchCost, [kTechDataMapName] = Metabolize.kMapName, [kTechDataResearchTimeKey] = kMetabolizeEnergyResearchTime,      [kTechDataDisplayName] = "METABOLIZE",  [kTechDataTooltipInfo] = "METABOLIZE_TOOLTIP"},  
        { [kTechDataId] = kTechId.MetabolizeHealth,     [kTechDataCategory] = kTechId.Fade,   [kTechDataCostKey] = kMetabolizeHealthResearchCost, [kTechDataResearchTimeKey] = kMetabolizeHealthResearchTime,      [kTechDataDisplayName] = "METABOLIZE_ADV",  [kTechDataTooltipInfo] = "METABOLIZE_ADV_TOOLTIP"}, 
        { [kTechDataId] = kTechId.Charge,         [kTechDataCategory] = kTechId.Onos,   [kTechDataCostKey] = kChargeResearchCost, [kTechDataResearchTimeKey] = kChargeResearchTime,      [kTechDataDisplayName] = "CHARGE",  [kTechDataTooltipInfo] = "CHARGE_TOOLTIP"},  
 
        // tier 2
        { [kTechDataId] = kTechId.Leap,           [kTechDataCategory] = kTechId.Skulk, [kTechDataDisplayName] = "LEAP", [kTechDataCostKey] = kLeapResearchCost, [kTechDataResearchTimeKey] = kLeapResearchTime, [kTechDataTooltipInfo] = "LEAP_TOOLTIP" },     
        { [kTechDataId] = kTechId.Stab,       
         [kTechDataCategory] = kTechId.Fade,  
         [kTechDataMapName] = StabBlink.kMapName, 
        [kTechDataCostKey] = kStabResearchCost, 
       [kTechDataResearchTimeKey] = kStabResearchTime,  
         [kTechDataDamageType] = kStabDamageType,    
          [kTechDataDisplayName] = "STAB_BLINK",
       [kTechDataTooltipInfo] = "STAB_TOOLTIP"},
       
        { [kTechDataId] = kTechId.BoneShield,     [kTechDataCategory] = kTechId.Onos,  [kTechDataMapName] = BoneShield.kMapName,      [kTechDataDisplayName] = "BONESHIELD", [kTechDataCostKey] = kBoneShieldResearchCost, [kTechDataResearchTimeKey] = kBoneShieldResearchTime, [kTechDataTooltipInfo] = "BONESHIELD_TOOLTIP" }, 
        

        { [kTechDataId] = kTechId.BoneShield,     [kTechDataCategory] = kTechId.Onos,  [kTechDataMapName] = BoneShield.kMapName,      [kTechDataDisplayName] = "BONESHIELD", [kTechDataCostKey] = kBoneShieldResearchCost, [kTechDataResearchTimeKey] = kBoneShieldResearchTime, [kTechDataTooltipInfo] = "BONESHIELD_TOOLTIP" }, 
        { [kTechDataId] = kTechId.Spores,         [kTechDataCategory] = kTechId.Lerk, [kTechDataDisplayName] = "SPORES",  [kTechDataMapName] = Spores.kMapName, [kTechDataCostKey] = kSporesResearchCost, [kTechDataResearchTimeKey] = kSporesResearchTime, [kTechDataTooltipInfo] = "SPORES_TOOLTIP"},
    
       { [kTechDataId] = kTechId.PrimalScream,  
         [kTechDataCategory] = kTechId.Lerk,
       [kTechDataDisplayName] = "Primal Scream",
        [kTechDataMapName] =  Primal.kMapName,
         [kTechDataCostKey] = kPrimalScreamCostKey, 
        [kTechDataResearchTimeKey] = kPrimalScreamTimeKey, 
 [kTechDataTooltipInfo] = "+dmg +energy +rof to all teammates in range"},
 
        // tier 3
       

 
       
                                    { [kTechDataId] = kTechId.WhipFlameThrowerChanceDrop,
       [kTechDataDisplayName] = "Slap FlameThrower", 
        [kTechDataCostKey] = kWhipFlameThrowerCost, 
         [kTechDataResearchTimeKey] = kWhipFlameThrowerTime, 
       [kTechDataTooltipInfo] = "If the whip slaps somebody with a flamethrowers, it has a 30% chance to steal the flamethrower from the player (Not for the exo)" }, 
       
       
       
        { [kTechDataId] = kTechId.Stomp,          [kTechDataCategory] = kTechId.Onos,  [kTechDataDisplayName] = "STOMP", [kTechDataCostKey] = kStompResearchCost, [kTechDataResearchTimeKey] = kStompResearchTime, [kTechDataTooltipInfo] = "STOMP_TOOLTIP" }, 
        { [kTechDataId] = kTechId.Shockwave,      [kTechDataDisplayName] = "SHOCKWAVE", [kTechDataDamageType] = kStompDamageType, [kTechDataMapName] = Shockwave.kMapName, [kTechDataTooltipInfo] = "SHOCKWAVE_TOOLTIP" }, 
        { [kTechDataId] = kTechId.WebTech,        [kTechDataDisplayName] = "WEB", [kTechDataCostKey] = kWebResearchCost, [kTechDataResearchTimeKey] = kWebResearchTime, [kTechDataTooltipInfo] = "WEB_TOOLTIP" },
        { [kTechDataId] = kTechId.SpiderGorge, 
         [kTechDataDisplayName] = "SpiderGorge", 
      [kTechDataCostKey] = kSpiderGorgeResearchCost, 
     [kTechDataResearchTimeKey] = kSpiderGorgeResearchTime, 
     [kTechDataTooltipInfo] = "Spider gorge does whatever a spider gorge wants" },
     

                       { [kTechDataId] = kTechId.PresBonus, 
         [kTechDataDisplayName] = "25% increased pres gain", 
      [kTechDataCostKey] = kPresBonusResearchCost, 
     [kTechDataResearchTimeKey] = kPresBonusResearchTime, 
     [kTechDataTooltipInfo] = "Increases the player res gain by 25%. An overall must have! (Research button is on a Harvester)" },
     
    
         { [kTechDataId] = kTechId.Xenocide,
         [kTechDataCategory] = kTechId.Skulk,
        [kTechDataMapName] = XenocideLeap.kMapName,  
        [kTechDataDamageType] = kXenocideDamageType,
           [kTechDataDisplayName] = "XENOCIDE",
          [kTechDataCostKey] = kXenocideResearchCost,
        [kTechDataResearchTimeKey] = kXenocideResearchTime, 
           [kTechDataTooltipInfo] = "Siege modification: Base 200 dmg and +5% dmg against marines/jetpackmarines and +25% dmg against exo/structure"},
   
        

        //{ [kTechDataId] = kTechId.Vortex ,        [kTechDataCategory] = kTechId.Fade,   [kTechDataMapName] = Vortex.kMapName,   [kTechDataDisplayName] = "VORTEX", [kTechDataCostKey] = kVortexResearchCost, [kTechDataResearchTimeKey] = kVortexResearchTime, [kTechDataTooltipInfo] = "VORTEX_TOOLTIP"},

 { [kTechDataId] = kTechId.AcidRocket,        
  [kTechDataCategory] = kTechId.Fade,   
     [kTechDataMapName] = AcidRocket.kMapName,  
[kTechDataCostKey] = kStabResearchCost,
 [kTechDataResearchTimeKey] = kStabResearchTime, 
    [kTechDataDamageType] = kStabDamageType,  
     [kTechDataDisplayName] = "AcidRocket",
 [kTechDataTooltipInfo] = "Ranged Projectile dealing damage only to armor and structures"},
 
        // Alien structures (spawn hive at 110 units off ground = 2.794 meters)
        { [kTechDataId] = kTechId.Hive, 
       [kTechDataIgnorePathingMesh] = true,
        [kTechDataBioMass] = kHiveBiomass, 
         [kTechDataBuildRequiresMethod] = GetIsSuddenDeathEnabled, 
         [kTechDataBuildMethodFailedMessage] = "Cannot drop Hive during suddendeath", 
         [kTechDataSpawnBlock] = true, [kTechDataMaxExtents] = Vector(2, 1, 2), [kTechDataHint] = "HIVE_HINT", [kTechDataAllowStacking] = true, [kTechDataGhostModelClass] = "AlienGhostModel",  [kTechDataMapName] = Hive.kMapName,   [kTechDataDisplayName] = "HIVE", [kTechDataCostKey] = kHiveCost,                     [kTechDataBuildTime] = kHiveBuildTime, [kTechDataModel] = Hive.kModelName,  [kTechDataHotkey] = Move.V,                [kTechDataMaxHealth] = kHiveHealth,  [kTechDataMaxArmor] = kHiveArmor,              [kStructureAttachClass] = "TechPoint",         [kTechDataSpawnHeightOffset] = 2.494,    [kTechDataInitialEnergy] = kHiveInitialEnergy,      [kTechDataMaxEnergy] = kHiveMaxEnergy, [kTechDataPointValue] = kHivePointValue, [kTechDataTooltipInfo] = "HIVE_TOOLTIP", [kTechDataObstacleRadius] = 2}, 
        { [kTechDataId] = kTechId.HiveHeal, [kTechDataDisplayName] = "HEAL", [kTechDataTooltipInfo] = "HIVE_HEAL_TOOLTIP"},
    
        { [kTechDataId] = kTechId.ResearchBioMassOne, [kTechDataBioMass] = kHiveBiomass, [kTechDataCostKey] = kResearchBioMassOneCost, [kTechDataResearchTimeKey] = kBioMassOneTime, [kTechDataDisplayName] = "BIOMASS", [kTechDataTooltipInfo] = "ADD_BIOMASS_TOOLTIP"},
        { [kTechDataId] = kTechId.ResearchBioMassTwo, [kTechDataBioMass] = kHiveBiomass, [kTechDataCostKey] = kResearchBioMassTwoCost, [kTechDataResearchTimeKey] = kBioMassTwoTime, [kTechDataDisplayName] = "BIOMASS", [kTechDataTooltipInfo] = "ADD_BIOMASS_TOOLTIP"},
        { [kTechDataId] = kTechId.ResearchBioMassThree, [kTechDataBioMass] = kHiveBiomass, [kTechDataCostKey] = kResearchBioMassThreeCost, [kTechDataResearchTimeKey] = kBioMassThreeTime, [kTechDataDisplayName] = "BIOMASS", [kTechDataTooltipInfo] = "ADD_BIOMASS_TOOLTIP"},
        { [kTechDataId] = kTechId.ResearchBioMassFour, [kTechDataBioMass] = kHiveBiomass, [kTechDataCostKey] = kResearchBioMassFourCost, [kTechDataResearchTimeKey] = kBioMassFourTime, [kTechDataDisplayName] = "BIOMASS", [kTechDataTooltipInfo] = "ADD_BIOMASS_TOOLTIP"},

        { [kTechDataId] = kTechId.BioMassOne, [kTechDataDisplayName] = "BIOMASS_ONE" },
        { [kTechDataId] = kTechId.BioMassTwo, [kTechDataDisplayName] = "BIOMASS_TWO" },
        { [kTechDataId] = kTechId.BioMassThree, [kTechDataDisplayName] = "BIOMASS_THREE" },
        { [kTechDataId] = kTechId.BioMassFour, [kTechDataDisplayName] = "BIOMASS_FOUR" },
        { [kTechDataId] = kTechId.BioMassFive, [kTechDataDisplayName] = "BIOMASS_FIVE" },
        { [kTechDataId] = kTechId.BioMassSix, [kTechDataDisplayName] = "BIOMASS_SIX" },
        { [kTechDataId] = kTechId.BioMassSeven, [kTechDataDisplayName] = "BIOMASS_SEVEN" },
        { [kTechDataId] = kTechId.BioMassEight, [kTechDataDisplayName] = "BIOMASS_EIGHT" },
        { [kTechDataId] = kTechId.BioMassNine, [kTechDataDisplayName] = "BIOMASS_NINE" },
        { [kTechDataId] = kTechId.BioMassTen, [kTechDataDisplayName] = "Biomass Ten" },
        { [kTechDataId] = kTechId.BioMassEleven, [kTechDataDisplayName] = "Biomass Ten" },
        { [kTechDataId] = kTechId.BioMassTwelve, [kTechDataDisplayName] = "Biomass Twelve" },
 
        { [kTechDataId] = kTechId.UpgradeToCragHive,    [kTechDataMapName] = CragHive.kMapName,   [kTechDataDisplayName] = "UPGRADE_CRAG_HIVE",  [kTechDataCostKey] = kUpgradeHiveCost, [kTechDataResearchTimeKey] = kUpgradeHiveResearchTime, [kTechDataModel] = Hive.kModelName,  [kTechDataTooltipInfo] = "UPGRADE_CRAG_HIVE_TOOLTIP", },
        { [kTechDataId] = kTechId.UpgradeToShiftHive,   [kTechDataMapName] = ShiftHive.kMapName,   [kTechDataDisplayName] = "UPGRADE_SHIFT_HIVE",  [kTechDataCostKey] = kUpgradeHiveCost, [kTechDataResearchTimeKey] = kUpgradeHiveResearchTime, [kTechDataModel] = Hive.kModelName,  [kTechDataTooltipInfo] = "UPGRADE_SHIFT_HIVE_TOOLTIP", },
        { [kTechDataId] = kTechId.UpgradeToShadeHive,   [kTechDataMapName] = ShadeHive.kMapName,   [kTechDataDisplayName] = "UPGRADE_SHADE_HIVE",  [kTechDataCostKey] = kUpgradeHiveCost, [kTechDataResearchTimeKey] = kUpgradeHiveResearchTime, [kTechDataModel] = Hive.kModelName,  [kTechDataTooltipInfo] = "UPGRADE_SHADE_HIVE_TOOLTIP", },

        { [kTechDataId] = kTechId.CragHive,  [kTechDataHint] = "CRAG_HIVE_HINT",          [kTechDataMapName] = CragHive.kMapName,                   [kTechDataDisplayName] = "CRAG_HIVE", [kTechDataCostKey] = kUpgradeHiveCost, [kTechDataResearchTimeKey] = kUpgradeHiveResearchTime, [kTechDataBuildTime] = kUpgradeHiveResearchTime, [kTechDataModel] = Hive.kModelName,  [kTechDataHotkey] = Move.V,  [kTechDataMaxHealth] = kHiveHealth,  [kTechDataMaxArmor] = kHiveArmor,     [kStructureAttachClass] = "TechPoint",         [kTechDataSpawnHeightOffset] = 2.494,    [kTechDataInitialEnergy] = kHiveInitialEnergy,      [kTechDataMaxEnergy] = kHiveMaxEnergy, [kTechDataPointValue] = kHivePointValue, [kTechDataTooltipInfo] = "CRAG_HIVE_TOOLTIP"},
        { [kTechDataId] = kTechId.ShadeHive, [kTechDataHint] = "SHADE_HIVE_HINT",          [kTechDataMapName] = ShadeHive.kMapName,                   [kTechDataDisplayName] = "SHADE_HIVE", [kTechDataCostKey] = kUpgradeHiveCost, [kTechDataResearchTimeKey] = kUpgradeHiveResearchTime, [kTechDataBuildTime] = kUpgradeHiveResearchTime, [kTechDataModel] = Hive.kModelName,  [kTechDataHotkey] = Move.V,  [kTechDataMaxHealth] = kHiveHealth,  [kTechDataMaxArmor] = kHiveArmor,     [kStructureAttachClass] = "TechPoint",         [kTechDataSpawnHeightOffset] = 2.494,    [kTechDataInitialEnergy] = kHiveInitialEnergy,      [kTechDataMaxEnergy] = kHiveMaxEnergy, [kTechDataPointValue] = kHivePointValue, [kTechDataTooltipInfo] = "SHADE_HIVE_TOOLTIP"},
        { [kTechDataId] = kTechId.ShiftHive, [kTechDataHint] = "SHIFT_HIVE_HINT",          [kTechDataMapName] = ShiftHive.kMapName,                   [kTechDataDisplayName] = "SHIFT_HIVE", [kTechDataCostKey] = kUpgradeHiveCost, [kTechDataResearchTimeKey] = kUpgradeHiveResearchTime, [kTechDataBuildTime] = kUpgradeHiveResearchTime, [kTechDataModel] = Hive.kModelName,  [kTechDataHotkey] = Move.V,  [kTechDataMaxHealth] = kHiveHealth,  [kTechDataMaxArmor] = kHiveArmor,     [kStructureAttachClass] = "TechPoint",         [kTechDataSpawnHeightOffset] = 2.494,    [kTechDataInitialEnergy] = kHiveInitialEnergy,      [kTechDataMaxEnergy] = kHiveMaxEnergy, [kTechDataPointValue] = kHivePointValue, [kTechDataTooltipInfo] = "SHIFT_HIVE_TOOLTIP"},
        
        // Drifter and tech
        { [kTechDataId] = kTechId.DrifterCamouflage,    [kTechDataDisplayName] = "CAMOUFLAGE",  [kTechDataTooltipInfo] = "DRIFTER_CAMOUFLAGE_TOOLTIP"},
        { [kTechDataId] = kTechId.DrifterCelerity,     [kTechDataDisplayName] = "CELERITY",  [kTechDataTooltipInfo] = "DRIFTER_CELERITY_TOOLTIP"},
        { [kTechDataId] = kTechId.DrifterRegeneration,     [kTechDataDisplayName] = "REGENERATION",  [kTechDataTooltipInfo] = "DRIFTER_REGENERATION_TOOLTIP"},
        { [kTechDataId] = kTechId.Drifter, [kTechDataBuildTime] = kDrifterHatchTime, [kTechDataSupply] = kDrifterSupply,  [kTechDataHint] = "DRIFTER_HINT", [kTechDataMapName] = Drifter.kMapName, [kTechDataDisplayName] = "DRIFTER",   [kTechDataCostKey] = kDrifterCost, [kTechDataCooldown] = kDrifterBuildTime, [kTechDataMaxHealth] = kDrifterHealth, [kTechDataMaxArmor] = kDrifterArmor, [kTechDataModel] = Drifter.kModelName, [kTechDataDamageType] = kDrifterAttackDamageType, [kTechDataPointValue] = kDrifterPointValue, [kTechDataTooltipInfo] = "DRIFTER_TOOLTIP", [kTechDataInitialEnergy] = kDrifterInitialEnergy,      [kTechDataMaxEnergy] = kDrifterMaxEnergy,},   
        { [kTechDataId] = kTechId.DrifterEgg, [kTechDataRequiresInfestation] = true, [kTechDataSupply] = kDrifterSupply, [kTechDataBuildTime] = kDrifterHatchTime, [kTechDataSupply] = kDrifterSupply,  [kTechDataHint] = "DRIFTER_HINT", [kTechDataMapName] = DrifterEgg.kMapName, [kTechDataDisplayName] = "DRIFTER",   [kTechDataCostKey] = kDrifterCost, [kTechDataCooldown] = kDrifterCooldown, [kTechDataMaxHealth] = kDrifterHealth, [kTechDataMaxArmor] = kDrifterArmor, [kTechDataModel] = DrifterEgg.kModelName, [kTechDataPointValue] = kDrifterPointValue, [kTechDataTooltipInfo] = "DRIFTER_TOOLTIP", [kTechDataInitialEnergy] = kDrifterInitialEnergy,      [kTechDataMaxEnergy] = kDrifterMaxEnergy,},   
        { [kTechDataId] = kTechId.SelectDrifter, [kTechIDShowEnables] = false, [kTechDataDisplayName] = "SELECT_DRIFTER", [kTechDataTooltipInfo] = "SELECT_NEAREST_DRIFTER" },   
        { [kTechDataId] = kTechId.SelectShift, [kTechIDShowEnables] = false, [kTechDataDisplayName] = "SELECT_SHIFT", [kTechDataTooltipInfo] = "SELECT_NEAREST_SHIFT" },   
  
        // Alien buildables
        { [kTechDataId] = kTechId.Egg,    [kTechDataHint] = "EGG_HINT",    [kTechDataMapName] = Egg.kMapName,                         [kTechDataDisplayName] = "EGG",         [kTechDataTooltipInfo] = "EGG_DROP_TOOLTIP", [kTechDataMaxHealth] = Egg.kHealth, [kTechDataMaxArmor] = Egg.kArmor, [kTechDataModel] = Egg.kModelName, [kTechDataPointValue] = kEggPointValue, [kTechDataBuildTime] = 1, [kTechDataMaxExtents] = Vector(1.75/2, .664/2, 1.275/2), [kTechDataRequiresInfestation] = true }, 
        { [kTechDataId] = kTechId.GorgeEgg,   [kTechDataHint] = "EGG_HINT", [kTechDataMapName] = GorgeEgg.kMapName,                         [kTechDataDisplayName] = "GORGE_EGG",         [kTechDataTooltipInfo] = "GORGE_EGG_DROP_TOOLTIP", [kTechDataMaxHealth] = Egg.kHealth, [kTechDataMaxArmor] = Egg.kArmor, [kTechDataModel] = Egg.kModelName, [kTechDataPointValue] = kEggPointValue, [kTechDataResearchTimeKey] = kEggGestateTime, [kTechDataCostKey] = kGorgeEggCost, [kTechDataMaxExtents] = Vector(1.75/2, .664/2, 1.275/2), [kTechDataRequiresInfestation] = true }, 
        { [kTechDataId] = kTechId.LerkEgg,    [kTechDataHint] = "EGG_HINT", [kTechDataMapName] = LerkEgg.kMapName,                         [kTechDataDisplayName] = "LERK_EGG",         [kTechDataTooltipInfo] = "LERK_EGG_DROP_TOOLTIP", [kTechDataMaxHealth] = Egg.kHealth, [kTechDataMaxArmor] = Egg.kArmor, [kTechDataModel] = Egg.kModelName, [kTechDataPointValue] = kEggPointValue, [kTechDataResearchTimeKey] = kEggGestateTime, [kTechDataCostKey] = kLerkEggCost, [kTechDataMaxExtents] = Vector(1.75/2, .664/2, 1.275/2), [kTechDataRequiresInfestation] = true }, 
        { [kTechDataId] = kTechId.FadeEgg,    [kTechDataHint] = "EGG_HINT", [kTechDataMapName] = FadeEgg.kMapName,                         [kTechDataDisplayName] = "FADE_EGG",         [kTechDataTooltipInfo] = "FADE_EGG_DROP_TOOLTIP", [kTechDataMaxHealth] = Egg.kHealth, [kTechDataMaxArmor] = Egg.kArmor, [kTechDataModel] = Egg.kModelName, [kTechDataPointValue] = kEggPointValue, [kTechDataResearchTimeKey] = kEggGestateTime, [kTechDataCostKey] = kFadeEggCost, [kTechDataMaxExtents] = Vector(1.75/2, .664/2, 1.275/2), [kTechDataRequiresInfestation] = true }, 
        { [kTechDataId] = kTechId.OnosEgg,    [kTechDataHint] = "EGG_HINT", [kTechDataMapName] = OnosEgg.kMapName,                         [kTechDataDisplayName] = "ONOS_EGG",         [kTechDataTooltipInfo] = "ONOS_EGG_DROP_TOOLTIP", [kTechDataMaxHealth] = Egg.kHealth, [kTechDataMaxArmor] = Egg.kArmor, [kTechDataModel] = Egg.kModelName, [kTechDataPointValue] = kEggPointValue, [kTechDataResearchTimeKey] = kEggGestateTime, [kTechDataCostKey] = kOnosEggCost, [kTechDataMaxExtents] = Vector(1.75/2, .664/2, 1.275/2), [kTechDataRequiresInfestation] = true }, 

        { [kTechDataId] = kTechId.Harvester, [kTechDataIgnorePathingMesh] = true, [kTechDataBioMass] = kHarvesterBiomass, [kTechDataSpawnBlock] = true, [kTechDataMaxExtents] = Vector(1, 1, 1), [kTechDataHint] = "HARVESTER_HINT", [kTechDataCollideWithWorldOnly] = true, [kTechDataAllowStacking] = true, [kTechDataGhostModelClass] = "AlienGhostModel",    [kTechDataMapName] = Harvester.kMapName,                    [kTechDataDisplayName] = "HARVESTER",  [kTechDataRequiresInfestation] = true,   [kTechDataCostKey] = kHarvesterCost,            [kTechDataBuildTime] = kHarvesterBuildTime, [kTechDataHotkey] = Move.H, [kTechDataMaxHealth] = kHarvesterHealth, [kTechDataMaxArmor] = kHarvesterArmor, [kTechDataModel] = Harvester.kModelName,           [kStructureAttachClass] = "ResourcePoint", [kTechDataPointValue] = kHarvesterPointValue, [kTechDataTooltipInfo] = "HARVESTER_TOOLTIP"},

        // Infestation
        { [kTechDataId] = kTechId.Infestation,           [kTechDataDisplayName] = "INFESTATION", [kTechDataTooltipInfo] = "INFESTATION_TOOLTIP", },
        { [kTechDataId] = kTechId.Slap,           [kTechDataDisplayName] = "WHIP_SLAP", [kTechDataTooltipInfo] = "WHIP_SLAP_TOOLTIP", },

        // Upgrade structures and research
        { [kTechDataId] = kTechId.Crag, [kTechDataBioMass] = kCragBiomass, [kTechDataSupply] = kCragSupply, [kTechDataHint] = "CRAG_HINT", [kTechDataGhostModelClass] = "AlienGhostModel",    [kTechDataMapName] = Crag.kMapName,                         [kTechDataDisplayName] = "CRAG",  [kTechDataCostKey] = kCragCost,     [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.C,       [kTechDataBuildTime] = kCragBuildTime, [kTechDataModel] = Crag.kModelName,           [kTechDataMaxHealth] = kCragHealth, [kTechDataMaxArmor] = kCragArmor,   [kTechDataInitialEnergy] = kCragInitialEnergy,      [kTechDataMaxEnergy] = kCragMaxEnergy, [kTechDataPointValue] = kCragPointValue, [kVisualRange] = Crag.kHealRadius, [kTechDataTooltipInfo] = "CRAG_TOOLTIP", [kTechDataGrows] = true},

        { [kTechDataId] = kTechId.Whip, [kTechDataBioMass] = kWhipBiomass, [kTechDataSupply] = kWhipSupply, [kTechDataHint] = "WHIP_HINT", [kTechDataGhostModelClass] = "AlienGhostModel",    [kTechDataMapName] = Whip.kMapName,                         [kTechDataDisplayName] = "WHIP",  [kTechDataCostKey] = kWhipCost,    [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.W,        [kTechDataBuildTime] = kWhipBuildTime, [kTechDataModel] = Whip.kModelName,           [kTechDataMaxHealth] = kWhipHealth, [kTechDataMaxArmor] = kWhipArmor,   [kTechDataDamageType] = kDamageType.Structural, [kTechDataInitialEnergy] = kWhipInitialEnergy,      [kTechDataMaxEnergy] = kWhipMaxEnergy, [kVisualRange] = Whip.kRange, [kTechDataPointValue] = kWhipPointValue, [kTechDataTooltipInfo] = "WHIP_TOOLTIP", [kTechDataGrows] = true},
        { [kTechDataId] = kTechId.EvolveBombard, [kTechDataDisplayName] = "EVOLVE_BOMBARD",  [kTechDataCostKey] = kEvolveBombardCost, [kTechDataResearchTimeKey] = kEvolveBombardResearchTime, [kTechDataTooltipInfo] = "EVOLVE_BOMBARD_TOOLTIP" },

        { [kTechDataId] = kTechId.Shift, [kTechDataBioMass] = kShiftBiomass, [kTechDataSupply] = kShiftSupply, [kTechDataHint] = "SHIFT_HINT", [kTechDataGhostModelClass] = "ShiftGhostModel",    [kTechDataMapName] = Shift.kMapName,                        [kTechDataDisplayName] = "SHIFT",  [kTechDataRequiresInfestation] = true, [kTechDataCostKey] = kShiftCost,    [kTechDataHotkey] = Move.S,        [kTechDataBuildTime] = kShiftBuildTime, [kTechDataModel] = Shift.kModelName,           [kTechDataMaxHealth] = kShiftHealth,  [kTechDataMaxArmor] = kShiftArmor,  [kTechDataInitialEnergy] = kShiftInitialEnergy,      [kTechDataMaxEnergy] = kShiftMaxEnergy, [kTechDataPointValue] = kShiftPointValue, [kVisualRange] = kEchoRange, [kTechDataTooltipInfo] = "SHIFT_TOOLTIP", [kTechDataGrows] = true },

        { [kTechDataId] = kTechId.Veil, [kTechDataBioMass] = kVeilBiomass, [kTechDataHint] = "VEIL_HINT", [kTechDataGhostModelClass] = "AlienGhostModel",     [kTechDataMapName] = Veil.kMapName,                         [kTechDataDisplayName] = "VEIL",  [kTechDataCostKey] = kVeilCost,     [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.C,       [kTechDataBuildTime] = kVeilBuildTime, [kTechDataModel] = Veil.kModelName,           [kTechDataMaxHealth] = kVeilHealth, [kTechDataMaxArmor] = kVeilArmor,  [kTechDataPointValue] = kVeilPointValue, [kTechDataTooltipInfo] = "VEIL_TOOLTIP", [kTechDataGrows] = true, [kTechDataObstacleRadius] = 0.5 },
        { [kTechDataId] = kTechId.TwoVeils, [kTechDataDisplayName] = "TWO_VEILS", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] = "TWO_VEILS_TOOLTIP"},               
        { [kTechDataId] = kTechId.ThreeVeils, [kTechDataDisplayName] = "THREE_VEILS", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] = "THREE_VEILS_TOOLTIP"},  

        { [kTechDataId] = kTechId.Spur, [kTechDataBioMass] = kSpurBiomass,  [kTechDataHint] = "SPUR_HINT", [kTechDataGhostModelClass] = "AlienGhostModel",     [kTechDataMapName] = Spur.kMapName,                         [kTechDataDisplayName] = "SPUR",  [kTechDataCostKey] = kSpurCost,     [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.C,       [kTechDataBuildTime] = kSpurBuildTime, [kTechDataModel] = Spur.kModelName,           [kTechDataMaxHealth] = kSpurHealth, [kTechDataMaxArmor] = kSpurArmor,  [kTechDataPointValue] = kSpurPointValue, [kTechDataTooltipInfo] = "SPUR_TOOLTIP", [kTechDataGrows] = true, [kTechDataObstacleRadius] = 0.75 },
        { [kTechDataId] = kTechId.TwoSpurs, [kTechDataDisplayName] = "TWO_SPURS", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] = "TWO_SPURS_TOOLTIP"},               
        { [kTechDataId] = kTechId.ThreeSpurs, [kTechDataDisplayName] = "THREE_SPURS", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] = "THREE_SPURS_TOOLTIP"},  

        { [kTechDataId] = kTechId.Shell, 
        [kTechDataCooldown] = 30, [kTechDataBioMass] = kShellBiomass, 
         [kTechDataHint] = "Randomly Generates 3-6 Eggs at placed location every 5 seconds for 30 seconds. The eggs will last for 2 minutes.", 
        [kTechDataGhostModelClass] = "AlienGhostModel",   
            [kTechDataMapName] = Shell.kMapName,        
                 [kTechDataDisplayName] = "Egg Beacon",  [kTechDataCostKey] = 10,   
            [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.C,   
         [kTechDataBuildTime] = kShellBuildTime, [kTechDataModel] = Shell.kModelName,   
              [kTechDataMaxHealth] = kShellHealth, [kTechDataMaxArmor] = kShellArmor,
      [kTechDataPointValue] = kShellPointValue, [kTechDataTooltipInfo] = "Randomly Generates 3-6 Eggs at placed location every 5 seconds for 30 seconds.",
          [kTechDataGrows] = true, [kTechDataObstacleRadius] = 0.75 },
        { [kTechDataId] = kTechId.TwoShells, [kTechDataDisplayName] = "TWO_SHELLS", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] = "TWO_SHELLS_TOOLTIP"},               
        { [kTechDataId] = kTechId.ThreeShells, [kTechDataDisplayName] = "THREE_SHELLS", [kTechIDShowEnables] = false, [kTechDataTooltipInfo] = "THREE_SHELLS_TOOLTIP"},
        
        { [kTechDataId] = kTechId.EvolutionChamber, [kTechDataHint] = "EVOCHAMBER", [kTechDataGhostModelClass] = "AlienGhostModel", [kTechDataMapName] = EvolutionChamber.kMapName, [kTechDataDisplayName] = "EVOCHAMBER", [kTechDataCostKey] = 0, [kTechDataBuildTime] = 0, [kTechDataModel] = EvolutionChamber.kModelName, [kTechDataMaxHealth] = 0, [kTechDataMaxArmor] = 0, [kTechDataTooltipInfo] = "EVOCHAMBER" },
        { [kTechDataId] = kTechId.Return, [kTechDataDisplayName] = "RETURN", [kTechDataTooltipInfo] = "RETURN_DESCRIPTION" },


        { [kTechDataId] = kTechId.TeleportHydra, [kTechIDShowEnables] = false,  [kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_HYDRA",  [kTechDataCostKey] = kEchoHydraCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = Hydra.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.TeleportWhip, [kTechIDShowEnables] = false, [kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_WHIP",  [kTechDataCostKey] = kEchoWhipCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = Whip.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.TeleportTunnel,  [kTechIDShowEnables] = false,[kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_TUNNEL",  [kTechDataCostKey] = kEchoTunnelCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = TunnelEntrance.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.TeleportCrag, [kTechIDShowEnables] = false,[kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_CRAG",  [kTechDataCostKey] = kEchoCragCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = Crag.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.TeleportShade,  [kTechIDShowEnables] = false,[kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_SHADE",  [kTechDataCostKey] = kEchoShadeCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = Shade.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.TeleportShift, [kTechIDShowEnables] = false,[kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_SHIFT",  [kTechDataCostKey] = kEchoShiftCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = Shift.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.TeleportVeil, [kTechIDShowEnables] = false, [kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_VEIL",  [kTechDataCostKey] = kEchoVeilCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = Veil.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.TeleportSpur, [kTechIDShowEnables] = false,[kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_SPUR",  [kTechDataCostKey] = kEchoSpurCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = Spur.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.TeleportShell,  [kTechIDShowEnables] = false, [kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_SHELL",  [kTechDataCostKey] = kEchoShellCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = Shell.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.TeleportHive, [kTechIDShowEnables] = false, [kTechDataImplemented] = false, [kTechDataGhostModelClass] = "TeleportAlienGhostModel",  [kTechDataDisplayName] = "ECHO_HIVE",  [kTechDataCostKey] = kEchoHiveCost,   [kTechDataRequiresInfestation] = false, [kTechDataModel] = Hive.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP", [kTechDataSpawnHeightOffset] = 2.494, [kStructureAttachClass] = "TechPoint"},
        { [kTechDataId] = kTechId.TeleportEgg,  [kTechIDShowEnables] = false,[kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_EGG",  [kTechDataCostKey] = kEchoEggCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = Egg.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.TeleportHarvester, [kTechIDShowEnables] = false,[kStructureAttachClass] = "ResourcePoint", [kTechDataMaxExtents] = Vector(1, 1, 1), [kTechDataCollideWithWorldOnly] = true, [kTechDataAllowStacking] = true, [kTechDataGhostModelClass] = "TeleportAlienGhostModel",   [kTechDataDisplayName] = "ECHO_HARVESTER",  [kTechDataCostKey] = kEchoHarvesterCost,   [kTechDataRequiresInfestation] = true, [kTechDataModel] = Harvester.kModelName, [kTechDataTooltipInfo] = "ECHO_TOOLTIP"},


        { [kTechDataId] = kTechId.Shade,
         [kTechDataBioMass] = kShadeBiomass,
        [kTechDataSupply] = kShadeSupply,
       [kTechDataHint] = "SHADE_HINT", 
   [kTechDataGhostModelClass] = "AlienGhostModel",    [kTechDataMapName] = Shade.kMapName,                        [kTechDataDisplayName] = "SHADE",  [kTechDataCostKey] = kShadeCost,      [kTechDataRequiresInfestation] = true,     [kTechDataBuildTime] = kShadeBuildTime, [kTechDataHotkey] = Move.D, [kTechDataModel] = Shade.kModelName,           [kTechDataMaxHealth] = kShadeHealth, [kTechDataMaxArmor] = kShadeArmor,   [kTechDataInitialEnergy] = kShadeInitialEnergy,      [kTechDataMaxEnergy] = kShadeMaxEnergy, [kTechDataPointValue] = kShadePointValue, [kVisualRange] = Shade.kCloakRadius, [kTechDataMaxExtents] = Vector(1, 1.3, .4), [kTechDataTooltipInfo] = "SHADE_TOOLTIP", [kTechDataGrows] = true },

        { [kTechDataId] = kTechId.Web, [kTechDataCategory] = kTechId.Gorge, [kTechDataMaxHealth] = kWebHealth, [kTechDataModel] = Web.kRootModelName, [kTechDataSpecifyOrientation] = true,  [kTechDataGhostModelClass] = "WebGhostModel", [kTechDataMaxAmount] = kNumWebsPerGorge, [kTechDataAllowConsumeDrop] = true, [kTechDataDisplayName] = "WEB", [kTechDataCostKey] = kWebBuildCost, [kTechDataTooltipInfo] = "WEB_TOOLTIP" },        
        { [kTechDataId] = kTechId.Hydra, [kTechDataHint] = "HYDRA_HINT", [kTechDataTooltipInfo] = "HYDRA_TOOLTIP", [kTechDataDamageType] = kHydraAttackDamageType, [kTechDataAllowConsumeDrop] = true, [kTechDataGhostModelClass] = "AlienGhostModel",    [kTechDataMaxAmount] = kHydrasPerHive,       [kTechDataMapName] = Hydra.kMapName,                        [kTechDataDisplayName] = "HYDRA",           [kTechDataCostKey] = kHydraCost,       [kTechDataBuildTime] = kHydraBuildTime, [kTechDataMaxHealth] = kHydraHealth, [kTechDataMaxArmor] = kHydraArmor, [kTechDataModel] = Hydra.kModelName, [kVisualRange] = Hydra.kRange, [kTechDataRequiresInfestation] = false, [kTechDataPointValue] = kHydraPointValue, [kTechDataGrows] = true},
        { [kTechDataId] = kTechId.Clog, [kTechDataGhostModelClass] = "AlienGhostModel",  [kTechDataAllowConsumeDrop] = true, [kTechDataTooltipInfo] = "CLOG_TOOLTIP", [kTechDataAllowStacking] = true,  [kTechDataMaxAmount] = kClogsPerHive,     [kTechDataMapName] = Clog.kMapName,                        [kTechDataDisplayName] = "CLOG",           [kTechDataCostKey] = kClogCost,  [kTechDataMaxHealth] = kClogHealth, [kTechDataMaxArmor] = kClogArmor, [kTechDataModel] = Clog.kModelName, [kTechDataRequiresInfestation] = false, [kTechDataPointValue] = kClogPointValue },
        { [kTechDataId] = kTechId.GorgeTunnel, 
        [kTechDataCategory] = kTechId.Gorge,
        [kTechDataMaxExtents] = Vector(1.2, 1.2, 1.2),
        [kTechDataTooltipInfo] = "GORGE_TUNNEL_TOOLTIP",
         [kTechDataGhostModelClass] = "AlienGhostModel",  
        [kTechDataAllowConsumeDrop] = true,
       [kTechDataAllowStacking] = false,  
       [kTechDataMaxAmount] = kNumGorgeTunnels,   
        [kTechDataMapName] = TunnelEntrance.kMapName,  
        [kTechDataDisplayName] = "TUNNEL_ENTRANCE", 
       [kTechDataHint] = "TUNNEL_ENTRANCE_HINT", 
       [kTechDataCostKey] = kGorgeTunnelCost,  
       [kTechDataMaxHealth] = kTunnelEntranceHealth, 
       [kTechDataMaxArmor] = kTunnelEntranceArmor,
        [kTechDataBuildTime] = kGorgeTunnelBuildTime, 
       [kTechDataModel] = TunnelEntrance.kModelName, 
      [kTechDataRequiresInfestation] = false, 
       [kTechDataPointValue] = kTunnelEntrancePointValue },
       
        { [kTechDataId] = kTechId.GorgeTunnelTech, [kTechDataDisplayName] = "GORGE_TUNNEL_TECH", [kTechDataTooltipInfo] = "GORGE_TUNNEL_TECH_TOOLTIP", [kTechDataCostKey] = kGorgeTunnelResearchCost, [kTechDataResearchTimeKey] = kGorgeTunnelResearchTime },
        { [kTechDataId] = kTechId.Babbler,  [kTechDataMapName] = Babbler.kMapName,  [kTechDataDisplayName] = "BABBLER",  [kTechDataModel] = Babbler.kModelName, [kTechDataMaxHealth] = kBabblerHealth, [kTechDataMaxArmor] = kBabblerArmor, [kTechDataPointValue] = kBabblerPointValue, [kTechDataTooltipInfo] = "BABBLER_TOOLTIP" },
        { [kTechDataId] = kTechId.BabblerTech,  [kTechDataDisplayName] = "BABBLER", [kTechDataTooltipInfo] = "BABBLER_TOOLTIP" },
        { [kTechDataId] = kTechId.BellySlide, [kTechDataDisplayName] = "BELLY_SLIDE", [kTechDataTooltipInfo] = "BELLY_SLIDE_TOOLTIP" },
        { [kTechDataId] = kTechId.BabblerEgg, [kTechDataCategory] = kTechId.Gorge, [kTechDataAllowConsumeDrop] = true, [kTechDataMaxAmount] = kNumBabblerEggsPerGorge, [kTechDataCostKey] = kBabblerCost,   [kTechDataBuildTime] = kBabblerEggBuildTime,          [kTechDataMapName] = BabblerEgg.kMapName,  [kTechDataDisplayName] = "BABBLER_EGG",  [kTechDataModel] = BabblerEgg.kModelName, [kTechDataMaxHealth] = kBabblerEggHealth, [kTechDataMaxArmor] = kBabblerEggArmor, [kTechDataPointValue] = kBabblerEggPointValue, [kTechDataTooltipInfo] = "BABBLER_EGG_TOOLTIP" },


        { [kTechDataId] = kTechId.Cyst, [kTechDataSpawnBlock] = true, [kTechDataBuildMethodFailedMessage] = "COMMANDERERROR_NO_CYST_PARENT_FOUND", [kTechDataOverrideCoordsMethod] = AlignCyst, [kTechDataHint] = "CYST_HINT", [kTechDataCooldown] = kCystCooldown, [kTechDataGhostModelClass] = "CystGhostModel",    [kTechDataMapName] = Cyst.kMapName,  [kTechDataDisplayName] = "CYST", [kTechDataTooltipInfo] = "CYST_TOOLTIP", [kTechDataCostKey] = kCystCost, [kTechDataBuildTime] = kCystBuildTime, [kTechDataMaxHealth] = kCystHealth, [kTechDataMaxArmor] = kCystArmor, [kTechDataModel] = Cyst.kModelName, [kVisualRange] = kInfestationRadius, [kTechDataRequiresInfestation] = false, [kTechDataPointValue] = kCystPointValue, [kTechDataGrows] = false,  [kTechDataBuildRequiresMethod] = GetCystParentAvailable },
        { [kTechDataId] = kTechId.Hallucinate,  [kTechDataCooldown] = kHallucinationCloudCooldown,   [kTechDataMapName] = HallucinationCloud.kMapName, [kTechDataDisplayName] = "HALLUCINATION_CLOUD", [kTechDataCostKey] = kHallucinationCloudCost, [kTechDataTooltipInfo] =  "HALLUCINATION_CLOUD_TOOLTIP"},
        { [kTechDataId] = kTechId.SelectHallucinations,  [kTechDataDisplayName] = "SELECT_HALLUCINATIONS", [kTechDataTooltipInfo] =  "SELECT_HALLUCINATIONS_TOOLTIP"},
        { [kTechDataId] = kTechId.EnzymeCloud,  [kTechDataCooldown] = kDrifterAbilityCooldown,   [kTechDataMapName] = EnzymeCloud.kMapName, [kTechDataDisplayName] = "ENZYME_CLOUD", [kTechDataCostKey] = kEnzymeCloudCost, [kTechDataTooltipInfo] =  "ENZYME_CLOUD_TOOLTIP"},
        { [kTechDataId] = kTechId.Storm,   [kTechDataCooldown] = kDrifterAbilityCooldown,  [kTechDataMapName] = StormCloud.kMapName, [kTechDataDisplayName] = "STORM", [kTechDataCostKey] = kStormCost, [kTechDataTooltipInfo] =  "STORM_TOOLTIP"},
        { [kTechDataId] = kTechId.MucousMembrane,  [kTechDataCooldown] = 15,   [kTechDataDisplayName] = "MUCOUS_MEMBRANE",  [kTechDataCostKey] = 5, [kTechDataMapName] = MucousMembrane.kMapName,  [kTechDataTooltipInfo] = "MUCOUS_MEMBRANE_TOOLTIP"},
     
     
               { [kTechDataId] = kTechId.CragUmbra,
         [kTechDataDisplayName] = "UMBRA",
      [kVisualRange] = Crag.kHealRadius, 
     [kTechDataCooldown] = kCragUmbraCooldown, 
     [kTechDataCostKey] = kCragUmbraCost,  
    [kTechDataTooltipInfo] = "CRAG_UMBRA_TOOLTIP"},
    
                   { [kTechDataId] = kTechId.HallucinatedExplosion,
         [kTechDataDisplayName] = "HallucinatedExplosion",
      [kVisualRange] = 12, 
     [kTechDataCooldown] = 0, 
     [kTechDataCostKey] = 0,  
    [kTechDataTooltipInfo] = "HallucinatedExplosion TOOLTIP"},
    
    
        { [kTechDataId] = kTechId.DestroyHallucination, [kTechDataDisplayName] = "DESTROY_HALLUCINATION"},
     

        // Alien structure abilities and their energy costs
                { [kTechDataId] = kTechId.CragHeal,
         [kTechDataDisplayName] = "HEAL", 
      [kTechDataTooltipInfo] = "Heals players and structures (+10 every 2 seconds, max 3 targets) Siege Modifications:30 Levels, each level adds a percentage of heal and time reduction till next heal. so Level 15 crag would be +30% effective heal and 30% faster heal. Every succesful heal gives 1 level"},
      //  { [kTechDataId] = kTechId.CragHeal,         [kTechDataDisplayName] = "HEAL",  [kTechDataTooltipInfo] = "CRAG_HEAL_TOOLTIP"},
        { [kTechDataId] = kTechId.CragUmbra,        [kTechDataDisplayName] = "UMBRA", [kVisualRange] = Crag.kHealRadius, [kTechDataTooltipInfo] = "CRAG_UMBRA_TOOLTIP"},
        { [kTechDataId] = kTechId.HealWave,    [kTechDataCooldown] = kHealWaveCooldown,     [kTechDataDisplayName] = "HEAL_WAVE",       [kTechDataCostKey] = kCragHealWaveCost,  [kTechDataTooltipInfo] = "HEAL_WAVE_TOOLTIP"},
        { [kTechDataId] = kTechId.WhipBombard,           [kTechDataHint] = "BOMBARD_WHIP_HINT", [kTechDataDisplayName] = "BOMBARD",         [kTechDataTooltipInfo] = "WHIP_BOMBARD_TOOLTIP" },
        { [kTechDataId] = kTechId.WhipBombardCancel,      [kTechDataDisplayName] = "CANCEL",         [kTechDataTooltipInfo] = "WHIP_BOMBARD_CANCEL"},
        { [kTechDataId] = kTechId.WhipBomb,              [kTechDataMapName] = WhipBomb.kMapName,        [kTechDataDamageType] = kWhipBombDamageType,    [kTechDataModel] = "", [kTechDataDisplayName] = "WHIPBOMB", },

        { [kTechDataId] = kTechId.ShiftEcho,     [kTechDataDisplayName] = "ECHO",  [kTechDataTooltipInfo] = "SHIFT_ECHO_TOOLTIP"},
        { [kTechDataId] = kTechId.ShiftHatch, [kTechDataCooldown] = kHatchCooldown,  [kTechDataMaxExtents] = Vector(Onos.XExtents, Onos.YExtents, Onos.ZExtents),  [kStructureAttachRange] = kShiftHatchRange,      [kTechDataBuildRequiresMethod] = GetShiftIsBuilt, [kTechDataGhostGuidesMethod] = GetShiftHatchGhostGuides, [kTechDataMapName] = Egg.kMapName, [kTechDataGhostModelClass] = "AlienGhostModel", [kTechDataModel] = Egg.kModelName, [kTechDataRequiresInfestation] = true,  [kTechDataDisplayName] = "HATCH",      [kTechDataTooltipInfo] = "SHIFT_HATCH_TOOLTIP", [kTechDataCostKey] = kShiftHatchCost},
        { [kTechDataId] = kTechId.ShiftEnergize,         [kTechDataDisplayName] = "ENERGIZE",    [kTechDataTooltipInfo] = "SHIFT_ENERGIZE_TOOLTIP"},

        { [kTechDataId] = kTechId.ShadeDisorient,         [kTechDataDisplayName] = "DISORIENT",      [kTechDataHotkey] = Move.D,  [kVisualRange] = Shade.kCloakRadius, [kTechDataTooltipInfo] = "SHADE_DISORIENT_TOOLTIP"},        
        { [kTechDataId] = kTechId.ShadeCloak,             [kTechDataDisplayName] = "CLOAK",      [kTechDataHotkey] = Move.C,  [kTechDataTooltipInfo] = "SHADE_CLOAK_TOOLTIP"},        
        { [kTechDataId] = kTechId.ShadeInk,    [kTechDataCooldown] = kShadeInkCooldown,       [kTechDataDisplayName] = "INK",      [kTechDataHotkey] = Move.C,     [kTechDataCostKey] = kShadeInkCost, [kTechDataTooltipInfo] = "SHADE_INK_TOOLTIP"},   
        { [kTechDataId] = kTechId.ShadePhantomMenu,            [kTechDataDisplayName] = "PHANTOM",     [kTechDataHotkey] = Move.P, [kTechDataImplemented] = true },
        { [kTechDataId] = kTechId.ShadePhantomStructuresMenu,  [kTechDataDisplayName] = "PHANTOM",     [kTechDataHotkey] = Move.P, [kTechDataImplemented] = true },

        { [kTechDataId] = kTechId.HallucinateDrifter,  [kTechDataDisplayName] = "HALLUCINATE_DRIFTER", [kTechDataTooltipInfo] = "HALLUCINATE_DRIFTER_TOOLTIP", [kTechDataCostKey] = kHallucinateDrifterEnergyCost },
        { [kTechDataId] = kTechId.HallucinateSkulk,  [kTechDataDisplayName] = "HALLUCINATE_SKULK", [kTechDataTooltipInfo] = "HALLUCINATE_SKULK_TOOLTIP", [kTechDataCostKey] = kHallucinateSkulkEnergyCost },
        { [kTechDataId] = kTechId.HallucinateGorge,  [kTechDataDisplayName] = "HALLUCINATE_GORGE", [kTechDataTooltipInfo] = "HALLUCINATE_GORGE_TOOLTIP", [kTechDataCostKey] = kHallucinateGorgeEnergyCost },
        { [kTechDataId] = kTechId.HallucinateLerk,  [kTechDataDisplayName] = "HALLUCINATE_LERK", [kTechDataTooltipInfo] = "HALLUCINATE_LERK_TOOLTIP", [kTechDataCostKey] = kHallucinateLerkEnergyCost },
        { [kTechDataId] = kTechId.HallucinateFade,  [kTechDataDisplayName] = "HALLUCINATE_FADE", [kTechDataTooltipInfo] = "HALLUCINATE_FADE_TOOLTIP", [kTechDataCostKey] = kHallucinateFadeEnergyCost },
        { [kTechDataId] = kTechId.HallucinateOnos,  [kTechDataDisplayName] = "HALLUCINATE_ONOS", [kTechDataTooltipInfo] = "HALLUCINATE_ONOS_TOOLTIP", [kTechDataCostKey] = kHallucinateOnosEnergyCost },
        
        { [kTechDataId] = kTechId.HallucinateHive,  [kTechDataSpawnHeightOffset] = 2.494, [kStructureAttachClass] = "TechPoint", [kTechDataDisplayName] =      "HALLUCINATE_HIVE",      [kTechDataModel] = Hive.kModelName, [kTechDataTooltipInfo] = "HALLUCINATE_HIVE_TOOLTIP", [kTechDataCostKey] = kHallucinateHiveEnergyCost },
        { [kTechDataId] = kTechId.HallucinateWhip, [kTechDataRequiresInfestation] = true, [kTechDataDisplayName] =      "HALLUCINATE_WHIP",      [kTechDataModel] = Whip.kModelName, [kTechDataTooltipInfo] = "HALLUCINATE_WHIP_TOOLTIP", [kTechDataCostKey] = kHallucinateWhipEnergyCost },
        { [kTechDataId] = kTechId.HallucinateShade,  [kTechDataRequiresInfestation] = true, [kTechDataDisplayName] =     "HALLUCINATE_SHADE",     [kTechDataModel] = Shade.kModelName, [kTechDataTooltipInfo] = "HALLUCINATE_SHADE_TOOLTIP", [kTechDataCostKey] = kHallucinateShadeEnergyCost },
        { [kTechDataId] = kTechId.HallucinateCrag,  [kTechDataRequiresInfestation] = true, [kTechDataDisplayName] =      "HALLUCINATE_CRAG",      [kTechDataModel] = Crag.kModelName, [kTechDataTooltipInfo] = "HALLUCINATE_CRAG_TOOLTIP", [kTechDataCostKey] = kHallucinateCragEnergyCost },
        { [kTechDataId] = kTechId.HallucinateShift,  [kTechDataRequiresInfestation] = true, [kTechDataDisplayName] =     "HALLUCINATE_SHIFT",     [kTechDataModel] = Shift.kModelName, [kTechDataTooltipInfo] = "HALLUCINATE_SHIFT_TOOLTIP", [kTechDataCostKey] = kHallucinateShiftEnergyCost },        
        { [kTechDataId] = kTechId.HallucinateHarvester,  [kStructureAttachClass] = "ResourcePoint", [kTechDataRequiresInfestation] = true, [kTechDataDisplayName] = "HALLUCINATE_HARVESTER", [kTechDataModel] = Harvester.kModelName, [kTechDataTooltipInfo] = "HALLUCINATE_HARVESTER_TOOLTIP", [kTechDataCostKey] = kHallucinateHarvesterEnergyCost },
        { [kTechDataId] = kTechId.HallucinateHydra, [kTechDataEngagementDistance] = 3.5, [kTechDataRequiresInfestation] = true, [kTechDataDisplayName] =     "HALLUCINATE_HYDRA",     [kTechDataModel] = Hydra.kModelName, [kTechDataTooltipInfo] = "HALLUCINATE_HYDRA_TOOLTIP", [kTechDataCostKey] = kHallucinateHydraEnergyCost },
        
        { [kTechDataId] = kTechId.WhipUnroot,           [kTechDataDisplayName] = "UNROOT_WHIP",     [kTechDataTooltipInfo] = "UNROOT_WHIP_TOOLTIP", [kTechDataMenuPriority] = 2},
        { [kTechDataId] = kTechId.WhipRoot,             [kTechDataDisplayName] = "ROOT_WHIP",       [kTechDataTooltipInfo] = "ROOT_WHIP_TOOLTIP", [kTechDataMenuPriority] = 3},

        // Alien lifeforms
        { [kTechDataId] = kTechId.Skulk, [kTechDataUpgradeCost] = kSkulkUpgradeCost, [kTechDataMapName] = Skulk.kMapName, [kTechDataGestateName] = Skulk.kMapName,                      [kTechDataGestateTime] = kSkulkGestateTime, [kTechDataDisplayName] = "SKULK",  [kTechDataTooltipInfo] = "SKULK_TOOLTIP",        [kTechDataModel] = Skulk.kModelName, [kTechDataCostKey] = kSkulkCost, [kTechDataMaxHealth] = Skulk.kHealth, [kTechDataMaxArmor] = Skulk.kArmor, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataMaxExtents] = Vector(Skulk.kXExtents, Skulk.kYExtents, Skulk.kZExtents), [kTechDataPointValue] = kSkulkPointValue},
        { [kTechDataId] = kTechId.Gorge, [kTechDataUpgradeCost] = kGorgeUpgradeCost, [kTechDataMapName] = Gorge.kMapName, [kTechDataGestateName] = Gorge.kMapName,                      [kTechDataGestateTime] = kGorgeGestateTime, [kTechDataDisplayName] = "GORGE", [kTechDataTooltipInfo] = "GORGE_TOOLTIP",          [kTechDataModel] = Gorge.kModelName,[kTechDataCostKey] = kGorgeCost, [kTechDataMaxHealth] = kGorgeHealth, [kTechDataMaxArmor] = kGorgeArmor, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataMaxExtents] = Vector(Gorge.kXZExtents, Gorge.kYExtents, Gorge.kXZExtents), [kTechDataPointValue] = kGorgePointValue},
        { [kTechDataId] = kTechId.Lerk, [kTechDataUpgradeCost] = kLerkUpgradeCost, [kTechDataMapName] = Lerk.kMapName, [kTechDataGestateName] = Lerk.kMapName,                       [kTechDataGestateTime] = kLerkGestateTime, [kTechDataDisplayName] = "LERK",   [kTechDataTooltipInfo] = "LERK_TOOLTIP",         [kTechDataModel] = Lerk.kModelName,[kTechDataCostKey] = kLerkCost, [kTechDataMaxHealth] = kLerkHealth, [kTechDataMaxArmor] = kLerkArmor, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataMaxExtents] = Vector(Lerk.XZExtents, Lerk.YExtents, Lerk.XZExtents), [kTechDataPointValue] = kLerkPointValue},
        { [kTechDataId] = kTechId.Fade, [kTechDataUpgradeCost] = kFadeUpgradeCost, [kTechDataMapName] = Fade.kMapName, [kTechDataGestateName] = Fade.kMapName,                       [kTechDataGestateTime] = kFadeGestateTime, [kTechDataDisplayName] = "FADE",   [kTechDataTooltipInfo] = "FADE_TOOLTIP",         [kTechDataModel] = Fade.kModelName,[kTechDataCostKey] = kFadeCost, [kTechDataMaxHealth] = Fade.kHealth, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataMaxArmor] = Fade.kArmor, [kTechDataMaxExtents] = Vector(Fade.XZExtents, Fade.YExtents, Fade.XZExtents), [kTechDataPointValue] = kFadePointValue},        
        { [kTechDataId] = kTechId.Onos, [kTechDataUpgradeCost] = kOnosUpgradeCost, [kTechDataMapName] = Onos.kMapName, [kTechDataGestateName] = Onos.kMapName,                       [kTechDataGestateTime] = kOnosGestateTime, [kTechDataDisplayName] = "ONOS",   [kTechDataTooltipInfo] = "ONOS_TOOLTIP", [kTechDataModel] = Onos.kModelName,[kTechDataCostKey] = kOnosCost, [kTechDataMaxHealth] = Onos.kHealth, [kTechDataEngagementDistance] = kOnosEngagementDistance, [kTechDataMaxArmor] = Onos.kArmor, [kTechDataMaxExtents] = Vector(Onos.XExtents, Onos.YExtents, Onos.ZExtents), [kTechDataPointValue] = kOnosPointValue},
        { [kTechDataId] = kTechId.Embryo,                [kTechDataMapName] = Embryo.kMapName, [kTechDataGestateName] = Embryo.kMapName,                     [kTechDataDisplayName] = "EMBRYO", [kTechDataModel] = Embryo.kModelName, [kTechDataMaxExtents] = Vector(Embryo.kXExtents, Embryo.kYExtents, Embryo.kZExtents)},
        { [kTechDataId] = kTechId.AlienCommander,        [kTechDataMapName] = AlienCommander.kMapName, [kTechDataDisplayName] = "ALIEN COMMANDER", [kTechDataModel] = ""},
        
        { [kTechDataId] = kTechId.Hallucination,         [kTechDataMapName] = Hallucination.kMapName, [kTechDataDisplayName] = "HALLUCINATION", [kTechDataCostKey] = kHallucinationCost, [kTechDataEngagementDistance] = kPlayerEngagementDistance },
        
        // Lifeform purchases
        { [kTechDataId] = kTechId.Redemption, 
       [kTechDataCategory] = kTechId.CragHive,  
        [kTechDataDisplayName] = "Redemption", 
      [kTechDataSponitorCode] = "B",  
      [kTechDataCostKey] = kRedemptionCost, 
     [kTechDataTooltipInfo] = "Will automatically return you to the hive when below 35% HP (if 45 sec cooldown is 0).", },
     
             { [kTechDataId] = kTechId.Rebirth, 
       [kTechDataCategory] = kTechId.CragHive,  
        [kTechDataDisplayName] = "Rebirth", 
      [kTechDataSponitorCode] = "A",  
      [kTechDataCostKey] = kRebirthCost, 
     [kTechDataTooltipInfo] = "You've tried Redemption, now try its alternative. Upon death, turns you back into a gestating egg (Back into the class you just died as) with a protective bonewall during the gestation.", },
   

             { [kTechDataId] = kTechId.Focus, 
       [kTechDataCategory] = kTechId.ShadeHive,  
        [kTechDataDisplayName] = "Focus", 
      [kTechDataSponitorCode] = "B",  
      [kTechDataCostKey] = kRebirthCost, 
     [kTechDataTooltipInfo] = "1st slot weapon and primary fire only (and healspray) - Each level of biomass slows attack rate by 2.75 percent and increases damage (or healspray) by 4.16 percent", },
  
        { [kTechDataId] = kTechId.Carapace,       [kTechDataCategory] = kTechId.CragHive,    [kTechDataDisplayName] = "CARAPACE",       [kTechDataSponitorCode] = "C",   [kTechDataCostKey] = kCarapaceCost, [kTechDataTooltipInfo] = "CARAPACE_TOOLTIP", },
        { [kTechDataId] = kTechId.Regeneration,   [kTechDataCategory] = kTechId.CragHive,    [kTechDataDisplayName] = "REGENERATION",   [kTechDataSponitorCode] = "R",   [kTechDataCostKey] = kRegenerationCost, [kTechDataTooltipInfo] = "REGENERATION_TOOLTIP", },
        { [kTechDataId] = kTechId.Silence,        [kTechDataCategory] = kTechId.ShadeHive,   [kTechDataDisplayName] = "SILENCE",        [kTechDataSponitorCode] = "S",   [kTechDataTooltipInfo] = "SILENCE_TOOLTIP", [kTechDataCostKey] = kSilenceCost },
        { [kTechDataId] = kTechId.Camouflage,     [kTechDataCategory] = kTechId.ShadeHive,   [kTechDataDisplayName] = "CAMOUFLAGE",     [kTechDataSponitorCode] = "M",   [kTechDataTooltipInfo] = "CAMOUFLAGE_TOOLTIP", [kTechDataCostKey] = kCamouflageCost },
        { [kTechDataId] = kTechId.Phantom,        [kTechDataCategory] = kTechId.ShadeHive,   [kTechDataDisplayName] = "PHANTOM",     [kTechDataSponitorCode] = "M",   [kTechDataTooltipInfo] = "PHANTOM_TOOLTIP", [kTechDataCostKey] = kCamouflageCost },
        { [kTechDataId] = kTechId.Aura,           [kTechDataCategory] = kTechId.ShadeHive,   [kTechDataDisplayName] = "AURA",     [kTechDataSponitorCode] = "M",   [kTechDataTooltipInfo] = "AURA_TOOLTIP", [kTechDataCostKey] = kAuraCost },

        { [kTechDataId] = kTechId.Celerity,       [kTechDataCategory] = kTechId.ShiftHive,   [kTechDataDisplayName] = "CELERITY",       [kTechDataSponitorCode] = "L",   [kTechDataTooltipInfo] = "CELERITY_TOOLTIP", [kTechDataCostKey] = kCelerityCost },
        { [kTechDataId] = kTechId.Adrenaline,     [kTechDataCategory] = kTechId.ShiftHive,   [kTechDataDisplayName] = "ADRENALINE",     [kTechDataSponitorCode] = "A",   [kTechDataTooltipInfo] = "ADRENALINE_TOOLTIP", [kTechDataCostKey] = kAdrenalineCost },
        { [kTechDataId] = kTechId.HyperMutation,  [kTechDataCategory] = kTechId.ShiftHive,   [kTechDataDisplayName] = "HYPERMUTATION",  [kTechDataSponitorCode] = "H",   [kTechDataTooltipInfo] = "HYPERMUTATION_TOOLTIP", [kTechDataCostKey] = kHyperMutationCost },

        // Alien markers
        { [kTechDataId] = kTechId.ThreatMarker,            [kTechDataImplemented] = true,      [kTechDataDisplayName] = "MARK_THREAT", [kTechDataTooltipInfo] = "PHEROMONE_THREAT_TOOLTIP",},
        { [kTechDataId] = kTechId.NeedHealingMarker,       [kTechDataImplemented] = true,      [kTechDataDisplayName] = "NEED_HEALING_HERE", [kTechDataTooltipInfo] = "PHEROMONE_HEAL_TOOLTIP",},
        { [kTechDataId] = kTechId.WeakMarker,              [kTechDataImplemented] = true,      [kTechDataDisplayName] = "WEAK_HERE", [kTechDataTooltipInfo] = "PHEROMONE_HEAL_TOOLTIP",},
        { [kTechDataId] = kTechId.ExpandingMarker,         [kTechDataImplemented] = true,      [kTechDataDisplayName] = "EXPANDING_HERE", [kTechDataTooltipInfo] = "PHEROMONE_EXPANDING_TOOLTIP",},
      
        { [kTechDataId] = kTechId.BoneWall, [kTechDataMaxExtents] = Vector(8, 1, 8), [kTechDataGhostModelClass] = "AlienGhostModel", [kTechDataModel] = BoneWall.kModelName, [kTechDataMapName] = BoneWall.kMapName, [kTechDataOverrideCoordsMethod] = AlignBoneWalls, [kTechDataMaxHealth] = kBoneWallHealth, [kTechDataMaxArmor] = kBoneWallArmor,  [kTechDataPointValue] = 0, [kTechDataCooldown] = kBoneWallCooldown, [kTechDataAllowStacking] = true, [kTechDataIgnorePathingMesh] = true, [kTechDataCollideWithWorldOnly] = true, [kTechDataRequiresInfestation] = true, [kTechDataDisplayName] = "INFESTATION_SPIKE", [kTechDataCostKey] = kBoneWallCost, [kTechDataTooltipInfo] =  "INFESTATION_SPIKE_TOOLTIP", [kVisualRange] = 2.75},
        { [kTechDataId] = kTechId.Contamination, 
      [kTechDataGhostModelClass] = "AlienGhostModel", 
      [kTechDataModel] = Contamination.kModelName, 
     [kTechDataMapName] = Contamination.kMapName, 
      [kTechDataMaxHealth] = kContaminationHealth, 
      [kTechDataMaxArmor] = kContaminationArmor,
         [kTechDataPointValue] = 0, 
       [kTechDataCooldown] = kContaminationCooldown, 
      [kTechDataCollideWithWorldOnly] = true, 
     [kTechDataDisplayName] = "CONTAMINATION", 
     [kTechDataCostKey] = kContaminationCost,
    [kTechDataTooltipInfo] =  "CONTAMINATION_TOOLTIP"},
    
        { [kTechDataId] = kTechId.Rupture, [kTechDataCooldown] = kRuptureCooldown, [kTechDataMapName] = Rupture.kMapName, [kTechDataGhostModelClass] = "AlienGhostModel", [kTechDataDisplayName] = "RUPTURE", [kTechDataAllowStacking] = true, [kTechDataCollideWithWorldOnly] = true, [kTechDataRequiresInfestation] = true, [kTechDataIgnorePathingMesh] = true, [kTechDataCostKey] = kRuptureCost, [kTechDataTooltipInfo] =  "RUPTURE_TOOLTIP"},
        
         
        // Alerts
        { [kTechDataId] = kTechId.MarineAlertSentryUnderAttack,                 [kTechDataAlertSound] = Sentry.kUnderAttackSound,                           [kTechDataAlertType] = kAlertType.Info,   [kTechDataAlertPriority] = 0, [kTechDataAlertText] = "MARINE_ALERT_SENTRY_UNDERATTACK", [kTechDataAlertTeam] = false},
        { [kTechDataId] = kTechId.MarineAlertSoldierUnderAttack,                [kTechDataAlertSound] = MarineCommander.kSoldierUnderAttackSound,           [kTechDataAlertType] = kAlertType.Info,   [kTechDataAlertPriority] = 0, [kTechDataAlertText] = "MARINE_ALERT_SOLDIER_UNDERATTACK", [kTechDataAlertTeam] = true},
        { [kTechDataId] = kTechId.MarineAlertStructureUnderAttack,              [kTechDataAlertSound] = MarineCommander.kStructureUnderAttackSound,         [kTechDataAlertType] = kAlertType.Info,   [kTechDataAlertPriority] = 1, [kTechDataAlertText] = "MARINE_ALERT_STRUCTURE_UNDERATTACK", [kTechDataAlertTeam] = true},
        { [kTechDataId] = kTechId.MarineAlertExtractorUnderAttack,              [kTechDataAlertSound] = MarineCommander.kStructureUnderAttackSound,         [kTechDataAlertType] = kAlertType.Info,   [kTechDataAlertPriority] = 1, [kTechDataAlertText] = "MARINE_ALERT_EXTRACTOR_UNDERATTACK", [kTechDataAlertTeam] = true, [kTechDataAlertIgnoreDistance] = true},          
        { [kTechDataId] = kTechId.MarineAlertCommandStationUnderAttack,         [kTechDataAlertSound] = CommandStation.kUnderAttackSound,                   [kTechDataAlertType] = kAlertType.Info,   [kTechDataAlertPriority] = 2, [kTechDataAlertText] = "MARINE_ALERT_COMMANDSTATION_UNDERAT",  [kTechDataAlertTeam] = true, [kTechDataAlertIgnoreDistance] = true, [kTechDataAlertSendTeamMessage] = kTeamMessageTypes.CommandStationUnderAttack},
        { [kTechDataId] = kTechId.MarineAlertInfantryPortalUnderAttack,         [kTechDataAlertSound] = InfantryPortal.kUnderAttackSound,                   [kTechDataAlertType] = kAlertType.Info,   [kTechDataAlertPriority] = 1, [kTechDataAlertText] = "MARINE_ALERT_INFANTRYPORTAL_UNDERAT",  [kTechDataAlertTeam] = true, [kTechDataAlertSendTeamMessage] = kTeamMessageTypes.IPUnderAttack},

        { [kTechDataId] = kTechId.MarineAlertCommandStationComplete,            [kTechDataAlertSound] = MarineCommander.kCommandStationCompletedSoundName,  [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_COMMAND_STATION_COMPLETE", [kTechDataAlertTeam] = true, [kTechDataAlertIgnoreDistance] = true,}, 
        { [kTechDataId] = kTechId.MarineAlertConstructionComplete,              [kTechDataAlertSound] = MarineCommander.kObjectiveCompletedSoundName,       [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_CONSTRUCTION_COMPLETE", [kTechDataAlertTeam] = false}, 
        { [kTechDataId] = kTechId.MarineCommanderEjected,                       [kTechDataAlertSound] = MarineCommander.kCommanderEjectedSoundName,         [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_COMMANDER_EJECTED",    [kTechDataAlertTeam] = true},
        { [kTechDataId] = kTechId.MarineAlertSentryFiring,                      [kTechDataAlertSound] = MarineCommander.kSentryFiringSoundName,             [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_SENTRY_FIRING"},
        { [kTechDataId] = kTechId.MarineAlertSoldierLost,                       [kTechDataAlertSound] = MarineCommander.kSoldierLostSoundName,              [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_SOLDIER_LOST",    [kTechDataAlertOthersOnly] = true},
        { [kTechDataId] = kTechId.MarineAlertAcknowledge,                       [kTechDataAlertSound] = MarineCommander.kSoldierAcknowledgesSoundName,      [kTechDataAlertType] = kAlertType.Request,  [kTechDataAlertText] = "MARINE_ALERT_ACKNOWLEDGE"},
        { [kTechDataId] = kTechId.MarineAlertNeedAmmo,      [kTechDataAlertIgnoreInterval] = true, [kTechDataAlertSound] = MarineCommander.kSoldierNeedsAmmoSoundName,         [kTechDataAlertType] = kAlertType.Request,  [kTechDataAlertText] = "MARINE_ALERT_NEED_AMMO"},
        { [kTechDataId] = kTechId.MarineAlertNeedMedpack,   [kTechDataAlertIgnoreInterval] = true, [kTechDataAlertSound] = MarineCommander.kSoldierNeedsHealthSoundName,       [kTechDataAlertType] = kAlertType.Request,  [kTechDataAlertText] = "MARINE_ALERT_NEED_MEDPACK"},
        { [kTechDataId] = kTechId.MarineAlertNeedOrder,     [kTechDataAlertIgnoreInterval] = true, [kTechDataAlertSound] = MarineCommander.kSoldierNeedsOrderSoundName,        [kTechDataAlertType] = kAlertType.Request,  [kTechDataAlertText] = "MARINE_ALERT_NEED_ORDER"},
        { [kTechDataId] = kTechId.MarineAlertUpgradeComplete,                   [kTechDataAlertSound] = MarineCommander.kUpgradeCompleteSoundName,          [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_UPGRADE_COMPLETE"},
        { [kTechDataId] = kTechId.MarineAlertResearchComplete,                  [kTechDataAlertSound] = MarineCommander.kResearchCompleteSoundName,         [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_RESEARCH_COMPLETE"},
        { [kTechDataId] = kTechId.MarineAlertManufactureComplete,               [kTechDataAlertSound] = MarineCommander.kManufactureCompleteSoundName,      [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_MANUFACTURE_COMPLETE"},
        { [kTechDataId] = kTechId.MarineAlertNotEnoughResources,                [kTechDataAlertSound] = Player.kNotEnoughResourcesSound,                    [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_NOT_ENOUGH_RESOURCES"},
        { [kTechDataId] = kTechId.MarineAlertMACBlocked,                        [kTechDataAlertType]  = kAlertType.Info,                                     [kTechDataAlertText] = "MARINE_ALERT_MAC_BLOCKED"},
        { [kTechDataId] = kTechId.MarineAlertOrderComplete,                     [kTechDataAlertSound] = MarineCommander.kObjectiveCompletedSoundName,       [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_ORDER_COMPLETE"},           
        { [kTechDataId] = kTechId.MACAlertConstructionComplete,                 [kTechDataAlertSound] = MarineCommander.kMACObjectiveCompletedSoundName,    [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "MARINE_ALERT_CONSTRUCTION_COMPLETE"},        
      
        { [kTechDataId] = kTechId.AlienAlertNeedMist,   [kTechDataAlertIgnoreInterval] = true, [kTechDataAlertSound] = AlienCommander.kSoldierNeedsMistSoundName,       [kTechDataAlertType] = kAlertType.Request,  [kTechDataAlertText] = "ALIEN_ALERT_NEED_MIST"},
        { [kTechDataId] = kTechId.AlienAlertNeedHarvester,   [kTechDataAlertIgnoreInterval] = true, [kTechDataAlertSound] = AlienCommander.kSoldierNeedsHarvesterSoundName,       [kTechDataAlertType] = kAlertType.Request,  [kTechDataAlertText] = "ALIEN_ALERT_NEED_HARVESTER"},
        { [kTechDataId] = kTechId.AlienAlertNeedDrifter,   [kTechDataAlertIgnoreInterval] = true, [kTechDataAlertSound] = AlienCommander.kSoldierNeedsEnzymeSoundName,       [kTechDataAlertType] = kAlertType.Request,  [kTechDataAlertText] = "ALIEN_ALERT_NEED_DRIFTER"},
        { [kTechDataId] = kTechId.AlienAlertHiveUnderAttack,                    [kTechDataAlertSound] = Hive.kUnderAttackSound,                             [kTechDataAlertType] = kAlertType.Info,   [kTechDataAlertPriority] = 2, [kTechDataAlertText] = "ALIEN_ALERT_HIVE_UNDERATTACK",             [kTechDataAlertTeam] = true, [kTechDataAlertIgnoreDistance] = true, [kTechDataAlertSendTeamMessage] = kTeamMessageTypes.HiveUnderAttack},
        { [kTechDataId] = kTechId.AlienAlertStructureUnderAttack,               [kTechDataAlertSound] = AlienCommander.kStructureUnderAttackSound,          [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertPriority] = 0, [kTechDataAlertText] = "ALIEN_ALERT_STRUCTURE_UNDERATTACK",        [kTechDataAlertTeam] = true},
        { [kTechDataId] = kTechId.AlienAlertHarvesterUnderAttack,               [kTechDataAlertSound] = AlienCommander.kHarvesterUnderAttackSound,          [kTechDataAlertType] = kAlertType.Info,   [kTechDataAlertPriority] = 1, [kTechDataAlertText] = "ALIEN_ALERT_HARVESTER_UNDERATTACK",        [kTechDataAlertTeam] = false, [kTechDataAlertIgnoreDistance] = true},
        { [kTechDataId] = kTechId.AlienAlertLifeformUnderAttack,                [kTechDataAlertSound] = AlienCommander.kLifeformUnderAttackSound,           [kTechDataAlertType] = kAlertType.Info,   [kTechDataAlertPriority] = 0, [kTechDataAlertText] = "ALIEN_ALERT_LIFEFORM_UNDERATTACK",         [kTechDataAlertTeam] = true},

        { [kTechDataId] = kTechId.AlienAlertHiveDying,                          [kTechDataAlertSound] = Hive.kDyingSound,                                   [kTechDataAlertType] = kAlertType.Info,   [kTechDataAlertPriority] = 3, [kTechDataAlertText] = "ALIEN_ALERT_HIVE_DYING",                 [kTechDataAlertTeam] = true, [kTechDataAlertIgnoreDistance] = true},        
        { [kTechDataId] = kTechId.AlienAlertHiveComplete,                       [kTechDataAlertSound] = Hive.kCompleteSound,                                [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "ALIEN_ALERT_HIVE_COMPLETE",    [kTechDataAlertTeam] = true, [kTechDataAlertIgnoreDistance] = true},
        { [kTechDataId] = kTechId.AlienAlertUpgradeComplete,                    [kTechDataAlertSound] = AlienCommander.kUpgradeCompleteSoundName,           [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "ALIEN_ALERT_UPGRADE_COMPLETE"},
        { [kTechDataId] = kTechId.AlienAlertResearchComplete,                   [kTechDataAlertSound] = AlienCommander.kResearchCompleteSoundName,          [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "ALIEN_ALERT_RESEARCH_COMPLETE"},
        { [kTechDataId] = kTechId.AlienAlertManufactureComplete,                [kTechDataAlertSound] = AlienCommander.kManufactureCompleteSoundName,       [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "ALIEN_ALERT_MANUFACTURE_COMPLETE"},
        { [kTechDataId] = kTechId.AlienAlertOrderComplete,                      [kTechDataAlertSound] = AlienCommander.kObjectiveCompletedSoundName,        [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "ALIEN_ALERT_ORDER_COMPLETE"},        
        { [kTechDataId] = kTechId.AlienAlertGorgeBuiltHarvester,                [kTechDataAlertType] = kAlertType.Info,                                                                                 [kTechDataAlertText] = "ALIEN_ALERT_GORGEBUILT_HARVESTER"},
        { [kTechDataId] = kTechId.AlienAlertNotEnoughResources,                 [kTechDataAlertSound] = Alien.kNotEnoughResourcesSound,                     [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "ALIEN_ALERT_NOTENOUGH_RESOURCES"},
        { [kTechDataId] = kTechId.AlienCommanderEjected,                        [kTechDataAlertSound] = AlienCommander.kCommanderEjectedSoundName,          [kTechDataAlertType] = kAlertType.Info,     [kTechDataAlertText] = "ALIEN_ALERT_COMMANDER_EJECTED",    [kTechDataAlertTeam] = true},        

        { [kTechDataId] = kTechId.DeathTrigger,                                 [kTechDataDisplayName] = "DEATH_TRIGGER",                                   [kTechDataMapName] = DeathTrigger.kMapName, [kTechDataModel] = ""},

    }

    return techData

end

kTechData = nil

function LookupTechId(fieldData, fieldName)

    // Initialize table if necessary
    if(kTechData == nil) then
    
        kTechData = BuildTechData()
        
    end
    
    if fieldName == nil or fieldName == "" then
    
        Print("LookupTechId(%s, %s) called improperly.", tostring(fieldData), tostring(fieldName))
        return kTechId.None
        
    end

    for index,record in ipairs(kTechData) do 
    
        local currentField = record[fieldName]
        
        if(fieldData == currentField) then
        
            return record[kTechDataId]
            
        end

    end
    
    //Print("LookupTechId(%s, %s) returned kTechId.None", fieldData, fieldName)
    
    return kTechId.None

end

// Table of fieldName tables. Each fieldName table is indexed by techId and returns data.
local cachedTechData = {}

function ClearCachedTechData()
    cachedTechData = {}
end

// Returns true or false. If true, return output in "data"
function GetCachedTechData(techId, fieldName)
    
    local entry = cachedTechData[fieldName]
    
    if entry ~= nil then
    
        return entry[techId]
        
    end
        
    return nil
    
end

function SetCachedTechData(techId, fieldName, data)

    local inserted = false
    
    local entry = cachedTechData[fieldName]
    
    if entry == nil then
    
        cachedTechData[fieldName] = {}
        entry = cachedTechData[fieldName]
        
    end
    
    if entry[techId] == nil then
    
        entry[techId] = data
        inserted = true
        
    end
    
    return inserted
    
end

// Call with techId and fieldname (returns nil if field not found). Pass optional
// third parameter to use as default if not found.
function LookupTechData(techId, fieldName, default)

    // Initialize table if necessary
    if(kTechData == nil) then
    
        kTechData = BuildTechData()
        
    end
    
    if techId == nil or techId == 0 or fieldName == nil or fieldName == "" then
    
        /*    
        local techIdString = ""
        if type(tonumber(techId)) == "number" then            
            techIdString = EnumToString(kTechId, techId)
        end
        
        Print("LookupTechData(%s, %s, %s) called improperly.", tostring(techIdString), tostring(fieldName), tostring(default))
        */
        
        return default
        
    end

    local data = GetCachedTechData(techId, fieldName)
    
    if data == nil then
    
        for index,record in ipairs(kTechData) do 
        
            local currentid = record[kTechDataId]

            if(techId == currentid and record[fieldName] ~= nil) then
            
                data = record[fieldName]
                
                break
                
            end
            
        end        
        
        if data == nil then
            data = default
        end
        
        if not SetCachedTechData(techId, fieldName, data) then
            //Print("Didn't insert anything when calling SetCachedTechData(%d, %s, %s)", techId, fieldName, tostring(data))
        else
            //Print("Inserted new field with SetCachedTechData(%d, %s, %s)", techId, fieldName, tostring(data))
        end
    
    end
    
    return data

end

// Returns true if specified class name is used to attach objects to
function GetIsAttachment(className)
    return (className == "TechPoint") or (className == "ResourcePoint")
end

function GetRecycleAmount(techId, upgradeLevel)

    local amount = GetCachedTechData(techId, kTechDataCostKey)
    if techId == kTechId.AdvancedArmory then
        amount = GetCachedTechData(kTechId.Armory, kTechDataCostKey, 0) + GetCachedTechData(kTechId.AdvancedArmoryUpgrade, kTechDataCostKey, 0)
    end

    return amount
    
end

local gTechForCategory = nil
function GetTechForCategory(techId)

    if gTechForCategory == nil then

        gTechForCategory = {}

        for upgradeId = 2, #kTechId do
        
            local category = LookupTechData(upgradeId, kTechDataCategory, nil)
            if category and category ~= kTechId.None then
                
                if not gTechForCategory[category] then
                    gTechForCategory[category] = {}
                end
                
                table.insertunique(gTechForCategory[category], upgradeId)

            end
        
        end
    
    end
    
    return gTechForCategory[techId] or {}

end

