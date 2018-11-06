Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/Additions/LerkBileBomb.lua")

local networkVars = {}

function Lerk:GetRebirthLength()
return 4
end
function Lerk:GetRedemptionCoolDown()
return 15
end


local kRandDebuff = Vector(math.random(0,.3), math.random(0,.3), math.random(0,.3)  ) --if 1 isnt too much
function Lerk:GetEngagementPointOverride()
    return self:GetOrigin() + kRandDebuff
end


function Lerk:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
        coords.xAxis = coords.xAxis * 0.8
        coords.yAxis = coords.yAxis * 0.8
        coords.zAxis = coords.zAxis * 0.8
    return coords
end

function Lerk:GetExtentsOverride()
local kXZExtents = 0.4 * 0.8
local kYExtents = 0.4 * 0.8
local crouchshrink = 0
     return Vector(kXZExtents, kYExtents, kXZExtents)
end

local origspeed = Lerk.GetMaxSpeed

function Lerk:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  return not self:GetIsOnFire() and speed * 1.30 or speed
end


function Lerk:OnUpdateAnimationInput(modelMixin)

    Player.OnUpdateAnimationInput(self, modelMixin)
    Alien.OnUpdateAnimationInput(self, modelMixin)
    local attackSpeed = 1.20
      --What's better? GetHasTech or skulk networkvar? I choose networkvar b.c enzyme does that, and primal
    if self.ModifyAttackSpeed then
    
        local attackSpeedTable = { attackSpeed = attackSpeed }
        self:ModifyAttackSpeed(attackSpeedTable)
        attackSpeed = attackSpeedTable.attackSpeed
        
    end
    
    modelMixin:SetAnimationInput("attack_speed", attackSpeed)
    
end


if Server then

function Lerk:GetTierFourTechId()
    return kTechId.PrimalScream
end

function Lerk:GetTierFiveTechId()
    return kTechId.None--LerkBileBomb
end



end


Shared.LinkClassToMap("Lerk", Lerk.kMapName, networkVars, true)