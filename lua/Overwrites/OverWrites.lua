Script.Load("lua/Overwrites/Convars.lua")
Script.Load("lua/Overwrites/CustomLightRules.lua")

if Server then
Script.Load("lua/Overwrites/AutoResearch.lua")
end

function CommandStructure:LoginPlayer(player,forced)
 return
end

function ScaleWithPlayerCount(value, numPlayers, scaleUp)

return 8 

end

function ConstructMixin:GetCanConstruct(constructor)

return self:isa("PowerPoint")
    
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
        if #marines >= 1 then
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
           marines = Clamp(#marines, 1, 4)
           multiplier = 1 + (marines/4) * 1
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





local function GetNumEggs(self)

    local numEggs = 0
    local eggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())
    
    for index, egg in ipairs(eggs) do
    
        if egg:GetIsAlive() and egg:GetIsFree() then
            numEggs = numEggs + 1
        end
        
    end
    
    return numEggs
    
end
local function SpawnEgg(self, eggCount)

    if self.eggSpawnPoints == nil or #self.eggSpawnPoints == 0 then
    
        --Print("Can't spawn egg. No spawn points!")
        return nil
        
    end

    if not eggCount then
        eggCount = 0
    end

    for i = 1, #self.eggSpawnPoints do

        local position = eggCount == 0 and table.random(self.eggSpawnPoints) or self.eggSpawnPoints[i]  

        -- Need to check if this spawn is valid for an Egg and for a Skulk because
        -- the Skulk spawns from the Egg.
        local validForEgg = GetCanEggFit(position)

        if validForEgg then
        
            local egg = CreateEntity(Egg.kMapName, position, self:GetTeamNumber())
            egg:SetHive(self)
            

            if egg ~= nil then
            
                -- Randomize starting angles
                local angles = self:GetAngles()
                angles.yaw = math.random() * math.pi * 2
                egg:SetAngles(angles)
                
                -- To make sure physics model is updated without waiting a tick
                egg:UpdatePhysicsModel()
                
                self.timeOfLastEgg = Shared.GetTime()
                
                return egg
                
            end
            
        end

    
    end
    
    return nil
    
end
function Hive:UpdateSpawnEgg()

    local success = false
    local egg = nil

    local eggCount = GetNumEggs(self)
    if eggCount < 8 then  
  
        egg = SpawnEgg(self, eggCount)
        success = egg ~= nil
        
    end
    
    return success, egg

end



end -- Server