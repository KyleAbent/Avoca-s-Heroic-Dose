class 'PanicAttack' (Hydra)
PanicAttack.kMapName = "panicattack"


function PanicAttack:OnCreate()
 Hydra.OnCreate(self)
 if Server then self:AddTimedCallback(PanicAttack.Killme, 8) end
end

function PanicAttack:GetSendDeathMessageOverride()
return false
end
function PanicAttack:GetCanBeHealedOverride()
    return false
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
    blipType = kMinimapBlipType.Hydra
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
if Server then
function PanicAttack:Killme()

     --     local wherelocation = GetLocationForPoint(self:GetOrigin())
   -- if not wherelocation or wherelocation:GetIsPowerUp() then 
      self:DeductHealth(50)
     -- end
     return self:GetIsAlive()
end
end
function PanicAttack:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
        coords.xAxis = coords.xAxis * 2
        coords.yAxis = coords.yAxis * 2
        coords.zAxis = coords.zAxis * 2
    return coords
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