----Hewavily modified within siege
---Kyle Abent

Script.Load("lua/Gamerules.lua")
Script.Load("lua/dkjson.lua")
Script.Load("lua/ServerSponitor.lua")


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
            self.lastaliencreatedentity = 0
            self.lastmarinecreatedentity = 0
            self.respawnedplayers = false
            self.issuddendeath = false
            self.mainrooms = Shared.GetTime()
            self.doorsopened = false
            self.marinepacksdropped = 0
            self.lastrespawnupdate = 0
            self.sideopened = false
            self.siegedoorsopened = false
            self.alienteamcanupgeggs = false
            self.lastupgeggtime = 0
            self.setuppowernodecount = 0
            self.setuppowernodecountbuilt = 0
            self.lastnode = false
            self.lastexploitcheck = Shared.GetTime()
            self:AddTimedCallback(NS2Gamerules.CollectResources, kResourceTowerResourceInterval) 
            self:AddTimedCallback(NS2Gamerules.ExpandKingCyst, kExpandCystInterval)
            self:AddTimedCallback(NS2Gamerules.OpenFrontMaybe, 1)
            self:AddTimedCallback(NS2Gamerules.OpenSiegeMaybe, 1)
            self:AddTimedCallback(NS2Gamerules.UpdateHiveEggs, 8)
            
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
                self.gameInfo:SetFrontTime(kFrontDoorTime)
                self.gameInfo:SetSiegeTime(kSiegeDoorTimey)
                
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
        self.marinepacksdropped = 0
        self.lastrespawnupdate = 0
        self.alienteamcanupgeggs = false
        self.lastupgeggtime = 0
        self.setuppowernodecount = 0
        self.setuppowernodecountbuilt= 0
        self.lastnode = false
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
        self.lastaliencreatedentity = 0
        self.lastmarinecreatedentity = 0
        
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
         if self:GetGameStarted() and not self.siegedoorsopened and not Shared.GetCheatsEnabled() and (self.lastexploitcheck + 30) < Shared.GetTime()  then
         self.lastexploitcheck = Shared.GetTime()
          for _, entity in ipairs(GetEntitiesWithMixin("Live")) do
               if not entity:isa("PowerPoint") and not entity:isa("Player") and entity.GetLocationName then
                   if string.find(entity:GetLocationName(), "siege") or string.find(entity:GetLocationName(), "Siege") then
                        if ( HasMixin(entity, "Construct") and entity:GetIsBuilt() )
                        or entity:isa("Cyst") or entity:isa("MAC") or entity:isa("Drifter") or entity:isa("ARC") or entity:isa("Egg") or entity:isa("Contamination") or entity:isa("Egg") or entity:isa("Hive")              
                        then
                        entity:GetTeam():AddTeamResources(LookupTechData(entity:GetTechId(), kTechDataCostKey))
                        DestroyEntity(entity)
                        end 
                   end  
               end 
           end 
         end  
      
            if self.justCreated then
            
                if not self.gameStarted then
                    self:ResetGame()
                end
                
                self.justCreated = false
                
            end
            
            if self:GetMapLoaded() then
            


                
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
            end

        end
        
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
            
      //  elseif not self:GetRookieMode() and not playedTutorial[player:GetSteamId()] and
        //        player:GetPlayerSkill() ~= -1 and player:GetPlayerSkill() < 1 then
          //  return false, 1
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
                     self:CheckGameStart()
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
            local team1hasplayer = self.team1:GetHasPlayer()
            local team2hasplayer = self.team2:GetHasPlayer()
            
            if ((team1hasplayer and team2hasplayer) or Shared.GetCheatsEnabled())  then
            
                if self:GetGameState() == kGameState.NotStarted then
                    self:SetGameState(kGameState.PreGame)
                end
                
            else
            
                if self:GetGameState() == kGameState.PreGame then
                    self:SetGameState(kGameState.NotStarted)
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
        function NS2Gamerules:CheckGameEndInAMoment()
          self:AddTimedCallback(NS2Gamerules.CheckGameEnd, 4)
        end
    function NS2Gamerules:CheckGameEnd()

        PROFILE("NS2Gamerules:CheckGameEnd")
        
        if self:GetGameStarted() and not Shared.GetCheatsEnabled() then

            local time = Shared.GetTime()

                local team1Lost = self.team1:GetHasTeamLost()
                local team2Lost = self.team2:GetHasTeamLost()  
  
                if team2Lost then

                    -- Still no draw after kDrawGameWindow, count the win
                    self:EndGame( self.team1 )

                elseif team1Lost then

                    -- Still no draw after kDrawGameWindow, count the win
                    self:EndGame( self.team2 )
                    
                end
        end
            return false
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
                if not canHear then canHear = speakerPlayer:GetAllTalkToggled() end
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
function NS2Gamerules:GetSetupNodeRatio()
       return self.setuppowernodecount
    end
