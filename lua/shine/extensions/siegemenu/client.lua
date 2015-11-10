--[[
	Shine admin menu.
]]

local Shine = Shine
local SGUI = Shine.GUI
local Hook = Shine.Hook

local IsType = Shine.IsType
local StringFormat = string.format
local TableConcat = table.concat

Shine.SiegeMenu = {}

local SiegeMenu = Shine.SiegeMenu

Hook.Add( "OnMapLoad", "SiegeMenu_Hook", function()
	Hook.SetupGlobalHook( "Scoreboard_OnClientDisconnect", "OnClientIDDisconnect", "PassivePre" )
end )

Client.HookNetworkMessage( "Shine_SiegeMenu_Open", function( Data )
	SiegeMenu:SetIsVisible( true )
end )


SiegeMenu.Tabs = {}

SiegeMenu.Pos = Vector( -400, -300, 0 )
SiegeMenu.Size = Vector( 800, 600, 0 )

function SiegeMenu:Create()
	self.Created = true

	local Window = SGUI:Create( "TabPanel" )
	Window:SetAnchor( "CentreMiddle" )
	Window:SetPos( self.Pos )
	Window:SetSize( self.Size )

	self.Window = Window

	Window.OnPreTabChange = function( Window )
		if not Window.ActiveTab then return end

		local Tab = Window.Tabs[ Window.ActiveTab ]

		if not Tab then return end

		self:OnTabCleanup( Window, Tab.Name )
	end

	self:PopulateTabs( Window )

	Window:AddCloseButton()
	Window.OnClose = function()
		self:SetIsVisible( false )

		if self.ToDestroyOnClose then
			for Panel in pairs( self.ToDestroyOnClose ) do
				Panel:Destroy()
				self.ToDestroyOnClose[ Panel ] = nil
			end
		end

		return true
	end
end

function SiegeMenu:DestroyOnClose( Object )
	self.ToDestroyOnClose = self.ToDestroyOnClose or {}

	self.ToDestroyOnClose[ Object ] = true
end

function SiegeMenu:DontDestroyOnClose( Object )
	if not self.ToDestroyOnClose then return end

	self.ToDestroyOnClose[ Object ] = nil
end

SiegeMenu.EasingTime = 0.25

function SiegeMenu:SetIsVisible( Bool )
	if not self.Created then
		self:Create()
	end

	if not Bool and Shine.Config.AnimateUI then
		Shine.Timer.Simple( self.EasingTime, function()
			if not SGUI.IsValid( self.Window ) then return end
			self.Window:SetIsVisible( false )
		end )
	else
		self.Window:SetIsVisible( Bool )
	end

	if Bool and not self.Visible then
		if Shine.Config.AnimateUI then
			self.Window:SetPos( Vector( -Client.GetScreenWidth() + self.Pos.x, self.Pos.y, 0 ) )
			self.Window:MoveTo( nil, nil, self.Pos, 0, self.EasingTime )
		else
			self.Window:SetPos( self.Pos )
		end

		SGUI:EnableMouse( true )
	elseif not Bool and self.Visible then
		SGUI:EnableMouse( false )

		if Shine.Config.AnimateUI then
			self.Window:MoveTo( nil, nil, Vector( Client.GetScreenWidth() - self.Pos.x, self.Pos.y, 0 ), 0,
				self.EasingTime, nil, math.EaseIn )
		end
	end

	self.Visible = Bool
end

function SiegeMenu:PlayerKeyPress( Key, Down )
	if not self.Visible then return end

	if Key == InputKey.Escape and Down then
		self:SetIsVisible( false )

		return true
	end
end

Hook.Add( "PlayerKeyPress", "SiegeMenu_KeyPress", function( Key, Down )
	SiegeMenu:PlayerKeyPress( Key, Down )
end, 1 )

function SiegeMenu:AddTab( Name, Data )
	self.Tabs[ Name ] = Data

	if self.Created then
		local ActiveTab = self.Window:GetActiveTab()
		local Tabs = self.Window.Tabs

		--A bit brute force, but its the easiest way to preserve tab order.
		for i = 1, self.Window.NumTabs do
			self.Window:RemoveTab( 1 )
		end

		self:PopulateTabs( self.Window )

		local WindowTabs = self.Window.Tabs
		for i = 1, #WindowTabs do
			local Tab = WindowTabs[ i ]
			if Tab.Name == ActiveTab.Name then
				Tab.TabButton:DoClick()
				break
			end
		end
	end
end

function SiegeMenu:RemoveTab( Name )
	local Data = self.Tabs[ Name ]

	if not Data then return end

	--Remove the actual menu tab.
	if Data.TabObj and SGUI.IsValid( Data.TabObj.TabButton ) then
		self.Window:RemoveTab( Data.TabObj.TabButton.Index )
	end

	self.Tabs[ Name ] = nil
end

