class 'AutoCyst' (Cyst)
AutoCyst.kMapName = "autocyst"
 local function ReallySpawnCysts(powerpoint, location)
local cysts, ratio = GetCystsInLocation(location, powerpoint)
            if cysts == 0 then 
              local cyst = CreateEntity(AutoCyst.kMapName, FindFreeSpace(powerpoint:GetOrigin(),4), 2)
              cyst:SetImmuneToRedeploymentTime(999)
             return 
            end
            

             if ratio >= 4 then

                   local nearestcyst = GetNearest(powerpoint:GetOrigin(), "AutoCyst", 2, function(ent) return GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(powerpoint:GetOrigin()) end)
                    if nearestcyst then
                    --   Print("nearestcyst is %s", nearestcyst)
                      local cyst = CreateEntity(AutoCyst.kMapName, FindFreeSpace(nearestcyst:GetOrigin(), kCystRedeployRange +1), 2)
                         cyst:SetImmuneToRedeploymentTime(999)
                      end
              end
            
end
if Server then
    function GetCystsInLocation(location, powerpoint)
        if not powerpoint then powerpoint = GetPowerPointForLocation(location.name) end
      /*
          local entities = location:GetEntitiesInTrigger()
           for i = 1, #entities do
              local entity = entities[i]
              if entity:isa("AutoCyst") then Print("AutoCyst found in room") end
           end
      */
         local tableof = {}
            local entities = GetEntitiesForTeamWithinRange("AutoCyst", 2, powerpoint:GetOrigin(), 24)
                local cysts = 0
            for i = 1, #entities do
            local entity = entities[i]
                if GetLocationForPoint(entity:GetOrigin()) == location then 
                  cysts = cysts + 1
                  table.insert(tableof, entity)
                end
            end
            local extents = (location:GetOrigin().x + location:GetOrigin().y + location:GetOrigin().z) - (location.scale.x + location.scale.y + location.scale.z)
            local ratio = math.abs(extents/(cysts*kCystRedeployRange))
            return cysts, ratio, tableof
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