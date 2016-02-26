-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. ======
--
-- lua\menu\ServerEntry.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more inTableation, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/WindowUtility.lua")

kServerEntryHeight = 34 -- little bit bigger than highlight server
local kDefaultWidth = 350
local kModeratePing = 90
local kBadPing = 180

local kFavoriteIconSize = Vector(26, 26, 0)
local kFavoriteIconPos = Vector(5, 4, 0)
local kFavoriteTexture = PrecacheAsset("ui/menu/favorite.dds")
local kNonFavoriteTexture = PrecacheAsset("ui/menu/nonfavorite.dds")

local kFavoriteMouseOverColor = Color(1,1,0,1)
local kFavoriteColor = Color(1,1,1,0.9)

local kPrivateIconSize = Vector(26, 26, 0)
local kPrivateIconTexture = PrecacheAsset("ui/lock.dds")

local kSkillIconSize = Vector(26, 26, 0)
local kSkillIconTextures = {
    PrecacheAsset("ui/menu/skill_equal.dds"),
    PrecacheAsset("ui/menu/skill_low.dds"),
    PrecacheAsset("ui/menu/skill_high.dds")
}

local kYellow = Color(1, 1, 0)
local kGold = Color(212/255, 175/255, 55/255)
local kGreen = Color(0, 1, 0)
local kRed = Color(1, 0 ,0)

function SelectServerEntry(entry)

    local height = entry:GetHeight()
    local topOffSet = entry:GetBackground():GetPosition().y + entry:GetParent():GetBackground():GetPosition().y
    entry.scriptHandle.selectServer:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
    entry.scriptHandle.selectServer:SetIsVisible(true)
    MainMenu_SelectServer(entry:GetId(), entry.serverData)
    MainMenu_SelectServerAddress(entry.serverData.address)
    
end

class 'ServerEntry' (MenuElement)

function ServerEntry:Initialize()

    self:DisableBorders()
    
    MenuElement.Initialize(self)
    
    self.serverName = CreateTextItem(self, true)
    self.mapName = CreateTextItem(self, true)
    self.mapName:SetTextAlignmentX(GUIItem.Align_Center)
    self.ping = CreateTextItem(self, true)
    self.ping:SetTextAlignmentX(GUIItem.Align_Center)
    self.tickRate = CreateTextItem(self, true)
    self.tickRate:SetTextAlignmentX(GUIItem.Align_Center)

    self.modName = CreateTextItem(self, true)
    self.modName:SetTextAlignmentX(GUIItem.Align_Center)
    self.modName.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")

    self.playerCount = CreateTextItem(self, true)
    self.playerCount:SetTextAlignmentX(GUIItem.Align_Center)
    
    self.favorite = CreateGraphicItem(self, true)
    self.favorite:SetSize(kFavoriteIconSize)
    self.favorite:SetPosition(kFavoriteIconPos)
    self.favorite:SetTexture(kNonFavoriteTexture)
    self.favorite:SetColor(kFavoriteColor)
    
    self.private = CreateGraphicItem(self, true)
    self.private:SetSize(kPrivateIconSize)
    self.private:SetTexture(kPrivateIconTexture)
    
    self.playerSkill = CreateGraphicItem(self, true)
    self.playerSkill:SetSize(kSkillIconSize)
    self.playerSkill:SetTexture(kSkillIconTextures[1])
    self.playerSkill:SetColor(kGreen)
    self.playerSkill.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
    self.playerSkill.tooltipText = Locale.ResolveString("SERVERBROWSER_SKILL_TOOLTIP_1")
    
    self:SetFontName(Fonts.kAgencyFB_Small)
    
    self:SetTextColor(kWhite)
    self:SetHeight(kServerEntryHeight)
    self:SetWidth(kDefaultWidth)
    self:SetBackgroundColor(kNoColor)
    
    --Has no children, but just to keep sure, we do that.
    self:SetChildrenIgnoreEvents(true)
        
    local eventCallbacks =
    {
        OnMouseIn = function(self, buttonPressed)
            MainMenu_OnMouseIn()
        end,
        
        OnMouseOver = function(self)
        
            local height = self:GetHeight()
            local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
            self.scriptHandle.highlightServer:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
            self.scriptHandle.highlightServer:SetIsVisible(true)
            
            if GUIItemContainsPoint(self.favorite, Client.GetCursorPosScreen()) then
                self.favorite:SetColor(kFavoriteMouseOverColor)
            else
                self.favorite:SetColor(kFavoriteColor)
            end
            
            if GUIItemContainsPoint(self.playerSkill, Client.GetCursorPosScreen()) then
                self.playerSkill.tooltip:SetText(self.playerSkill.tooltipText)
                self.playerSkill.tooltip:Show()
            elseif self.modName.tooltipText and GUIItemContainsPoint(self.modName, Client.GetCursorPosScreen()) then
                self.modName.tooltip:SetText(self.modName.tooltipText)
                self.modName.tooltip:Show()
            else
                self.modName.tooltip:Hide()
            end
        end,
        
        OnMouseOut = function(self)
        
            self.scriptHandle.highlightServer:SetIsVisible(false)
            self.favorite:SetColor(kFavoriteColor)
            self.playerSkill.tooltip:Hide()
        
        end,
        
        OnMouseDown = function(self, key, doubleClick)
        
            if key == InputKey.MouseButton1 then
            
                self.scriptHandle.serverDetailsWindow:SetServerData(self.serverData, self:GetId() or 0)
                 self.scriptHandle.serverDetailsWindow:SetIsVisible(true)
                 
            end
            
            if GUIItemContainsPoint(self.favorite, Client.GetCursorPosScreen()) then
            
                if not self.serverData.favorite then
                
                    self.favorite:SetTexture(kFavoriteTexture)
                    self.serverData.favorite = true
                    SetServerIsFavorite(self.serverData, true)
                    
                else
                
                    self.favorite:SetTexture(kNonFavoriteTexture)
                    self.serverData.favorite = false
                    SetServerIsFavorite(self.serverData, false)
                    
                end
                
                self.parentList:UpdateEntry(self.serverData, true)
                
            else
            
                SelectServerEntry(self)
                
                if doubleClick then
                
                    if (self.timeOfLastClick ~= nil and (Shared.GetTime() < self.timeOfLastClick + 0.3)) then
                        self.scriptHandle:ProcessJoinServer()
                    end
                    
                else
                
                    -- < 0 indicates that this server hasn't been queried yet.
                    -- This happens when a server is a favorite and hasn't
                    -- been downloaded yet.
                    if self:GetId() >= 0 then
                    
                        local function RefreshCallback(serverIndex)
                            MainMenu_OnServerRefreshed(serverIndex)
                        end
                        Client.RefreshServer(self:GetId(), RefreshCallback)
                        
                    else
                    
                        --local function RefreshCallback(name, ping, players)
                        --    MainMenu_OnServerRefreshed(serverIndex)
                        --end
                        --Client.RefreshServer(self.serverData.address, RefreshCallback)
                        
                    end
                    
                end
                
                self.timeOfLastClick = Shared.GetTime()
                
            end
            
        end
    }
    
    self:AddEventCallbacks(eventCallbacks)