function NS2Gamerules:GetFrontDoorsOpen()
return self.doorsopened
end
function NS2Gamerules:GetCanAlienTeamUpgEggs()
return self.alienteamcanupgeggs and ( (self.lastupgeggtime + 6) < Shared.GetTime() )
end
function NS2Gamerules:SetEggTimer()
self.lastupgeggtime = Shared.GetTime()
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
function NS2Gamerules:GetLocationWithMostMixedPlayers()
--Kyle Abent - works good 2.15
--so far v1.23 shows this works okay except for picking empty res rooms for some reason -.-
//Print("GetLocationWithMostMixedPlayers")

local team1avgorigin = Vector(0, 0, 0)
local marines = 1
local team2avgorigin = Vector(0, 0, 0)
local aliens = 1
local neutralavgorigin = Vector(0, 0, 0)

            for _, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
            if marine:GetIsAlive() and not marine:isa("Commander") then marines = marines + 1 team1avgorigin = team1avgorigin + marine:GetOrigin() end
             end
             
           for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do
            if alien:GetIsAlive() and not alien:isa("Commander") then aliens = aliens + 1 team2avgorigin = team2avgorigin + alien:GetOrigin() end 
             end
             --v1.23 added check to make sure room isnt empty
         neutralavgorigin =  team1avgorigin + team2avgorigin
         neutralavgorigin =  neutralavgorigin / (marines+aliens) --better as a table i know
     //    Print("neutralavgorigin is %s", neutralavgorigin)
     local nearest = GetNearest(neutralavgorigin, "Location", nil, function(ent) local powerpoint = GetPowerPointForLocation(ent.name) return ent:MakeSureRoomIsntEmpty() and ( powerpoint ~= nil and powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() ) and not (not self.siegedoorsopened  and string.find(ent.name, "Siege") or string.find(ent.name, "siege") ) end)
    if nearest then
   // Print("nearest is %s", nearest.name)

   
        return nearest
    end

end
function NS2Gamerules:GetCombatEntitiesCount()
--Kyle Abent
            local combatentities = 1
            for _, entity in ipairs(GetEntitiesWithMixin("Combat")) do
             local inCombat = (entity.timeLastDamageDealt + kMainRoomTimeInSecondsOfCombatToCount > Shared.GetTime()) or (entity.lastTakenDamageTime + kMainRoomTimeInSecondsOfCombatToCount > Shared.GetTime())
                  if inCombat then combatentities = combatentities + 1 end
                  if entity.mainbattle == true then entity.mainbattle = false end
             end
             //     Print("combatentities %s", combatentities)
            return combatentities
end
function NS2Gamerules:GetCombatEntitiesCountInRoom(location)
--Kyle Abent
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
       // Print("location %s, eligable %s", location, eligable)
        return eligable
end
function NS2Gamerules:MainRoomSD()
--Kyle Abent
                        for _, CC in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
                             CreatePheromone(kTechId.ThreatMarker, CC:GetOrigin(), 2) 
                             local powerpoint = GetPowerPointForLocation(CC:GetLocationName())
                            if powerpoint ~= nil then powerpoint:SetMainRoom() powerpoint:AttackDefendWayPoint() end
                        end
                        for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
                             hive:MarineOrders() 
                             break
                        end
                             return true
end

function NS2Gamerules:PickMainRoom(force)
  //Kyle Abent ns2siege 11.22 kyleabent@gmail.com
    if not self:GetGameStarted() then return  end 
                 if self:GetIsSuddenDeath() then
                     self:MainRoomSD()
                    return true
                 end
                local location = self:GetLocationWithMostMixedPlayers()
                if not location then return true end
                      local entities = location:GetEntitiesInTrigger()
                  if entities then
                  
                             local powerpoint = GetPowerPointForLocation(location.name)
                             if powerpoint ~= nil then
                                    powerpoint:SetMainRoom()
                               end
                              
                    for _, entity in ipairs(entities) do
                      if (entity.GetTeamNumber and entity:GetTeamNumber() == 1) and HasMixin(entity, "Construct") then entity.mainbattle = true end
                    end
                 self:TriggerZedTime()
                  end
      return true
end
function NS2Gamerules:TriggerZedTime()

end
function NS2Gamerules:CollectResources()

            local team1Players = self.team1:GetNumPlayers()
            local team2Players = self.team2:GetNumPlayers()
            local unbalancedAmount = math.abs(team1Players - team2Players)

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
  local alienmoreplayers = team2Players > team1Players and (harvesters - (unbalancedAmount/14) * harvesters)  or harvesters
  local marinemoreplayers = team2Players < team1Players and (extractors - (unbalancedAmount/14) * extractors)  or extractors
  
  harvesters = alienmoreplayers
  extractors = marinemoreplayers
  
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
                 alienres = alienres * 1.15
             end
           player:AddResources(alienres * harvesters)
         end

    end

        
        self.team1:AddTeamResources(kTeamResourcePerTick  * extractors)
        self.team2:AddTeamResources(kTeamResourcePerTick  * harvesters)
        self:AutoBuildResTowers()
           return true
end

function NS2Gamerules:AutoBuildResTowers()
//if self.doorsopened == true then return end
  for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
         respoint:AutoDrop()
    end//
