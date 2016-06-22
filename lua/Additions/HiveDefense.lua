local function GetDefenseEntsInRange(who)
 local shifts = GetEntitiesForTeamWithinRange("Shift", 2, who:GetOrigin(), 24)
 local crags = GetEntitiesForTeamWithinRange("Crag", 2, who:GetOrigin(), 24)
 local shades = GetEntitiesForTeamWithinRange("Shade", 2, who:GetOrigin(), 24)
return shifts, crags, shades
end
function Conductor:MaintainHiveDefense()
 local which = {}
 
             for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
               if hive:GetIsAlive() and hive:GetIsBuilt() then 
                 table.insert(which, hive)
                end
          end
          if #which == 0 then return true end --false?
          local hive = table.random(which)
          self:HiveDefenseMain(hive, GetDefenseEntsInRange(hive))
          
                  return true
end
function Conductor:HiveDefenseMain(hive, shifts, crags, shades)
        -- local tres = kStructureDropCost
         local spawned = false
         local origin = hive:GetOrigin()
                   if #shifts <= math.random(1,3) then
                   --   if self:GetCanSpawnAlienEntity(tres, 0) then  
                   --   self.team2:SetTeamResources(self.team2:GetTeamResources()  - tres)  
                      local shift = CreateEntity(Shift.kMapName, FindFreeSpace(origin), 2) 
                      shift:SetConstructionComplete()
                  --    end
                    end
                    
                    if #crags <= math.random(1,3) then
                      if not spawned then
                    --  if self:GetCanSpawnAlienEntity(tres, 0) then  
                   --   self.team2:SetTeamResources(self.team2:GetTeamResources()  - tres)  
                      local crag = CreateEntity(HiveCrag.kMapName, FindFreeSpace(origin ), 2) 
                      crag:SetConstructionComplete()
                    --  end
                      end
                    end
                    
                    if #shades <= math.random(1,3) then
                       if not spawned then 
                    --  if self:GetCanSpawnAlienEntity(tres, 0) then  
                     -- self.team2:SetTeamResources(self.team2:GetTeamResources()  - tres)  
                       local shade = CreateEntity(Shade.kMapName, FindFreeSpace(origin), 2) 
                      shade:SetConstructionComplete()
                     --  end
                       end
                    end

        


end



