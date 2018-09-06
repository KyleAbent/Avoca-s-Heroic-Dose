--Kyle 'Avoca' Abent

class 'Imaginator' (Entity) --Because I dont want to spawn it other than when conductor is active and that file is already full. 
Imaginator.kMapName = "imaginator"


local networkVars = 

{
  lastMarineBeacon =  "private time",
  lasthealwave = "private time",
}

function Imaginator:GetIsMapEntity()
return true
end

function Imaginator:OnCreate() 
   for i = 1, 8 do
     Print("Imaginator created")
   end
   self.lasthealwave = 0
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
          -- local cost = math.random(1,4) --node.cost
         if canRes and node:GetIsResearch() and node:GetCanResearch() then
                --who:GetTeam():SetTeamResources(who:GetTeam():GetTeamResources() - cost)
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
   
        
            if not  self.timeLastImaginations or self.timeLastImaginations + 8 <= Shared.GetTime() then
            self.timeLastImaginations = Shared.GetTime()
        self:Imaginations()
         end
         
         if not self.timeLastResearch or self.timeLastResearch + 16 <= Shared.GetTime() then
               
         local gamestarted = GetGamerules():GetGameState() == kGameState.Started 
               if gamestarted then 

               local researchables = {}
                   for _, ent in ientitylist(Shared.GetEntitiesWithClassname("EvolutionChamber")) do
                   table.insert(researchables, ent)
                   end

                   for _, researchable in ipairs(GetEntitiesWithMixinForTeam("Research", 1)) do
                   table.insert(researchables, researchable)  
                        if researchable:isa("Observatory") then
					    table.insert(researchables, researchable)
					    end 
                   end
               
                   for i = 1, #researchables do
                       local researchable = researchables[i]
                       ResearchEachTechButton(researchable)  
                   end
                
             self.timeLastResearch = Shared.GetTime()  
             end
         end
         
   end //Server
   
end

function Imaginator:Imaginations() --Tres spending WIP
   --   local marine = GetEntitiesWithMixinForTeam("Construct", 1) 
  --    local alien = GetEntitiesWithMixinForTeam("Construct", 2) 
