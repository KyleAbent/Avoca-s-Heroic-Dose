local function AlreadySpawned(self, origin)
        local ents = GetEntitiesWithMixinForTeamWithinRange("Construct", 1, origin, 18)
        if ents and #ents >= 4 then return true else return false end
        
end



function Conductor:SpawnBaseEntities()
--messy and mir-air. But whatever. Requires GetGroundPosition
local techPointOrigin = nil
        local cc = GetEntitiesForTeam("CommandStructure", 1)
        if cc and #cc > 0 and not techPointOrigin then
            techPointOrigin = cc[1]:GetOrigin()
        end

    CreateEntity(InfantryPortal.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(InfantryPortal.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(Armory.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(ArmsLab.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(RoboticsFactory.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    


    CreateEntity(PrototypeLab.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(PhaseAvoca.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(PhaseGate.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    CreateEntity(Observatory.kMapName, FindFreeSpace(techPointOrigin,4), 1)
    

        
    
end





 if Server then
function Conductor:SpawnInitialStructures()
    self:SpawnBaseEntities()
   -- TrySomethingElse(self)
    --SpawnAlienHives(self)
end
end