function SiegeMenu:PopulateTabs( Window )
	local DoorsTab = self.Tabs.Doors
	local CreditsTab = self.Tabs.Credits
	//local DataBaseTab = self.Tabs.DataBase
	local CragStackTab = self.Tabs.CragStack
	local RTDTab = self.Tabs.RTD
	local CCDropTab = self.Tabs.CCDrop
	local AboutTab = self.Tabs.About




	--Remove them here so they're not in the pairs loop.
    self.Tabs.Doors = nil
	self.Tabs.Credits = nil
	//self.Tabs.DataBase = nil
	self.Tabs.CragStack = nil
	self.Tabs.RTD = nil
	self.Tabs.CCDrop = nil
	self.Tabs.About = nil


	for Name, Data in SortedPairs( self.Tabs ) do
		local Tab = Window:AddTab( Name, function( Panel )
			Data.OnInit( Panel, Data.Data )
		end )
		Data.TabObj = Tab
	end

	--Add them back.
    self.Tabs.Doors = DoorsTab
    
    	Tab = Window:AddTab( "Doors", function( Panel )
		DoorsTab.OnInit( Panel )
	end )
	DoorsTab.TabObj = Tab
	
	self.Tabs.Credits = CreditsTab

	Tab = Window:AddTab( "Credits", function( Panel )
		CreditsTab.OnInit( Panel )
	end )
	CreditsTab.TabObj = Tab
	
	/*
		self.Tabs.DataBase = DataBaseTab

	Tab = Window:AddTab( "DataBase", function( Panel )
		DataBaseTab.OnInit( Panel )
	end )
	DataBaseTab.TabObj = Tab
    */
	
			self.Tabs.CragStack = CragStackTab
		Tab = Window:AddTab( "CragStack", function( Panel )
		CragStackTab.OnInit( Panel )
	end )
	CragStackTab.TabObj = Tab
	
				self.Tabs.RTD = RTDTab
		Tab = Window:AddTab( "RTD", function( Panel )
		RTDTab.OnInit( Panel )
	end )
	RTDTab.TabObj = Tab
	
	
		self.Tabs.CCDrop = CCDropTab
	Tab = Window:AddTab("CCDrop", function (Panel ) 
	 CCDropTab.OnInit(Panel)
	 end)
	 
					self.Tabs.About = AboutTab
		Tab = Window:AddTab( "About", function( Panel )
		AboutTab.OnInit( Panel )
	end )
	AboutTab.TabObj = Tab
	

end

function SiegeMenu:OnTabCleanup( Window, Name )
	local Tab = self.Tabs[ Name ]

	if not Tab then return end

	local OnCleanup = Tab.OnCleanup

	if not OnCleanup then return end

	local Ret = OnCleanup( Window.ContentPanel )

	if Ret then
		Tab.Data = Ret
	end
end

function SiegeMenu.GetListState( List )
	local SelectedIndex

	if List.MultiSelect then
		local Selected = List:GetSelectedRows()

		if #Selected > 0 then
			SelectedIndex = {}
			for i = 1, #Selected do
				SelectedIndex[ i ] = Selected[ i ].Index
			end
		end
	else
		local Row = List:GetSelectedRow()
		if Row then
			SelectedIndex = Row.Index
		end
	end

	return {
		SortedColumn = List.SortedColumn,
		Descending = List.Descending,
		SelectedIndex = SelectedIndex
	}
end

function SiegeMenu.RestoreListState( List, Data )
	if not Data then return end
	if not Data.SortedColumn and not Data.SelectedIndex then return end

	if Data.SortedColumn then
		List:SortRows( Data.SortedColumn, nil, Data.Descending )
	end

	if Data.SelectedIndex and List.Rows then
		if List.MultiSelect and IsType( Data.SelectedIndex, "table" ) then
			local Selected = Data.SelectedIndex

			for i = 1, #Selected do
				local Row = List.Rows[ Selected[ i ] ]

				if Row then
					Row:SetHighlighted( true, true )
					Row.Selected = true
				end
			end
		elseif not List.MultiSelect and IsType( Data.SelectedIndex, "number" ) then
			local Row = List.Rows[ Data.SelectedIndex ]
			if Row then
				List:OnRowSelect( Data.SelectedIndex, Row )
				Row:SetHighlighted( true, true )
				Row.Selected = true
			end
		end
	end

	return Data.SortedColumn ~= nil
end

do
	local Text = [[ 
	       Side Doors, if the map has any, allow a side route to attack. Generally open 
	       before front doors
	       
           Front Doors disallow both sides from attacking eachother until they open, thus
           allowing both sides to setup for a few minutes to get upgrades and such, safely,
           without any threat to disrupt the process
           
           Siege Doors typically grant marines access to the Siege Room where
           they may safely Arc out the alien hives, if the aliens don't do anything about it.
           THIS ROOM MUST BE PRIORITIZED FOR BOTH SIDES WHEN OPENED BECAUSE IT DICTATES ENDGAME!
           
           Breakable Doors may be broken by the alien side and welded by the marine side and
           remain locked by default
           
           All doors are highlighted by a glowing visual
	]]

	SiegeMenu:AddTab( "Doors", {
		OnInit = function( Panel )
			local Label = SGUI:Create( "Label", Panel )
			Label:SetPos( Vector( 16, 24, 0 ) )
			Label:SetFont( "fonts/AgencyFB_small.fnt" )
			Label:SetText( Text )
			Label:SetBright( true )
			end
                               })
    
			
