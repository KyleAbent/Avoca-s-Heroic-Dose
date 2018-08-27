CreditMixin = CreateMixin( CreditMixin )
CreditMixin.type = "Credit"

CreditMixin.networkVars =
{
isacreditstructure = "boolean",
    
}

function CreditMixin:__initmixin()
   -- Print("%s initmiin avoca mixin", self:GetClassName())
      self.isacreditstructure = false

   --  Print("%s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)

end
function CreditMixin:SetIsACreditStructure(boolean)
    
      self.isacreditstructure = boolean
     -- Print("CreditMixin SetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
end
function CreditMixin:GetCanStick()
     local canstick = false --not GetSetupConcluded()
     --Print("Canstick = %s", canstick)
     return canstick and self:GetIsACreditStructure() 
end

function CreditMixin:GetIsACreditStructure()
    
      --  Print("CreditMixin GetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
return self.isacreditstructure 
 

end