end
    function NS2Gamerules:NodeRules(powerpoint)
               --Ratios
               local frontdooropenratio = self.setuppowernodecount 
               local built, unbuilt = self:CountCurrentNodes()       
               local currentstatusratio = (built/unbuilt)
               --Time
               local gameRules = GetGamerules()
               local gameLength = Shared.GetTime() - gameRules:GetGameStartTime()
               local currenttimeleft = math.abs(kSiegeDoorTimey - gameLength )
               local currentroundratio = GetRoundLengthToSiege()
               --Positive or Negative?
                local positive = false
                local negative = false
                
                  if currentstatusratio >= frontdooropenratio then
                    positive = true
                   else
                    negative = true
                   end
               -- Okay, how much time?
               local setsiegedoortime = 0
                 setsiegedoortime = ConditionalValue(positive == true, currentroundratio * currentstatusratio + (currenttimeleft * currentroundratio), frontdooropenratio - currentstatusratio * (currenttimeleft * currentroundratio ))  
                  Print("setsiegedoortime is %s", setsiegedoortime)
               setsiegedoortime = ConditionalValue(self.lastnode == true, setsiegedoortime * 4 , setsiegedoortime) --last node rules
                  Print("setsiegedoortime is %s", setsiegedoortime)
             --  setsiegedoortime = math.abs(currenttimeleft - (kSiegeDoorTime - gameLength) )
             --      Print("setsiegedoortime is %s", setsiegedoortime)
               
             --  if negative == true then setsiegedoortime = setsiegedoortime * -1 end
             --      Print("setsiegedoortime is %s", setsiegedoortime)
             local amount = math.round(setsiegedoortime,0)
             Shared.ConsoleCommand(string.format("sh_addsiegetime %s", amount ))
             SendTeamMessage(self.team1, kTeamMessageTypes.SiegeTime, amount)
             SendTeamMessage(self.team2, kTeamMessageTypes.SiegeTime, amount)
end
    function NS2Gamerules:NodeBuiltFront(powerpoint)
    --Kyle Abent =] 
    
         self:NodeRules(powerpoint)
           
    end
        function NS2Gamerules:SetupRoomBluePrint(location, powerpoint, hasfrontdoor, issiege)
          local laystructureCCcount = 0
                for index, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
                    if marine:GetIsBuildingCC() then
                     laystructureCCcount = laystructureCCcount + 1
                    end
                end

                local armoryspawnpoint = powerpoint:FindFreeSpace()
                local armory = CreateEntity(Armory.kMapName, armoryspawnpoint, 1)  
                  if armory then
                  armory:GetTeam():RemoveSupplyUsed(kArmorySupply)
                  end
                  
                local prototypespawn = powerpoint:FindFreeSpace()
                local prototype = CreateEntity(PrototypeLab.kMapName, prototypespawn, 1)  
                
                local observatoryspawnpoint = powerpoint:FindFreeSpace()
                if issiege then
                observatoryspawnpoint = powerpoint:FindArcHiveSpawn()
                end
                local phasegatespawnpoint = powerpoint:FindFreeSpace()
                local roboticsspawnpoint = powerpoint:FindFreeSpace()
                local arcspawnpoint = powerpoint:FindFreeSpace()
                local CCpawnpoint = powerpoint:FindFreeSpace()
                local nearestobs = GetEntitiesForTeamWithinRange("Observatory", 1, observatoryspawnpoint, Observatory.kDetectionRange)
                local nearestphasegate = GetEntitiesForTeamWithinRange("PhaseGate", 1, phasegatespawnpoint, Observatory.kDetectionRange*2.75)
                local nearestrobotics = GetEntitiesForTeamWithinRange("RoboticsFactory", 1, roboticsspawnpoint, Observatory.kDetectionRange*2.75)
                local nearestCC = GetEntitiesForTeamWithinRange("CommandStation", 1, CCpawnpoint, Observatory.kDetectionRange*2.75) or 0
                local allCCs = GetEntitiesForTeamWithinRange("CommandStation", 1, CCpawnpoint, 999999) or 0
                local nearestarc = GetEntitiesForTeamWithinRange("ARC", 1, arcspawnpoint, Observatory.kDetectionRange*2.5)
                if #nearestobs == 0 then
                 local observatory = CreateEntity(Observatory.kMapName, observatoryspawnpoint, 1)  
                     if observatory then
                     observatory:GetTeam():RemoveSupplyUsed(kObservatorySupply)
                      if isinsiege then observatorySetConstructionComplete() end
                     end
                end
                if #nearestarc == 0 then
                 local dropship = CreateEntity(Dropship.kMapName, arcspawnpoint, 1)  
                end  
                
                if #nearestrobotics == 0 then
                 local roboticsfactory = CreateEntity(RoboticsFactory.kMapName, roboticsspawnpoint, 1)  
                     if roboticsfactory then
                        roboticsfactory:GetTeam():RemoveSupplyUsed(kRoboticsFactorySupply)
                     end
                end
                
               if #nearestphasegate == 0 then
                 local phasegate = CreateEntity(PhaseGate.kMapName, phasegatespawnpoint, 1)  
                     if phsaegate then
                     phsaegate:GetTeam():RemoveSupplyUsed(kPhaseGateSupply)
                     end
                end
                
               if #nearestCC + #allCCs + laystructureCCcount <= 2 then
                 local CC = CreateEntity(CommandStation.kMapName, CCpawnpoint, 1)  
                end
                
           if hasfrontdoor then      
                CreateEntity(Sentry.kMapName, spawnpoint, 1)  
                CreateEntity(Sentry.kMapName,spawnpoint, 1)  
                CreateEntity(Sentry.kMapName, spawnpoint, 1)  
                CreateEntity(Sentry.kMapName, spawnpoint, 1)  
                CreateEntity(Sentry.kMapName, spawnpoint, 1)  
                CreateEntity(Sentry.kMapName, spawnpoint, 1)  
                CreateEntity(Observatory.kMapName, spawnpoint, 1)  
           end
        
        end
    function NS2Gamerules:DelayedAllowance(origin, allowance, techid, mapname)
     for i = 1, allowance do      
     local cost = LookupTechData(techid, kTechDataCostKey)
     
      if self.team1:GetTeamResources() >= cost then
              local dropship = CreateEntity(Dropship.kMapName, self:FindFreeDropShipSpace(origin), 1)  
              dropship:SetTechId(techid)
              dropship:SetMapName(mapname)
              self.team1:SetTeamResources(self.team1:GetTeamResources()  - cost)
       end
     end
    end
    function NS2Gamerules:FindCustomFreeSpace(who, min, max)
    
        for index = 1, 20 do
           local extents = Vector(1,1,1)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)                                  --not sure about filter?
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, who:GetModelOrigin(), min, max, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == who:GetLocationName()
        
           if spawnPoint ~= nil and sameLocation then 
           return spawnPoint
           end
       end
           Print("No valid spot found for FindCustomFreeSpace")
           return who:GetOrigin()
    end
    function NS2Gamerules:FindFreeDropShipSpace(where)
    
        for index = 1, 24 do
           local extents = Vector(1,1,1)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)                             
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, 1, 24, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == GetLocationForPoint(where) 
           --sameLocation = sameLocation  and not GetIsPointOnInfestation(where)
        
           if spawnPoint ~= nil and sameLocation then 
           return spawnPoint
           end
       end
           Print("No valid spot found for FindFreeDropShipSpace")
           return where
    end
