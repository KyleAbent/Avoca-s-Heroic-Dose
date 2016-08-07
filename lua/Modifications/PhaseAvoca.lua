class 'PhaseAvoca' (PhaseGate)
PhaseAvoca.kMapName = "phaseavoca"

function PhaseAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.PhaseGate
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end




Shared.LinkClassToMap("PhaseAvoca", PhaseAvoca.kMapName, networkVars)