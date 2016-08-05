--Kyle 'Avoca' Abent
class 'LocationArc' (ARC)
LocationArc.kMapName = "locationarc"


local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"

local kNanoshieldMaterial = PrecacheAsset("cinematics/vfx_materials/nanoshield.material")
LocationArc.kAnimationGraph = PrecacheAsset("models/marine/mainroompayload/mainroompayload.animation_graph")

local networkvars = { 

locationID = "entityid"

}

function LocationArc:OnCreate()
 ARC.OnCreate(self)
  self.locationID = Entity.invalidI
end
function LocationArc:OnInitialized()
 ARC.OnInitialized(self)
    self:SetModel(ARC.kModelName, LocationArc.kAnimationGraph)
end
function LocationArc:GetDamageType()
return kDamageType.StructuresOnly
end

local function SoTheGameCanEnd(self, who) --Although HiveDefense prolongs it
   local arc = GetEntitiesWithinRange("ARC", who:GetOrigin(), ARC.kFireRange)
   if #arc >= 1 then CreateEntity(Scan.kMapName, who:GetOrigin(), 1) end
end

local function CheckHivesForScan()
local hives = {}
           for _, hiveent in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             table.insert(hives, hiveent)
          end
          if #hives == 0 then return end
          --Scan hive if arc in range, only 1 check per hive.. not per arc.. or whatever. 
          for i = 1, #hives do
             local ent = hives[i]
             SoTheGameCanEnd(self, ent)
          end
end
local function CheckForAndActAccordingly(who)
local stopanddeploy = false
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, who:GetOrigin(), kARCRange)) do
             if who:GetCanFireAtTarget(enemy, enemy:GetOrigin()) then
             stopanddeploy = true
             break
             end
          end
        --Print("stopanddeploy is %s", stopanddeploy)
       return stopanddeploy
end
function LocationArc:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end
function LocationArc:GetCanFireAtTargetActual(target, targetPoint)    

    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    
    if target:isa("PanicAttack") then
        return false
    end
    
    if not target:GetIsSighted() and not GetIsTargetDetected(target) then
        return false
    end
    
    local distToTarget = (target:GetOrigin() - self:GetOrigin()):GetLengthXZ()
    if (distToTarget > ARC.kFireRange) or (distToTarget < ARC.kMinFireRange) then
        return false
    end
    
    return true
    
end
function ARC:InRadius()
return  GetIsPointWithinHiveRadius(self:GetOrigin()) or CheckForAndActAccordingly(self) 
end
local function ShouldStop(who)

local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 8)
if #players >=1 then return false end
return true
end
local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end

local function GiveUnDeploy(who)
     --Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end
function LocationArc:SetArcLocation()
  local locations = {}
          for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
               table.insertunique(locations,location:GetId())  
          end
   
          for _, locationarc in ientitylist(Shared.GetEntitiesWithClassname("LocationArc")) do
               local locationarcid = locationarc.locationarcID
               if table.find(locations, locationarcid) then table.removevalue(locations,locationarcid) end
          end   

   if #locations == 0 then return end 
            local random = table.random(locations)
            self.locationID = random
end
local function MoveToLocation(self)

local location = self.locationID ~= Entity.invalidI and Shared.GetEntity( self.locationID ) or nil
  if location then 
  
       if GetLocationForPoint(self:GetOrigin()):GetId() == location and not self.moving then  self:GiveOrder(kTechId.ARCDeploy, self:GetId(),self:GetOrigin(), nil, true, true) end
      local powerpoint = GetNearest(location:GetOrigin(), "PowerPoint", 1) --, function(ent) return GetLocationForPoint(ent:GetOrigin()):GetId() == location end)
           if powerpoint then
            self:GiveOrder(kTechId.Move, nil, FindFreeSpace(powerpoint:GetOrigin()), nil, true, true)
            end
  else
     self:SetArcLocation()
           end
           

end
function LocationArc:SpecificRules()
local moving = self.mode == ARC.kMode.Moving     
local shouldstop = ShouldStop(self)
local shouldmove = not shouldstop and not moving
local shouldstop = moving and ShouldStop(self)
  
  if moving then
    
    if shouldstop  then 
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
 elseif not moving then
      
    if shouldmove  then
       MoveToLocation(self)
       end 
 end
 
        return not self:GetInAttackMode()
end
function LocationArc:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.ARC
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function LocationArc:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
   local location = self.locationID ~= Entity.invalidI and Shared.GetEntity( self.locationID ) or nil
    if location then 
    unitName = string.format(Locale.ResolveString("%s", location.name) )
    end
return unitName
end  

function LocationArc:BeginTimer()
           self:AddTimedCallback(LocationArc.Instruct, 4)
end


