--Kyle 'Avoca' Abent
class 'MainRoomArc' (ARC)
MainRoomArc.kMapName = "mainroomarc"


local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"

local kNanoshieldMaterial = PrecacheAsset("cinematics/vfx_materials/nanoshield.material")
MainRoomArc.kAnimationGraph = PrecacheAsset("models/marine/mainroompayload/mainroompayload.animation_graph")

local networkvars = { }

function MainRoomArc:OnCreate()
 ARC.OnCreate(self)
end
function MainRoomArc:OnInitialized()
 ARC.OnInitialized(self)
    self:SetModel(ARC.kModelName, MainRoomArc.kAnimationGraph)
end
function MainRoomArc:GetDamageType()
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
function MainRoomArc:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end
function MainRoomArc:GetCanFireAtTargetActual(target, targetPoint)    

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
local function MoveToMainRoom(self)
            for index, pheromone in ientitylist(Shared.GetEntitiesWithClassname("Pheromone")) do
            self:GiveOrder(kTechId.Move, nil, pheromone:GetOrigin(), nil, true, true)
            break
           end
           

end
function MainRoomArc:SpecificRules()
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

local shouldstop = ShouldStop(self)
--Print("shouldstop is %s", shouldstop) 
local shouldmove = not shouldstop and not moving and not inradius
--Print("shouldmove is %s", shouldmove) 
local shouldstop = moving and ShouldStop(self)
--Print("shouldstop is %s", shouldstop) 
local shouldattack = inradius and not attacking 
--Print("shouldattack is %s", shouldattack) 
local shouldundeploy = attacking and not inradius and not moving
--Print("shouldundeploy is %s", shouldundeploy) 
  
  if moving then
    
    if shouldstop or shouldattack then 
           FindNewParent(self)
       --Print("StopOrder")
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
 elseif not moving then
      
    if shouldmove and not shouldattack  then
        if shouldundeploy then
         --Print("ShouldUndeploy")
         GiveUnDeploy(self)
       else --should move
       --Print("CanMove")
       MoveToMainRoom(self)
       end
       
   elseif shouldattack then
     --Print("ShouldAttack")
     GiveDeploy(self)
    return true
    
 end
 
    end
    
end
function MainRoomArc:OnGetMapBlipInfo()
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
function MainRoomArc:GetCanMove()
local moving = self.mode == ARC.kMode.Moving          
local attacking = self.deployMode == ARC.kDeployMode.Deployed
local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) or CheckForAndActAccordingly(self)  
local shouldstop = ShouldStop(self)
local shouldmove = not shouldstop and not moving and not inradius
local shouldstop = moving and ShouldStop(self)
local shouldattack = inradius and not attacking 
local shouldundeploy = attacking and not inradius and not moving

   if not moving and shouldmove and not shouldattack  then
        if not shouldundeploy then return true end
  end
  return noorder or false
end
local function MoveToHives(who) --Closest hive from origin
local where = who:GetOrigin()
 local hive =  GetNearest(where, "Hive", 2, function(ent) return not ent:GetIsDestroyed() end)

 
               if hive then
        local origin = hive:GetOrigin() -- The arc should auto deploy beforehand
        who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
                    return
                end  
     --Print("No closest hive????")    
end
function MainRoomArc:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
      if  not self:GetInAttackMode() then
    unitName = string.format(Locale.ResolveString("MainRoomPayLoad") )
    else
    unitName = string.format(Locale.ResolveString("MainRoomArc") )
    end
return unitName
end  

function MainRoomArc:BeginTimer()
           self:AddTimedCallback(MainRoomArc.Instruct, 4)
end


function MainRoomArc:Instruct()
   CheckHivesForScan()
   self:SpecificRules()
   return true
end
if Server then
function MainRoomArc:PreOnKill(attacker, doer, point, direction)
--AddPayLoadTime(120) --NO WONDER TIMER WENT LONG LOL
end 
function MainRoomArc:UpdateMoveOrder(deltaTime)

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

    function MainRoomArc:OnUpdateRender()
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

Shared.LinkClassToMap("MainRoomArc", MainRoomArc.kMapName, networkVars)