local function GetDroppackSoundName(techId)

    if techId == kTechId.MedPack then
        return MedPack.kHealthSound
    elseif techId == kTechId.AmmoPack then
        return AmmoPack.kPickupSound
    elseif techId == kTechId.CatPack then
        return CatPack.kPickupSound
    end 
   
end
    function NS2Gamerules:DropMarineSupport(who, position, techId)
      if self.team1:GetTeamResources() == 0 then return end
    local donotadd = false
    
    if self.marinepacksdropped == 4 then
       self.team1:SetTeamResources(self.team1:GetTeamResources()  - 1)
       donotadd = true
       self.marinepacksdropped = 0
    end
    
    local mapName = LookupTechData(techId, kTechDataMapName)
    local success = false
    
    if mapName then
      --Print("DropMarineSupport test")
        local desired = self:FindCustomFreeSpace(who, 0, 4)
         if desired ~= nil then
         position = desired
         end
        local droppack = CreateEntity(mapName, position, 1)
        StartSoundEffectForPlayer(GetDroppackSoundName(techId), self)
       // self:ProcessSuccessAction(techId)
        success = true
        
        if not donotadd then
        self.marinepacksdropped = Clamp(self.marinepacksdropped + 1, 1, 4)
        end
        
    end

    return success
    
    end
    function NS2Gamerules:NodeKilledFront(powerpoint)
    --Kyle Abent 
          self:NodeRules(powerpoint)
    end
    function NS2Gamerules:CountCurrentNodes()
    local built = 0
    local unbuilt = 0
                 for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                 if not powerpoint:GetIsInSiegeRoom() then
                   if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then
                     built = built + 1
                   elseif powerpoint:GetIsDisabled() or powerpoint:GetIsSocketed() then
                     unbuilt = unbuilt + 1
                   end
                   end
                end
                if built <= 1 then self.lastnode = true
                else
                self.lastnode = false
                end
                return built, unbuilt
    end

function NS2Gamerules:CountNodes()
--Kyle Abent
local built = 0
local unbuilt = 0
                 for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                 if not powerpoint:GetIsInSiegeRoom() then
                   if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then
                     built = built + 1
                   elseif powerpoint:GetIsDisabled() or powerpoint:GetIsSocketed() then
                     unbuilt = unbuilt + 1
                   end
                   end
                end
                
                if self.setuppowernodecountbuilt == 0 then
                self.setuppowernodecountbuilt = built
                end
                 if self.setuppowernodecount == 0 then
                self.setuppowernodecount = math.abs(built/unbuilt) 
                end
                
                if self.siegedoorsopened then
                  self.siegepowernodecount = math.abs(built/unbuilt) 
                end
                
                Print("unbuilt = %s, built = %s, setuppowernodecount = %s, siegepowernodecount = %s,", unbuilt, built, self.setuppowernodecount, self.siegepowernodecount)
               // return built
               
               if not self.siegedoorsopened then return false end
               
               return self.siegedoorsopened, self.setuppowernodecount, self.siegepowernodecount 

