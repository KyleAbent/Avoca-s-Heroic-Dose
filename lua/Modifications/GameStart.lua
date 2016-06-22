/*
local function SpawnChairThenSpawnBase(self)
local cc = nil
local tech = nil
                    local techPoints = EntityListToTable(Shared.GetEntitiesWithClassname("TechPoint"))
                    for i=1, #techPoints do
                             tech = techPoints[i]
                          if tech:GetAttached() == nil then
                           local cc = tech:SpawnCommandStructure(1)
                          cc:SetConstructionComplete()
                            self:SpawnBaseEntities(self, tech:GetOrigin())
                          end
                    end

end
*/
local function AlreadySpawned(self, origin)
        local ents = GetEntitiesWithMixinForTeamWithinRange("Construct", 1, origin, 18)
        if ents and #ents >= 4 then return true else return false end
        
end
function Conductor:SpawnBaseEntities(self, origin)
//messy and mir-air. But whatever. Requires GetGroundPosition
local techPointOrigin = nil or origin
        local cc = GetEntitiesForTeam("CommandStructure", 1)
        if cc and #cc > 0 and not techPointOrigin then
            techPointOrigin = cc[1]:GetOrigin()
        end
      
     -- if AlreadySpawned(self, techPointOrigin) then return end -- For when things get reversed

  
        local IPspawnPoint1 = GetRandomBuildPosition( kTechId.InfantryPortal, techPointOrigin, 8 )
        local IPspawnPoint2 = FindFreeSpace(IPspawnPoint1,4)
        local ArmoryPoint = FindFreeSpace(IPspawnPoint2,4)
        local ArmsLabPoint = FindFreeSpace(ArmoryPoint,4)
        local Robotic = FindFreeSpace(ArmsLabPoint,4)
        local PrototypeLabPoint = FindFreeSpace(Robotic,4)
        local PhaseGatePoint = FindFreeSpace(PrototypeLabPoint,4)
        local ObsPoint = FindFreeSpace(PhaseGatePoint,4)
  
    CreateEntity(InfantryPortal.kMapName, IPspawnPoint1, 1)
    CreateEntity(InfantryPortal.kMapName, IPspawnPoint2, 1)
    CreateEntity(Armory.kMapName, ArmoryPoint, 1)
    CreateEntity(ArmsLab.kMapName, ArmsLabPoint, 1)
    CreateEntity(RoboticsFactory.kMapName, Robotic, 1)
    CreateEntity(MAC.kMapName, MacPoint2, 1)
    CreateEntity(MAC.kMapName, MacPoint3, 1)
    CreateEntity(PrototypeLab.kMapName, PrototypeLabPoint, 1)
    CreateEntity(PhaseGate.kMapName, PhaseGatePoint, 1)
    CreateEntity(Observatory.kMapName, ObsPoint, 1)
    
    --if #cc < 3 then
   --   SpawnChairThenSpawnBase(self)
  -- end
        
    
end
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
        
         for i = 1, 2 do
              if Server then
              local techpoint = CreateEntity(TechPoint.kMapName, FindFreeSpace(cc, 8), nil) 
              local chair = techpoint:SpawnCommandStructure(1)
                chair:SetConstructionComplete()
              techpoint:SetIsVisible(false)
               end
              
         end
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
function Conductor:SpawnInitialStructures()
    self:SpawnBaseEntities(self)
    TrySomethingElse(self)
    --SpawnAlienHives(self)
end