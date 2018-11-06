-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/



class 'Conductor' (Entity)
Conductor.kMapName = "conductor"



local networkVars = 

{

   phaseCannonTime = "float",
 alienenabled = "private boolean",
marineenabled = "private boolean",
arcSiegeOrig = "vector",
   
}

function Conductor:TimerValues()
  
   self.arcSiegeOrig = self:GetOrigin()
   
end
function Conductor:OnReset() 
   self:TimerValues()
end
   

local function MatchOrigins(mac, where)
local macloation = GetLocationForPoint(mac:GetOrigin())
local macloationname = macloation and macloation:GetName() or ""
local orderlocation = where.name
  return macloationname == orderlaction 
end
local function GetIsWeldedByOtherMAC(self, target)

    if target then
    
        for _, mac in ipairs(GetEntitiesForTeam("MAC", self:GetTeamNumber())) do
        
            if self ~= mac then
            
                if mac.secondaryTargetId ~= nil and Shared.GetEntity(mac.secondaryTargetId) == target then
                    return true
                end
                
                local currentOrder = mac:GetCurrentOrder()
                local orderTarget = nil
                if currentOrder and currentOrder:GetParam() ~= nil then
                    orderTarget = Shared.GetEntity(currentOrder:GetParam())
                end
                
                if currentOrder and orderTarget == target and (currentOrder:GetType() == kTechId.FollowAndWeld or currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.AutoWeld) then
                    return true
                end
                
            end
            
        end
        
    end
    
    return false
    
end

local function EntityIsaPowerPoint(nearestenemy)
 return nearestenemy:isa("PowerPoint") and nearestenemy:GetIsBuilt() and not nearestenemy:GetIsDisabled()
end
local function CreateAlienMarker(where)
        
        
        local nearestchair = GetNearest(where, "CommandStation", 1, function(ent) return ent:GetIsAlive()  end)
        local nearestarc = GetNearest(where, "ARC", 1, function(ent) return ent:GetIsAlive()  end)
        if not nearestarc or not nearestchair then return end 
        

        local random = math.random(1,4)
        
       if random == 1 then 
       
        local nearestarc = GetNearest(where, "ARC", 1, function(ent) return ent:GetIsAlive()  end)
         if nearestarc then 
           local arcwhere = nearestarc:GetOrigin() 
        CreatePheromone(kTechId.ThreatMarker,arcwhere, 2) 
        
        
        elseif random == 2 then
            local nearestchair = GetNearest(where, "CommandStation", 1, function(ent) return ent:GetIsAlive()  end)
               if nearestchair then
                    local ccwhere = nearestchair:GetOrigin()
                   CreatePheromone(kTechId.ThreatMarker, where, 2)  
                    --CreatePheromone(kTechId.ExpandingMarker, where, 2)  
                end
            end
        elseif random == 3 then
             local nearestenemy = GetNearestMixin(where, "Combat", 1, function(ent) return not ent:isa("Commander") and ent:GetIsAlive()  end)
             if not nearestenemy then return end -- hopefully not. Just for now this should be useful anyway.
             local inCombat = (nearestenemy.timeLastDamageDealt + 8 > Shared.GetTime()) or (nearestenemy.lastTakenDamageTime + 8 > Shared.GetTime())
              local where = nearestenemy:GetOrigin()
              CreatePheromone(kTechId.ThreatMarker,where, 2) 
        elseif random == 4 then
        
        
              local nearestheal = GetNearestMixin(where, "Combat", 2, function(ent) return not ent:isa("Commander") and ent:GetIsAlive() and ent:GetHealthScalar() <= 0.7 and ent:GetCanBeHealed() end)
          if nearestheal then 
           local where = nearestheal:GetOrigin()
                   CreatePheromone(kTechId.NeedHealingMarker,where, 2) 
           end
           
           
      end
      

      
end
local function FindMarineMove(where, which)
local random = {}
      local powerpoint = GetPowerPointForLocation(which.name)
         if powerpoint then
              return table.insert(random, powerpoint)
        end
          local payload = GetNearest(where, "ARC", 1)
         if payload then
              return table.insert(random, payload)
        end
        return table.random(random)
end
local function FindMarineOffense(where)
          local nearestalien = GetNearestMixin(where, "Combat", 2, function(ent) return not ent:isa("Commander") and not HasMixin(ent, "Construct") and ent:GetIsAlive() and ent:GetIsInCombat() end)
         if nearestalien then
              return nearestalien
        end
        return nil
end


