class 'PanicAttack' (Hydra)
PanicAttack.kMapName = "panicattack"


function PanicAttack:OnCreate()
 Hydra.OnCreate(self)
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
end

function PanicAttack:GetSendDeathMessageOverride()
return false
end
function PanicAttack:GetMaxHealth()
    return kHydraHealth * 4
end
function PanicAttack:GetMaxArmor()
    return kHydrayArmor * 4
end
function PanicAttack:OnInitialized()
  Hydra.OnInitialized(self)
  if Server then
        self.targetSelector = TargetSelector():Init(
                self,
                Hydra.kRange * (math.random(1,100)/100) + Hydra.kRange, 
                true,
                { kAlienStaticTargets, kAlienMobileTargets }, { self.FilterTarget(self) } )  
  end
      
end

function PanicAttack:OnGetMapBlipInfo()
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
function PanicAttack:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
        coords.xAxis = coords.xAxis * 2
        coords.yAxis = coords.yAxis * 2
        coords.zAxis = coords.zAxis * 2
    return coords
end
function PanicAttack:ActivateSelfDestruct()
              self:AddTimedCallback(PanicAttack.Killme, 16)
end
function PanicAttack:Killme()
    self:DeductHealth(90)
     return true
end
function PanicAttack:FilterTarget()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end
function PanicAttack:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("AvocaArc") and not target:GetInAttackMode() then
    return false
    end
    
   return target:isa("ARC") and target.health ~= 0 
    
end
Shared.LinkClassToMap("PanicAttack", PanicAttack.kMapName, networkVars)