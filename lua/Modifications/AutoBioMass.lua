

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
    DeductTres(cost)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
   self:SetResearching(techNode, self)
   end
   
   
end