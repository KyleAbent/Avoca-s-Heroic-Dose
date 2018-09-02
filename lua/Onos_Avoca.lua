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