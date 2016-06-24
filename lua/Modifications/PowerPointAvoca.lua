function PowerPoint:ModifyDamageTaken(damageTable, attacker, doer, damageType)
       if attacker and attacker:isa("PowerDrainer") then damageTable.damage = damageTable.damage * 1.5 end
end

