-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/


class 'Conductor' (Entity)
Conductor.kMapName = "conductor"



local networkVars = 

{
   payLoadTime = "float",
   phaseCannonTime = "float"
}

/*
local function AddPlayerResources(harvesters, extractors)
  --Settling with this cheap stuff for now to just see how it works without spending too much time on it
   for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do     
         local presamount = kPlayerResPerInterval 
         if player:GetTeamNumber() == 1 then
            player:AddResources(presamount * extractors)
         elseif player:GetTeamNumber() == 2 then
           player:AddResources(presamount * harvesters)
         end
    end
end
*/   
              
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

local function EntityIsaPowerPoint(nearestenemy)
 return nearestenemy:isa("PowerPoint") and nearestenemy:GetIsBuilt() and not nearestenemy:GetIsDisabled()
end
local function CreateAlienMarker(where)
  /*
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
      */
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
local function FindArcOrder(where)
          local neareststructure = GetNearestMixin(where, "Construct", 2, function(ent) return ent:GetIsSighted() and not ent:isa("Harvester") end)
         if neareststructure then
              return neareststructure:GetOrigin()
        end
        return nil
end
local function MoveArcs(where)
        for _, arc in ipairs(GetEntitiesWithinRange("MainRoomArc", where, 999)) do
           if arc:GetCanMove()  then
           arc.orderorigin = FindArcOrder(where)
           end
       end
       
end
local function FindMarineDefense(where)
          local nearesttodefend = GetNearestMixin(where, "Combat", 1, function(ent) return HasMixin(ent, "Construct") end)
         if nearesttodefend then
            local inCombat = (nearesttodefend.timeLastDamageDealt + 8 > Shared.GetTime()) or (nearesttodefend.lastTakenDamageTime + 8 > Shared.GetTime())
             if inCombat then 
                return nearesttodefend
              end
        end
        return nil
end
/*
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
              
           move =  FindMarineMove(where, which)
           if move ~= nil  then
                who:GiveOrder(kTechId.Move, nil, move, nil, true, true)
                return
           end

end
 */
local function DefendPayLoad(player, where, which)
         local payload = GetNearest(where, "ARC", 1)
         if payload then
         local range = 0
               range = player:GetDistance(payload)
               --Print("player to payload distance is %s", range)
               if range <= 32 and ( payload.deployMode ~= ARC.kDeployMode.Deployed  and not payload:InRadius() ) then
               player:GiveOrder(kTechId.Defend, payload:GetId(), payload:GetOrigin(), nil, true, true)
               return
               end
        end
        --SendTheMarineOrdersHere(player,where, which)
end
 local function ForAllMarinesSendWP(where, which)
          for _, player in ipairs(GetEntitiesWithinRange("Marine", where, 999)) do
           if player:GetIsAlive() and not player:isa("Commander") then
               DefendPayLoad(player, where, which)
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
              if king:GetIsMature() and not king.moving then
              
               if king:CheckTarget(toplace) then --prevent stuckage?
                 king:GiveOrder(kTechId.Move, nil, toplace, nil, true, true) 
                 else
                   king:SetOrigin(toplace)
                   end
                   
               king:MoveWhipAvoca(toplace)
               end
          else
              local KingCyst = CreateEntity(CystAvoca.kMapName, where, 2)
              KingCyst:SetConstructionComplete()
              KingCyst:SetInfestationRadius(0)
              king = KingCyst
          end
     else
--       Print("No spot found for king cyst!")
     end
       
      -- if king then Print("King Cyst located in %s", which.name) end

end

local function BuildAllNodes(self)

          for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
              powerpoint:SetConstructionComplete()
          end

end
function Conductor:OnRoundStart() 
           if Server then
              BuildAllNodes(self)
              self:SpawnInitialStructures()
              self:AutoBioMass()
              local CreateImagination = CreateEntity(Imaginator.kMapName)
              self:AddTimedCallback(Conductor.PickMainRoom, 16)
              self:AddTimedCallback(Conductor.Automations, 8)
              self:AddTimedCallback(Conductor.PayloadTimer, 1)
              self:AddTimedCallback(Conductor.PCTimer, 1)
            end
