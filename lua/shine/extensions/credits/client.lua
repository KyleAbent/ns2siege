local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end

Shine.VoteMenu:AddPage ("SpendStructures", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton( "Mac(5)", function() Shared.ConsoleCommand ("sh_buy Mac")  end)
    self:AddSideButton( "Observatory(10)", function() Shared.ConsoleCommand ("sh_buy Observatory")  end)
    self:AddSideButton( "Sentry(8)", function() Shared.ConsoleCommand ("sh_buy Sentry")  end)
    self:AddSideButton( "Armory(12)", function() Shared.ConsoleCommand ("sh_buy Armory")  end)
    self:AddSideButton( "PhaseGate(15)", function() Shared.ConsoleCommand ("sh_buy PhaseGate")  end)
    self:AddSideButton( "InfantryPortal(10)", function() Shared.ConsoleCommand ("sh_buy InfantryPortal")  end)
    self:AddSideButton( "RoboticsFactory(10)", function() Shared.ConsoleCommand ("sh_buy RoboticsFactory")  end)
    self:AddSideButton( "ARC(20)", function() Shared.ConsoleCommand ("sh_buy ARC")  end)
   // self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
    elseif player:GetTeamNumber() == 2 then
    self:AddSideButton( "Hydra(1)", function() Shared.ConsoleCommand ("sh_buy Hydra")  end)
    self:AddSideButton( "Drifter(5)", function() Shared.ConsoleCommand ("sh_buy Drifter")  end)
    self:AddSideButton( "Shade(10)", function() Shared.ConsoleCommand ("sh_buy Shade")  end)
    self:AddSideButton( "Crag(10)", function() Shared.ConsoleCommand ("sh_buy Crag")  end)
    self:AddSideButton( "Whip(10)", function() Shared.ConsoleCommand ("sh_buy Whip")  end)
    self:AddSideButton( "Shift(10)", function() Shared.ConsoleCommand ("sh_buy Shift")  end)
    //self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
   end

        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendWeapons", function( self )
        self:AddSideButton( "Welder(1)", function() Shared.ConsoleCommand ("sh_buy Welder")  end)
        self:AddSideButton( "Mines(1.5)", function() Shared.ConsoleCommand ("sh_buy Mines")  end)
        self:AddSideButton( "HeavyMachineGun(5)", function() Shared.ConsoleCommand ("sh_buy HeavyMachineGun")  end)
        self:AddSideButton( "ShotGun(2)", function() Shared.ConsoleCommand ("sh_buy ShotGun")  end)
        self:AddSideButton( "FlameThrower(3)", function() Shared.ConsoleCommand ("sh_buy FlameThrower")  end)
        self:AddSideButton( "GrenadeLauncher(3)", function() Shared.ConsoleCommand ("sh_buy GrenadeLauncher")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendCommAbilities", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    
    self:AddSideButton ("CatPack(2)", function()Shared.ConsoleCommand ("sh_buy CatPack")end)
    self:AddSideButton ("Nano(2)", function()Shared.ConsoleCommand ("sh_buy Nano")end)
    self:AddSideButton( "AmmoPack(1)", function() Shared.ConsoleCommand ("sh_buy AmmoPack")  end)
    self:AddSideButton( "MedPack(1)", function() Shared.ConsoleCommand ("sh_buy MedPack")  end)
    self:AddSideButton( "Scan(1)", function() Shared.ConsoleCommand ("sh_buy Scan")  end)
    
        elseif player:GetTeamNumber() == 2 then
       self:AddSideButton ("NutrientMist(1)", function()Shared.ConsoleCommand ("sh_buy NutrientMist")end)
       self:AddSideButton( "EnzymeCloud(1)", function() Shared.ConsoleCommand ("sh_buy EnzymeCloud")  end)
       self:AddSideButton( "Enzyme(2)", function() Shared.ConsoleCommand ("sh_buy Enzyme")  end)
       self:AddSideButton( "Umbra(2)", function() Shared.ConsoleCommand ("sh_buy Umbra")  end)
       self:AddSideButton( "Ink(2)", function() Shared.ConsoleCommand ("sh_buy Ink")  end)
       self:AddSideButton( "Hallucination(1)", function() Shared.ConsoleCommand ("sh_buy Hallucination")  end)
       self:AddSideButton( "Contamination(1)", function() Shared.ConsoleCommand ("sh_buy Contamination")  end)
       self:AddSideButton( "Egg(2)", function() Shared.ConsoleCommand ("sh_buy Egg")  end)
    end
     self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendClasses", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton( "JetPack(10)", function() Shared.ConsoleCommand ("sh_buy JetPack")  end)
    self:AddSideButton( "MiniGunClawExo(30)", function() Shared.ConsoleCommand ("sh_buy MiniGunClawExo")  end)
    self:AddSideButton( "RailGunClawExo(30)", function() Shared.ConsoleCommand ("sh_buy RailGunClawExo")  end)
    self:AddSideButton( "DualMiniGunExo(45)", function() Shared.ConsoleCommand ("sh_buy DualMiniGunExo")  end)
    self:AddSideButton( "DualRailGunExo(45)", function() Shared.ConsoleCommand ("sh_buy DualRailExo")  end)
        elseif player:GetTeamNumber() == 2 then
      self:AddSideButton( "Gorge(10)", function() Shared.ConsoleCommand ("sh_buy Gorge")  end)
      self:AddSideButton( "Lerk(15)", function() Shared.ConsoleCommand ("sh_buy Lerk")  end)
      self:AddSideButton( "Fade(25)", function() Shared.ConsoleCommand ("sh_buy Fade")  end)
      self:AddSideButton( "Onos(30)", function() Shared.ConsoleCommand ("sh_buy Onos")  end)
    end
     self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendExpensive", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
   self:AddSideButton( "ResPoint(100)", function() Shared.ConsoleCommand ("sh_buy ResPoint")  end)  
    self:AddSideButton( "Extractor(150)", function() Shared.ConsoleCommand ("sh_buy Extractor")  end)  
   // self:AddSideButton( "TechPoint(500)", function() Shared.ConsoleCommand ("sh_buy TechPoint")  end)    
   // self:AddSideButton( "CommandStation(1000)", function() Shared.ConsoleCommand ("sh_buy CommandStation")  end)
  //  self:AddSideButton( "Custom Badge(1k)", function() Shared.ConsoleCommand ("sh_buy Badge")  end)
        elseif player:GetTeamNumber() == 2 then
     self:AddSideButton( "ResPoint(100)", function() Shared.ConsoleCommand ("sh_buy ResPoint")  end)  
     self:AddSideButton( "Harvester(150)", function() Shared.ConsoleCommand ("sh_buy Harvester")  end) 
    // self:AddSideButton( "TechPoint(500)", function() Shared.ConsoleCommand ("sh_buy TechPoint")  end)    
     //self:AddSideButton( "Hive(1k)", function() Shared.ConsoleCommand ("sh_buy Hive")  end)
     //self:AddSideButton( "Custom Badge(1000)", function() Shared.ConsoleCommand ("sh_buy BadgeA")  end)
    end

     self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendFun", function( self )
       local player = Client.GetLocalPlayer()
     self:AddSideButton( "LowGravity(1)", function() Shared.ConsoleCommand ("sh_buy Gravity")  end) 
   //  self:AddSideButton( "Shrink(5)", function() Shared.ConsoleCommand ("sh_buy Shrink")  end) 
      if player:GetTeamNumber() == 2 then
     self:AddSideButton( "Grow(5)", function() Shared.ConsoleCommand ("sh_buy Grow")  end) 
      end
      
      if player:GetTeamNumber() == 1 then
     self:AddSideButton( "GlowPurple(5)", function() Shared.ConsoleCommand ("sh_buy GlowPurple")  end)
     self:AddSideButton( "GlowGreen(5)", function() Shared.ConsoleCommand ("sh_buy GlowGreen")  end)
     end
     
     self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendCredits", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 


elseif player:GetTeamNumber() == 2 then

end    

     

     
     self:AddSideButton( "CommAbilities", function() self:SetPage( "SpendCommAbilities" ) end)
     
     self:AddSideButton( "Structures", function() self:SetPage( "SpendStructures" ) end)
     
     self:AddSideButton( "Classes", function() self:SetPage( "SpendClasses" ) end) 
     
    self:AddSideButton( "Fun", function() self:SetPage( "SpendFun" ) end)
    
   //self:AddSideButton( "Misc", function() self:SetPage( "Spendmisc" ) end)
     
     self:AddSideButton( "Expensive", function() self:SetPage( "SpendExpensive" ) end)
     
     if player:GetTeamNumber() == 1 then 
        self:AddSideButton( "Weapons", function() self:SetPage( "SpendWeapons" ) end)
     end
     
     self:AddBottomButton( "Back", function()self:SetPage("Main")end)
end)

Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "Credits", function() self:SetPage( "SpendCredits" ) end)
end)


