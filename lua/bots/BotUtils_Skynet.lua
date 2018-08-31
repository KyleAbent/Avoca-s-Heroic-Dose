--stoner ---disre3gard use engagenentpoint
function GetBestAimPoint( target )

    if target.GetEngagementPoint then

        return target:GetEngagementPoint()

    elseif HasMixin( target, "Model" ) then

        local min, max = target:GetModelExtents()
        local o = target:GetOrigin()
        return (min+max)*0.09 + o - Vector(0, 0.2, 0)

    else

        return target:GetOrigin()

    end

end