end

function ServerEntry:SetParentList(parentList)
    self.parentList = parentList
end

function ServerEntry:SetFontName(fontName)

    self.serverName:SetFontName(fontName)
    self.serverName:SetScale(GetScaledVector())
    self.mapName:SetFontName(fontName)
    self.mapName:SetScale(GetScaledVector())
    self.ping:SetFontName(fontName)
    self.ping:SetScale(GetScaledVector())
    self.tickRate:SetFontName(fontName)
    self.tickRate:SetScale(GetScaledVector())
    self.modName:SetFontName(fontName)
    self.modName:SetScale(GetScaledVector())
    self.playerCount:SetFontName(fontName)
    self.playerCount:SetScale(GetScaledVector())

end

function ServerEntry:SetTextColor(color)

    self.serverName:SetColor(color)
    self.mapName:SetColor(color)
    self.ping:SetColor(color)
    self.tickRate:SetColor(color)
    self.modName:SetColor(color)
    self.playerCount:SetColor(color)
    
end

function ServerEntry:SetIsFiltered(filtered)
    self.filtered = filtered
end

function ServerEntry:GetIsFiltered()
    return self.filtered == true
end

--[[
-- Returns the local clients hive skill or -1 if the hive service is not avaible
 ]]
function Client.GetSkill()
    return tonumber(GetGUIMainMenu().playerSkill) or -1
end

function Client.GetScore()
    return GetGUIMainMenu().playerScore or -1
end

function Client.GetLevel()
    return GetGUIMainMenu().playerLevel or -1
end

