--Kyle 'Avoca' Abent

class 'Imaginator' (Entity) --Because I dont want to spawn it other than when conductor is active and that file is already full. 
Imaginator.kMapName = "imaginator"


local networkVars = 

{
  lastMarineBeacon =  "private time",
}

function Imaginator:GetIsMapEntity()
return true
end

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
local function NotBeingResearched(techId, who)   

 if techId ==  kTechId.AdvancedArmoryUpgrade or techId == kTechId.UpgradeRoboticsFactory then return true end
  
     for _, structure in ientitylist(Shared.GetEntitiesWithClassname( string.format("%s", who:GetClassName()) )) do
         if structure:GetIsResearching() and structure:GetClassName() == who:GetClassName() and structure:GetResearchingId() == techId then return false end
     end
    return true
end
local function ResearchEachTechButton(who)
local techIds = who:GetTechButtons() or {}
      if who:isa("EvolutionChamber") then
      
               techIds = {}
               table.insert(techIds, kTechId.Charge )
               table.insert(techIds, kTechId.BileBomb )
               table.insert(techIds, kTechId.MetabolizeEnergy )
               table.insert(techIds, kTechId.Leap )
               table.insert(techIds, kTechId.Spores )
               table.insert(techIds, kTechId.Umbra )
               table.insert(techIds, kTechId.MetabolizeHealth )
               table.insert(techIds, kTechId.BoneShield )
               table.insert(techIds, kTechId.Stab )
               table.insert(techIds, kTechId.Stomp )
               table.insert(techIds, kTechId.Xenocide )
          
      end
      
            if who:isa("Observatory") then
             techIds = {}
             table.insert(techIds, kTechId.PhaseTech )
            end

      
                       for _, techId in ipairs(techIds) do
                     if techId ~= kTechId.None then
                        if not GetHasTech(who, techId) and who:GetCanResearch(techId) then
                          local tree = GetTechTree(who:GetTeamNumber())
                         local techNode = tree:GetTechNode(techId)
                          assert(techNode ~= nil)
                          
                            if tree:GetTechAvailable(techId) then
                             local cost = 0--LookupTechData(techId, kTechDataCostKey) * 
                                if  NotBeingResearched(techId, who) and TresCheck(1,cost) then  
                                  who:SetResearching(techNode, who)
                                  break -- Because having 2 armslabs research at same time voids without break. So lower timer 16 to 4
                                --  who:GetTeam():SetTeamResources(who:GetTeam():GetTeamResources() - cost)
                                 end
                             end
                         end
                      end
                  end
end
local function HiveResearch(who)
if not who or GetGameInfoEntity():GetWarmUpActive() then return true end
if who:GetIsResearching() then return true end
local tree = who:GetTeam():GetTechTree()
local technodes = {}

    for _, node in pairs(tree.nodeList) do
           local canRes = tree:GetHasTech(node:GetPrereq1()) and tree:GetHasTech(node:GetPrereq2())
           local cost = math.random(1,4) --node.cost
         if canRes and TresCheck(2, cost) and node:GetIsResearch() and node:GetCanResearch() then
                who:GetTeam():SetTeamResources(who:GetTeam():GetTeamResources() - cost)
                node:SetResearched(true)
                tree:SetTechNodeChanged(node, string.format("hasTech = %s", ToString(true)))
         end
    
    end              
                  return true


end
function Imaginator:UpdateHivesManually()
                 for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
                     if hive:GetIsBuilt() then 
                         HiveResearch(hive) 
                     end
               end
     return true
