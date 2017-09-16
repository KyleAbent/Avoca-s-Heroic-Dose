--derp

function PrototypeLab:GetMinRangeAC()
return 35 / 3      
end 

local oldfunc = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
        local  otherbuttons = { kTechId.Jetpack, kTechId.DualMinigunExosuit, kTechId.DualRailgunExosuit, 
                                kTechId.DualWelderExosuit, kTechId.DualFlamerExosuit}
        
               
           return otherbuttons
end
