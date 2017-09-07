Script.Load("lua/Overwrites/Convars.lua")
Script.Load("lua/Overwrites/CustomLightRules.lua")

--gotta do this the smart way derphead

if Server then
Script.Load("lua/Overwrites/EggSpawn.lua")
end

function CorrodeMixin:OnUpdate(deltaTime)   
   return
end

if Server then
function CommandStructure:LoginPlayer(player,forced)
 return
end
function MaturityMixin:OnConstructionComplete()

            self:SetMature()
end
    function MaturityMixin:OnMaturityUpdate(deltaTime)
        
    end

end
function CorrodeMixin:__initmixin()

return
    
end

function FollowMoveMixin:SetFollowTarget(target)
  if self:GetTeamNumber() == 1 then 
 local nearest = GetNearest(self:GetOrigin(), "AvocaArc", 1)
--  if not nearest then nearest =  GetNearestMixin(self:GetOrigin(), "Combat", math.random(1,2), function(ent) return ent:GetIsInCombat() end) end
   if nearest then target = nearest end
   
  end
    if target then
        self.imposedTargetId = target:GetId()
    else
        self.imposedTargetId = Entity.invalidId
    end
    
end

function Hive:GetCanBeUsed(player, useSuccessTable)
        useSuccessTable.useSuccess = false
end

function Hive:GetCanBeUsedConstructed(byPlayer)
    return false
end

-- allow players to enter the hives before game start to signal that they want to command
function CommandStructure:GetUseAllowedBeforeGameStart()
    return false
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
    local damage = not self:isa("PowerDrainer") and Clamp(damage * self:GetHealthScalar(), 1, damage) or Whip.kDamage * 0.35
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






    function NS2Gamerules:CheckForNoCommander(onTeam, commanderType)

end

function NS2Gamerules:KillEnemiesNearCommandStructureInPreGame(derp)

end

function NS2Gamerules:UpdatePlayerSkill()

end

 

end -- Server