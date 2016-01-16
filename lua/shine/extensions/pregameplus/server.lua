local Plugin = Plugin

Plugin.HasConfig = true 
Plugin.ConfigName = "PregamePlus.json"

Plugin.DefaultConfig = {
	LimitToggleDelay = 30,
	StatusTextPosX = 0.05,
	StatusTextPosY = 0.45,
	StatusTextColour = { 0, 255, 255 },
	ExtraMessageLine = "[Siege] ~ All Doors are open!",
	Strings = {
		Status = "Pregame \"Sandbox\" - Mode is %s. A match has not started.",
		Limit = "Turns %s when %s %s players.",
		NoLimit = "No player limit.",
		Countdown = "Pregame \"Sandbox\" - Mode turning %s in %s seconds.",
	}
}
Plugin.CheckConfig = true
Plugin.CheckConfigTypes = true

local Shine = Shine
local StringFormat = string.format

--Hacky stuff
local function ReplaceGameStarted1( OldFunc, ... )
	local Hook = Shine.Hook.Call( "CanEntDoDamageTo", ... )
	if not Hook then return OldFunc(...) end

	local gameinfo = GetGameInfoEntity()
	local oldGameInfoState = gameinfo:GetState()
	gameinfo:SetState( kGameState.Started )
	local temp = OldFunc(...)
	gameinfo:SetState( oldGameInfoState )

	return temp
end

local function ReplaceGameStarted2( OldFunc, ... )
	local Hook = Shine.Hook.Call("ProcessBuyAction", ...)
	if not Hook then return OldFunc(...) end

	local oldGetGameStarted = NS2Gamerules.GetGameStarted
	NS2Gamerules.GetGameStarted = function() return true end
	local temp = OldFunc(...)
	NS2Gamerules.GetGameStarted = oldGetGameStarted
	return temp
end

--Hooks
do
	local SetupClassHook = Shine.Hook.SetupClassHook
	local SetupGlobalHook = Shine.Hook.SetupGlobalHook

	SetupClassHook( "Alien", "ProcessBuyAction", "PreProcessBuyAction", ReplaceGameStarted2 )
	SetupClassHook( "AlienTeam", "Update", "AlTeamUpdate", "PassivePost")
	SetupClassHook( "AlienTeam", "UpdateBioMassLevel", "AlTeamUpdateBioMassLevel", "ActivePre")
	SetupClassHook( "InfantryPortal", "FillQueueIfFree", "FillQueueIfFree", "Halt" )
	//SetupClassHook( "MAC", "GetMoveSpeed", "MACGetMoveSpeed", "ActivePre" )
	//SetupClassHook( "MAC", "OnUse", "MACOnUse", "PassivePost" )
	SetupClassHook( "MarineTeam", "Update", "MarTeamUpdate", "PassivePost" )
	SetupClassHook( "ScoringMixin", "AddAssistKill", "AddAssistKill", "ActivePre" )
	SetupClassHook( "ScoringMixin", "AddDeaths", "AddDeaths", "ActivePre" )
	SetupClassHook( "ScoringMixin", "AddKill", "AddKill", "ActivePre" )
	SetupClassHook( "ScoringMixin", "AddScore", "AddScore", "ActivePre" )
	SetupGlobalHook( "CanEntityDoDamageTo", "CanEntDoDamageTo", ReplaceGameStarted1 )

	SetupClassHook( "NS2Gamerules", "ResetGame", "OnResetGame", "PassivePre" )

	--SetGestationData gets overloaded by the comp mod
	Shine.Hook.Add( "Think", "LoadPGPHooks", function()
		SetupClassHook( "Embryo", "SetGestationData", "SetGestationData", "PassivePost" )

		Shine.Hook.Remove( "Think", "LoadPGPHooks")
	end)
end

function Plugin:Initialise()
	local Gamemode = Shine.GetGamemode()

	self.Enabled = true

	self.dt.BioLevel = 12
	self.dt.UpgradeLevel = 3
	self.dt.WeaponLevel = 3
	self.dt.ArmorLevel = 3 

	self.dt.StatusX = math.Clamp(self.Config.StatusTextPosX, 0 , 1)
	self.dt.StatusY = math.Clamp(self.Config.StatusTextPosY, 0 , 1)
	self.dt.StatusR = math.Clamp(self.Config.StatusTextColour[1], 0 , 255 )
	self.dt.StatusG = math.Clamp(self.Config.StatusTextColour[2], 0 , 255 )
	self.dt.StatusB = math.Clamp(self.Config.StatusTextColour[3], 0 , 255 )
	self.dt.StatusDelay = math.Clamp(self.Config.LimitToggleDelay, 0, 1023)

	self.Ents = {}

	--if the plugin gets enabled at a later point then the first load
	self:OnResume()

	return true
