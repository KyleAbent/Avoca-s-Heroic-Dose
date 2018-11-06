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
		 if not hive:GetIsAlive() then return end
         local origin = hive:GetOrigin()
        local canafford = true --GetCanSpawnAlienEntity(0)
        if canafford then SpawnUpgChamber(origin) end    
          
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
         -- veil:SetConstructionComplete() Phase Four?
          workaround = veil
          spawnedupg = true
          end
          
           if spurs <=  2 and not spawnedupg  then
          local spur = CreateEntity(Spur.kMapName, FindFreeSpace(origin), 2) 
         -- spur:SetConstructionComplete() Phase Four?
          workaround = spur
          spawnedupg = true
           end
           
          if shells <= 2  and not spawnedupg then
          local shell = CreateEntity(Shell.kMapName, FindFreeSpace(origin), 2) 
        --shell:SetConstructionComplete() 
          workaround = shell
          spawnedupg = true
          end
          
        -- if spawnedupg == true then
        --   workaround:GetTeam():SetTeamResources(workaround:GetTeam():GetTeamResources() - 0) 
          --  end
            
end



