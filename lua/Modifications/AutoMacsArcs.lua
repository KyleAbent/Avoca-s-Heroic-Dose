local kOpenSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_open")
local kCloseSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_close")

local function GetMacsAmount()
    local macs = 0
        for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                macs = macs + 1
         end
    return  macs
end
local function GetArcsAmount()
    local arcs = 0
        for index, ARC in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                arcs = arcs + 1
         end
    return  arcs
end
local function ArcQualifications(self)
 local boolean = false
     if GetArcsAmount() <= 11 and
       -- self:GetTeam():GetTeamResources() >= kARCCost and 
      --    ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.ARC, kTechDataSupply, 0)) and 
            self.deployed and 
            GetIsUnitActive(self) and 
           self:GetResearchProgress() == 0 and
          not self.open then
            boolean = true
      end
      
      return boolean
end
local function MacQualifications(self)

 local boolean = false
     if GetMacsAmount() <= 7 and
      --  self:GetTeam():GetTeamResources() >= kMACCost and 
       --   ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.MAC, kTechDataSupply, 0)) and 
            self.deployed and 
            GetIsUnitActive(self) and 
           self:GetResearchProgress() == 0  and
          not self.open then
            boolean = true
      end
      
      return boolean
        
end
function RoboticsFactory:OnTag(tagName)
    
    PROFILE("RoboticsFactory:OnTag")

    if self.open and self.researchId ~= Entity.invalidId and tagName == "end" then

        self.builtEntity:Rollout(self, RoboticsFactory.kRolloutLength)
        
        
          if Server then
                local entity = self.builtEntity
                if entity:isa("ARC") then
                   entity:MoveToHives()
                end
          end
          
          self.builtEntity = nil
          
    end
    
    if tagName == "open_start" then
        StartSoundEffectAtOrigin(kOpenSound, self:GetOrigin())
    elseif tagName == "close_start" then
        StartSoundEffectAtOrigin(kCloseSound, self:GetOrigin())
    end
    
end


if Server then
  function RoboticsFactory:OnUpdate()
   if self.timeOfLastMacCheck == nil or Shared.GetTime() > self.timeOfLastMacCheck + 8 then
           if MacQualifications(self) then
           self:OverrideCreateManufactureEntity(kTechId.MAC)
           --self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kMACCost )
           elseif ArcQualifications(self) then
           self:OverrideCreateManufactureEntity(kTechId.ARC)
           end
           
    self.timeOfLastMacCheck = Shared.GetTime()  
    end
end
end