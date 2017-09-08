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
function Conductor:ResetLight()
if not self.powerlighth then return false end 
self.powerlighth:RestoreColorDerp()
return false
end        
   
function Conductor:CoordinateWithPowerNode(locationname)
self.powerlighth = nil
                 local powernode = GetPowerPointForLocation(locationname)
                    if powernode and powernode:GetIsBuilt() and powernode.lightHandler then
                    self.powerlighth = powernode.lightHandler
                     self.powerlighth:DiscoLights()
                    self:AddTimedCallback( Conductor.ResetLight, math.random(8, 16) )
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
local function DefendPayLoad(player, where)
         local payload = GetNearest(where, "ARC", 1, function(ent) return not ent:isa("BigArc") end)
         if payload then
               player:GiveOrder(kTechId.Defend, payload:GetId(), payload:GetOrigin(), nil, true, true)
               return
        end
end
 local function ForSingleMarineDefendArc(who,where)
           if who and who:GetIsAlive() and not who:isa("Commander") then
               DefendPayLoad(who, who:GetOrigin())
           end
end
local function BuildDisabledPower(player, where)
         local powerpoint = GetNearest(where, "PowerPoint", 1, function(ent) return ent:GetIsDisabled() end)
         if powerpoint then
               player:GiveOrder(kTechId.Build, powerpoint:GetId(), powerpoint:GetOrigin(), nil, true, true)
               return
        else 
             ForSingleMarineDefendArc(who,where)
        end
end
 local function ForAllMarinesDefendArc(where)
          for _, player in ipairs(GetEntitiesWithinRange("Marine", where, 999)) do
           if player:GetIsAlive() and not player:isa("Commander") then
               DefendPayLoad(player, player:GetOrigin())
           end
         end
end
 local function ForAllMarinesBuildPower(where)
          for _, player in ipairs(GetEntitiesWithinRange("Marine", where, 999)) do
           if player:GetIsAlive() and not player:isa("Commander") then
               BuildDisabledPower(player, player:GetOrigin())
           end
         end
end
local function SendMarineOrders(where)
   local random = math.random(1,2)
   if random == 1 then
    ForAllMarinesDefendArc(where)
   elseif random == 2 then
     ForAllMarinesBuildPower(where)
   end
end
/*

local function FindOrCreateKingCyst(where, which, opcyst)
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
          
             -- if not king.moving then
                   if king:CheckTarget(toplace) then
                      king:GiveOrder(kTechId.Move, nil, toplace, nil, true, true) 
                      king:MoveWhipAvoca(toplace)
                  else
                       king:SetOrigin(toplace)
                        king:TeleportWhipAvoca(toplace)
                   end
                   
                   if opcyst then king:AdjustMaxHealth(8191) king:AdjustMaxArmor(2045) end
              -- end
               
          else
              local KingCyst = CreateEntity(CystAvoca.kMapName, where, 2)
              KingCyst:SetConstructionComplete()
              KingCyst:SetInfestationRadius(0)
              king = KingCyst
             if opcyst then king:AdjustMaxHealth(8191) king:AdjustMaxArmor(2045) end
          end
     else
--       Print("No spot found for king cyst!")
     end
       
      -- if king then Print("King Cyst located in %s", which.name) end

end

*/

local function BuildAllNodes(self)

          for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
             powerpoint:SetConstructionComplete() 
             local where = powerpoint:GetOrigin()
               if powerpoint:GetIsBuilt() and powerpoint.lightHandler then  powerpoint.lightHandler:SimpleLights() end
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

/*

local function SetupBaseDefense(self)

          for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
                if GetIsPointInMarineBase(location:GetOrigin()) then
                 location:InitiateDefense()
               end
          end

end

*/