end
function NS2Gamerules:CystUnbuiltRooms()
     for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
               if not powerpoint:GetIsBuilt() then powerpoint:ActivateCystTimer() end
     end
end
function NS2Gamerules:AutoDrop(respoint)          
          local powerpoint = GetPowerPointForLocation(respoint:GetLocationName())
          if powerpoint ~= nil then 
           if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then 
              respoint:SpawnResourceTowerForTeamModified(1, kTechId.Extractor)
           elseif powerpoint:GetIsDisabled() or  powerpoint:GetIsSocketed() and self:GetCanSpawnAlienEntity(kStructureDropCost) then                                   
              local infestation = GetEntitiesWithMixinWithinRange("Infestation", respoint:GetOrigin(), 7) 
              if #infestation >= 1 then
              local success = false
               success = respoint:SpawnResourceTowerForTeamModified(2, kTechId.Harvester)
                     if success ~= false then 
                     local amount = not self.doorsopened and 4 or 8
                     self.team2:SetTeamResources(self.team2:GetTeamResources()  - amount)
                     self.lastaliencreatedentity = Shared.GetTime() 
                     end
               end
              end
           end
end
function NS2Gamerules:SetLocationVar()
     for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
              location:SetIsPoweredAtFrontOpen()
     end
end
function NS2Gamerules:EnableIPsBeacon()
local ent = nil
     for _, IP in ientitylist(Shared.GetEntitiesWithClassname("InfantryPortal")) do
              if not IP:GetIsBeaconActive() then IP:ActivateBeacons() end
     end
     return true
end
    function NS2Gamerules:OpenFrontMaybe()
       local fronttime = self.gameInfo:GetFrontTime()
          if Shared.GetTime() - self:GetGameStartTime() > fronttime and not self.doorsopened then
            self:OpenFrontDoors()
          end
          return not self.doorsopened
    end
    function NS2Gamerules:OpenSiegeMaybe()
       local siegetime = self.gameInfo:GetSiegeTime()
          if Shared.GetTime() - self:GetGameStartTime() > siegetime and not self.siegedoorsopened then
            self:OpenSiegeDoors()
          end
          return not self.siegedoorsopened
    end
function NS2Gamerules:OpenFrontDoors()
 self.doorsopened = true
 self:CountNodes()
 self:CystUnbuiltRooms()
 self:SetLocationVar()
                 SendTeamMessage(self.team1, kTeamMessageTypes.FrontDoor)
                 SendTeamMessage(self.team2, kTeamMessageTypes.FrontDoor)
                
     for _, funcdoor in ientitylist(Shared.GetEntitiesWithClassname("FuncDoor")) do
               funcdoor:SetState(FuncDoor.kState.Welded)
     end
                 for index, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                frontdoor.driving = true
                frontdoor.isvisible = false
                end
                
              self:AddTimedCallback(NS2Gamerules.PickMainRoom, 10)
              self:EnableIPsBeacon()
              self:AddTimedCallback(NS2Gamerules.EnableIPsBeacon, 90)
                
              for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
              StartSoundEffectForPlayer(NS2Gamerules.kFrontDoorSound, player)           
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
                sidedoor.isvisible = false
                end
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
               return self.issuddendeath == false
end
function NS2Gamerules:GetSiegePowerPoint()
local powernode = nil
             for index, powerpoint in ipairs(GetEntitiesForTeam("PowerPoint", 1)) do
               if powerpoint:GetIsInSiegeRoom() then 
                powernode = powerpoint
                break
                end
          end 
return powernode

end
function NS2Gamerules:GetArcCountInSiege()
local count = 0
             for index, arc in ipairs(GetEntitiesForTeam("ARC", 1)) do
               if arc:GetIsInSiege() then 
                count = count + 1
                end
          end 
return count

end
function NS2Gamerules:GetHiveLocationForScan()
             for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
               if hive then 
                   return hive:GetOrigin()
                end
          end 
          return nil
end
function NS2Gamerules:DropshipArcs()
   local arcspawnpoint = self:GetSiegePowerPoint():FindArcHiveSpawn()
     if self:GetArcCountInSiege() <= 12 and self.team1:GetTeamResources() >= 8 then

         if arcspawnpoint ~= nil then
         local dropship = CreateEntity(Dropship.kMapName, arcspawnpoint, 1) 
          self.team1:SetTeamResources(self.team1:GetTeamResources()  - 8)
            dropship.flyspeed = .4
        end
     end
    
     
     if  self.team1:GetTeamResources() >= 3 then
          local origin = self:GetHiveLocationForScan()
          CreateEntity( Scan.kMapName, origin or arcspawnpoint, 1)
          self.team1:SetTeamResources(self.team1:GetTeamResources()  - 3)
     end
     
     return self.siegedoorsopened

end
function NS2Gamerules:MaintainHiveDefense()
             for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
               if hive:GetIsAlive() then 
                 self:HiveDefenseMain(hive, hive:GetDefenseEntsInRange())
                 break
                end
          end
          
                  return true
