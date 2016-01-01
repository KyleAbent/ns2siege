// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\NS2Gamerules.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Gamerules.lua")
Script.Load("lua/dkjson.lua")
Script.Load("lua/ServerSponitor.lua")
Script.Load("lua/PlayerRanking.lua")

if Client then
    Script.Load("lua/NS2ConsoleCommands_Client.lua")
else
    Script.Load("lua/NS2ConsoleCommands_Server.lua")
end

class 'NS2Gamerules' (Gamerules)

NS2Gamerules.kMapName = "ns2_gamerules"

kGameEndAutoConcedeCheckInterval = 0.75
kDrawGameWindow = 0.75

local kPregameLength = 3
local kTimeToReadyRoom = 8
local kPauseToSocializeBeforeMapcycle = 30
local kGameStartMessageInterval = 10

local kMaxWorldSoundDistance = 30

// How often to send the "No commander" message to players in seconds.
local kSendNoCommanderMessageRate = 50

// Find team start with team 0 or for specified team. Remove it from the list so other teams don't start there. Return nil if there are none.
function NS2Gamerules:ChooseTechPoint(techPoints, teamNumber)

    local validTechPoints = { }
    local totalTechPointWeight = 0
    
    // Build list of valid starts (marked as "neutral" or for this team in map)
    for _, currentTechPoint in pairs(techPoints) do
    
        // Always include tech points with team 0 and never include team 3 into random selection process
        local teamNum = currentTechPoint:GetTeamNumberAllowed()
        if (teamNum == 0 or teamNum == teamNumber) and teamNum ~= 3 then
        
            table.insert(validTechPoints, currentTechPoint)
            totalTechPointWeight = totalTechPointWeight + currentTechPoint:GetChooseWeight()
            
        end
        
    end
    
    local chosenTechPointWeight = self.techPointRandomizer:random(0, totalTechPointWeight)
    local chosenTechPoint = nil
    local currentWeight = 0
    for _, currentTechPoint in pairs(validTechPoints) do
    
        currentWeight = currentWeight + currentTechPoint:GetChooseWeight()
        if chosenTechPointWeight - currentWeight <= 0 then
        
            chosenTechPoint = currentTechPoint
            break
            
        end
        
    end
    
    // Remove it from the list so it isn't chosen by other team
    if chosenTechPoint ~= nil then
        table.removevalue(techPoints, chosenTechPoint)
    else
        assert(false, "ChooseTechPoint couldn't find a tech point for team " .. teamNumber)
    end
    
    return chosenTechPoint
    
end

////////////
// Server //
////////////
if Server then

    Script.Load("lua/PlayingTeam.lua")
    Script.Load("lua/ReadyRoomTeam.lua")
    Script.Load("lua/SpectatingTeam.lua")
    Script.Load("lua/GameViz.lua")
    Script.Load("lua/ObstacleMixin.lua")
   
    NS2Gamerules.SiegeMusic1 = PrecacheAsset("sound/NS2.fev/ambient/descent/club_music")
   // NS2Gamerules.SiegeMusic2 = PrecacheAsset("sound/NS2.fev/ambient/descent/docking_background_music")
