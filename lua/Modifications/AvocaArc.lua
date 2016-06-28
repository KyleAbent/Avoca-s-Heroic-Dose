--Kyle 'Avoca' Abent
class 'AvocaArc' (ARC)
AvocaArc.kMapName = "avocaarc"
local kNanoshieldMaterial = PrecacheAsset("cinematics/vfx_materials/nanoshield.material")


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
local function ShouldStop(who)

local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 4)
if #players >=1 then return false end
return true
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
local damage = self:GetInAttackMode() and 0.7 or 0 
        damageTable.damage = damageTable.damage * damage
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



Shared.LinkClassToMap("AvocaArc", AvocaArc.kMapName, networkVars)