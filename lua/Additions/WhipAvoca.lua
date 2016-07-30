class 'WhipAvoca' (Whip)
WhipAvoca.kMapName = "whipavoca"


function WhipAvoca:GetSendDeathMessageOverride()
return false
end

function WhipAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Whip
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function WhipAvoca:ActivateSelfDestruct()
              self:AddTimedCallback(WhipAvoca.Killme, 16)
end
function WhipAvoca:Killme()
    self:DeductHealth(100)
     return true
end
Shared.LinkClassToMap("WhipAvoca", WhipAvoca.kMapName, networkVars)