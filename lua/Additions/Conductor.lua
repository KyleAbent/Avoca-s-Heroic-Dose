-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/



class 'Conductor' (Entity)
Conductor.kMapName = "conductor"



local networkVars = 

{

   PhaseTwoTimer = "float",
   PhaseOneTimer = "float",
   PhaseThreeTimer = "float",
   PhaseFourTimer = "float",
   phase = "float",
   
   --modeling after ns2 gamerules in gamestate for hooking trigger for specific rules on each state of round.
   --thanks  stoner
   
  
   
   
   //payLoadTime = "float",
   phaseCannonTime = "float",
   
   gameStartTime = "time"
}

function Conductor:TimerValues()
  
  
   self.PhaseOneTimer = 300
   self.PhaseTwoTimer = 600
   self.PhaseThreeTimer = 900
   self.PhaseFourTimer = 1200
   self.phase = 0
   
end
function Conductor:OnReset() 
   self:TimerValues()
end

function Conductor:ResetLight()
if not self.powerlighth then return false end 
self.powerlighth:RestoreColorDerp()
return false
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
            self.gameStartTime = Shared.GetTime()
           self:TimerValues()
           if Server then
              BuildAllNodes(self)
              DeleteResNodes(self)
              self:SpawnInitialStructures()
            end
            
    if kDamageTypeRules then      --DamageTypes.lua overwrite mod
     DoAvoca()
  --  kDamageTypeRules[kDamageType.Corrode] = {}
   -- table.insert(kDamageTypeRules[kDamageType.Corrode], ReduceGreatlyForPlayers)
    --table.insert(kDamageTypeRules[kDamageType.Corrode], IgnoreHealthForPlayersUnlessExo)
    
       end
    
end
function Conductor:OnCreate()  
   self.gameStartTime = 0 
   if Server then
   self.phaseCannonTime = 30
   self.powerlighth = nil
   end
    self.phase = 0
      self:SetUpdates(true)
end


function Conductor:GetPhaseOneLength()
 return self.PhaseOneTimer 
end
function Conductor:GetPhaseTwoLength()
 return self.PhaseTwoTimer 
end

function Conductor:GetPhaseThreeLength()
 return self.PhaseThreeTimer 
end
function Conductor:GetPhaseFourLength()
 return self.PhaseFourTimer 
end


function Conductor:GetIsPhaseOneBoolean()
    --   Print(" Conductor:GetIsPhaseOneBoolean() is %s", self:GetIsPhaseOne())
        return  self:GetIsPhaseOne()
end
function Conductor:GetIsPhaseTwoBoolean()
       --Print(" Conductor:GetIsPhaseTwoBoolean() is %s", self:GetIsPhaseTwo())
        return  self:GetIsPhaseTwo()
end
function Conductor:GetIsPhaseThreeBoolean()
    --   Print(" Conductor:GetIsPhaseOneBoolean() is %s", self:GetIsPhaseOne())
        return  self:GetIsPhaseThree()
end
function Conductor:GetIsPhaseFourBoolean()
       --Print(" Conductor:GetIsPhaseTwoBoolean() is %s", self:GetIsPhaseTwo())
        return  self:GetIsPhaseFour()
end
function Conductor:GetIsPhaseOne()
           if self.phase == 1 then return true end 
           local gamestarttime = self.gameStartTime
           local gameLength = Shared.GetTime() - gamestarttime
            local istrue = gameLength >= self.PhaseOneTimer 
           if istrue then
             self:SetGamePhase(1)
            end
          // Print(" GetIsPhaseOne (%s) gameLength is %s, PhaseOneTimer is %s", gameLength >= self.PhaseOneTimer, gameLength, self.PhaseOneTimer)
           return  gameLength >= self.PhaseOneTimer
