Script.Load("lua/InfestationMixin.lua")


local networkVars = 

{   
}

AddMixinNetworkVars(InfestationMixin, networkVars)

local originit = Crag.OnInitialized
function Crag:OnInitialized()
originit(self)
InitMixin(self, InfestationMixin)
end

  function Crag:GetInfestationRadius()
     if  GetConductor():GetIsPhaseTwoBoolean() then
     return kInfestationRadius
     elseif  GetConductor():GetIsPhaseOneBoolean() then
     return kInfestationRadius/3
     else
     return kInfestationRadius /4
     end
   end



function Crag:GetMinRangeAC()
return 14/3 
end




function Crag:GetCragsInRange()
      local crag = GetEntitiesWithinRange("Crag", self:GetOrigin(), Crag.kHealRadius)
           return Clamp(#crag, 0, 7)
end


function Crag:GetBonusAmt()
return (self:GetCragsInRange()/10)
end


function Crag:GetUnitNameOverride(viewer) --Triggerhappy stoner
    local unitName = GetDisplayName(self)   
    --unitName = string.format(Locale.ResolveString("Crag (+%sS 0%)"), self:GetCragsInRange()) --, self:GetBonusAmt() )
    unitName = "Crag (+"..self:GetCragsInRange().."0% heal)" --, self:GetBonusAmt() )
return unitName
end


function Crag:TryHeal(target)

    local unclampedHeal = target:GetMaxHealth() * Crag.kHealPercentage
    local heal = Clamp(unclampedHeal, Crag.kMinHeal, Crag.kMaxHeal) 
       
    if self.healWaveActive then
        heal = heal * Crag.kHealWaveMultiplier
    end
    
    --heal = heal * self:GetCragsInRange()/3 + heal
    if self:GetCragsInRange() >= 1 then
    heal = heal * self:GetBonusAmt() + heal
    end
    
   -- if self:GetIsSiege() and self:IsInRangeOfHive() and target:isa("Hive") or target:isa("Crag") then
   --    heal = heal * kCragSiegeBonus
   -- end
    
    if target:GetHealthScalar() ~= 1 and (not target.timeLastCragHeal or target.timeLastCragHeal + Crag.kHealInterval <= Shared.GetTime()) then
       local amountHealed = target:AddHealth(heal)
       target.timeLastCragHeal = Shared.GetTime()
       
       return amountHealed
    else
        return 0
    end
   
end


Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)

