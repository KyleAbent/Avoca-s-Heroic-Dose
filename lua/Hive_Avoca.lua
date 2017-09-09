
 function Hive:OnAdjustModelCoords(modelCoords)
         local coords = modelCoords
    	local scale = 0.5 
        coords.xAxis = coords.xAxis * scale                       
        coords.yAxis = coords.yAxis * scale                           
        coords.zAxis = coords.zAxis * scale
   
    return coords
end

if Server then


function Hive:UpdateAliensWeaponsManually() ///Seriously this makes more sense than spamming some complicated formula every 0.5 seconds no?
 for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do 
        alien:HiveCompleteSoRefreshTechsManually() 
end
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

local function GetTechPoint(where)
    for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", where, 8)) do
         if techpoint then return techpoint end
    end
end



local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

local function BuildRoomPower(who)

     local nearestPower = GetNearest(who:GetOrigin(), "PowerPoint", 1, function(ent) return LocationsMatch(who,ent)  end)
       if nearestPower and nearestPower:GetIsDisabled() then
            local cheaptrick = CreateEntity(PowerPoint.kMapName, nearestPower:GetOrigin(), 1)
            cheaptrick:SetConstructionComplete()
                DestroyEntity(nearestPower) 
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
 self:UpdateAliensWeaponsManually()
--if self:GetIsBuilt() then AddPayLoadTime(16) end
--local child = GetTechPoint(self:GetOrigin())
BuildRoomPower(child)
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
self:UpdateAliensWeaponsManually()
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