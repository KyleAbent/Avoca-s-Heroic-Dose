



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
local function GetBioMassLevel()
           local teamInfo = GetTeamInfoEntity(2)
           local bioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
           return math.round(bioMass / 3, 1, 3)
end
local function SpawnRandomEgg(who, where)


       
      local eggtechmapnames = {}
      local gorgechance = math.random(1,2)
      local lerkchance = math.random(1,3)
      local fadechance = math.random(1,4)
      local onoschance = math.random(1,5)
      if gorgechance == 1 and GetBioMassLevel() >= 3 then  table.insert(eggtechmapnames, kTechId.GorgeEgg) end
      if lerkchance == 1 and GetBioMassLevel() >= 5 then   table.insert(eggtechmapnames, kTechId.LerkEgg) end
      if fadechance == 1 and GetBioMassLevel() >= 7 then   table.insert(eggtechmapnames, kTechId.FadeEgg) end
      if onoschance == 1 and GetBioMassLevel() >= 9 then   table.insert(eggtechmapnames, kTechId.OnosEgg) end
      local egg = CreateEntity(Egg.kMapName, where, 2)
      egg:SetHive(who)
      
            local randomegg = table.random(eggtechmapnames)
            if randomegg then
             egg:UpgradeToTechId(randomegg)
            end
      return egg
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
               local egg = SpawnRandomEgg(self,position)

            

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

function GorgeEgg:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Egg
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function LerkEgg:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Egg
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function FadeEgg:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Egg
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function OnosEgg:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Egg
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end