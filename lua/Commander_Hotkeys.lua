// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Commander_Hotkeys.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Handle commander hotkeys. This will change to a cleaner solution later.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function Commander:HandleCommanderHotkeys(input)
local grid_1 = Client.GetOptionString("input/Grid1", "Q")
local grid_2 = Client.GetOptionString("input/Grid2", "W")
local grid_3 = Client.GetOptionString("input/Grid3", "E")
local grid_4 = Client.GetOptionString("input/Grid4", "A")
local grid_5 = Client.GetOptionString("input/Grid5", "S")
local grid_6 = Client.GetOptionString("input/Grid6", "D")
local grid_7 = Client.GetOptionString("input/Grid7", "F")
local grid_8 = Client.GetOptionString("input/Grid8", "Z")
local grid_9 = Client.GetOptionString("input/Grid9", "X")
local grid_10 = Client.GetOptionString("input/Grid10", "C")
local grid_11 = Client.GetOptionString("input/Grid11", "V")

gKey = {
// Hotkeys
None                = 0, 
Q                   = 1,                
W                   = 2,
E                   = 3,
R                   = 4,
T                   = 5,
Y                   = 6,
U                   = 7,
I                   = 8,
O                   = 9,
P                   = 10,
A                   = 11,
S                   = 12,
D                   = 13,
F                   = 14,
G                   = 15,
H                   = 16,
J                   = 17,
K                   = 18,
L                   = 19,
Z                   = 20,
X                   = 21,
C                   = 22,
V                   = 23,
B                   = 24,
N                   = 25,
M                   = 26,
Space               = 27,
ESC                 = 28
}
local ComKey1 = gKey[grid_1]
local ComKey2 = gKey[grid_2]
local ComKey3 = gKey[grid_3]
local ComKey4 = gKey[grid_4]
local ComKey5 = gKey[grid_5]
local ComKey6 = gKey[grid_6]
local ComKey7 = gKey[grid_7]
local ComKey8 = gKey[grid_8]
local ComKey9 = gKey[grid_9]
local ComKey10 = gKey[grid_10]
local ComKey11 = gKey[grid_11]

kGridHotkeys =
{
    ComKey1, ComKey2, ComKey3, "",
    ComKey4, ComKey5, ComKey6, ComKey7,
    ComKey8, ComKey9, ComKey10, ComKey11,
}

    if input.hotkey ~= 0 then
    
        for index, hotkey in ipairs(kGridHotkeys) do
        
            if (input.hotkey == hotkey) and self.menuTechButtonsAllowed and self.menuTechButtonsAllowed[index] and self.menuTechButtonsAffordable and self.menuTechButtonsAffordable[index] and not MainMenu_GetIsOpened() then
            
                // Check if the last hotkey was released.
                if hotkey ~= nil and self.lastHotkeyIndex ~= index then
                
                    self.lastHotkeyIndex = nil
                    
                end
                
                // Check if a new hotkey was pressed. Don't allow the last
                // key pressed unless it has been released first.
                if hotkey ~= nil and input.hotkey == hotkey and self.lastHotkeyIndex ~= index then
                    
                    self:SetHotkeyHit(index)
                    self.lastHotkeyIndex = index
                    CommanderUI_OnButtonClicked()
                    
                    break
                    
                end
                    
            end
            
        end
        
    else
    
        self.lastHotkeyIndex = nil
        
    end
    
end

gHotkeyDescriptions = { 
    [Move.A] = "A",
    [Move.B] = "B",
    [Move.C] = "C",
    [Move.D] = "D",
    [Move.E] = "E",
    [Move.F] = "F",
    [Move.G] = "G",
    [Move.H] = "H",
    [Move.I] = "I",
    [Move.J] = "J",
    [Move.K] = "K",
    [Move.L] = "L",
    [Move.M] = "M",
    [Move.N] = "N",
    [Move.O] = "O",
    [Move.P] = "P",
    [Move.Q] = "Q",
    [Move.R] = "R",
    [Move.S] = "S",
    [Move.T] = "T",
    [Move.U] = "U",
    [Move.V] = "V",
    [Move.W] = "W",
    [Move.X] = "X",
    [Move.Y] = "Y",
    [Move.Z] = "Z",         
}
