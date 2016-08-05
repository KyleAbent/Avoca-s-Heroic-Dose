class 'Janitor' (Hydra)
Janitor.kMapName = "janitor"


function Janitor:OnCreate()
 Hydra.OnCreate(self)
 if Server then self:AddTimedCallback(Janitor.Killme, 8) end
  self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
end
function Janitor:GetCanBeHealedOverride()
    return false
end
function Janitor:GetSendDeathMessageOverride()
return false
end
function Janitor:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    local damage = 1
        if doer and doer:isa("MainRoomArc") then --maybe not bigarc
         damage = damage * .25
         -- damage = damage * Clamp(doer:GetHealthScalar(), 0.25, 1) maybe not sure
         end
        damageTable.damage = damageTable.damage * damage
end
function Janitor:GetMaxHealth()
    return kMatureHydraHealth
end
function Janitor:GetMaxArmor()
    return kMatureHydraArmor
end
if Server then
function Janitor:Killme()

     --     local wherelocation = GetLocationForPoint(self:GetOrigin())
   -- if not wherelocation or wherelocation:GetIsPowerUp() then 
      self:DeductHealth(100)
     -- end
     return self:GetIsAlive()
end
end
function Janitor:OnInitialized()
  Hydra.OnInitialized(self)
  if Server then
        self.targetSelector = TargetSelector():Init(
                self,
                72, 
                true,
                { kAlienStaticTargets, kAlienMobileTargets }, { self.FilterTarget(self) } )  
  end
      
end

function Janitor:OnGetMapBlipInfo()
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
function Janitor:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
        coords.xAxis = coords.xAxis * 2
        coords.yAxis = coords.yAxis * 2
        coords.zAxis = coords.zAxis * 2
    return coords
end
function Janitor:FilterTarget()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end
function Janitor:GetCanFireAtTargetActual(target, targetPoint)        
   if  HasMixin(target, "Construct") and target.health ~= 0 then return true end
   
   return false
    
end
Shared.LinkClassToMap("Janitor", Janitor.kMapName, networkVars)