end
function Conductor:OnCreate() 
   if Server then
   self.payLoadTime = 600
   self.phaseCannonTime = 120
   end
end
function Conductor:GetIsMapEntity()
return true
end
function Conductor:GetPayloadLength()
 return self.payLoadTime
end
function Conductor:GetTimeLeftTillPC()
 return self.phaseCannonTime
end
function Conductor:PickMainRoom()
       --Print("Picking main room")
       local location = self:GetLocationWithMostMixedPlayers()
       if not location then return true end
       self:SetMainRoom(location:GetOrigin(), location) 
       --self:OnPickMainRoom(location)
       return true
end
function Conductor:SetMainRoom(where, which)
        CoordinateWithPowerNode(which.name)
        if not self:GetCanVape() then CreateAlienMarker(where) end
        ForAllMarinesSendWP(where, which)
        FindOrCreateKingCyst(where, which)
end
local function SuddenDeathConditionsCheck(self)
          local arc = GetPayLoadArc()
          
          if arc and arc:GetInAttackMode() then return true end
          
          return false
end
local function RanOutOfWeed()
            for _, vaporizer in ientitylist(Shared.GetEntitiesWithClassname("Vaporizer")) do
                    if vaporizer then DestroyEntity(vaporizer) end
             end
end
function Conductor:GetCanVape()
           local gamestarttime = GetGamerules():GetGameStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.payLoadTime
end
function Conductor:GetCanFire()
           local gamestarttime = GetGamerules():GetGameStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.phaseCannonTime
end
function Conductor:ResetPC()
self.phaseCannonTime = self.phaseCannonTime + 120 + 5
self:AddTimedCallback(Conductor.PCTimer, 1)
return false
end
local function FirePCAllBuiltRooms(self)
                 for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                   if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then
                     self:FirePhaseCannons(powerpoint, force)
                    end
                end
                
end
function Conductor:PayloadTimer()

   local boolean = false
       if  self:GetCanVape() then
                  boolean = true
             if not SuddenDeathConditionsCheck(self) then
               --GetGamerules():SetGameState(kGameState.Team2Won)
                RanOutOfWeed()
             else
               AddPayLoadTime(8)
             end
       end
       return not boolean
       
end
function Conductor:PCTimer()
   local boolean = false
    if self:GetCanFire() then
         boolean = true
         FirePCAllBuiltRooms(self) -- Ddos!
         self:AddTimedCallback(Conductor.ResetPC, 4)
       end
       
       return not boolean
end
function Conductor:AddTime(seconds)
  self.payLoadTime = self.payLoadTime + seconds
end
function Conductor:SendNotification(who, seconds)
--replace with shine plugin avocagamerules
end
function Conductor:Automations()

              self:CollectResources()
              self:MaintainHiveDefense()
              self:HandoutMarineBuffs()
              self:CheckAndMaybeBuildMac()
              return true
end
if Server then 
function Conductor:CollectResources()
   local harvesters = Clamp(SimpleCClass(string.format("Harvester"), true) or 0, 1, 14)
   local extractors =  Clamp(SimpleCClass(string.format("Extractor"), true) or 0, 1, 14)
   
   if harvesters <=1 then   GetGamerules():GetTeam2():AddTeamResources(math.random(4,8)) end
   if extractors <=1 then    GetGamerules():GetTeam1():AddTeamResources(math.random(4,8))  end
   
   --AddPlayerResources(harvesters, extractors)

end
end

function Conductor:GetLocationWithMostMixedPlayers()
-- works good 2.15
--so far v1.23 shows this works okay except for picking empty res rooms for some reason -.-
//Print("GetLocationWithMostMixedPlayers")

            for _, mainent in ientitylist(Shared.GetEntitiesWithClassname("CommandStructure")) do
                    if mainent:GetIsInCombat() then return mainent end
             end
             
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
     local nearest = GetNearest(neutralavgorigin, "Location", nil, function(ent) local powerpoint = GetPowerPointForLocation(ent.name) return powerpoint ~= nil end)
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




