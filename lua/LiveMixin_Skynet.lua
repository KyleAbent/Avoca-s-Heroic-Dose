local origkill = LiveMixin.Kill
function LiveMixin:Kill(attacker, doer, point, direction)
  if self:GetIsAlive() and self:GetCanDie() then
          ---Rebirth
          
         if self:isa("Alien") then
         
      
          if GetHasRebirthUpgrade(self) and self:GetEligableForRebirth() then
                if Server then 
                    if attacker and attacker:isa("Player")  then 
                      local points = self:GetPointValue()
                       attacker:AddScore(points)
                     end 
                    end
                self:TriggerRebirth()
                return
                end
            
            if Server and GetConductor():GetIsPhaseTwoBoolean() and math.random(1,100) >= 30 then  
             if  self:isa("Skulk")   then
              CreateEntity(Rupture.kMapName, point, 2)
              elseif self:isa("Gorge") then
              --CreateEntity(Babbler.kMapName, point, 2)
              -- CreateEntity(Babbler.kMapName, point, 2)
              --CreateEntity(Babbler.kMapName, point, 2)
              --CreateEntity(Babbler.kMapName, point, 2)
             end
            end
         end
            
            --Hunger
            
      if self:GetTeamNumber() == 1 then 
      --   if self:isa("Player")  then
          /*
              if attacker and attacker:isa("Alien") and attacker:isa("Player") and GetHasHungerUpgrade(attacker) then
                  local duration = 6
                     if attacker:isa("Onos") then
                       duration = duration * .7
                       end
                    attacker:TriggerEnzyme(duration)

          attacker:AddEnergy(attacker:GetMaxEnergy() * .10 )
          attacker:AddHealth(attacker:GetHealth() * (10/100))
          */
        --end
     -- elseif
        --Default
        if ( HasMixin(self, "Construct") or self:isa("ARC") or self:isa("MAC") ) and attacker and attacker:isa("Player") then 
              --if GetHasHungerUpgrade(attacker) and attacker:isa("Gorge") and doer:isa("DotMarker") then 
                if attacker:isa("Gorge") and doer:isa("DotMarker") then 
                        attacker:TriggerEnzyme(5)
                        attacker:AddEnergy(30)
               end
          end
     end 
     
            
            
   end     
return origkill(self, attacker, doer, point, direction)
end