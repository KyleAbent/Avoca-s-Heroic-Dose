
local networkVars = 
{
 avoca = "boolean",

}

local origInit = MAC.OnInitialized

function MAC:OnInitialized()
    origInit(self)
     if  GetAvocaMac() == nil then
           self.avoca = true 
        --   MAC.kConstructRate =  0.4* 1.4 
        --  MAC.kWeldRate =  0.5 * 1.4
           MAC.kRepairHealthPerSecond =  125
         return
      end
        



    if  GetConductor():GetIsPhaseFourBoolean()  then 
    MAC.kConstructRate =  0.4* 1.30 
    MAC.kWeldRate =  0.5 * 1.30
    MAC.kRepairHealthPerSecond =  50 * 1.30
    elseif  GetConductor():GetIsPhaseThreeBoolean()  then 
    MAC.kConstructRate =  0.4* 1.20 
    MAC.kWeldRate =  0.5 * 1.20
    MAC.kRepairHealthPerSecond =  50 * 1.20
    elseif  GetConductor():GetIsPhaseTwoBoolean()  then 
    MAC.kConstructRate = 0.4* 1.10 
    MAC.kWeldRate =  0.5 * 1.10
    MAC.kRepairHealthPerSecond =  50 * 1.10
    end

   
end


function MAC:GetIsAvoca()
 if self.avoca == true then 
  return true
  else
  return false
 end
end

function MAC:OnUse(player, elapsedTime, useSuccessTable)
        if Server then
            self:GiveOrder(kTechId.FollowAndWeld, player:GetId(), player:GetOrigin(), nil, true, true)
         end
end

function MAC:GetCanBeWeldedOverride()
    return true --self.lastTakenDamageTime + 1 < Shared.GetTime()
end


function MAC:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil and self:GetIsAvoca() then
      -- if GetConductor():GetIsPhaseTwoBoolean() then
        damageTable.damage = damageTable.damage * 0.25
        --end
    end

end

Shared.LinkClassToMap("MAC", MAC.kMapName, networkVars)