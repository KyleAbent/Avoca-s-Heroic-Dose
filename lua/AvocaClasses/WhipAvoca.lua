class 'WhipAvoca' (Whip)
WhipAvoca.kMapName = "whipavoca"


function WhipAvoca:OnCreate()
 Whip.OnCreate(self)
  self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
end

function WhipAvoca:GetSendDeathMessageOverride()
return false
end
function WhipAvoca:GetMaxHealth()
    return kMatureWhipHealth * 1.3
end
function WhipAvoca:GetMaxArmor()
    return kMatureWhipArmor * 1.3 
end
function WhipAvoca:ModifyDamageTaken(damageTable, attacker, doer, damageType)
local damage = 1
        if doer and doer:isa("MainRoomArc") then 
         damage = damage * .35
         -- damage = damage * Clamp(doer:GetHealthScalar(), 0.25, 1) maybe not sure
         end
        damageTable.damage = damageTable.damage * damage
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
        self:Kill()
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

function WhipAvoca:OnInitialized()
  Whip.OnInitialized(self)
      
  
  if Server then
        local targetTypes = { kAlienStaticTargets, kAlienMobileTargets }
        self.slapTargetSelector = TargetSelector():Init(self, Whip.kRange + 4, true, targetTypes,  { self.FilterTarget(self) })
        self.bombardTargetSelector = TargetSelector():Init(self, Whip.kBombardRange + 4, true, targetTypes, { self.FilterTarget(self) })
  end
      
end
function WhipAvoca:FilterTarget()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end
function WhipAvoca:GetCanFireAtTargetActual(target, targetPoint)    
      if target:isa("AvocaArc") and not target:GetInAttackMode() then
    return false
    end
    
    return target.health ~= 0 
    
end
Shared.LinkClassToMap("WhipAvoca", WhipAvoca.kMapName, networkVars)