
Onos.XExtents = .7 * .8
Onos.YExtents = 1.2 * .8 
Onos.ZExtents = .4 * .8

function Onos:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
        coords.xAxis = coords.xAxis * 0.8
        coords.yAxis = coords.yAxis * 0.8
        coords.zAxis = coords.zAxis * 0.8
    return coords
end

/*
function Onos:GetExtentsOverride()
     return Vector(7 * 0.8 , 1.2 * 0.8, .4 * 0.8)
end
*/


function Onos:OnUpdateAnimationInput(modelMixin)

    Player.OnUpdateAnimationInput(self, modelMixin)
    Alien.OnUpdateAnimationInput(self, modelMixin)
    local attackSpeed = self.raged and 1.15 or 1
      --What's better? GetHasTech or skulk networkvar? I choose networkvar b.c enzyme does that, and primal
    if self.ModifyAttackSpeed then
    
        local attackSpeedTable = { attackSpeed = attackSpeed }
        self:ModifyAttackSpeed(attackSpeedTable)
        attackSpeed = attackSpeedTable.attackSpeed
        
    end
    
    modelMixin:SetAnimationInput("attack_speed", attackSpeed)
    
end


function Onos:GetHasMovementSpecial()
    return GetHasTech(self, kTechId.Charge)
end
function Onos:GetRebirthLength()
return 6
end
function Onos:GetRedemptionCoolDown()
return 27
end


function Onos:GetBaseHealth()
    
        if  GetConductor():GetIsPhaseFourBoolean()  then 
       return Onos.kHealth * 1.10
    elseif  GetConductor():GetIsPhaseThreeBoolean()  then 
      
    elseif  GetConductor():GetIsPhaseTwoBoolean()  then 

    elseif GetConductor():GetIsPhaseOneBoolean()  then

    end
     
      return Onos.kHealth 
end


function Onos:PreUpdateMove(input, runningPrediction)
    //Nerp overwrite messy who cares its messy anyway
    if self.charging then
    
             //Don't remove ability, just charge extra.
        local manuverability = ConditionalValue(self.charging, math.max(0, 0.8 - math.sqrt(self:GetChargeFraction())), 1)
        local turboCost = manuverability and 1.15 or 1
        self:DeductAbilityEnergy( ( Onos.kChargeEnergyCost * input.time ) * turboCost )
        
        -- stop charging if out of energy, jumping or we have charged for a second and our speed drops below 4.5
        -- - changed from 0.5 to 1s, as otherwise touchin small obstactles orat started stopped you from charging
        if self:GetEnergy() == 0 or
          (self.timeLastCharge + 1 < Shared.GetTime() and self:GetVelocity():GetLengthXZ() < 4.5) then
        
            self:EndCharge()
            
        end
        
    end
    
    if Server then
        self:Stampede()
    end
    
    if self.autoCrouching then
        self.crouching = self.autoCrouching
    end
    
    
end