local function BuildAllNodes(self)

          for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
             powerpoint:SetConstructionComplete() 
             local where = powerpoint:GetOrigin()
               if powerpoint:GetIsBuilt() and powerpoint.lightHandler then  powerpoint.lightHandler:DiscoLights() end
              if not GetIsPointInMarineBase(where) and math.random(1,2) == 1  then 
                     powerpoint:Kill() 
              end 
          end

end
local function DeleteResNodes(self)
   
          for _, resnode in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
               DestroyEntity(resnode)
          end   

end


function Conductor:OnRoundStart() 

           self:TimerValues()
           if Server then
              BuildAllNodes(self)
              DeleteResNodes(self)
              self:SpawnInitialStructures()
            end
            
   -- if kDamageTypeRules then      --DamageTypes.lua overwrite mod
   --  DoAvoca()
  --  kDamageTypeRules[kDamageType.Corrode] = {}
   -- table.insert(kDamageTypeRules[kDamageType.Corrode], ReduceGreatlyForPlayers)
    --table.insert(kDamageTypeRules[kDamageType.Corrode], IgnoreHealthForPlayersUnlessExo)
    
     --  end
    
end
function Conductor:OnCreate()  
   self.marineenabled = true
   self.alienenabled = true
   self.arcSiegeOrig = self:GetOrigin()
   if Server then
   self.phaseCannonTime = 30
   end
    self.phase = 0
      self:SetUpdates(true)
end



function Conductor:OnUpdate(deltatime)

             
if Server then
  
         if GetSiegeDoorOpen() then
          local inradius = #GetEntitiesWithinRange("Hive", self.arcSiegeOrig, ARC.kFireRange) >= 1
            if not inradius then
               Print("Conductor arc spot to place not in hive radius")
               local siegelocation = GetASiegeLocation()
               local siegepower = GetPowerPointForLocation(siegelocation.name)
               local hiveclosest = GetNearest(siegepower:GetOrigin(), "Hive", 2)
                    if hiveclosest then
                    Print("Found hiveclosest")
                      local origin  =FindArcHiveSpawn(siegepower:GetOrigin())  
                       if origin then
                       self.arcSiegeOrig = origin
                       Print("Found arc spot within hive radius")
                       end
                    end
            end
            if not inradius then
               Print("Conductor arc spot to place not in hive radius")
               local siegelocation = GetASiegeLocation()
               local siegepower = GetPowerPointForLocation(siegelocation.name)
               local hiveclosest = GetNearest(siegepower:GetOrigin(), "Hive", 2)
                    if hiveclosest then
                    Print("Found hiveclosest")
                      local origin  =FindArcHiveSpawn( ( (  siegepower:GetOrigin() + hiveclosest:GetOrigin() ) / 2) )  
                       if origin then
                       self.arcSiegeOrig = origin
                       Print("Found arc spot within hive radius")
                       end
                    end
            end
         end
         
             if not self.timeLastAutomations or self.timeLastAutomations + 8 <= Shared.GetTime() then
                   self:Automations()
                 self.timeLastAutomations = Shared.GetTime()
           end   
           
            if not self.phaseCannonTime or self.phaseCannonTime + math.random(23,69) <= Shared.GetTime() then
             self:PCTimer()
            self.phaseCannonTime = Shared.GetTime()
            end
           
         
  
  end
  
  
end 
function Conductor:GetIsMapEntity()
return true
end

local function FirePCAllBuiltRooms(self)
   local onechance = math.random(1,2)
 --if self:GetIsPhaseFourBoolean() then
   if onechance == 1 then
      local chance = math.random(1,100)
      if chance >= 70 then
         local power = GetRandomActivePower()
         if power then  self:FirePhaseCannons(power) return end --if not power then
      else
         local cc = GetRandomCC()
         if cc then  self:FirePhaseCannons(cc) return end
      end
      else
 --elseif self:GetIsPhaseTwoBoolean() then
      -- local cc = GetRandomCC()
     --  if cc then  self:FirePhaseCannons(cc) return end
      local power = GetRandomActivePower()
      if power then  self:FirePhaseCannons(power) return end
 end
 
local built = {}
                 for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                   if not GetIsPointInMarineBase(powerpoint:GetOrigin()) and powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then
                      table.insert(built, powerpoint)
                    end
                end
                if #built == 0 then return end
                local random = table.random(built)
                 self:FirePhaseCannons(random)
end


function Conductor:PCTimer()
         FirePCAllBuiltRooms(self)
