
local function HasUpgrade(callingEntity, techId)

    if not callingEntity then
        return false
    end

    local techtree = GetTechTree(callingEntity:GetTeamNumber())

    if techtree then
        return callingEntity:GetHasUpgrade(techId) // and techtree:GetIsTechAvailable(techId)
    else
        return false
    end

end

function GetHasRedemptionUpgrade(callingEntity)
   local rand = math.random(1,100)
   local bool = false
     if rand <= 20 then
     bool = true
     end
     
    return bool
end
function GetHasRebirthUpgrade(callingEntity)
   local rand = math.random(1,100)
   local bool = false
     if rand <= 20 then
     bool = true
     end
     
    return bool
end