function ServerEntry:SetServerData(serverData)

    PROFILE("ServerEntry:SetServerData")

    if self.serverData ~= serverData then
    
        local numReservedSlots = GetNumServerReservedSlots(serverData.serverId)
        self.playerCount:SetText(string.format("%d/%d", serverData.numPlayers, (serverData.maxPlayers - numReservedSlots)))
        if serverData.numPlayers >= serverData.maxPlayers then
            self.playerCount:SetColor(kRed)
        elseif serverData.numPlayers >= serverData.maxPlayers - numReservedSlots then
            self.playerCount:SetColor(kYellow)
        else
            self.playerCount:SetColor(kWhite)
        end 
     
        self.serverName:SetText(serverData.name)
        
        if serverData.rookieOnly then
            self.serverName:SetColor(kGreen)
        else
            self.serverName:SetColor(kWhite)
        end
        
        self.mapName:SetText(serverData.map)
        
        self.ping:SetText(ToString(serverData.ping))    
        if serverData.ping >= kBadPing then
            self.ping:SetColor(kRed)
        elseif serverData.ping >= kModeratePing then
            self.ping:SetColor(kYellow)
        else    
            self.ping:SetColor(kGreen)
        end
        
        if serverData.performanceScore ~= nil then
            self.tickRate:SetColor( ServerPerformanceData.GetColor(serverData.performanceScore) )
            self.tickRate:SetText( ServerPerformanceData.GetPerformanceText(serverData.performanceQuality, serverData.performanceScore))
            -- Log("%s: score %s, q %s", serverData.name, serverData.performanceScore, serverData.performanceQuality)
        else
            self.tickRate:SetColor(Color(0.5, 0.5, 0.5, 1))
            self.tickRate:SetText("??")
        end
        self.private:SetIsVisible(serverData.requiresPassword)
        
        self.modName:SetText(serverData.mode)
        self.modName:SetColor(kWhite)
        self.modName.tooltipText = nil

        if serverData.ranked then
            self.modName:SetColor(kGold)
            self.modName.tooltipText = Locale.ResolveString(string.format("SERVERBROWSER_RANKED_TOOLTIP"))
        end
        
        if serverData.favorite then
            self.favorite:SetTexture(kFavoriteTexture)
        else
            self.favorite:SetTexture(kNonFavoriteTexture)
        end
        
        local skillColor = kGreen
        local skillAngle = 0
        local skillTextureId = 1
        local toolTipId = 1
        local skill = Client.GetSkill()
        if skill > 0 and serverData.numPlayers > 0 then
            local skillFraction = (  skill - serverData.playerSkill ) / skill
            
            if skillFraction > 0.1 then 
                skillAngle = math.pi
                toolTipId = toolTipId + 2
            end
            
            if math.abs(skillFraction) >= 0.3 then
                skillTextureId = 3
                toolTipId = toolTipId + 2
                skillColor = kRed
            elseif math.abs(skillFraction) > 0.1 then
                skillTextureId = 2
                toolTipId = toolTipId + 1
                skillColor = kYellow
            end
        end
        
        self.playerSkill:SetTexture(kSkillIconTextures[skillTextureId])
        self.playerSkill:SetColor(skillColor)
        self.playerSkill:SetRotation(Vector( 0, 0, skillAngle ))
        self.playerSkill.tooltipText = Locale.ResolveString(string.format("SERVERBROWSER_SKILL_TOOLTIP_%s", toolTipId))
        
        self:SetId(serverData.serverId)
        self.serverData = { }
        for name, value in pairs(serverData) do
            self.serverData[name] = value
        end
        
    end
    
end

function ServerEntry:SetWidth(width, isPercentage, time, animateFunc, callBack)

    if width ~= self.storedWidth then
        -- The percentages and padding for each column are defined in the CSS
        -- We can use them here to set the position correctly instead of guessing like previously
        MenuElement.SetWidth(self, width, isPercentage, time, animateFunc, callBack)
        local currentPos = 0
        local currentWidth = self.favorite:GetSize().x
        local currentPercentage = width * 0.03
        local kPaddingSize = 4
        self.favorite:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), GUIScale(2), 0))
        
        currentPos = currentPercentage + kPaddingSize
        currentPercentage = width * 0.03
        currentWidth = self.private:GetSize().x
        self.private:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), GUIScale(2), 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.06
        currentWidth = self.playerSkill:GetSize().x
        self.playerSkill:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), GUIScale(2), 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.35
        self.serverName:SetPosition(Vector((currentPos + kPaddingSize), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.07
        currentWidth = GUIScale(self.modName:GetTextWidth(self.modName:GetText()))
        self.modName:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.15
        currentWidth = GUIScale(self.mapName:GetTextWidth(self.mapName:GetText()))
        self.mapName:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.14
        currentWidth = GUIScale(self.playerCount:GetTextWidth(self.playerCount:GetText()))
        self.playerCount:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.075
        currentWidth = GUIScale(self.tickRate:GetTextWidth(self.tickRate:GetText()))
        self.tickRate:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.075
        currentWidth = GUIScale(self.ping:GetTextWidth(self.ping:GetText()))
        self.ping:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        self.storedWidth = width
    
    end

end

function ServerEntry:UpdateVisibility(minY, maxY, desiredY)

    if not self:GetIsFiltered() then

        if not desiredY then
            desiredY = self:GetBackground():GetPosition().y
        end
        
        local yPosition = self:GetBackground():GetPosition().y
        local ySize = self:GetBackground():GetSize().y
        
        local inBoundaries = ((yPosition + ySize) > minY) and yPosition < maxY
        self:SetIsVisible(inBoundaries)
        
    else
        self:SetIsVisible(false)
    end    

end

function ServerEntry:SetBackgroundTexture()
    Print("ServerEntry:SetBackgroundTexture")
end

-- do nothing, save performance, save the world
function ServerEntry:SetCSSClass(cssClassName, updateChildren)
end

function ServerEntry:GetTagName()
    return "serverentry"
end

function ServerEntry:SetId(id)

    assert(type(id) == "number")
    self.rowId = id
    
end

function ServerEntry:GetId()
    return self.rowId
end