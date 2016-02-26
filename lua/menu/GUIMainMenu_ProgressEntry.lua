-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_WelcomeProgress.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kFadeInTime = 2

class 'GUIProgressEntry' (MenuElement)

function GUIProgressEntry:Initialize()
	MenuElement.Initialize(self)

	self.icon = CreateMenuElement(self, "Image")
	self.icon:SetBackgroundTexture("ui/progress/locked.dds")

	--Todo Unlock Overlay
	self.iconfront = CreateMenuElement(self.icon, "Image")
	self.iconfront:SetBackgroundTexture("ui/progress/locked.dds")

	self.title = CreateMenuElement(self, "Font")
	self.title:SetCSSClass("title")

	self.description = CreateMenuElement(self, "Font")
	self.description:SetCSSClass("text")
end

function GUIProgressEntry:SetDone()
	self:SetCSSClass()
	self:ReloadCSSClass()

	self.icon:SetBackgroundTexture("ui/progress/unlocked.dds")
	self.iconfront:SetBackgroundTexture(self.doneTexture)
end

function GUIProgressEntry:Setup(data)
	self.doneTexture = data.icon or "ui/progress/claws.dds"

	self.name = data.title

	self.title:SetText(data.title)
	self.description:SetText(data.description)

	self.achievement = data.achievement
	self.static = data.static

	return self:CheckProgress()
end

function GUIProgressEntry:CheckProgress()
	local unlocked = self.static or Client and Client.GetAchievement(self.achievement)
	if unlocked then
		self:SetDone()

		local option = string.format("menu/unlocked_%s", string.gsub(self.name, " ", ""))
		if not self.static and not Client.GetOptionBoolean(option, false) then
			Client.SetOptionBoolean(option, true)
			self.fadeIn = 0
			
			MainMenu_OnUnlock()
		end
	end

	return unlocked
end

function GUIProgressEntry:Highlight()
	self.iconfront:SetBackgroundTexture("ui/progress/highlighted.dds")
	self:SetCSSClass("highlight")
	self:ReloadCSSClass()
end

function GUIProgressEntry:SetIsVisible(isVisible)
	MenuElement.SetIsVisible(self, isVisible)

	self:CheckProgress()
end

function GUIProgressEntry:GetTagName()
	return "progressentry"
end

function GUIProgressEntry:Update(deltaTime)
	if not self.fadeIn then return end

	self.fadeIn = math.min(self.fadeIn + deltaTime, kFadeInTime)

	self.iconfront:SetBackgroundColor( Color(1, 1, 1, self.fadeIn/kFadeInTime) )

	if self.fadeIn == 5 then
		self.fadeIn = nil
	end
end

