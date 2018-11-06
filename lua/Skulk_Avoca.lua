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

function Skulk:OnUpdateAnimationInput(modelMixin)

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