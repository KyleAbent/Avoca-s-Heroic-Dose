/*Kyle Abent  
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb
*/
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"


Shine.Hook.SetupClassHook( "PlayingTeam", "GetCommander", "OnGetCommander", "Replace" )
Shine.Hook.SetupClassHook( "Conductor", "SendNotification", "OnSendNotification", "Replace" )

function Plugin:NotifyPayloadTimer( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[PayloadTimer]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end

function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
return true
end

function Plugin:OnSendNotification(seconds)
    local who = nil
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
    if not client:GetIsVirtual() and not GetGamerules():GetGameStarted() then
    
           for i = 1, 11 do
           Shared.ConsoleCommand("addbot")
           end
           
           Shared.ConsoleCommand("sh_randomrr")
          GetGamerules():SetGameState(kGameState.Countdown)
          GetGamerules().countdownTime = 4
    end
end
function Plugin:CreateCommands()


end