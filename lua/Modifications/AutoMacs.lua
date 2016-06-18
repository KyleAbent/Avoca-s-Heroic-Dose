local function GetMacsAmount()
    local macs = 0
        for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                macs = macs + 1
         end
    return  macs
end

if Server then
  function RoboticsFactory:OnUpdate()
   if self.timeOfLastMacCheck == nil or Shared.GetTime() > self.timeOfLastMacCheck + 8 then
   --if self.automaticspawningmac then
        if self:GetTeam():GetTeamResources() >= kMACCost and ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.MAC, kTechDataSupply, 0)) and self.deployed and GetIsUnitActive(self) and self:GetResearchProgress() == 0 and not self.open and GetMacsAmount() <= 8 then
        
            self:OverrideCreateManufactureEntity(kTechId.MAC)
            self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kMACCost )
        end
   -- end
    self.timeOfLastMacCheck = Shared.GetTime()  
    end
end
end