end

do
local WebPage
local Text = [[ 
              We run a custom Plugin titled Credits. What Are Credits? 
              Credits are points that allow you to purchase in game items,
              in return for playing Siege! How Are Credits Earned? 10 in game score = 1 credit. 
              You earn score by killing enemies, building structures, basically playing the game
              At the end of each round, there's a credit bonus based on how well your team performed.. 
               To spend credits, press M and click Credits, 
              or bind a key to sh_buy <item>]]

	SiegeMenu:AddTab( "Credits", {
		OnInit = function( Panel )
			local Label = SGUI:Create( "Label", Panel )
			Label:SetPos( Vector( 16, 24, 0 ) )
			Label:SetFont( "fonts/AgencyFB_small.fnt" )
			Label:SetText( Text )
			Label:SetBright( true )
			end
	} )
end
/*
do
local WebPage

	SiegeMenu:AddTab( "DataBase", {
		OnInit = function( Panel )
			local Label = SGUI:Create( "Label", Panel )
			Label:SetPos( Vector( 16, 24, 0 ) )
			Label:SetFont( "fonts/AgencyFB_small.fnt" )
			Label:SetText( [[derp]] )
			Label:SetBright( true )
			if not SGUI.IsValid( WebPage ) then
				WebPage = SGUI:Create( "Webpage", Panel )
				WebPage:SetPos( Vector( 16, 224, 0 ) )
				WebPage:LoadURL( "http://credits.ns2siege.com", 800, 600 )
			else
				WebPage:SetParent( Panel )
				WebPage:SetIsVisible( true )
			end

			SiegeMenu:DontDestroyOnClose( WebPage )
		end,

		OnCleanup = function( Panel )
			WebPage:SetParent()
			WebPage:SetIsVisible( false )
			SiegeMenu:DestroyOnClose( WebPage )
		end
	} )
end
*/
do
	local Text = [[ 
	        At the moment, Crags DO STACK. Meaning, the more you have
	        close to eachother, the more heal they give off.
	        Currently, 3 crags = 2x healamount.
	        This is crucial for both frontline and for the hive room
	        when being Sieged out by Marines
	        Ontop of this, crags have special buffed rules for
	        when Siege doors are opened, to make Crags even more Viable!
	]]

	SiegeMenu:AddTab( "CragStack", {
		OnInit = function( Panel )
			local Label = SGUI:Create( "Label", Panel )
			Label:SetPos( Vector( 16, 24, 0 ) )
			Label:SetFont( "fonts/AgencyFB_small.fnt" )
			Label:SetText( Text )
			Label:SetBright( true )
			end
                               })
    
			
end
do
	local Text = [[ 
	           RTD stands for RollTheDice 
	           This is another custom plugin ontop of Credits
	           RTD is a gambling system which reaps rewards.. or punishments
	           To roll the dice, type /rollthedice in chat or press M and click RTD
	           The current setup is defined by when you decide to roll!
	           Such as during setup time before doors open, when in combat (Fighting),
	           or when neutral.
	]]

	SiegeMenu:AddTab( "RTD", {
		OnInit = function( Panel )
			local Label = SGUI:Create( "Label", Panel )
			Label:SetPos( Vector( 16, 24, 0 ) )
			Label:SetFont( "fonts/AgencyFB_small.fnt" )
			Label:SetText( Text )
			Label:SetBright( true )
			end
                               })
    
			
end
do
	local Text = [[ 
                 At the moment, Command Chairs are allowed to be dropped anywhere
                 This allows marines to have a base practically anywhere on the map.
                 And Infantry Portals combined with Beacon is a dangerous combination
                 if done right ! :)
	]]

	SiegeMenu:AddTab( "CCDrop", {
		OnInit = function( Panel )
			local Label = SGUI:Create( "Label", Panel )
			Label:SetPos( Vector( 16, 24, 0 ) )
			Label:SetFont( "fonts/AgencyFB_small.fnt" )
			Label:SetText( Text )
			Label:SetBright( true )
			end
                               })
    
			
end
do
	local Text = [[ 
               Siege is a concept that first derived back in NS1 all them years ago
               There's no true author for siege. It was community made.
               Dozens of mappers made dozens of designs and the community was very active.
               With NS2, the opposite is true. There's not many contributors.
               NS2Siege began in September of 2014 and stays alive by the 
               funding of players. If there's no support, no funds, the project will cease.
	]]

	SiegeMenu:AddTab( "About", {
		OnInit = function( Panel )
			local Label = SGUI:Create( "Label", Panel )
			Label:SetPos( Vector( 16, 24, 0 ) )
			Label:SetFont( "fonts/AgencyFB_small.fnt" )
			Label:SetText( Text )
			Label:SetBright( true )
			end
                               })
    
			
end

