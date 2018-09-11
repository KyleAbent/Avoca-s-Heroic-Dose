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
                                if  NotBeingResearched(techId, who) then  
                                  who:SetResearching(techNode, who)
                                  break -- Because having 2 armslabs research at same time voids without break. So lower timer 16 to 4
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
         if canRes and node:GetIsResearch() and node:GetCanResearch() then
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
               self:MarineConstructs()
              self:AlienConstructs(false)
         end

       if not  self.timeLastStructOne or self.timeLastStructOne + 9 <= Shared.GetTime() then 
             self.timeLastStructOne = Shared.GetTime()
              GetConductor():ManageMacs()  
              GetConductor():ManageArcs()
         end
       if not  self.timeLastStructTwo or self.timeLastStructTwo + 10 <= Shared.GetTime() then
            self.timeLastStructTwo = Shared.GetTime()
            GetConductor():ManageDrifters() 
            GetConductor():ManageCrags() 
         end
         
        if not  self.timeLastStructThree or self.timeLastStructThree + 11 <= Shared.GetTime() then
            self.timeLastStructThree = Shared.GetTime()
            GetConductor():ManageShifts()
            GetConductor():ManageWhips() --gonna affect Phase Cannon ....... horrible perf?
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
local gamestarted = false
--Horrible for performance, right? Not precaching ++ local variables ++ table && for loops !!! 

-----------------------------------------------------------------------------------------------  
         local  PhaseGates = #GetActiveConstructsForTeam( "PhaseGate", 1 )
         
        if PhaseGates <= 3 then
        table.insert(tospawn, kTechId.PhaseGate)
        end --phaseavoca init 
   ------------------------------------------------------------------------------------------- 
     
        local  Armory = #GetActiveConstructsForTeam( "Armory", 1 )
      
         if Armory <= 7 then
         table.insert(tospawn, kTechId.Armory)
         end
   ---------------------------------------------------------------------------------------------
      
         local  RoboticsFactory = #GetActiveConstructsForTeam( "RoboticsFactory", 1 )
      
         if RoboticsFactory <= 3 then
         table.insert(tospawn, kTechId.RoboticsFactory)
         end
 ------------------------------------------------------------------------------------------------
         local  Observatory = #GetActiveConstructsForTeam( "Observatory", 1 )
      
         if Observatory <= 08 then
         table.insert(tospawn, kTechId.Observatory)
         end
 -----------------------------------------------------------------------------------------------
       
      if GetHasAdvancedArmory()  then
          local  PrototypeLab = #GetActiveConstructsForTeam( "PrototypeLab", 1 ) 
            if PrototypeLab < 6 then
             table.insert(tospawn, kTechId.PrototypeLab)
           end
     end
-------------------------------------------------------------------------------------------------   
         local  Sentry = #GetActiveConstructsForTeam( "Sentry", 1 )
      
         if Sentry <= 11 then
         table.insert(tospawn, kTechId.Sentry)
         end
----------------------------------------------------------------------------------------------------
      --timecheck to prevent 3 CC in one room w/o checking for such definition
         local  CommandStation = #GetEntitiesForTeam( "CommandStation", 1 )
         local timecheck = true--( Shared.GetTime() - GetGamerules():GetGameStartTime() ) >= 120
           if timecheck and CommandStation < 3 and not GetConductor():GetIsPhaseFourBoolean() then
           table.insert(tospawn, kTechId.CommandStation)
           end
           
------------------------------------------------------------------------------------------------------
--Lets make IPS purposefully spawn anywhere, possibly seperated from commandstation. Refer to previous version for ns2_ base hoarding.
         local  IPs = #GetActiveConstructsForTeam( "InfantryPortal", 1 )
           if IPs < 12 then --stop spawning? Noice. Natural. Old school 2015 (Better) ONLY IF I DO THE SAME WITH EGGS LOL
           table.insert(tospawn, kTechId.InfantryPortal) --make everyone director lulz
           end
 ----------------------------------------------------------------------------------------------------
  --Lets make arms lab do the same and spawn anywhere with power independent from cc
         local  Labs = #GetActiveConstructsForTeam( "ArmsLab", 1 )  
               --the 3 on the map could be inactive. 
           if Labs < 3 then --more? compare to alien 3 of each 
           table.insert(tospawn, kTechId.ArmsLab) 
           end
 ----------------------------------------------------------------------------------------------------

local  CCs = #GetEntitiesForTeam( "CommandStation", 1 )  

  local finalchoice = nil--table.random(tospawn) 
  
           if CCs < 3 then --more? compare to alien 3 of each 
          -- table.insert(tospawn, kTechId.CommandStation) 
             finalchoice = kTechId.CommandStation
           else
           finalchoice = table.random(tospawn) 
           end
---------------------------------------------------------------------------------------------------------
      return finalchoice
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



function Imaginator:ActualFormulaMarine()
     local randomspawn = nil
     local tospawn = GetMarineSpawnList(self)
     if  GetIsTimeUp(self.lastMarineBeacon, 30) then 
	 GetConductor():ManageMarineBeacons()
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
                               success = true
                            end --
                      else -- it tonly takes 1!
                       entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                          success = true
                        end  
                    end
                end
    
  return success
  
end






local function GetAlienSpawnList(self)
local tospawn = {}

      local  Shift = #GetActiveConstructsForTeam( "Shift", 2 )
      
      if Shift < 14 then
      table.insert(tospawn, kTechId.Shift)
      end 
      
      local  Whip = #GetActiveConstructsForTeam( "Whip", 2 )
      if Whip < 18 then
      table.insert(tospawn, kTechId.Whip)
      end 
      
      local  Crag = #GetActiveConstructsForTeam( "Crag", 2 )
      if Crag < 18 then
      table.insert(tospawn, kTechId.Crag)
      end 
      
      local  Shade = #GetActiveConstructsForTeam( "Shade", 2 )
      if Shade < 12 then
      table.insert(tospawn, kTechId.Shade)
      end 
      
     
    local finalchoice = nil
            
       if not GetHasFourHives() then
     finalchoice = kTechId.Hive 
      else
          finalchoice  = table.random(tospawn)
      end
  


      return finalchoice
  
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
       
            
      local finalchoice = table.random(tospawn)
      return finalchoice
       
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
local tospawn
local success = false
local randomspawn = nil
local hive = GetHive()
if not gamestarted then return end
     if hive and tospawn then             
                 randomspawn = FindFreeSpace( hive:GetOrigin(), 4, 24, true)
            if randomspawn then
                   local entity = CreateEntityForTeam(tospawn, randomspawn, 2)
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

       for i = 1, 8 do
         local success = self:ActualAlienFormula(cystonly)
         if success == true then break end
       end

              self:DoBetterUpgs()

return true

end





function Imaginator:ActualAlienFormula(cystonly)
  local randomspawn = nil
  local powerpoint  = GetRandomDisabledPower()
  local tospawn = GetAlienSpawnList(self)
  local success = false
  local entity = nil


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
                          end
                          success = true
                       else -- it tonly takes 1!
                          entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                          success = true
                     end 
            end
  end
   -- if success and entity then self:AdditionalSpawns(entity) end
  return success
 end
 

Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)