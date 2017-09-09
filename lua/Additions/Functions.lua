 function GetHasCragHive()
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
       if hive:GetTechId() == kTechId.CragHive then return true end
    end
    return false
end
 function GetHasShiftHive()
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
       if hive:GetTechId() == kTechId.ShiftHive then return true end
    end
    return false
end
 function GetHasShadeHive()
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
       if hive:GetTechId() == kTechId.ShadeHive then return true end
    end
    return false
end

function GetRandomHive() 
   local hives = {}
 for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do 
       table.insert(hives, hive)
end
   if #hives == 0 then return nil end
   
   return table.random(hives)
end
/*

local function GetHasArcInRoom(who)
//Though doesn't cover entire area .. then again i didn't measure
           local arcs = GetEntitiesForTeamWithinRange("ARC", 1, who:GetOrigin(), kScanRadius) --arcradius
            if #arcs == 0 then return false end
            
            for i = 1, #arcs do
              local ent = arcs[i]
              local locationName = ent.name
              if locationName == who.name then 
            -- Print("GetHasArcInRoom location %s true", locationName) 
              return true 
               end
            end

            return false
            
end
function GetUnpoweredLocationWithoutArc()
 //gonna be some excess

  local unpoweredloc = {}
  local goTo = {}
 
   for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
             local powerpoint = GetPowerPointForLocation(location.name)
             if powerpoint and powerpoint:GetIsDisabled() then 
             table.insert(unpoweredloc,powerpoint) 
          --     Print("GetUnpoweredLocationWithoutArc  location %s powerpoint disabled", location.name)
             end
   end
   
   for i = 1, #unpoweredloc do
       local loc = unpoweredloc[i]
    --   Print("loc %s", loc.name)
       if not GetHasArcInRoom(loc) then  
       --  Print("loc %s inswerted into table", loc) 
         table.insert(goTo, loc) 
         end
   end
   
   if #unpoweredloc == 0 then return end
   local random = table.random( goTo )
   Print("GetUnpoweredLocationWithoutArc  %s", random)
   return random
   
 
end

*/
function GetRandomDisabledPower()
  local powers = {}
  for _, power in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        if power:GetIsDisabled() then table.insert(powers,power) end
    end
    if #powers == 0 then return nil end
    return table.random(powers)
end
function GetRandomActivePower()
  local powers = {}
  for _, power in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        if power:GetIsBuilt() and not power:GetIsDisabled() then table.insert(powers,power) end
    end
    return table.random(powers)
end
function GetIsRoomPowerDown(who)
 local location = GetLocationForPoint(who:GetOrigin())
  if not location then return false end
 local powernode = GetPowerPointForLocation(location.name)
 if powernode and powernode:GetIsDisabled()  then return true end
 return false
end
local kExtents = Vector(0.4, 0.5, 0.4) -- 0.5 to account for pathing being too high/too low making it hard to palce tunnels
function isPathable(position)
--Gorgetunnelability local function

    local noBuild = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
end
function InsideLocation(ents, teamnum)
local origin = nil
  if #ents == 0  then return origin end
  for i = 1, #ents do
    local entity = ents[i]   
      if teamnum == 2 then
    if entity:isa("Alien") and entity:GetIsAlive() and isPathable( entity:GetOrigin() ) then return FindFreeSpace(entity:GetOrigin(), math.random(2, 4), math.random(8,24), true) end
    elseif teamnum == 1 then
    if entity:isa("Marine") and entity:GetIsAlive() and isPathable( entity:GetOrigin() ) then return FindFreeSpace(entity:GetOrigin(), math.random(2,4), math.random(8,24), false ) end
    end 
  end
return origin
  
end
function GetAllLocationsWithSameName(origin)
local location = GetLocationForPoint(origin)
if not location then return end
local locations = {}
local name = location.name
 for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
        if location.name == name then table.insert(locations, location) end
    end
    return locations
end
 function GetHasActiveObsInRange(where)

            local obs = GetEntitiesForTeamWithinRange("Observatory", 1, where, kScanRadius)
            if #obs == 0 then return false end
            for i = 1, #obs do
             local ent = obs[i]
             if GetIsUnitActive(ent) then return true end
            end
            
            return false  
                
end
function GetHasPGInRoom(where)

            local pgs = GetEntitiesForTeamWithinRange("PhaseGate", 1, where, 999999)
            if #pgs == 0 then return false end
            for i = 1, #pgs do
             local ent = pgs[i]
              if GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(where) then return true end
            end
            
            return false  
                
end
function GetIsTimeUp(timeof, timelimitof)
 local time = Shared.GetTime()
 local boolean = (timeof + timelimitof) < time
 --Print("timeof is %s, timelimitof is %s, time is %s", timeof, timelimitof, time)
 -- if boolean == true then Print("GetTimeIsUp boolean is %s, timelimitof is %s", boolean, timelimitof) end
 return boolean
end

function AddPayLoadTime(seconds)
    local entityList = Shared.GetEntitiesWithClassname("Conductor")
    if entityList:GetSize() > 0 then
                 local conductor = entityList:GetEntityAtIndex(0) 
                conductor:SendNotification(seconds)
                conductor:AddTime(seconds) 
    end    
end
function GetPayLoadArc()
           for _, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                 if ARC.avoca == true then return avocaarc end
          end
    return nil
end
function GetDeployedPayLoadArc()
           for _, avocaarc in ientitylist(Shared.GetEntitiesWithClassname("AvocaArc")) do
                  if ARC.avoca == true and avocaarc:GetInAttackMode( )then return avocaarc end
          end
    return nil
end
function GetIsPointInMarineBase(where)    
    local cclocation = nil
           for _, cc in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
        cclocation = GetLocationForPoint(cc:GetOrigin())
        cclocation = cclocation.name
             break
          end
    
    local pointlocation = GetLocationForPoint(where)
          pointlocation = pointlocation and pointlocation.name or nil
          
          return pointlocation == cclocation
    
end
function FindFreeSpace(where, mindistance, maxdistance, infestreq)    
     if not mindistance then mindistance = .5 end
     if not maxdistance then maxdistance = 24 end
        for index = 1, math.random(4,8) do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, mindistance, maxdistance, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation.name or nil
           local sameLocation = spawnPoint ~= nil and locationName == wherelocation
           
           if infestreq then
             sameLocation = sameLocation and GetIsPointOnInfestation(spawnPoint)
           end
        
           if spawnPoint ~= nil and sameLocation   then
              return spawnPoint
           end
       end
--           Print("No valid spot found for FindFreeSpace")
          if infestreq and not GetIsPointOnInfestation(where) then
             if Server then CreateEntity(Cyst.kMapName, FindFreeSpace(where,1, 6),  2) end
             --For now anyway, bite me. Remove later? :X or tres spend. Who knows right now. I wanna see this in action.
          end
          
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
function GetIsPointWithinTechPointRadius(point)     
    /*
    local hivesnearby = GetEntitiesWithinRange("Hive", point, ARC.kFireRange)
      for i = 1, #hivesnearby do
           local ent = hivesnearby[i]
           if ent == GetClosestHiveFromCC(point) then return true end
              return false   
     end
   */
  
   local tp = GetEntitiesWithinRange("TechPoint", point, ARC.kFireRange)
   if #tp >= 1 then return true end

   return false
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
            return cysts, tableof
end

end