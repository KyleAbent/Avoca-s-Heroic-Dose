--Kyle 'Avoca' Abent

class 'Imaginator' (Entity) --Because I dont want to spawn it other than when conductor is active and that file is already full. 
Imaginator.kMapName = "imaginator"


local networkVars = 

{
}

function Imaginator:OnCreate() 
   for i = 1, 8 do
     Print("Imaginator created")
   end
       /*
           if Server then
              --self:AddTimedCallback(Imaginator.PickMainRoom, 16)
              self:AddTimedCallback(Imaginator.Automations, 16)
              self:AddTimedCallback(Imaginator.Imaginations, 16)
              self:AddTimedCallback(Imaginator.CystTimer, 8)
            end
        */
   self:SetUpdates(true)
end
function Imaginator:OnUpdate(deltatime)
   
   if Server then
   
         
       if not  self.timeLastAutomations or self.timeLastAutomations + 16 <= Shared.GetTime() then
        self.timeLastAutomations = Shared.GetTime()
        self:Automations()
        end
        
            if not  self.timeLastImaginations or self.timeLastImaginations + 16 <= Shared.GetTime() then
            self.timeLastImaginations = Shared.GetTime()
        self:Imaginations()
         end
            if not  self.timeLastCystTimer or self.timeLastCystTimer + 8 <= Shared.GetTime() then
            self.timeLastCystTimer = Shared.GetTime()
         self:CystTimer()
         end
         
   end //Server
   
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
           -- if number == 1 then
           -- tower:SetConstructionComplete()
           -- end
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
--Requires more complexity like siege simple 8.25.17
local tospawn = {}

     if TresCheck(1,kPhaseGateCost) then
     table.insert(tospawn, kTechId.PhaseGate)
       end
       
    if TresCheck(1,kArmoryCost) then
    table.insert(tospawn, kTechId.Armory)
    end
    
      if TresCheck(1,kObservatoryCost) then
       table.insert(tospawn, kTechId.Observatory)
      end
      
     if TresCheck(3) then
     table.insert(tospawn, kTechId.Scan)
     end
       
      if TresCheck(1,kRoboticsFactoryCost) then
      table.insert(tospawn, kTechId.RoboticsFactory)
      end
      

    if TresCheck(1,8) then
    table.insert(tospawn, kTechId.Sentry)
    end
    
     if TresCheck(1,kPrototypeLabCost) then
     table.insert(tospawn, kTechId.PrototypeLab)
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
local function GetScanMinRangeReq(where)

            local obs = #GetEntitiesForTeamWithinRange("Observatory", 1, where, kScanRadius)
            
            for i = 1, obs do
             if GetIsUnitActive(obs) then return 999 end
            end
            
            return kScanRadius  
                
end
local function BuildNotificationMessage(where, self, mapname)
end

local function FindPosition(location, searchEnt, teamnum)
  if not location or #location == 0  then return end
  local origin = nil
  local where = {}
    for i = 1, #location do
    local location = location[i]   
      local ents = location:GetEntitiesInTrigger()
      local potential = InsideLocation(ents, teamnum)
      if potential ~= nil then  table.insert(where, potential ) end 
  end
     for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("Construct", teamnum, searchEnt:GetOrigin(), 24) ) do
       if  GetLocationForPoint(entity:GetOrigin()) ==  GetLocationForPoint(searchEnt:GetOrigin()) then
          table.insert(where, entity:GetOrigin() )
       end
     end
  if #where == 0 then return nil end
  local random = table.random(where)
  local actualWhere = FindFreeSpace(random)
  if random == actualWhere then return nil end -- ugh
  return actualWhere

end

local function GiveConstructOrder(who, where)

local random = {}
    for _, ent in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct",1, where, 999999)) do
      if  not ent:GetIsBuilt() and ent:GetCanConstruct(who) and who:CheckTarget(ent:GetOrigin()) then
        table.insert(random, ent)
        end
    end
    
 
       local constructable = table.random(random)
               if constructable then
                    local target = constructable
                    local orderType = kTechId.Construct
                    local where = target:GetOrigin()
                   return who:GiveOrder(orderType, target:GetId(), where, nil, false, false)   
                end
end

