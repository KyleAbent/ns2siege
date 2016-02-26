//======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\WeaponUtility.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// Weapon utility functions.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

/**
 * Pass in a target direction and a spread amount in radians and a new
 * direction vector is returned. Pass in a function that returns a random
 * number between and including 0 and 1.
 */
function CalculateSpread(directionCoords, spreadAmount, randomizer)

    local spreadAngle = spreadAmount / 2
    
    local randomAngle = randomizer() * math.pi * 2
    local randomRadius = randomizer() * math.tan(spreadAngle)
    
    local spreadDirection = directionCoords.zAxis +
                            (directionCoords.xAxis * math.cos(randomAngle) +
                             directionCoords.yAxis * math.sin(randomAngle)) * randomRadius
    
    spreadDirection:Normalize()
    
    return spreadDirection

end

function DebugFireRate(weapon)

    if Server then
    
        if not weapon.timeLastShootDebug then
            weapon.timeLastShootDebug = 0
        end
    
        local delta = Shared.GetTime() - weapon.timeLastShootDebug        
        DebugPrint("%s: %.3f seconds since last shot", ToString(weapon), delta)            
        weapon.timeLastShootDebug = Shared.GetTime()
        
    end

end