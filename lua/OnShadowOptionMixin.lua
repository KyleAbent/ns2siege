// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\OnShadowOptionMixin.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Allow entities to register as listeners to the shadow graphics option
//
// Client-only mixin

OnShadowOptionMixin = CreateMixin( OnShadowOptionMixin )
OnShadowOptionMixin.type = "OnShadowOption"

OnShadowOptionMixin.expectedCallbacks =
{
    OnShadowOptionChanged = "Be notified of a change in the shadow graphics option setting",
}

function OnShadowOptionMixin:__initmixin()
    self:OnShadowOptionChanged( OnShadowOptionMixin.currentShadowOption )
end

local lastTimeChecked = 0
local kCheckInterval = 1
OnShadowOptionMixin.currentShadowOption = nil

local function OnUpdateClient()
   Client.SetDebugText("OnShadowOption.OnUpdateClient entry")
    local now = Shared.GetTime()
    if now + kCheckInterval > lastTimeChecked then
      
        lastTimeChecked = now
        local shadow = Client.GetOptionBoolean( kShadowsOptionsKey, false )
        if shadow ~= nil and shadow ~= OnShadowOptionMixin.currentShadowOption then
          
            OnShadowOptionMixin.currentShadowOption = shadow
            
            for index, entity in ipairs(GetEntitiesWithMixin( "OnShadowOption" )) do
                entity:OnShadowOptionChanged(shadow)
            end
            
        end
    end
    Client.SetDebugText("OnShadowOption.OnUpdateClient exit")
end

Event.Hook("UpdateClient", OnUpdateClient, "OnShadowOptionMixin")


