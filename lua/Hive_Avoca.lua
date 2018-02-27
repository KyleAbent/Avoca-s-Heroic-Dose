
if Server then
local function CreateAlienMarker(where)
        
        
        local nearestarc = GetNearest(where, "ARC", 1, function(ent) return ent:GetIsAlive()  end)
        if not nearestarc then return end 
        
        local arcwhere = nearestarc:GetOrigin() 
        CreatePheromone(kTechId.ThreatMarker,arcwhere, 2) 
     
      

      
end

    function Hive:OnTakeDamage(damage, attacker, doer, point)

            if doer and doer:isa("ARC") then
               CreateAlienMarker(self:GetOrigin())
            end
        end
    
 end
   
 function Hive:OnAdjustModelCoords(modelCoords)
         local coords = modelCoords
    	local scale = ConditionalValue(GetTechPoint(self:GetOrigin()) ~= nil, 1, 0.5) 
        coords.xAxis = coords.xAxis * scale                       
        coords.yAxis = coords.yAxis * scale                           
        coords.zAxis = coords.zAxis * scale
   
    return coords
end

function Hive:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    -- webs can't be destroyed with bullet weapons
    if doer ~= nil then 
      --  local scale = ConditionalValue(GetTechPoint(self:GetOrigin()) ~= nil, 1, 0.5) 
      --  damageTable.damage = damageTable.damage * scale
        
        if doer:isa("ARC") and doer.avoca == true then
         damageTable.damage = damageTable.damage * 2
        end
        
    end

end

local kEggMinRange = 4
local kEggMaxRange = 22
/*
function Hive:GenerateEggSpawns(hiveLocationName) // random unbuilt power

    PROFILE("Hive:GenerateEggSpawns")

    self.eggSpawnPoints = { }

    local origin = GetRandomDisabledPower() 
      if origin == nil then 
       origin = self:GetModelOrigin() 
     else 
       origin = FindFreeSpace(origin:GetOrigin())
      end

    for _, eggSpawn in ipairs(Server.eggSpawnPoints) do
        if (eggSpawn - origin):GetLength() < kEggMaxRange then
            table.insert(self.eggSpawnPoints, eggSpawn)
        end
    end

    local minNeighbourDistance = 1.5
    local maxEggSpawns = 20
    local maxAttempts = maxEggSpawns * 10

    if #self.eggSpawnPoints >= maxEggSpawns then return end

    local extents = LookupTechData(kTechId.Egg, kTechDataMaxExtents, nil)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)

    -- pre-generate maxEggSpawns, trying at most maxAttempts times
    for index = 1, maxAttempts do
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, kEggMinRange, kEggMaxRange, EntityFilterAll())

        local location = spawnPoint and GetLocationForPoint(spawnPoint)
        local locationName = location and location:GetName() or ""

        local sameLocation = spawnPoint ~= nil and locationName == hiveLocationName

        if spawnPoint ~= nil and sameLocation then

            local tooCloseToNeighbor = false
            for _, point in ipairs(self.eggSpawnPoints) do

                if (point - spawnPoint):GetLengthSquared() < (minNeighbourDistance * minNeighbourDistance) then

                    tooCloseToNeighbor = true
                    break

                end

            end

            if not tooCloseToNeighbor then

                table.insert(self.eggSpawnPoints, spawnPoint)
                if #self.eggSpawnPoints >= maxEggSpawns then
                    break
                end

            end

        end

    end

    if #self.eggSpawnPoints < kAlienEggsPerHive * 2 then
        Print("Hive in location \"%s\" only generated %d egg spawns (needs %d). Place some egg enteties.", hiveLocationName, table.icount(self.eggSpawnPoints), kAlienEggsPerHive)
    end

end
*/
if Server then



local orig_Hive_OnResearchComplete = Hive.OnResearchComplete
function Hive:OnResearchComplete(researchId)
--Print("HiveOnResearchComplete")
  UpdateAliensWeaponsManually() 
    if researchId == kTechId.UpgradeToCragHive or researchId == kTechId.UpgradeToShadeHive or researchId ==  kTechId.UpgradeToShiftHive then
        self:AddTimedCallback(Hive.CheckForDoubleUpG, 4) 
      --  Print("Started Callback Hive CheckForDoubleUpG")
     end   
   --for now just updtate alien hp on all research completes b/c i dont feel like filtering the biomass -.-
      -- IfBioMassThenAdjustHp(self)
  return orig_Hive_OnResearchComplete(self, researchId) 
end



local function LocationsMatch(who,whom)
   
  local whoname = GetLocationForPoint(who:GetOrigin())
  local whomname = GetLocationForPoint(whom:GetOrigin())
  return true --whoname == whomname
end

