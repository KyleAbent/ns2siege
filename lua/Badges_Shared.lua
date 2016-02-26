
local function MakeBadgeInfo(name)
    return {
        name = name,
        unitStatusTexture = "ui/badges/"..name..".dds",
        scoreboardTexture = "ui/badges/"..name.."_20.dds",
    }
end

local function MakeBadgeInfo2(name, ddsPrefix)
    return {
        name = name,
        unitStatusTexture = "ui/badges/"..ddsPrefix..".dds",
        scoreboardTexture = "ui/badges/"..ddsPrefix.."_20.dds",
    }
end

local function MakeWCBadgeInfo(ddsPrefix)
    return {
        name = ddsPrefix,
        unitStatusTexture = "ui/badges/"..ddsPrefix..".dds",
        scoreboardTexture = "ui/badges/"..ddsPrefix.."_20.dds",
    }
end

// All non-tier badges go here
gBadgesData =
{
    MakeBadgeInfo("dev"),
    MakeBadgeInfo("dev_retired"),
    MakeBadgeInfo("maptester"),
    MakeBadgeInfo("playtester"),
    MakeBadgeInfo("ns1_playtester"),
    MakeBadgeInfo2("constellation", "constelation"),
    MakeBadgeInfo("hughnicorn"),
    MakeBadgeInfo("squad5_blue"),
    MakeBadgeInfo("squad5_silver"),
    MakeBadgeInfo("squad5_gold"),
    MakeBadgeInfo("commander"),
    MakeBadgeInfo("community_dev"),

    MakeBadgeInfo2("reinforced1", "game_tier1_blue"),
    MakeBadgeInfo2("reinforced2", "game_tier2_silver"),
    MakeBadgeInfo2("reinforced3", "game_tier3_gold"),
    MakeBadgeInfo2("reinforced4", "game_tier4_diamond"),
    MakeBadgeInfo2("reinforced5", "game_tier5_shadow"),
    MakeBadgeInfo2("reinforced6", "game_tier6_onos"),
    MakeBadgeInfo2("reinforced7", "game_tier7_Insider"),
    MakeBadgeInfo2("reinforced8", "game_tier8_GameDirector"),

    MakeWCBadgeInfo("wc2013_supporter"),
    MakeWCBadgeInfo("wc2013_silver"),
    MakeWCBadgeInfo("wc2013_gold"),
    MakeWCBadgeInfo("wc2013_shadow"),
    
    // The only DLC one
    { name = "pax2012",
        productId = 4931,
        unitStatusTexture = "ui/badges/badge_pax2012.dds",
        scoreboardTexture = "ui/badges/badge_pax2012.dds"}
}

function Badge2NetworkVarName( badgeName )
    return "has_"..badgeName.."_badge"
end

function Badges_GetMaxBadges()
    return #gBadgesData
end

function GetBadgeFormalName(name)
    local nameString = string.upper(string.format("BADGE_%s", name))
    local fullString = Locale.ResolveString(nameString)
    if fullString ~= nameString then
        return fullString
    end
    
    return "Custom Badge"
end

//----------------------------------------
//  Create network message spec
//----------------------------------------

local kBadgesMessage = 
{
    clientId = "integer",
}

for _,badge in ipairs(gBadgesData) do
    kBadgesMessage[ Badge2NetworkVarName( badge.name ) ] = "integer"
end

Shared.RegisterNetworkMessage("ClientBadges", kBadgesMessage)
