



 function Hive:OnAdjustModelCoords(modelCoords)
         local coords = modelCoords
    	local scale = ConditionalValue(GetTechPoint(self:GetOrigin()) ~= nil, 1, 0.5) 
        coords.xAxis = coords.xAxis * scale                       
        coords.yAxis = coords.yAxis * scale                           
        coords.zAxis = coords.zAxis * scale
   
    return coords
end

function Hive:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)


    if doer ~= nil then 

        
        if doer:isa("ARC") and doer.avoca == true then
         damageTable.damage = damageTable.damage * 2
        end
        
    end

end

if Server then



local orig_Hive_OnResearchComplete = Hive.OnResearchComplete
function Hive:OnResearchComplete(researchId)
  UpdateAliensWeaponsManually() 
    if researchId == kTechId.UpgradeToCragHive or researchId == kTechId.UpgradeToShadeHive or researchId ==  kTechId.UpgradeToShiftHive then
        self:AddTimedCallback(Hive.CheckForDoubleUpG, 4) 
     end   
  return orig_Hive_OnResearchComplete(self, researchId) 
end



local function LocationsMatch(who,whom)
   
  local whoname = GetLocationForPoint(who:GetOrigin())
  local whomname = GetLocationForPoint(whom:GetOrigin())
  return true --whoname == whomname
end





local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

local function BuildRoomPower(who)

     local nearestPower = GetNearest(who:GetOrigin(), "PowerPoint", 1, function(ent) return LocationsMatch(who,ent)  end)
       if nearestPower and nearestPower:GetIsDisabled() then
            --local cheaptrick = CreateEntity(PowerPoint.kMapName, nearestPower:GetOrigin(), 1)
            nearestPower:OnConstructionComplete()
            nearestPower:SpawnSurgeForEach(nearestPower:GetOrigin(), nearestPower)
               -- DestroyEntity(nearestPower) 
       end
       
       
    -- who:AddTimedCallback(function() 
--     local bigarc = CreateEntity(BigArc.kMapName, who:GetOrigin(), 1)
 --    bigarc:GiveDeploy()
    --   local cc = CreateEntity(CommandStation.kMapName, who:GetOrigin(), 1)
   --    cc:SetConstructionComplete()
   --  end, 8)
     
end



local orig_Hive_OnKill = Hive.OnKill
function Hive:OnKill(attacker, doer, point, direction)
 --self:UpdateAliensWeaponsManually()
--if self:GetIsBuilt() then AddPayLoadTime(16) end
--local child = GetTechPoint(self:GetOrigin())
BuildRoomPower(self)
--DestroyAvocaArcInRadius(self:GetOrigin())
--child:SetIsVisible(false)
 return orig_Hive_OnKill(self,attacker, doer, point, direction)
end
/*
local orig_Hive_OnResearchComplete = Hive.OnResearchComplete
function Hive:OnResearchComplete(researchId)
 self:UpdateAliensWeaponsManually()
 return orig_Hive_OnResearchComplete(researchId, self)
end
*/
local function TresCheck(cost)
    return GetGamerules().team1:GetTeamResources() >= cost
end
local function DeductTres(cost,teamnum)
       if teamnum == 1 then
          local marineteam = GetGamerules().team1
          marineteam:SetTeamResources(marineteam:GetTeamResources() - cost)
      else
          local alienteam = GetGamerules().team2
          alienteam:SetTeamResources(alienteam:GetTeamResources() - cost)
      end
end

local orig_Hive_OnDestroy = Hive.OnDestroy
function Hive:OnDEstroy()
orig_Hive_OnDestroy(self)
UpdateAliensWeaponsManually()
end

function Hive:OnConstructionComplete()

  if Server then
    self.bioMassLevel = 3
  end
  
  
--biomass 0
    -- Play special tech point animation at same time so it appears that we bash through it.
    UpdateTypeOfHive(self)
    local attachedTechPoint = self:GetAttached()
    if attachedTechPoint then
        attachedTechPoint:SetIsSmashed(true)
    else
        Print("Hive not attached to tech point")
    end
    
    local team = self:GetTeam()
    
    if team then
        team:OnHiveConstructed(self)
    end
    
    if self.hiveType == 1 then
        self:OnResearchComplete(kTechId.UpgradeToCragHive)
    elseif self.hiveType == 2 then
        self:OnResearchComplete(kTechId.UpgradeToShadeHive)
    elseif self.hiveType == 3 then
        self:OnResearchComplete(kTechId.UpgradeToShiftHive)
    end

    local cysts = GetEntitiesForTeamWithinRange( "Cyst", self:GetTeamNumber(), self:GetOrigin(), self:GetCystParentRange())
    for _, cyst in ipairs(cysts) do
        cyst:ChangeParent(self)
    end
end



-- overwrite get rid of scale with player count

function Hive:UpdateSpawnEgg()

    local success = false
    local egg

    local eggCount = self:GetNumEggs()
    if eggCount < kAlienEggsPerHive and not GetConductor():GetIsPhaseFourBoolean() then

        egg = self:SpawnEgg()
        success = egg ~= nil

    end

    return success, egg

end

function Hive:HatchEggs() --overwrite get rid of scaleplayer
    local amountEggsForHatch = kEggsPerHatch
    local eggCount = 0
    for i = 1, amountEggsForHatch do
        local egg = self:SpawnEgg(true)
        if egg then eggCount = eggCount + 1 end
    end

    if eggCount > 0 then
        self:TriggerEffects("hatch")
        return true
    end

    return false
end

function Hive:GetNumEggs() --Well all 3 hives in same location, and if each hive is suppose to have X eggs then assign them the hive id via egg

    local numEggs = 0
    local eggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())

    for index, egg in ipairs(eggs) do

        if   self == egg:GetHive()  and egg:GetIsAlive() and egg:GetIsFree() and not egg.manuallySpawned then
            numEggs = numEggs + 1
        end

    end

    return numEggs

end
    
    


end