--       Print("Construct Count:  marine: %s, alien %s", #marine, #alien)

      
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
   if CommandStations >= 3 then
   return true 
   end
return GetConductor():GetIsPhaseFourBoolean()
end

local function GetHasFourHives()
   local Hives = #GetEntitiesForTeam( "Hive", 2 )
   if Hives >= 4 then return true end
   return GetConductor():GetIsPhaseFourBoolean()
end

local function GetHasAdvancedArmory()
    for index, armory in ipairs(GetEntitiesForTeam("Armory", 1)) do
       if armory:GetTechId() == kTechId.AdvancedArmory then return true end
    end
    return false
end

local function GetMarineSpawnList()

local tospawn = {}
local canafford = {}
local cost = 1 
local gamestarted = false
--Horrible for performance, right? Not precaching ++ local variables ++ table && for loops !!! 

-----------------------------------------------------------------------------------------------  
         local  PhaseGates = GetEntitiesForTeam( "PhaseGate", 1 )
         local pgcount = #PhaseGates
 
         if #PhaseGates >= 1 then 
              for i = 1, #PhaseGates do
              local ent = PhaseGates[i]
                 if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
                 pgcount = pgcount - 1
                 end
              end
         end
      
        if pgcount <= 3 then
        table.insert(tospawn, kTechId.PhaseGate)
        end --phaseavoca init 
   ------------------------------------------------------------------------------------------- 
     
        local  Armory = GetEntitiesForTeam( "Armory", 1 )
        local acount = #Armory
           if acount >= 1 then 
              for i = 1, #Armory do
              local ent = Armory[i]
                if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
                acount = acount - 1
                end
              end
           end
      
         if acount <= 7 then
         table.insert(tospawn, kTechId.Armory)
         end
   ---------------------------------------------------------------------------------------------
      
         local  RoboticsFactory = GetEntitiesForTeam( "RoboticsFactory", 1 )
         local rcount = #RoboticsFactory 
          if rcount >= 1 then 
             for i = 1, #RoboticsFactory do
              local ent = RoboticsFactory[i]
                if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
                rcount = rcount -1
                end
             end
         end
      
         if rcount <= 3 then
         table.insert(tospawn, kTechId.RoboticsFactory)
         end
 ------------------------------------------------------------------------------------------------
         local  Observatory = GetEntitiesForTeam( "Observatory", 1 )
         local ocount = #Observatory
          if ocount >= 1 then 
              for i = 1, ocount do
              local ent = Observatory[i]
               if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
               ocount = ocount - 1
               end
            end
         end
      
         if ocount <= 08 then
         table.insert(tospawn, kTechId.Observatory)
         end
 -----------------------------------------------------------------------------------------------
       
      if GetHasAdvancedArmory()  then
          local  PrototypeLab = GetEntitiesForTeam( "PrototypeLab", 1 )
          local pcount = #PrototypeLab
          if pcount >= 1 then 
             for i = 1, #PrototypeLab do
              local ent = PrototypeLab[i]
                if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
                pcount = pcount - 1
                end
             end
          end      

            if pcount < 6 then
             table.insert(tospawn, kTechId.PrototypeLab)
           end
     end
-------------------------------------------------------------------------------------------------   
         local  Sentry = GetEntitiesForTeam( "Sentry", 1 )
         local sentrycount = #Sentry 
          if #Sentry >= 1 then 
            for i = 1, #Sentry do
              local ent = Sentry[i]
              if ( ent:GetIsBuilt() and not ent.attachedToBattery ) then
              sentrycount = sentrycount - 1
               end
            end
         end
      
         if sentrycount <= 11 then
         table.insert(tospawn, kTechId.Sentry)
         end
----------------------------------------------------------------------------------------------------
      --timecheck to prevent 3 CC in one room w/o checking for such definition
         local  CommandStation = #GetEntitiesForTeam( "CommandStation", 1 )
         local timecheck = true--( Shared.GetTime() - GetGamerules():GetGameStartTime() ) >= 120
           if timecheck and CommandStation < 3 and not GetConductor():GetIsPhaseFourBoolean() then
           table.insert(tospawn, kTechId.CommandStation)
           end
 ----------------------------------------------------------------------------------------------------

          for _, techid in pairs(tospawn) do
            local cost = Clamp(LookupTechData(techid, kTechDataCostKey), 1, 10)
             if not gamestarted or TresCheck(1,cost) then
              table.insert(canafford, techid)
            end
         end
--------------------------------------------------------------------------------------------------------
      local finalchoice = table.random(canafford) 
         if table.find(canafford, kTechId.CommandStation) and math.random(1,100) <= 30  then
           finalchoice = kTechId.CommandStation
        end
---------------------------------------------------------------------------------------------------------
      local finalcost = not gamestarted and 0
      finalcost = LookupTechData(finalchoice, kTechDataCostKey)
      --Print("GetMarineSpawnList() return finalchoice %s, finalcost %s", finalchoice, finalcost)
      return finalchoice, finalcost, gamestarted
----------------------------------------------------------------------------------------------------------
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

local function BuildNotificationMessage(where, self, mapname)
end

local function FindPosition(location, searchEnt, teamnum)

     if not location or #location == 0  then
	 return
	 end

      local origin = nil
      local where = {}
       for i = 1, #location do
         local location = location[i]   
         local ents = location:GetEntitiesInTrigger()
         local potential = InsideLocation(ents, teamnum)
          if potential ~= nil then
		  table.insert(where, potential )
		  end 
     end

     for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("Construct", teamnum, searchEnt:GetOrigin(), 24) ) do
       if  GetLocationForPoint(entity:GetOrigin()) ==  GetLocationForPoint(searchEnt:GetOrigin()) then
          table.insert(where, entity:GetOrigin() )
       end
     end

     if #where == 0 then return nil end
      local random = table.random(where)
      local actualWhere = FindFreeSpace(random)
        if random == actualWhere then
	    return nil
	    end -- ugh
     return actualWhere
 end


