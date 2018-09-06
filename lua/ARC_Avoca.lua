PrecacheAsset("Glow/green/GlowTP.surface_shader")
local kAvocaWeedMaterial = PrecacheAsset("Glow/green/green.material")


--Script.Load("lua/Additions/LevelsMixin.lua")

local networkVars = 
{
 avoca = "boolean",
 lastCheck = "time",
  vortexCheck = "boolean",
}

--AddMixinNetworkVars(LevelsMixin, networkVars)

function ARC:SetIsACreditStructure(boolean)
    
self.isacreditstructure = boolean
self.avoca = false
self:GiveOrder(kTechId.ARCDeploy, self:GetId(), self:GetOrigin(), nil, true, true)
      --Print("AvocaMixin SetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
end

function ARC:GetIsACreditStructure()
    
       -- Print("AvocaMixin GetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
return self.isacreditstructure 
 

end


    
if Server then




    
    
local origInit = ARC.OnInitialized

function ARC:OnInitialized()
    origInit(self)
    -- self:AddTimedCallback(ARC.Instruct, 2.5)
    
    



    if  GetConductor():GetIsPhaseFourBoolean()  then 
     --  ARC.kMoveSpeed = 4
        ARC.kAttackDamage = kARCDamage*1.3
    elseif  GetConductor():GetIsPhaseThreeBoolean()  then 
       --ARC.kMoveSpeed = 3.5
        ARC.kAttackDamage = kARCDamage*1.2
    elseif  GetConductor():GetIsPhaseTwoBoolean()  then 
       --ARC.kMoveSpeed = 3
         ARC.kAttackDamage = kARCDamage*1.1
    elseif GetConductor():GetIsPhaseOneBoolean()  then
         --ARC.kMoveSpeed = 2.5
          ARC.kAttackDamage = kARCDamage*1.05
    end
     self.lastCheck = 0
     if  GetPayLoadArc() == nil and not self.isacreditstructure then
           self.avoca = true 
     end
     self.vortexCheck = false
end


    

function ARC:GetDamageType()
return kDamageType.StructuresOnly
end

function ARC:GetIsPL()
 if self.avoca then 
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


/*

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

*/



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
          
          return count>=3
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
                --  if who.avoca == true and  (distToTarget <= 8) and not hasFire(who) then
                 --  CreateEntity(FireFlameCloud.kMapName, enemy:GetOrigin() , 1) 
                   --Set parent nearby player
                  --  end
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
    /*
local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 8)

      for i = 1, #players do
        local ent = players[i]
           if not  who:GetInAttackMode() and  ent:isa("Marine") then ent:AddHealth(200) ent:AddHealth( math.random(4,8) ) end
         if ent:GetIsAlive() then return false end
      end
      
return not who.mainroom
*/
return false
end

local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end
function ARC:CheckVortex()
    local vortex =  GetNearest(self:GetOrigin(), "Vortex", 2)
     if not vortex then
          CreateEntity(CommVortex.kMapName, self:GetOrigin() , 2) 
     end
end


function ARC:GiveScan()

 --  if self.vortexCheck == true then 
 --   self.vortexCheck = false
 --   self:CheckVortex()
 --  end
  
   if not self:GetInAttackMode() or  self.targetPosition == nil then return end
   
 --   local where = GetNearestEligable(self):GetOrigin()

    if not hasScan(self, self.targetPosition ) then  
      CreateEntity(Scan.kMapName, self.targetPosition , 1) 
      end
      
    for _, shade in ipairs(GetEntitiesWithinRange("Shade", self.targetPosition, 20)) do
       if shade:GetIsBuilt() then
           shade.shouldInk = true  --better than shade onup scan check
           break -- one at a time?
       --  self.vortexCheck = true
         end
    end
    

end


local origu = ARC.OnUpdate
function ARC:OnUpdate(deltaTime)
    origu(self, deltaTime)
   
   
    if self.isacreditstructure and  GetIsTimeUp(self.lastCheck, 4)  then
      self.lastCheck = Shared.GetTime()
      self:GiveScan()
    end
    

end




     
local function GiveDeploy(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
--CreateEntity(Scan.kMapName, who:GetOrigin(), 1) 


end
local function GiveUnDeploy(who)
     --Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end



local function GetPowerBuilt(self)
    local choice = math.random(1,100)  
    local power = nil
     if choice >= 70 then
      power =  GetNearest(self:GetOrigin(), "PowerPoint", 1, function(ent) return ent:GetIsBuilt() and not ent:GetIsDisabled() and GetLocationForPoint(self:GetOrigin()) ~= GetLocationForPoint(ent:GetOrigin())   end) --or arc nearby and not in attack radius 
     else 
      power = GetRandomActivePower()
     end
     if power then
          --  Print("Power is %s", GetLocationForPoint(power:GetOrigin()).name)
            return power
     else
            return nil
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
local function MoveToHives(who) --Closest hive from origin
local where = who:GetOrigin()
 local hive =  GetNearest(where, "Hive", 2, function(ent) return not ent:GetIsDestroyed() end)
               if hive then
                  local origin = hive:GetOrigin() -- The arc should auto deploy beforehand
                  who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
                  return
                end  
end


local function MoveToMainRoom(self)
    local power = nil
    local phase = GetConductor().phase
    --Print("Phase is %s", phase)
    if phase == 1 then
           power = GetPowerBuilt(self)
    elseif phase == 2 then
           power = GetNearestEligable(self)
    elseif phase == 3 then
           power = GetNearestEligable(self)
    elseif phase == 4 then
           MoveToHives(self) --90 percent chance or so mething, else nearest or chance random
           return
    else
           power = GetPowerBuilt(self)
    end
    --local chance = 50 50 to random eligable?
      --GetRandomEligable(self)
    --  if power then --or chance
    --  else                                --GetRandomEligable is bad because for loop anyway
   --      power = GetNearestEligable(self) --GetRandomEligable(self) --getNEarest or getrandom is better dunno. chance it, better chance nerest
     -- end
         if not power then 
         power = GetNearestEligable(self)
         return 
        end
        if not power then return end
         local where = power:GetOrigin()
         if not where then return end
         self:GiveOrder(kTechId.Move, nil, where, nil, true, true)

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

function ARC:SpecificRules(phase)
--BuffPlayers(self)

local moving = self.mode == ARC.kMode.Moving     
--Print("moving is %s", moving) 
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
      if attacking then self:GiveScan() end
local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) or CheckForAndActAccordingly(self)  
local shouldstop = ShouldStop(self)
local shouldmove = not shouldstop and not moving and not inradius
      shouldstop = moving and shouldstop
local shouldattack = inradius and not attacking 
local shouldundeploy = attacking and not inradius and not moving
  
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
          if self.avoca == false then 
              MoveToMainRoom(self)
          else
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
   if not self:GetIsACreditStructure() then
   self:SpecificRules()
   end
   return true
end


    


end--server



function ARC:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
    local scale = ConditionalValue(self.avoca, 0.8, 1)
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    return coords
end





Shared.LinkClassToMap("ARC", ARC.kMapName, networkVars)