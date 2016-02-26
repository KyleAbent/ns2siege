// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GatherList.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/GatherEntry.lua")
Script.Load("lua/Globals.lua")

local kDefaultWidth = 350
local kDefaultColumnHeight = 64
local kDefaultBackgroundColor = Color(0.5, 0.5, 0.5, 0.4)

class 'GatherList' (MenuElement)

local function GetBoundaries(self)

    local minY = -self:GetParent():GetContentPosition().y
    local maxY = minY + self:GetParent().contentStencil:GetSize().y
    
    return minY, maxY
    
end

local function RenderGatherList(self)

    PROFILE("GatherList:RenderGatherList")
    
    local renderPosition = 0
    
    local gatherListWidth = self:GetParent():GetWidth()
    local gatherListSize = #self.gatherEntries
    local numGathers = #self.tableData

    // Add, remove entries, but reuse as many GUIItems as possible.
    if gatherListSize < numGathers then
    
        for i = 1, numGathers - gatherListSize do
        
            local entry = CreateMenuElement(self, 'GatherEntry', false)
            table.insert(self.gatherEntries, entry)

        end
        
    elseif gatherListSize > numGathers then
    
        for i = 1, gatherListSize - numGathers do
        
            self.gatherEntries[#self.gatherEntries]:Uninitialize()
            table.remove(self.gatherEntries, #self.gatherEntries)
            
        end
        
    end
    
    local minY, maxY = GetBoundaries(self)
    self.gameTypes = {}
    
    local iconsPerRow = math.floor(gatherListWidth / kGatherEntryWidth)
    
    for i = 1, #self.tableData do
    
        local gatherEntry = self.gatherEntries[i]
        
        local xPos = ((i-1) % iconsPerRow) * kGatherEntryWidth
        local yPos = math.floor((i-1) / iconsPerRow) * kGatherEntryHeight

        gatherEntry:SetBackgroundPosition(Vector(xPos, yPos, 0))
        gatherEntry:SetGatherData(self.tableData[i])
        
        //gatherEntry:UpdateVisibility(minY, maxY, renderPosition * kGatherEntryHeight)      
        
    end

    self:SetHeight((1 + math.floor(#self.tableData / iconsPerRow)) * kGatherEntryHeight)
    self:SetWidth(gatherListWidth)

end

function GatherList:Initialize()

    self:DisableBorders()
    
    MenuElement.Initialize(self)
    
    self:SetWidth(kDefaultWidth)
    self:SetBackgroundColor(kNoColor)
    
    self.tableData = { }
    self.gatherEntries = { }
    self.filter = { }
    
    self.numEntries = 0
    
end

function GatherList:Uninitialize()

    MenuElement.Uninitialize(self)
    
    self.tableData = { }
    self.gatherEntries = { }
    
end

function GatherList:GetTagName()
    return "gatherlist"
end

function GatherList:ClearChildren()

    MenuElement.ClearChildren(self)
    
    self.tableData = { }
    self.gatherEntries = { }
    self.numEntries = 0
    
end

function GatherList:GetNumEntries()
    return self.numEntries
end    

function GatherList:AddEntry(gatherEntry)

    table.insert(self.tableData, gatherEntry)
    self.numEntries = self.numEntries + 1
    
end

function GatherList:UpdateEntry(gatherEntry)

    local updated = false

    for s = 1, #self.tableData do
    
        if self.tableData[s].gatherId == gatherEntry.gatherId then
        
            for k, v in pairs(gatherEntry) do
                self.tableData[s][k] = v
            end
            updated = true
            
            break
            
        end
        
    end
    
    return updated
    
end

function GatherList:RenderNow()
    RenderGatherList(self)
end