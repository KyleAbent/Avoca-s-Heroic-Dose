class 'PanicAttack' (Hydra)
PanicAttack.kMapName = "panicattack"


function PanicAttack:GetSendDeathMessageOverride()
return false
end

function PanicAttack:GetCanAutoBuild()
return true
end


function PanicAttack:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Hydra
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("PanicAttack", PanicAttack.kMapName, networkVars)