end
function Conductor:GetIsPhaseTwo()
           if self.phase == 2 then return true end 
           local gamestarttime =   self.gameStartTime
           local gameLength = Shared.GetTime() - gamestarttime
            local istrue = gameLength >= self.PhaseTwoTimer 
           if istrue then
             self:SetGamePhase(2)
            end
           --Print(" GetIsPhaseTwo gameLength is %s, PhaseTwoTimer is %s", gameLength, self.PhaseTwoTimer)
           return  gameLength >= self.PhaseTwoTimer
end

 
 function Conductor:GetIsPhaseThree()
             if self.phase == 3 then return true end 
           local gamestarttime = GetGameInfoEntity():GetStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           local istrue = gameLength >= self.PhaseFourTimer 
           if istrue then
             self:SetGamePhase(3)
            end
           return  gameLength >= self.PhaseThreeTimer
end
function Conductor:GetIsPhaseFour()
           if self.phase == 4 then return true end 
           local gamestarttime = GetGameInfoEntity():GetStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           local istrue = gameLength >= self.PhaseFourTimer --and state != "Four" -- still iteratively annoying
           if istrue then
             self:SetGamePhase(4)
            end
    
           return  istrue
end


function Conductor:TriggerPhaseTwo()
  
end 




function Conductor:OnUpdate(deltatime)

             
if Server then
  
         
             if not self.timeLastAutomations or self.timeLastAutomations + 8 <= Shared.GetTime() then
                   self:Automations()
                 self.timeLastAutomations = Shared.GetTime()
           end   
           
            if not self.phaseCannonTime or self.phaseCannonTime + math.random(23,69) <= Shared.GetTime() then
             self:PCTimer()
            self.phaseCannonTime = Shared.GetTime()
            end
            /*
            if not self.payLoadTime or self.payLoadTime + 60 <= Shared.GetTime()  then
              self:PayloadTimer()
              self.payLoadTime = Shared.GetTime()
            end
           */
           
         
  
  end
  
  
end 
function Conductor:GetIsMapEntity()
return true
end

local function FirePCAllBuiltRooms(self)

 if self:GetIsPhaseFourBoolean() then
      local chance = math.random(1,100)
      if chance >= 70 then
         local power = GetRandomActivePower()
         if power then  self:FirePhaseCannons(power) return end --if not power then
      else
         local cc = GetRandomCC()
         if cc then  self:FirePhaseCannons(cc) return end
      end
 elseif self:GetIsPhaseTwoBoolean() then
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
function Conductor:Automations()
              self:DoMist()
              self:CollectResources()
            --  self:MaintainHiveDefense()
              self:HandoutMarineBuffs()
            --  self:CheckAndMaybeBuildMac()
              return true
end



function Conductor:ManageArcs()
    /*
    if self.phase == 1 then
    elseif self.phase == 2 then
    elseif self.phase == 3 then
    elseif self.phase== 4 then
    else
    end
    */
    
   for index, arc in ipairs(GetEntitiesForTeam("ARC", 1)) do
     arc:Instruct()
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

     local eligable = {}
        for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
           if  entity:GetTeamNumber() == 1 and entity:GetIsAlive() and entity:GetCanBeWelded(who) then
           table.insert(eligable, entity )
           end
       end
  
     if #eligable == 0 then 
           for _, entity in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
               if entity:GetIsAlive() and entity:GetCanBeWelded(who) then
               table.insert(eligable, entity )
              end
          end
     end
     
      if #eligable == 0 then return end 
      
     local whoTo = table.random(eligable)
     local where = whoTo:GetOrigin()
     who:SetOrigin(FindFreeSpace(where))
     who:GiveOrder(kTechId.Weld, whoTo:GetId(), where, nil, false, false)  

end

function Conductor:ManageMacs()

  local cc = GetRandomCC()
  local  macs = GetEntitiesForTeam( "MAC", 1 )  

     if cc then
       local where = cc:GetOrigin()
            if not #macs or #macs <4 then
            CreateEntity(MAC.kMapName, FindFreeSpace(where), 1)
            end
     end
   
            for i = 1, #macs do
            local mac = macs[i]
              if not mac:GetHasOrder() then
                  if mac:GetIsAvoca() then
                    ManagePower(mac, mac:GetOrigin())
                   else
                    ManagePlayerWeld(mac, mac:GetOrigin())
                  end
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
              end
          end
        end
   
   end
   