end
function NS2Gamerules:HiveDefenseMain(hive, shifts, crags, shades)
         local tres = kStructureDropCost
         local spawned = false
                   if #shifts <= math.random(1,3) then
                      if self:GetCanSpawnAlienEntity(tres, 0) then  
                      self.team2:SetTeamResources(self.team2:GetTeamResources()  - tres)  
                      local shift = CreateEntity(Shift.kMapName, hive:FindFreeSpace(), 2) 
                      shift:SetConstructionComplete()
                      end
                    end
                    
                    if #crags <= math.random(1,3) then
                      if not spawned then
                      if self:GetCanSpawnAlienEntity(tres, 0) then  
                      self.team2:SetTeamResources(self.team2:GetTeamResources()  - tres)  
                      local crag = CreateEntity(Crag.kMapName, hive:FindFreeSpace(), 2) 
                      crag:SetConstructionComplete()
                      end
                      end
                    end
                    
                    if #shades <= math.random(1,3) then
                       if not spawned then 
                      if self:GetCanSpawnAlienEntity(tres, 0) then  
                      self.team2:SetTeamResources(self.team2:GetTeamResources()  - tres)  
                       local shade = CreateEntity(Shade.kMapName, hive:FindFreeSpace(), 2) 
                      shade:SetConstructionComplete()
                       end
                       end
                    end

        


end
function NS2Gamerules:UpdateHiveEggs()
            for index, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
                  if hive:GetIsAlive() then hive:SpawnEggs() break end 
                end 
                return true
end
function NS2Gamerules:OpenSiegeDoors()
 self.siegedoorsopened = true
  
                 SendTeamMessage(self.team1, kTeamMessageTypes.SiegeDoor)
                 SendTeamMessage(self.team2, kTeamMessageTypes.SiegeDoor)
               
               self:AddTimedCallback(NS2Gamerules.DropshipArcs, 15)
               self:AddTimedCallback(NS2Gamerules.MaintainHiveDefense, 8)

                
               for index, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                siegedoor.driving = true
                siegedoor.isvisible = false
                end 
                 for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                   StartSoundEffectForPlayer(NS2Gamerules.kSiegeDoorSound, player)
                    end 
end
function NS2Gamerules:ToggleFuncMoveable()
               for index, funcmoveable in ientitylist(Shared.GetEntitiesWithClassname("FuncMoveable")) do
                funcmoveable.driving = not funcmoveable.driving
                end
end

function NS2Gamerules:GetCanUpdateRespawnTime()
  return (self.lastrespawnupdate + 16) < Shared.GetTime()
end
function NS2Gamerules:UpdateSpawnTime()
  self.lastrespawnupdate = Shared.GetTime()
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
function NS2Gamerules:SynrhonizeCystEntities(whips, crags, cyst, origin)
--Kyle Abent
            local spawned = false 
            local tres = not self.doorsopened and kStructureDropCost * .5 or kStructureDropCost
            self.alienteamcanupgeggs = ConditionalValue(self.team2:GetTeamResources()>= 100, true,false)
        if self:GetCanSpawnAlienEntity(tres, nil, cyst:GetIsInCombat()) then
         
        
                    if #whips <= math.random(1,19) then
                       if not spawned then
                      local whip = CreateEntity(Whip.kMapName, origin, 2) 
                      self.lastaliencreatedentity = Shared.GetTime()
                        spawned = true
                      end
                    end
                    
                    if #crags <= math.random(1,19) then
                       if not spawned then
                      local crag = CreateEntity(Crag.kMapName, origin, 2) 
                      self.lastaliencreatedentity = Shared.GetTime()
                        spawned = true
                      end
                    end
                    
        end   
        

            if not spawned then
                 self.alienteamcanupgeggs = true
            else
              self.team2:SetTeamResources(self.team2:GetTeamResources()  - tres)
              cyst.MinKingShifts = Clamp(cyst.MinKingShifts + 1, 0, Cyst.MinimumKingShifts)
            end     
            
end
function NS2Gamerules:SpawnNewHive(origin)
   
self:AddTimedCallback(function() CreateEntity(Hive.kMapName, origin, 2)  end, math.random(4,16))
    

end
function NS2Gamerules:SetupRulesTest()
        local frontdoor = nil
        local averageorigin = Vector(0,0,0)
        local nearestpowernode = nil
        local nearestrelevancy = nil
        local mainroomorigin = nil
          
         for index, frontdoorderp in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
           frontdoor = frontdoorderp
           break
        end
             if self.doorsopened then
             nearestrelevancy = GetNearest(frontdoor:GetOrigin(), "Location", nil, function(ent) return ent:GetHadPowerDuringSetup() and ent:RoomCurrentlyHasPower() end)  
             end
             
             if not nearestrelevancy then
              nearestrelevancy = GetNearest(frontdoor:GetOrigin(), "PowerPoint", nil, function(ent) return ent:GetIsBuilt() and not ent:GetIsDisabled() and not ( string.find(ent:GetLocationName(), "siege") or string.find(ent:GetLocationName(), "Siege") ) end)  
             else
               nearestrelevancy = GetPowerPointForLocation(nearestrelevancy.name)
             end
              

       for index, pherome in ientitylist(Shared.GetEntitiesWithClassname("Pheromone")) do
                       local techId = pherome:GetType()
                  if  techId == kTechId.ThreatMarker then
                    mainroomorigin = pherome:GetOrigin()
                    break
                   end
              end
              
   if nearestrelevancy  then
                averageorigin = averageorigin + nearestrelevancy:GetOrigin()
                if mainroomorigin then
                 averageorigin = averageorigin + mainroomorigin
                 averageorigin = averageorigin / 2
                else
                 averageorigin = averageorigin / 1
                end
   end
           return averageorigin
