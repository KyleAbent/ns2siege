/*
Kyleabent@gmail.com - Siege 2015 http://ns2siege.com
12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb
*/
local Shine = Shine
local Plugin = Plugin



Plugin.Version = "1.0"


function Plugin:Initialise()
self.rtd_succeed_cooldown = 90
self.rtdenabled = true
self.rtd_failed_cooldown = self.rtd_succeed_cooldown
self.Users = {}
self:CreateCommands()
self.Enabled = true
self.CreditPool = 0
return true
end

function Plugin:GetIsInCombatRTD(Player)
     if Player.timeLastDamageDealt + 15 >= Shared.GetTime() or Player.lastTakenDamageTime + 15 >= Shared.GetTime() then
     return true
     else
     return false
     end
end

function Plugin:CreateCommands()

local function AddPool(Client, Number)
self.CreditPool = self.CreditPool + (Number/(10/kCreditMultiplier))
end

local AddPoolCommand = self:BindCommand("sh_addpool", "addpool", AddPool)
AddPoolCommand:Help("sh_addpool <number>")
AddPoolCommand:AddParam{ Type = "number" }

local function RollTheDice( Client )
//Do something regarding pre-game?
local Player = Client:GetControllingPlayer()
  /*
         if Player:isa("Egg") or Player:isa("Embryo") then
         Shine:NotifyError( Player, "You cannot gamble while an egg/embryo (Yet)" )
         return
         end
     */    
       //  if Player:isa("ReadyRoomPlayer") or (Player:GetTeamNumber() ~= 1 and Player:GetTeamNumber() ~= 2) then
       //  Shine:NotifyError( Player, "You must be an alien or marine to gamble (In this version, atleast)" )
       //  return
       //  end
         
         if Player:isa("Commander") then
         Shine:NotifyError( Player, "You cannot gamble while a commander (Yet)" )
         return
         end
         
          if Player:isa("Spectator") then
         Shine:NotifyError( Player, "You cannot gamble while spectating (Yet)" )
         return
         end
         
         if not Player:GetIsAlive() then
         Shine:NotifyError( Player, "You cannot gamble when you are dead (Yet)" )
         return
         end
         
local Time = Shared.GetTime()
local NextUse = self.Users[ Client ]
      
      if NextUse and NextUse > Time and not Shared.GetCheatsEnabled() then
       Shine:NotifyError( Player, "You must wait %s before gambling again.", true, string.TimeToString( NextUse - Time ) )
      return
       end
  self.Users[ Client ] = Time + self.rtd_succeed_cooldown
  
           if Player:isa("ReadyRoomPlayer") or (Player:GetTeamNumber() ~= 1 and Player:GetTeamNumber() ~= 2) then
                  self:RollRRNonMarineNonAlienCreditRoll(Player)
         return
         end
       
                      if self:AbleToUseSetupRolls() then  
                               if Player:isa("Marine") then
                                     self:RollMarineSETUP(Player)
                               elseif Player:isa("Alien") then
                                      if Player:isa("Gorge") then
                                     self:RollGorgeSETUP(Player)
                                       elseif not Player:isa("Gorge") then
                                      self:RollNONGORGESETUP(Player)
                                       end
                               end
                      return
                      end
                      
    if not self:GetIsInCombatRTD(Player) then 
            if Player:isa("JetpackMarine") then
            self:RollJetpack(Player)
            elseif Player:isa("Exo") then
            self:RollExo(Player)
            elseif Player:isa("Marine") then
            self:RollMarine(Player)
            elseif Player:isa("Egg") or Player:isa("Embryo") then
            self:RollEggEmbryo(Player)
            elseif Player:isa("Alien") then
            self:RollAlien(Player)
            end
    elseif self:GetIsInCombatRTD(Player) then
            if Player:isa("JetpackMarine") then
            self:RollJetpackCombat(Player)
            elseif Player:isa("Exo") then
            self:RollExoCombat(Player)
          elseif Player:isa("Marine") then
            self:RollMarineCombat(Player)
          elseif Player:isa("Egg") or Player:isa("Embryo") then
            self:RollEggEmbryo(Player)
            elseif Player:isa("Alien") then
            self:RollAlienCombat(Player)
            end
    end

end

local RollTheDiceCommand = self:BindCommand( "sh_rtd", { "rollthedice", "rtd" }, RollTheDice, true)
RollTheDiceCommand:Help( "Gamble and emit a positive or negative effect") 


end

function Plugin:RollMarine(Player)
           local roll = math.random(1,9)
                if roll == 1 then 
                self:RollMarineJetpackMarineExoAlienWinloseRes(Player)
                elseif roll == 2 then
                self:RollMarineJetpackMarineExoAlienWinloseCredits(Player)
                elseif roll == 3 then
                self:RollMarineJetpackMarineRandomWeapon(Player)
                elseif roll ==  4 then
                self:RollMarineJetpackMarineExoGlow(Player)
                elseif roll == 5 then
                self:RollMarineJetpackMarineExoCombatandNonCombatBonewall(Player)
                elseif roll == 6 then 
                self:RollMarineJetpackMarineExoCombatandNonCombatWeb(Player)
                elseif roll == 7 then
                self:RollMarineJetpackMarineExoParasite(Player)
                elseif roll == 8 then
                self:RollMarineJetpackMarineExoChangeClass(Player)
                elseif roll == 9 then
                self:RollMarineExoAlienNonCombatLowGravity(Player)
                end
         //  self:NotifyMarine( Player, "Marine Roll %s", true, roll)
