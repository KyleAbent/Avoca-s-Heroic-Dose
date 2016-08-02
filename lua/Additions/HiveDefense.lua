   --Kyle 'Avoca' Abent
 local function GetBuiltStructureCount(className, teamNum, locationId)
        local count = 0
        for _, structure in ipairs(GetEntitiesForTeam(className, teamNum)) do
            if structure:GetIsBuilt() and structure:GetIsAlive() then
                if locationId ~= nil then
                    if structure.locationId == locationId then
                        count = count + 1
                    end
                else
                    count = count + 1
                end
            end
        end
        
        return count
    end
local function GetCragsCount(where)
local crags = 0
          for _, crag in ientitylist(Shared.GetEntitiesWithClassname("Crag")) do
             if crag:GetIsAlive() and not crag:isa("HiveCrag") then crags = crags + 1 end
          end
          return crags

end
local function GetDefenseEntsInRange(who)
 local shifts = GetEntitiesForTeamWithinRange("Shift", 2, who:GetOrigin(), 24)
 local crags = GetCragsCount(who:GetOrigin())
 local hivecrags = GetEntitiesWithinRange("HiveCrag", who:GetOrigin(), 24)
 local shades = GetEntitiesForTeamWithinRange("Shade", 2, who:GetOrigin(), 24)
 local drifters = GetEntitiesForTeamWithinRange("DrifterAvoca", 2, who:GetOrigin(), 9999)
return shifts, crags, hivecrags, shades, drifters
end
local function UpdateTypeOfHive(who)
local hasshade = false
local hasecrag = false
local hasshift = false

             for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
               if hive:GetIsAlive() and hive:GetIsBuilt() then 
                  if hive:GetTechId() ==  kTechId.CragHive then
                  hasecrag = true
                  elseif hive:GetTechId() ==  kTechId.ShadeHive then
                  hasshade = true
                  elseif hive:GetTechId() ==  kTechId.ShiftHive then
                  hasshift = true
                  end
                end
              end
local techids = {}
if hasecrag == false then table.insert(techids, kTechId.CragHive) end
if hasshade == false then table.insert(techids, kTechId.ShadeHive) end
if hasshift == false then table.insert(techids, kTechId.ShiftHive) end
   
   if #techids == 0 then return end 
    for i = 1, #techids do
      local current = techids[i]
      if who:GetTechId() == techid then
      table.remove(techids, current)
      end
    end
    
    local random = table.random(techids)
    
    who:UpgradeToTechId(random) 
    who:GetTeam():GetTechTree():SetTechChanged()

end
function Conductor:MaintainHiveDefense()
 local which = {}

             for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
               if hive:GetIsAlive() and hive:GetIsBuilt() then 
                 table.insert(which, hive)
                end
          end
          if #which == 0 then return true end --false?
          
          for i = 1, #which do
             local hive = which[i]
             if not hive:GetIsResearching() and hive:GetTechId() == kTechId.Hive then UpdateTypeOfHive(hive) end
          end
          
          local hive = table.random(which)
          self:HiveDefenseMain(hive, GetDefenseEntsInRange(hive))
          
                  return true
end
local function GetCanSpawnAlienEntity(trescount)
    return GetGamerules().team2:GetTeamResources() >= trescount
end
local function SpawnUpgChamber(origin)
        local spawned = false
         local veils = Clamp(GetBuiltStructureCount("Veil", 2), 0, 3) 
         local spurs = Clamp(GetBuiltStructureCount("Spur", 2), 0, 3)
         local shells = Clamp(GetBuiltStructureCount("Shell", 2), 0, 3)
         local spawnedupg = false 
         local workaround = nil
            --messy archaic primitive spawn formula because it simply works - built from ground up - improved over time etc
          if veils <= 2 then
          local veil = CreateEntity(Veil.kMapName, FindFreeSpace(origin), 2) 
          veil:SetConstructionComplete()
          workaround = veil
          spawnedupg = true
          end
          
           if spurs <=  2 and not spawnedupg  then
          local spur = CreateEntity(Spur.kMapName, FindFreeSpace(origin), 2) 
          spur:SetConstructionComplete()
          workaround = spur
          spawnedupg = true
           end
           
          if shells <= 2  and not spawnedupg then
          local shell = CreateEntity(Shell.kMapName, FindFreeSpace(origin), 2) 
          shell:SetConstructionComplete()
          workaround = shell
          spawnedupg = true
          end
          
         if spawnedupg == true then
           workaround:GetTeam():SetTeamResources(workaround:GetTeam():GetTeamResources() - 0) 
            end
            
end
function Conductor:HiveDefenseMain(hive, shifts, crags, hivecrags, shades, drifters)
        -- local tres = kStructureDropCost
         if not hive:GetIsAlive() then return end
         local origin = hive:GetOrigin()
        local canafford = GetCanSpawnAlienEntity(0)
        if canafford then SpawnUpgChamber(origin) end    

         
                   if #shifts <= math.random(1,3) then
                      local tres = 0 --kShiftCost
                     -- if GetCanSpawnAlienEntity(tres) then  
                      local shift = CreateEntity(Shift.kMapName, FindFreeSpace(origin), 2) 
                      --shift:GetTeam():SetTeamResources(shift:GetTeam():GetTeamResources() - tres)
                      shift:SetConstructionComplete()
                     -- end
                    end

                    if crags <= math.random(1,3) then
                      if not spawned then
                       local tres = 0 --kCragCost
                     -- if GetCanSpawnAlienEntity(tres) then  
                      local crag = CreateEntity(Crag.kMapName, FindFreeSpace(origin ), 2) 
                    --  crag:GetTeam():SetTeamResources(crag:GetTeam():GetTeamResources() - tres)
                      crag:SetConstructionComplete()
                     -- end
                      end
                    end
      
                    if #hivecrags <= math.random(1,3) then
                      if not spawned then
                    --  if self:GetCanSpawnAlienEntity(tres, 0) then  
                   --   self.team2:SetTeamResources(self.team2:GetTeamResources()  - tres)  
                      local crag = CreateEntity(HiveCrag.kMapName, FindFreeSpace(origin ), 2) 
                      crag:SetConstructionComplete()
                    --  end
                      end
                    end
                    
                    if #shades <= math.random(1,3) then
                       local tres = 0 --kShadeCost
                       if not spawned then 
                    --  if GetCanSpawnAlienEntity(tres) then  
                       local shade = CreateEntity(Shade.kMapName, FindFreeSpace(origin), 2) 
                    --  shade:GetTeam():SetTeamResources(shade:GetTeam():GetTeamResources() - tres)
                      shade:SetConstructionComplete()
                      -- end
                       end
                    end

                    if #drifters <= 2 then
                       local tres = 0 --kShadeCost
                       if not spawned then 
                     -- if GetCanSpawnAlienEntity(tres) then  
                       local drifter = CreateEntity(DrifterAvoca.kMapName, FindFreeSpace(origin), 2) 
                     -- drifter:GetTeam():SetTeamResources(drifter:GetTeam():GetTeamResources() - tres)
                       --end
                       end
                    end
        


end



