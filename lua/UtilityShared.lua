//======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\UtilityShared.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// Includes utility function used by the GUIView VMs as well as the World VMs
// Move things over from Utility.lua as the GUIViews needs them
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================


local math_min, math_max, math_floor = math.min, math.max, math.floor

function Round(value, decimalPlaces)
    local mult = 10 ^ (decimalPlaces or 0)
    return math_floor(value * mult + 0.5) / mult
end

function Clamp(value, min, max)
    // fsfod says this is faster in LuaJIT
    return (math_min(math_max(value, min), max))
end

function ClampVector(vector, min, max)

    vector.x = Clamp(vector.x, min.x, max.x)
    vector.y = Clamp(vector.y, min.x, max.y)
    vector.z = Clamp(vector.z, min.x, max.z)

end

function Limit(x, limit1, limit2)

    if limit1 == limit2 then
        return limit1
    elseif limit1 < limit2 then
        return Clamp(x, limit1, limit2)
    else
        return Clamp(x, limit2, limit1)
    end
    
end

function Wrap(x, min, max)

    range = max - min
    
    if range == 0 then
        return min
    end
    
    local returnVal = x
    
    if returnVal < min then
        returnVal = returnVal + math.floor((max - returnVal) / range) * range
    end
    
    if returnVal >= max then
        returnVal = returnVal - math.floor((returnVal - min) / range) * range
    end
    
    return returnVal
    
end
