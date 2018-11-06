

 
 local kRandDebuff = Vector(math.random(0,.3), math.random(0,.3), math.random(0,.3)  ) --if 1 isnt too much
function Lerk:GetEngagementPointOverride()
    return self:GetOrigin() + kRandDebuff
end


/*

Lerk.kHealth = kLerkHealth
function Lerk:GetBaseHealth()
    return ConditionalValue( GetHasTech(self, kTechId.AlienHealth1), Lerk.kHealth * 1.10, Lerk.kHealth)  --Lerk.kHealth
end



function Lerk:OnAdjustModelCoords(modelCoords) --adjust hitbox model too
    local scale = .8
    local coords = modelCoords
    coords.xAxis = coords.xAxis * scale
    coords.yAxis = coords.yAxis * scale
    coords.zAxis = coords.zAxis * scale
      
    return coords
    
end

function Lerk:GetExtentsOverride()
local kXZExtents = 0.4 * 0.8
local kYExtents = 0.4 * 0.8
local crouchshrink = 0
     return Vector(kXZExtents, kYExtents, kXZExtents)
end
*/

function Lerk:GetRebirthLength()
return 4
end
function Lerk:GetRedemptionCoolDown()
return 15
end

if Server then

function Lerk:GetTierFourTechId()
    return kTechId.PrimalScream
end




end



