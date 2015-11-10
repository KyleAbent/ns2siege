
local orig_PrototypeLab_GetItemList = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
    if forPlayer:isa("Exo") then
        return { kTechId.Exosuit }
    end
    local otherbuttons = { kTechId.Jetpack, kTechId.Exosuit, kTechId.JumpPack }
             
          if forPlayer.hasjumppack or forPlayer:isa("JetpackMarine")  or forPlayer:isa("Exo") then
              otherbuttons[1] = kTechId.None
              otherbuttons[3] = kTechId.None
           end
            
         return otherbuttons
end
