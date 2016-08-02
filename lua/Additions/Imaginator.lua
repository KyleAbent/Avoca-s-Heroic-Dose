--Kyle 'Avoca' Abent

class 'Imaginator' (Conductor) --Because I dont want to spawn it other than when conductor is active and that file is already full. 
Imaginator.kMapName = "imaginator"


local networkVars = 

{
}

function Imaginator:OnCreate() 
   for i = 1, 8 do
     Print("Imaginator created")
   end
           if Server then
              --self:AddTimedCallback(Imaginator.PickMainRoom, 16)
              self:AddTimedCallback(Imaginator.Automations, 8)
              self:AddTimedCallback(Imaginator.Imaginations, 4)
              self:AddTimedCallback(Imaginator.CystTimer, 1)
            end
end
local function GetDisabledPowerPoints()
 local nodes = {}
 
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                    if powerpoint and powerpoint:GetIsDisabled() then
                    table.insert(nodes, powerpoint)
                    end
                    
             end

return nodes

end
local function PowerPointStuff(who)
local team = 0
local location = GetLocationForPoint(who:GetOrigin())
local powerpoint =  location and GetPowerPointForLocation(location.name)
      if powerpoint ~= nil then 
              if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then 
                team = 1
             elseif powerpoint:GetIsDisabled() or  powerpoint:GetIsSocketed()  then
             -- local infestation = GetEntitiesWithMixinWithinRange("Infestation", who:GetOrigin(), 7) 
               -- if #infestation >= 1 then
                 team = 2
                -- end
               end
     end
     return team
end
local function WhoIsQualified(who)
   return PowerPointStuff(who)
end
local function Touch(who, where, what, number)
 local tower = CreateEntityForTeam(what, where, number, nil)
         if tower then
            who:SetAttached(tower)
            if number == 1 then
            tower:SetConstructionComplete()
            end
            return tower
         end
end
local function Envision(who, which)
   if which == 1 then
     Touch(who, who:GetOrigin(), kTechId.Extractor, 1)
   elseif which == 2 then
     Touch(who, who:GetOrigin(), kTechId.Harvester, 2)
    end
end
local function AutoDrop(self,who)
  local which = WhoIsQualified(who)
  if which ~= 0 then Envision(who, which) end
end
function Imaginator:Automations() 
              self:AutoBuildResTowers()
              return true
end
function Imaginator:Imaginations() --Tres spending WIP
              self:MarineConstructs()
              self:AlienConstructs(false)
              return true
end
function Imaginator:CystTimer()
              self:AlienConstructs(true)
              return true
end
local function FindRandomPerson(airlock, powerpoint)

  local ents = airlock:GetEntitiesInTrigger()
  
  if #ents == 0 then return powerpoint:GetOrigin() end
  
  for i = 1, #ents do
    local entity = ents[i]
    if entity:isa("Marine") and entity:GetIsAlive() then return entity:GetOrigin() end
  end

 return powerpoint:GetOrigin()
end
local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end
local function TresCheck(team, cost)
    if team == 1 then
    return GetGamerules().team1:GetTeamResources() >= cost
    elseif team == 2 then
    return GetGamerules().team2:GetTeamResources() >= cost
    end

end
local function GetSentryMinRangeReq(where)
local count = 0
            local ents = GetEntitiesForTeamWithinRange("SentryAvoca", 1, where, 16)
            for index, ent in ipairs(ents) do
                  count = count + 1
           end
           
           count = Clamp(count, 1, 4)
           
           return count*8
                
end
local function GetWhipMinRangeReq(where)
local count = 0
            local ents = GetEntitiesForTeamWithinRange("WhipAvoca", 1, where, 16)
            for index, ent in ipairs(ents) do
                  count = count + 1
           end
           
           count = Clamp(count, 1, 4)
           
           return count*16
                
end
local function GetMarineSpawnList()

local tospawn = {}

     if TresCheck(1,kPhaseGateCost) then
     table.insert(tospawn, PhaseGate.kMapName)
       end
       
    if TresCheck(1,kArmoryCost) then
    table.insert(tospawn, Armory.kMapName)
    end
    
      if TresCheck(1,kObservatoryCost) then
       table.insert(tospawn, Observatory.kMapName)
      end
      
     if TresCheck(3) then
     table.insert(tospawn, Scan.kMapName)
     end
       
      if TresCheck(1,kRoboticsFactoryCost) then
      table.insert(tospawn, RoboticsFactory.kMapName)
      end
      

    if TresCheck(1,8) then
    table.insert(tospawn, SentryAvoca.kMapName)
    end
    
     if TresCheck(1,kPrototypeLabCost) then
     table.insert(tospawn, PrototypeLab.kMapName)
     end
     
     --if TresCheck(4) then
     --table.insert(tospawn, SentryBattery.kMapName)
     -- end



return table.random(tospawn)
end
function Imaginator:MarineConstructs()
       for i = 1, 8 do
         local success = self:ActualFormulaMarine()
         if success == true then break end
       end