local function OrganizedIPCheck(who, self)
     if not who:GetIsBuilt() then
	 return 
	 end
	 
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
      
         if labs < 2 then --and TresCheck(1, armscost) then
               local origin = FindFreeSpace(who:GetOrigin(), 1, kInfantryPortalAttachRange)
               local armslab = CreateEntity(ArmsLab.kMapName, origin,  1)
               --armslab:GetTeam():SetTeamResources(armslab:GetTeam():GetTeamResources() - armscost)
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
              -- if TresCheck(1, cost) then 
                local where = who:GetOrigin()
                local origin = FindFreeSpace(where, 4, kInfantryPortalAttachRange)
                   if origin ~= where then
                   local ip = CreateEntity(InfantryPortal.kMapName, origin,  1)
                   --ip:GetTeam():SetTeamResources(ip:GetTeam():GetTeamResources() - cost)
                   end
            --  end
end


local function HaveCCsCheckIps(self)
   local CommandStations = GetEntitiesForTeam( "CommandStation", 1 )
       if not CommandStations then return end
        OrganizedIPCheck(table.random(CommandStations), self)
end



function Imaginator:ActualFormulaMarine()
     GetConductor():ManageMacs()  
     GetConductor():ManageArcs()
     local randomspawn = nil
     local tospawn, cost, gamestarted = GetMarineSpawnList(self)
     if  GetIsTimeUp(self.lastMarineBeacon, 30) then 
	 GetConductor():ManageMarineBeacons()
	 end

     if GetGamerules():GetGameState() == kGameState.Started then 
	 gamestarted = true
	 HaveCCsCheckIps(self)
	 end

     local powerpoint = GetRandomActivePower()
     local success = false
     local entity = nil
            if powerpoint and tospawn then
                 local potential = FindPosition(GetAllLocationsWithSameName(powerpoint:GetOrigin()), powerpoint, 1)
                  if potential == nil then local roll = math.random(1,3)
				    if roll == 3 then
				    self:ActualFormulaMarine() return
				    else
				    return
				    end
		        end

            randomspawn = FindFreeSpace(potential, 2.5)
                if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 1, function(ent) return ent:GetTechId() == tospawn or ( ent:GetTechId() == kTechId.AdvancedArmory and tospawn == kTechId.Armory)  or ( ent:GetTechId() == kTechId.ARCRoboticsFactory and tospawn == kTechId.RoboticsFactory) end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                  --    Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange = nearestof.GetMinRangeAC and nearestof:GetMinRangeAC() or math.random(4,24) --nearestof:GetMinRangeAC()

                          if tospawn == kTechId.PhaseGate and GetHasPGInRoom(randomspawn) then
						  return
						  end
                          
                      if range >=  minrange  then
                            entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                           -- if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                               --BuildNotificationMessage(randomspawn, self, tospawn)
                               success = true
                            end --
                      else -- it tonly takes 1!
                       entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                        --  if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                          success = true
                        end  
                    end
                end
    
  return success
  
end






local function GetAlienSpawnList(self)

//local tospawn = {}


