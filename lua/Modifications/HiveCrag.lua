class 'HiveCrag' (Crag)
HiveCrag.kMapName = "hivecrag"

--Nothin yet eh
function HiveCrag:OnCreate()
 Crag.OnCreate(self)
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
end
function HiveCrag:GetMaxHealth()
    return kMatureCragHealth
end 

function HiveCrag:GetMaxArmor()
    return kMatureCragArmor
end 
function HiveCrag:GetDeathIconIndex()
    return kDeathMessageIcon.Crag
end
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