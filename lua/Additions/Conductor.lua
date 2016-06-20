-- Kyle 'Avoca' Abent


class 'Conductor' (Entity)
Conductor.kMapName = "conductor"



local networkVars = 

{
}

 function GetIsInAirLock(who)  --I don't want to rely on networkvars.
local boolean = false
if who:isa("Spectator") then return false end

            for _, airlock in ientitylist(Shared.GetEntitiesWithClassname("AirLock")) do
               local location = GetLocationForPoint(who:GetOrigin())
               boolean = location and airlock.name == location.name -- Smart ! -- Better than OnUpdate too.
               break
          end
   
 --Print("who in airlock is %s", boolean)
return boolean

end
local function AddPlayerResources(harvesters, extractors)
  --Settling with this cheap stuff for now to just see how it works without spending too much time on it
   for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do      --4% PRES increase for 'being' in AirLock.
         local presamount = kPlayerResPerInterval * ConditionalValue(GetIsInAirLock(player), 1.3, 1)
          if presamount > kPlayerResPerInterval then Print("Player Pres Bonus: %s", math.min(presamount - kPlayerResPerInterval) * extractors) end
         if player:GetTeamNumber() == 1 then
            player:AddResources(presamount * extractors)
         elseif player:GetTeamNumber() == 2 then
           player:AddResources(presamount * harvesters)
         end
    end
end
local function MarinesInAirLock()
   local marines = GetGamerules():GetTeam1():GetNumPlayers()
  local count = 0
  local bonusper = 1
   for _, player in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do 
        if player:GetIsAlive() and GetIsInAirLock(player) then
         count = count + 1
        --Print("marines count is %s", count)
         end
   end
      local total = (count/marines)*bonusper
      --Print("marines total is %s", total)
     return (count/marines)*bonusper
end
local function AliensInAirLock()
    local aliens = GetGamerules():GetTeam2():GetNumPlayers()
  local count = 0
  local bonusper = 1
   for _, player in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do 
        if player:GetIsAlive() and GetIsInAirLock(player) then
         count = count + 1
           --Print("aliens count is %s", count)
         end
   end
      local total = (count/aliens)*bonusper
      --Print("aliens total is %s", total)
     return (count/aliens)*bonusper
end
local function AddTeamResources(harvesters, extractors)
               local tresamount = kTeamResourcePerTick + MarinesInAirLock()
               if tresamount > kTeamResourcePerTick then Print("Marine team Tres Bonus: %s", math.min(tresamount - kTeamResourcePerTick) * extractors ) end
               GetGamerules():GetTeam1():AddTeamResources(tresamount  * extractors)
               local tresamount = kTeamResourcePerTick + AliensInAirLock()
               if tresamount > kTeamResourcePerTick then Print("Alien team Tres Bonus: %s", math.min(tresamount - kTeamResourcePerTick) * harvesters ) end
               GetGamerules():GetTeam2():AddTeamResources(tresamount  * harvesters)
               Print("derp")
end
    
              
local function CoordinateWithPowerNode(locationname)
                 local powernode = GetPowerPointForLocation(locationname)
                    if powernode then
                    powernode:SetLightMode(kLightMode.MainRoom)
                    powernode:AddTimedCallback(function() powernode:SetLightMode(kLightMode.Normal) end, 10)
                    end
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
local function FindAppropriateOrder(mac,where)
            local constructable =  GetNearestMixin(where, "Construct", 1, function(ent) return not ent:GetIsBuilt() and ent:GetCanConstruct(mac) and mac:CheckTarget(ent:GetOrigin())  end)
               if constructable then
                    mac:GiveOrder(kTechId.Construct, constructable:GetId(), constructable:GetOrigin())
                    return
                end
            
                // Look for entities to heal with weld.
                local weldables = GetEntitiesWithMixinForTeamWithinRange("Weldable", 1, where, 12)
                for w = 1, #weldables do
                
                    local weldable = weldables[w]
                    // There are cases where the weldable's weld percentage is very close to
                    // 100% but not exactly 100%. This second check prevents the MAC from being so pedantic.
                    if weldable:GetCanBeWelded(mac) and weldable:GetWeldPercentage() < 1 and not GetIsWeldedByOtherMAC(mac, weldable) then
                    mac:GiveOrder(kTechId.Construct, weldable:GetId(), weldable:GetOrigin())
                    return
                    end
                 end
        
end
local function MoveMacs(where)
        for _, mac in ipairs(GetEntitiesWithinRange("MAC", where, 999)) do
           if mac:GetIsAlive() and not mac:GetHasOrder() and not MatchOrigins(mac, where) then
           FindAppropriateOrder(mac, where)
           end
       end
end
local function EntityIsaPowerPoint(nearestenemy)
 return nearestenemy:isa("PowerPoint") and nearestenemy:GetIsBuilt() and not nearestenemy:GetIsDisabled()
