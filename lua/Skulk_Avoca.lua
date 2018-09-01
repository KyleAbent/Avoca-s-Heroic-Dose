function Skulk:GetRebirthLength()
return 3
end
function Skulk:GetRedemptionCoolDown()
return 9
end

local kRandDebuff = Vector(math.random(0,.7), math.random(0,.7), math.random(0,.7)  ) --if 1 isnt too much
function Skulk:GetEngagementPointOverride()
    return self:GetOrigin() + kRandDebuff
end