return true
end
function Imaginator:TriggerNotification(locationId, techId)

    local message = BuildCommanderNotificationMessage(locationId, techId)
    
    -- send the message only to Marines (that implies that they are alive and have a hud to display the notification
    
    for index, marine in ipairs(GetEntitiesForTeam("Player", 1)) do
        Server.SendNetworkMessage(marine, "CommanderNotification", message, true) 
    end

end
local function GetTechId(mapname)
      local thehardway = GetEntitiesWithMixinForTeam("Construct", 1) 
      
      for i = 1, #thehardway do
        local ent = thehardway[i]
         if ent:GetMapName() == mapname then return ent:GetTechId() end
      end
      return nil
end
local function GetActiveAirLock()
  local airlocks = {}
  for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
        if location:GetIsAirLock(true) then table.insert(airlocks,location) end
    end
    return table.random(airlocks) 
end
local function GetScanMinRangeReq(where)

            local obs = #GetEntitiesForTeamWithinRange("Observatory", 1, where, kScanRadius)
            
            for i = 1, obs do
             if GetIsUnitActive(obs) then return 999 end
            end
            
            return kScanRadius  
                
end
local function BuildNotificationMessage(where, self, mapname)
end
function Imaginator:ActualFormulaMarine()

--Print("AutoBuildConstructs")
local randomspawn = nil
local tospawn = GetMarineSpawnList()
local airlock = GetActiveAirLock()
local success = false
            if airlock and tospawn then
                local powerpoint = GetPowerPointForLocation(airlock.name)
             if powerpoint then
                local randomspawn = FindFreeSpace(FindRandomPerson(airlock, powerpoint))
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 1, function(ent) return ent:GetMapName() == tospawn end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      --Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange = 12
                          if tospawn == Armory.kMapName then minrange = 12 end
                          if tospawn == PhaseGate.kMapName then minrange = 42 end
                          if tospawn == Observatory.kMapName then minrange = kScanRadius end
                          if tospawn == RoboticsFactory.kMapName then minrange = 52  end
                          if tospawn == SentryAvoca.kMapName then minrange = GetSentryMinRangeReq(randomspawn) end
                          if tospawn == PrototypeLab.kMapName then minrange = 52  end
                          if tospawn == Scan.kMapName then minrange = GetScanMinRangeReq(randomspawn)  cost = 3 end
                          if tospawn == SentryBattery.kMapName then minrange = 16 end
                          if range >=  minrange  then
                           local entity = CreateEntity(tospawn, randomspawn, 1)
                               entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)
                               BuildNotificationMessage(randomspawn, self, tospawn)
                               success = true
                          end --
                     else -- it tonly takes 1!
                        CreateEntity(tospawn, randomspawn, 1)
                        success = true
                     end
               end   
            end
  end
    
  return success
  
end
/*
local function HasThreeUpgFor()
GetGamerules().team2
end
*/
local function GetAlienSpawnList(cystonly)

local tospawn = {}

      if cystonly then 
      return AutoCyst.kMapName
      end
      
          if TresCheck(2,kShiftCost) then
      table.insert(tospawn, Shade.kMapName)
          end
          if TresCheck(2,kShadeCost) then
      table.insert(tospawn, Shift.kMapName)
          end
          if TresCheck(2,kWhipCost) then
      table.insert(tospawn, Whip.kMapName)
      end
      
      return table.random(tospawn)
end
function Imaginator:AlienConstructs(cystonly)

       for i = 1, 8 do
         local success = self:ActualAlienFormula(cystonly)
         if success == true then break end
       end

return true

end

function Imaginator:ActualAlienFormula(cystonly)
--Print("AutoBuildConstructs")
local randomspawn = nil
local powerPoints = GetDisabledPowerPoints()
local tospawn = GetAlienSpawnList(cystonly)
local success = false
     if powerPoints and tospawn then
                local powerpoint = table.random(powerPoints)
             if powerpoint and powerpoint:GetIsDisabled() then
                local randomspawn = FindFreeSpace(FindRandomPerson(GetLocationForPoint(powerpoint:GetOrigin()), powerpoint))
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 2, function(ent) return ent:GetMapName() == tospawn end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      --Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange = 12
                          if tospawn == Cyst.kMapName then minrange = kCystRedeployRange end
                          if tospawn == Shade.kMapName then minrange = 17 end
                          if tospawn == Shift.kMapName then minrange = kEnergizeRange end
                          if tospawn == Whip.kMapName then minrange = GetWhipMinRangeReq(randomspawn) end
                          if range >=  minrange then
                           CreateEntity(tospawn, randomspawn, 2)
                          end
                          success = true
                     else -- it tonly takes 1!
                        local entity = CreateEntity(tospawn, randomspawn, 2)
                        entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)
                        success = true
                     end
               end   
            end
  end
    
  return success
 end
function Imaginator:AutoBuildResTowers()
  for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
        if respoint:GetAttached() == nil then AutoDrop(self, respoint) end
    end
end

Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)