function LocationArc:Instruct()
   CheckHivesForScan()
   self:SpecificRules()
   return true
end
if Server then
    function LocationArc:OnOrderComplete(currentOrder)

       self:GiveOrder(kTechId.ARCDeploy, self:GetId(),self:GetOrigin(), nil, true, true)
    
    end
function LocationArc:PreOnKill(attacker, doer, point, direction)
--AddPayLoadTime(120) --NO WONDER TIMER WENT LONG LOL
end 

local function GetEntitiesInSameLocation(where)
  local ents = {}
  
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation:GetName() or ""
           
     for _, eligable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct", 2, where, 72)) do
     
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = locationName == wherelocation
           table.insert(ents, eligable)
     end
     
     return ents


end
local function PerformAttack(self)

    if self.targetPosition then
    
        self:TriggerEffects("arc_firing")    
        -- Play big hit sound at origin
        
        -- don't pass triggering entity so the sound / cinematic will always be relevant for everyone
        GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self.targetPosition)})
        
        local hitEntities = GetEntitiesInSameLocation(self:GetOrigin()) or GetEntitiesWithMixinWithinRange("Live", self.targetPosition, ARC.kSplashRadius)

        -- Do damage to every target in range
        RadiusDamage(hitEntities, self.targetPosition, ARC.kSplashRadius, ARC.kAttackDamage, self, true)

        -- Play hit effect on each
        for index, target in ipairs(hitEntities) do
        
            if HasMixin(target, "Effects") then
                target:TriggerEffects("arc_hit_secondary")
            end 
           
        end
        
    end
    
    -- reset target position and acquire new target
    self.targetPosition = nil
    self.targetedEntity = Entity.invalidId
    
end
function LocationArc:OnTag(tagName)

    PROFILE("ARC:OnTag")
    
    if tagName == "fire_start" then
        PerformAttack(self)
    elseif tagName == "target_start" then
        self:TriggerEffects("arc_charge")
    elseif tagName == "attack_end" then
        self:SetMode(ARC.kMode.Targeting)
    elseif tagName == "deploy_start" then
        self:TriggerEffects("arc_deploying")
    elseif tagName == "undeploy_start" then
        self:TriggerEffects("arc_stop_charge")
    elseif tagName == "deploy_end" then
    
        -- Clear orders when deployed so new ARC attack order will be used
        self.deployMode = ARC.kDeployMode.Deployed
        self:ClearOrders()
        -- notify the target selector that we have moved.
        self.targetSelector:AttackerMoved()
        
        self:AdjustMaxHealth(kARCDeployedHealth)
        
        local currentArmor = self:GetArmor()
        if currentArmor ~= 0 then
            self.undeployedArmor = currentArmor
        end
        
        self:SetMaxArmor(kARCDeployedArmor)
        self:SetArmor(self.deployedArmor)
        
    elseif tagName == "undeploy_end" then
    
        self.deployMode = ARC.kDeployMode.Undeployed
        
        self:AdjustMaxHealth(kARCHealth)
        self.deployedArmor = self:GetArmor()
        self:SetMaxArmor(kARCArmor)
        self:SetArmor(self.undeployedArmor)

    end
    
end
function LocationArc:UpdateMoveOrder(deltaTime)

    local currentOrder = self:GetCurrentOrder()
    ASSERT(currentOrder)
    
    self:SetMode(ARC.kMode.Moving)  
    
    local moveSpeed = ( self:GetIsInCombat() or self:GetGameEffectMask(kGameEffect.OnInfestation) ) and 1.2 or 3
   -- local marines = GetEntitiesWithinRange("Marine", self:GetOrigin(), 4)
    --        if #marines >= 2 then
    --        moveSpeed = moveSpeed * Clamp(#marines/4, 1.1, 4)
   --         end
    local maxSpeedTable = { maxSpeed = moveSpeed }
    self:ModifyMaxSpeed(maxSpeedTable)
    
    self:MoveToTarget(PhysicsMask.AIMovement, currentOrder:GetLocation(), maxSpeedTable.maxSpeed, deltaTime)
    
    self:AdjustPitchAndRoll()
    
    if self:IsTargetReached(currentOrder:GetLocation(), kAIMoveOrderCompleteDistance) then
    
        self:CompletedCurrentOrder()
        self:SetPoseParam(kMoveParam, 0)
        
        -- If no more orders, we're done
        if self:GetCurrentOrder() == nil then
            self:SetMode(ARC.kMode.Stationary)
        end
        
    else
        self:SetPoseParam(kMoveParam, .5)
    end
    
end
elseif Client then

    function LocationArc:OnUpdateRender()
          local showMaterial = self:GetInAttackMode()
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kNanoshieldMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client/server

Shared.LinkClassToMap("LocationArc", LocationArc.kMapName, networkVars)