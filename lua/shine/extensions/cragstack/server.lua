local Shine = Shine
local Plugin = Plugin
local StringFormat = string.format

Plugin.Version = "1.0"

//Shine.Hook.SetupClassHook( "Crag", "DocumentandHookWithShineTheStructureHeal", "DisplayStructureHeal", "Replace" )
Shine.Hook.SetupClassHook( "Crag", "DocumentandHookWithShineThePlayerHeal", "DisplayPlayerHeal", "Replace" )

function Plugin:Initialise()
self.Enabled = true
return true
end
/*
function Plugin:DisplayStructureHeal(healamount, unclampedheal, clampedmaxheal, heal, target)

end
*/
 function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end

  Shine.ScreenText.Add( 1, {X = 0.45, Y = 0.70,Text = "Heal Amount",Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Client )
  Shine.ScreenText.Add( 2, {X = 0.45, Y = 0.65,Text = "UnClamped Heal",Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Client )
  Shine.ScreenText.Add( 3, {X = 0.45, Y = 0.60,Text = "Clamped Max Heal:",Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Client )
  Shine.ScreenText.Add( 4, {X = 0.45, Y = 0.55,Text = "Clamped Min Max Heal",Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Client )
  Shine.ScreenText.Add( 5, {X = 0.45, Y = 0.50,Text = "Interval:",Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Client )
  Shine.ScreenText.Add( 6, {X = 0.45, Y = 0.45,Text = "Target:",Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Client )
    
end
function Plugin:DisplayPlayerHeal(healamount, unclampedheal, clampedmaxheal, heal, Interval, target)
/*
 local player = target:GetClient()
 local controlling = player:GetControllingPlayer()
 local Client = controlling:GetClient()
 */
  Shine.ScreenText.SetText( 1, {X = 0.45, Y = 0.70,Text = StringFormat("Heal Amount: %s",tonumber(healamount)),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,})
  Shine.ScreenText.SetText( 2, {X = 0.45, Y = 0.65,Text = StringFormat("UnClamped Heal: %s", tonumber(unclampedheal)),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,})
  Shine.ScreenText.SetText( 3, {X = 0.45, Y = 0.60,Text = StringFormat("Clamped Max Heal: %s", tonumber(clampedmaxheal)),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,})
  Shine.ScreenText.SetText( 4, {X = 0.45, Y = 0.55,Text = StringFormat("Clamped Min Max Heal: %s", tonumber(heal)),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,})
  Shine.ScreenText.SetText( 5, {X = 0.45, Y = 0.50,Text = StringFormat("Interval: %s", tonumber(Interval)),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,})
  Shine.ScreenText.SetText( 6, {X = 0.45, Y = 0.45,Text = StringFormat("Target: %s", tonumber(target)),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,})

end

function Plugin:NotifyMapStats( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[MapStats]",  255, 0, 0, String, Format, ... )
end

function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end