/*

local function ToSpawnFormula(self,panicstospawn, where)
         for i = 1, panicstospawn do
                           local bitch = GetPayLoadArc()
                           if bitch and GetIsPointWithinHiveRadius(bitch:GetOrigin()) then
                           local spawnpoint = FindFreeSpace(bitch:GetOrigin(), 4, 8)
                              if spawnpoint then
                              local panicattack = CreateEntity(PanicAttack.kMapName, spawnpoint, 2)
                               panicattack:SetConstructionComplete()
                               panicattack:SetMature()
                               end
                           end
               end
            
end
local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end
local function SendAnxietyAttack(self, where, who)
         for i = 1, #who do
                           local panicattack = who[i]
                         --  local bitch = GetDeployedPayLoadArc()
                        --   if bitch and GetIsPointWithinHiveRadius(bitch:GetOrigin()) and GetRange(panicattack,bitch:GetOrigin()) >= 16 then                  
                           local spawnpoint = FindFreeSpace(where, 4, 8)
                              if spawnpoint then
                                    panicattack:SetOrigin(spawnpoint)
                               end
                         --  end
               end
end
local function PanicInitiate(self,where)
local panicattacks = {}

        for _, panicattack in ipairs(GetEntitiesWithinRange("PanicAttack", where, 9999)) do
                if panicattack:GetIsAlive() then
                       table.insert(panicattacks,panicattack) 
               end
       end
       
  local countofpanic = Clamp(table.count(panicattacks), 0, 8)
  local maxpanic = 4
  local panicstospawn = math.abs(maxpanic - countofpanic)
        panicstospawn = Clamp(panicstospawn, 1, 2)

            if panicstospawn >= 1 then ToSpawnFormula(self,panicstospawn, where) end
            
            if countofpanic >= 1 then
                SendAnxietyAttack(self, where, panicattacks) -- not sure
            end
            
end

local orig_Hive_OnTakeDamage = Hive.OnTakeDamage
function Hive:OnTakeDamage(damage, attacker, doer, point)

   if attacker then --and doer.avoca == true then 
         Print("PanicAttack Initiated")
         PanicInitiate(self,attacker:GetOrigin())
        --if self:GetIsBuilt() then  AddPayLoadTime(10)  end
    end
    
return orig_Hive_OnTakeDamage(self,damage, attacker, doer, point)
end



*/



/*

local function DestroyAvocaArcInRadius(where)
    for _, avocaarc in ipairs(GetEntitiesWithinRange("AvocaArc", where, kARCRange)) do
         if avocaarc then avocaarc:Kill() end
    end
end
*/




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
--biomass 0
    -- Play special tech point animation at same time so it appears that we bash through it.
    UpdateTypeOfHive(self)
    self:AddTimedCallback(Hive.UpdateManually, 15)
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
function Hive:UpdateManually()
   if Server then  
     self:UpdatePassive()
   end
   return self:GetIsAlive()
end

local function GetBioMassLevel()
           local teamInfo = GetTeamInfoEntity(2)
           local bioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
           return math.round(bioMass / 4, 1, 3)
end
function Hive:UpdatePassive()
       if GetHasTech(self, kTechId.Xenocide) or not GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return true end
           
           local teamInfo = GetTeamInfoEntity(2)
           local teambioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
           
    local techid = nil
    

      if teambioMass >= 2 and not GetHasTech(self, kTechId.Charge) then
    techid = kTechId.Charge
      elseif teambioMass >= 3 and not GetHasTech(self, kTechId.BileBomb) then
    techid = kTechId.BileBomb
      elseif teambioMass >= 3 and not GetHasTech(self, kTechId.MetabolizeEnergy) then
    techid = kTechId.MetabolizeEnergy
      elseif teambioMass >= 4 and not GetHasTech(self, kTechId.Leap) then
    techid = kTechId.Leap
      elseif teambioMass >= 4 and not GetHasTech(self, kTechId.Spores) then
    techid = kTechId.Spores
      elseif teambioMass >= 5 and not GetHasTech(self, kTechId.Umbra) then
    techid = kTechId.Umbra
      elseif teambioMass >= 5 and not GetHasTech(self, kTechId.MetabolizeHealth) then
    techid = kTechId.MetabolizeHealth
      elseif teambioMass >= 6 and not GetHasTech(self, kTechId.BoneShield) then 
    techid = kTechId.BoneShield
      elseif teambioMass >= 7 and not GetHasTech(self, kTechId.Stab) then 
    techid = kTechId.Stab
      elseif teambioMass >= 8 and not GetHasTech(self, kTechId.Stomp) then 
    techid = kTechId.Stomp
      elseif teambioMass >= 9 and not GetHasTech(self, kTechId.Xenocide) then 
    techid = kTechId.Xenocide
    end
    
        if techid == nil and self.bioMassLevel <= 1 then
    techid = kTechId.ResearchBioMassOne
    elseif techid == nil and self.bioMassLevel == 2 then
    techid = kTechId.ResearchBioMassTwo
    elseif techid == nil and self.bioMassLevel == 3 then
    techid = kTechId.ResearchBioMassThree
    elseif techid == nil and self.bioMassLevel == 4 then
    techid = kTechId.ResearchBioMassFour   
    end
    
    if techid == nil then return true end
    local cost = LookupTechData(techid, kTechDataCostKey, 0)
    if TresCheck(cost) then
    DeductTres(cost, 2)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
   self:SetResearching(techNode, self)
   end
   
   
end


    


end