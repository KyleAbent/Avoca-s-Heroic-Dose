function Fade:GetCanMetabolizeHealth()
    return GetHasTech(self, kTechId.MetabolizeHealth)
end


function Fade:GetRebirthLength()
return 4
end
function Fade:GetRedemptionCoolDown()
return 20
end