end
function Imaginator:OnUpdate(deltatime)
   
   if Server then
   
         /*
       if not  self.timeLastAutomations or self.timeLastAutomations + 16 <= Shared.GetTime() then
        self.timeLastAutomations = Shared.GetTime()
        self:Automations()
        end
        */
        
            if not  self.timeLastImaginations or self.timeLastImaginations + 8 <= Shared.GetTime() then
            self.timeLastImaginations = Shared.GetTime()
        self:Imaginations()
         end
         
         /*
            if not  self.timeLastCystTimer or self.timeLastCystTimer + 8 <= Shared.GetTime() then
            self.timeLastCystTimer = Shared.GetTime()
         self:CystTimer()
         end
         */
         
         if not self.timeLastResearch or self.timeLastResearch + 16 <= Shared.GetTime() then
               
         local gamestarted = GetGamerules():GetGameState() == kGameState.Started 
               if gamestarted then --and self:GetMarineEnabled() then dsd

                        local researchables = {}
                       for _, ent in ientitylist(Shared.GetEntitiesWithClassname("EvolutionChamber")) do
                       table.insert(researchables, ent)
                       end
                     for _, researchable in ipairs(GetEntitiesWithMixinForTeam("Research", 1)) do
                     if not researchable:isa("RoboticsFactory") then table.insert(researchables, researchable)  end
                      if researchable:isa("Observatory") then table.insert(researchables, researchable) end 
                   end
               
                   for i = 1, #researchables do
                       local researchable = researchables[i]
                       ResearchEachTechButton(researchable)  
                   end
                   /*
                     for i = 1, #eggs do
                          local egg = eggs[i]
                         egg:DelayedActivation()
                          break
                     end
                end
               end
               */
                
             self.timeLastResearch = Shared.GetTime()  
             end
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

/*

local function Touch(who, where, what, number)
 local tower = CreateEntityForTeam(what, where, number, nil)
         if tower then
            who:SetAttached(tower)
            if number == 1 then
           -- tower:SetConstructionComplete()
             tower.isGhostStructure = false
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
*/