local tospawn = {}
local canafford = {}

     -- if cystonly == true then 
     -- return kTechId.Cyst
    --  end
   
      local  Shift = #GetEntitiesForTeam( "Shift", 2 )
      
      if Shift < 14 then
      table.insert(tospawn, kTechId.Shift)
      end 
      
      local  Whip = #GetEntitiesForTeam( "Whip", 2 )
      if Whip < 18 then
      table.insert(tospawn, kTechId.Whip)
      end 
      
      local  Crag = GetEntitiesForTeam( "Crag", 2 )
      if #Crag < 18 then
      table.insert(tospawn, kTechId.Crag)
      end 
      
      local  Shade = GetEntitiesForTeam( "Shade", 2 )
      if #Shade < 12 then
      table.insert(tospawn, kTechId.Shade)
      end 
      
      local timecheck = true --( Shared.GetTime() - GetGamerules():GetGameStartTime() ) >= 120
       if timecheck and not GetHasFourHives() then
      table.insert(tospawn, kTechId.Hive)
      end
  
         for _, techid in pairs(tospawn) do
            local cost = LookupTechData(techid, kTechDataCostKey)
             if not gamestarted or TresCheck(2,cost) then
             table.insert(canafford, techid)   
             end
         end
  

      
      
      local finalchoice = table.random(canafford)
      local finalcost = LookupTechData(finalchoice, kTechDataCostKey)
      --Print("GetAlienSpawnList() return finalchoice %s, finalcost %s", finalchoice, finalcost)
      return finalchoice, finalcost
  
    --  return table.random(tospawn)
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
                  --  if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
            end
  end
    
  return success
end


local function HandleShiftCallReceive() --disabled
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
       
        --  if  GetHasShiftHive() then --messy
        --    HandleShiftCallReceive() 
        --  end
          
              self:DoBetterUpgs()

return true

end


/*
local function Fake(where) 
         local cyst = GetEntitiesWithinRange("Cyst",where, kCystRedeployRange)
         local cost = 1 
        if not (#cyst >=1) then --and TresCheck(2, cost) then
        where = FindFreeSpace(where, 1, kCystRedeployRange-1, false)
        entity = CreateEntityForTeam(kTechId.Cyst, where, 2)
       -- entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)
        end
end
*/





function Imaginator:ActualAlienFormula(cystonly)
  GetConductor():ManageDrifters() 
  GetConductor():ManageCrags() 
  GetConductor():ManageShifts()
  GetConductor():ManageWhips() --gonna affect Phase Cannon ....... horrible perf?
  local randomspawn = nil
  local powerpoint  = GetRandomDisabledPower()
  local tospawn, cost = GetAlienSpawnList(self) --, cost, gamestarted = GetAlienSpawnList(self, cystonly)
  local success = false
  local entity = nil

  --if spawnNearEnt then
  --Print("ActualAlienFormula cystonly %s, spawnNearEnt %s, tospawn %s", cystonly,  powerpoint:GetMapName() or nil, LookupTechData(tospawn, kTechDataMapName)  )
  --end

     if powerpoint and tospawn then     
                 local potential = FindPosition(GetAllLocationsWithSameName(powerpoint:GetOrigin()), powerpoint, 2)
                   if potential == nil then
				     local roll = math.random(1,3)
				       if roll == 3 then
				       self:ActualAlienFormula() return
				       else
				       return
				      end
				   end              
                  randomspawn = FindFreeSpace(potential, math.random(2.5, 4) , math.random(8, 16), not tospawn == kTechId.Cyst )
             if randomspawn then
                    local nearestof = GetNearestMixin(randomspawn, "Construct", 2, function(ent) return ent:GetTechId() == tospawn end)
                      if nearestof then
                        local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      -- Print("ActualAlienFormula range is %s", range)
                      -- Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange =  nearestof.GetMinRangeAC and nearestof:GetMinRangeAC() or math.random(4,8) --nearestof:GetMinRangeAC()
                         -- if tospawn == kTechId.NutrientMist then minrange = NutrientMist.kSearchRange end
                           if range >=  minrange then
                             --Print("ActualAlienFormula range range >=  minrange")
                             entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                             -- cost = GetAlienCostScalar(self, cost)
                           --  if gamestarted then
						  --- 	entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)
							-- end
                          end
                          success = true
                       else -- it tonly takes 1!
                          entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                        -- if entity:isa("Cyst") then CystChain(entity:GetOrigin()) end
                      --      if not entity:isa("Cyst") then FakeCyst(entity:GetOrigin()) end
                         -- if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                          success = true
                     end 
            end
  end
   -- if success and entity then self:AdditionalSpawns(entity) end
  return success
 end
 

Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)