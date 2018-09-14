
local networkVars = 
{
  addBonus = "integer",
}



local origC = PowerPoint.OnCreate
function PowerPoint:OnCreate()
   origC(self)
   self.addBonus = 100
end



function PowerPoint:OnAddHealth()
   self:AddArmor(1)
end




/*

function PowerPoint:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
        coords.xAxis = coords.xAxis * 2
        coords.yAxis = coords.yAxis * 1
        coords.zAxis = coords.zAxis * 2
    return coords
end
*/

function PowerPoint:OnAddHealth()
   self:AddArmor(1)
end


local kDestructionBuildDelay = 1

function GetPowerPointRecentlyDestroyed(self)
    return (self.timeOfDestruction + kDestructionBuildDelay) > Shared.GetTime()
end


local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
     return player  --who:SetOwner(player)
    end
end

function PowerPoint:SpawnSurgeForEach(where, who)
           local marine = FindNewParent(who)
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation:GetName() or ""
           if not wherelocation then return end
           
     for _, eligable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct", 2, where, 72)) do
        -- if not eligable:isa("Harvester") and not eligable:isa("Cyst") and not eligable:isa("Hive") then --and not GetIsPointInMarineBase(eligable:GetOrigin()) then
           local location = GetLocationForPoint(eligable:GetOrigin())
           local locationName = location and location:GetName() or ""
           local sameLocation = locationName == wherelocation
          if sameLocation then 
                eligable:DeductHealth(400, marine, nil, true, false, true)
                eligable:TriggerEffects("arc_hit_primary")
          end --
        -- end
     end--
     
end
local orig_PowerPoint_StopDamagedSound = PowerPoint.StopDamagedSound
    function PowerPoint:StopDamagedSound()
    orig_PowerPoint_StopDamagedSound(self)
        if self:GetHealthScalar() ~= 1 then return end
         self:SpawnSurgeForEach(self:GetOrigin(), self)
         --  if Server then
         --       self:AdjustMaxHealth(self:GetMaxHealth() + 250)
          --      self:AdjustMaxArmor(self:GetMaxArmor() + 25)
          -- end
          --self:SetArmor(kPowerPointArmor) -- macs dont weld armor. Hm.
        -- AddPayLoadTime(kTimeAddPowerBuilt)
       -- local nearestHarvester = GetNearest(self:GetOrigin(), "Harvester", 2, function(ent) return LocationsMatch(self,ent)  end)
      -- if nearestHarvester then nearestHarvester:Kill() end
   end
   
/*
   
local orig_PowerPoint_OnKill = PowerPoint.OnKill
    function PowerPoint:OnKill(attacker, doer, point, direction)
    orig_PowerPoint_OnKill(self, attacker, doer, point, direction)
    
      local  PanicAttackCount = GetEntitiesForTeam( "PanicAttack", 2 )
      if #PanicAttackCount < 18 then 
             for i = 1 ,math.random(1, ( 18 - #PanicAttackCount ) * mult ) do
             local panicattack = CreateEntity(PanicAttack.kMapName, FindFreeSpace(self:GetOrigin(), 8, 24), 2)
             end
      end     
       
    end
   */ 

    
    
    function PowerPoint:GetCanBeUsedConstructed(byPlayer)
    return false
end

function PowerPoint:GetCanBeUsed(player, useSuccessTable)


        useSuccessTable.useSuccess = false

    
end


if Server then


local origK = PowerPoint.OnKill
 function PowerPoint:OnKill(attacker, doer, point, direction)
    
       origK(self, attacker, doer, point, direction)
     --  self:AdjustMaxHealth(self:GetMaxHealth() + 100)
       --self:AdjustMaxArmor(self:GetMaxArmor() + 10)
        kPowerPointHealth = kPowerPointHealth + 10
        kPowerPointArmor = kPowerPointArmor + 5
        
     end

/*
local origW = PowerPoint.OnWeldOverride
function PowerPoint:OnWeldOverride(entity, elapsedTime)
        if self:GetHealthScalar() == 1 and self:GetPowerState() == PowerPoint.kPowerState.destroyed then
            self.health = kPowerPointHealth + self.addBonus
            self.armor = kPowerPointArmor + (self.addBonus/10)
            self:SetMaxHealth(kPowerPointHealth + self.addBonus)
            self:SetMaxArmor(kPowerPointArmor + (self.addBonus/10) )
            self.addBonus = self.addBonus + 100
        end
                  origW(self, entity, elapsedTime)
        
    end
*/
    
end
