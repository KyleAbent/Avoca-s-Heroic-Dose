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






if Server then

function Lerk:GetTierFourTechId()
    return kTechId.PrimalScream
end




end


