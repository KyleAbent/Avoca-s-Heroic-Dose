--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"

local OldUpdGestation

local function NewHpdateGestation(self)
    // Cannot spawn unless alive.
    if self:GetIsAlive() and self.gestationClass ~= nil then
    
        if not self.gestateEffectsTriggered then
        
            self:TriggerEffects("player_start_gestate")
            self.gestateEffectsTriggered = true
            
        end
        
        // Take into account catalyst effects
        local kUpdateGestationTime = 0.1
        local amount = GetAlienCatalystTimeAmount(kUpdateGestationTime, self)
        self.evolveTime = self.evolveTime + kUpdateGestationTime + amount
        
        self.evolvePercentage = Clamp((self.evolveTime / self.gestationTime) * 100, 0, 100)
        
        if self.evolveTime >= self.gestationTime then
        
            // Replace player with new player
            local newPlayer = self:Replace(self.gestationClass)
            newPlayer:SetCameraDistance(0)

            local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
            local newAlienExtents = LookupTechData(newPlayer:GetTechId(), kTechDataMaxExtents)

            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
            
            --validate the spawn point before using it
            if self.validSpawnPoint and GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, self.validSpawnPoint + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterTwo(self, newPlayer)) then
                newPlayer:SetOrigin(self.validSpawnPoint)
            else
                for index = 1, 100 do

                    local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))

                    if spawnPoint then

                        newPlayer:SetOrigin(spawnPoint)
                        break

                    end

                end

            end

            newPlayer:DropToFloor()
            
            self:TriggerEffects("player_end_gestate")
            
            // Now give new player all the upgrades they purchased
            local upgradesGiven = 0
            
            for index, upgradeId in ipairs(self.evolvingUpgrades) do

                if newPlayer:GiveUpgrade(upgradeId) then
                    upgradesGiven = upgradesGiven + 1
                end
                
            end
            
            local healthScalar = self.storedHealthScalar or 1
            local armorScalar = self.storedArmorScalar or 1

            newPlayer:SetHealth(healthScalar * LookupTechData(self.gestationTypeTechId, kTechDataMaxHealth))
            newPlayer:SetArmor(armorScalar * LookupTechData(self.gestationTypeTechId, kTechDataMaxArmor))
           if  newPlayer.OnGestationComplete then newPlayer:OnGestationComplete() end
            newPlayer:SetHatched()
            newPlayer:TriggerEffects("egg_death")
           
            
           if  GetHasRebirthUpgrade(newPlayer) then
               if self.triggeredrebirth then
                  newPlayer:SetHealth(newPlayer:GetHealth() * 0.7)
                  newPlayer:SetArmor(newPlayer:GetArmor() * 0.7)
               end
          newPlayer:TriggerRebirthCountDown(newPlayer:GetClient():GetControllingPlayer())
          newPlayer.lastredeemorrebirthtime = Shared.GetTime()
           end
          


        if GetHasRedemptionUpgrade(newPlayer) then
          newPlayer:TriggerRedeemCountDown(newPlayer:GetClient():GetControllingPlayer())
          newPlayer.lastredeemorrebirthtime = Shared.GetTime()
         end
            
            if self.resOnGestationComplete then
                newPlayer:AddResources(self.resOnGestationComplete)
            end
            
            local newUpgrades = newPlayer:GetUpgrades()
            if #newUpgrades > 0 then            
                newPlayer.lastUpgradeList = newPlayer:GetUpgrades()
            end

            // Notify team

            local team = self:GetTeam()

            if team and team.OnEvolved then

                team:OnEvolved(newPlayer:GetTechId())

                for _, upgradeId in ipairs(self.evolvingUpgrades) do

                    if team.OnEvolved then
                        team:OnEvolved(upgradeId)
                    end
                    
                end

            end
            
            // Return false so that we don't get called again if the server time step
            // was larger than the callback interval
            return false
            
        end
        
    end
    
    return true

end

OldUpdGestation = Shine.Hook.ReplaceLocalFunction( Embryo.OnInitialized, "UpdateGestation", NewHpdateGestation )


Shine.Hook.SetupClassHook( "Alien", "TriggerRedeemCountDown", "OnRedemedHook", "PassivePre" )
Shine.Hook.SetupClassHook( "Alien", "TriggerRebirthCountDown", "TriggerRebirthCountDown", "PassivePre" )

  function Plugin:OnRedemedHook(player) 
            local herp = player:GetClient()
            local derp = herp:GetControllingPlayer()
            Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.90,Text = "Redemption Cooldown: %s",Duration = derp:GetRedemptionCoolDown() or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, player ) 
 end

 function Plugin:TriggerRebirthCountDown(player)
            local herp = player:GetClient()
            local derp = herp:GetControllingPlayer()
            Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.90,Text = "Rebirth Cooldown: %s",Duration = ( derp:GetRedemptionCoolDown() * 1.3 ) or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, player ) 
