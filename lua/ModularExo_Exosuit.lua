/*
Script.Load("lua/Exosuit.lua")



local networkVars = {
    
}

local orig_Exosuit_OnInitialized = Exosuit.OnInitialized
function Exosuit:OnInitialized()
    orig_Exosuit_OnInitialized(self)

end

if Server then
    local orig_Exosuit_OnUse = Exosuit.OnUse
    function Exosuit:OnUse(player, elapsedTime, useSuccessTable)
        if self:GetIsValidRecipient( player ) and ( not self.useRecipient or self.useRecipient:GetIsDestroyed() ) then
         self.useRecipient = player
     if player and not player:GetIsDestroyed() and self:GetIsValidRecipient(player) then
          local extraValues = {
            leftArmModuleType  = kExoModuleTypes.Claw,
            rightArmModuleType = kExoModuleTypes.Minigun,
            utilityModuleType = kExoModuleTypes.Nano,
            powerModuleType = kExoModuleTypes.None
        }
          player:Replace("exo",player:GetTeamNumber(), false, nil, extraValues)
            DestroyEntity(self)
    end 
      end
    end
end

Class_Reload("Exosuit", networkVars)
*/