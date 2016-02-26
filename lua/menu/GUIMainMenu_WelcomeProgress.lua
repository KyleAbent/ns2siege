-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_WelcomeProgress.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/menu/GUIMainMenu_ProgressEntry.lua")

class 'GUIWelcomeProgress' (MenuElement)

local entryData = {
	{
		title = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_1_TITLE"),
		achievement = "First_0_1",
		description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_1_TEXT"),
	},
	{
		title = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_2_TITLE"),
		achievement = "First_0_2",
		description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_2_TEXT"),
	},
	{
		title = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_3_TITLE"),
		achievement = "First_0_3",
		description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_3_TEXT"),
	},
	{
		title = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_4_TITLE"),
		achievement = "First_0_4",
		description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_4_TEXT"),
	},
	{
		title = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_5_TITLE"),
		achievement = "First_0_5",
		description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_5_TEXT"),
	},
	{
		title = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_6_TITLE"),
		description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_6_TEXT"),
		icon = "ui/progress/skulk.dds",
		static = true
	}
}

function GUIWelcomeProgress:Initialize()
	MenuElement.Initialize(self)

	self.mainFrame = CreateMenuElement(self, "Image");
	self.mainFrame:SetCSSClass("main_frame")

	self.welcomeHeader = CreateMenuElement(self.mainFrame, "Font")
	self.welcomeHeader:SetCSSClass("header")
	self.welcomeHeader:SetText(Locale.ResolveString("WELCOME_PROGRESS_HEAD"))

	self.welcomeText = CreateMenuElement(self.mainFrame, "Font")
	self.welcomeText:SetCSSClass("text")
	self.welcomeText:SetText(Locale.ResolveString("WELCOME_PROGRESS_TEXT"))

	self.entries = {}

	local finished = true
	for i, data in ipairs(entryData) do
		self.entries[i] = CreateMenuElement(self.mainFrame, "GUIProgressEntry")

		if not self.entries[i]:Setup(data) and finished then
			self.entries[i]:Highlight()
			finished = false
		end

		self.entries[i]:SetTopOffset(i * 110)
	end

	if finished then
		Client.SetAchievement("First_1_0")
		Client.GrantPromoItems()
		MenuMenu_PlayMusic("sound/NS2.fev/victory")
		local info = CreateMenuElement(GetGUIMainMenu().mainWindow, "GUINewItemInfo")
		info:Setup{
			title = "Eat your Greens Shoulder Patch",
			icon = "ui/item_green_blood.dds",
			description = "Getting your toes wet, a shoulder decal is what you get!"
		}
	end
end

function GUIWelcomeProgress:Hide()
	self:SetIsVisible(false)

	self.hide = true
end

function GUIWelcomeProgress:SetIsVisible(visible)
	if self.hide then return end

	MenuElement.SetIsVisible(self, visible)
end

function GUIWelcomeProgress:Update(deltaTime)
	for _, entry in ipairs(self.entries) do
		entry:Update(deltaTime)
	end
end

function GUIWelcomeProgress:GetTagName()
	return "progress"
end