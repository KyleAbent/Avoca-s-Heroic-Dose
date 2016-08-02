Script.Load("lua/Overwrites/Convars.lua")
Script.Load("lua/Overwrites/CustomLightRules.lua")

if Server then
Script.Load("lua/Overwrites/AutoResearch.lua")
Script.Load("lua/Overwrites/EggSpawn.lua")
end




function CommandStructure:LoginPlayer(player,forced)
 return
end

function ScaleWithPlayerCount(value, numPlayers, scaleUp)

return 8 

end

function ConstructMixin:GetCanConstruct(constructor)

return self:isa("PowerPoint") or ( constructor and constructor:isa("MAC") )
    
end
/*
--or modification
function PowerConsumerMixin:GetIsPowered() 
    return self.powered or self.powerSurge or self:GetHasSentryBatteryInRadius()
end
function PowerConsumerMixin:GetHasSentryBatteryInRadius()
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), SentryBattery.kRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end
*/


--Control Point based marine construction based on player amount inside?

if Server then

--Whips do less damage with less health (slap atleast)

function Whip:SlapTarget(target)
    self:FaceTarget(target)
    -- where we hit
    local targetPoint = target:GetEngagementPoint()
    local attackOrigin = self:GetEyePos()
    local hitDirection = targetPoint - attackOrigin
    hitDirection:Normalize()
    -- fudge a bit - put the point of attack 0.5m short of the target
    local hitPosition = targetPoint - hitDirection * 0.5
    local damage = Whip.kDamage 
    local damage = not self:isa("PowerDrainer") and Clamp(damage * self:GetHealthScalar(), 1, damage) or Whip.kDamage * 0.3
    self:DoDamage(damage, target, hitPosition, hitDirection, nil, true)
    self:TriggerEffects("whip_attack")

end


local function GetIsPowered(where)
--By memory, didnt have to look this one up. Wrote it word for word too :P
  local location = GetLocationForPoint(where)
  local locationName = location and location.name or ""
  local powerpoint = GetPowerPointForLocation(locationName)
      if powerpoint then
         if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then 
         return true
         end
      end
    return false
end
function ConstructMixin:OnConstructUpdate(deltaTime)
        
    local effectTimeout = Shared.GetTime() - self.timeLastConstruct > 0.65
    self.underConstruction = not self:GetIsBuilt() and not effectTimeout
    
    if not self:GetIsBuilt() and not self:isa("PowerPoint")  then
    local canauto = false
      if GetIsAlienUnit(self) then
      canauto = not self.GetCanAutoBuild or self:GetCanAutoBuild()
      else --Because pressing e and building everything slows down the tempo wayy too much
         --and is not in sync with the fast gameplay that I have going on here.
         --maybe this will be better than ns2siege where i had dynamic build speed based on playercount & roundlength?
        local marines = GetEntitiesWithinRange("Marine", self:GetOrigin(), 4)
        local macs = GetEntitiesWithinRange("MAC", self:GetOrigin(), 4)
        if #marines >= 1 or #macs >= 1 then
        canauto = GetIsPowered(self:GetOrigin())
        end
      end
      
         if canauto then
            local multiplier = 1
            if GetIsAlienUnit(self) then
            multiplier = self.hasDrifterEnzyme and kDrifterBuildRate or kAutoBuildRate
            multiplier = multiplier * ( (HasMixin(self, "Catalyst") and self:GetIsCatalysted()) and kNutrientMistAutobuildMultiplier or 1 )
            else
           local marines = GetEntitiesWithinRange("Marine", self:GetOrigin(), 4)
           local macs = GetEntitiesWithinRange("MAC", self:GetOrigin(), 4)
           marines = Clamp(#marines, 1, 4)
           macs = Clamp(#macs, 1, 4)
           multiplier = 1 + (marines/4) * 1
           multiplier = 1 + (macs/4) * 1
            end
            self:Construct(deltaTime * multiplier)
        end --canauto
      end --notbuilt
    
    if self.timeDrifterConstructEnds then
        
        if self.timeDrifterConstructEnds <= Shared.GetTime() then
        
            self.hasDrifterEnzyme = false
            self.timeDrifterConstructEnds = nil
            
        end
        
    end

    -- respect the cheat here; sometimes the cheat breaks due to things relying on it NOT being built until after a frame
    if GetGamerules():GetAutobuild() then
        self:SetConstructionComplete()
    end
    
    if self.underConstruction or not self.constructionComplete then
        return kUpdateIntervalFull
    end
    
    -- stop running once we are fully constructed
    return false
    
end


 function NS2Gamerules:OnUpdate(timePassed)
    
        PROFILE("NS2Gamerules:OnUpdate")
        
        GetEffectManager():OnUpdate(timePassed)
        
        if Server then
            
            if self.justCreated then
            
                if not self.gameStarted then
                    self:ResetGame()
                end
                
                self.justCreated = false
                
            end
            
            if self:GetMapLoaded() then
            
                self:CheckGameStart()
                self:CheckGameEnd()

                self:UpdateWarmUp()
                
                self:UpdatePregame(timePassed)
                self:UpdateToReadyRoom()
                self:UpdateMapCycle()
                self:ServerAgeCheck()
                self:UpdateAutoTeamBalance(timePassed)
                
                self.timeSinceGameStateChanged = self.timeSinceGameStateChanged + timePassed
                
                self.worldTeam:Update(timePassed)
                self.team1:Update(timePassed)
                self.team2:Update(timePassed)
                self.spectatorTeam:Update(timePassed)
                
                -- concede sequence
                self:UpdateConcedeSequence()
                
                self:UpdatePings()
                self:UpdateHealth()
                self:UpdateTechPoints()

                --self:CheckForNoCommander(self.team1, "MarineCommander")
                --self:CheckForNoCommander(self.team2, "AlienCommander")
                --self:KillEnemiesNearCommandStructureInPreGame(timePassed)
                
                --self:UpdatePlayerSkill()
                self:UpdateNumPlayersForScoreboard()
                self:UpdatePerfTags(timePassed)
                self:UpdateCustomNetworkSettings()
                
            end

            self.sponitor:Update(timePassed)
            self.gameInfo:SetIsGatherReady(Server.GetIsGatherReady())
            
        end
        
    end
    

end -- Server