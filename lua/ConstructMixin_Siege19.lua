/*
local orig = ConstructMixin.__initmixin
function ConstructMixin:__initmixin() --Simple? -- Avoca -- Requires more in this formula. I love while more than onupdate or timedcallback or timer.
   orig (self)
   if self:isa("PowerPoint") or ( Server and GetGameRules() == nil or not GetGameRules():GetMapLoaded() ) then return end
    if GetGameStarted() and  not GetSetupConcluded() then //and powered if marine or unpowered if alien
           while(not GetSetupConcluded() and self.underConstruction == false and (self.timeLastConstruct == nil or self.timeLastConstruct > 4) and self.buildFraction < 0.9) do
              self.timeLastConstruct = Shared.GetTime() //if is powered and marine then not ghost//
              self:Construct(0.25, false) 
              Print("HM")
          end --while
    end --setup
end
*/


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