end
function Plugin:RollJetpack(Player)
           local roll = math.random(1,9)
                if roll == 1 then 
                self:RollMarineJetpackMarineExoAlienWinloseRes(Player)
                elseif roll == 2 then
                self:RollMarineJetpackMarineExoAlienWinloseCredits(Player)
                elseif roll == 3 then
                self:RollMarineJetpackMarineRandomWeapon(Player)
                elseif roll ==  4 then
                self:RollMarineJetpackMarineExoGlow(Player)
                elseif roll == 5 then
                self:RollMarineJetpackMarineExoCombatandNonCombatBonewall(Player)
                elseif roll == 6 then 
                self:RollMarineJetpackMarineExoCombatandNonCombatWeb(Player)
                elseif roll == 7 then
                self:RollMarineJetpackMarineExoParasite(Player)
                elseif roll == 8 then
                self:RollMarineJetpackMarineExoChangeClass(Player)
                elseif roll == 9 then
                self:RollInstantJetpackFuelReplenish(Player)
                end
         //  self:NotifyJetpackMarine( Player, "Jetpack Roll %s", true, roll)
end
function Plugin:RollExo(Player)
           local roll = math.random(1,8)
                if roll == 1 then 
                self:RollMarineJetpackMarineExoAlienWinloseRes(Player)
                elseif roll == 2 then
                self:RollMarineJetpackMarineExoAlienWinloseCredits(Player)
                elseif roll == 3 then
                self:RollMarineJetpackMarineExoCombatandNonCombatBonewall(Player)
                elseif roll == 4 then
                self:RollMarineJetpackMarineExoCombatandNonCombatWeb(Player)
                elseif roll == 5 then
                self:RollMarineJetpackMarineExoParasite(Player)
                elseif roll == 6 then
                self:RollMarineJetpackMarineExoGlow(Player)
                elseif roll == 7 then
                self:RollMarineJetpackMarineExoChangeClass(Player)
                elseif roll == 8 then
                self:RollMarineExoAlienNonCombatLowGravity(Player)
                end
         //  self:NotifyExo( Player, "Exo Roll %s", true, roll)
end
function Plugin:RollAlien(Player)
           local roll = math.random(1,4)
           if roll == 1 then
           self:RollAlienScan(Player)
           elseif roll == 2 then
           self:RollMarineJetpackMarineExoAlienWinloseCredits(Player)
           elseif roll == 3 then
           self:RollMarineJetpackMarineExoAlienWinloseRes(Player)
           elseif roll == 4 then
           self:RollMarineExoAlienNonCombatLowGravity(Player)
           end
          // self:NotifyAlien( Player, "Alien Roll %s", true, roll)
end
function Plugin:RollEggEmbryo(Player)

          local roll = math.random(1,2)
          if roll == 1 then
          self:ChangeAlienClass(Player)
          elseif roll == 2 then
          self:RollNutrientMist(Player)
          end
 
end
function Plugin:RollMarineCombat(Player)
           local roll = math.random(1,9)
                if roll == 1 then
                self:RollMarineCombatJetpackMarineCombatAlienCombatHealth(Player) 
                elseif roll == 2 then
                self:MarineJetpackMarineStun(Player)
                elseif roll == 3 then
                self:MarineJetpackMarineExoCombatCatpack(Player)
                elseif roll == 4 then
                self:MarineJetpackMarineExoCombatNano(Player)
                elseif roll == 5 then
                self:MarineJetpackMarineExoCombatCatpackANDNano(Player)
                elseif roll == 6 then
                self:RollMarineJetpackMarineExoCombatandNonCombatWeb(Player)
                elseif roll == 7 then
                self:RollMarineJetpackMarineExoCombatandNonCombatBonewall(Player)
                elseif roll == 8 then
                self:RollMarineJetpackMarineExoCombatOnGroundContamination(Player)
                elseif roll == 9 then
                self:RollMarineJetpackmarineCombatAlterAmmo(Player)
                end
           //self:NotifyMarineCombat( Player, "Marine Combat Roll %s", true, roll)
end
function Plugin:RollJetpackCombat(Player)
           local roll = math.random(1,10)
                if roll == 1 then
                self:RollMarineCombatJetpackMarineCombatAlienCombatHealth(Player) 
                elseif roll == 2 then
                self:MarineJetpackMarineStun(Player)
                elseif roll == 3 then
                self:MarineJetpackMarineExoCombatCatpack(Player)
                elseif roll == 4 then
                self:MarineJetpackMarineExoCombatNano(Player)
                elseif roll == 5 then
                self:MarineJetpackMarineExoCombatCatpackANDNano(Player)
                elseif roll == 6 then
                self:RollMarineJetpackMarineExoCombatandNonCombatWeb(Player)
                elseif roll == 7 then
                self:RollMarineJetpackMarineExoCombatandNonCombatBonewall(Player)
                elseif roll == 8 then
                self:RollInstantJetpackFuelReplenish(Player)
                elseif roll == 9 then
                self:RollMarineJetpackMarineExoCombatOnGroundContamination(Player)
                elseif roll == 10 then
                self:RollMarineJetpackmarineCombatAlterAmmo(Player)
                end
           //self:NotifyJetpackMarineCombat(Player, "Jetpack Combat Roll %s", true, roll)
end
function Plugin:RollExoCombat(Player)
           local roll = math.random(1,7)
          // self:NotifyExoCombat( Player, "Exo Combat Roll %s", true, roll)
           if roll == 1 then
           self:RollMarineJetpackMarineExoCombatandNonCombatWeb(Player)
           elseif roll == 2 then
           self:RollMarineJetpackMarineExoCombatandNonCombatBonewall(Player)
           elseif roll == 3 then
           self:MarineJetpackMarineExoCombatCatpack(Player)
           elseif roll == 4 then
           self:MarineJetpackMarineExoCombatNano(Player)
           elseif roll == 5 then
           self:MarineJetpackMarineExoCombatCatpackANDNano(Player)
           elseif roll == 6 then
           self:ExoCombatArmor(Player)
           elseif roll == 7 then
           self:RollMarineJetpackMarineExoCombatOnGroundContamination(Player)
           end
