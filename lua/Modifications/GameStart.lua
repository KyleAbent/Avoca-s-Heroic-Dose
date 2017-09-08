local function AlreadySpawned(self, origin)
        local ents = GetEntitiesWithMixinForTeamWithinRange("Construct", 1, origin, 18)
        if ents and #ents >= 4 then return true else return false end
        
end
/*


function Conductor:SpawnBaseEntities()
//messy and mir-air. But whatever. Requires GetGroundPosition
local techPointOrigin = nil
        local cc = GetEntitiesForTeam("CommandStructure", 1)
        if cc and #cc > 0 and not techPointOrigin then
            techPointOrigin = cc[1]:GetOrigin()
        end

    CreateEntity(InfantryPortal.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(InfantryPortal.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    --CreateEntity(Armory.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(ArmsLab.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(RoboticsFactory.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    
  --  CreateEntity(BaseMac.kMapName, FindFreeSpace(techPointOrigin,4), 1)
   -- CreateEntity(BaseMac.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    
--    CreateEntity(BigMac.kMapName, FindFreeSpace(techPointOrigin,4), 1)

    --CreateEntity(PrototypeLab.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(PhaseAvoca.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(PhaseGate.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    --CreateEntity(Observatory.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    
    --if #cc < 3 then
   --   SpawnChairThenSpawnBase(self)
  -- end
        
    
end

*/

/*
local function SpawnAlienHives(self)
 local hive = nil
        local hives = GetEntitiesForTeam("Hive", 2)
        if hives and #hives == 1 then
            hive = hives[1]:GetOrigin()
        end
        
         for i = 1, 2 do
              if Server then
              local techpoint = CreateEntity(TechPoint.kMapName, FindFreeSpace(hive, 8), nil) 
              local hive = techpoint:SpawnCommandStructure(2)
                hive:SetConstructionComplete()
              techpoint:SetIsVisible(false)
               end
              
         end
end
*/


local function TrySomethingElse(self)
 local cc = nil
        local ccs = GetEntitiesForTeam("CommandStation", 1)
        if ccs and #ccs == 1 then
            cc = ccs[1]:GetOrigin()
        end
        /*
         for i = 1, 2 do
              if Server then
              local techpoint = CreateEntity(TechPoint.kMapName, FindFreeSpace(cc, 8), nil) 
              local chair = techpoint:SpawnCommandStructure(1)
                chair:SetConstructionComplete()
              techpoint:SetIsVisible(false)
               end
             end
        */

       /*
              local ccs = GetEntitiesForTeam("CommandStation", 1)
              for i = 1, #ccs do
                local chair = ccs[i]
                local vaporizer = CreateEntity(Vaporizer.kMapName, chair:GetOrigin(), 1)
              end 
       */

--self:SpawnBaseEntities(self, cc)    
 
local hive = nil
local tech = nil
                    local techPoints = EntityListToTable(Shared.GetEntitiesWithClassname("TechPoint"))
                    for i=1, #techPoints do
                             tech = techPoints[i]
                          if tech:GetAttached() == nil then
                           local hive = tech:SpawnCommandStructure(2)
                          hive:SetConstructionComplete()
                          end
                    end
         
         
end 
 if Server then
function Conductor:SpawnInitialStructures()
   -- self:SpawnBaseEntities()
    TrySomethingElse(self)
    --SpawnAlienHives(self)
end
end