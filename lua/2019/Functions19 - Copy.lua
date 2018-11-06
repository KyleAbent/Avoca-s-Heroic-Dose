
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
function GetCheckSentryLimit(techId, origin, normal, commander)
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if locationName then
    
        validRoom = true
        
        for index, sentry in ientitylist(Shared.GetEntitiesWithClassname("Sentry")) do
        
            if sentry:GetLocationName() == locationName  then
              if sentry:GetIsACreditStructure()  then
                numInRoom = numInRoom + 0.5 
               else
                numInRoom = numInRoom + 1
                end
            end
            
        end
        
    end
    
    return validRoom and numInRoom < 4
    
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
