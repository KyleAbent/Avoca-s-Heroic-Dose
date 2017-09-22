/*

function PowerPoint:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
        coords.xAxis = coords.xAxis * 2
        coords.yAxis = coords.yAxis * 1
        coords.zAxis = coords.zAxis * 2
    return coords
end

*/
local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
     return player  --who:SetOwner(player)
    end
end

function PowerPoint:SpawnSurgeForEach(where, who)
           local marine = FindNewParent(who)
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation:GetName() or ""
           if not wherelocation then return end
           
     for _, eligable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct", 2, where, 72)) do
        -- if not eligable:isa("Harvester") and not eligable:isa("Cyst") and not eligable:isa("Hive") then --and not GetIsPointInMarineBase(eligable:GetOrigin()) then
           local location = GetLocationForPoint(eligable:GetOrigin())
           local locationName = location and location:GetName() or ""
           local sameLocation = locationName == wherelocation
          if sameLocation then 
                eligable:DeductHealth(400, marine, nil, true, false, true)
                eligable:TriggerEffects("arc_hit_primary")
          end --
        -- end
     end--
     
end
local orig_PowerPoint_StopDamagedSound = PowerPoint.StopDamagedSound
    function PowerPoint:StopDamagedSound()
    orig_PowerPoint_StopDamagedSound(self)
        if self:GetHealthScalar() ~= 1 then return end
         self:SpawnSurgeForEach(self:GetOrigin(), self)
        -- AddPayLoadTime(kTimeAddPowerBuilt)
       -- local nearestHarvester = GetNearest(self:GetOrigin(), "Harvester", 2, function(ent) return LocationsMatch(self,ent)  end)
      -- if nearestHarvester then nearestHarvester:Kill() end
   end
   /*
local orig_PowerPoint_OnKill = PowerPoint.OnKill
    function PowerPoint:OnKill(attacker, doer, point, direction)
    orig_PowerPoint_OnKill(self)
                --  AddPayLoadTime(kTimeRemovePowerKilled)
    --if not GetIsPointInMarineBase(self:GetOrigin()) then KillAllStructuresInLocation(self:GetOrigin(), 1) end
    
       --local nearestExtractor = GetNearest(self:GetOrigin(), "Extractor", 1, function(ent) return LocationsMatch(self,ent)  end)
      -- if nearestExtractor then
       --  nearestExtractor:Kill()
       --end
       
    end
    */