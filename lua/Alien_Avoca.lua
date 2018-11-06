

local networkVars = 

{
  canRebirth = "boolean",
  canRedeem = "boolean",
  primaled = "boolean", 
 primaledID = "entityid",
 }


local orig_Alien_OnCreate = Alien.OnCreate
function Alien:OnCreate()
    orig_Alien_OnCreate(self)
     self:UpdateWeapons()
    -- self.lastredeemorrebirthtime = 0 --i would like to make a new alien class with custom networkvars like this some day :/
    -- self.canredeemorrebirth = true
      self.primaled = false
      self.primaledID = Entity.invalidI 
      self.primalGiveTime = 0
	  self.canRedeem = false
	  self.canRebirth = false
	   self.lastredeemorrebirthtime = 0
end




local orig_Alien_OnInit = Alien.OnInitialized

function Alien:OnInitialized()
   orig_Alien_OnInit(self)
    self:AddTimedCallback(Alien.CheckRedemptionTimer, .5) 
end

function Alien:GetRebirthLength()
return 5
end
function Alien:GetRedemptionCoolDown()
return 25
end

function Alien:HiveCompleteSoRefreshTechsManually()
     self:UpdateWeapons()
end

function Alien:UpdateWeapons()
     if Server then
        self:AddTimedCallback(function() UpdateAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId(), self:GetTierFourTechId(), self:GetTierFiveTechId()) end, 0.6) 
        self:AddTimedCallback(function() UpdateAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId(), self:GetTierFourTechId(), self:GetTierFiveTechId()) end, 1) 
     end
end

function Alien:CheckRedemptionTimer()
    if  GetHasRedemptionUpgrade(self) then 
        if Server then
        self:AddTimedCallback(Alien.RedemptionTimer, 3) 
        end
       end
       return false
end

local function CheckPrimalScream(self)
	self.primaled = self.primalGiveTime - Shared.GetTime() > 0
	return self.primaled
end

function Alien:TriggerRedeemCountDown(player)

end
function Alien:TriggerRebirthCountDown(player)

end

if Server then


  
  
function Alien:RedemptionTimer()
           local threshold =   math.random(kRedemptionEHPThresholdMin,kRedemptionEHPThresholdMax)  / 100
              --Print("threshold is %s", threshold)
              local scalar = self:GetHealthScalar()
               if GetHasRedemptionUpgrade(self) and scalar <= threshold  then
                 self.canredeem = Shared.GetTime() > self.lastredeemorrebirthtime  + self:GetRedemptionCoolDown()
                 --Print("scalar is %s threshold is %s", scalar, threshold)
                 if self.canredeem then
                 self.canredeem = false
                 self:AddTimedCallback(Alien.RedemAlienToHive, math.random(1,4) ) 
                 end      
        end
          return true
end
local function GetRelocationHive(usedhive, origin, teamnumber)
    local hives = GetEntitiesForTeam("Hive", teamnumber)
	local selectedhive
	
    for i, hive in ipairs(hives) do
			selectedhive = hive
	end
	return selectedhive
end
function Alien:TeleportToHive(usedhive)
	local selectedhive = GetRelocationHive(usedhive, self:GetOrigin(), self:GetTeamNumber())
    local success = false
    if selectedhive then 
            local position = table.random(selectedhive.eggSpawnPoints)
                SpawnPlayerAtPoint(self, position)
--               --Shared.Message("LOG - %s SuccessFully Redeemed", self:GetClient():GetControllingPlayer():GetUserId() )
                success = true
    end

