--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"

local function SpawnSurgeForEach(where)
  
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation:GetName() or ""
           if not wherelocation then return end
           
     for _, eligable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct", 2, where, 72)) do
         if not eligable:isa("Harvester") and not eligable:isa("Cyst") and not eligable:isa("Hive") then --and not GetIsPointInMarineBase(eligable:GetOrigin()) then
           local location = GetLocationForPoint(eligable:GetOrigin())
           local locationName = location and location:GetName() or ""
           local sameLocation = locationName == wherelocation
          if sameLocation then 
                eligable:DeductHealth(400, nil, nil, false, false, true)
                eligable:TriggerEffects("arc_hit_primary")
                eligable:TriggerEffects("arc_hit_secondary")
          end --
         end
     end--
     
end

Shine.Hook.SetupClassHook( "PlayingTeam", "GetCommander", "OnGetCommander", "Replace" )
Shine.Hook.SetupClassHook( "Conductor", "SendNotification", "OnSendNotification", "Replace" )
Shine.Hook.SetupClassHook( "PowerPoint", "OnConstructionComplete", "OnConstructionComplete", function( OldFunc, self )
		OldFunc( self )
         SpawnSurgeForEach(self:GetOrigin())
        local nearestHarvester = GetNearest(self:GetOrigin(), "Harvester", 2)
       if nearestHarvester then nearestHarvester:Kill() end
end )

function Plugin:NotifyPayloadTimer( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[PayloadTimer]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end

function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
return true
end

function Plugin:MapPostLoad()
      Server.CreateEntity(Conductor.kMapName)

end



function Plugin:CommLoginPlayer( Building, Player  )

     Player:Kill()
      
      
end

function Plugin:SetGameState( Gamerules, State, OldState )
           if State == kGameState.Countdown then
       self:SimpleTimer( 8, function() 
          for _, conductor in ientitylist(Shared.GetEntitiesWithClassname("Conductor")) do
             conductor:OnRoundStart()
             break
          end
       end)   
          end
end
function Plugin:OnSendNotification(seconds)
    local who = nil
    local entityList = Shared.GetEntitiesWithClassname("Conductor")
    if entityList:GetSize() > 0 then
               local conductor = entityList:GetEntityAtIndex(0)
                who = conductor
    end 
 self:NotifyGeneric( nil, "Timer extended by %s from %s to %s", true, seconds, who.payLoadTime, who.payLoadTime + seconds)
end
function Plugin:OnGetCommander()
    local players = GetEntitiesForTeam("Player", 1)
    if players and #players > 0 then
        return players[1]
    end    

    return nil
end
function Plugin:ClientConnect(client)
     --if client:GetUserId() == 22542592 then
     

     local team = math.random(1,2)
     self:SimpleTimer( 4, function() 
     if client then Shared.ConsoleCommand(string.format("sh_setteam %s %s", client:GetUserId(), team )) end
      end)

   --  end
    if not client:GetIsVirtual() and not GetGamerules():GetGameStarted() then
    
          -- for i = 1, 7 do
          -- Shared.ConsoleCommand("addbot")
          -- end
           
          GetGamerules():SetMaxBots(12, false)
           Shared.ConsoleCommand("sh_randomrr")
          GetGamerules():SetGameState(kGameState.Countdown)
          GetGamerules().countdownTime = 4
    end
end
function Plugin:CreateCommands()


end