local function ManageMacs()
local cc = nil

   for index, chair in ipairs(GetEntitiesForTeam("CommandStation", 1)) do
       cc = chair 
       break
   end
   
   if cc then
     local where = cc:GetOrigin()
     local MACS = GetEntitiesForTeamWithinRange("MAC", 1, where, 9999)
           if not #MACS or #MACS <=3 then
            CreateEntity(MAC.kMapName, FindFreeSpace(where), 1)
           end
   
   if #MACS >= 1 then
   
     for i = 1, #MACS do
        local mac = MACS[i]
           if not mac:GetHasOrder() then
          GiveConstructOrder(mac, mac:GetOrigin())
          end
     end
   
   end
   
   end
   
end

function Imaginator:ActualFormulaMarine()
 ManageMacs() 
local randomspawn = nil
local tospawn, cost, gamestarted = GetMarineSpawnList(self)
 --ManageMacs() 
  --ManageDropExos(self) not working debug
--if gamestarted and not string.find(Shared.GetMapName(), "pl_") then ManageRoboticFactories(self)  ManageArcs(self) end
--if  GetIsTimeUp(self.lastMarineBeacon, 30) then self:ManageMarineBeacons() end
local powerpoint = GetRandomActivePower()
local success = false
local entity = nil
            if powerpoint and tospawn then
                 local potential = FindPosition(GetAllLocationsWithSameName(powerpoint:GetOrigin()), powerpoint, 1)
                 if potential == nil then local roll = math.random(1,3) if roll == 3 then self:ActualFormulaMarine() return else return end end
                 randomspawn = FindFreeSpace(potential, 2.5)
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 1, function(ent) return ent:GetTechId() == tospawn or ( ent:GetTechId() == kTechId.AdvancedArmory and tospawn == kTechId.Armory)  or ( ent:GetTechId() == kTechId.ARCRoboticsFactory and tospawn == kTechId.RoboticsFactory) end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                  --    Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange = nearestof.GetMinRangeAC and nearestof:GetMinRangeAC() or math.random(4,24) --nearestof:GetMinRangeAC()
                          if tospawn == kTechId.Scan and GetHasActiveObsInRange(randomspawn) then return end
                          if tospawn == kTechId.PhaseGate and GetHasPGInRoom(randomspawn) then return end
                          
                          if range >=  minrange  then
                            entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                               --BuildNotificationMessage(randomspawn, self, tospawn)
                               success = true
                          end --
                     else -- it tonly takes 1!
                       entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                        success = true
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

      if cystonly == true then 
      return kTechId.Cyst
      end
      
       if TresCheck(2,kCragCost) then
      table.insert(tospawn, kTechId.Crag)
          end
          
          if TresCheck(2,kShiftCost) then
      table.insert(tospawn, kTechId.Shade)
          end
          if TresCheck(2,kShadeCost) then
      table.insert(tospawn, kTechId.Shift)
          end
          if TresCheck(2,kWhipCost) then
      table.insert(tospawn, kTechId.Whip)
      end
      
      return table.random(tospawn)
end
function Imaginator:AlienConstructs(cystonly)
--Print("AlienConstructs cystonly %s", cystonly)
       for i = 1, 8 do
         local success = self:ActualAlienFormula(cystonly)
         if success == true then break end
       end

return true

end

local function GetAlienSpawnNearEntity()
 local ents = {}
  local location = nil
  --Fine tuned ;)
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                    if powerpoint and  (powerpoint:GetIsDisabled() or ( powerpoint:GetIsSocketed() and not powerpoint:GetIsBuilt() ) )  then
                    table.insert(ents, powerpoint)
                    end
             end

            for _, cyst in ientitylist(Shared.GetEntitiesWithClassname("Cyst")) do
               if cyst:GetIsBuilt() then
                  --  local location = GetLocationForPoint(cyst:GetOrigin())
                 --   local powerpoint =  location and GetPowerPointForLocation(location.name)
                 --   if powerpoint and not powerpoint:GetIsDisabled() and powerpoint:GetIsBuilt()  then
                     table.insert(ents, cyst)
                   -- end
                end
             end
        
             for _, entity in ipairs( GetEntitiesWithMixinForTeam("Construct", 2 ) ) do
               if not entity:GetGameEffectMask(kGameEffect.OnInfestation) then 
                  local location = GetLocationForPoint(entity:GetOrigin())
                  local powerpoint =  location and GetPowerPointForLocation(location.name)
                  if powerpoint and powerpoint:GetIsDisabled() then
                     table.insert(ents, entity)
                   end
               end
            end
            
            table.insert(ents, GetRandomHive())
       
        
 if #ents == 0 then return nil end
return table.random(ents)

end

