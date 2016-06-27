function AddPayLoadTime(seconds)
    local entityList = Shared.GetEntitiesWithClassname("Conductor")
    if entityList:GetSize() > 0 then
               local conductor = entityList:GetEntityAtIndex(0)
                conductor:SendNotification(seconds)
                conductor.payLoadTime = conductor.payLoadTime + seconds
    end    
end
function FindFreeSpace(where, mindistance, maxdistance)    
     if not mindistance then mindistance = .5 end
     if not maxdistance then maxdistance = 24 end
        for index = 1, 8 do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, mindistance, maxdistance, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == GetLocationForPoint(where).name
        
           if spawnPoint ~= nil and sameLocation   then
              return spawnPoint
           end
       end
           Print("No valid spot found for FindFreeSpace")
           return where
end
     function FindArcSpace(where)    
        for index = 1, 12 do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, ARC.kFireRange - 8, 24, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           if spawnPoint ~= nil and GetIsPointWithinHiveRadius(spawnPoint) then
           return spawnPoint
           end
       end
           Print("No valid spot found for FindArcHiveSpawn")
           return nil
end

function GetClosestHiveFromCC(point)
    --Want this to be the closest hive to the current chair
    local cc = GetNearest(point, "CommandStation", 1)  
    local nearesthivetocc = GetNearest(cc:GetOrigin(), "Hive", 2) 
   return nearesthivetocc  
  
end
function GetIsPointWithinHiveRadius(point)     
    /*
    local hivesnearby = GetEntitiesWithinRange("Hive", point, ARC.kFireRange)
      for i = 1, #hivesnearby do
           local ent = hivesnearby[i]
           if ent == GetClosestHiveFromCC(point) then return true end
              return false   
     end
   */
  
   local hive = GetEntitiesWithinRange("Hive", point, ARC.kFireRange)
   if #hive >= 1 then return true end

   return false
end