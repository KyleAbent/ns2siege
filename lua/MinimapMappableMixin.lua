// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========    
//    
// lua\MinimapMappableMixin.lua    
//    
//    Created by: Mats Olsson (mats.olsson@matsotech.se)
//
// Anything that wants to have a chance at being shown on the minimap must implement this mixin. 
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

// pure Client-side mixin

if Client then 

kHallucinationColor = Color(0.8, 0.6, 1, 1)
MinimapMappableMixin = CreateMixin( MinimapMappableMixin )
MinimapMappableMixin.type = "MinimapMappable"

MinimapMappableMixin.expectedMixins =
{
}

 -- define levels of activity:
 -- Inactive = invisible,
 -- Static = will not change,
 -- "Low" = change at 10Hz, "Medium" = 25Hz, "High" = framerate
kMinimapActivity = enum ( { "Static", "Low", "Medium", "High" } )

MinimapMappableMixin.expectedCallbacks =
{
    UpdateMinimapActivity = "Return a kMinimapActivity describing how active the entity will be on the minimap (or nil if not shown)",
    GetMapBlipType = "Return the type of mapblip for this entity",
    GetMapBlipColor = "Return the color of the mapblip",
    GetMapBlipTeam = "Return the kMapBlipTeam used for this mapblip"
}

MinimapMappableMixin.optionalCallbacks =
{
    GetMapBlipOriginOverride = "Return the origin for the mapblip - defaults to GetOrigin()",
    UpdateMinimapItemHook = "Called before the rest of the minimap item is updated"
}

MinimapMappableMixin.kTeamMapping =
{
    [kMinimapBlipTeam.Alien]          = { team = kMinimapBlipTeam.Alien,      active = true },
    [kMinimapBlipTeam.InactiveAlien]  = { team = kMinimapBlipTeam.Alien,      active = false },
    [kMinimapBlipTeam.FriendAlien]    = { team = kMinimapBlipTeam.Alien,      active = true },
    [kMinimapBlipTeam.Marine]         = { team = kMinimapBlipTeam.Marine,     active = true },
    [kMinimapBlipTeam.InactiveMarine] = { team = kMinimapBlipTeam.Marine,     active = false },
    [kMinimapBlipTeam.FriendMarine]   = { team = kMinimapBlipTeam.Marine,     active = true }
}

function MinimapMappableMixin.OnSameMinimapBlipTeam(blipTeam1, blipTeam2)
    return  
        (MinimapMappableMixin.kTeamMapping[blipTeam1] and MinimapMappableMixin.kTeamMapping[blipTeam2]) and
        (MinimapMappableMixin.kTeamMapping[blipTeam1].team == MinimapMappableMixin.kTeamMapping[blipTeam2].team)
end

function MinimapMappableMixin.MinimapBlipTeamIsActive(blipTeam)
    return (MinimapMappableMixin.kTeamMapping[blipTeam] and MinimapMappableMixin.kTeamMapping[blipTeam].active)
end


local function MixColor(dst, src, scalar)
    local invscalar = 1 - scalar
    dst.r =  dst.r * scalar + src.r * invscalar
    dst.g =  dst.g * scalar + src.g * invscalar
    dst.b =  dst.b * scalar + src.b * invscalar
    return dst
end


function MinimapMappableMixin.PulseRed()

    local anim = (math.cos(Shared.GetTime() * 10) + 1) * 0.5
    local color = Color()
    
    color.r = 1
    color.g = anim
    color.b = anim
    
    return color

end

function MinimapMappableMixin.PulseDarkRed(blipColor)

    local anim = (math.cos(Shared.GetTime() * 10) + 1) * 0.5
    local color = Color(1/3, 0, 0)

    MixColor(color, blipColor, anim)

    return color
end


function MinimapMappableMixin:GetMapBlipOrigin()
    if self.GetMapBlipOriginOverride then
        return self:GetMapBlipOriginOverride(playerTeam)
    end
    return self:GetOrigin()
end

-- convinience function to extract info from the data tables
function MinimapMappableMixin:InitMinimapItem(minimap, item)
    minimap:InitMinimapIcon(item, self:GetMapBlipType(), self:GetMapBlipTeam(minimap))
    
    item.prevBlipOrigin = nil
    item.prevBlipColor = nil
    
    if self.InitMinimapItemHook then
        self:InitMinimapItemHook(minimap, item)
    end
end

function MinimapMappableMixin:UpdateMinimapItem(minimap, item)
    -- if a big change happen (like change of team or type), set the
    -- self.resetMinimapItem to cause a reset
    if item.resetMinimapItem then
        self:InitMinimapItem(minimap, item)
    end
     
    minimap:UpdateBlipPosition(item, self:GetMapBlipOrigin())
    
    if self.UpdateMinimapItemHook then
        self:UpdateMinimapItemHook(minimap, item)
    end
    
    local blipColor = self:GetMapBlipColor(minimap,item)
    if blipColor ~= item.prevBlipColor then
        item.prevBlipColor = blipColor
        item:SetColor(blipColor)
    end
    
end

end