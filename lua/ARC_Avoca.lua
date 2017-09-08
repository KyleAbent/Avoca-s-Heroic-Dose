local networkVars = 
{
 avoca = "boolean",
 mainroom = "boolean",
 
}

/*

function ARC:OnCreate()
 ARC.OnCreate(self)
end


*/
if Server then

local origInit = ARC.OnInitialized

function ARC:OnInitialized()
    origInit(self)
     self:AddTimedCallback(ARC.Instruct, 2.5)
end
function ARC:GetDamageType()
return kDamageType.StructuresOnly
end




local function SoTheGameCanEnd(self, who) --Although HiveDefense prolongs it
   local arc = GetEntitiesWithinRange("ARC", who:GetOrigin(), ARC.kFireRange)
   if #arc >= 1 then CreateEntity(Scan.kMapName, who:GetOrigin(), 1) end
end


local function hasScan(who)
          for _, scan in ipairs(GetEntitiesWithMixinForTeamWithinRange("Scan", 1, who:GetOrigin(), kARCRange)) do
               if scan then
                  return true
             end
          end
          
          return false
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
              if not hasScan(ent) then
             SoTheGameCanEnd(self, ent)
             end
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
function ARC:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end
function ARC:GetCanFireAtTargetActual(target, targetPoint)    

    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    
    if target:isa("PanicAttack") then
        return false
    end
    
     if self.avoca and not target:isa("Hive") then
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
if self.mainroom then return false end
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
      
--      for index, pheromone in ientitylist(Shared.GetEntitiesWithClassname("Pheromone")) do
  --          self:GiveOrder(kTechId.Move, nil, pheromone:GetOrigin(), nil, true, true)
    --        break
      --     end
      
      local where = GetUnpoweredLocationWithoutArc()
      if not where then return end
           self:GiveOrder(kTechId.Move, nil, FindFreeSpace(where:GetOrigin()), nil, true, true)

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

local function AliensStop(who)
  
end

local function BuffPlayers(who)

local marines =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 6)

     
    if not who:GetInAttackMode() and #marines >= 1 then
         for i = 1, #marines do
              local marine = marines[i]
              if marine:isa("Marine") then who:AddHealth(54) marine:AddHealth( math.random(4,8) ) end
         end
    end

end

function ARC:SpecificRules()
BuffPlayers(self)

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
          if self.mainroom == true then 
           MoveToMainRoom(self)
          elseif self.avoca == true then
             MoveToHives(self)
          end
       end
       
   elseif shouldattack then
     --Print("ShouldAttack")
     GiveDeploy(self)
    return true
    
 end
 
    end
    
end
function ARC:OnGetMapBlipInfo()
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
function ARC:GetCanMove()
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





function ARC:Instruct()
   --Print("Arc instructing")
    CheckHivesForScan()
   self:SpecificRules()
   return true
end

local function DestroPanicAttackInRadius(where)
    for _, panicattack in ipairs(GetEntitiesWithinRange("PanicAttack", where, kARCRange)) do
         if panicattack then panicattack:Kill() end
    end
end

function ARC:PreOnKill(attacker, doer, point, direction)
 if self.avoca then
AddPayLoadTime(16) 
DestroPanicAttackInRadius(self:GetOrigin())
end

end 

end//server

function ARC:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    if self.mainroom then
      if  not self:GetInAttackMode() then
    unitName = string.format(Locale.ResolveString("UnpoweredPL") )
    end
   elseif self.avoca then 
       unitName = string.format(Locale.ResolveString("Hive-Payload") )
   end
return unitName
end  

Shared.LinkClassToMap("ARC", ARC.kMapName, networkVars)