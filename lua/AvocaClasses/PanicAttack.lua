class 'PanicAttack' (Hydra)
PanicAttack.kMapName = "panicattack"


function PanicAttack:OnCreate()
 Hydra.OnCreate(self)
 if Server then self:AddTimedCallback(PanicAttack.Killme, 8) end
  self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
end
function PanicAttack:GetMaxHealth()
    return kMatureHydraHealth * 4
end
function PanicAttack:GetMaxArmor()
    return 0
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
if Server then

local function CreateSpikeProjectile(self)
    local startPoint = self:GetBarrelPoint()
    local directionToTarget = self.target:GetEngagementPoint() - self:GetEyePos()
    local targetDistanceSquared = directionToTarget:GetLengthSquared()
    local theTimeToReachEnemy = targetDistanceSquared / (Hydra.kSpikeSpeed * Hydra.kSpikeSpeed)
    local engagementPoint = self.target:GetEngagementPoint()
    if self.target.GetVelocity then
    
        local targetVelocity = self.target:GetVelocity()
        engagementPoint = self.target:GetEngagementPoint() - ((targetVelocity:GetLength() * Hydra.kTargetVelocityFactor * theTimeToReachEnemy) * GetNormalizedVector(targetVelocity))
        
    end
    local fireDirection = GetNormalizedVector(engagementPoint - startPoint)
    local fireCoords = Coords.GetLookIn(startPoint, fireDirection)    
    local spreadDirection = CalculateSpread(fireCoords, Hydra.kSpread, math.random)
    local endPoint = startPoint + spreadDirection * Hydra.kRange
        self:DoDamage(Hydra.kDamage, self.target, endPoint, fireDirection)
end

function PanicAttack:AttackTarget()

    self:TriggerUncloak()
    
    CreateSpikeProjectile(self)    
    self:TriggerEffects("hydra_attack")
    
    -- Random rate of fire to prevent players from popping out of cover and shooting regularly
    self.timeOfNextFire = Shared.GetTime() + 1 + math.random()
    
end


end
Shared.LinkClassToMap("PanicAttack", PanicAttack.kMapName, networkVars)