end


local OldSmashNearbyEggs

local function HeroicSmash(self)

    assert(Server)
    
    
        local nearbyEggs = GetEntitiesWithinRange("Egg", self:GetOrigin(), kSmashEggRange)
        for e = 1, #nearbyEggs do
            nearbyEggs[e]:Kill(self, self, self:GetOrigin(), Vector(0, -1, 0))
        end
        
        local nearbyEmbryos = GetEntitiesWithinRange("Embryo", self:GetOrigin(), kSmashEggRange)
        for e = 1, #nearbyEmbryos do
            nearbyEmbryos[e]:Kill(self, self, self:GetOrigin(), Vector(0, -1, 0))
        end
    if GetConductor():GetIsPhaseTwoBoolean() then
        local nearbySpurs = GetEntitiesWithinRange("Spur", self:GetOrigin(), kSmashEggRange)
        for e = 1, #nearbySpurs do
            nearbySpurs[e]:Kill(self, self, self:GetOrigin(), Vector(0, -1, 0))
        end
        
        local nearbyVeils = GetEntitiesWithinRange("Veil", self:GetOrigin(), kSmashEggRange)
        for e = 1, #nearbyVeils do
            nearbyVeils[e]:Kill(self, self, self:GetOrigin(), Vector(0, -1, 0))
        end
        
        local nearbyShells = GetEntitiesWithinRange("Shell", self:GetOrigin(), kSmashEggRange)
        for e = 1, #nearbyShells do
            nearbyShells[e]:Kill(self, self, self:GetOrigin(), Vector(0, -1, 0))
        end
        
     end // p2  
    
    -- Keep on killing those nasty eggs forever.
    return true
    
end

OldSmashNearbyEggs = Shine.Hook.ReplaceLocalFunction( Exo.OnCreate, "SmashNearbyEggs", HeroicSmash )

Shine.Hook.SetupClassHook( "PlayingTeam", "GetCommander", "OnGetCommander", "Replace" )

Shine.Hook.SetupClassHook( "Conductor", "TriggerPhaseTwo", "OnTriggerPhaseTwo", "PassivePost" )

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
    Shine.ScreenText.Add( 1, {X = 0.01, Y = 0.39,Text = "Phase One: %s",Duration = OneLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 1,FadeIn = 0,}, Client )
end


local function AddPhaseTwoTimer(who)
    local Client = who
    local NowToTwo = GetConductor():GetPhaseTwoLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local TwoLength =  math.ceil( Shared.GetTime() + NowToTwo - Shared.GetTime() )
    Shine.ScreenText.Add( 2, {X = 0.01, Y = 0.44,Text = "Phase Two: %s",Duration = TwoLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 1,FadeIn = 0,}, Client )
end


local function AddPhaseThreeTimer(who)
    local Client = who
    local NowToThree = GetConductor():GetPhaseThreeLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local ThreeLength =  math.ceil( Shared.GetTime() + NowToThree - Shared.GetTime() )
    Shine.ScreenText.Add( 3, {X = 0.01, Y = 0.49,Text = "Phase Three: %s",Duration = ThreeLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 1,FadeIn = 0,}, Client )
end


local function AddPhaseFourTimer(who)
    local Client = who
    local NowToFour = GetConductor():GetPhaseFourLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local FourLength =  math.ceil( Shared.GetTime() + NowToFour - Shared.GetTime() )
    Shine.ScreenText.Add( 4, {X = 0.01, Y = 0.54,Text = "Phase Four: %s",Duration = NowToFour,R = 255, G = 255, B = 255,Alignment = 0,Size = 1,FadeIn = 0,}, Client )
end


local function GiveTimersToAll()
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  AddPhaseOneTimer(Player)
                  AddPhaseTwoTimer(Player)
                  AddPhaseThreeTimer(Player)
                  AddPhaseFourTimer(Player)
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
          GetGamerules():SetMaxBots(14, false)
           Shared.ConsoleCommand("sh_randomrr")
           Shared.ConsoleCommand("sh_forceroundstart")

          end)
    end
    
     if client:GetIsVirtual() then return end
     
     if GetGamerules():GetGameStarted() then
         
   -- if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kPhaseOneTimer then
       AddPhaseOneTimer(client)
   --  end
    
   -- if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kPhaseTwoTimer then
         AddPhaseTwoTimer(client)
   --end
     AddPhaseThreeTimer(client)
     AddPhaseFourTimer(client)
   
   end
      
end


function Plugin:CreateCommands()





end