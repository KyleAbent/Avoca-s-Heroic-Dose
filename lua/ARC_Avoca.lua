Script.Load("lua/Additions/LevelsMixin.lua")

local networkVars = 
{
 avoca = "boolean",
 mainroom = "boolean",
 lastCheck = "time",
}

AddMixinNetworkVars(LevelsMixin, networkVars)



function ARC:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    -- webs can't be destroyed with bullet weapons
    if doer ~= nil then 
        if self.avoca == true then
         damageTable.damage = damageTable.damage * 0.5
        end
        
    end

end

if Server then


function ARC:OnAddXp()
  local dmg = kARCDamage
  self.kAttackDamage = dmg * (self.level/100) + dmg
end


    
    
local origInit = ARC.OnInitialized

function ARC:OnInitialized()
    origInit(self)
     self:AddTimedCallback(ARC.Instruct, 2.5)
     self.lastCheck = 0
     if  GetPayLoadArc() == nil then
           self.avoca = true 
     else
     self.mainroom = true
        end
     InitMixin(self, LevelsMixin)
end


    function ARC:GetMaxLevel()
    return 30
    end
    function ARC:GetAddXPAmount()
    return 0.25
    end
    

function ARC:GetDamageType()
return kDamageType.StructuresOnly
end

function ARC:GetIsPL()
 if self. avoca then 
  return true
  else
  return false
 end
end


local function SoTheGameCanEnd(who) --Although HiveDefense prolongs it
   local arc = GetEntitiesWithinRange("ARC", who:GetOrigin(), ARC.kFireRange)
   if #arc >= 1 then CreateEntity(Scan.kMapName, who:GetOrigin(), 1) end
end
local function CanMoveTo(self, target)    

    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
   
    
     if self.avoca == true and not target:isa("Hive") then
        return false
    end
     if target:isa("Cyst") then return false end
  --  if not target:GetIsSighted() and not GetIsTargetDetected(target) then
 --       return false
  --  end
    
   -- local distToTarget = (target:GetOrigin() - self:GetOrigin()):GetLengthXZ()
   -- if (distToTarget > ARC.kFireRange) or (distToTarget < ARC.kMinFireRange) then
   --     return false
   -- end
    
    return true
    
end
local function GetNearestEligable(self)
    local nearest = GetNearestMixin(self:GetOrigin(), "Construct", 2, function(ent) return CanMoveTo(self, ent) end)
    if nearest then
    -- Print("avoca is %s, mainroom is %s, nearest is %s", self.avoca, self.mainroom, nearest:GetMapName())
    return nearest 
    end
end


local function GetRandomEligable(self)
 local eligable = {}
        for index, target in ipairs(GetEntitiesWithMixinWithinRange("Construct", self:GetOrigin(), 9999 )) do
                if target:GetTeamNumber() == 2 and CanMoveTo(self, target) then
                  table.insert(eligable, target)
                end
          end
          if #eligable == 0 then return nil end
          local ent = table.random(eligable)
        --  Print("GetRandomEligable is %s", ent:GetMapName())
          return  ent
end

local function hasScan(who, where)
          if not where then where = who:GetOrigin() end 
          for _, scan in ipairs(GetEntitiesForTeamWithinRange("Scan", 1, where, kScanRadius)) do
               if scan then
                  return true
             end
          end
          
          return false
end

local function hasFire(who)
local count = 0
          for _, fire in ipairs(GetEntitiesForTeamWithinRange("FireFlameCloud", 1, who:GetOrigin(), 4)) do
              count = count + 1
          end
          
          return count<=3
end
/*
local function CheckHivesForScan(who)
local hives = {}
    
           for _, hive in ipairs(GetEntitiesForTeamWithinRange("Hive", 2, who:GetOrigin(), kARCRange)) do
             table.insert(hives, hiveent)
          end
          
          if #hives == 0 then return end
          --Scan hive if arc in range, only 1 check per hive.. not per arc.. or whatever. 
          for i = 1, #hives do
             local ent = hives[i]
              if not hasScan(ent) then
             SoTheGameCanEnd(who)
             end
          end
end
*/

