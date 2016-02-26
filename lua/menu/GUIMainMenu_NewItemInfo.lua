-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_NewItemInfo.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUINewItemInfo' (Window)

function GUINewItemInfo:Initialize()
	Window.Initialize(self)

	self:SetWindowName("New Item Received!")
	self:SetInitialVisible(true)
	self:DisableResizeTile()
	self:DisableSlideBar()
	self:DisableTitleBar()
	self:DisableContentBox()
	self:DisableCloseButton()
	self:SetLayer(kGUILayerMainMenuDialogs)

	self.icon = CreateMenuElement(self, "Image")

	self.title = CreateMenuElement(self, "Font")
	self.title:SetCSSClass("title")

	self.description = CreateMenuElement(self, "Font")
	self.description:SetCSSClass("description")

	self.okButton = CreateMenuElement(self, "MenuButton")
	self.okButton:SetText(Locale.ResolveString("OK"))
	self.okButton:AddEventCallbacks({ OnClick = function()
		self:SetIsVisible(false)
	end})
end

function GUINewItemInfo:Setup(data)
	self.icon:SetBackgroundTexture(data.icon)

	self.title:SetText(string.format("New Item: %s", data.title))
	self.description:SetText(data.description)
end

function GUINewItemInfo:GetTagName()
	return "newiteminfo"
end