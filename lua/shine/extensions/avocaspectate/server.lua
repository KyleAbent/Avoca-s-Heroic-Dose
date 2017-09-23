--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin


Shine.Hook.SetupClassHook( "AvocaSpectator", "ChangeView", "OnChangeView", "PassivePre" )

Plugin.Version = "1.0"


local function AutoSpectate(self, client)

    Shine.Timer.Create( "AutoSpectate", 8, -1, function() if client and client:isa("AvocaSpectator") then self:OnChangeView(client) else Shine.Timer.Destroy("AutoSpectate") end  end )
end


function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()
return true
end
function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Director]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifySand( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Director]",  255, 0, 0, String, Format, ... )
end
local function GetPregameView()
local choices = {}
 
              
                   for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                  if player ~= self and not player:isa("Spectator")  and not player:isa("ReadyRoomPlayer")  and not player:isa("Commander") and player:GetIsOnGround() then table.insert(choices, player) break end
              end 
            
              local random = table.random(choices)
              return random
              

end
local function GetLocationWithMostMixedPlayers()

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
     local nearest = GetNearestMixin(neutralavgorigin, "Combat", nil, function(ent)  return ent:isa("Player") and ent:GetIsInCombat() end)
    if nearest then
   // Print("nearest is %s", nearest.name)
        return nearest
    end

end
local function GetIsBusy(who)
  local order = who:GetCurrentOrder()
local busy = false
   if order then
   busy = true
   end
  -- if who:isa("MAC") then
 --  elseif who:isa("Drifter") then
   -- end
return busy
end
local function GetViewOne()


if not GetGamerules():GetGameStarted() then return GetPregameView() end

local choices = {}
--arc if moving or in siege
--contam
--commandstructure if in combat
--alive power node in combat
--egg or structure beacon
local interesting = GetLocationWithMostMixedPlayers()
if interesting ~= nil then table.insert(choices,interesting) end
           

              for index, shadeink in ientitylist(Shared.GetEntitiesWithClassname("ShadeInk")) do
                   table.insert(choices, shadeink)
              end     
    
           --   for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
            --      if GetIsBusy(mac) then table.insert(choices, mac) break end 
            --  end     
              
               for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                      if arc.mode == ARC.kMode.Moving then table.insert(choices, arc) end
              end 
             for index, contam in ientitylist(Shared.GetEntitiesWithClassname("Contamination")) do
                  table.insert(choices, contam) 
                   break  -- just 1xx
              end 
             for index, cs in ientitylist(Shared.GetEntitiesWithClassname("CommandStructure")) do
                  if cs:GetIsInCombat() then table.insert(choices, cs) break end
              end 
                   for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do
                  if not construct:isa("Hydra") and construct:GetIsAlive() and construct:GetHealthScalar() <= .5 and construct:GetIsInCombat() then table.insert(choices, construct) break end --built and not disabled should be summed up by if in combat?
              end  

              
          --   for index, alienbeacon in ientitylist(Shared.GetEntitiesWithClassname("AlienBeacon")) do
           --       if alienbeacon:GetIsAlive() then table.insert(choices, alienbeacon) break end --built and not disabled should be summed up by if in combat?
         --     end   
              
              local random = table.random(choices)
              return random
end
 local function GetViewTwo()

local choices = {}
local interesting = GetLocationWithMostMixedPlayers()
if interesting ~= nil then table.insert(choices,interesting) end
             
 
             for index, obs in ientitylist(Shared.GetEntitiesWithClassname("Observatory")) do
                  if obs:GetIsBeaconing() or obs:GetIsAdvancedBeaconing() then table.insert(choices, obs) break end --built and not disabled should be summed up by if in combat?
              end  
              
             for index, breakabledoor in ientitylist(Shared.GetEntitiesWithClassname("BreakableDoor")) do
              if breakabledoor:GetHealthScalar() <= .7 and not breakabledoor:GetHealth() == 0 and  breakabledoor:GetIsInCombat() then
                     local player =  GetNearest(breakabledoor:GetOrigin(), "Player", nil, function(ent) return self ~= player and not ent:isa("ReadyRoomPlayer") and not ent:isa("Commander") and ent ~= self end)
                     if player then
                     table.insert(choices, player) 
                     break  -- just 1
                     end
                end
              end  
      
             for index, contam in ientitylist(Shared.GetEntitiesWithClassname("Contamination")) do
                  table.insert(choices, contam) 
                   break  -- just 1
              end
        
                   for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do
                  if construct:GetIsBuilt() and construct:GetHealthScalar() <= .3 and construct:GetIsInCombat() then table.insert(choices, construct) break end --built and not disabled should be summed up by if in combat?
              end     

             --for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
              --   local order = arc:GetCurrentOrder()
               --   if order then
                -- if order:GetType() == kTechId.Move then table.insert(choices, arc) break end -- just 1
                 --end
              --end          
              
              
              local random = table.random(choices)
              return random

end
local function GetViewThree()
local choices = {}    
       
                      for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                    local order = arc:GetCurrentOrder()
                      if order then 
                 if order:GetType() == kTechId.Move then table.insert(choices, arc) break end -- just 1
                     end
              end 
              
             for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                  if GetIsBusy(mac) then table.insert(choices, mac) break end 
              end   
         /*  
             for index, cyst in ientitylist(Shared.GetEntitiesWithClassname("Cyst")) do
                  if not cyst:GetIsBuilt() then table.insert(choices, cyst) break end 
              end
      */
  
             for index, drifter in ientitylist(Shared.GetEntitiesWithClassname("Drifter")) do
                  if GetIsBusy(drifter) then table.insert(choices, drifter) break end 
              end    
                   for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do
                  if not construct:isa("PowerPoint") and not GetIsInSiege(construct) and not construct:GetIsBuilt() 
                  then table.insert(choices, construct) 
                 --  break
                   end --built and not disabled should be summed up by if in combat?
              end    
              
              local random = table.random(choices)
              return random