local function CheckForAndActAccordingly(who)
local stopanddeploy = false
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, who:GetOrigin(), kARCRange)) do
              local distToTarget = (enemy:GetOrigin() - who:GetOrigin()):GetLengthXZ()
                  if who.avoca == true and  (distToTarget < 4) and not hasFire(who) then
                   CreateEntity(FireFlameCloud.kMapName, enemy:GetOrigin() , 1) 
                   --Set parent nearby player
                    end
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
    
     if self.avoca == true and not target:isa("Hive") then
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
--if who.mainroom == true then return false end
local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 8)

      for i = 1, #players do
        local ent = players[i]
           if not  who:GetInAttackMode() and  ent:isa("Marine") then ent:AddHealth(200) ent:AddHealth( math.random(4,8) ) end
         if ent:GetIsAlive() then return false end
      end
      
return not who.mainroom
end

local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end
function ARC:GiveScan()
    local where = GetNearestEligable(self):GetOrigin()
    
    for _, shade in ipairs(GetEntitiesWithinRange("Shade", where, 20)) do
       if shade:GetIsBuilt() then
         shade.shouldInk = true
         end
    end
    
    if not hasScan(self, where) then  
      CreateEntity(Scan.kMapName, where , 1) 
      end
end


local origu = ARC.OnUpdate
function ARC:OnUpdate(deltaTime)
    origu(self, deltaTime)
   
    if self:GetInAttackMode() and  GetIsTimeUp(self.lastCheck, 4)  then
      self.lastCheck = Shared.GetTime()
      self:GiveScan()
    end

end



     
local function GiveDeploy(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
CreateEntity(Scan.kMapName, who:GetOrigin(), 1) 


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
     --   Print("MoveToMainRoom 1")
--      for index, pheromone in ientitylist(Shared.GetEntitiesWithClassname("Pheromone")) do
  --          self:GiveOrder(kTechId.Move, nil, pheromone:GetOrigin(), nil, true, true)
    --        break
      --     end
      local ent = GetRandomEligable(self) --GetUnpoweredLocationWithoutArc()
             -- Print("MoveToMainRoom ent is %s", ent:GetMapName())
      local where = ent:GetOrigin()
      if not where then return end
      self:GiveOrder(kTechId.Move, nil, FindFreeSpace(where), nil, true, true)

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

/*
local function BuffPlayers(who)

local marines =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 6)

     
    if not who:GetInAttackMode() and #marines >= 1 then
         for i = 1, #marines do
              local marine = marines[i]
              if marine:isa("Marine") then who:AddHealth(200) marine:AddHealth( math.random(4,8) ) end
         end
    end

end

*/

function ARC:SpecificRules()
--BuffPlayers(self)

local moving = self.mode == ARC.kMode.Moving     
--Print("moving is %s", moving) 
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
--Print("avoca is %s mainroom is %s attacking is %s", self.avoca, self.mainroom, attacking) 
local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) or CheckForAndActAccordingly(self)  
--Print("avoca is %s mainroom is %s inradius is %s", self.avoca, self.mainroom, inradius) 

local shouldstop = ShouldStop(self)
--Print("avoca is %s mainroom is %s shouldstop is %s", self.avoca, self.mainroom, shouldstop) 
local shouldmove = not shouldstop and not moving and not inradius
--Print("avoca is %s mainroom is %s shouldmove is %s", self.avoca, self.mainroom, shouldmove) 
      shouldstop = moving and shouldstop
--Print("avoca is %s mainroom is %s shouldstop is %s", self.avoca, self.mainroom, shouldstop) 
local shouldattack = inradius and not attacking 
--Print("avoca is %s mainroom is %s shouldattack is %s", self.avoca, self.mainroom, shouldattack) 
local shouldundeploy = attacking and not inradius and not moving
--Print("avoca is %s mainroom is %s shouldundeploy is %s", self.avoca, self.mainroom, shouldundeploy) 
  
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





function ARC:Instruct()
   --Print("Arc instructing")
   -- CheckHivesForScan(self)
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

    function ARC:OnDamageDone(doer, target)
    
        if doer == self then
         self:AddXP(self:GetAddXPAmount())
         self:AddHealth(100)
            
        end
        
    end
    


end//server

function ARC:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    if self.mainroom then
      if  not self:GetInAttackMode() then
    unitName = string.format(Locale.ResolveString("StructureFinder (%s)") )
    end
   elseif self.avoca then 
       unitName = string.format(Locale.ResolveString("Hive-Payload (%s)") )
   end
return unitName
end  

Shared.LinkClassToMap("ARC", ARC.kMapName, networkVars)