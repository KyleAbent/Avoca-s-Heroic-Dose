local function SpawnBaseEntities(self)
//messy and mir-air. But whatever. Requires GetGroundPosition
local techPointOrigin = nil
        local cc = GetEntitiesForTeam("CommandStructure", 1)
        if cc and #cc > 0 then
            techPointOrigin = cc[1]:GetOrigin()
        end
        
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
        
    
end
function Conductor:SpawnInitialStructures()
    SpawnBaseEntities(self)
end