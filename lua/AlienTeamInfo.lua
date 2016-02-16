// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/AlienTeamInfo.lua
//
// AlienTeamInfo is used to sync information about a team to clients.
// Only alien team players (and spectators) will receive the information about number
// of shells, spurs or veils.
//
// Created by Andreas Urwalek (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TeamInfo.lua")

class 'AlienTeamInfo' (TeamInfo)

AlienTeamInfo.kMapName = "AlienTeamInfo"

local networkVars =
{
    numHives = "integer (0 to 10)",
    eggCount = "integer (0 to 120)",
    bioMassLevel = "integer (0 to 12)",
    bioMassAlertLevel = "integer (0 to 12)",
    maxBioMassLevel = "integer (0 to 12)",
    veilLevel = "integer (0 to 3)",
    spurLevel = "integer (0 to 3)",
    shellLevel = "integer (0 to 3)",
}

function AlienTeamInfo:OnCreate()

    TeamInfo.OnCreate(self)
    
    self.numHives = 0
    self.eggCount = 0
    self.bioMassLevel = 0
    self.bioMassAlertLevel = 0
    self.maxBioMassLevel = 0
    self.veilLevel = 0
    self.spurLevel = 0
    self.shellLevel = 0

end

if Server then

    local function GetBuiltStructureCount(className, teamNum)
    
        local count = 0
    
        for _, structure in ipairs(GetEntitiesForTeam(className, teamNum)) do
        
            if structure:GetIsBuilt() and structure:GetIsAlive() then
                count = count + 1
            end
        
        end
    
        return count
    
    end

    function AlienTeamInfo:Reset()
    
		TeamInfo.Reset( self ) 
		
        self.numHives = 0
        self.eggCount = 0
        self.bioMassLevel = 0
        self.bioMassAlertLevel = 0
        self.maxBioMassLevel = 0
        self.veilLevel = 0
        self.spurLevel = 0
        self.shellLevel = 0
        
    end

    function AlienTeamInfo:OnUpdate(deltaTime)
    
        TeamInfo.OnUpdate(self, deltaTime)
        
        local team = self:GetTeam()
        if team then
        
            self.numHives = team:GetNumHives()
            self.eggCount = team:GetActiveEggCount()
            self.bioMassLevel = Clamp(team:GetBioMassLevel(), 0, 12)
            self.bioMassAlertLevel = Clamp(team:GetBioMassAlertLevel(), 0 , 12)
            self.maxBioMassLevel = Clamp(team:GetMaxBioMassLevel(), 0 , 12)
            
            local veillevel =  self:GetUpgradeLevels() or 0
            local spurlevel = self:GetUpgradeLevels() or 0
            local shelllevel = self:GetUpgradeLevels() or 0
            
            self.veilLevel = veillevel
            self.spurLevel = spurlevel
            self.shellLevel = shelllevel

        end
        
    end

end
function AlienTeamInfo:GetUpgradeLevels()
           local bioMass = self.bioMassLevel
          return Clamp(bioMass / 3, 0, 3)
end
function AlienTeamInfo:GetNumHives()
    return self.numHives
end

function AlienTeamInfo:GetBioMassLevel()
    return self.bioMassLevel
end

function AlienTeamInfo:GetBioMassAlertLevel()
    return self.bioMassAlertLevel
end

function AlienTeamInfo:GetMaxBioMassLevel()
    return self.maxBioMassLevel
end

function AlienTeamInfo:GetEggCount()
    return self.eggCount
end

Shared.LinkClassToMap("AlienTeamInfo", AlienTeamInfo.kMapName, networkVars)