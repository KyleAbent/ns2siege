// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MedPack.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/DropPack.lua")

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'MedPack' (DropPack)

MedPack.kMapName = "medpack"

MedPack.kModelName = PrecacheAsset("models/marine/medpack/medpack.model")
MedPack.kHealthSound = PrecacheAsset("sound/NS2.fev/marine/common/health")

MedPack.kHealth = 50

local kPickupDelay = 0.53

local networkVars =
{
}

function MedPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel(MedPack.kModelName)


    
end

function MedPack:OnTouch(recipient)

    if not recipient.timeLastMedpack or recipient.timeLastMedpack + kPickupDelay <= Shared.GetTime() then
    
        recipient:AddHealth(MedPack.kHealth, false, true)
        recipient.timeLastMedpack = Shared.GetTime()
        StartSoundEffectAtOrigin(MedPack.kHealthSound, self:GetOrigin())
        

    
    end
    
end
function GetMedPackLimit(techId, origin, normal, commander)
    local medpacks = 0
        for index, medpack in ientitylist(Shared.GetEntitiesWithClassname("MedPack")) do
                medpacks = medpacks + 1 
         end
    return  medpacks <= 9
    
end
function MedPack:GetIsValidRecipient(recipient)
        if not recipient:isa("Marine") then 			
		                return false 			
        end 
    return recipient:GetIsAlive() and not GetIsVortexed(recipient) and recipient:GetHealth() < recipient:GetMaxHealth() and (not recipient.timeLastMedpack or recipient.timeLastMedpack + kPickupDelay <= Shared.GetTime())
end


Shared.LinkClassToMap("MedPack", MedPack.kMapName, networkVars, false)