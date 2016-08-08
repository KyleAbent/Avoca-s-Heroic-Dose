class 'AutoCyst' (Cyst)
AutoCyst.kMapName = "autocyst"

if Server then
   function AutoCyst:GetIsActuallyConnected()
   return true
   end
end


function AutoCyst:GetInfestationRadius()
    return math.max(kInfestationRadius, kCystRedeployRange)
end

function AutoCyst:GetCystParentRange()
return 999
end
function AutoCyst:GetCanAutoBuild()

return true

end




Shared.LinkClassToMap("AutoCyst", AutoCyst.kMapName, networkVars)