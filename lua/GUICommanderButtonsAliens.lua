// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUICommanderButtonsAliens.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages alien specific layout and updating for commander buttons.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUICommanderButtons.lua")

class 'GUICommanderButtonsAliens' (GUICommanderButtons)

GUICommanderButtonsAliens.kBackgroundTexture = "ui/alien_commander_background.dds"

GUICommanderButtonsAliens.kNumberAlienButtonRows = 2
GUICommanderButtonsAliens.kNumberAlienButtonColumns = 4

function GUICommanderButtonsAliens:GetBackgroundTextureName()

    return GUICommanderButtonsAliens.kBackgroundTexture

end

function GUICommanderButtonsAliens:InitializeButtons()

    // One row of special buttons on top.
    GUICommanderButtonsAliens.kNumberMarineTopTabs = GUICommanderButtonsAliens.kNumberAlienButtonColumns
    // With the normal buttons below.
    GUICommanderButtonsAliens.kNumberAlienButtons = GUICommanderButtonsAliens.kNumberAlienButtonRows * GUICommanderButtonsAliens.kNumberAlienButtonColumns

    GUICommanderButtonsAliens.kButtonYOffset = 20 * GUIScale(kCommanderGUIsGlobalScale)

    GUICommanderButtonsAliens.kMarineTabXOffset = 37 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsAliens.kMarineTabYOffset = 30 * GUIScale(kCommanderGUIsGlobalScale)

    GUICommanderButtonsAliens.kMarineTabWidth = 99 * GUIScale(kCommanderGUIsGlobalScale)
    // Determines how much space is between each tab.
    GUICommanderButtonsAliens.kAlienTabSpacing = 4 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsAliens.kAlienTabTopHeight = 40 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsAliens.kAlienTabBottomHeight = 8 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsAliens.kAlienTabBottomOffset = 0 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsAliens.kAlienTabConnectorWidth = 109 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsAliens.kAlienTabConnectorHeight = 15 * GUIScale(kCommanderGUIsGlobalScale)

    self:InitializeHighlighter()
    
    local settingsTable = { }
    settingsTable.NumberOfTabs = GUICommanderButtonsAliens.kNumberMarineTopTabs
    settingsTable.TabXOffset = GUICommanderButtonsAliens.kMarineTabXOffset
    settingsTable.TabYOffset = GUICommanderButtonsAliens.kMarineTabYOffset
    settingsTable.TabWidth = GUICommanderButtonsAliens.kMarineTabWidth
    settingsTable.TabSpacing = GUICommanderButtonsAliens.kAlienTabSpacing
    settingsTable.TabTopHeight = GUICommanderButtonsAliens.kAlienTabTopHeight
    settingsTable.TabBottomHeight = GUICommanderButtonsAliens.kAlienTabBottomHeight
    settingsTable.TabBottomOffset = GUICommanderButtonsAliens.kAlienTabBottomOffset
    settingsTable.TabConnectorWidth = GUICommanderButtonsAliens.kAlienTabConnectorWidth
    settingsTable.TabConnectorHeight = GUICommanderButtonsAliens.kAlienTabConnectorHeight
    settingsTable.NumberOfColumns = GUICommanderButtonsAliens.kNumberAlienButtonColumns
    settingsTable.NumberOfButtons = GUICommanderButtonsAliens.kNumberAlienButtons
    settingsTable.ButtonYOffset = GUICommanderButtonsAliens.kButtonYOffset
    self:SharedInitializeButtons(settingsTable)
    
end