local kDistressBeaconSoundMarine = PrecacheAsset("sound/NS2.fev/marine/common/distress_beacon_marine")
local orig = CommandStation.OnCreate
function CommandStation:OnCreate()
   orig(self)
   
    if Server then
    
        self.distressBeaconSound = Server.CreateEntity(SoundEffect.kMapName)
        self.distressBeaconSound:SetAsset(kDistressBeaconSoundMarine)
        self.distressBeaconSound:SetRelevancyDistance(Math.infinity)
        
        self:AddTimedCallback(Observatory.RevealCysts, 0.4)
        
        self.beaconRelevancyPortal = -1
        
    end
    
    
end
local function GetIsPlayerNearby(_, player, toOrigin)
    return (player:GetOrigin() - toOrigin):GetLength() < Observatory.kDistressBeaconRange
end

local function GetPlayersToBeacon(self, toOrigin)

    local players = { }
    
    for _, player in ipairs(self:GetTeam():GetPlayers()) do
    
        -- Don't affect Commanders or Heavies
        if player:isa("Marine") then
        
            -- Don't respawn players that are already nearby.
            local nearby = GetIsPlayerNearby(self, player, toOrigin)
            local inTheSameLocation = GetLocationForPoint(player:GetOrigin()) == GetLocationForPoint(toOrigin)
            if not nearby or not inTheSameLocation then
            
                if player:isa("Exo") then
                    table.insert(players, 1, player)
                else
                    table.insert(players, player)
                end
                
            end
            
        end
        
    end

    return players
    
end
local function BeaconGetMarineSpawnPoints(orig, number)
    local techId = kTechId.Marine
    local mapName = Marine.kMapName
    local entities = {}
    local extents = LookupTechData(kTechId.Marine, kTechDataMaxExtents)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)
    local range = Observatory.kDistressBeaconRange
    local position = nil

    number = number or 1
    for i = 1, number do

        local success = false
        -- Persistence is the path to victory.
        for index = 1, 150 do

            teamNumber = 1
            position = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, orig, 2, range, EntityFilterAll())
            if position then
                success = true

                local CCLocation = GetLocationForPoint(orig)
                local marineLocation = GetLocationForPoint(position)
                -- Check if we are in the same location room
                if (CCLocation and (not marineLocation or CCLocation:GetName() ~= marineLocation:GetName()))
                then
                    success = false
                    Log("Beaconing a marine to the wrong location (%s instead of %s), let's retry", marineLocation:GetName(), CCLocation:GetName())
                end

                if (success) then
                    -- Log("Location found in %s for a marine", marineLocation and marineLocation:GetName() or "")
                    table.insert(entities, position)
                    break
                end
            end

        end

        -- if not success then
        --    Print("Create %s: Couldn't find space for entity", EnumToString(kTechId, techId))
        -- end
    end

    return entities
end
local function RespawnPlayer(_, player, distressOrigin)

    -- Always marine capsule (player could be dead/spectator)
    local extents = HasMixin(player, "Extents") and player:GetExtents() or LookupTechData(kTechId.Marine, kTechDataMaxExtents)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)
    local range = Observatory.kDistressBeaconRange
    local spawnPoints = BeaconGetMarineSpawnPoints(distressOrigin, 1)
    local spawnPoint = #spawnPoints > 0 and spawnPoints[1] or nil
    
    if spawnPoint then
        
        -- Obsolete Jan. 2, 2018, w/ relevancy portals.
        --if HasMixin(player, "SmoothedRelevancy") then
            --player:StartSmoothedRelevancy(spawnPoint)
        --end
        
        player:SetOrigin(spawnPoint)
        if player.TriggerBeaconEffects then
            player:TriggerBeaconEffects()
        end

    end
    
    return spawnPoint ~= nil, spawnPoint
    
end

function CommandStation:PerformDistressBeacon()
    self.distressBeaconSound:Stop()

    local anyPlayerWasBeaconed = false
    local successfullPositions = {}
    local successfullExoPositions = {}
    local failedPlayers = {}
    
    local distressOrigin =  self:GetOrigin()
    if distressOrigin then
    
            // Respawn DeadPlayers
                        for _, entity in ientitylist(Shared.GetEntitiesWithClassname("MarineSpectator")) do
                          if entity:GetTeamNumber() == 1 and not entity:GetIsAlive() then
                          entity:SetCameraDistance(0)
                          entity:GetTeam():ReplaceRespawnPlayer(entity, distressOrigin)
                          end
                        end
                        
                        if GetConductor().phase == 4 then return end
                        
                        
        for index, player in ipairs(GetPlayersToBeacon(self, distressOrigin)) do
        
            local success, respawnPoint = RespawnPlayer(self, player, distressOrigin)
            if success then
            
                anyPlayerWasBeaconed = true
                if player:isa("Exo") then
                    table.insert(successfullExoPositions, respawnPoint)
                end
                    
                table.insert(successfullPositions, respawnPoint)
                
            else
                table.insert(failedPlayers, player)
            end
            
        end
        

            
        
    end
    
    local usePositionIndex = 1
    local numPosition = #successfullPositions

    for i = 1, #failedPlayers do
    
        local player = failedPlayers[i]  
    
        if player:isa("Exo") then        
            player:SetOrigin(successfullExoPositions[math.random(1, #successfullExoPositions)])  
            player:SetCameraDistance(0)      
        else
              
            player:SetOrigin(distressOrigin)
            player:SetCameraDistance(0) 
            if player.TriggerBeaconEffects then
                player:TriggerBeaconEffects()
                player:SetCameraDistance(0)  
            end
            
            usePositionIndex = Math.Wrap(usePositionIndex + 1, 1, numPosition)
            
        end    
    
    end

    if anyPlayerWasBeaconed then
        self:TriggerEffects("distress_beacon_complete")
    end
    
end


 function CommandStation:OnAdjustModelCoords(modelCoords)
         local coords = modelCoords
    	local scale = 0.5 
        coords.xAxis = coords.xAxis * scale                       
        coords.yAxis = coords.yAxis * scale                           
        coords.zAxis = coords.zAxis * scale
   
    return coords
end
local function TriggerMarineBeaconEffects(self)

    for _, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do
    
        if player:GetIsAlive() and (player:isa("Marine") or player:isa("Exo")) then
            player:TriggerEffects("player_beacon")
        end
    
    end

end
function CommandStation:TriggerDistressBeacon()
        self.distressBeaconSound:Start()
        local origin = self:GetOrigin()()
            self.distressBeaconSound:SetOrigin(origin)
            if Server then
                TriggerMarineBeaconEffects(self)
                local location = GetLocationForPoint(self:GetOrigin())
                local locationName = location and location:GetName() or ""
                local locationId = Shared.GetStringIndex(locationName)
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Beacon, locationId)
                --SetupBeaconRelevancyPortal(self, origin)
            end
    self:PerformDistressBeacon()
    
end

/*
function CommandStation:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil then
       if GetConductor():GetIsPhaseTwoBoolean() then
        damageTable.damage = damageTable.damage * 2
        end
    end

end
*/