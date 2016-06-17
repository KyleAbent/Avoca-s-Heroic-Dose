-- Kyle 'Avoca' Abent

class 'Conductor' (Entity)
Conductor.kMapName = "conductor"



local networkVars = 

{
}

local function  GetIsInAirLock(who)  --I don't want to rely on networkvars.
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
         local presamount = kPlayerResPerInterval * ConditionalValue(GetIsInAirLock(player), 1.04, 1)
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
local function CreateAlienMarker(where)
       

       
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
 local hasking = falss
 local king = false
 local toplace = GetNearest(where, "Player", 2, function(ent) return not ent:isa("Commander") and ent:GetIsAlive() and ent:GetIsOnGround() end) 
     
     if toplace then 
     
           for _, kingcyst in ientitylist(Shared.GetEntitiesWithClassname("CystAvoca")) do
             hasking = true
             king = kingcyst
             break
          end
          
          if hasking and king then
               king:SetDesiredInfestationRadius(0)
               king:SetOrigin(toplace:GetOrigin()) 
               king:SetDesiredInfestationRadius(7)
          else
              local KingCyst = CreateEntity(CystAvoca.kMapName, where, 2)
              KingCyst:SetConstructionComplete()
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
  
  FindOrCreateKingCyst(where, which)
  
  
end
local function SealAirLock()

          for _, airlock in ientitylist(Shared.GetEntitiesWithClassname("AirLock")) do
             DestroyEntity(airlock)
          end

end

function Conductor:OnCreate() 
           if Server then
              self:AddTimedCallback(Conductor.PickMainRoom, 16)
              self:AddTimedCallback(Conductor.Automations, 8)
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
        CoordinateWithPowerNode(which.name)
        CreateAlienMarker(where)
        BreachAirLock(where, which)
        ForAllMarinesSendWP(where, which)
end
function Conductor:Automations()
              self:CollectResources()
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




