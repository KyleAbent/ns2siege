// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ResourceTower_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Generic resource structure that marine and alien structures inherit from.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function ResourceTower:GetIsCollecting()
    return GetIsUnitActive(self) and GetGamerules():GetGameStarted()
end


