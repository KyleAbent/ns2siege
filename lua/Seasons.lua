-- ======= Copyright (c) 2015-2015, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Seasons.lua
--
--    Created by:   Mats Olsson (mats.olsson@matsotech.se)
--
-- ========= For more information, visit us at http://www.unknownworlds.com ====================='


-- Determine season by date (or config file) and enable/disable various map layers and commands depending on season

Seasons = {}
Seasons.kPropertyKey = "Season"
Seasons.kWinter = "Winter"
Seasons.kFall = "Fall"
Seasons.kNone = "None"
Seasons.kSeasonKeys = { [Seasons.kFall] = true, [Seasons.kWinter] = true, [Seasons.kNone]=true }

-- We need to set the season property BEFORE other scripts that depends on it load,
-- so Seasons.lua needs to be included early on the server side (the client will have them set
-- before the scripts starts loading)
if Server then

    local function GetDate()
        local date = os.date("*t", Shared.GetSystemTime())
        return date.month, date.day
    end

    function SetServerSeason(overrideSeason, overrideMonth)

        local season = Seasons.kNone

        if overrideSeason and Seasons.kSeasonKeys[overrideSeason] then
            season = overrideSeason
        else

            local month, day = GetDate()
            if overrideMonth and overrideMonth > 0 and overrideMonth < 13 then
                month = overrideMonth
                day = 14
            end

            if (month == 10 and day >= 15) or (month == 11 and day <= 15) then
                season =  Seasons.kFall
            elseif (month == 12 and day >= 15) or (month == 1 and day <= 15) then
                season = Seasons.kWinter
            end

        end

        Server.SetServerProperty(Seasons.kPropertyKey, season)

    end

end


function GetSeason()
    return Shared.GetServerProperty(Seasons.kPropertyKey)
end


if Client then
    if GetSeason() == Seasons.kFall then
        Locale.substitutions["WELCOME_TO_READY_ROOM"] = "WELCOME_TO_READY_ROOM_HALLOWEEN"
    end
    if GetSeason() == Seasons.kWinter then
        Locale.substitutions["WELCOME_TO_READY_ROOM"] = "WELCOME_TO_READY_ROOM_HOLIDAY"
    end
end


local kSeasonGroupData = {
    SeasonalFall = { Seasons.kFall, true },
    SeasonalWinter = { Seasons.kWinter, true },
    SeasonalFallExclude = { Seasons.kFall, false }, 
    SeasonalWinterExclude = { Seasons.kWinter, false },
}

-- Return true if a group is active in the given season
-- A group that isn't affected by seasons are always active (not part of the kSeasonGroupData)
-- A group in the table will be affected
-- * if the second value is true, then it is ONLY active when the season matches
-- * if the second value is false, then it is active if the season does NOT match
function IsGroupActiveInSeason(groupName, season)
 
    local entry = kSeasonGroupData[groupName]
    if entry then
        local seasonMatches = entry[1] == season
        local active = seasonMatches == entry[2]
        -- Log("Group %s is active=%s in season %s", groupName, active, season)
        return active
    end
    return true
    
end

function UpdateMapForSeasons()

    local season = GetSeason()
    
    if season == Seasons.kFall then 
        Shared.PreLoadSetGroupNeverVisible(kSeasonalWinterName)   
        Shared.PreLoadSetGroupPhysicsId(kSeasonalWinterName, 0)
		Shared.PreLoadSetGroupNeverVisible(kSeasonalFallExcludeName)   
        Shared.PreLoadSetGroupPhysicsId(kSeasonalFallExcludeName, 0)
    elseif season == Seasons.kWinter then
        Shared.PreLoadSetGroupNeverVisible(kSeasonalFallName)   
        Shared.PreLoadSetGroupPhysicsId(kSeasonalFallName, 0)   
        Shared.PreLoadSetGroupNeverVisible(kSeasonalWinterExcludeName)   
        Shared.PreLoadSetGroupPhysicsId(kSeasonalWinterExcludeName, 0)   
    else
        Shared.PreLoadSetGroupNeverVisible(kSeasonalFallName)   
        Shared.PreLoadSetGroupPhysicsId(kSeasonalFallName, 0)   
        Shared.PreLoadSetGroupNeverVisible(kSeasonalWinterName)   
        Shared.PreLoadSetGroupPhysicsId(kSeasonalWinterName, 0)   
    end
    
end

function FireSeasonalProjectile(player)
    
    local season = GetSeason()
    
    if season == Seasons.kFall then
        FireCandyProjectile(player)
    elseif season == Seasons.kWinter then
        FireSnowballProjectile(player)
    end

end

function IsSeasonForThrowing()
    local season = GetSeason()
    return season == Seasons.kFall or season == Seasons.kWinter
end