Script.Load("lua/InfestationMixin.lua")


local networkVars = 

{   

lastCheck = "time",

}

AddMixinNetworkVars(InfestationMixin, networkVars)

local originit = Crag.OnInitialized
function Crag:OnInitialized()
originit(self)
InitMixin(self, InfestationMixin)
self.lastCheck = 0
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
           return Clamp(#crag - 1, 0.1, 10)
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

if Server then


function Crag:OnUpdate(deltaTime)
       if  GetIsTimeUp(self.lastCheck, 4)  then
       local bonus = ( self:GetCragsInRange() * 10/100)
           Crag.kHealRadius = 14 * bonus + 14
           Crag.kHealAmount = 10 * bonus + 10
           Crag.kHealWaveAmount = 50 * bonus + 50
           Crag.kMaxTargets = 3 * bonus + 3
          // Crag.kThinkInterval = .25 
          // Crag.kHealInterval = 2
         //  Crag.kHealEffectInterval = 1
          // Crag.kHealWaveDuration = 8
           Crag.kHealPercentage = 0.06 * bonus + 0.06
           Crag.kMinHeal = 10 * bonus + 10
           Crag.kMaxHeal = 60 * bonus + 60
           Crag.kHealWaveMultiplier = 1.3 * bonus + 1.3
           self.lastCheck = Shared.GetTime()
       end

end

end


Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)