end
function Conductor:SendNotification(who, seconds)
--replace with shine plugin avocagamerules
end
function Conductor:DoMist()
   local hive = GetRandomHive()
   local embryo = nil
      if hive then
         embryo = GetNearest(hive:GetOrigin(), "Embryo", 2,  function(ent) return ent:GetIsAlive()  end ) --not misted
         if embryo then
            CreateEntity(NutrientMist.kMapName,embryo:GetModelOrigin(), 2 )
         end
      end
end
local function PowerPointStuff(who, self)
local location = GetLocationForPoint(who:GetOrigin())
local powerpoint =  location and GetPowerPointForLocation(location.name)
  local team1Commander = GetGamerules().team1:GetCommander()
  local team2Commander = GetGamerules().team2:GetCommander()
      if powerpoint ~= nil then 
              if not ( team1Commander and self.marineenabled )  and ( powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() ) then 
                return 1
              end
             if ( not team2Commander and self.alienenabled ) and ( powerpoint:GetIsDisabled() )  then
                  return 2
               end
     end
end
local function WhoIsQualified(who, self)
   return PowerPointStuff(who, self)
end
local function Touch(who, where, what, number)
 local tower = CreateEntityForTeam(what, where, number, nil)
   if not GetSetupConcluded() then tower:SetConstructionComplete() end
         if tower then
            who:SetAttached(tower)
            if number == 1 then
           -- tower:SetConstructionComplete()
            --end
            elseif number == 2 then
             doChain(tower)
             CreateEntity(Clog.kMapName,where, 2 )
            end
            return tower
         end
end
local function Envision(self,who, which)
   if which == 1 and self.marineenabled then
     Touch(who, who:GetOrigin(), kTechId.Extractor, 1)
   elseif which == 2 and self.alienenabled then
     Touch(who, who:GetOrigin(), kTechId.Harvester, 2)
    end
end
local function AutoDrop(self,who)
  local which = WhoIsQualified(who, self)
  if which ~= 0 then Envision(self,who, which) end
end
function Conductor:AutoBuildResTowers()
  for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
        if not respoint:GetAttached() then AutoDrop(self, respoint) end
    end
end
function Conductor:Automations()
              self:DoMist()
            --  self:MaintainHiveDefense()
              self:HandoutMarineBuffs() 
            --  self:CheckAndMaybeBuildMac()
             if GetGameStarted() then
               self:AutoBuildResTowers()
             end 
             
              return true
end



function Conductor:ManageArcs()

 local where = nil
     if self.arcSiegeOrig ~= self:GetOrigin() then
       where = self.arcSiegeOrig
     end
   for index, arc in ipairs(GetEntitiesForTeam("ARC", 1)) do
     arc:Instruct(where)
   end
   
   
end

local function ManageConstruct(who, where)
    local conS = nil
        conS = GetNearestMixin(where, "Construct", 1,  function(ent) return not ent:GetIsBuilt()  end ) 
      if conS then 
                    local where = conS:GetOrigin()
                    --if ispathable and canreach then....
                   return who:GiveOrder(kTechId.Weld, conS:GetId(), where, nil, false, false)   
      end
end

local function ManagePower(who, where)
    local choice = math.random(1,100)  
    local power = nil
     -- why random and not nearest? well if its a lost cause then why repeat it and not spread. hm
      if choice >= 70 then
        power = GetNearest(where, "PowerPoint", 1,  function(ent) return ent:GetIsDisabled()  end ) 
      else
        power = GetRandomDisabledPowerNotHive() --was told not to go to hive. 
      end
      if power then --while power 
                    local target = power
                    local where = target:GetOrigin()
                      who:SetOrigin(FindFreeSpace(where))
                   return who:GiveOrder(kTechId.Weld, target:GetId(), where, nil, false, false)   
      end
end


local function ManagePlayerWeld(who, where)

 local player =  GetNearest(who:GetOrigin(), "Marine", 1, function(ent) return ent:GetIsAlive() end) 
 
  if player then
    who:GiveOrder(   kTechId.FollowAndWeld, player:GetId(), player:GetOrigin(), nil, false, false)
  end

end

function Conductor:ManageMacs()

  local cc = GetRandomCC()
  local  macs = GetEntitiesForTeam( "MAC", 1 )  

     if cc then
       local where = cc:GetOrigin()
            if not #macs or #macs <6 then
            CreateEntity(MAC.kMapName, FindFreeSpace(where), 1)
            end
     end
   
            for i = 1, #macs do
            local mac = macs[i]
              if not mac:GetHasOrder() then
                  --if mac:GetIsAvoca() then
                    --if front door open then managepower
                   -- ManagePower(mac, mac:GetOrigin())
                     -- ManageConstruct(mac, mac:GetOrigin())
                      --break
                  -- else
                    ManagePlayerWeld(mac, mac:GetOrigin())
                --  end
               end
             end

   
