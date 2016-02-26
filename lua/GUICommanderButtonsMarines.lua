// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUICommanderButtonsMarines.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages marine specific layout and updating for commander buttons.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUICommanderButtons.lua")

class 'GUICommanderButtonsMarines' (GUICommanderButtons)

GUICommanderButtonsMarines.kBackgroundTexture = "ui/marine_commander_textures.dds"

GUICommanderButtonsMarines.kNumberMarineButtonRows = 2
GUICommanderButtonsMarines.kNumberMarineButtonColumns = 4

function GUICommanderButtonsMarines:GetBackgroundTextureName()

    return GUICommanderButtonsMarines.kBackgroundTexture

end

function GUICommanderButtonsMarines:InitializeButtons()

    // One row of special buttons on top.
    GUICommanderButtonsMarines.kNumberMarineTopTabs = GUICommanderButtonsMarines.kNumberMarineButtonColumns
    // With the normal buttons below.
    GUICommanderButtonsMarines.kNumberMarineButtons = GUICommanderButtonsMarines.kNumberMarineButtonRows * GUICommanderButtonsMarines.kNumberMarineButtonColumns

    GUICommanderButtonsMarines.kButtonYOffset = 20 * GUIScale(kCommanderGUIsGlobalScale)

    GUICommanderButtonsMarines.kMarineTabXOffset = 37 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsMarines.kMarineTabYOffset = 30 * GUIScale(kCommanderGUIsGlobalScale)

    GUICommanderButtonsMarines.kMarineTabWidth = 99 * GUIScale(kCommanderGUIsGlobalScale)
    // Determines how much space is between each tab.
    GUICommanderButtonsMarines.kMarineTabSpacing = 4 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsMarines.kMarineTabTopHeight = 40 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsMarines.kMarineTabBottomHeight = 8 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsMarines.kMarineTabBottomOffset = 0 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsMarines.kMarineTabConnectorWidth = 109 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderButtonsMarines.kMarineTabConnectorHeight = 15 * GUIScale(kCommanderGUIsGlobalScale)

    self:InitializeHighlighter()
    
    local settingsTable = { }
    settingsTable.NumberOfTabs = GUICommanderButtonsMarines.kNumberMarineTopTabs
    settingsTable.TabXOffset = GUICommanderButtonsMarines.kMarineTabXOffset
    settingsTable.TabYOffset = GUICommanderButtonsMarines.kMarineTabYOffset
    settingsTable.TabWidth = GUICommanderButtonsMarines.kMarineTabWidth
    settingsTable.TabSpacing = GUICommanderButtonsMarines.kMarineTabSpacing
    settingsTable.TabTopHeight = GUICommanderButtonsMarines.kMarineTabTopHeight
    settingsTable.TabBottomHeight = GUICommanderButtonsMarines.kMarineTabBottomHeight
    settingsTable.TabBottomOffset = GUICommanderButtonsMarines.kMarineTabBottomOffset
    settingsTable.TabConnectorWidth = GUICommanderButtonsMarines.kMarineTabConnectorWidth
    settingsTable.TabConnectorHeight = GUICommanderButtonsMarines.kMarineTabConnectorHeight
    settingsTable.NumberOfColumns = GUICommanderButtonsMarines.kNumberMarineButtonColumns
    settingsTable.NumberOfButtons = GUICommanderButtonsMarines.kNumberMarineButtons
    settingsTable.ButtonYOffset = GUICommanderButtonsMarines.kButtonYOffset
    self:SharedInitializeButtons(settingsTable)

end