end
function Conductor:ManageShifts()

       local random = math.random(1,4)
       

       
       for i = 1, random do --maybe time delay ah
           local hive = GetRandomHive()
           local nearestof = GetNearest(hive:GetOrigin(), "Shift", 2, function(ent) return ent:GetIsBuilt() and ( ent.GetIsInCombat and not ent:GetIsInCombat() and not ent:GetIsACreditStructure() and not ent.moving )  end)
            if nearestof then
               local power = GetNearest(nearestof:GetOrigin(), "PowerPoint", 1,  function(ent) return ent:GetIsBuilt() and ent:GetIsDisabled() and GetLocationForPoint(nearestof:GetOrigin()) ~= GetLocationForPoint(ent:GetOrigin())  end ) 
               if power then
                 nearestof:GiveOrder(kTechId.Move, power:GetId(), FindFreeSpace(power:GetOrigin(), 4), nil, false, false) 
               end
            end 
       end  
end



function Conductor:ManageCrags()

       local random = math.random(1,4)
       

       
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

       --mindfuck would be getnearest built node that is beyond the arc radius of the closest arc to that node. HAH.
       --local powerpoint = GetRandomActivePower() 
       
       --gonna affect contam whip etc
       local random = math.random(1,4)
       
       --leave min around hive not all leave. hm.
       
       for i = 1, random do --maybe time delay ah
           local hive = GetRandomHive()
           local nearestof = GetNearest(hive:GetOrigin(), "Whip", 2, function(ent) return ent:GetIsBuilt() and ( ent.GetIsInCombat and not ent:GetIsInCombat() and not ent:GetIsACreditStructure() and not ent.moving )  end)
            if nearestof then
               local power = GetNearest(nearestof:GetOrigin(), "PowerPoint", 1,  function(ent) return ent:GetIsBuilt() and not ent:GetIsDisabled()  end ) 
               if power then
                 nearestof:GiveOrder(kTechId.Move, power:GetId(), FindFreeSpace(power:GetOrigin(), 4), nil, false, false) 
                 -- CreatePheromone(kTechId.ThreatMarker,power:GetOrigin(), 2)  if get is time up then
               end
            end 
       end   

end





 function Conductor:SetGamePhase(phase)
    

        if phase ~= self.phase then
        
          self.phase = phase
          
          if phase == 1 then
          elseif phase == 2 then
          elseif  phase == 3 then
           elseif phase == 4 then

              --if state == four
            --   if kDamageTypeGlobalRules then --Server then 
            --     table.insert(kDamageTypeGlobalRules, PhaseFourYo) --if this works then better than checking on every dmg prior
           --    end
               
           end
            
        end
        
    end

if Server then 



function Conductor:CollectResources()  --Not great for CO_ With 4 total PP. 0 res.
   local builtpower = 9
   local disabledpower = 9
   local marineteam = nil
   local alienteam = nil

       for _, player in ipairs(GetEntitiesForTeam("Player", 1)) do
        if not player:isa("Commander") then
            player:AddResources(builtpower / 10 )  --clamp it
            if not marineteam then marineteam = player:GetTeam() end
        end
    end
    
        for _, player in ipairs(GetEntitiesForTeam("Player", 2)) do
        if not player:isa("Commander") then
            player:AddResources(disabledpower / 10) 
             if not alienteam then alienteam = player:GetTeam() end
        end
    end
    
        if alienteam then
        alienteam:AddTeamResources(kTeamResourcePerTick, true)
       end
       
        if marineteam then
        marineteam:AddTeamResources(kTeamResourcePerTick, true)
       end
    
   --AddPlayerResources(harvesters, extractors)

end



end




Shared.LinkClassToMap("Conductor", Conductor.kMapName, networkVars)