end


local function GetDrifterBuff()
 local buffs = {}
 if GetHasShadeHive()  then table.insert(buffs,kTechId.Hallucinate) end
 if GetHasCragHive()  then table.insert(buffs,kTechId.MucousMembrane) end
  if GetHasShiftHive()  then table.insert(buffs,kTechId.EnzymeCloud) end
    return table.random(buffs)
end

function Conductor:GiveDrifterOrder(who, where)

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
    
        if structure then      
            who:GiveOrder(kTechId.Grow, structure:GetId(), structure:GetOrigin(), nil, false, false)
            return  
        end
        
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

function Conductor:ManageDrifters()
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
              break
              end
          end
        end
   
   end
   
end
function Conductor:ManageShifts()

     
       if not GetFrontDoorOpen() then return end

         local random = math.random(1,4)
       for i = 1, random do --maybe time delay ah
           local hive = GetRandomHive()
           local nearestof = GetNearest(hive:GetOrigin(), "Shift", 2, function(ent) return ent:GetIsBuilt() and ( ent.GetIsInCombat and not ent:GetIsInCombat() and not ent:GetIsACreditStructure() and not ent.moving )  end)
            if nearestof then
               --if not moving
               local power = GetNearest(nearestof:GetOrigin(), "PowerPoint", 1,  function(ent) return ent:GetIsBuilt() and ent:GetIsDisabled() and GetLocationForPoint(nearestof:GetOrigin()) ~= GetLocationForPoint(ent:GetOrigin())  end ) 
               if power then
                 nearestof:GiveOrder(kTechId.Move, power:GetId(), FindFreeSpace(power:GetOrigin(), 4), nil, false, false) 
               end
            end 
       end  
end

function Conductor:ManageScans()
if not GetSiegeDoorOpen() then return end
  local hive = GetRandomHive()
  if hive then
   CreateEntity(Scan.kMapName, hive:GetOrigin(), 1) 
   end
end

function Conductor:ManageCrags()

       local random = math.random(1,4)
       if not GetFrontDoorOpen() then return end

       
       for i = 1, random do --maybe time delay ah
           local hive = GetRandomHive()
           local nearestof = GetNearest(hive:GetOrigin(), "Crag", 2, function(ent) return ent:GetIsBuilt() and not ent:GetIsACreditStructure() end) --and not ent.moving )  end)
            if nearestof then
            --if moving then like arc instruct specificrules
               nearestof:InstructSpecificRules()

               if nearestof.moving then return end
               local power = GetNearest(nearestof:GetOrigin(), "PowerPoint", 1,  function(ent) return ent:GetIsBuilt() and ent:GetIsDisabled() and GetLocationForPoint(nearestof:GetOrigin()) ~= GetLocationForPoint(ent:GetOrigin()) end ) 
               if power then
                 nearestof:GiveOrder(kTechId.Move, power:GetId(), FindFreeSpace(power:GetOrigin(), 4), nil, false, false) 
               end
            end 
       end  
end

function Conductor:ManageWhips()

    if not GetFrontDoorOpen() then return end
       --mindfuck would be getnearest built node that is beyond the arc radius of the closest arc to that node. HAH.
       --local powerpoint = GetRandomActivePower() 
       
       --gonna affect contam whip etc
       local random = math.random(1,4)
       
       --leave min around hive not all leave. hm.
       

       
       for i = 1, random do --maybe time delay ah
           local hive = GetRandomHive()
           local nearestof = GetNearest(hive:GetOrigin(), "Whip", 2, function(ent) return ent:GetIsBuilt() and ( ent.GetIsInCombat and not ent:GetIsInCombat() and not ent.moving )  end)
            if nearestof then
               -- if not moving
               local power = GetNearest(nearestof:GetOrigin(), "PowerPoint", 1,  function(ent) return ent:GetIsBuilt() and not ent:GetIsDisabled()  end ) 
               if power then
                 nearestof:GiveOrder(kTechId.Move, power:GetId(), FindFreeSpace(power:GetOrigin(), 4), nil, false, false) 
                 -- CreatePheromone(kTechId.ThreatMarker,power:GetOrigin(), 2)  if get is time up then
               end
            end 
       end   

end







Shared.LinkClassToMap("Conductor", Conductor.kMapName, networkVars)







