    function Location:OnTriggerEntered(entity, triggerEnt)
        ASSERT(self == triggerEnt)
        local powerPoint = GetPowerPointForLocation(self.name)
            if powerPoint ~= nil then
               if not powerPoint:GetIsDisabled() and not powerPoint:GetIsSocketed() then 
                    if entity:isa("Marine") and not entity:isa("Commander") then
                         powerPoint:SetInternalPowerState(PowerPoint.kPowerState.socketed)  
                    end
                end
            end
      end