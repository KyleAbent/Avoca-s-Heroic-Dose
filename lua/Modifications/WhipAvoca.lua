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
function WhipAvoca:UpdateRootState()
    
    local infested = true --self:GetGameEffectMask(kGameEffect.OnInfestation)
    local moveOrdered = self:GetCurrentOrder() and self:GetCurrentOrder():GetType() == kTechId.Move
    -- unroot if we have a move order or infestation recedes
    if self.rooted and (moveOrdered or not infested) then
        self:Unroot()
    end
    
    -- root if on infestation and not moving/teleporting
    if not self.rooted and infested and not (moveOrdered or self:GetIsTeleporting()) then
        self:Root()
    end
    
end

function WhipAvoca:Killme()
    self:DeductHealth(100)
     return true
end
Shared.LinkClassToMap("WhipAvoca", WhipAvoca.kMapName, networkVars)