end

function Plugin:ProcessBuyAction()
	if self.dt.Enabled then return true end
end

function Plugin:CanEntDoDamageTo( _, Target )
	if not self.dt.Enabled then return end

	 if Target:isa("MAC") or Target:isa("Observatory") or Target:isa("ARC") or ( Target:isa("CommandStructure") and Target:GetIsBuilt() ) then return false end

	return true
end

local function RespawnAllDeadPlayer( Team )
	local spectators = Team:GetSortedRespawnQueue()
	for i = 1, #spectators do
		local spec = spectators[ i ]
		Team:RemovePlayerFromRespawnQueue( spec )
		local success, newAlien = Team:ReplaceRespawnPlayer( spec, nil, nil )
		if success then newAlien:SetCameraDistance( 0 ) end
	end
end

-- instantly respawns dead aliens
function Plugin:AlTeamUpdate( AlTeam )
	if self.dt.Enabled then
		RespawnAllDeadPlayer( AlTeam )
	end
end

-- instantly respawn dead marines
function Plugin:MarTeamUpdate( MarTeam )
	if self.dt.Enabled then
		RespawnAllDeadPlayer( MarTeam )
	end
end

function Plugin:AlTeamUpdateBioMassLevel( AlienTeam )
	if self.dt.Enabled then
		AlienTeam.bioMassLevel = 12
		AlienTeam.bioMassAlertLevel = 0
		AlienTeam.maxBioMassLevel = 12
		AlienTeam.bioMassFraction = 12
		return true
	end
end

-- set all evolution times to 1 second
function Plugin:SetGestationData( Embryo )
	if self.dt.Enabled then Embryo.gestationTime = 1 end
end

--prevents placing dead marines in IPs so we can do instant respawn
function Plugin:FillQueueIfFree()
	if self.dt.Enabled then return true end
end
function Plugin:AddAssistKill()
	if self.dt.Enabled then return true end
end

function Plugin:AddKill()
	if self.dt.Enabled then return true end
end

function Plugin:AddDeaths()
	if self.dt.Enabled then return true end
end

function Plugin:AddScore()
	if self.dt.Enabled then return true end
end

function Plugin:SendText()
	self.dt.StatusText = StringFormat("%s\n%s\n%s", StringFormat(self.Config.Strings.Status, self.dt.Enabled and "enabled" or "disabled"),
		self.Config.CheckLimit and StringFormat( self.Config.Strings.Limit, self.dt.Enabled and "off" or "on",
			self.dt.Enabled and "being at" or "being under", self.Config.PlayerLimit )
		or self.Config.Strings.NoLimit,	self.Config.ExtraMessageLine )
	self.dt.ShowStatus = true
end

function Plugin:DestroyEnts()
	for i = 1, #self.Ents do
		local entid = self.Ents[ i ]
		local ent = Shared.GetEntity(entid)
		if ent then 
			DestroyEntity( ent )
		end
	end

	self.Ents = {}
end
local function MakeTechEnt( techPoint, mapName, rightOffset, forwardOffset, teamType )
	local origin = techPoint:GetOrigin()
	local right = techPoint:GetCoords().xAxis
	local forward = techPoint:GetCoords().zAxis
	local position = origin + right * rightOffset + forward * forwardOffset

	local newEnt = CreateEntity( mapName, position, teamType)
	if HasMixin( newEnt, "Construct" ) then
		SetRandomOrientation( newEnt )
		newEnt:SetConstructionComplete() 
	end

	local ID = newEnt:GetId()
	table.insert( Plugin.Ents, ID )
end
local function SpawnBuildings( team )
	local teamNr = team:GetTeamNumber()
	local techPoint = team:GetInitialTechPoint()

	if team:GetTeamType() == kAlienTeamType then
		MakeTechEnt( techPoint, Crag.kMapName, 3.5, 2, teamNr )
		MakeTechEnt( techPoint, Crag.kMapName, 3.5, -2, teamNr )
		MakeTechEnt( techPoint, Shift.kMapName, -3.5, 2, teamNr )
	end
	
