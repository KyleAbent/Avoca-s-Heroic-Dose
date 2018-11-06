function ConstructMixin:SetIsACreditStructure(boolean)
    
self.isacreditstructure = boolean
      --Print("AvocaMixin SetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
end
function ConstructMixin:GetCanStick()
     local canstick = not GetSetupConcluded()
     --Print("Canstick = %s", canstick)
     return canstick and self:GetIsACreditStructure() 
end

function ConstructMixin:GetIsACreditStructure()
    
       -- Print("AvocaMixin GetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
return self.isacreditstructure 
 

end


if Server then


function ConstructMixin:AdjustHPArmor()
  if GetIsRoomPowerUp(self) then --if phase 1? or not phase 4?
   local amthp =  self:isa("PowerPoint") and 25 or 100
   local amtarmor =  self:isa("PowerPoint") and 5 or 25
  if not self:GetIsInCombat() then self:AddHealth(amthp) self:AddArmor(amtarmor) end
else
  self:DeductHealth(100)  
 end
  return true//self:GetIsBuilt()
end

local orig consOn = ConstructMixin.OnConstructionComplete
function ConstructMixin:OnConstructionComplete(builder)
      consOn(self, builder)
      if self:GetTeamNumber() == 1 then
      self:AddTimedCallback(ConstructMixin.AdjustHPArmor, 4)
      end
end

function ConstructMixin:OnUpdate(deltaTime)
  if ( self.GetIsInCombat  ) and not self:GetIsInCombat() and not self:isa("PowerPoint") and self:GetTeamNumber() == 1 and not self:GetIsBuilt() and GetIsRoomPowerUp(self) then
 -- Print("derp")
  self:Construct(0.0125)
  end
end


end//server