end
local function GetLocationName(who)
        local location = GetLocationForPoint(who:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
local function FindEntNear(where)
                  local entity =  GetNearestMixin(where, "Combat", nil, function(ent) return ent:GetIsInCombat() and not ent:isa("Commander") end)
                    if entity then
                    return FindFreeSpace(entity:GetOrigin())
            end
            return where
end


local function SandNearby(self, client)

if not GetGamerules():GetGameStarted()  then return end

   for _, player in ipairs(GetEntitiesWithinRange("Player", client:GetOrigin(), 4)) do
    local  userid = player:GetClient():GetUserId()
        if player ~= client and userid ~= nil then
         Shared.ConsoleCommand(string.format("sh_addSand %s 0.1 false true", userid ) )
         self:NotifySand( player, "You have been visited!!!!", true ) 
         end
  
   end
  
end
local function SandChosen(self, client, rank)

if not GetGamerules():GetGameStarted()  then return end

    local userid = client.GetUserId and client:GetUserId()
        if userid ~= nil then
         local addamt = rank / 10
         Shared.ConsoleCommand(string.format("sh_addSand %s %s false true", userid, addamt ) )
         self:NotifySand( client:GetControllingPlayer(), "Your rank of score is currently # %s (+ %s Sand)", rank, addamt, true )  
         end
  
  
end
local function SwitchToOverHead(client, self, where)
        client:BreakChains()
        local height = math.random(4,12)
        self:NotifyGeneric( client, "Overhead mode nearby otherwise inside entity origin. Height is %s", true, height)
        if client.specMode ~= kSpectatorMode.Overhead  then client:SetSpectatorMode(kSpectatorMode.Overhead)  end
        client:SetOrigin(where)
        client.overheadModeHeight =  height

end
local function overHeadandNear(self, client, vip)
          client:SetDesiredCameraDistance(0)
        -- Print("vip is %s", vip:GetClassName())
          if client:GetSpectatorMode() ~= kSpectatorMode.FreeLook then client:SetSpectatorMode(kSpectatorMode.FreeLook)  end
          local viporigin = vip:GetOrigin()
          local findfreespace = FindFreeSpace(viporigin, 1, 8)
          if findfreespace == viporigin then findfreespace.x = findfreespace.x - 2 return end
              client:SetOrigin(findfreespace)
             local dir = GetNormalizedVector(viporigin - client:GetOrigin())
             local angles = Angles(GetPitchFromVector(dir), GetYawFromVector(dir), 0)
             client:SetOffsetAngles(angles)
             client:SetLockOnTarget(vip:GetId())
             //Sixteenth notes within eigth notes which is the other untilNext
             
             self:NotifyGeneric( client, "VIP is %s, location is %s", true, vip:GetClassName(), GetLocationName(client) )
end
local function firstPersonScoreBased(self, client)

    client:BreakChains()
    function sortByScore(ent1, ent2)
        return ent1:GetScore() > ent2:GetScore()
    end
    
    local tableof = {}
                for _, scorer in ipairs(GetEntitiesWithMixin("Scoring")) do
                 if not scorer:isa("ReadyRoomPlayer") and not scorer:isa("Commander") and scorer:GetIsAlive() then table.insert(tableof, scorer) end
              end  
    if table.count(tableof) == 0 then return end
    local max = Clamp(table.count(tableof), 1, 4)
    table.sort(tableof, sortByScore)
    local entrant = math.random(1,max)
    local topscorer = tableof[entrant]
    if not topscorer then return end
    if client:GetSpectatorMode() ~= kSpectatorMode.FirstPerson then client:SetSpectatorMode(kSpectatorMode.FirstPerson)  end
    Server.GetOwner(client):SetSpectatingPlayer(topscorer)
    SandChosen(self, topscorer, entrant)
    self:NotifyGeneric( client, "(First person) VIP is %s, # rank in score is %s", true, topscorer:GetName(), entrant )
end
 function Plugin:OnChangeView(client, untilNext, betweenLast)
 -- Print("ChangeView")
      -- client.SendNetworkMessage("SwitchFromFirstPersonSpectate", { mode = kSpectatorMode.Following })
        
        if not client then return end
       local vip = nil
       local random = math.random(1,3)
    
        if random == 1 then
           vip = GetViewOne()
        elseif random == 2 then
           vip = GetViewTwo()
        else
           vip = GetViewThree()
        end
       
        if vip ~= nil then 
            //  local roll = math.random(1,2)
            // if roll == 1 then
              overHeadandNear(self, client, vip)
            // elseif roll == 2 then
            //  firstPersonScoreBased(self, client)
            //  end
        else
        firstPersonScoreBased(self, client)
         end
  
         Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.75,Text = "[Director] untilNext: %s",Duration = betweenLast or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, client )  

end




function Plugin:CreateCommands()



local function Direct( Client, Targets )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
          Player:Replace(AvocaSpectator.kMapName)
          AutoSpectate(self, Client)
     end
end

local DirectCommand = self:BindCommand( "sh_direct", "direct", Direct)
DirectCommand:AddParam{ Type = "clients" }



end