function Imaginator:Imaginations() --Tres spending WIP
      local marine = GetEntitiesWithMixinForTeam("Construct", 1) 
      local alien = GetEntitiesWithMixinForTeam("Construct", 2) 
       Print("Construct Count:  marine: %s, alien %s", #marine, #alien)

      
              self:MarineConstructs()
              
       --  if #alien <= 99 then
              self:AlienConstructs(false)
       --   end
          
              return true
end

/*
function Imaginator:CystTimer()
              self:AlienConstructs(true)
              return true
end
*/

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

local function GetHasThreeChairs()
local CommandStations = #GetEntitiesForTeam( "CommandStation", 1 )

if CommandStations >= 3 then return true end

return false

end

local function GetHasSixHives()
local Hives = #GetEntitiesForTeam( "Hive", 2 )

if Hives >= 6 then return true end

return false

end

local function GetMarineSpawnList()
--Not sure if count is necessary
local tospawn = {}
local canAfford = {}

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
     
          if TresCheck(3) then
     table.insert(tospawn, kTechId.SentryBattery)
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
      local  CommandStation = #GetEntitiesForTeam( "CommandStation", 1 )
      


               --gamelength around 3 mins to drop this way more power are built
      if not GetHasThreeChairs() then
      table.insert(tospawn, kTechId.CommandStation)
      end
      
       for _, techid in pairs(tospawn) do
        local cost = LookupTechData(techid, kTechDataCostKey)
           if TresCheck(1,cost) then
             table.insert(canAfford, techid)
           end
    end
    
     local finalchoice = table.random(canAfford), true

return finalchoice, LookupTechData(finalchoice, kTechDataCostKey)
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

/*

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

*/

local function OrganizedIPCheck(who, self)

-- One entity at a time
local count = 0
local ips = GetEntitiesForTeamWithinRange("InfantryPortal", 1, who:GetOrigin(), kInfantryPortalAttachRange)
 --ADd in getisactive
      --Add in arms lab because having these spread through the map is a bit odd.
      local armscost = LookupTechData(kTechId.ArmsLab, kTechDataCostKey)
      local  ArmsLabs = GetEntitiesForTeam( "ArmsLab", 1 )
      local labs = #ArmsLabs or 0
      if #ArmsLabs >= 1 then 

      
      for i = 1, #ArmsLabs do
          local ent = ArmsLabs[i]
          if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
          labs = labs - 1
          end
      end
      
      end
      
      if labs < 2 and TresCheck(1, armscost) then
               local origin = FindFreeSpace(who:GetOrigin(), 1, kInfantryPortalAttachRange)
               local armslab = CreateEntity(ArmsLab.kMapName, origin,  1)
              armslab:GetTeam():SetTeamResources(armslab:GetTeam():GetTeamResources() - armscost)
              return --one at a time
      end
      

            for index, ent in ipairs(ips) do
              if ent:GetIsPowered() or not ent:GetIsBuilt() then
                  count = count + 1
               end   
           end
           
           if count >= 2 then return end
           
         --  for i = 1, math.abs( 2 - count ) do --one at a time
           local cost = 20
               if TresCheck(1, cost) then 
                local where = who:GetOrigin()
               local origin = FindFreeSpace(where, 4, kInfantryPortalAttachRange)
                 if origin ~= where then
                 local ip = CreateEntity(InfantryPortal.kMapName, origin,  1)
                ip:GetTeam():SetTeamResources(ip:GetTeam():GetTeamResources() - cost)
                end
           end
           
              
           
end


local function HaveCCsCheckIps(self)
   local CommandStations = GetEntitiesForTeam( "CommandStation", 1 )
       if not CommandStations then return end
        OrganizedIPCheck(table.random(CommandStations), self)
end

function Imaginator:ManageMarineBeacons()
            local chair = nil
          --  Print(" umm 1 ")
                for _, entity in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
               if entity:GetIsBuilt() and entity:GetHealthScalar() <= 0.3 then chair = entity   Print(" umm 2 ") break end
               end
                -- Print(" umm 3 ")
               if not chair then return end
                -- Print(" umm 4 ")
               local obs = GetNearest(chair:GetOrigin(), "Observatory", 1,  function(ent) return GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(chair:GetOrigin()) and ent:GetIsBuilt() and ent:GetIsPowered()  end )
             
          if obs then 
           -- Print(" umm 5 ")
              --  self:TellEveryoneAbtBeacon()
                obs:TriggerDistressBeacon() 
            --   for _, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
            --       mac:GiveOrder(kTechId.Weld, chair:GetId(), chair:GetOrigin(), nil, false, false)   
            --   end
                self.lastMarineBeacon = Shared.GetTime()
         end
   
end

function Imaginator:ActualFormulaMarine()
 --ManageMacs() 
local randomspawn = nil
local tospawn, cost, gamestarted = GetMarineSpawnList(self)
if  GetIsTimeUp(self.lastMarineBeacon, 30) then self:ManageMarineBeacons() end
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true HaveCCsCheckIps(self) end
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

     -- if cystonly == true then 
     -- return kTechId.Cyst
    --  end
      
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
    
    
      if TresCheck(2,40) then
          for _, techpoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
                   local location = GetLocationForPoint(techpoint:GetOrigin())
                    local powerpoint =  location and GetPowerPointForLocation(location.name)
             if techpoint:GetAttached() == nil and powerpoint and powerpoint:GetIsDisabled()  or not powerpoint:GetIsBuilt() then 
                  local hive = techpoint:SpawnCommandStructure(2) 
                  if hive then hive:GetTeam():SetTeamResources(hive:GetTeam():GetTeamResources() - 40) break end
             end
          end
     end
   
   
       if not GetHasSixHives() then
      table.insert(tospawn, kTechId.Hive)
      end
  
      return table.random(tospawn)
end

local function UpgChambers()
local gamestarted = not GetGameInfoEntity():GetWarmUpActive()   
if not gamestarted then return true end     
 local tospawn = {}
local canafford = {}    


        if GetHasShiftHive() then  
            --  Print("GetHasShiftHive true")
              local  Spur = #GetEntitiesForTeam( "Spur", 2 )
              if Spur < 3 then table.insert(tospawn, kTechId.Spur) end
       end

        if GetHasCragHive()  then  
            --   Print("GetHasCragHive true")
              local  Shell = #GetEntitiesForTeam( "Shell", 2 )
              if Shell < 3 then table.insert(tospawn, kTechId.Shell) end
       end
        if GetHasShadeHive() then  
            --     Print("GetHasShadeHive true")
                local  Veil = #GetEntitiesForTeam( "Veil", 2 )
                if Veil < 3 then table.insert(tospawn, kTechId.Veil) end
       end
       
             
       for _, techid in pairs(tospawn) do
          local cost = LookupTechData(techid, kTechDataCostKey)
           if not gamestarted or TresCheck(2,cost) then
             table.insert(canafford, techid)   
           end
    end
       
      local finalchoice = table.random(canafford)
      local finalcost = LookupTechData(finalchoice, kTechDataCostKey)
      finalcost = not gamestarted and 0 or finalcost
    --  Print("GetAlienSpawnList() UpgChambers() return finalchoice %s, finalcost %s", finalchoice, finalcost)
      return finalchoice, finalcost, gamestarted
       
end
local function GetHive()
 local hivey = nil
            for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
               hivey = hive
               break   
             end


return hivey

end


function Imaginator:DoBetterUpgs()
local tospawn, cost, gamestarted = UpgChambers()
local success = false
local randomspawn = nil
local hive = GetHive()
if not gamestarted then return end
     if hive and tospawn then             
                 randomspawn = FindFreeSpace( hive:GetOrigin(), 4, 24, true)
            if randomspawn then
                   local entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                    if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
            end
  end
    
  return success
end


local function HandleShiftCallReceive()
   local shifts = {}
   
 --   local boolean = GetSiegeDoorOpen()
  --  if boolena then return end
      for index, shift in ipairs(GetEntitiesForTeam("Shift", 2)) do
          table.insert(shifts, shift)
          shift.calling = false
          shift.receiving = true
      end
      local random = table.random(shifts)
      if not random then return end
      
      random.receiving = false
      random.calling = true
      
      for i = 1, #shifts do
          local shift = shifts[i]
          shift:AutoCommCall()
      end
end

function Imaginator:AlienConstructs(cystonly)
--Print("AlienConstructs cystonly %s", cystonly)
       for i = 1, 8 do
         local success = self:ActualAlienFormula(cystonly)
         if success == true then break end
       end
       
        --  if  GetHasShiftHive() then
        --    HandleShiftCallReceive() 
        --  end
          
              self:DoBetterUpgs()

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
             
         /*
            for _, cyst in ientitylist(Shared.GetEntitiesWithClassname("Cyst")) do
               if cyst:GetIsBuilt() then
                  --  local location = GetLocationForPoint(cyst:GetOrigin())
                 --   local powerpoint =  location and GetPowerPointForLocation(location.name)
                 --   if powerpoint and not powerpoint:GetIsDisabled() and powerpoint:GetIsBuilt()  then
                     table.insert(ents, cyst)
                   -- end
                end
             end
         */
         
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

/*

local function FakeCyst(where) 
         local cyst = GetEntitiesWithinRange("Cyst",where, kCystRedeployRange)
         local cost = 1 
        if not (#cyst >=1) and TresCheck(2, cost) then
        where = FindFreeSpace(where, 1, kCystRedeployRange-1, false)
        entity = CreateEntityForTeam(kTechId.Cyst, where, 2)
        entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)
        end
end

*/

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
                      --     if not entity:isa("Cyst") then FakeCyst(entity:GetOrigin()) end
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                        success = true
                     end 
            end
  end
   -- if success and entity then self:AdditionalSpawns(entity) end
  return success
 end
 
 /*
 
function Imaginator:AutoBuildResTowers()
  for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
        if respoint:GetAttached() == nil then AutoDrop(self, respoint) end
    end
end

*/

Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)