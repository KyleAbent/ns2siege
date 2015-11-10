//
// lua\MucousableMixin.lua
//

MucousableMixin = CreateMixin( Mucousable )
MucousableMixin.type = "Mucousable"

local kMaxShield = 400

MucousableMixin.networkVars =
{
    mucousShield = "boolean",
    shieldRemaining = string.format("float (0 to %f by 1)", kMaxShield)
}

function MucousableMixin:__initmixin()

    self.mucousShield = false
    self.shieldRemaining = 0
    self.lastMucousShield = 0
    
end

local function ClearShield(self)

    self.mucousShield = false
    self.shieldRemaining = 0    
    
end

function MucousableMixin:OnDestroy()

    if self:GetHasMucousShield() then
        ClearShield(self)
    end
    
end

function MucousableMixin:GetHasMucousShield()
    return self.mucousShield
end

function MucousableMixin:GetMuscousShieldAmount()
    return self.shieldRemaining
end

function MucousableMixin:GetMaxShieldAmount()

 return math.floor(math.min(self:GetBaseHealth() * kMucousShieldPercent, kMaxShield))
  
end

function MucousableMixin:GetShieldPercentage()
    return (self.shieldRemaining / self:GetMaxShieldAmount())
end

function MucousableMixin:ComputeDamageOverrideMixin(attacker, damage, damageType, hitPoint)
    if self:GetHasMucousShield() then
        if damage < self.shieldRemaining then
            self.shieldRemaining = math.max(self.shieldRemaining - damage, 0)
            damage = 0
        else
            damage = math.max(damage - self.shieldRemaining, 0)
            self.shieldRemaining = 0
        end
        if self.shieldRemaining == 0 then
            self.mucousShield = false
        end
    end 
    return damage
end
    
local function SharedUpdate(self)
    if Server then
        self.mucousShield = self.lastMucousShield + kMucousShieldDuration >= Shared.GetTime() and self.shieldRemaining > 0
        if not self.mucousShield and self.shieldRemaining > 0 then
            self.shieldRemaining = 0
        end
    end
end

function MucousableMixin:OnProcessMove(input)   
    SharedUpdate(self)
end

if Server then

    function MucousableMixin:SetMucousShield()
        local time = Shared.GetTime()
        if self.lastMucousShield + kMucousShieldCooldown < time then
            self.mucousShield = true
            self.shieldRemaining = self:GetMaxShieldAmount()
            self.lastMucousShield = time
        end
    end
    
end