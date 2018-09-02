local function DoMoreArmorOnStructThanNormal(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then --and target:GetArmorScalar() > 0.1 then
       -- healthPerArmor = healthPerArmor * (kStructureLightHealthPerArmor / kHealthPointsPerArmor)
        armorFractionUsed = 1
      --  damage = damage * 2
    end
    return damage, armorFractionUsed, healthPerArmor
end
    local kMachineGunPlayerDamageScalar = 1.7
     local function MultiplyForMachineGun(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
     return ConditionalValue(target:isa("Player") or target:isa("Exosuit"), damage * kMachineGunPlayerDamageScalar, damage), armorFractionUsed, healthPerArmor
    end  
function DoAvoca()

    kDamageTypeRules[kDamageType.MachineGun] = {}
    table.insert(kDamageTypeRules[kDamageType.MachineGun], MultiplyForMachineGun)
    
    
 --  kDamageTypeRules[kDamageType.Corrode] = {}
   -- table.insert(kDamageTypeRules[kDamageType.Corrode], ReduceGreatlyForPlayers)
   -- table.insert(kDamageTypeRules[kDamageType.Corrode], IgnoreHealthForPlayersUnlessExo)
    -- table.insert(kDamageTypeRules[kDamageType.Corrode], DoMoreArmorOnStructThanNormal)
    
    
end

function PhaseFourYo(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)

    if target:isa("Player") and attacker:isa("Player") then
    damage = damage * 1.4
    end
    return damage, armorFractionUsed, healthPerArmor

end
