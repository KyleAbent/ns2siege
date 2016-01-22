function Cyst:GetCanAutoBuild()
    return true
end

function Cyst:OnKill()

    self:TriggerEffects("death")
    self:SetModel(nil)

end   

function Cyst:GetSendDeathMessageOverride()
    return false
end

function Cyst:OnTakeDamage(damage, attacker, doer, point)

    // When we take disconnection damage, don't play alerts or effects, just expire silently
    if doer ~= self and damage > 0 then
        local team = self:GetTeam()
        if team.TriggerAlert then
            team:TriggerAlert(kTechId.AlienAlertStructureUnderAttack, self)
        end
    end
    
end