end
function NS2Gamerules:ExpandKingCyst()
  --Kyle Abent
 -- Print("updating kings")
   local averageorigin = self:SetupRulesTest() 
         local nearescysttoavg = GetNearest(averageorigin , "Cyst", nil, function(ent) return ent:GetIsBuilt()  end)
              if nearescysttoavg then
                    for index, cyst in ientitylist(Shared.GetEntitiesWithClassname("Cyst")) do
                     if cyst.isking and cyst ~= nearescysttoavg and cyst:GetCanDethrone() then
                       local kinglocation = cyst:GetLocationName() 
                       local nearestlocation = nearescysttoavg:GetLocationName()
                        if nearestlocation ~= kinglocation then cyst:Dethrone() end
                    end         
                      if cyst.level ~= 0 then
                       cyst.wasking = cyst.level ~= 0
                       if cyst.wasking then return true end -- dethrone first
                       end
                  end
                     CreatePheromone(kTechId.ExpandingMarker, nearescysttoavg:GetOrigin(), 2) 
                      nearescysttoavg.isking = true
                      nearescysttoavg:ActivateMagnetize()
                      nearescysttoavg.wasking = false
                      nearescysttoavg:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup) 
                 end
       return true
end
function NS2Gamerules:GetCanSpawnAlienEntity(trescount, timeywimey, isincombat)
   local canafford = self.team2:GetTeamResources() >= trescount
   if not timeywimey then
    local time = self.lastaliencreatedentity + math.random(4,32)
    time = ConditionalValue(self.doorsopened or self.siegedoorsopened, time *.5, time)
    time = ConditionalValue(isincombat, time * math.random(.7, .90), time)
    time = time - (self.team2:GetTeamResources()/200) * time
    timeywimey = time
    end
        if timeywimey < Shared.GetTime() then
              return canafford
         end
end
function NS2Gamerules:AntiExploitCystFrontDoor(cyst)
   if not self.doorsopened then
     local nearestdoor = GetNearest(cyst:GetOrigin(), "FrontDoor", nil)  
         if nearestdoor then
          local distance = (cyst:GetOrigin() - nearestdoor:GetOrigin()):GetLengthXZ()
            if distance <= 4 then
              DestroyEntity(cyst)
            end
         end
   end

end

function NS2Gamerules:SpawnPrototypeEnts(proto)
--kyle abent
     if self:GetCanSpawnMarineEntity(8,nil, proto:GetIsInCombat()) then 
local location = GetLocationForPoint(proto:GetOrigin())

if location then

local jps, exos = proto:GetJPExoEntitiesCount()
local spawnpoint = proto:FindFreeSpace()
  if spawnpoint ~= nil then
   local spawned = false
    if jps <= math.random(1,2) then
            local dropship = CreateEntity(Dropship.kMapName, spawnpoint, 1)  
              dropship:SetTechId(kTechId.Jetpack)
              dropship:SetMapName(Jetpack.kMapName)
              local lulz = 4
              lulz = ConditionalValue(proto:GetIsInCombat(), 8, lulz)
              dropship.flyspeed = lulz
         self.lastmarinecreatedentity = Shared.GetTime()
               self.team1:SetTeamResources(self.team1:GetTeamResources()  - 8)
               spawned= true
    elseif exos <= math.random(1,2) then
       if not spawned then
            local dropship = CreateEntity(Dropship.kMapName, spawnpoint, 1)  
              local lulz = 2
              lulz = ConditionalValue(proto:GetIsInCombat(), 4, lulz)
              dropship.flyspeed = lulz
              dropship:SetTechId(kTechId.Exosuit)
              dropship:SetMapName(Exosuit.kMapName)
         self.lastmarinecreatedentity = Shared.GetTime()
         self.team1:SetTeamResources(self.team1:GetTeamResources()  - 8)
         end
    end
    
 end
 end
 
 end
 
end
function NS2Gamerules:SpawnArmoryEnts(armory)
--kyle abent
     if self:GetCanSpawnMarineEntity(2,nil, armory:GetIsInCombat()) then 
local location = GetLocationForPoint(armory:GetOrigin())

if location then