end
function Plugin:RollAlienCombat(Player)
           local roll = math.random(1,10)
           if roll == 1 then
           self:RollMarineCombatJetpackMarineCombatAlienCombatHealth(Player)
           elseif roll == 2 then
           self:AlienInCombatRedeem(Player)
           elseif roll == 3 then
           self:AlienInCombatHallucinate(Player)
           elseif roll == 4 then
           self:AlienInCombatInk(Player)
           elseif roll == 5 then
           self:AlienInCombatElectrify(Player)
           elseif roll == 6 then
           self:AlienInCombatOrSetupEnzyme(Player, false)
           elseif roll == 7 then 
           self:AlienInCombatUmbra(Player)
           elseif roll == 8 then
           self:AlienInCombatEnzymeANDUmbra(Player)
           elseif roll == 9 then
           self:AlienInCombatEnergyModification(Player, false)
           elseif roll == 10 then
           self:RollAlienCombatWhip(Player)
           end
          // self:NotifyAlienCombat( Player, "Alien Combat Roll %s", true, roll)
end
function Plugin:RollMarineSETUP(Player)
         local roll = math.random(1,2)
         if roll == 1 then
               self:RollMarineSETUPBuildSpeedAdjustment(Player)
         elseif roll == 2 then 
               self:RollMarineSetupMINE(Player)
         end
          // self:NotifyMarineSetup( Player, "Alien Setup Roll Non Gorge %s", true, roll)
end
function Plugin:RollGorgeSETUP(Player)
        // local roll == 1 then
               self:RollGORGESetupBuildBuffDebuff(Player)
         //end
        // self:NotifyAlienSetup( Player, "Alien Setup Roll Gorge %s", true, roll)
end
function Plugin:RollNONGORGESETUP(Player)
         //local roll == 1 then
               self:RollNonGorgeAlienSetup(Player)
        // end
        // self:NotifyAlienSetup( Player, "Alien Setup Roll Non Gorge %s", true, roll)