end
local function CreateAlienMarker(where)

       local gameLength = Shared.GetTime() - GetGamerules():GetGameStartTime()
      if gameLength <= 300  then
           local hive = nil
             for _, hivey in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             hive = hivey
            end

        local nearestbuiltnode = GetNearest(hive:GetOrigin(), "PowerPoint", 1, function(ent) return ent:GetIsBuilt() and not ent:GetIsDisabled()  end)
    if nearestbuiltnode then
         CreatePheromone(kTechId.ThreatMarker,nearestbuiltnode:GetOrigin(), 2)
         return 
    end
      end
        local nearestenemy = GetNearestMixin(where, "Combat", 1, function(ent) return not ent:isa("Commander") and ent:GetIsAlive()  end)
        if not nearestenemy then return end -- hopefully not. Just for now this should be useful anyway.
        local inCombat = (nearestenemy.timeLastDamageDealt + 8 > Shared.GetTime()) or (nearestenemy.lastTakenDamageTime + 8 > Shared.GetTime())
        local where = nearestenemy:GetOrigin()
       if inCombat then 
        CreatePheromone(kTechId.ThreatMarker,where, 2) 
        else
        CreatePheromone(kTechId.ExpandingMarker, where, 2)  
      end
      
      local nearestheal = GetNearestMixin(where, "Combat", 2, function(ent) return not ent:isa("Commander") and ent:GetIsAlive() and ent:GetHealthScalar() <= 0.7 end)
          if nearestheal then 
           local where = nearestheal:GetOrigin()
                   CreatePheromone(kTechId.NeedHealingMarker,where, 2) 
           end
      
end
local function FindMarineMove(which)
      local random = GetPowerPointForLocation(which.name)
         if random then
              return random:GetOrigin()
        end
        return nil
end
local function FindMarineOffense(where)
          local nearestalien = GetNearestMixin(where, "Combat", 2, function(ent) return not ent:isa("Commander") and not HasMixin(ent, "Construct") and ent:GetIsAlive() and ent:GetIsInCombat() end)
         if nearestalien then
              return nearestalien
        end
        return nil
end
local function FindMarineDefense(where)
          local nearesttodefend = GetNearestMixin(where, "Combat", 1)
         if nearesttodefend then
            local inCombat = (nearesttodefend.timeLastDamageDealt + 8 > Shared.GetTime()) or (nearesttodefend.lastTakenDamageTime + 8 > Shared.GetTime())
             if inCombat then 
                return nearesttodefend
              end
        end
        return nil
end
local function SendTheMarineOrdersHere(who, where, which) 
 local offense = nil 
 local defense = nil 
 local move = nil  


             local gameLength = Shared.GetTime() - GetGamerules():GetGameStartTime()
      if gameLength <= 300  then
           local cc = nil
          local team1avgorigin = Vector(0, 0, 0)
          local marines = 1
          
            for _, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
            if marine:GetIsAlive() and not marine:isa("Commander") then marines = marines + 1 team1avgorigin = team1avgorigin + marine:GetOrigin() end
             end
             
            team1avgorigin  = (team1avgorigin / marines )

        local nearestbuildable = GetNearestMixin(team1avgorigin, "Construct", 1, function(ent) return not ent:GetIsBuilt() end)
    if nearestbuildable then
        who:GiveOrder(kTechId.Build, nearestbuildable:GetId(), nearestbuildable:GetOrigin(), nil, true, true)
         return 
    end
      end
      
      
           offense = FindMarineOffense(where)
                if offense ~= nil then
                who:GiveOrder(kTechId.Attack, offense:GetId(), offense:GetOrigin(), nil, true, true)
                return
                end
           defense = FindMarineDefense(where) 
              if defense ~= nil then
              who:GiveOrder(kTechId.Defend, defense:GetId(), defense:GetOrigin(), nil, true, true)
              return
              end
              
           move =  FindMarineMove(which)
           if move ~= nil  then
                who:GiveOrder(kTechId.Move, nil, move, nil, true, true)
                return
           end

end   
 local function ForAllMarinesSendWP(where, which)
          for _, player in ipairs(GetEntitiesWithinRange("Marine", where, 999)) do
           if player:GetIsAlive() and not player:isa("Commander") then
               SendTheMarineOrdersHere(player,where, which)
           end
         end
end
local function FindOrCreateKingCyst(where, which)
 local king = false
 local temphack =  GetNearest(where, "Player", nil, function(ent) return not ent:isa("Commander") and ent:GetIsAlive() end) 
  if not temphack then return end
 local toplace = GetRandomBuildPosition( kTechId.Whip, temphack:GetOrigin(), 8 )
     if not toplace then return end
   toplace = GetGroundAtPosition(toplace, nil, PhysicsMask.CommanderBuild)

     if toplace then 

           for _, kingcyst in ientitylist(Shared.GetEntitiesWithClassname("CystAvoca")) do
             hasking = true
             king = kingcyst
             break
          end
          
          if hasking and king then
             king:SetOrigin(toplace) 
          else
              local KingCyst = CreateEntity(CystAvoca.kMapName, where, 2)
              KingCyst:SetConstructionComplete()
              KingCyst:SetInfestationRadius(0)
              king = KingCyst
          end
     else
       Print("No spot found for king cyst!")
     end
       
       if king then Print("King Cyst located in %s", which.name) end