function Conductor:OnRoundStart() 

           if Server then
              BuildAllNodes(self)
              DeleteResNodes(self)
            --  SetupBaseDefense(self)
              self:SpawnInitialStructures()
              local CreateImagination = CreateEntity(Imaginator.kMapName)
              local CreateResearcher = CreateEntity(Researcher.kMapName)
              self:AddTimedCallback(Conductor.PickMainRoom, 16)
              self:AddTimedCallback(Conductor.Automations, 8)
              self:AddTimedCallback(Conductor.PayloadTimer, 1)
              self:AddTimedCallback(Conductor.PCTimer, 1)
            end
end
function Conductor:OnCreate() 
   if Server then
   self.payLoadTime = 999
   self.phaseCannonTime = 30
   self.powerlighth = nil
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
local function SetMarineBaseAsMain(self)
    local chair = nil
         for _, mainent in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
                    if mainent:GetIsAlive() then chair = mainent break end
             end
               if chair then
                    local ccwhere = chair:GetOrigin()
                    self:SetMainRoom(ccwhere, GetLocationForPoint(ccwhere), true)
               end
end
function Conductor:PickMainRoom()
       --Print("Picking main room")
       if self:CounterComplete() then
             SetMarineBaseAsMain(self)
      else
       local location = self:GetLocationWithMostMixedPlayers()
       if not location then return true end
       self:SetMainRoom(location:GetOrigin(), location, opcyst) 
       --self:OnPickMainRoom(location)
        end
       return true
end
function Conductor:SetMainRoom(where, which, opcyst)
        if Server then MoveArcs(where) end 
        self:CoordinateWithPowerNode(which.name)
        CreateAlienMarker(where) 
        SendMarineOrders(where)
       -- FindOrCreateKingCyst(where, which, opcyst)
end
local function SuddenDeathConditionsCheck(self)
          local arc = GetPayLoadArc()
          
          if arc and arc:GetInAttackMode() then return true end
          
          return false
end
function Conductor:CounterComplete()
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
--16 seconds for each built node
self.phaseCannonTime = Shared.GetTime() + 15 --Clamp(16*self:CountUnBuiltNodes(), 45, 180)--+ 120
self:AddTimedCallback(Conductor.PCTimer, 1)
local built = {}
local unbuilt = 0
return false
end


local function FirePCAllBuiltRooms(self)
local built = {}
                 for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                   if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then
                      table.insert(built, powerpoint)
                    end
                end
                if #built == 0 then return end
                local random = table.random(built)
                 self:FirePhaseCannons(random)
end



local function DisableVaporizer()
            for _, vaporizer in ientitylist(Shared.GetEntitiesWithClassname("Vaporizer")) do
                    if vaporizer then DestroyEntity(vaporizer) end
             end
end
function Conductor:PayloadTimer()

   local boolean = false
       if  self:CounterComplete() then
                  boolean = true
             if not SuddenDeathConditionsCheck(self) then
               --GetGamerules():SetGameState(kGameState.Team2Won)
               DisableVaporizer()
               self.payLoadTime = 0
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
         self.phaseCannonTime = 0
         self:AddTimedCallback(Conductor.ResetPC, 8)
       end
       
       return not boolean
end
function Conductor:AddTime(seconds)
  if not self:CounterComplete() then self.payLoadTime = self.payLoadTime + seconds end
end
function Conductor:SendNotification(who, seconds)
--replace with shine plugin avocagamerules
end
function Conductor:Automations()

              self:CollectResources()
              self:MaintainHiveDefense()
              self:HandoutMarineBuffs()
            --  self:CheckAndMaybeBuildMac()
              return true
end





if Server then 



function Conductor:CollectResources()
   local builtpower = 0
   local disabledpower = 0
   local marineteam = nil
   local alienteam = nil
   
          for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
            if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then
               builtpower = builtpower + 1
            else
               disabledpower = disabledpower + 1
            end
        end
   
       for _, player in ipairs(GetEntitiesForTeam("Player", 1)) do
        if not player:isa("Commander") then
            player:AddResources(builtpower / 10 ) 
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




