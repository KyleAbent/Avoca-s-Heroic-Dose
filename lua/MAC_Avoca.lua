
local networkVars = 
{
 avoca = "boolean",

}

local origInit = MAC.OnInitialized

function MAC:OnInitialized()
    origInit(self)
     if  GetAvocaMac() == nil then
           self.avoca = true 
           MAC.kRepairHealthPerSecond = 250
     else
        end
end


function MAC:GetIsAvoca()
 if self.avoca == true then 
  return true
  else
  return false
 end
end

function MAC:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil and self:GetIsAvoca() then
      // if GetConductor():GetIsPhaseTwoBoolean() then
        damageTable.damage = damageTable.damage * 0.25
        //end
    end

end

Shared.LinkClassToMap("MAC", MAC.kMapName, networkVars)