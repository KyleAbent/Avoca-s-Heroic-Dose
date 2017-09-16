--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"


Shine.Hook.SetupClassHook( "PlayingTeam", "GetCommander", "OnGetCommander", "Replace" )

Shine.Hook.SetupClassHook( "Conductor", "TriggerPhaseTwo", "OnTriggerPhaseTwo", "Replace" )

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
      Server.CreateEntity(Imaginator.kMapName)
end

local function AddPhaseOneTimer(who)
    local Client = who
    local NowToOne = GetConductor():GetPhaseOneLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local OneLength =  math.ceil( Shared.GetTime() + NowToOne - Shared.GetTime() )
    Shine.ScreenText.Add( 1, {X = 0.40, Y = 0.85,Text = "Phase One: %s",Duration = OneLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end


local function AddPhaseTwoTimer(who)
    local Client = who
    local NowToTwo = GetConductor():GetPhaseTwoLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local TwoLength =  math.ceil( Shared.GetTime() + NowToTwo - Shared.GetTime() )
    local ycoord = ConditionalValue(who:isa("Spectator"), 0.85, 0.95)
    Shine.ScreenText.Add( 2, {X = 0.40, Y = ycoord,Text = "Phase Two: %s",Duration = TwoLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end


local function AddPhaseThreeTimer(who)
    local Client = who
    local NowToThree = GetConductor():GetPhaseThreeLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local ThreeLength =  math.ceil( Shared.GetTime() + NowToThree - Shared.GetTime() )
    Shine.ScreenText.Add( 1, {X = 0.40, Y = 0.85,Text = "Phase Three: %s",Duration = ThreeLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end


local function AddPhaseFourTimer(who)
    local Client = who
    local NowToFour = GetConductor():GetPhaseFourLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local FourLength =  math.ceil( Shared.GetTime() + NowToFour - Shared.GetTime() )
    local ycoord = ConditionalValue(who:isa("Spectator"), 0.85, 0.95)
    Shine.ScreenText.Add( 2, {X = 0.40, Y = ycoord,Text = "Phase Four: %s",Duration = NowToFour,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end


local function GiveTimersToAll()
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  AddPhaseOneTimer(Player)
                  AddPhaseTwoTimer(Player)
                  end
              end
end

local function GiveThirdFourthTimersToAll() --Gotta do onjoin for those who join after. 
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  AddPhaseThreeTimer(Player)
                  AddPhaseFourTimer(Player)
                  end
              end
end

function Plugin:OnTriggerPhaseTwo()
   Print("Shine OnTriggerPhaseTwo")
   GiveThirdFourthTimersToAll()
end

function Plugin:SetGameState( Gamerules, State, OldState )
           if State == kGameState.Started then
                for _, conductor in ientitylist(Shared.GetEntitiesWithClassname("Conductor")) do
               conductor:OnRoundStart()
               break
               end
          end
          
          
     if State == kGameState.Started then 
       GiveTimersToAll()
      else
     Shine.ScreenText.End(1) 
      Shine.ScreenText.End(2)
      Shine.ScreenText.End(3)                   
      end 
        
          
          
end
function Plugin:OnGetCommander()
    local players = GetEntitiesForTeam("Player", 1)
    if players and #players > 0 then
        return players[1]
    end    

    return nil
end




function Plugin:ClientConfirmConnect(client)
     --if client:GetUserId() == 22542592 then
     

     local team = math.random(1,2)
   --  self:SimpleTimer( 4, function() 
     if client then Shared.ConsoleCommand(string.format("sh_setteam %s %s", client:GetUserId(), team )) end
    --  end)

   --  end
    if not client:GetIsVirtual() and not GetGamerules():GetGameStarted() then
    
          -- for i = 1, 7 do
          -- Shared.ConsoleCommand("addbot")
          -- end
           self:SimpleTimer( 4, function() 
          GetGamerules():SetMaxBots(12, false)
           Shared.ConsoleCommand("sh_randomrr")
           Shared.ConsoleCommand("sh_forceroundstart")

          end)
    end
    
     if client:GetIsVirtual() then return end
     
     if GetGamerules():GetGameStarted() then
         
    if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kPhaseOneTimer then
       AddPhaseOneTimer(client)
     end
    
    if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kPhaseTwoTimer then
         AddPhaseTwoTimer(client)
   end
   
   end
      
end


function Plugin:CreateCommands()





end