end
function Alien:TriggerRebirth()


        local position = self:GetOrigin()
        local trace = Shared.TraceRay(position, position + Vector(0, -0.5, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOne(self))
        
            -- Check for room
            local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
            local newLifeFormTechId = self:GetTechId() --/ :P
            local upgradeManager = AlienUpgradeManager()
            upgradeManager:Populate(self)
             upgradeManager:AddUpgrade(lifeFormTechId)
            local newAlienExtents = LookupTechData(newLifeFormTechId, kTechDataMaxExtents)
            local physicsMask = PhysicsMask.Evolve
            
            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
            
             local evolveAllowed = self:GetIsOnGround() and GetHasRoomForCapsule(eggExtents + spawnBufferExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self)

            local roomAfter
            local spawnPoint
       
            -- If not on the ground for the buy action, attempt to automatically
            -- put the player on the ground in an area with enough room for the new Alien.
            if not evolveAllowed then
            
                for index = 1, 100 do
                
                    spawnPoint = GetRandomSpawnForCapsule(eggExtents.y, math.max(eggExtents.x, eggExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
  
                    if spawnPoint then
                        self:SetOrigin(spawnPoint)
                        position = spawnPoint
                        break 
                    end
                    
                end
            end   
            
            if not GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, self:GetOrigin() + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterOne(self)) then
           
                for index = 1, 100 do

                    roomAfter = GetRandomSpawnForCapsule(newAlienExtents.y, math.max(newAlienExtents.x, newAlienExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
                    
                    if roomAfter then
                        evolveAllowed = true
                        break
                    end

                end
                
            else
                roomAfter = position
                evolveAllowed = true
            end
            
            if evolveAllowed and roomAfter ~= nil then

                local newPlayer = self:Replace(Embryo.kMapName)
                position.y = position.y + Embryo.kEvolveSpawnOffset
                newPlayer:SetOrigin(position)
                -- Clear angles, in case we were wall-walking or doing some crazy alien thing
                local angles = Angles(self:GetViewAngles())
                angles.roll = 0.0
                angles.pitch = 0.0
                newPlayer:SetOriginalAngles(angles)
                newPlayer:SetValidSpawnPoint(roomAfter)
                
                --Eliminate velocity so that we don't slide or jump as an egg
                newPlayer:SetVelocity(Vector(0, 0, 0))                
                newPlayer:DropToFloor()
                
               newPlayer:TriggerRebirthCountDown(newPlayer:GetClient():GetControllingPlayer())
               newPlayer:SetGestationData(upgradeManager:GetUpgrades(), newLifeFormTechId, 10, 10) --Skulk to X 
               newPlayer.gestationTime = self:GetRebirthLength()
               newPlayer.lastredeemorrebirthtime = Shared.GetTime()
               newPlayer.triggeredrebirth = true
               
               --Spawn protective boneshield    
                success = true
                
                
            else

               self:TeleportToHive()

            end    
            
    
    
    
end

local function SingleHallucination(self, player)
  --Why a cloud ?
                local alien = player
                local newAlienExtents = LookupTechData(alien:GetTechId(), kTechDataMaxExtents)
                local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(newAlienExtents) 
                
                local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, alien:GetModelOrigin(), 0.5, 5)
                
                if spawnPoint then

                    local hallucinatedPlayer = CreateEntity(alien:GetMapName(), spawnPoint, self:GetTeamNumber())
                    hallucinatedPlayer.isHallucination = true
                    InitMixin(hallucinatedPlayer, PlayerHallucinationMixin)                
                    InitMixin(hallucinatedPlayer, SoftTargetMixin)                
                    InitMixin(hallucinatedPlayer, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance }) 

                    hallucinatedPlayer:SetName(alien:GetName())
                    hallucinatedPlayer:SetHallucinatedClientIndex(alien:GetClientIndex())
                end
                    


end

function Alien:OnRedeem(player)

   --self:GiveItem(HallucinationCloud.kMapName)   
   --SingleHallucination(self, player) --if gethastech redemption hallucination (veil research)
   self:AddScore(1, 0, false)
   self:TriggerRedeemCountDown(player)
end

function Alien:GetEligableForRebirth()
return Shared.GetTime() > self.lastredeemorrebirthtime  + ( self:GetRedemptionCoolDown() * 1.3 )
end
function Alien:GetEligableForRedemption()
return Shared.GetTime() > self.lastredeemorrebirthtime  + self:GetRedemptionCoolDown() 
end


function Alien:RedemAlienToHive()
     if self:GetEligableForRedemption() then
        self:TeleportToHive()
          local client = self:GetClient()
          if client and client.GetIsVirtual and client:GetIsVirtual() then return end
          client = client:GetControllingPlayer()
         if client and self.OnRedeem then self:OnRedeem(client) end
        self.lastredeemorrebirthtime = Shared:GetTime()
     end
        return false
end


function Alien:GetTierFourTechId()
    return kTechId.None
end

function Alien:GetTierFiveTechId()
    return kTechId.None
end

function Alien:CreditBuy(techId)
        local cost = LookupTechData(techId, kTechDataCostKey, 0)
         self:AddResources(cost)
        local upgradetable = {}
        local upgrades = Player.lastUpgradeList
        if upgrades and #upgrades > 0 then
            table.insert(upgradetable, upgrades)
        end
        
        table.insert(upgradetable, techId)
        self:ProcessBuyAction(upgradetable, true)
        self:AddResources(cost)
end




function Alien:HiveCompleteSoRefreshTechsManually()
     self:UpdateWeapons()
end


function Alien:GetHasLayStructure()
        local weapon = self:GetWeaponInHUDSlot(5)
        local builder = false
    if (weapon) then
            builder = true
    end
    
    return builder
end
function Alien:GiveLayStructure(techid, mapname)
  --  if not self:GetHasLayStructure() then
           local laystructure = self:GiveItem(LayStructures.kMapName)
           self:SetActiveWeapon(LayStructures.kMapName)
           laystructure:SetTechId(techid)
           laystructure:SetMapName(mapname)
  -- else
   --  self:TellMarine(self)
  -- end
end



local function GetRelocationHive(usedhive, origin, teamnumber)
    local hives = GetEntitiesForTeam("Hive", teamnumber)
	local selectedhive
	
    for i, hive in ipairs(hives) do
			selectedhive = hive
	end
	return selectedhive
end

function Alien:TeleportToHive(usedhive)
	local selectedhive = GetRelocationHive(usedhive, self:GetOrigin(), self:GetTeamNumber())
    local success = false
    if selectedhive then 
            local position = table.random(selectedhive.eggSpawnPoints)
                SpawnPlayerAtPoint(self, position)
--               Shared.Message("LOG - %s SuccessFully Redeemed", self:GetClient():GetControllingPlayer():GetUserId() )
                success = true
    end
   
end

function Alien:PrimalScream(duration)
        if not self.primaled then
			self:AddTimedCallback(CheckPrimalScream, duration)
		end
        self.primaled = true
        self.primalGiveTime = Shared.GetTime() + duration
end


    function Alien:CancelPrimal()

    if self.primalGiveTime > Shared.GetTime() or self:GetIsOnFire() then 
        self.primalGiveTime = Shared.GetTime()
        self.primaledID = Entity.invalidI
    end
    
    end






end --server

function Alien:GetHasPrimalScream()
    return self.primaled
end

function Alien:CancelPrimal()

    if self.primalGiveTime > Shared.GetTime() or self:GetIsOnFire() then 
        self.primalGiveTime = Shared.GetTime()
        self.primaledID = Entity.invalidI
    end
    
end

--Hmm? Overwrite? My palms are open, not clenched.. Idk about my asshole, though.
function Alien:OnUpdateAnimationInput(modelMixin)

    Player.OnUpdateAnimationInput(self, modelMixin)
    
    local attackSpeed = self:GetIsEnzymed() and kEnzymeAttackSpeed or 1
    attackSpeed = attackSpeed * ( self.electrified and kElectrifiedAttackSpeed or 1 )
    attackSpeed = attackSpeed + ( self:GetHasPrimalScream() and kPrimalScreamROFIncrease or 0)
    if self.ModifyAttackSpeed then
    
        local attackSpeedTable = { attackSpeed = attackSpeed }
        self:ModifyAttackSpeed(attackSpeedTable)
        attackSpeed = attackSpeedTable.attackSpeed
        
    end
    
    modelMixin:SetAnimationInput("attack_speed", attackSpeed)
    
end






if Client then




local orig_Alien_UpdateClientEffects = Alien.UpdateClientEffects
function Alien:UpdateClientEffects(deltaTime, isLocal)
orig_Alien_UpdateClientEffects(self, deltaTime, isLocal)


       self:UpdateGhostModel()

end
    

--local orig_Alien_UpdateGhostModel = Alien.UpdateGhostModel
function Alien:UpdateGhostModel()

--orig_Alien_UpdateGhostModel(self)

 self.currentTechId = nil
 
    self.ghostStructureCoords = nil
    self.ghostStructureValid = false
    self.showGhostModel = false
    
    local weapon = self:GetActiveWeapon()

    if weapon then
       if weapon:isa("LayStructures") then
        self.currentTechId = weapon:GetDropStructureId()
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
         end
    end




end --function

function Alien:GetShowGhostModel()
    return self.showGhostModel
end    

function Alien:GetGhostModelTechId()
    return self.currentTechId
end

function Alien:GetGhostModelCoords()
    return self.ghostStructureCoords
end

function Alien:GetIsPlacementValid()
    return self.ghostStructureValid
end

function Alien:AddGhostGuide(origin, radius)

return

end

end --client 
