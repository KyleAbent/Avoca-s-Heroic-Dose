Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/2019/DigestCommMixin.lua")

local networkVars = {}
AddMixinNetworkVars(DigestCommMixin, networkVars)


function Crag:GetMinRangeAC()
return CragAutoCCMR       
end

local origcreate = Crag.OnCreate
function Crag:OnCreate()
   origcreate(self)
   if not GetHasTech(self, kTechId.CragHeals1) and Crag.kHealPercentage ~= 0.06 then --else stays
      Crag.kHealPercentage = 0.06
      Crag.kMinHeal = 10
      Crag.kMaxHeal = 60
   end
       InitMixin(self, DigestCommMixin)
 end
 

local origbuttons = Crag.GetTechButtons
function Crag:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[5] = kTechId.CragHeals1
  table[8] = kTechId.DigestComm

 
 return table

end


local function ManageHealWave(self)
      for _, entity in ipairs(GetEntitiesWithinRange("Live", self:GetOrigin(), Crag.kHealRadius)) do
                 if not self:GetIsOnFire() and GetIsUnitActive(self) and entity:GetIsInCombat() and entity:GetHealthScalar() <= .9  then
                         self:TriggerHealWave()
                         if self.moving then 
                            self:ClearOrders()
                        end
                end
      end
end



function Crag:InstructSpecificRules()
ManageHealWave(self)
end

 function Crag:OnConstructionComplete()
	 GetImaginator().activeCrags = GetImaginator().activeCrags + 1;  
end


 function Crag:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsBuilt() then
	    GetImaginator().activeCrags  = GetImaginator().activeCrags- 1;  
	  end
end

if Server then

function Crag:OnOrderComplete(currentOrder)
    if currentOrder == kTechId.Move then 
   doChain(self)
    end
end

function Crag:OnResearchComplete(researchId)
  
  if researchId == kTechId.CragHeals1 then
     Crag.kHealPercentage = 0.066--Crag.kHealPercentage * 1.05
     Crag.kMinHeal = 11--Crag.kMinHeal * 1.05
     Crag.kMaxHeal = 66--Crag.kMaxHeal * 1.05
   end

end



end