end
local function BreachAirLock(where, which)
  local airlock = CreateEntity(AirLock.kMapName, where)
  airlock.scale = which.scale
  airlock.name = which.name
  airlock:SetBox(airlock.scale)  -- Rather than trigger init?
  Print("Airlock @ %s", which.name)
  

  
  
end
local function SealAirLock()

          for _, airlock in ientitylist(Shared.GetEntitiesWithClassname("AirLock")) do
             DestroyEntity(airlock)
          end

end
local function BuildAllNodes(self)

          for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
              powerpoint:SetConstructionComplete()
          end

end
function Conductor:OnCreate() 
   for i = 1,8  do
     Print("Conductor created")
   end
   

   
           if Server then
              BuildAllNodes(self)
              self:SpawnInitialStructures()
              self:AutoBioMass()
              local CreateImagination = CreateEntity(Imaginator.kMapName)
              self:AddTimedCallback(Conductor.PickMainRoom, 16)
              self:AddTimedCallback(Conductor.Automations, 8)
            end
end
function Conductor:OnDestroy()
     if Server then
          for _, imagination in ientitylist(Shared.GetEntitiesWithClassname("Imaginator")) do
             DestroyEntity(imagination)  --how cruel
          end
      end

end
function Conductor:PickMainRoom()
       --Print("Picking main room")
       SealAirLock()
       local location = self:GetLocationWithMostMixedPlayers()
       if not location then return true end
       self:SetMainRoom(location:GetOrigin(), location) 
       return true
end
function Conductor:SetMainRoom(where, which)
       if Server then MoveMacs(where) end
        CoordinateWithPowerNode(which.name)
        CreateAlienMarker(where)
        BreachAirLock(where, which)
        ForAllMarinesSendWP(where, which)
        FindOrCreateKingCyst(where, which)
end
function Conductor:Automations()
              self:InitiateBalancer()
              self:CollectResources()
              self:MaintainHiveDefense()
              self:HandoutMarineBuffs()
              return true
end
function Conductor:CollectResources()
   local harvesters = Clamp(SimpleCClass(string.format("Harvester"), true) or 0, 1, 14)
   local extractors =  Clamp(SimpleCClass(string.format("Extractor"), true) or 0, 1, 14)
   AddPlayerResources(harvesters, extractors)
   AddTeamResources(harvesters, extractors)
end


function Conductor:GetLocationWithMostMixedPlayers()
-- works good 2.15
--so far v1.23 shows this works okay except for picking empty res rooms for some reason -.-
//Print("GetLocationWithMostMixedPlayers")

local team1avgorigin = Vector(0, 0, 0)
local marines = 1
local team2avgorigin = Vector(0, 0, 0)
local aliens = 1
local neutralavgorigin = Vector(0, 0, 0)

            for _, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
            if marine:GetIsAlive() and not marine:isa("Commander") then marines = marines + 1 team1avgorigin = team1avgorigin + marine:GetOrigin() end
             end
             
           for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do
            if alien:GetIsAlive() and not alien:isa("Commander") then aliens = aliens + 1 team2avgorigin = team2avgorigin + alien:GetOrigin() end 
             end
             --v1.23 added check to make sure room isnt empty
         neutralavgorigin =  team1avgorigin + team2avgorigin
         neutralavgorigin =  neutralavgorigin / (marines+aliens) --better as a table i know
     //    Print("neutralavgorigin is %s", neutralavgorigin)
     local nearest = GetNearest(neutralavgorigin, "Location", nil, function(ent) local powerpoint = GetPowerPointForLocation(ent.name) return ent:MakeSureRoomIsntEmpty() and  powerpoint ~= nil end)
    if nearest then
   // Print("nearest is %s", nearest.name)
        return nearest
    end

end
function Conductor:GetCombatEntitiesCount()
            local combatentities = 1
            for _, entity in ipairs(GetEntitiesWithMixin("Combat")) do
                --Though taken from combatmixin.lua :P
             local inCombat = (entity.timeLastDamageDealt + math.random(4,8) > Shared.GetTime()) or (entity.lastTakenDamageTime + math.random(4,8) > Shared.GetTime())
                  if inCombat then combatentities = combatentities + 1 end
                  if entity.mainbattle == true then entity.mainbattle = false end
             end
             //     Print("combatentities %s", combatentities)
            return combatentities
end
function Conductor:GetCombatEntitiesCountInRoom(location)
       local entities = location:GetEntitiesInTrigger()
       local eligable = 0
             for _, entity in ipairs(entities) do
             if HasMixin(entity, "Combat") then
                local inCombat = (entity.timeLastDamageDealt + math.random(4,8) > Shared.GetTime()) or (entity.lastTakenDamageTime + math.random(4,8) > Shared.GetTime())
                  if inCombat then
                  eligable = eligable + 1
                 end
             end
            end
       // Print("location %s, eligable %s", location, eligable)
        return eligable
end


--

Shared.LinkClassToMap("Conductor", Conductor.kMapName, networkVars)




--




