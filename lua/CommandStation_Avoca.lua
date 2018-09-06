
 function CommandStation:OnAdjustModelCoords(modelCoords)
         local coords = modelCoords
    	local scale = 0.5 
        coords.xAxis = coords.xAxis * scale                       
        coords.yAxis = coords.yAxis * scale                           
        coords.zAxis = coords.zAxis * scale
   
    return coords
end

/*
function CommandStation:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil then
       if GetConductor():GetIsPhaseTwoBoolean() then
        damageTable.damage = damageTable.damage * 2
        end
    end

end
*/