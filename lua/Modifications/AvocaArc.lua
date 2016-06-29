--Kyle 'Avoca' Abent
class 'AvocaArc' (ARC)
AvocaArc.kMapName = "avocaarc"
local kNanoshieldMaterial = PrecacheAsset("cinematics/vfx_materials/nanoshield.material")
local kPhaseSound = PrecacheAsset("sound/NS2.fev/marine/structures/phase_gate_teleport")

local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"


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
function ARC:GetShowDamageIndicator()
    return true
end
local function MoveToHives(who) --Closest hive from origin
local where = who:GetOrigin()
 local hive =  GetNearest(where, "Hive", 2, function(ent) return not ent:GetIsDestroyed() end)

 
               if hive then
        local origin = hive:GetOrigin() -- The arc should auto deploy beforehand
        who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
                    return
                end  
    -- Print("No closest hive????")    
end

local function CheckForAndActAccordingly(who)
local stopanddeploy = false
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, who:GetOrigin(), kARCRange)) do
             if who:GetCanFireAtTargetActual(enemy, enemy:GetOrigin()) then
             stopanddeploy = true
             break
             end
          end
        --Print("stopanddeploy is %s", stopanddeploy)
       return stopanddeploy
end
local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end
local function GiveDeploy(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
end
local function GiveUnDeploy(who)
     --Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end
local function PlayersNearby(who)

local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 4)
return #players or 0 
end
function AvocaArc:SpecificRules()
--How emberassing to have the 6.22 video show off broken lua but hey that what's given after only 6 hours
--and saying i would come back to fix the hive origin and of course fix the actual function of the intention
--of payload rules xD
--local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) --or CheckForAndActAccordingly(self)  
--Print("SpecificRules")

local moving = self.mode == ARC.kMode.Moving     
--Print("moving is %s", moving) 
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
--Print("attacking is %s", moving) 
local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) or CheckForAndActAccordingly(self)  
--Print("inradius is %s", inradius) 

local shouldstop = PlayersNearby(self) == 0
--Print("shouldstop is %s", shouldstop) 
local shouldmove = not shouldstop and not moving and not inradius
--Print("shouldmove is %s", shouldmove) 
local shouldstop = moving and PlayersNearby(self) == 0
--Print("shouldstop is %s", shouldstop) 
local shouldattack = inradius and not attacking 
--Print("shouldattack is %s", shouldattack) 
local shouldundeploy = attacking and not inradius and not moving
--Print("shouldundeploy is %s", shouldundeploy) 
  
  if moving then
    
    if shouldstop or shouldattack then 
       --Print("StopOrder")
       FindNewParent(self)
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
 elseif not moving then
      
    if shouldmove and not shouldattack  then
        if shouldundeploy then
         --Print("ShouldUndeploy")
         GiveUnDeploy(self)
       else --should move
       --Print("GiveMove")
       MoveToHives(self)
       end
       
   elseif shouldattack then
     --Print("ShouldAttack")
     GiveDeploy(self)
    return true
    
 end
 
    end
    
end
function AvocaArc:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
      if  not self:GetInAttackMode() then
    unitName = string.format(Locale.ResolveString("Hive-PAYLOAD") )
    else
    unitName = string.format(Locale.ResolveString("AvocaArc") )
    end
return unitName
end  
function AvocaArc:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end
function AvocaArc:GetCanFireAtTargetActual(target, targetPoint)    

    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    
    if not target:isa("Hive") then
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
function AvocaArc:ModifyDamageTaken(damageTable, attacker, doer, damageType)
local damage = self:GetInAttackMode() and 0.25 or 0 
        damageTable.damage = damageTable.damage * damage
end
function AvocaArc:GetDamageType()
return kDamageType.StructuresOnly
end
if Client then

    function AvocaArc:OnUpdateRender()
          local showMaterial = not self:GetInAttackMode()
    
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
end -- client
function AvocaArc:BeginTimer()
           self:AddTimedCallback(AvocaArc.Instruct, 4)
end
function AvocaArc:OnAdjustModelCoords(coords)
    
    	local scale = 1.5 
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
        
    return coords
    
end
function AvocaArc:OnGetMapBlipInfo()
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
function AvocaArc:Instruct()
   CheckHivesForScan()
   self:SpecificRules()
   return true
end

if Server then
function AvocaArc:PreOnKill(attacker, doer, point, direction)
AddPayLoadTime(120) 
end 
function AvocaArc:UpdateMoveOrder(deltaTime)

    local currentOrder = self:GetCurrentOrder()
    ASSERT(currentOrder)
    
    self:SetMode(ARC.kMode.Moving)  
    
    local moveSpeed = ( self:GetIsInCombat() or self:GetGameEffectMask(kGameEffect.OnInfestation) ) and ARC.kCombatMoveSpeed or ARC.kMoveSpeed
   -- local marines = GetEntitiesWithinRange("Marine", self:GetOrigin(), 4)
    --        if #marines >= 2 then
    --        moveSpeed = moveSpeed * Clamp(#marines/4, 1.1, 4)
    --        end
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
local function GetDestinationGateEndPoint(self)
    -- Find next phase gate to teleport to
    local phaseGates = {}    
    for index, phaseGate in ipairs( GetEntitiesForTeam("PhaseGate", self:GetTeamNumber()) ) do
        if GetIsUnitActive(phaseGate) then
            table.insert(phaseGates, phaseGate)
        end
    end    
    
    if table.count(phaseGates) < 2 then
        return nil
    end
    
    -- Find our index and add 1
    local index = table.find(phaseGates, self)
    if (index ~= nil) then
    
        local nextIndex = ConditionalValue(index == table.count(phaseGates), 1, index + 1)
        local entity = phaseGates[0]
        return entity:GetOrigin()
        
    end
end
function AvocaArc:GetCanBeUsed(player, useSuccessTable)
    if player:isa("Marine") then
    useSuccessTable.useSuccess = true    
    else
    useSuccessTable.useSuccess = false
    end
end
function AvocaArc:OnUse(player, elapsedTime, useSuccessTable)

      if HasMixin(user, "PhaseGateUser") then
        user:TriggerEffects("phase_gate_player_enter")        
        user:TriggerEffects("teleport")
        
        StartSoundEffectAtOrigin(kPhaseSound, self:GetOrigin())
        local origin = GetDestinationGateEndPoint(self)
        local destinationCoords = Angles(0, self.targetYaw, 0):GetCoords()
        
        player:OnPhaseGateEntry(origin)
        
        TransformPlayerCoordsForPhaseGate(user, self:GetCoords(), destinationCoords)

        player:SetOrigin(origin)
        -- trigger exit effect at destination
        player:TriggerEffects("phase_gate_player_exit")
        
        StartSoundEffectAtOrigin(kPhaseSound, origin)

        return true

      end
    
end

end

Shared.LinkClassToMap("AvocaArc", AvocaArc.kMapName, networkVars)