end
local function SpawnMac(techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
		
        spawnPoint = GetRandomBuildPosition( kTechId.MAC, techPointOrigin, kInfantryPortalAttachRange + 5 )
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    
    if spawnPoint then
    
        local pt = CreateEntity(MAC.kMapName, spawnPoint, self:GetTeamNumber())
        
        
    end
    
end
local function SpawnArc(techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
		
        spawnPoint = GetRandomBuildPosition( kTechId.ARC, techPointOrigin, kInfantryPortalAttachRange - 5)
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    
    if spawnPoint then
    
        local arc = CreateEntity(ARC.kMapName, spawnPoint, self:GetTeamNumber())
        arc:GiveOrder(kTechId.ARCDeploy, arc:GetId(), arc:GetOrigin(), nil, false, false)
        
        
    end
    
end
local function SpawnObservatory(techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
		
        spawnPoint = GetRandomBuildPosition( kTechId.Observatory, techPointOrigin, kInfantryPortalAttachRange )
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    
    if spawnPoint then
    
        local pt = CreateEntity(Observatory.kMapName, spawnPoint, self:GetTeamNumber())
        SetRandomOrientation(pt)
        pt:SetConstructionComplete()
        
    end
    
end
local function SpawnPrototypeLab(techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
		
        spawnPoint = GetRandomBuildPosition( kTechId.PrototypeLab, techPointOrigin, kInfantryPortalAttachRange + 5)
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    
    if spawnPoint then
    
        local pt = CreateEntity(PrototypeLab.kMapName, spawnPoint, self:GetTeamNumber())
        
        SetRandomOrientation(pt)
        pt:SetConstructionComplete()
        
    end
    
end
function Plugin:OnResetGame()
	self:Disable()

	self:SimpleTimer(0.1, function()
		if GetGamerules():GetGameState() == kGameState.NotStarted then
			self:Enable()
		end
	end)
end

function Plugin:Enable()
	self.dt.Enabled = true
	self:SendText()

	if self.dt.Enabled then
		local Rules = GetGamerules()
		if not Rules then return end

		Rules:SetAllTech( true )

		local Team1 = Rules:GetTeam1()
		local Team2 = Rules:GetTeam2()
		SpawnBuildings(Team1)
		SpawnBuildings(Team2)

		/*
		         for _, teleport in ientitylist(Shared.GetEntitiesWithClassname("TeleportTrigger")) do
		          if Shared.GetMapName() == "ns_darksiege" then return end
           teleport.enabled = false
          
     end
     */
			 for _, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
           frontdoor.driving = true
     end
     			 for _, sidedoor in ientitylist(Shared.GetEntitiesWithClassname("SideDoor")) do
           sidedoor.driving = true
     end
     			 for _, funcdoor in ientitylist(Shared.GetEntitiesWithClassname("FuncDoor")) do
           funcdoor.amountoftimesbroken = .9
           funcdoor.health = 0
     end
             if not Shared.GetMapName() == "ns_siegeaholic_remade" and Shared.GetMapName() ~= "ns_biosiege" and Shared.GetMapName() ~= "ns_cerbsiege" then
     	 for _, funcmoveable in ientitylist(Shared.GetEntitiesWithClassname("FuncMoveable")) do
           funcmoveable.driving = true 
     end
            end
     	 for _, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
           siegedoor.driving = true
     end
    for _, breakable in ientitylist(Shared.GetEntitiesWithClassname("LogicBreakable")) do
           breakable.driving = true
     end
	end
end

function Plugin:Disable()

	self.dt.ShowStatus = false

	--stop the ongoing countdown
	self:DestroyTimer( "Countdown" )
	self.dt.CountdownText = ""

	if not self.dt.Enabled then return end

	self:DestroyEnts()
	self.dt.Enabled = false
	
	local rules = GetGamerules()
	if not rules then return end

	rules:SetAllTech( false )
	             if not Shared.GetMapName() == "ns_siegeaholic_remade" then
		 for _, door in ientitylist(Shared.GetEntitiesWithClassname("FuncMoveable")) do
           door.driving = false
           door:Reset()
     end
          			 for _, funcdoor in ientitylist(Shared.GetEntitiesWithClassname("FuncDoor")) do
           funcdoor.amountoftimesbroken = 0
           funcdoor:Reset()
     end
             end
    for _, funcdoor in ientitylist(Shared.GetEntitiesWithClassname("FuncDoor")) do
           funcdoor:Reset()
     end
    for _, breakable in ientitylist(Shared.GetEntitiesWithClassname("LogicBreakable")) do
           breakable.driving =  false
           breakable:Reset()
     end
     
end


function Plugin:OnSuspend()
	self:Disable()
end

function Plugin:OnResume()
	if GetGamerules and GetGamerules() and GetGamerules():GetGameState() ~= kGameState.NotStarted then
		self:Enable()
	end
end

function Plugin:Cleanup()
	self:Disable()

	self.BaseClass.Cleanup( self )

	self.Enabled = false
end