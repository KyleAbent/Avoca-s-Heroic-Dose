--Kyle 'Avoca' Abent
class 'BigArc' (ARC)
BigArc.kMapName = "bigarc"

local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"

function BigArc:OnCreate()
 ARC.OnCreate(self)
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
end
function BigArc:GetMaxHealth()
    return 8000
end
function BigArc:GetMaxArmor()
    return 2000
end
function BigArc:GiveDeploy()
self:GiveOrder(kTechId.ARCDeploy, self:GetId(), self:GetOrigin(), nil, true, true)
 self:AddTimedCallback(BigArc.Forgivemeforthis, 4)
 return false
end
function BigArc:Forgivemeforthis()
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
 return false
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
local function GetTechPoint(where)
    for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", where, 8)) do
         if techpoint then return techpoint end
    end
end
function BigArc:GetDamageType()
return kDamageType.StructuresOnly
end
local function BuildAlienHive(who)
     who:AddTimedCallback(function() 
     if who:GetAttached() == nil then 
     local hive = who:SpawnCommandStructure(2)
     hive:SetConstructionComplete()
     end
     
          local nearestPower = GetNearest(who:GetOrigin(), "PowerPoint", 1)
       if nearestPower and not nearestPower:GetIsDisabled() then
              nearestPower:Kill()
       end
       
     end, 8)
end
function BigArc:OnKill(attacker, doer, point, direction)
local child = GetTechPoint(self:GetOrigin())
if Server then AddPayLoadTime(8) end
BuildAlienHive(child)
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
function BigArc:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("BigArc") )
return unitName
end  
function BigArc:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end
function BigArc:OnAdjustModelCoords(coords)
    
    	local scale = 4 
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
        
    return coords
    
end
function BigArc:OnGetMapBlipInfo()
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

if Server then
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
        RadiusDamage(hitEntities, self.targetPosition, ARC.kSplashRadius, 2000, self, true)

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

--all this just to modify damage -.-

function AvocaArc:OnTag(tagName)

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
        
      --  self:AdjustMaxHealth(kARCDeployedHealth * 4)
        
       -- local currentArmor = self:GetArmor()
       -- if currentArmor ~= 0 then
       --     self.undeployedArmor = currentArmor
       -- end
        
      --  self:SetMaxArmor(kARCDeployedArmor)
      --  self:SetArmor(self.deployedArmor)
        
    elseif tagName == "undeploy_end" then
    
        self.deployMode = ARC.kDeployMode.Undeployed
        
      --  self:AdjustMaxHealth(kARCHealth * 4)
       -- self.deployedArmor = self:GetArmor()
       -- self:SetMaxArmor(kARCArmor * 2)
       -- self:SetArmor(self.undeployedArmor)

    end
    
end

end



Shared.LinkClassToMap("BigArc", BigArc.kMapName, networkVars)