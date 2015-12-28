function ResourceTower:OnSighted(sighted)

    local attached = self:GetAttached()
    if attached and sighted then
        attached.showObjective = true
    end

end
function ResourceTower:GetIsCollecting()

return GetIsUnitActive(self) and GetGamerules():GetGameStarted()

end

