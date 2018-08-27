if Server then
   function Cyst:GetIsActuallyConnected()
   return true
   end
end


function Cyst:GetInfestationRadius()
    return math.max(kInfestationRadius, kCystRedeployRange)
end

function Cyst:GetCystParentRange()
return 999
end
function Cyst:GetCanAutoBuild()

return true

end

