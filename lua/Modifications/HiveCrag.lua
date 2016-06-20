class 'HiveCrag' (Crag)
HiveCrag.kMapName = "hivecrag"

--Nothin yet eh


function HiveCrag:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Crag
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end


Shared.LinkClassToMap("HiveCrag", HiveCrag.kMapName, networkVars)