local function FakeCyst(where) 
         local cyst = GetEntitiesWithinRange("Cyst",where, kCystRedeployRange)
         local cost = 1 
        if not (#cyst >=1) and TresCheck(2, cost) then
        where = FindFreeSpace(where, 1, kCystRedeployRange-1, false)
        entity = CreateEntityForTeam(kTechId.Cyst, where, 2)
        entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)
        end
end

local function GetDrifterBuff()
 local buffs = {}
 if GetHasShadeHive()  then table.insert(buffs,kTechId.Hallucinate) end
 if GetHasCragHive()  then table.insert(buffs,kTechId.MucousMembrane) end
  if GetHasShiftHive()  then table.insert(buffs,kTechId.EnzymeCloud) end
    return table.random(buffs)
end


local function GiveDrifterOrder(who, where)

local structure =  GetNearestMixin(who:GetOrigin(), "Construct", 2, function(ent) return not ent:GetIsBuilt() and (not ent.GetCanAutoBuild or ent:GetCanAutoBuild())   end)
local player =  GetNearest(who:GetOrigin(), "Alien", 2, function(ent) return ent:GetIsInCombat() and ent:GetIsAlive() end) 
    
    local target = nil
    
    if structure then
      target = structure
    end
    
    
    if player then
        local chance = math.random(1,100)
        local boolean = chance >= 70
        if boolean then
        who:GiveOrder(GetDrifterBuff(), player:GetId(), player:GetOrigin(), nil, false, false)
        return
        end
    end
    
        if  structure then      
    
            who:GiveOrder(kTechId.Grow, structure:GetId(), structure:GetOrigin(), nil, false, false)
            return  
      
        end
        
end


local function ManageDrifters()
local hive = GetRandomHive()


   
   if hive then
     local where = hive:GetOrigin()
     local Drifters = GetEntitiesForTeamWithinRange("Drifter", 2, where, 9999)
           if not #Drifters or #Drifters <=3 then
            CreateEntity(Drifter.kMapName, FindFreeSpace(where), 2)
           end
   
   if #Drifters >= 1 then
   
     for i = 1, #Drifters do
        local drifter = Drifters[i]
           if not drifter:GetHasOrder() then
          GiveDrifterOrder(drifter, drifter:GetOrigin())
          end
     end
   
   end
   
   end
   
end


function Imaginator:ActualAlienFormula(cystonly)
 ManageDrifters() 
local randomspawn = nil
local spawnNearEnt = GetAlienSpawnNearEntity() 
local tospawn = GetAlienSpawnList(self, cystonly) --, cost, gamestarted = GetAlienSpawnList(self, cystonly)
local success = false
local entity = nil

if spawnNearEnt then
--Print("ActualAlienFormula cystonly %s, spawnNearEnt %s, tospawn %s", cystonly,  spawnNearEnt:GetMapName() or nil, LookupTechData(tospawn, kTechDataMapName)  )
end

     if spawnNearEnt and tospawn then     
                 local potential = FindPosition(GetAllLocationsWithSameName(spawnNearEnt:GetOrigin()), spawnNearEnt, 2)
                 if potential == nil then local roll = math.random(1,3) if roll == 3 then self:ActualAlienFormula() return else return end  end              
                 randomspawn = FindFreeSpace(potential, math.random(2.5, 4) , math.random(8, 16), not tospawn == kTechId.Cyst )
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 2, function(ent) return ent:GetTechId() == tospawn end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      --Print("ActualAlienFormula range is %s", range)
                      --Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange =  nearestof.GetMinRangeAC and nearestof:GetMinRangeAC() or math.random(4,8) --nearestof:GetMinRangeAC()
                         -- if tospawn == kTechId.NutrientMist then minrange = NutrientMist.kSearchRange end
                          if range >=  minrange then
                           --Print("ActualAlienFormula range range >=  minrange")
                            entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                           -- cost = GetAlienCostScalar(self, cost)
                          if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                          end
                          success = true
                     else -- it tonly takes 1!
                         entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                       -- if entity:isa("Cyst") then CystChain(entity:GetOrigin()) end
                           if not entity:isa("Cyst") then FakeCyst(entity:GetOrigin()) end
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                        success = true
                     end 
            end
  end
   -- if success and entity then self:AdditionalSpawns(entity) end
  return success
 end
function Imaginator:AutoBuildResTowers()
  for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
        if respoint:GetAttached() == nil then AutoDrop(self, respoint) end
    end
end

Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)