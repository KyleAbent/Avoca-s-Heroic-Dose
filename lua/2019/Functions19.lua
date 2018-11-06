function GetASiegeLocation()
 local siegeloc = nil

 for _, loc in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
    if string.find(loc.name, "siege") or string.find(loc.name, "Siege") then
      siegeloc = loc
    end
 end
 
    if siegeloc then 
    return siegeloc
    end
    
    return nil
end
function doChain(entity) --I can't believe this works lol
  local where = entity:GetOrigin()
   if GetIsPointOnInfestation(where) then return end
   local cyst = GetEntitiesWithinRange("Cyst",where, 7)
   if (#cyst >=1) then return end
        
   local splitPoints = GetCystPoints(entity:GetOrigin(), true, 2)
   
    for i = 1, #splitPoints do
         local csyt = CreateEntity(Cyst.kMapName, FindFreeSpace(splitPoints[i], 1, 7), 2)
         if not GetSetupConcluded() then csyt:SetConstructionComplete() end
    end
end
function GetIsPointWithinChairRadius(point)     
  
   local cc = GetEntitiesWithinRange("CommandStation", point, ARC.kFireRange)
   if #cc >= 1 then return true end

   return false
end
function GetNearestMixin(origin, mixinType, teamNumber, filterFunc)
    assert(type(mixinType) == "string")
    local nearest = nil
    local nearestDistance = 0
    for index, ent in ientitylist(Shared.GetEntitiesWithTag(mixinType)) do
        if not filterFunc or filterFunc(ent) then
            if teamNumber == nil or (teamNumber == ent:GetTeamNumber()) then
                local distance = (ent:GetOrigin() - origin):GetLength()
                if nearest == nil or distance < nearestDistance then
                    nearest = ent
                    nearestDistance = distance
                end
            end
        end
    end
    return nearest
end
function GetImaginator() 
    local entityList = Shared.GetEntitiesWithClassname("Imaginator")
    if entityList:GetSize() > 0 then
                 local imaginator = entityList:GetEntityAtIndex(0) 
                 return imaginator
    end    
    return nil
end
function GetConductor() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("Conductor")
    if entityList:GetSize() > 0 then
                 local conductor = entityList:GetEntityAtIndex(0) 
                 return conductor
    end    
    return nil
end

function GetGStartTime()
    
        for _, ginfo in ipairs(GetEntitiesWithinRange("GameInfo", where, 8)) do
         if ginfo then return ginf:GetStartTime() end
    end
    
    
    return nil
end

 function IsInRangeOfHive(who)
      local hives = GetEntitiesWithinRange("Hive", who:GetOrigin(), Shade.kCloakRadius)
   if #hives >=1 then return true end
   return false
end
 function GetTechPoint(where) --getnearest
    for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", where, 8)) do
         if techpoint then return techpoint end
    end
end
function TresCheck(team, cost)
    if team == 1 then
    return GetGamerules().team1:GetTeamResources() >= cost
    elseif team == 2 then
    return GetGamerules().team2:GetTeamResources() >= cost
    end

end

 function UpdateTypeOfHive(who)
local techids = {}
if GetHasCragHive() == false then table.insert(techids, kTechId.CragHive) end
if GetHasShadeHive() == false then table.insert(techids, kTechId.ShadeHive) end
if GetHasShiftHive() == false then table.insert(techids, kTechId.ShiftHive) end
   
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

function GetIsOriginInHiveRoom(point)  
 local location = GetLocationForPoint(point)
 local hivelocation = nil
     local hives = GetEntitiesWithinRange("Hive", point, 999)
     if not hives then return false end
     
     for i = 1, #hives do  --better way to do this i know
     local hive = hives[i]
     hivelocation = GetLocationForPoint(hive:GetOrigin())
     break
     end
     
     if location == hivelocation then return true end
     
     return false
     
end
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

function GetRandomDisabledPowerNotHive()
  local powers = {}
  for _, power in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        if not GetIsOriginInHiveRoom(power:GetOrigin()) and power:GetIsBuilt() and power:GetIsDisabled() then  table.insert(powers,power)  end
    end
    if #powers == 0 then return nil end
    local power = table.random(powers)
    return  power
end
function GetRandomDisabledPower()
  local powers = {}
  for _, power in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        if  power:GetIsBuilt() and power:GetIsDisabled() then  table.insert(powers,power)  end
    end
    if #powers == 0 then return nil end
    local power = table.random(powers)
    return  power
end
function GetRandomCC()
  local ccs = {}
  for _, cc in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
        if cc and cc:GetIsBuilt() then table.insert(ccs,cc) end
    end
    return table.random(ccs)
end
function GetRandomActivePower()
  local powers = {}
  for _, power in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        if power:GetIsBuilt() and not power:GetIsDisabled() then table.insert(powers,power) end
    end
    return table.random(powers)
end
function GetIsRoomPowerUp(who)
 local location = GetLocationForPoint(who:GetOrigin())
  if not location then return false end
 local powernode = GetPowerPointForLocation(location.name)
 if powernode and powernode:GetIsBuilt() and not powernode:GetIsDisabled()  then return true end
 return false
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
function GetAvocaMac()
           for _, arc in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                 if arc:GetIsAvoca() then return arc end
          end
    return nil
end

function GetPayLoadArc()
           for _, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                 if arc:GetIsPL() then return arc end
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
    
           for _, cc in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
              local cclocation = nil
              cclocation = GetLocationForPoint(cc:GetOrigin())
              cclocation = cclocation and cclocation.name or nil
              local pointlocation = GetLocationForPoint(where)
               pointlocation = pointlocation and pointlocation.name or nil
              if pointlocation == cclocation then return true end
          end
    


          
          return false
    
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
         -- if infestreq and not GetIsPointOnInfestation(where) then
            -- if Server then CreateEntity(Cyst.kMapName, FindFreeSpace(where,1, 6),  2) end
             --For now anyway, bite me. Remove later? :X or tres spend. Who knows right now. I wanna see this in action.
        --  end
          
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
  
   local tp = GetEntitiesWithinRange("TechPoint", point, ARC.kFireRange)
   if #tp >= 1 then return true end

   return false
end
function GetIsPointWithinHiveRadius(point)     

   local hive = GetEntitiesWithinRange("Hive", point, ARC.kFireRange)
   if #hive >= 1 then return true end

   return false
end




--copied
function GetRoomHasNoBackupBattery(techId, origin, normal, commander)

    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local validRoom = false
    
    if locationName then
    
        validRoom = true
    
        for index, sentryBattery in ientitylist(Shared.GetEntitiesWithClassname("BackupBattery")) do
            
            if sentryBattery:GetLocationName() == locationName then
                validRoom = false
                break
            end
            
        end
    
    end
    
    return validRoom

end
function GetNearestMixin(origin, mixinType, teamNumber, filterFunc)
    assert(type(mixinType) == "string")
    local nearest = nil
    local nearestDistance = 0
    for index, ent in ientitylist(Shared.GetEntitiesWithTag(mixinType)) do
        if not filterFunc or filterFunc(ent) then
            if teamNumber == nil or (teamNumber == ent:GetTeamNumber()) then
                local distance = (ent:GetOrigin() - origin):GetLength()
                if nearest == nil or distance < nearestDistance then
                    nearest = ent
                    nearestDistance = distance
                end
            end
        end
    end
    return nearest
end
function GetIsRoomPowerUp(who)
 local location = GetLocationForPoint(who:GetOrigin())
  if not location then return false end
 local powernode = GetPowerPointForLocation(location.name)
 if powernode and powernode:GetIsBuilt() and not powernode:GetIsDisabled()  then return true end
 return false
end
function GetSiegeLocation(where)
--local locations = {}


 local siegeloc = nil

  siegeloc = GetNearest(where, "Location", nil, function(ent) return string.find(ent.name, "siege") or string.find(ent.name, "Siege") end)

 
if siegeloc then return siegeloc end
 return nil
end

function GetIsOriginInHiveRoom(point)  
 local location = GetLocationForPoint(point)
 local hivelocation = nil
     local hives = GetEntitiesWithinRange("Hive", point, 999)
     if not hives then return false end
     
     for i = 1, #hives do  --better way to do this i know
     local hive = hives[i]
     hivelocation = GetLocationForPoint(hive:GetOrigin())
     break
     end
     
     if location == hivelocation then return true end
     
     return false
     
end


local function UnlockAbility(forAlien, techId)

    local mapName = LookupTechData(techId, kTechDataMapName)
    if mapName and forAlien:GetIsAlive() then
    
        local activeWeapon = forAlien:GetActiveWeapon()

        local tierWeapon = forAlien:GetWeapon(mapName)
        if not tierWeapon then
        
            forAlien:GiveItem(mapName)
            
            if activeWeapon then
                forAlien:SetActiveWeapon(activeWeapon:GetMapName())
            end
            
        end
    
    end

end
function UpdateSiegeAbility(forAlien, tierThreeTechId, tierFourTechId, tierFiveTechId)
        

        local team = forAlien:GetTeam()
        if team and team.GetTechTree then

   local t3 = false
   local t4 = false
   local t5 = false
     
            t3 = GetGamerules():GetAllTech() or (tierThreeTechId ~= nil and tierThreeTechId ~= kTechId.None and GetHasTech(forAlien, tierThreeTechId))
            t4 = GetGamerules():GetAllTech() or (tierFourTechId ~= nil and tierFourTechId ~= kTechId.None and t3)
             t5 = GetGamerules():GetAllTech() or (tierFiveTechId ~= nil and tierFiveTechId ~= kTechId.None and t3)

            
            
               if t4 then
               UnlockAbility(forAlien,  tierFourTechId)
            end
            
            if t5 then
               UnlockAbility(forAlien, tierFiveTechId)
            end
            
            
    --Print("t1 is %s", t1)
    --Print("t2 is %s", t2)
    --Print("t3 is %s", t3)
  --  Print("t4 is %s", t4)
            
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


function GetSetupConcluded()
return GetFrontDoorOpen()
end
function GetFrontDoorOpen()
   return GetTimer():GetFrontOpenBoolean()
end
function GetSiegeDoorOpen()
   local boolean = GetTimer():GetSiegeOpenBoolean()
   return boolean
end



function GetPayloadPercent()  //change to link 
    local entityList = Shared.GetEntitiesWithClassname("AvocaArc")
    if entityList:GetSize() > 0 then
                 local payload = entityList:GetEntityAtIndex(0) 
                 local furthestgoal = payload:GetHighestWaypoint()
                 local speed = payload:GetMoveSpeed()
                 local isReverse = speed < 1
                 local distance =  GetPathDistance(payload:GetOrigin(), furthestgoal:GetOrigin()) 
                 local time = math.round(distance / speed, 1)
                 //Print("Distance is %s, speed is %s, time is %s", distance, speed, time)
                 return time, speed, isReverse
    end    
    return nil
end

function GetSiegeDoor() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("SiegeDoor")
    if entityList:GetSize() > 0 then
                 local siegedoor = entityList:GetEntityAtIndex(0) 
                 return siegedoor
    end    
    return nil
end
function GetTimer() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("Timer")
    if entityList:GetSize() > 0 then
                 local timer = entityList:GetEntityAtIndex(0) 
                 return timer
    end    
    return nil
end

function GetGameStarted()
     local gamestarted = false
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   return gamestarted
end
function GetIsInSiege(who)
local locationName = GetLocationForPoint(who:GetOrigin())
                     locationName = locationName and locationName.name or nil
                     if locationName== nil then return false end
if locationName and string.find(locationName, "siege") or string.find(locationName, "Siege") then return true end
return false
end

function GetWhereIsInSiege(where)
local locationName = GetLocationForPoint(where)
                     locationName = locationName and locationName.name or nil
                     if locationName== nil then return false end
if string.find(locationName, "siege") or string.find(locationName, "Siege") then return true end
return false
end



      function FindArcHiveSpawn(where)    
        for index = 1, 24 do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, 2, 18, EntityFilterAll())
           local inradius = false

           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
             inradius = #GetEntitiesWithinRange("Hive", spawnPoint, ARC.kFireRange) >= 1
           end
                -- Print("FindArcHiveSpawn inradius is %s", inradius)
           local sameLocation = spawnPoint ~= nil and GetWhereIsInSiege(spawnPoint)
          -- Print("FindArcHiveSpawn sameLocation is %s", sameLocation)

           if spawnPoint ~= nil and sameLocation and inradius then
           return spawnPoint
           end
       end
          -- Print("No valid spot found for FindArcHiveSpawn")
           return nil --FindFreeSpace(where, .5, 48)
end