//    NS2Gamerules.SiegeMusic3 = PrecacheAsset("sound/NS2.fev/music/decay")
   // NS2Gamerules.SiegeMusic4 = PrecacheAsset("sound/NS2.fev/music/main_menu")
    ///NS2Gamerules.SiegeMusic5 = PrecacheAsset("sound/NS2.fev/ambient/ns1_music")
                              
      NS2Gamerules.SuddenDeathMusic = PrecacheAsset("sound/NS2.fev/ambient/ns1_music")
     NS2Gamerules.kSiegeDoorSound = PrecacheAsset("sound/siegeroom.fev/door/siege")
     NS2Gamerules.kFrontDoorSound = PrecacheAsset("sound/siegeroom.fev/door/frontdoor")
    NS2Gamerules.kSuddenDeathSound = PrecacheAsset("sound/siegeroom.fev/door/SD")
    NS2Gamerules.kMarineStartSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/game_start")
    NS2Gamerules.kAlienStartSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/game_start")
    NS2Gamerules.kCountdownSound = PrecacheAsset("sound/NS2.fev/common/countdown")

    // Allow players to spawn in for free (not using IP or eggs) for this many seconds after the game starts
    //local kFreeSpawnTime = 60

    function NS2Gamerules:BuildTeam(teamType)

        if teamType == kAlienTeamType then
            return AlienTeam()
        end
        
        return MarineTeam()
        
    end
    
    function NS2Gamerules:ResetPlayerScores()
    
        for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            if player.ResetScores and player.client then
                player:ResetScores()
            end
        end

    end
     function NS2Gamerules:CreateFirstShiftHive()
         
        for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
           hive:UpgradeToTechId(kTechId.ShiftHive)
           local team = hive:GetTeam()
           if team then
           team:OnUpgradeChamberConstructed(hive)
           end
        end
     end
    function NS2Gamerules:SetGameState(state)
    
        if state ~= self.gameState then
        
            self.gameState = state
            self.gameInfo:SetState(state)
            self.timeGameStateChanged = Shared.GetTime()
            self.timeSinceGameStateChanged = 0
            
            local frozenState = (state == kGameState.Countdown) and (not Shared.GetDevMode())
            self.team1:SetFrozenState(frozenState)
            self.team2:SetFrozenState(frozenState)
            
            if self.gameState == kGameState.Started then    
        //   self:AddTimedCallback(NS2Gamerules.DisplayFrontDoorLocation, 30)
            MarineTeam.gSandboxMode = false
            self.playedfrontsound = false
            self.playedsiegesound = false
            self.respawnedplayers = false
            self.issuddendeath = false
            self.mainrooms = Shared.GetTime()
            self.doorsopened = false
            self.sideopened = false
            self.siegedoorsopened = false
            self.iszedtime = false
            self.lastexploitcheck = Shared.GetTime()
            self:CreateFirstShiftHive()
            self:AddTimedCallback(NS2Gamerules.CollectResources, kResourceTowerResourceInterval) 
            
       //     self:AddTimedCallback(NS2Gamerules.FrontDoor, kFrontDoorTime) 
       //     self:AddTimedCallback(NS2Gamerules.SiegeDoor, kSiegeDoorTime) 
       //      self:AddTimedCallback(NS2Gamerules.SuddenDeath, kSiegeDoorTime + kTimeAfterSiegeOpeningToEnableSuddenDeath) 
         //   self.alreadyhookeddoors = false
         //   self.alreadyhookedsiege = false
         //  self.alreadyhookedsuddendeath = false
            
              for _, moveable in ipairs(GetEntitiesWithMixin("Moveable")) do
                   if not moveable:isa("LogicBreakable") then
                   moveable.driving = false
                   moveable:Reset()
                   end
              end
                
                PostGameViz("Game started")
                self:ResetPlayerScores()
                self.gameStartTime = Shared.GetTime()
                
                self.gameInfo:SetStartTime(self.gameStartTime)
                
                SendTeamMessage(self.team1, kTeamMessageTypes.GameStarted)
                SendTeamMessage(self.team2, kTeamMessageTypes.GameStarted)
                
            end
            
            // On end game, check for map switch conditions
            if state == kGameState.Team1Won or state == kGameState.Team2Won then
                MarineTeam.gSandboxMode = true
                if MapCycle_TestCycleMap() then
                    self.timeToCycleMap = Shared.GetTime() + kPauseToSocializeBeforeMapcycle
                else
                    self.timeToCycleMap = nil
                end
                
            end
            
        end
        
    end

    function NS2Gamerules:GetGameTimeChanged()
        return self.timeSinceGameStateChanged
    end
    function NS2Gamerules:GetGameState()
        return self.gameState
    end

    function NS2Gamerules:OnCreate()

        // Calls SetGamerules()
        Gamerules.OnCreate(self)

        self.sponitor = ServerSponitor()
        self.sponitor:Initialize(self)
        
        self.playerRanking = PlayerRanking()
        
        self.techPointRandomizer = Randomizer()
        self.techPointRandomizer:randomseed(Shared.GetSystemTime())
        
        // Create team objects
        self.team1 = self:BuildTeam(kTeam1Type)
        self.team1:Initialize(kTeam1Name, kTeam1Index)
        self.sponitor:ListenToTeam(self.team1)
        
        self.team2 = self:BuildTeam(kTeam2Type)
        self.team2:Initialize(kTeam2Name, kTeam2Index)
        self.sponitor:ListenToTeam(self.team2)
        
        self.worldTeam = ReadyRoomTeam()
        self.worldTeam:Initialize("World", kTeamReadyRoom)
        
        self.spectatorTeam = SpectatingTeam()
        self.spectatorTeam:Initialize("Spectator", kSpectatorIndex)
        
        self.gameInfo = Server.CreateEntity(GameInfo.kMapName)
        
        self:SetGameState(kGameState.NotStarted)
        
        self.allTech = false
        self.orderSelf = false
        self.autobuild = false
        self.teamsReady = false
        self.tournamentMode = false
        self.doorsopened = false
        self.siegedoorsopened = false
        self.iszedtime = false
        self.alreadyhookeddoors = false
        self.alreadyhookedsiege = false
        self.alreadyhookedsuddendeath = false
        
        self:SetIsVisible(false)
        self:SetPropagate(Entity.Propagate_Never)
        
        // Track how much pres clients have when they switch a team or disconnect
        self.clientpres = {}
        
        self.justCreated = true
        self.playedfrontsound = false
        self.playedsiegesound = false
        self.respawnedplayers = false
        
    end

    function NS2Gamerules:OnDestroy()

        self.team1:Uninitialize()
        self.team1 = nil
        self.team2:Uninitialize()
        self.team2 = nil
        self.worldTeam:Uninitialize()
        self.worldTeam = nil
        self.spectatorTeam:Uninitialize()
        self.spectatorTeam = nil

        Gamerules.OnDestroy(self)

    end
    
    function NS2Gamerules:GetFriendlyFire()
        return false
    end
    
    // All damage is routed through here.
    function NS2Gamerules:CanEntityDoDamageTo(attacker, target)
        return CanEntityDoDamageTo(attacker, target, Shared.GetCheatsEnabled(), Shared.GetDevMode(), self:GetFriendlyFire())
    end
    
    function NS2Gamerules:OnClientDisconnect(client)

        local player = client:GetControllingPlayer()
        
        if player then
        
            // When a player disconnects remove them from their team
            local teamNumber = player:GetTeamNumber()
            local team = self:GetTeam(teamNumber)
            if team then
                team:RemovePlayer(player)
            end
            
            player:RemoveSpectators(nil)
            
            local clientUserId = client:GetUserId()
            if not self.clientpres[clientUserId] then self.clientpres[clientUserId] = {} end
            self.clientpres[clientUserId][teamNumber] = player:GetResources()
            
        end
        
        Gamerules.OnClientDisconnect(self, client)
        
    end
    
    function NS2Gamerules:OnEntityCreate(entity)

        self:OnEntityChange(nil, entity:GetId())

        if entity.GetTeamNumber then
        
            local team = self:GetTeam(entity:GetTeamNumber())
            
            if team then
            
                if entity:isa("Player") then
            
                    team:AddPlayer(entity)

                end
                
            end
            
        end
        
    end

    function NS2Gamerules:OnEntityDestroy(entity)
        
        self:OnEntityChange(entity:GetId(), nil)

        if entity.GetTeamNumber then
        
            local team = self:GetTeam(entity:GetTeamNumber())
            if team then
            
                if entity:isa("Player") then
                    team:RemovePlayer(entity)
                end
                
            end
            
        end
       
    end

    // Update player and entity lists
    function NS2Gamerules:OnEntityChange(oldId, newId)

        PROFILE("NS2Gamerules:OnEntityChange")
        
        if self.worldTeam then
            self.worldTeam:OnEntityChange(oldId, newId)
        end
        
        if self.team1 then
            self.team1:OnEntityChange(oldId, newId)
        end
        
        if self.team2 then
            self.team2:OnEntityChange(oldId, newId)
        end
        
        if self.spectatorTeam then
            self.spectatorTeam:OnEntityChange(oldId, newId)
        end
        
        // Keep server map entities up to date
        local index = table.find(Server.mapLoadLiveEntityValues, oldId)
        if index then
        
            table.removevalue(Server.mapLoadLiveEntityValues, oldId)
            if newId then
                table.insert(Server.mapLoadLiveEntityValues, newId)
            end
            
        end
        
        local notifyEntities = Shared.GetEntitiesWithTag("EntityChange")
        
        // Tell notifyEntities this entity has changed ids or has been deleted (changed to nil).
        for index, ent in ientitylist(notifyEntities) do
        
            if ent:GetId() ~= oldId and ent.OnEntityChange then
                ent:OnEntityChange(oldId, newId)
            end
            
        end
        
    end

    // Called whenever an entity is killed. Killer could be the same as targetEntity. Called before entity is destroyed.
    function NS2Gamerules:OnEntityKilled(targetEntity, attacker, doer, point, direction)
        
        // Also output to log if we're recording the game for playback in the game visualizer
        PostGameViz(string.format("%s killed %s", SafeClassName(doer), SafeClassName(targetEntity)), targetEntity)
        
        self.team1:OnEntityKilled(targetEntity, attacker, doer, point, direction)
        self.team2:OnEntityKilled(targetEntity, attacker, doer, point, direction)
        self.worldTeam:OnEntityKilled(targetEntity, attacker, doer, point, direction)
        self.spectatorTeam:OnEntityKilled(targetEntity, attacker, doer, point, direction)
        self.sponitor:OnEntityKilled(targetEntity, attacker, doer)

    end

    // logs out any players currently as the commander
    function NS2Gamerules:LogoutCommanders()

        for index, entity in ientitylist(Shared.GetEntitiesWithClassname("CommandStructure")) do
            entity:Logout()
        end
        
    end
     
    /**
     * Starts a new game by resetting the map and all of the players. Keep everyone on current teams (readyroom, playing teams, etc.) but 
     * respawn playing players.
     */
    function NS2Gamerules:ResetGame()
    
        TournamentModeOnReset()
    
        // save commanders for later re-login
        local team1CommanderClient = self.team1:GetCommander() and self.team1:GetCommander():GetClient()
        local team2CommanderClient = self.team2:GetCommander() and self.team2:GetCommander():GetClient()
        
        // Cleanup any peeps currently in the commander seat by logging them out
        // have to do this before we start destroying stuff.
        self:LogoutCommanders()
        
        // Destroy any map entities that are still around
        DestroyLiveMapEntities()
        
        self:SetGameState(kGameState.NotStarted)
        
        // Reset all players, delete other not map entities that were created during 
        // the game (hives, command structures, initial resource towers, etc)
        // We need to convert the EntityList to a table since we are destroying entities
        // within the EntityList here.
        for index, entity in ientitylist(Shared.GetEntitiesWithClassname("Entity")) do
        
            // Don't reset/delete NS2Gamerules or TeamInfo.
            // NOTE!!!
            // MapBlips are destroyed by their owner which has the MapBlipMixin.
            // There is a problem with how this reset code works currently. A map entity such as a Hive creates
            // it's MapBlip when it is first created. Before the entity:isa("MapBlip") condition was added, all MapBlips
            // would be destroyed on map reset including those owned by map entities. The map entity Hive would still reference
            // it's original MapBlip and this would cause problems as that MapBlip was long destroyed. The right solution
            // is to destroy ALL entities when a game ends and then recreate the map entities fresh from the map data
            // at the start of the next game, including the NS2Gamerules. This is how a map transition would have to work anyway.
            // Do not destroy any entity that has a parent. The entity will be destroyed when the parent is destroyed or
            // when the owner manually destroyes the entity.
            local shieldTypes = { "GameInfo", "MapBlip", "NS2Gamerules", "PlayerInfoEntity" }
            local allowDestruction = true
            for i = 1, #shieldTypes do
                allowDestruction = allowDestruction and not entity:isa(shieldTypes[i])
            end
            
            if allowDestruction and entity:GetParent() == nil then
            
                local isMapEntity = entity:GetIsMapEntity()
                local mapName = entity:GetMapName()
                
                // Reset all map entities and all player's that have a valid Client (not ragdolled players for example).
                local resetEntity = entity:isa("TeamInfo") or entity:GetIsMapEntity() or (entity:isa("Player") and entity:GetClient() ~= nil)
                if resetEntity then
                
                    if entity.Reset then
                        entity:Reset()
                    end
                    
                else
                    DestroyEntity(entity)
                end
                
            end       
            
        end
        
        // Clear out obstacles from the navmesh before we start repopualating the scene
        RemoveAllObstacles()
        
        // Build list of tech points
        local techPoints = EntityListToTable(Shared.GetEntitiesWithClassname("TechPoint"))
        if table.maxn(techPoints) < 2 then
            Print("Warning -- Found only %d %s entities.", table.maxn(techPoints), TechPoint.kMapName)
        end
        
        local resourcePoints = Shared.GetEntitiesWithClassname("ResourcePoint")
        if resourcePoints:GetSize() < 2 then
            Print("Warning -- Found only %d %s entities.", resourcePoints:GetSize(), ResourcePoint.kPointMapName)
        end
        
        // add obstacles for resource points back in
        for index, resourcePoint in ientitylist(resourcePoints) do        
            resourcePoint:AddToMesh()        
        end
        
        local team1TechPoint = nil
        local team2TechPoint = nil
        
        if Server.teamSpawnOverride and #Server.teamSpawnOverride > 0 then
           
            for t = 1, #techPoints do

                local techPointName = string.lower(techPoints[t]:GetLocationName())
                local selectedSpawn = Server.teamSpawnOverride[1]
                if techPointName == selectedSpawn.marineSpawn then
                    team1TechPoint = techPoints[t]
                elseif techPointName == selectedSpawn.alienSpawn then
                    team2TechPoint = techPoints[t]
                end
                
            end
            
            if not team1TechPoint or not team2TechPoint then
                Shared.Message("Invalid spawns, defaulting to normal spawns")
                if Server.spawnSelectionOverrides then
        
                    local selectedSpawn = self.techPointRandomizer:random(1, #Server.spawnSelectionOverrides)
                    selectedSpawn = Server.spawnSelectionOverrides[selectedSpawn]
                    
                    for t = 1, #techPoints do
                    
                        local techPointName = string.lower(techPoints[t]:GetLocationName())
                        if techPointName == selectedSpawn.marineSpawn then
                            team1TechPoint = techPoints[t]
                        elseif techPointName == selectedSpawn.alienSpawn then
                            team2TechPoint = techPoints[t]
                        end
                        
                    end
                        
                else
                    
                    // Reset teams (keep players on them)
                    team1TechPoint = self:ChooseTechPoint(techPoints, kTeam1Index)
                    team2TechPoint = self:ChooseTechPoint(techPoints, kTeam2Index)

                end
            
            end
            
        elseif Server.spawnSelectionOverrides then
        
            local selectedSpawn = self.techPointRandomizer:random(1, #Server.spawnSelectionOverrides)
            selectedSpawn = Server.spawnSelectionOverrides[selectedSpawn]
            
            for t = 1, #techPoints do
            
                local techPointName = string.lower(techPoints[t]:GetLocationName())
                if techPointName == selectedSpawn.marineSpawn then
                    team1TechPoint = techPoints[t]
                elseif techPointName == selectedSpawn.alienSpawn then
                    team2TechPoint = techPoints[t]
                end
                
            end
            
        else
        
            // Reset teams (keep players on them)
            team1TechPoint = self:ChooseTechPoint(techPoints, kTeam1Index)
            team2TechPoint = self:ChooseTechPoint(techPoints, kTeam2Index)

        end
        
        self.team1:ResetPreservePlayers(team1TechPoint)
        self.team2:ResetPreservePlayers(team2TechPoint)
        
        assert(self.team1:GetInitialTechPoint() ~= nil)
        assert(self.team2:GetInitialTechPoint() ~= nil)
        
        // Save data for end game stats later.
        self.startingLocationNameTeam1 = team1TechPoint:GetLocationName()
        self.startingLocationNameTeam2 = team2TechPoint:GetLocationName()
        self.startingLocationsPathDistance = GetPathDistance(team1TechPoint:GetOrigin(), team2TechPoint:GetOrigin())
        self.initialHiveTechId = nil
        
        self.worldTeam:ResetPreservePlayers(nil)
        self.spectatorTeam:ResetPreservePlayers(nil)    
        
        // Replace players with their starting classes with default loadouts at spawn locations
        self.team1:ReplaceRespawnAllPlayers()
        self.team2:ReplaceRespawnAllPlayers()
        
		self.clientpres = {}
		
        // Create team specific entities
        local commandStructure1 = self.team1:ResetTeam()
        local commandStructure2 = self.team2:ResetTeam()
        
        // login the commanders again
        local function LoginCommander(commandStructure, client)
			local player = client and client:GetControllingPlayer()
            if commandStructure and player then
				// make up for not manually moving to CS and using it
				commandStructure.occupied = true
				player:SetOrigin(commandStructure:GetDefaultEntryOrigin())
				commandStructure:LoginPlayer(player,true)
            end
        end
        
        LoginCommander(commandStructure1, team1CommanderClient)
        LoginCommander(commandStructure2, team2CommanderClient)
        
        // Create living map entities fresh
        CreateLiveMapEntities()
        
        self.forceGameStart = false
        self.preventGameEnd = nil
        // Reset banned players for new game
        self.bannedPlayers = {}
        
        // Send scoreboard and tech node update, ignoring other scoreboard updates (clearscores resets everything)
        for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            Server.SendCommand(player, "onresetgame")
            player.sendTechTreeBase = true
        end
        
        self.team1:OnResetComplete()
        self.team2:OnResetComplete()
        
    end
    
    function NS2Gamerules:GetTeam1()
        return self.team1
    end
    
    function NS2Gamerules:GetTeam2()
        return self.team2
    end
    
    function NS2Gamerules:GetWorldTeam()
        return self.worldTeam
    end
    
    function NS2Gamerules:GetSpectatorTeam()
        return self.spectatorTeam
    end
    
    function NS2Gamerules:GetTeams()
        return { self.team1, self.team2, self.worldTeam, self.spectatorTeam }
    end
    
    /**
     * Should be called when the Hive type is chosen.
     */
    function NS2Gamerules:SetHiveTechIdChosen(hive, techId)
    
        if self.initialHiveTechId == nil then
            self.initialHiveTechId = techId
        end
        
    end

    // Batch together string with pings of every player to update scoreboard. This is a separate
    // command to keep network utilization down.
    function NS2Gamerules:UpdatePings()
    
        local now = Shared.GetTime()
        
        // Check if the individual player's should be sent their own ping.
        if self.timeToSendIndividualPings == nil or now >= self.timeToSendIndividualPings then
        
            for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                Server.SendNetworkMessage(player, "Ping", BuildPingMessage(player:GetClientIndex(), player:GetPing()), false)
            end
            
            self.timeToSendIndividualPings =  now + kUpdatePingsIndividual
            
        end
        
        // Check if all player's pings should be sent to everybody.
        if self.timeToSendAllPings == nil or  now >= self.timeToSendAllPings then
        
            for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                Server.SendNetworkMessage("Ping", BuildPingMessage(player:GetClientIndex(), player:GetPing()), false)
            end
            
            self.timeToSendAllPings =  now + kUpdatePingsAll
            
        end
        
    end
    
    // Sends player health to all spectators
    function NS2Gamerules:UpdateHealth()
    
        if self.timeToSendHealth == nil or Shared.GetTime() > self.timeToSendHealth then
        
            local spectators = Shared.GetEntitiesWithClassname("Spectator")
            if spectators:GetSize() > 0 then
            
                // Send spectator all health
                for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                
                    for index, spectator in ientitylist(spectators) do
                    
                        if not spectator:GetIsFirstPerson() then
                            Server.SendNetworkMessage(spectator, "Health", BuildHealthMessage(player), false)
                        end
                        
                    end
                    
                end
            
            end
            self.timeToSendHealth = Shared.GetTime() + 0.25
            
        end
        
    end
    
    // Send Tech Point info to all spectators
    function NS2Gamerules:UpdateTechPoints()
    
        if self.timeToSendTechPoints == nil or Shared.GetTime() > self.timeToSendTechPoints then
        
            local spectators = Shared.GetEntitiesWithClassname("Spectator")
            if spectators:GetSize() > 0 then
                
                local powerNodes = Shared.GetEntitiesWithClassname("PowerPoint")
                local eggs = Shared.GetEntitiesWithClassname("Egg")
                
                for _, techpoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
                
                    local message = BuildTechPointsMessage(techpoint, powerNodes, eggs)
                    for _, spectator in ientitylist(spectators) do
                    
                        if not spectator:GetIsFirstPerson() then
                            Server.SendNetworkMessage(spectator, "TechPoints", message, false)
                        end
                        
                    end
                    
                end
            
            end
            
            self.timeToSendTechPoints = Shared.GetTime() + 0.5
            
        end
        
    end
        
    function VotingConcedeVoteAllowed()
        local gameRules = GetGamerules()
        return gameRules:GetGameStarted() and Shared.GetTime() - gameRules:GetGameStartTime() > kMinTimeBeforeConcede
    end
    
    // Commander ejection functionality
    function NS2Gamerules:CastVoteByPlayer(voteTechId, player)
    
        if voteTechId == kTechId.VoteConcedeRound then
        
            if VotingConcedeVoteAllowed() then
            
                local team = player:GetTeam()
                if team.VoteToGiveUp then
                    team:VoteToGiveUp(player)
                end
                
            end
        
        elseif voteTechId == kTechId.VoteDownCommander1 or voteTechId == kTechId.VoteDownCommander2 or voteTechId == kTechId.VoteDownCommander3 then

            // Get the 1st, 2nd or 3rd commander by entity order (does this on client as well)    
            local playerIndex = (voteTechId - kTechId.VoteDownCommander1 + 1)        
            local commanders = GetEntitiesForTeam("Commander", player:GetTeamNumber())
            
            if playerIndex <= table.count(commanders) then
            
                local targetCommander = commanders[playerIndex]
                local team = player:GetTeam()
                
                if player and team.VoteToEjectCommander then
                    team:VoteToEjectCommander(player, targetCommander)
                end
                
            end
            
        end
        
    end

    function NS2Gamerules:OnMapPostLoad()

        Gamerules.OnMapPostLoad(self)
        
        // Now allow script actors to hook post load
        local allScriptActors = Shared.GetEntitiesWithClassname("ScriptActor")
        for index, scriptActor in ientitylist(allScriptActors) do
            scriptActor:OnMapPostLoad()
        end
        
    end

    function NS2Gamerules:UpdateToReadyRoom()

        local state = self:GetGameState()
        if(state == kGameState.Team1Won or state == kGameState.Team2Won or state == kGameState.Draw) then
        
            if self.timeSinceGameStateChanged >= kTimeToReadyRoom then
            
                // Force the commanders to logout before we spawn people
                // in the ready room
                self:LogoutCommanders()
        
                // Set all players to ready room team
                local function SetReadyRoomTeam(player)
                    player:SetCameraDistance(0)
                    self:JoinTeam(player, kTeamReadyRoom)
                end
                Server.ForAllPlayers(SetReadyRoomTeam)

                // Spawn them there and reset teams
                self:ResetGame()

            end
            
        end
        
    end
    
    function NS2Gamerules:UpdateMapCycle()
    
        if not Server.GetIsGatherReady() then
    
            if self.timeToCycleMap ~= nil and Shared.GetTime() >= self.timeToCycleMap then

                MapCycle_CycleMap()               
                self.timeToCycleMap = nil
                
            end
        
        end
        
    end
    
    // Network variable type time has a maximum value it can contain, so reload the map if
    // the age exceeds the limit and no game is going on.
    local kMaxServerAgeBeforeMapChange = 36000
    local function ServerAgeCheck(self)
    
        if self.gameState ~= kGameState.Started and Shared.GetTime() > kMaxServerAgeBeforeMapChange then
            MapCycle_ChangeMap(Shared.GetMapName())
        end
        
    end
    /*
    local function UpdateAutoTeamBalance(self, dt)
    
        local wasDisabled = false
        
        // Check if auto-team balance should be enabled or disabled.
        local autoTeamBalance = Server.GetConfigSetting("auto_team_balance")
        local autoTeamBalance = not Shared.GetCheatsEnabled() and Server.GetConfigSetting("auto_team_balance")
        if autoTeamBalance and autoTeamBalance.enabled then
        
            local enabledOnUnbalanceAmount = autoTeamBalance.enabled_on_unbalance_amount or 2
            // Prevent the unbalance amount from being 0 or less.
            enabledOnUnbalanceAmount = enabledOnUnbalanceAmount > 0 and enabledOnUnbalanceAmount or 2
            local enabledAfterSeconds = autoTeamBalance.enabled_after_seconds or 10
            
            local team1Players = self.team1:GetNumPlayers()
            local team2Players = self.team2:GetNumPlayers()
            
            local unbalancedAmount = math.abs(team1Players - team2Players)
            if unbalancedAmount >= enabledOnUnbalanceAmount then
            
                if not self.autoTeamBalanceEnabled then
                
                    self.teamsUnbalancedTime = self.teamsUnbalancedTime or 0
                    self.teamsUnbalancedTime = self.teamsUnbalancedTime + dt
                    
                    if self.teamsUnbalancedTime >= enabledAfterSeconds then
                    
                        self.autoTeamBalanceEnabled = true
                        if team1Players > team2Players then
                            self.team1:SetAutoTeamBalanceEnabled(true, unbalancedAmount)
                        else
                            self.team2:SetAutoTeamBalanceEnabled(true, unbalancedAmount)
                        end
                        
                        SendTeamMessage(self.team1, kTeamMessageTypes.TeamsUnbalanced)
                        SendTeamMessage(self.team2, kTeamMessageTypes.TeamsUnbalanced)
                        Print("Auto-team balance enabled")
                        

                        
                    end
                    
                end
                
            // The autobalance system itself has turned itself off.
            elseif self.autoTeamBalanceEnabled then
                wasDisabled = true
            end
            
        // The autobalance system was turned off by the admin.
        elseif self.autoTeamBalanceEnabled then
            wasDisabled = true
        end
        
        if wasDisabled then
        
            self.team1:SetAutoTeamBalanceEnabled(false)
            self.team2:SetAutoTeamBalanceEnabled(false)
            self.teamsUnbalancedTime = 0
            self.autoTeamBalanceEnabled = false
            SendTeamMessage(self.team1, kTeamMessageTypes.TeamsBalanced)
            SendTeamMessage(self.team2, kTeamMessageTypes.TeamsBalanced)
            Print("Auto-team balance disabled")
            

            
        end
        
    end
    */
    local function CheckForNoCommander(self, onTeam, commanderType)

        self.noCommanderStartTime = self.noCommanderStartTime or { }
        
        if not self:GetGameStarted() then
            self.noCommanderStartTime[commanderType] = nil
        else
        
            local commanderExists = Shared.GetEntitiesWithClassname(commanderType):GetSize() ~= 0
            
            if commanderExists then
                self.noCommanderStartTime[commanderType] = nil
            elseif not self.noCommanderStartTime[commanderType] then
                self.noCommanderStartTime[commanderType] = Shared.GetTime()
            elseif Shared.GetTime() - self.noCommanderStartTime[commanderType] >= kSendNoCommanderMessageRate then
            
                self.noCommanderStartTime[commanderType] = nil
                SendTeamMessage(onTeam, kTeamMessageTypes.NoCommander)
                
            end
            
        end
        
    end
    
    local function KillEnemiesNearCommandStructureInPreGame(self, timePassed)
    
        if self:GetGameState() == kGameState.NotStarted then
        
            local commandStations = Shared.GetEntitiesWithClassname("CommandStructure")
            for _, ent in ientitylist(commandStations) do
            
                local enemyPlayers = GetEntitiesForTeam("Player", GetEnemyTeamNumber(ent:GetTeamNumber()))
                for e = 1, #enemyPlayers do
                
                    local enemy = enemyPlayers[e]
                    if enemy:GetDistance(ent) <= 5 then
                        enemy:TakeDamage(25 * timePassed, nil, nil, nil, nil, 0, 25 * timePassed, kDamageType.Normal)
                    end
                    
                end
                
            end
            
        end
        
    end
    
    local function RemoveTag(tagName)
        local tags = { }
        Server.GetTags(tags)

        for t = 1, #tags do

            if string.find(tags[t], tagName) then
                Server.RemoveTag(tags[t])
            end

        end

    end

    local function UpdateTag(tagName, value)

        RemoveTag(tagName)
        Server.AddTag(string.format("%s%s", tagName, value))

    end
    function NS2Gamerules:SetRookieMode(state)
        self.rookieMode = state

        if state then
            Server.AddTag("rookie_only")
        else
            RemoveTag("rookie_only")
        end
    end

    function NS2Gamerules:GetRookieMode()
        return self.rookieMode
    end
    
    function NS2Gamerules:UpdatePlayerSkill()
        
        local kTime = Shared.GetTime()
        if not self.nextTimeUpdatePlayerSkill or kTime > self.nextTimeUpdatePlayerSkill then

            self.nextTimeUpdatePlayerSkill = kTime + 10

            local averageSkill = self.playerRanking:GetAveragePlayerSkill()
            UpdateTag("P_S", math.floor(averageSkill))

            self.gameInfo:SetAveragePlayerSkill(averageSkill)

        end

        self.playerRanking:OnUpdate()

    end

    function NS2Gamerules:UpdateNumPlayersForScoreboard()
        
        local kTime = Shared.GetTime()
        if not self.nextTimeUpdateNumPlayersForScoreboard or self.nextTimeUpdateNumPlayersForScoreboard < kTime then
            
            local numPlayersTotal = Server.GetNumPlayersTotal and Server.GetNumPlayersTotal() or 0
            
            self.gameInfo:SetNumPlayersTotal( numPlayersTotal )
                
            self.nextTimeUpdateNumPlayersForScoreboard = kTime + 0.25
        end

    end

    local kTickCount = 0
    local kTickTimeSum = 0
    function NS2Gamerules:UpdatePerfTags(timePassed)

        UpdateTag("tickrate_", math.floor(Server.GetFrameRate()))

        kTickCount = kTickCount + 1
        kTickTimeSum = kTickTimeSum + timePassed

        local kTime = Shared.GetTime()
        if not self.nextServerTickrateUpdate or self.nextServerTickrateUpdate < kTime then

            kNextServerTickrateUpdate = Shared.GetTime() + 10
            kTickCount = kTickCount / kTickTimeSum
            kTickTimeSum = 1
            --round it
            local avgTickrate = string.format("%.0f", kTickCount)
            UpdateTag("ServerTickrate", avgTickrate)
            
            self.nextServerTickrateUpdate = kTime + 10
        end

    end
    
    function NS2Gamerules:UpdateCustomNetworkSettings()

        local kTime = Shared.GetTime()
        if not self.nextTimeUpdateCustomNetworkSettings or self.nextTimeCustomNetworkSettings < kTime then
            if  Server.GetSendrate() ~= 20 or Server.GetTickrate() ~= 30 or Shared.GetSettingsVariable( "mr" ) ~= "30.000000" or Shared.GetSettingsVariable("interp") ~= "0.100000" then
                UpdateTag("custom_network_settings", "")
            else 
                RemoveTag("custom_network_settings")
            end
            self.nextTimeUpdateNetworkSettingsModded = kTime + 10
        end

    end
    
function NS2Gamerules:OnUpdate(timePassed)
    
        PROFILE("NS2Gamerules:OnUpdate")
        
        GetEffectManager():OnUpdate(timePassed)
        
        if Server then
        
        /*
        local NowToFront = kFrontDoorTime - (Shared.GetTime() - GetGamerules():GetGameStartTime())
        local FrontLength =  math.ceil( Shared.GetTime() + NowToFront - Shared.GetTime() )
        SendTeamMessage(self.team1,  text = "Front Door Opens in %s"..FrontLength)
        SendTeamMessage(self.team2, text = "Front Door Opens in %s"..FrontLength)                     
*/
    
        //Siege Front & Siege Doors
         if self:GetGameStarted() and not self.siegedoorsopened and not Shared.GetCheatsEnabled() and (self.lastexploitcheck + 10) > Shared.GetTime()  then
         self.lastexploitcheck = Shared.GetTime()
        // self.siegedoorsopened = true  
     //  if not self.alreadyhookedsiege then self:HookSiegeOpen() self.alreadyhookesiege = true end
          for _, entity in ipairs(GetEntitiesWithMixin("Live")) do
               if not entity:isa("PowerPoint") and not entity:isa("Player") and entity.GetLocationName then
                   if string.find(entity:GetLocationName(), "siege") or string.find(entity:GetLocationName(), "Siege") then
                        if ( HasMixin(entity, "Construct") and entity:GetIsBuilt() )
                        or entity:isa("Cyst") or entity:isa("MAC") or entity:isa("Drifter") or entity:isa("ARC") or entity:isa("Egg") or entity:isa("Contamination") or entity:isa("Egg") or entity:isa("Hive")              
                        then
                        entity:GetTeam():AddTeamResources(LookupTechData(entity:GetTechId(), kTechDataCostKey))
                        DestroyEntity(entity)
                        end //
                   end  //
               end  //
           end // 
         end  //
      
            if self.justCreated then
            
                if not self.gameStarted then
                    self:ResetGame()
                end
                
                self.justCreated = false
                
            end
            
            if self:GetMapLoaded() then
            
                self:CheckGameStart()
                self:CheckGameEnd()
                
                self:UpdatePregame(timePassed)
                self:UpdateToReadyRoom()
                self:UpdateMapCycle()
                ServerAgeCheck(self)
                //UpdateAutoTeamBalance(self, timePassed)
                
                self.timeSinceGameStateChanged = self.timeSinceGameStateChanged + timePassed
                
                self.worldTeam:Update(timePassed)
                self.team1:Update(timePassed)
                self.team2:Update(timePassed)
                self.spectatorTeam:Update(timePassed)
                
                self:UpdatePings()
                self:UpdateHealth()
                self:UpdateTechPoints()
                
                CheckForNoCommander(self, self.team1, "MarineCommander")
                CheckForNoCommander(self, self.team2, "AlienCommander")
                KillEnemiesNearCommandStructureInPreGame(self, timePassed)
                
                self:UpdatePlayerSkill()
                self:UpdateNumPlayersForScoreboard()
                self:UpdatePerfTags(timePassed)
                self:UpdateCustomNetworkSettings()
                
            end

            self.sponitor:Update(timePassed)
            self.gameInfo:SetIsGatherReady(Server.GetIsGatherReady())
            
        end
        
    end
            
    
    /**
     * Ends the current game
     */
    function NS2Gamerules:EndGame(winningTeam)
    
        if self:GetGameState() == kGameState.Started then        
        
            
            local winningTeamType = winningTeam and winningTeam.GetTeamType and winningTeam:GetTeamType() or kNeutralTeamType
            
            if winningTeamType == kMarineTeamType then

                self:SetGameState(kGameState.Team1Won)
                PostGameViz("Marines Win!")
                
            elseif winningTeamType == kAlienTeamType then

                self:SetGameState(kGameState.Team2Won)
                PostGameViz("Aliens Win!")

            else

                self:SetGameState(kGameState.Draw)
                PostGameViz("Draw Game!")

            end
            
            Server.SendNetworkMessage( "GameEnd", { win = winningTeamType }, true)
            
            self.team1:ClearRespawnQueue()
            self.team2:ClearRespawnQueue()

            // Clear out Draw Game window handling
            self.team1Lost = nil
            self.team2Lost = nil
            self.timeDrawWindowEnds = nil
            
            // Automatically end any performance logging when the round has ended.
            Shared.ConsoleCommand("p_endlog")

            if winningTeam then
                self.sponitor:OnEndMatch(winningTeam)
                self.playerRanking:EndGame(winningTeam)
            end
            TournamentModeOnGameEnd()

        end
        
    end
    
    function NS2Gamerules:OnTournamentModeEnabled()
        self.tournamentMode = true
        self.sponitor.tournamentMode = true
    end
    
    function NS2Gamerules:OnTournamentModeDisabled()
        self.tournamentMode = false
        self.sponitor.tournamentMode = false
    end
    
    function NS2Gamerules:DrawGame()

        self:EndGame()
        
    end

    function NS2Gamerules:GetTeam(teamNum)

        local team = nil    
        if(teamNum == kTeamReadyRoom) then
            team = self.worldTeam
        elseif(teamNum == kTeam1Index) then
            team = self.team1
        elseif(teamNum == kTeam2Index) then
            team = self.team2
        elseif(teamNum == kSpectatorIndex) then
            team = self.spectatorTeam
        end
        return team
        
    end

    function NS2Gamerules:GetRandomTeamNumber()

        // Return lesser of two teams, or random one if they are the same
        local team1Players = self.team1:GetNumPlayers()
        local team2Players = self.team2:GetNumPlayers()
        
        if team1Players < team2Players then
            return self.team1:GetTeamNumber()
        elseif team2Players < team1Players then
            return self.team2:GetTeamNumber()
        end
        
        return ConditionalValue(math.random() < .5, kTeam1Index, kTeam2Index)
        
    end
    
    --list of users that played the tutorial
    local playedTutorial = {}

    -- No enforced balanced teams on join as the auto team balance system balances teams.
    function NS2Gamerules:GetCanJoinTeamNumber(player, teamNumber)

        local forceEvenTeams = Server.GetConfigSetting("force_even_teams_on_join")
        -- This option was added after shipping, so support older config files that don't include it.
        -- Fallback to forcing even teams if they don't have this entry in the config file.
        if not (forceEvenTeams == false) then
        
            local team1Players = self.team1:GetNumPlayers()
            local team2Players = self.team2:GetNumPlayers()
            
            if (team1Players > team2Players) and (teamNumber == self.team1:GetTeamNumber()) then
                return false, 0
            elseif (team2Players > team1Players) and (teamNumber == self.team2:GetTeamNumber()) then
                return false, 0
            end
            
        elseif not self:GetRookieMode() and not playedTutorial[player:GetSteamId()] and
                player:GetPlayerSkill() ~= -1 and player:GetPlayerSkill() < 1 then
            return false, 1
        end
        
        return true
        
    end

    local function OnReceivedTutorialPlayed(client)
        playedTutorial[client:GetUserId()] = true
    end
    
    Server.HookNetworkMessage("PlayedTutorial", OnReceivedTutorialPlayed)
    
    function NS2Gamerules:GetCanSpawnImmediately()
        return not self:GetGameStarted() or Shared.GetCheatsEnabled() or (Shared.GetTime() < (self.gameStartTime + kFrontDoorTime )) //kFreeSpawnTime)) Siege experiment (exploitable???)
    end
    
    /**
     * Returns two return codes: success and the player on the new team. This player could be a new
     * player (the default respawn type for that team) or it will be the original player if the team 
     * wasn't changed (false, original player returned). Pass force = true to make player change team 
     * no matter what and to respawn immediately.
     */
    function NS2Gamerules:JoinTeam(player, newTeamNumber, force)
        
        local client = Server.GetOwner(player)
        if not client then return end
        player:SetCameraDistance(0)
        
        local success = false
        local oldPlayerWasSpectating = client and client:GetSpectatingPlayer()
        local oldTeamNumber = player:GetTeamNumber()
        
        // Join new team
        if oldTeamNumber ~= newTeamNumber or force then        
            
            if player:isa("Commander") then
                OnCommanderLogOut(player)
            end        
            
            if not Shared.GetCheatsEnabled() and self:GetGameStarted() and newTeamNumber ~= kTeamReadyRoom then
                player.spawnBlockTime = Shared.GetTime() + kSuicideDelay
            end
        
            local team = self:GetTeam(newTeamNumber)
            local oldTeam = self:GetTeam(oldTeamNumber)
            
            // Remove the player from the old queue if they happen to be in one
            if oldTeam then
                oldTeam:RemovePlayerFromRespawnQueue(player)
            end
            
            // Spawn immediately if going to ready room, game hasn't started, cheats on, or game started recently
            if newTeamNumber == kTeamReadyRoom or self:GetCanSpawnImmediately() or force then
            
                success, newPlayer = team:ReplaceRespawnPlayer(player, nil, nil)
                
                local teamTechPoint = team.GetInitialTechPoint and team:GetInitialTechPoint()
                if teamTechPoint then
                    newPlayer:OnInitialSpawn(teamTechPoint:GetOrigin())
                end
                
            else
            
                // Destroy the existing player and create a spectator in their place.
                newPlayer = player:Replace(team:GetSpectatorMapName(), newTeamNumber)
                
                // Queue up the spectator for respawn.
                team:PutPlayerInRespawnQueue(newPlayer)
                
                success = true
                
            end
            
            local clientUserId = client:GetUserId()
            //Save old pres 
            if oldTeam == self.team1 or oldTeam == self.team2 then
                if not self.clientpres[clientUserId] then self.clientpres[clientUserId] = {} end
                self.clientpres[clientUserId][oldTeamNumber] = player:GetResources()
            end
            
            // Update frozen state of player based on the game state and player team.
            if team == self.team1 or team == self.team2 then
            
                local devMode = Shared.GetDevMode()
                local inCountdown = self:GetGameState() == kGameState.Countdown
                if not devMode and inCountdown then
                    newPlayer.frozen = true
                end
                
                local pres = self.clientpres[clientUserId] and self.clientpres[clientUserId][newTeamNumber]
                newPlayer:SetResources( pres or ConditionalValue(team == self.team1, kMarineInitialIndivRes, kAlienInitialIndivRes) )
            
            else
            
                // Ready room or spectator players should never be frozen
                newPlayer.frozen = false
                
            end
            
            
            newPlayer:TriggerEffects("join_team")
            
            if success then
                
                self.sponitor:OnJoinTeam(newPlayer, team)
                
                local newPlayerClient = Server.GetOwner(newPlayer)
                if oldPlayerWasSpectating then
                    newPlayerClient:SetSpectatingPlayer(nil)
                end
                
                if newPlayer.OnJoinTeam then
                    newPlayer:OnJoinTeam()
                end    
                
                if newTeamNumber == kTeam1Index or newTeamNumber == kTeam2Index then
                    newPlayer:SetEntranceTime()
                elseif newPlayer:GetEntranceTime() then
                    newPlayer:SetExitTime()
                end
                
                Server.SendNetworkMessage(newPlayerClient, "SetClientTeamNumber", { teamNumber = newPlayer:GetTeamNumber() }, true)
                
                if newTeamNumber == kSpectatorIndex then
                    newPlayer:SetSpectatorMode(kSpectatorMode.Overhead)
                end
                
            end

            return success, newPlayer
            
        end
        
        // Return old player
        return success, player
        
    end
    
    /* For test framework only. Prevents game from ending on its own also. */
    function NS2Gamerules:SetGameStarted()

        self:SetGameState(kGameState.Started)
        self.preventGameEnd = true
        
    end

    function NS2Gamerules:SetPreventGameEnd(state)
        self.preventGameEnd = state
    end
    
    function NS2Gamerules:SetTeamsReady(ready)
    
        self.teamsReady = ready
        
        // unstart the game without tracking statistics
        if self.tournamentMode and not ready and self:GetGameStarted() then
            self:ResetGame()
        end
        
    end
    
    function NS2Gamerules:SetPaused()    
    end
    
    function NS2Gamerules:DisablePause()
    end
    
    function NS2Gamerules:CheckGameStart()
    
        if self:GetGameState() == kGameState.NotStarted or self:GetGameState() == kGameState.PreGame then
        
            // Start pre-game when both teams have commanders or when once side does if cheats are enabled
            local team1Commander = self.team1:GetCommander()
            local team2Commander = self.team2:GetCommander()
            
            if ((team1Commander and team2Commander) or Shared.GetCheatsEnabled()) and (not self.tournamentMode or self.teamsReady) then
            
                if self:GetGameState() == kGameState.NotStarted then
                    self:SetGameState(kGameState.PreGame)
                end
                
            else
            
                if self:GetGameState() == kGameState.PreGame then
                    self:SetGameState(kGameState.NotStarted)
                end
                
                if (not team1Commander or not team2Commander) and not self.nextGameStartMessageTime or Shared.GetTime() > self.nextGameStartMessageTime then
                
                    SendTeamMessage(self.team1, kTeamMessageTypes.GameStartCommanders)
                    SendTeamMessage(self.team2, kTeamMessageTypes.GameStartCommanders)
                    self.nextGameStartMessageTime = Shared.GetTime() + kGameStartMessageInterval
                    
                end
                
            end
            
        end
        
    end
    
    local function CheckAutoConcede(self)

        PROFILE("NS2Gamerules:CheckAutoConcede")
                
        // This is an optional end condition based on the teams being unbalanced.
        local endGameOnUnbalancedAmount = Server.GetConfigSetting("end_round_on_team_unbalance")
        if endGameOnUnbalancedAmount and endGameOnUnbalancedAmount > 0 then

            local gameLength = Shared.GetTime() - self:GetGameStartTime()
            // Don't start checking for auto-concede until the game has started for some time.
            local checkAutoConcedeAfterTime = Server.GetConfigSetting("end_round_on_team_unbalance_check_after_time") or 300
            if gameLength > checkAutoConcedeAfterTime then

                local team1Players = self.team1:GetNumPlayers()
                local team2Players = self.team2:GetNumPlayers()
                local totalCount = team1Players + team2Players
                // Don't consider unbalanced game end until enough people are playing.

                if totalCount > 6 then
                
                    local team1ShouldLose = false
                    local team2ShouldLose = false
                    
                    if (1 - (team1Players / team2Players)) >= endGameOnUnbalancedAmount then

                        team1ShouldLose = true
                    elseif (1 - (team2Players / team1Players)) >= endGameOnUnbalancedAmount then

                        team2ShouldLose = true
                    end
                    
                    if team1ShouldLose or team2ShouldLose then
                    
                        // Send a warning before ending the game.
                        local warningTime = Server.GetConfigSetting("end_round_on_team_unbalance_after_warning_time") or 30
                        if self.sentAutoConcedeWarningAtTime and Shared.GetTime() - self.sentAutoConcedeWarningAtTime >= warningTime then
                            return team1ShouldLose, team2ShouldLose
                        elseif not self.sentAutoConcedeWarningAtTime then
                        
                            Shared.Message((team1ShouldLose and "Marine" or "Alien") .. " team auto-concede in " .. warningTime .. " seconds")
                            Server.SendNetworkMessage("AutoConcedeWarning", { time = warningTime, team1Conceding = team1ShouldLose }, true)
                            self.sentAutoConcedeWarningAtTime = Shared.GetTime()
                            
                        end
                        
                    else
                        self.sentAutoConcedeWarningAtTime = nil
                    end
                    
                end
                
            else
                self.sentAutoConcedeWarningAtTime = nil
            end
            
        end
        
        return false, false
        
    end
    
    function NS2Gamerules:CheckGameEnd()

        PROFILE("NS2Gamerules:CheckGameEnd")
        
        if self:GetGameStarted() and self.timeGameEnded == nil and not Shared.GetCheatsEnabled() and not self.preventGameEnd then

            local time = Shared.GetTime()
            if not self.timeDrawWindowEnds or time < self.timeDrawWindowEnds then

                local team1Lost = self.team1Lost or self.team1:GetHasTeamLost()
                local team2Lost = self.team2Lost or self.team2:GetHasTeamLost()

                if team1Lost or team2Lost then
            
                    -- After a team has entered a loss condition, they can not recover
                    self.team1Lost = team1Lost
                    self.team2Lost = team2Lost

                    -- Continue checking for a draw for kDrawGameWindow seconds
                    if not self.timeDrawWindowEnds then
                        self.timeDrawWindowEnds = time + kDrawGameWindow
                    end
                    
                else
                    -- Check for auto-concede if neither team lost.
                    if not self.timeNextAutoConcedeCheck or self.timeNextAutoConcedeCheck < time then
                        
                        team1Lost, team2Lost = CheckAutoConcede(self)
                        if team2Lost then
                            self:EndGame( self.team1 )
                        elseif team1Lost then
                            self:EndGame( self.team2 )
                        end
                        
                        self.timeNextAutoConcedeCheck = time + kGameEndAutoConcedeCheckInterval
                    end
                    
                end

            else

                if self.team2Lost and self.team1Lost then
                    
                    -- It's a draw
                    self:DrawGame()
                    
                elseif self.team2Lost then

                    -- Still no draw after kDrawGameWindow, count the win
                    self:EndGame( self.team1 )

                elseif self.team1Lost then

                    -- Still no draw after kDrawGameWindow, count the win
                    self:EndGame( self.team2 )
                    
                end

            end

        end

    end

    function NS2Gamerules:GetCountingDown()
        return self:GetGameState() == kGameState.Countdown
    end
    
    local function StartCountdown(self)
    
        self:ResetGame()
        
        self:SetGameState(kGameState.Countdown)
        self.countdownTime = kCountDownLength
        
        self.lastCountdownPlayed = nil
        
    end
    
    function NS2Gamerules:GetPregameLength()
    
        local preGameTime = kPregameLength
        if Shared.GetCheatsEnabled() then
            preGameTime = 0
        end
        
        return preGameTime
        
    end
    
    function NS2Gamerules:UpdatePregame(timePassed)

        if self:GetGameState() == kGameState.PreGame then
        
            local preGameTime = self:GetPregameLength()
            
            if self.timeSinceGameStateChanged > preGameTime then
            
                StartCountdown(self)
                if Shared.GetCheatsEnabled() then
                    self.countdownTime = 1
                end
                
            end
            
        elseif self:GetGameState() == kGameState.Countdown then
        
            self.countdownTime = self.countdownTime - timePassed
            
            // Play count down sounds for last few seconds of count-down
            local countDownSeconds = math.ceil(self.countdownTime)
            if self.lastCountdownPlayed ~= countDownSeconds and (countDownSeconds < 4) then
            
                self.worldTeam:PlayPrivateTeamSound(NS2Gamerules.kCountdownSound)
                self.team1:PlayPrivateTeamSound(NS2Gamerules.kCountdownSound)
                self.team2:PlayPrivateTeamSound(NS2Gamerules.kCountdownSound)
                self.spectatorTeam:PlayPrivateTeamSound(NS2Gamerules.kCountdownSound)
                
                self.lastCountdownPlayed = countDownSeconds
                
            end
            
            if self.countdownTime <= 0 then
            
                self.team1:PlayPrivateTeamSound(ConditionalValue(self.team1:GetTeamType() == kAlienTeamType, NS2Gamerules.kAlienStartSound, NS2Gamerules.kMarineStartSound))
                self.team2:PlayPrivateTeamSound(ConditionalValue(self.team2:GetTeamType() == kAlienTeamType, NS2Gamerules.kAlienStartSound, NS2Gamerules.kMarineStartSound))
                
                self:SetGameState(kGameState.Started)
                self.sponitor:OnStartMatch()
                self.playerRanking:StartGame()
                
            end
            
        end
        
    end

    function NS2Gamerules:GetAllTech()
        return self.allTech
    end

    function NS2Gamerules:SetAllTech(state)

        if state ~= self.allTech then
        
            self.allTech = state
            
            self.team1:GetTechTree():SetTechChanged()
            self.team2:GetTechTree():SetTechChanged()
            
        end
        
    end

    function NS2Gamerules:GetAutobuild()
        return self.autobuild
    end

    function NS2Gamerules:SetAutobuild(state)
        self.autobuild = state
    end

    function NS2Gamerules:SetOrderSelf(state)
        self.orderSelf = state
    end

    function NS2Gamerules:GetOrderSelf()
        return self.orderSelf
    end

    function NS2Gamerules:GetIsPlayerFollowingTeamNumber(player, teamNumber)

        local following = false
        
        if player:isa("Spectator") then
        
            local playerId = player:GetFollowingPlayerId()
            
            if playerId ~= Entity.invalidId then
            
                local followedPlayer = Shared.GetEntity(playerId)
                
                if followedPlayer and followedPlayer:GetTeamNumber() == teamNumber then
                
                    following = true
                    
                end
                
            end

        end
        
        return following

    end

    // Function for allowing teams to hear each other's voice chat
    function NS2Gamerules:GetCanPlayerHearPlayer(listenerPlayer, speakerPlayer, channelType)

        local canHear = false
        
        if Server.GetConfigSetting("alltalk") or Server.GetConfigSetting("pregamealltalk") and not self:GetGameStarted() then
            return true
        end
        
        // Check if the listerner has the speaker muted.
        if listenerPlayer:GetClientMuted(speakerPlayer:GetClientIndex()) then
            return false
        end
        
        // If both players have the same team number, they can hear each other
        if(listenerPlayer:GetTeamNumber() == speakerPlayer:GetTeamNumber()) then
            if channelType == nil or channelType == VoiceChannel.Global then
                canHear = true
            else 
                canHear = listenerPlayer:GetDistance(speakerPlayer) < kMaxWorldSoundDistance
            end
        end
            
        // Or if cheats or dev mode is on, they can hear each other
        if(Shared.GetCheatsEnabled() or Shared.GetDevMode()) then
            canHear = true
        end
        
        // NOTE: SCRIPT ERROR CAUSED IN THIS FUNCTION WHEN FP SPEC WAS ADDED.
        // This functionality never really worked anyway.
        // If we're spectating a player, we can hear their team (but not in tournamentmode, once that's in)
        //if self:GetIsPlayerFollowingTeamNumber(listenerPlayer, speakerPlayer:GetTeamNumber()) then
        //    canHear = true
        //end
        
        return canHear
        
    end

    function NS2Gamerules:RespawnPlayer(player)

        local team = player:GetTeam()
        team:RespawnPlayer(player, nil, nil)
        
    end

    // Add SteamId of player to list of players that can't command again until next game
    function NS2Gamerules:BanPlayerFromCommand(playerId)
        ASSERT(type(playerId) == "number")
        table.insertunique(self.bannedPlayers, playerId)
    end

    function NS2Gamerules:GetPlayerBannedFromCommand(playerId)
        ASSERT(type(playerId) == "number")
        return (table.find(self.bannedPlayers, playerId) ~= nil)
    end
function NS2Gamerules:GetFrontDoorsOpen()
return self.doorsopened
end
function NS2Gamerules:GetSideDoorsOpen()
return self.sideopened
end
function NS2Gamerules:GetSiegeDoorsOpen()
return self.siegedoorsopened
end
function NS2Gamerules:GetIsSuddenDeath()
return self.issuddendeath
end
function NS2Gamerules:ClearLocations()
         self.mainrooms = Shared.GetTime()
end
function NS2Gamerules:GetCombatEntitiesCount()
            local combatentities = 1
            for _, entity in ipairs(GetEntitiesWithMixin("Combat")) do
             local inCombat = (entity.timeLastDamageDealt + kMainRoomTimeInSecondsOfCombatToCount > Shared.GetTime()) or (entity.lastTakenDamageTime + kMainRoomTimeInSecondsOfCombatToCount > Shared.GetTime())
                  if inCombat then combatentities = combatentities + 1 end
                  if entity.mainbattle == true then entity.mainbattle = false end
             end
            return combatentities
end
function NS2Gamerules:GetCombatEntitiesCountInRoom(location)
       local entities = location:GetEntitiesInTrigger()
       local eligable = 0
             for _, entity in ipairs(entities) do
             if HasMixin(entity, "Combat") then
                local inCombat = (entity.timeLastDamageDealt + kMainRoomTimeInSecondsOfCombatToCount > Shared.GetTime()) or (entity.lastTakenDamageTime + kMainRoomTimeInSecondsOfCombatToCount > Shared.GetTime())
                  if inCombat then
                  eligable = eligable + 1
                 end
             end
            end
        return eligable
end
function NS2Gamerules:MainRoomSD()
                        for _, CC in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
                             CreatePheromone(kTechId.ThreatMarker, CC:GetOrigin(), 2) 
                             local powerpoint = GetPowerPointForLocation(CC:GetLocationName())
                            if powerpoint ~= nil then powerpoint:SetMainRoom() powerpoint:AttackDefendWayPoint() end
                        end
                        for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
                             hive:MarineOrders() 
                             break
                        end
                              self.mainrooms = Shared.GetTime()
                              self:AddTimedCallback(NS2Gamerules.ClearLocations, kMainRoomPickEveryXSeconds)
                             return true
end

function NS2Gamerules:PickMainRoom()
  //Kyle Abent ns2siege 11.22 kyleabent@gmail.com
    if not self:GetGameStarted() then return  end //pregame bug fix? because at start of round says self.mainrooms = shared.gettime //12.5
       if not self.doorsopened or (self.mainrooms + kMainRoomPickEveryXSeconds) > Shared.GetTime() then return true end 
       
                 if self:GetIsSuddenDeath() then
                     self:MainRoomSD()
                     return true
                 end
          
     local locations = EntityListToTable(Shared.GetEntitiesWithClassname("Location"))
     for i = 1, #locations do //
        local location = locations[i]
               if self.siegedoorsopened then
                          if string.find(location.name, "Siege") or string.find(location.name, "siege") then 
                          local powerpoint = GetPowerPointForLocation(location.name)
                             if powerpoint ~= nil then
                             powerpoint:SetMainRoom()
                              end
                           self.mainrooms = Shared.GetTime()
                           self:AddTimedCallback(NS2Gamerules.ClearLocations, kMainRoomPickEveryXSeconds)
                            return true //or break? meh.
                          end
                end //siege
              if self:GetCombatEntitiesCountInRoom(location) >=  ( self:GetCombatEntitiesCount() * kPercentofInCombatToQualify ) then  
                  self.mainrooms = Shared.GetTime() //Prevents 2 rooms being picked at once?
                   self:AddTimedCallback(NS2Gamerules.ClearLocations, kMainRoomPickEveryXSeconds) // Clears and says is ready for another
                      local entities = location:GetEntitiesInTrigger()
                      local shouldbreak = 0
                  if entities then
                  
                             local powerpoint = GetPowerPointForLocation(location.name)
                             if powerpoint ~= nil then
                             powerpoint:SetMainRoom()
                             Print("main room is %s", powerpoint:GetLocationName())
                              end
                              
                    for _, entity in ipairs(entities) do
                      if HasMixin(entity, "PowerConsumer") then entity.mainbattle = true end
                    //  if entity.GetLocationName then Print("main room is %s", entity:GetLocationName()) end
                      //if entity:isa("PowerPoint") then entity:SetMainRoom() end
                      // if HasMixin(entity, "Combat") then entity:InsideMainRoom() end
                      //break
                    end
                 self:TriggerZedTime()
                  end
             end//room check
      end //locations do
      return true
end
function NS2Gamerules:TriggerZedTime()

end
function NS2Gamerules:CollectResources()

   local harvesters = 0
   local extractors =  0
  for _, restower in ientitylist(Shared.GetEntitiesWithClassname("ResourceTower")) do
      if restower:GetIsBuilt() then
         if restower:GetTeamNumber() == 1 then
           extractors = extractors + 1
         elseif restower:GetTeamNumber() == 2 then
           harvesters = harvesters + 1
         end
       end
    end
                
       if extractors == 0 then
            extractors = 1
       elseif harvesters == 0 then
            harvesters = 1
        end      
   
   for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
         if player:GetTeamNumber() == 1 then
            player:AddResources(kPlayerResPerInterval * extractors)
         elseif player:GetTeamNumber() == 2 then
             local alienres = kPlayerResPerInterval
             if self:GetGameStarted() and not self.doorsopened then
                 alienres = alienres * 1.3
             end
           player:AddResources(alienres * harvesters)
         end

    end

        
        self.team1:AddTeamResources(kTeamResourcePerTick  * extractors)
        self.team2:AddTeamResources(kTeamResourcePerTick  * harvesters)
        
           return true
end

function NS2Gamerules:OpenFrontDoors()
 self.doorsopened = true
 
                 SendTeamMessage(self.team1, kTeamMessageTypes.FrontDoor)
                 SendTeamMessage(self.team2, kTeamMessageTypes.FrontDoor)
                
     for _, funcdoor in ientitylist(Shared.GetEntitiesWithClassname("FuncDoor")) do
               funcdoor:SetState(FuncDoor.kState.Welded)
     end
                 for index, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                frontdoor.driving = true
                frontdoor.cleaning = false
                frontdoor.isvisible = false
                end
                
              self:AddTimedCallback(NS2Gamerules.PickMainRoom, 5)
                
              for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
              StartSoundEffectForPlayer(NS2Gamerules.kFrontDoorSound, player)
              
                //   local random = math.random(1,4)
                   
                  // if random == 1 then
                    //  StartSoundEffectForPlayer(NS2Gamerules.SiegeMusic1, player)
                 //  elseif random == 2 then
                 //     StartSoundEffectForPlayer(NS2Gamerules.SiegeMusic2, player)
                 //  elseif random == 3 then
              //        StartSoundEffectForPlayer(NS2Gamerules.SiegeMusic3, player)
                //   elseif random == 4 then
                  //    StartSoundEffectForPlayer(NS2Gamerules.SiegeMusic4, player)
                  // end
                   
                   
              end
end
function NS2Gamerules:DisplayFrontDoorLocation()
         FrontDoor():SendLocationMessage()
         return not self.doorsopened
end
function NS2Gamerules:OpenSideDoors()
 self.sideopened = true
                 for index, sidedoor in ientitylist(Shared.GetEntitiesWithClassname("SideDoor")) do
                sidedoor.driving = true
                sidedoor.cleaning = false
                sidedoor.isvisible = false
                end
                /*
              for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
              StartSoundEffectForPlayer(NS2Gamerules.kFrontDoorSound, player)
              end
              */
end
function NS2Gamerules:SwitchShadesToSiegeMode()

          for index, Shade in ipairs(GetEntitiesForTeam("Shade", 2)) do
               if not Shade:GetIsOnFire() and Shade:GetIsBuilt() and GetHasTech(Shade, kTechId.ShadeHive) and Shade:IsInRangeOfHive() and Shade:GetIsSiege() then 
                Shade:PerformActivation(kTechId.ShadeInk, nil, normal, commander) 
                end
          end
          
                   //Ends with SuddenDeath
               return self.issuddendeath == false
end
function NS2Gamerules:SwitchCragsToSiegeMode()

          for index, Crag in ipairs(GetEntitiesForTeam("Crag", 2)) do
               if not Crag:GetIsOnFire() and GetHasTech(Crag, kTechId.CragHive) and Crag:IsInRangeOfHive() then 
                Crag:PerformActivation(kTechId.HealWave, nil, normal, commander) 
                end
          end
                   //Ends with SuddenDeath
               return self.issuddendeath == false
end
function NS2Gamerules:SwitchObservatoryToSiegeMode()

          for index, Observatory in ipairs(GetEntitiesForTeam("Observatory", 1)) do
               if Observatory:GetIsInSiege() and Observatory:GetIsPowered() and Observatory:GetIsBuilt() then 
                Observatory:ScanAtOrigin()
                end
          end
                   //Ends with SuddenDeath
               return self.issuddendeath == false
end
function NS2Gamerules:OpenSiegeDoors()
 self.siegedoorsopened = true
 
  
                 SendTeamMessage(self.team1, kTeamMessageTypes.SiegeDoor)
                 SendTeamMessage(self.team2, kTeamMessageTypes.SiegeDoor)
                 
               self:AddTimedCallback(NS2Gamerules.SwitchShadesToSiegeMode, kShadeInkCooldown)
               self:AddTimedCallback(NS2Gamerules.SwitchCragsToSiegeMode, kHealWaveCooldown)
               self:AddTimedCallback(NS2Gamerules.SwitchObservatoryToSiegeMode, kSiegeObsAutoScanCooldown)
                 
               for index, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                siegedoor.driving = true
                siegedoor.isvisible = false
                end //
                 for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                   StartSoundEffectForPlayer(NS2Gamerules.kSiegeDoorSound, player)
                 //  local random = math.random(1,4)
                   
                //   if random == 1 then
                   //   StartSoundEffectForPlayer(NS2Gamerules.SiegeMusic1, player)
                  // elseif random == 2 then
                  //    StartSoundEffectForPlayer(NS2Gamerules.SiegeMusic2, player)
                  // elseif random == 3 then
                //      StartSoundEffectForPlayer(NS2Gamerules.SiegeMusic3, player)
                //   elseif random == 4 then
                   //   StartSoundEffectForPlayer(NS2Gamerules.SiegeMusic4, player)
                   //end
                   

                    end //  
end
function NS2Gamerules:ToggleFuncMoveable()
               for index, funcmoveable in ientitylist(Shared.GetEntitiesWithClassname("FuncMoveable")) do
                funcmoveable.driving = not funcmoveable.driving
                end
end
function NS2Gamerules:EnableSuddenDeath()
self.issuddendeath = true

                 SendTeamMessage(self.team1, kTeamMessageTypes.SuddenDeath)
                 SendTeamMessage(self.team2, kTeamMessageTypes.SuddenDeath)
                 
                
               for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                if entity:GetTeamNumber() == 1 or entity:GetTeamNumber() == 2 then
                 // if not entity:GetIsAlive() then
                 // entity:GetTeam():ReplaceRespawnPlayer(entity)
                 // entity:SetCameraDistance(0)
                 // end //
                  StartSoundEffectForPlayer(NS2Gamerules.kSuddenDeathSound, entity)
                //  entity:SetResources(100)
                end //
              end //
              
end
function NS2Gamerules:ToggleMarineZedTime()

               for index, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
                marine.zedtimeslow = self:GetIsZedTime()
                end
                
                return self:GetIsZedTime()
end
function NS2Gamerules:GetIsZedTime()
  return self.iszedtime 
end
function NS2Gamerules:SendZedTimeActivationMessage()
                 self.iszedtime = true
                 self:AddTimedCallback(NS2Gamerules.ToggleMarineZedTime, 1)
                 
                 SendTeamMessage(self.team1, kTeamMessageTypes.ZedTimeBegin)
                 SendTeamMessage(self.team2, kTeamMessageTypes.ZedTimeBegin)
end
function NS2Gamerules:SendZedTimeDeActivationMessage()
                 self.iszedtime = false
                 SendTeamMessage(self.team1, kTeamMessageTypes.ZedTimeEnd)
                 SendTeamMessage(self.team2, kTeamMessageTypes.ZedTimeEnd)
end
/*
    function NS2Gamerules:FrontDoor()
    self.doorsopened = true
                   for index, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                frontdoor.driving = true
                frontdoor.cleaning = false
                end
                 if not self.playedfrontsound then
              self.playedfrontsound = true
              for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
              StartSoundEffectForPlayer(NS2Gamerules.kFrontDoorSound, player)
              end
              end
    end
    function NS2Gamerules:SiegeDoor()
                    self.siegedoorsopened = true
               for index, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                siegedoor.driving = true
                end //
              if not self.playedsiegesound then
                 self.playedsiegesound = true
                 for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                   StartSoundEffectForPlayer(NS2Gamerules.kSiegeDoorSound, player)
                    end // 
              end 
    end
    function NS2Gamerules:SuddenDeath()
             self.issuddendeath = true
       //  if not self.alreadyhookedsuddendeath then self:HookSuddenDeathStart() self.alreadyhookedsuddendeath = true end
            if not self.respawnedplayers then
              self.respawnedplayers = true
               for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                if entity:GetTeamNumber() == 1 or entity:GetTeamNumber() == 2 then
                  if not entity:GetIsAlive() then
                  entity:GetTeam():ReplaceRespawnPlayer(entity)
                  end //
                  StartSoundEffectForPlayer(NS2Gamerules.SuddenDeathMusic, entity)
                  StartSoundEffectForPlayer(NS2Gamerules.kSuddenDeathSound, entity)
                  entity:SetResources(100)
                end //
              end //
           end //
    end
  */  
/*
function NS2Gamerules:HookDoorsOpen()
end
function NS2Gamerules:HookSiegeOpen()
end
function NS2Gamerules:HookSuddenDeathStart()
end
*/
////////////////    
// End Server //
////////////////

end

function NS2Gamerules:GetGameStartTime()
    return ConditionalValue(self:GetGameStarted(), self.gameStartTime, 0)
end

function NS2Gamerules:GetGameStarted()
    return self.gameState == kGameState.Started
end
Shared.LinkClassToMap("NS2Gamerules", NS2Gamerules.kMapName, { })
