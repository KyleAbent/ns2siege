// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ShiftGhostModel.lua
//
//    Created by:   Juanjo Alfaro
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Hud/Commander/GhostModel.lua")

class 'ShiftGhostModel' (GhostModel)

function ShiftGhostModel:Initialize()

    GhostModel.Initialize(self)
    
end

function ShiftGhostModel:Destroy() 

    GhostModel.Destroy(self)
    
end

function ShiftGhostModel:SetIsVisible(isVisible)

    GhostModel.SetIsVisible(self, isVisible)
    
end

function ShiftGhostModel:Update()

    local modelCoords = GhostModel.Update(self)
    
    if modelCoords then        
        
        local player = Client.GetLocalPlayer()
        
      if player:isa("Commander") then  player:AddGhostGuide(Vector(modelCoords.origin), kEnergizeRange) end
        
    end
    
end
