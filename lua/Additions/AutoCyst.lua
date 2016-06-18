class 'AutoCyst' (Cyst)
AutoCyst.kMapName = "autocyst"
 local function ReallySpawnCysts(powerpoint, location)
local extents = (location:GetOrigin().x + location:GetOrigin().y + location:GetOrigin().z) - (location.scale.x + location.scale.y + location.scale.z)
local cysts, ratio = GetCystsInLocation(location, powerpoint)
            if cysts == 0 then 
              local cyst = CreateEntity(AutoCyst.kMapName, FindFreeSpace(powerpoint:GetOrigin(),4), 2)
              cyst:SetImmuneToRedeploymentTime(999)
             return 
            end
            
       local ratio = math.abs(extents/(cysts*kCystRedeployRange))
             if ratio >= 4 or cysts == 1 then

                   local nearestcyst = GetNearest(powerpoint:GetOrigin(), "Cyst", 2, function(ent) return GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(powerpoint:GetOrigin()) end)
                    if nearestcyst then
                    --   Print("nearestcyst is %s", nearestcyst)
                      local cyst = CreateEntity(AutoCyst.kMapName, FindFreeSpace(nearestcyst:GetOrigin(), kCystRedeployRange +1), 2)
                         cyst:SetImmuneToRedeploymentTime(999)
                      end
              end
            
end
if Server then
    function GetCystsInLocation(location, powerpoint)
     local extents = (location:GetOrigin().x + location:GetOrigin().y + location:GetOrigin().z) - (location.scale.x + location.scale.y + location.scale.z)
            local entities = GetEntitiesForTeamWithinRange("Cyst", 2, powerpoint:GetOrigin(), 24)
                local cysts = 0
            for i = 1, #entities do
            local entity = entities[i]
                if entity:isa("Cyst") and entity:GetLocationName() == location.name then 
                  cysts = cysts + 1
                end
            end

            
            return cysts, ratio
end
end


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
function PowerPoint:PreOnKill(attacker, doer, point, direction)
self:AddTimedCallback(PowerPoint.CystBrothersActivate, 6)
end 
    function PowerPoint:CystBrothersActivate()
       local location = GetLocationForPoint(self:GetOrigin())
        if location then
       ReallySpawnCysts(self, location)
       end
       return self:GetIsDisabled() or not self:GetIsBuilt()
    
end



Shared.LinkClassToMap("AutoCyst", AutoCyst.kMapName, networkVars)