--local shotguns, hmgs, flamethrowers, GLS = armory:GetWeaponsCount()
local shotguns, flamethrowers, GLS = armory:GetWeaponsCount()
local spawnpoint = armory:FindFreeSpace()
  if spawnpoint ~= nil then
   local spawned = false
    if shotguns <= 1 then
              local dropship = CreateEntity(Dropship.kMapName, spawnpoint, 1)  
              dropship:SetTechId(kTechId.Shotgun)
              dropship:SetMapName(Shotgun.kMapName)
              local lulz = 4
              lulz = ConditionalValue(armory:GetIsInCombat(), 8, lulz)
                dropship.flyspeed = lulz
               self.lastmarinecreatedentity = Shared.GetTime()
               self.team1:SetTeamResources(self.team1:GetTeamResources()  - 2)
               spawned = true
               /*
    elseif hmgs <= 1 then
       if not spawned then
            local dropship = CreateEntity(Dropship.kMapName, spawnpoint, 1)  
              local lulz = 2
              lulz = ConditionalValue(armory:GetIsInCombat(), 8, lulz)
              dropship.flyspeed = lulz
              dropship:SetTechId(kTechId.HeavyRifle)
              dropship:SetMapName(HeavyRifle.kMapName)
         self.lastmarinecreatedentity = Shared.GetTime()
         self.team1:SetTeamResources(self.team1:GetTeamResources()  - 2)
               spawned = true
         end
         */
    elseif flamethrowers <= 1 then
       if not spawned then
            local dropship = CreateEntity(Dropship.kMapName, spawnpoint, 1)  
              local lulz = 2
              lulz = ConditionalValue(armory:GetIsInCombat(), 8, lulz)
              dropship.flyspeed = lulz
              dropship:SetTechId(kTechId.Flamethrower)
              dropship:SetMapName(Flamethrower.kMapName)
         self.lastmarinecreatedentity = Shared.GetTime()
         self.team1:SetTeamResources(self.team1:GetTeamResources()  - 2)
               spawned = true
         end
    elseif GLS <= 1 then
       if not spawned then
            local dropship = CreateEntity(Dropship.kMapName, spawnpoint, 1)  
              local lulz = 2
              lulz = ConditionalValue(armory:GetIsInCombat(), 8, lulz)
              dropship.flyspeed = lulz
              dropship:SetTechId(kTechId.GrenadeLauncher)
              dropship:SetMapName(GrenadeLauncher.kMapName)
         self.lastmarinecreatedentity = Shared.GetTime()
         self.team1:SetTeamResources(self.team1:GetTeamResources()  - 2)
               spawned = true
         end
    end
    
 end
 end
 
 end
 
end
function NS2Gamerules:SpawnCommandStationEnts(CC)
--kyle abent
local tres = 14
     if self:GetCanSpawnMarineEntity(tres,nil, CC:GetIsInCombat()) then 
local location = GetLocationForPoint(CC:GetOrigin())

if location then

local infantryportals = CC:GETIPCount()
local spawnpoint = CC:FindFreeSpace()
  if spawnpoint ~= nil then
   local spawned = false
          if infantryportals <= math.random(1,2) then
            local dropship = CreateEntity(Dropship.kMapName, spawnpoint, 1)  
              dropship:SetTechId(kTechId.InfantryPortal)
              dropship:SetMapName(InfantryPortal.kMapName)
         self.lastmarinecreatedentity = Shared.GetTime()
               self.team1:SetTeamResources(self.team1:GetTeamResources()  - tres)
               spawned= true
    end
    end
 end
 
 end
 
end
function NS2Gamerules:GetCanSpawnMarineEntity(trescount, timeywimey, isincombat)
   local canafford = self.team1:GetTeamResources() >= trescount
   if not timeywimey then
    local time = self.lastmarinecreatedentity + math.random(4,32)
    time = ConditionalValue(self.doorsopened or self.siegedoorsopened, time *.5, time)
    time = ConditionalValue(isincombat, time * math.random(.7, .90), time)
    time = time - (self.team1:GetTeamResources()/200) * time
    timeywimey = time
    end
        if timeywimey < Shared.GetTime() then
              return canafford
         end
end
function NS2Gamerules:SpawnCystsAtLocation(location, powerpoint)
   if self:GetCanSpawnAlienEntity(kCystSpawnCost, math.random(4,8)) then
            local extents = (location:GetOrigin().x + location:GetOrigin().y + location:GetOrigin().z) - (location.scale.x + location.scale.y + location.scale.z)
            local cysts = location:GetCystsInLocation(location, powerpoint)
            
               -- Print("cysts is %s", cysts)
            if cysts == 0 then 
              local cyst = CreateEntity(Cyst.kMapName, powerpoint:FindFreeSpace(), 2)
               self.team2:SetTeamResources(self.team2:GetTeamResources()  - 1)
               self.lastaliencreatedentity = Shared.GetTime()
             return 
             end
             
            local ratio = math.abs(extents/(cysts*kCystRedeployRange))
          --  Print("Cyst Ratio is %s for room %s", ratio, location.name)
            
            if ratio >= 4 then
           -- Print("Ratio is >= 4")
                   local nearestcyst = GetNearest(powerpoint:GetOrigin(), "Cyst", 2, function(ent) return GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(powerpoint:GetOrigin()) end)
                    if nearestcyst then
                    --   Print("nearestcyst is %s", nearestcyst)
                      local cyst = CreateEntity(Cyst.kMapName, nearestcyst:FindFreeSpawn(), 2)
                      self.team2:SetTeamResources(self.team2:GetTeamResources()  - 1)
                      self.lastaliencreatedentity = Shared.GetTime()
                      end
            end
            
            
   end

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
