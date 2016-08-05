--Kyle 'Avoca Abent'
kMarineResearchDelay = 5
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
function Conductor:AutoBioMass()
          for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             hive:AddTimedCallback(Hive.UpdateManually, 15)
          end
end
function Hive:UpdateManually()
   if Server then  
     self:UpdatePassive()
   end
   return true
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
    elseif techid == nil and self.bioMassLevel <= 2 then
    techid =kTechId.ResearchBioMassTwo    --Prolly easier to just read techtree and their requirements no?
    end
    
    if techid == nil then return true end
    local cost = LookupTechData(techid, kTechDataCostKey, 0)
    if TresCheck(cost) then
    DeductTres(cost, 2)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
   self:SetResearching(techNode, self)
   end
   
   
end

function RoboticsFactory:OnConstructionComplete()
self:AddTimedCallback(RoboticsFactory.UpdateManually, 4)
 self.deployed = true
end
function RoboticsFactory:UpdateManually()
   if Server then  
     self:UpdatePassive()
   end
   return true
end
function ArmsLab:UpdateManually()
   if Server then  
     self:UpdatePassive()
   end
   return true
end
function ArmsLab:OnConstructionComplete()
self:AddTimedCallback(ArmsLab.UpdateManually, kMarineResearchDelay)
end
function ArmsLab:UpdateManually()
   if Server then  
     self:UpdatePassive()
   end
   return true
end
function PrototypeLab:OnConstructionComplete()
self:AddTimedCallback(PrototypeLab.UpdateManually, kMarineResearchDelay)
end
function PrototypeLab:UpdateManually()
   if Server then  
     self:UpdatePassive()
   end
   return true
end
function Armory:OnConstructionComplete()
    self:AddTimedCallback(Armory.UpdateManually, kMarineResearchDelay)
end
function Armory:UpdateManually()
   if Server then  
     self:UpdatePassive()
   end
   return true
end

function RoboticsFactory:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
       if self:GetTechId() == kTechId.ARCRoboticsFactory  then
           return false
     end
   if not GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return true end
    
    local techid = nil
    
    if self:GetTechId() ~= kTechId.ARCRoboticsFactory then
    techid = kTechId.UpgradeRoboticsFactory
    else
       return  
    end
    
    local cost = 1 --LookupTechData(techid, kTechDataCostKey, 0)
    if TresCheck(cost) then
    DeductTres(cost, 1)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
   self:SetResearching(techNode, self)
   else return true 
   end
   
end
function PrototypeLab:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    if GetHasTech(self, kTechId.ExosuitTech)  then return false end 
      if not GetHasTech(self, kTechId.Weapons2) or not GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return true end
    
    local techid = nil
    
    if not GetHasTech(self, kTechId.JetpackTech) then
    techid = kTechId.JetpackTech
    elseif GetHasTech(self, kTechId.JetpackTech) and not GetHasTech(self, kTechId.ExosuitTech) then
    techid = kTechId.ExosuitTech
    else
       return  
    end
    
    local cost = 1 --LookupTechData(techid, kTechDataCostKey, 0)
    if TresCheck(cost) then
    DeductTres(cost, 1)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
   self:SetResearching(techNode, self)
      else return true 
   end
   
end
function ArmsLab:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
     if GetHasTech(self, kTechId.Armor3) then return false end
       if self:GetIsResearching() then return true end
    local techid = nil  
    
    if not GetHasTech(self, kTechId.Weapons1) then
    techid = kTechId.Weapons1
    --SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Weapons1Researching)
    elseif GetHasTech(self, kTechId.Weapons1) and not GetHasTech(self, kTechId.Armor1) then
    techid = kTechId.Armor1
    --SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Armor1Researching)
   elseif GetHasTech(self, kTechId.Armor1) and not GetHasTech(self, kTechId.Weapons2) then
    techid = kTechId.Weapons2
   --SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Weapons2Researching)
  elseif GetHasTech(self, kTechId.Weapons2) and not GetHasTech(self, kTechId.Armor2) then
    techid = kTechId.Armor2
    --SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Armor2Researching)
   elseif GetHasTech(self, kTechId.Armor2) and not GetHasTech(self, kTechId.Weapons3) then
    techid = kTechId.Weapons3
    --SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Weapons3Researching)
   elseif GetHasTech(self, kTechId.Weapons3) and not GetHasTech(self, kTechId.Armor3) then
    techid = kTechId.Armor3
    --SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Armor3Researching)
    else
       return  false
    end
    local cost = 1 --LookupTechData(techid, kTechDataCostKey, 0)
    if TresCheck(cost) then
    DeductTres(cost, 1)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
                 self:SetResearching(techNode, self)
      else return true         
   end
end
function Armory:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
    if (self:GetTechId() == kTechId.AdvancedArmory and GetHasTech(self, kTechId.HeavyMachineGunTech) ) then return false end
    if not  GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return true end

    
    local techid = nil
    
    if not GetHasTech(self, kTechId.MinesTech) then
    techid = kTechId.MinesTech
    elseif GetHasTech(self, kTechId.MinesTech) and not GetHasTech(self, kTechId.GrenadeTech) then
    techid = kTechId.GrenadeTech
    elseif GetHasTech(self, kTechId.GrenadeTech) and not GetHasTech(self, kTechId.ShotgunTech) then
    techid = kTechId.ShotgunTech
    elseif GetHasTech(self, kTechId.ShotgunTech) and not self:GetTechId() == kTechId.AdvancedArmory then
    --techid = kTechId.AdvancedArmoryUpgrade   
     self:SetTechId(kTechId.AdvancedArmory)
    elseif self:GetTechId() == kTechId.AdvancedArmory and not GetHasTech(self, kTechId.HeavyMachineGunTech) then
    techid = kTechId.HeavyMachineGunTech   
    else
       return  
    end
    local cost = 1 --LookupTechData(techid, kTechDataCostKey, 0)
    if TresCheck(cost) then
    DeductTres(cost, 1)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
    self:SetResearching(techNode, self)
       else return true 
    end
end
    
    