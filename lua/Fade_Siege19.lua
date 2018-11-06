Script.Load("lua/Weapons/PredictedProjectile.lua")


local origcreate = Fade.OnCreate
function Fade:OnCreate()
origcreate(self)

InitMixin(self, PredictedProjectileShooterMixin)
--InitMixin(self, PhaseGateUserMixin)

end


local origspeed = Fade.GetMaxSpeed
function Fade:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  --return not self:GetIsOnFire() and speed * 1.25 or speed
  return speed
end

function Fade:GetBaseHealth()
    return ConditionalValue( GetHasTech(self, kTechId.AlienHealth1), Fade.kHealth * 1.10, Fade.kHealth) 
end

function Fade:GetRebirthLength()
return 4
end
function Fade:GetRedemptionCoolDown()
return 20
end



if Server then

function Fade:GetTierFourTechId()
    --return kTechId.AcidRocket fix me does dmg entity line 422, rocket line 2014 testme
end

/*
function Fade:GetTierFiveTechId()
    return kTechId.None
end
*/

end