end
function Plugin:NotifyMarine( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Marine]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyMarineSetup( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Marine] [Setup]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyPool( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Credits] [Pool]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyJetpackMarine( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [JP]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyExo( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Exo]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyAlien( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Alien]", 144, 238, 144, String, Format, ... )
end
function Plugin:NotifyAlienSetup( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Alien] [Setup]", 144, 238, 144, String, Format, ... )
end
function Plugin:NotifyMarineCombat( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Marine] [Combat]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyJetpackMarineCombat( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [JP] [Combat]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyExoCombat( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Exo] [Combat]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyAlienCombat( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Alien] [Combat]", 144, 238, 144, String, Format, ... )
end
function Plugin:NotifyRRNonMarineNonAlienPlayer( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Player]", 144, 238, 144, String, Format, ... )
end
function Plugin:NotifyGorgeSetup( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [Gorge] [Setup]", 144, 238, 144, String, Format, ... )
end
function Plugin:NotifyNonGorgeSetup( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] [NonGorge] [Setup]", 144, 238, 144, String, Format, ... )
end
function Plugin:RollMarineCombatJetpackMarineCombatAlienCombatHealth(Player)
           local playerhealth = Player:GetHealth()
            local playermaxhealth = Player:GetMaxHealth()
           local random = math.random(1,playermaxhealth)
           if random == playerhealth then self:RollMarineCombatJetpackMarineCombatAlienCombatHealth(Player) return end
          Player:SetHealth(random) 
               if Player:isa("JetpackMarine") then
                          self:NotifyJetpackMarineCombat( Player, "Set health to %s, previous: %s", true, random, math.round(playerhealth,1))    
              elseif Player:isa("Marine") then
                        self:NotifyMarineCombat( Player, "Set health to %s, previous: %s", true, random, math.round(playerhealth,1))    
              elseif Player:isa("Alien") then
                     self:NotifyAlienCombat( Player, "Set health to %s, previous: %s", true, random, math.round(playerhealth,1))    
              end
              self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:RollMarineCombatJetpackMarineCombatAlienCombatArmor(Player)
           local playerarmor = Player:GetArmor()
            local playermaxarmor = Player:GetMaxArmor()
           local random = math.random(1,playermaxarmor)
           if random == playerarmor then self:RollMarineCombatJetpackMarineCombatAlienCombatArmor(Player) return end
          Player:SetArmor(random) 
               if Player:isa("JetpackMarine") then
                          self:NotifyJetpackMarineCombat( Player, "Set armor to %s, previous: %s", true, random, math.round(playerarmor,1))    
              elseif Player:isa("Marine") then
                        self:NotifyMarineCombat( Player, "Set armor to %s, previous: %s", true, random, math.round(playerarmor,1))
              elseif Player:isa("Alien") then
                     self:NotifyAlienCombat( Player, "Set health to %s, previous: %s", true, random, math.round(playerarmor,1))     
              end
              self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:RollMarineJetpackMarineExoAlienWinloseRes(Player)
   
    local resources = Player:GetResources()
    local random = math.random(1,100)
    Player:SetResources(random)
           if Player:isa("JetpackMarine") then
           self:NotifyJetpackMarine( Player, "Set resources to %s, previous: %s", true, random, resources) 
           elseif Player:isa("Exo") then
           self:NotifyExo( Player, "Set resources to %s, previous: %s", true, random, resources) 
           elseif Player:isa("Marine") then
           self:NotifyMarine( Player, "Set resources to %s, previous: %s", true, random, resources) 
           elseif Player:isa("Alien") then
           self:NotifyAlien( Player, "Set resources to %s, previous: %s", true, random, resources) 
           end 
        self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:RollRRNonMarineNonAlienCreditRoll(Player)
    local pool = Clamp(self.CreditPool, 1, 100*kCreditMultiplier)
       local posorneg = math.random(1,2)
       local credits = 0
            if posorneg == 1 then
              credits = math.random(1, pool)
             self.CreditPool = Clamp(self.CreditPool - credits, 1, 100)
            elseif posorneg == 2 then
              credits = math.random(-1, -5)
             self.CreditPool = Clamp(self.CreditPool + (credits * -1), 1, 100)
            end

         
       pool = self.CreditPool
       self:NotifyRRNonMarineNonAlienPlayer(Player, "%s credits", true, credits) 
       
end
function Plugin:RollMarineJetpackMarineExoAlienWinloseCredits(Player)
    local pool = Clamp(self.CreditPool, 1, 100*kCreditMultiplier)
       local posorneg = math.random(1,2)
       local credits = 0
            if posorneg == 1 then
              credits = math.random(1, pool)
             self.CreditPool = Clamp(self.CreditPool - credits, 1, 100)
            elseif posorneg == 2 then
              credits = math.random(-1, -5)
             self.CreditPool = Clamp(self.CreditPool + (credits * -1), 1, 100)
            end

         
       pool = self.CreditPool
     

    Shared.ConsoleCommand(string.format("sh_addcredits %s %s false", Player:GetClient():GetUserId(), credits)) 
           if Player:isa("JetpackMarine") then
           self:NotifyJetpackMarine(Player, "%s credits", true, credits) 
           elseif Player:isa("Exo") then
           self:NotifyExo(Player, "%s credits", true, credits) 
           elseif Player:isa("Marine") then
           self:NotifyMarine(Player, "%s credits", true, credits) 
           elseif Player:isa("Alien") then
           self:NotifyAlien(Player, "%s credits", true, credits) 
           end 
           self:NotifyPool(nil, "%s credits", true,  pool) 
end
function Plugin:RollMarineJetpackMarineRandomWeapon(Player)     
           local WeaponRoll = math.random(1, 9) 
           local attainedweapon = nil
           if WeaponRoll == 1 and Player:GetWeaponInHUDSlot(1) ~= nil and not Player:GetWeaponInHUDSlot(1):isa("GrenadeLauncher") then DestroyEntity(Player:GetWeaponInHUDSlot(1)) attainedweapon = Player:GiveItem(GrenadeLauncher.kMapName) end
                     if WeaponRoll == 1 and Player:GetWeaponInHUDSlot(1) == nil then Player:GiveItem(GrenadeLauncher.kMapName) self:NotifyMarine( nil, "switched to a GrenadeLauncher", true)return end
           if WeaponRoll == 2 and not Player.hasfirebullets then Player.hasfirebullets = true return end
           if WeaponRoll == 3 and Player:GetWeaponInHUDSlot(1) ~= nil and not Player:GetWeaponInHUDSlot(1):isa("Flamethrower") then DestroyEntity(Player:GetWeaponInHUDSlot(1)) attainedweapon = Player:GiveItem(Flamethrower.kMapName)  end
                      if WeaponRoll == 3 and Player:GetWeaponInHUDSlot(1) == nil then attainedweapon = Player:GiveItem(Flamethrower.kMapName) end
           if WeaponRoll == 4 and Player:GetWeaponInHUDSlot(1) ~= nil and not Player:GetWeaponInHUDSlot(1):isa("Rifle") then DestroyEntity(Player:GetWeaponInHUDSlot(1)) attainedweapon = Player:GiveItem(Rifle.kMapName)  end
                      if WeaponRoll == 4 and Player:GetWeaponInHUDSlot(1) == nil then attainedweapon = Player:GiveItem(Rifle.kMapName)  end
           if WeaponRoll == 5 and not Player:GetWeaponInHUDSlot(3):isa("Welder") then attainedweapon = Player:GiveItem(Welder.kMapName)  end
           if WeaponRoll == 6 and not Player:GetWeaponInHUDSlot(3):isa("Axe") then DestroyEntity(Player:GetWeaponInHUDSlot(3)) attainedweapon = Player:GiveItem(Axe.kMapName) end
           if WeaponRoll == 7 and Player:GetWeaponInHUDSlot(2) ~= nil and not Player:GetWeaponInHUDSlot(2):isa("Pistol") then DestroyEntity(Player:GetWeaponInHUDSlot(2)) attainedweapon = Player:GiveItem(Pistol.kMapName) end
                     if WeaponRoll == 7 and Player:GetWeaponInHUDSlot(2) == nil then attainedweapon = Player:GiveItem(Pistol.kMapName)  end
           if WeaponRoll == 8 and Player:GetWeaponInHUDSlot(1) ~= nil and not Player:GetWeaponInHUDSlot(1):isa("Shotgun") then DestroyEntity(Player:GetWeaponInHUDSlot(1)) attainedweapon = Player:GiveItem(Shotgun.kMapName) end
                     if WeaponRoll == 8 and Player:GetWeaponInHUDSlot(2) == nil then attainedweapon = Player:GiveItem(Shotgun.kMapName) end
           if WeaponRoll == 9 and Player:GetWeaponInHUDSlot(4) == nil then attainedweapon = Player:GiveItem(LayMines.kMapName) end
           if attainedweapon ~= nil then
                 if Player:isa("Marine") then
                 self:NotifyMarine( Player, "Attained %s", true, attainedweapon:GetClassName())
                 elseif Player:isa("JetpackMarine") then
                 self:NotifyJetpackMarine( Player, "Attained %s", true, attainedweapon:GetClassName())
                 end
           else
          self:RollMarineJetpackMarineRandomWeapon(Player)
          end
end
function Plugin:MarineJetpackMarineStun(Player)
     local kStunDuration = math.random(1,10)
     if Player:isa("Marine") then
           if not Player:GetIsOnGround() then self:RollMarineCombat(Player) return end
           self:NotifyMarineCombat( Player, "stunned for %s seconds", true, kStunDuration)
     elseif Player:isa("JetpackMarine") then
           if not Player:GetIsOnGround() then self:RollJetpackCombat(Player) return end
           self:NotifyJetpackMarineCombat( Player, "stunned for %s seconds", true, kStunDuration)
     end
     Player:SetStun(kStunDuration)
     self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
     Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.80,Text = "Stunned for %s",Duration = kStunDuration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player ) 
end
function Plugin:MarineJetpackMarineExoCombatCatpack(Player)
            local kCatPackDuration = math.random(8,60)
            StartSoundEffectAtOrigin(CatPack.kPickupSound, Player:GetOrigin())
            Player:ApplyDurationCatPack(kCatPackDuration) 
            Shine.ScreenText.Add( 51, {X = 0.20, Y = 0.80,Text = "Catpack: %s",Duration = kCatPackDuration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
                  if Player:isa("JetpackMarine") then
                 self:NotifyJetpackMarineCombat( Player, "Catalyst for %s seconds", true, kCatPackDuration)
                 elseif Player:isa("Exo") then
                 self:NotifyExoCombat( Player, "Catalyst for %s seconds", true, kCatPackDuration)
                 elseif Player:isa("Marine") then
                 self:NotifyMarineCombat( Player, "Catalyst for %s seconds", true, kCatPackDuration)
                 end
end
function Plugin:MarineJetpackMarineExoCombatNano(Player)
            local kNanoShieldDuration = math.random (8, 45)
            Player:ActivateDurationNanoShield(kNanoShieldDuration)
            Shine.ScreenText.Add( 52, {X = 0.20, Y = 0.80,Text = "Nano: %s",Duration = kNanoShieldDuration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
                 if Player:isa("JetpackMarine") then
                 self:NotifyJetpackMarineCombat( Player, "Nano for %s seconds", true, kNanoShieldDuration)
                 elseif Player:isa("Exo") then
                 self:NotifyExoCombat( Player, "Nano for %s seconds", true, kNanoShieldDuration)
                elseif Player:isa("Marine") then
                 self:NotifyMarineCombat( Player, "Nano for %s seconds", true, kNanoShieldDuration)
                 end
end
function Plugin:MarineJetpackMarineExoCombatCatpackANDNano(Player)
            local  kNanoShieldANDCatPackTimer = math.random(10,60)
            Shine.ScreenText.Add( 55, {X = 0.20, Y = 0.80,Text = "Catpack/Nano: %s",Duration = kNanoShieldANDCatPackTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            Player:ActivateDurationNanoShield(kNanoShieldANDCatPackTimer)
            Player:ApplyDurationCatPack(kNanoShieldANDCatPackTimer) 
            StartSoundEffectAtOrigin(CatPack.kPickupSound, Player:GetOrigin())
                 if Player:isa("JetpackMarine") then
                 self:NotifyJetpackMarineCombat( Player, "Catpack AND Nano for %s seconds", true, kNanoShieldANDCatPackTimer)
                 elseif Player:isa("Exo") then
                 self:NotifyExoCombat( Player, "Catpack AND Nano for %s seconds", true, kNanoShieldANDCatPackTimer)
                 elseif Player:isa("Marine") then
                 self:NotifyMarineCombat( Player, "Catpack AND Nano for %s seconds", true, kNanoShieldANDCatPackTimer)
                 end
end
function Plugin:RollMarineJetpackMarineExoGlow(Player)
                 if Player:isa("JetpackMarine") then
                       if not Player.Glowing then
                       self:NotifyJetpackMarine( Player, "Glowing for 2 minutes", true)
                       Player:GlowColor(math.random(1,kNumberofGlows), 120)
                       else
                       self:RollJetpack(Player)
                       end
                 elseif Player:isa("Exo") then
                       if not Player.Glowing then
                       self:NotifyExo( Player, "Glowing for 2 minutes", true)
                       Player:GlowColor(math.random(1,kNumberofGlows), 120)
                       else
                       self:RollJetpack(Player)
                       end
                 elseif Player:isa("Marine") then
                       if not Player.Glowing then
                       self:NotifyMarine( Player, "Glowing for 2 minutes", true)
                       Player:GlowColor(math.random(1,kNumberofGlows), 120)
                       else
                       self:RollMarine(Player)
                       end
                 end
end
function Plugin:RollMarineJetpackMarineExoCombatandNonCombatWeb(Player)
            local  kWebTimer = math.random(5,30)
            Shine.ScreenText.Add( 56, {X = 0.20, Y = 0.80,Text = "Webbed: %s",Duration = kWebTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            Player:SetWebbed(kWebTimer)
       if not self:GetIsInCombatRTD(Player) then 
            if Player:isa("JetpackMarine") then
             self:NotifyJetpackMarine( Player, "webbed for %s seconds", true, kWebTimer)
            elseif Player:isa("Exo") then
             self:NotifyExo(Player,  "webbed for %s seconds", true, kWebTimer)
            elseif Player:isa("Marine") then
            self:NotifyMarine(Player,  "webbed for %s seconds", true, kWebTimer)  
            end
    elseif self:GetIsInCombatRTD(Player) then
            if Player:isa("JetpackMarine") then
             self:NotifyJetpackMarineCombat(Player,  "webbed for %s seconds", true, kWebTimer)
            elseif Player:isa("Exo") then
             self:NotifyExoCombat(Player,  "webbed for %s seconds", true, kWebTimer)
            elseif Player:isa("Marine") then
            self:NotifyMarineCombat( Player, "webbed for %s seconds", true, kWebTimer)  
            end
    end
    self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:RollMarineJetpackMarineExoCombatandNonCombatBonewall(Player)
local bonewall = CreateEntity(BoneWall.kMapName, Player:GetOrigin(), 2)   

       if not self:GetIsInCombatRTD(Player) then 
            if Player:isa("JetpackMarine") then
             self:NotifyJetpackMarine( Player, "Bonewall", true)
            elseif Player:isa("Exo") then
             self:NotifyExo(Player,  "Bonewall", true)
            elseif Player:isa("Marine") then
            self:NotifyMarine(Player,  "Bonewall", true)  
            end
    elseif self:GetIsInCombatRTD(Player) then
            if Player:isa("JetpackMarine") then
             self:NotifyJetpackMarineCombat(Player,  "Bonewall", true)
            elseif Player:isa("Exo") then
             self:NotifyExoCombat(Player,  "Bonewall", true)
            elseif Player:isa("Marine") then
            self:NotifyMarineCombat(Player,  "Bonewall", true)  
            end
    end
    self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:RollMarineJetpackMarineExoParasite(Player)
           Player:SetParasited()
            if Player:isa("JetpackMarine") then
             self:NotifyJetpackMarine(Player,  "Parasite", true)
            elseif Player:isa("Exo") then
             self:NotifyExo(Player,  "Parasite", true)
            elseif Player:isa("Marine") then
            self:NotifyMarine( Player, "Parasite", true)  
            end
            self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
/*
function Plugin:ExoCombatDualMinigunInfiniteFireandNoOverheatRoll(Player)
   if not Player:GetHasDualMiniGun() then self:RollExoCombat(Player) return end
    local kRandoDuration = math.random(5,45)
    self:NotifyExo(Player,  "Rambo: %s seconds", true, kRandoDuration)
    Player.minigunAttacking = true
    Player.rambo = true
    self:CreateTimer(2, kRandoDuration, 1, function () if not Player:GetIsAlive() then self:DestroyTimer(2) self.ScreenText.End(53) return end StartSoundEffectForPlayer(Observatory.kCommanderScanSound, Player) CreateEntity(Scan.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  end )
end
*/
function Plugin:RollMarineJetpackMarineExoChangeClass(Player)
            if Player:isa("JetpackMarine") then
                      local changeclass = math.random(1,2)
                         if changeclass == 1 then
                         self:NotifyJetpackMarine(Player,  "Changeglass to Marine", true)
                         Player:GiveMarine()
                         Player.spawnprotection = false
                         else
                           local exoclass = math.random(1,4)
                           if exoclass == 1 then
                           self:NotifyJetpackMarine(Player,  "Changeglass to Claw Minigun Exo", true)
                           Player:GiveExo(Player:GetOrigin())
                           elseif exoclass == 2 then
                           self:NotifyJetpackMarine(Player,  "Changeglass to Dual Minigun Exo", true)
                           Player:GiveDualExo(Player:GetOrigin())
                           elseif exoclass == 3 then
                           self:NotifyJetpackMarine(Player,  "Changeglass to Claw Railgun Exo", true)
                           Player:GiveClawRailgunExo(Player:GetOrigin())
                           elseif exoclass == 4 then
                           self:NotifyJetpackMarine(Player,  "Changeglass to Dual Railgun Exo", true)
                           Player:GiveDualRailgunExo(Player:GetOrigin())
                           end
                       end
            elseif Player:isa("Exo") then
                         local changeclass = math.random(1,2)
                         if changeclass == 1 then
                          self:NotifyExo(Player,  "Changeglass to Jetpack", true)
                          Player:GiveJetpack()
                        else
                          self:NotifyExo(Player,  "Changeglass to Marine", true)
                          Player:GiveMarine() 
                          Player.spawnprotection = false
                        end
            elseif Player:isa("Marine") then
                         local changeclass = math.random(1,2)
                         if changeclass == 1 then
                         self:NotifyMarine(Player,  "Changeglass to JetpackMarine", true)
                         Player:GiveJetpack()
                         Player.spawnprotection = false
                         else
                           local exoclass = math.random(1,4)
                           if exoclass == 1 then
                           self:NotifyMarine(Player,  "Changeglass to Claw Minigun Exo", true)
                           Player:GiveExo(Player:GetOrigin())
                           elseif exoclass == 2 then
                           self:NotifyMarine(Player,  "Changeglass to Dual Minigun Exo", true)
                           Player:GiveDualExo(Player:GetOrigin())
                           elseif exoclass == 3 then
                           self:NotifyMarine(Player,  "Changeglass to Claw Railgun Exo", true)
                           Player:GiveClawRailgunExo(Player:GetOrigin())
                           elseif exoclass == 4 then
                           self:NotifyMarine(Player,  "Changeglass to Dual Railgun Exo", true)
                           Player:GiveDualRailgunExo(Player:GetOrigin())
                           end
                       end 
            end
end
function Plugin:RollInstantJetpackFuelReplenish(Player)
     local kInfiniteJetpackFuelDuration = math.random(15,60)
      if self:GetIsInCombatRTD(Player) then
      self:NotifyJetpackMarineCombat(Player,  "Instant Jetpack Fuel Replenish: %s seconds", true, kInfiniteJetpackFuelDuration)
      else
      self:NotifyJetpackMarine(Player,  "Instant Jetpack Fuel Replenish: %s seconds", true, kInfiniteJetpackFuelDuration)
      end
     Shine.ScreenText.Add( 68, {X = 0.20, Y = 0.80,Text = "Instant Fuel: %s", Duration = kInfiniteJetpackFuelDuration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
     Player:GiveInfiniteFuel(kInfiniteJetpackFuelDuration)
end
function Plugin:ExoCombatArmor(Player)
           local playerarmor = Player:GetArmor()
            local playermaxarmor = Player:GetMaxArmor()
           local random = math.random(1,playermaxarmor)
           if random == playerarmor then self:ExoCombatArmor(Player) return end
          Player:SetArmor(random)
           self:NotifyExoCombat( Player, "Set armor to %s, previous: %s", true, playermaxarmor, playerarmor)    
           self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:RollAlienScan(Player)
            CreateEntity(Scan.kMapName, Player:GetOrigin(), 1)    
            StartSoundEffectForPlayer(Observatory.kCommanderScanSound, Player)
            self:NotifyAlien( Player, "Scanned", true)
             self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:ChangeAlienClass(Player)

           local number = math.random(1,5)
      self:ChangeClass(Player, number)   
           
end
function Plugin:ChangeClass(Player, number)

         local tochange = number
         
         if tochange == 1 then
                     Player:Replace(Skulk.kMapName, Player:GetTeamNumber(), nil, nil, extraValues)  
                     self:NotifyAlien( Player, "New Class: Skulk", true)  
         elseif tochange == 2 then
                     self:NotifyAlien( Player, "New Class: Gorge", true)  
                     Player:Replace(Gorge.kMapName, Player:GetTeamNumber(), nil, nil, extraValues)  
        elseif tochange == 3 then
                     self:NotifyAlien( Player, "New Class: Lerk", true)  
                     Player:Replace(Lerk.kMapName, Player:GetTeamNumber(), nil, nil, extraValues)  
        elseif tochange == 4 then
                     self:NotifyAlien( Player, "New Class: Fade", true)  
                    Player:Replace(Fade.kMapName, Player:GetTeamNumber(), nil, nil, extraValues)  
       elseif tochange == 5 then
                     self:NotifyAlien( Player, "New Class: Onos", true)  
                     Player:Replace(Onos.kMapName, Player:GetTeamNumber(), nil, nil, extraValues)  
       end
              Player:SetCameraDistance(0)
                if Player.lastUpgradeList then
                    Player.upgrade1 = Player.lastUpgradeList[1] or 1
                    Player.upgrade2 = Player.lastUpgradeList[2] or 1
                    Player.upgrade3 = Player.lastUpgradeList[3] or 1
                 end
end
function Plugin:AlienInCombatRedeem(Player)
if not Player:GetHealthScalar() <= kRedemptionEHPThreshold then self:RollAlienCombat(Player) return end
self:NotifyAlienCombat( Player, "Redeemed", true) 
Player:TeleportToHive() 
 self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:AlienInCombatHallucinate(Player)
self:NotifyAlienCombat( Player, "Hallucination", true)
Player:GiveItem(HallucinationCloud.kMapName)
 self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:AlienInCombatInk(Player)
self:NotifyAlienCombat( Player, "Ink", true)
Player:GiveItem(ShadeInk.kMapName)
 self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:AlienInCombatElectrify(Player)
      local kElectrifyTimer = math.random(5, 30)
     Shine.ScreenText.Add( 61, {X = 0.20, Y = 0.80,Text = "Electrified: %s",Duration = kElectrifyTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      self:NotifyAlienCombat( Player, "Electrified for %s seconds", true, kElectrifyTimer)
      Player:SetElectrified(kElectrifyTimer)
end
function Plugin:AlienInCombatOrSetupEnzyme(Player,issetuproll)
      local  kEnzymeTimer = math.random(15,60)    

            if issetuproll then
            self:NotifyGorgeSetup( Player, "Enzyme for %s seconds", true, kEnzymeTimer)
            else
            self:NotifyAlienCombat( Player, "Enzyme for %s seconds", true, kEnzymeTimer)
            end
                            
    if not ignorenotification then  Shine.ScreenText.Add( 59, {X = 0.20, Y = 0.80,Text = "Enzyme: %s",Duration = kEnzymeTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player ) end
      Player:TriggerFireProofEnzyme(kEnzymeTimer)
end
function Plugin:AlienInCombatUmbra(Player)
      local  kUmbraTimer = math.random(15,60)
      self:NotifyAlienCombat( Player, "Umbra for %s seconds", true, kUmbraTimer)  
      Shine.ScreenText.Add( 60, {X = 0.20, Y = 0.80,Text = "Umbra: %s", Duration = kEnzymeTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      Player:SetHasFireProofUmbra(true, kUmbraTimer)
end
function Plugin:AlienInCombatEnzymeANDUmbra(Player)
     local  kInfiniteEnergyANDUmraTimer = math.random(15,60)
      Shine.ScreenText.Add( 67, {X = 0.20, Y = 0.80,Text ="Energy & Umbra: %s",Duration = kInfiniteEnergyANDUmraTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      self:NotifyAlienCombat( Player, "Enzyme & Umbra for %s seconds", true, kInfiniteEnergyANDUmraTimer)
      Player:SetHasFireProofUmbra(true, kInfiniteEnergyANDUmraTimer)
      Player:TriggerFireProofEnzyme(kInfiniteEnergyANDUmraTimer)
end
function Plugin:AlienInCombatEnergyModification(Player, issetuproll)
    local random = math.random(1,2)
    local duration = math.random(15,60)
    if random == 1 then
            if issetuproll then
            self:NotifyGorgeSetup( Player, "Infinite Energy: %s seconds", true, duration)
            else
            self:NotifyAlienCombat( Player, "Infinite Energy: %s seconds", true, duration)
            end
      Player:TriggerInfiniteEnergy(duration)
      Shine.ScreenText.Add( 65, {X = 0.20, Y = 0.80,Text = "Infinite Energy: %s",Duration = duration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
    else
                if issetuproll then
            self:NotifyGorgeSetup( Player, "Zero Energy: %s seconds", true, duration)
            else
            self:NotifyAlienCombat( Player, "Zero Energy: %s seconds", true, duration)
            end
            
      Shine.ScreenText.Add( 65, {X = 0.20, Y = 0.80,Text = "Zero Energy: %s",Duration = duration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      Player:SetEnergy(0)
       self:CreateTimer(11, 1, duration, function () if not Player:GetIsAlive() then self.ScreenText.End(65) self:DestroyTimer(11) return end Player:SetEnergy(0) end )
    end
end
function Plugin:RollNutrientMist(Player, ignorenotification)
  if not ignorenotification then self:NotifyAlienCombat( Player, "NutrientMist", true) end
Player:GiveItem(NutrientMist.kMapName)
 self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end
function Plugin:RollMarineExoAlienNonCombatLowGravity(Player)

            if Player:isa("Exo") then
                if Player.gravity == -2 then self:RollExo(Player) return end
                self:NotifyExo(Player,  "Low Gravity", true)
                Player.gravity = -2
            elseif Player:isa("Marine") then
                if Player.gravity == -5 then self:RollMarine(Player) return end
                Player.gravity = -5
                self:NotifyMarine(Player,  "Low Gravity", true)  
            elseif Player:isa("Alien") then
               if Player.gravity == -5 then self:RollAlien(Player) return end
                Player.gravity = -5
                self:NotifyAlien(Player,  "Low Gravity", true)  
           end
            
            self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
end

function Plugin:RollMarineJetpackMarineExoCombatOnGroundContamination(Player)

            if Player:isa("JetpackMarine") then
                 if not Player:GetIsOnGround() then self:RollJetpackMarineCombat(Player) return end
                self:NotifyJetpackMarineCombat(Player,  "Contamination", true)
            elseif Player:isa("Exo") then
                 if not Player:GetIsOnGround() then self:RollExoCombat(Player) return end
                 self:NotifyExoCombat(Player,  "Contamination", true)
            elseif Player:isa("Marine") then
               if not Player:GetIsOnGround() then self:RollMarineCombat(Player) return end
                self:NotifyMarineCombat(Player,  "Contamination", true)  
            end
            
    local contamination = CreateEntity(Contamination.kMapName, Player:GetOrigin(), 2)   
    Player:SetOrigin(Player:GetOrigin() + Vector(0,1,0) )
    self.Users[ Player:GetClient() ] = Shared.GetTime() + 30

end
function Plugin:RollMarineJetpackmarineCombatAlterAmmo(Player)

    local random = math.random(1,2)
    local duration = math.random(15,60)
    if random == 1 then
              if Player:isa("JetpackMarine") then
                   self:NotifyJetpackMarineCombat( Player, "Infinite Ammo: %s seconds", true, duration)
              elseif Player:isa("Marine") then
                   self:NotifyMarineCombat( Player, "Infinite Ammo: %s seconds", true, duration)
               end
                   Player.RTDinfiniteammomode = true
                   
                   Shine.ScreenText.Add( 65, {X = 0.20, Y = 0.80,Text = "Infinite Ammo: %s",Duration = duration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
                  self:CreateTimer(12, duration, 1, function () if not Player or not Player:GetIsAlive() then self.ScreenText.End(65) self:DestroyTimer(12) return end Player.RTDinfiniteammomode = false end )
    else
                  if Player:isa("JetpackMarine") then
                   self:NotifyJetpackMarineCombat( Player, "Zero Ammo: %s seconds", true, duration)
                elseif Player:isa("Marine") then
                   self:NotifyMarineCombat( Player, "Zero Ammo: %s seconds", true, duration)
                  end
           Shine.ScreenText.Add( 65, {X = 0.20, Y = 0.80,Text = "Zero Ammo: %s",Duration = duration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
                      self:CreateTimer(5, 1, duration, function () 
                     if not Player:GetIsAlive() or not Player then self:DestroyTimer(5) self.ScreenText.End(57) return end
                     if Player:GetWeaponInHUDSlot(1) ~= nil then 
                     Player:GetWeaponInHUDSlot(1):SetClip(0) 
                     end 
                     if Player:GetWeaponInHUDSlot(0) ~= nil then 
                      Player:GetWeaponInHUDSlot(2):SetClip(0) 
                      end  
                       end )
    end
end
function Plugin:RollMarineSETUPBuildSpeedAdjustment(Player)
     local buildspeed = 0
     local fiftyfifty = math.random(1,2)
        if fiftyfifty == 1 then
        buildspeed = math.random(101, 300)
        elseif fiftyfifty == 2 then
         buildspeed = math.random(0,99)
        end
        
            if buildspeed == 1 then self:RollMarineSETUPBuildSpeedAdjustment(Player) return end
             local duration = math.random(15,45)
             self:NotifyMarineSetup(Player, "%s percent (of 100) build speed for %s seconds", true, buildspeed, duration)
             Shine.ScreenText.Add( 1, {X = 0.20, Y = 0.80,Text = "Altered build speed: %s",Duration = duration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player ) 
             
             
             Player.buildspeed = buildspeed/1000
             self:CreateTimer( 45, duration, 1, 
             function () 
              Player.buildspeed = kUseInterval
              end )
      
end
function Plugin:RollNonGorgeAlienSetup(Player)
           self:RollAlien(Player)
           self:NotifyNonGorgeSetup( Player, "Non Gorge SetupRoll is Currently Empty.")
end
function Plugin:RollGORGESetupBuildBuffDebuff(Player)
                
               local roll = math.random(1,3)
               if roll == 1 then
                   self:NotifyGorgeSetup( Player, "NutrientMist")
                   self:RollNutrientMist(Player, true)
               elseif roll == 2 then
                   self:AlienInCombatOrSetupEnzyme(Player, true)
              elseif roll == 3 then
                   self:AlienInCombatEnergyModification(Player, true)
               end
               
                   
end
function Plugin:RollAlienCombatWhip(Player) 
          local roll = math.random(1,2)
          if roll == 1 then
          CreateEntity(Clog.kMapName, Player:GetOrigin(), Player:GetTeamNumber()) 
          local whip = CreateEntity(Whip.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
          whip:SetConstructionComplete()
          whip:SetOwner(Player)
          Player:GetTeam():RemoveSupplyUsed(kWhipSupply)
          self:NotifyAlienCombat( Player, "Whip + Clog", true)
          elseif roll == 2 then
          self:RollAlienCombat(Player)
          end
end
function Plugin:RollMarineSetupMINE(Player)
  if Player:GetWeaponInHUDSlot(4) == nil then
    Player:GiveItem(LayMines.kMapName) 
    self:NotifyMarineSetup(Player, "Mines", true)
    self.Users[ Player:GetClient() ] = Shared.GetTime() + 30
  else
   self:RollMarineSETUP(Player)
  end
end
function Plugin:AbleToUseSetupRolls()
local Gamerules = GetGamerules()
      if Gamerules then 
            if Gamerules:GetGameStarted() and not Gamerules:GetFrontDoorsOpen() then return true end
      end
      return false
end