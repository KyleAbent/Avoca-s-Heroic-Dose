--Kyle 'Avoca Abent'
--But messy but whatevs. Maybe easier to pull the techids from TechButtons and tier them that way.
kMarineResearchDelay = 5

local function TresCheck(cost)
    return GetGamerules().team1:GetTeamResources() >= cost
end
local function DeductTres(cost)
          local marineteam = GetGamerules().team1
          marineteam:SetTeamResources(marineteam:GetTeamResources() - cost)
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
    DeductTres(cost)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
   self:SetResearching(techNode, self)
   else return true 
   end
   
end
function PrototypeLab:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    if GetHasTech(self, kTechId.ExosuitTech)  then return false end 
      if not GetHasTech(self, kTechId.AdvancedWeaponry) and not GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return true end
    
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
    DeductTres(cost)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
   self:SetResearching(techNode, self)
      else return true 
   end
   
end
function PrototypeLab:UpdateResearch(deltaTime)
 if not self.timeLastUpdateCheck or self.timeLastUpdateCheck + 15 < Shared.GetTime() then 
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
    if researchNode then
        local gameRules = GetGamerules()
        local projectedminutemarktounlock = 60
        local currentroundlength = ( Shared.GetTime() - gameRules:GetGameStartTime() )
        if researchNode:GetTechId() == kTechId.JetpackTech then
           projectedminutemarktounlock = math.random(300, 420)
        elseif researchNode:GetTechId() == kTechId.ExosuitTech then
          projectedminutemarktounlock = math.random(300, 420)
        end --
       
        local progress = Clamp(currentroundlength / projectedminutemarktounlock, 0, 1)
        //Print("%s", progress)
        
        if progress ~= self.researchProgress then
        
            self.researchProgress = progress
            researchNode:SetResearchProgress(self.researchProgress)
            
            local techTree = self:GetTeam():GetTechTree()
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
            
            // Update research progress
            if self.researchProgress == 1 then
                // Mark this tech node as researched
                researchNode:SetResearched(true)
                
                techTree:QueueOnResearchComplete(self.researchingId, self)
                
            end --
        
        end --
        
    end  --
            self.timeLastUpdateCheck = Shared.GetTime()
    end
end
function ArmsLab:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
     if GetHasTech(self, kTechId.Armor3) then return false end
       if not GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return false end
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
    DeductTres(cost)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
                 self:SetResearching(techNode, self)
      else return true         
   end
end

function ArmsLab:UpdateResearch(deltaTime)
 if not self.timeLastUpdateCheck or self.timeLastUpdateCheck + 15 < Shared.GetTime() then 
   //Kyle Abent Siege 10.25.15 morning writing twtich.tv/kyleabent
   //11.10 updating to improve - Add in the adition of dynamic timers rather than set static timers
   //11.10 updating to improve - Performance via adding 15 seconds delay between reseearch updates rather than 25x per second.
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
    if researchNode then
        local gameRules = GetGamerules()
        local projectedminutemarktounlock = 60
        local currentroundlength = ( Shared.GetTime() - gameRules:GetGameStartTime() )
        local percentageofround = 1
        if researchNode:GetTechId() == kTechId.Weapons1 then
           secondmark = math.random(45, 90)
        elseif researchNode:GetTechId() == kTechId.Weapons2 then
           projectedminutemarktounlock = math.random(90, 180)
        elseif researchNode:GetTechId() == kTechId.Weapons3 then
           projectedminutemarktounlock = math.random(300, 380)
        elseif researchNode:GetTechId() == kTechId.Armor1 then
           projectedminutemarktounlock = math.random(45, 180)
          elseif researchNode:GetTechId() == kTechId.Armor2 then
           projectedminutemarktounlock =  math.random(180,240)
         elseif researchNode:GetTechId() == kTechId.Armor3 then
           projectedminutemarktounlock = math.random(420, 480)
        end --
      
       
      local progress = Clamp(currentroundlength / projectedminutemarktounlock, 0, 1)
        //Print("%s", progress)
        
        if progress ~= self.researchProgress then
        
            self.researchProgress = progress

            researchNode:SetResearchProgress(self.researchProgress)
            
            local techTree = self:GetTeam():GetTechTree()
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
            
            // Update research progress
            if self.researchProgress == 1 then

                // Mark this tech node as researched
                researchNode:SetResearched(true)
                
                techTree:QueueOnResearchComplete(self.researchingId, self)
                
            end --
        
        end --
        
    end --
       end
        self.timeLastUpdateCheck = Shared.GetTime()
    end
function Armory:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
    if (self:isa("AdvancedArmory") and GetHasTech(self, kTechId.HeavyMachineGunTech) ) then return false end
    if not  GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return true end

    
    local techid = nil
    
    if not GetHasTech(self, kTechId.MinesTech) then
    techid = kTechId.MinesTech
    elseif GetHasTech(self, kTechId.MinesTech) and not GetHasTech(self, kTechId.GrenadeTech) then
    techid = kTechId.GrenadeTech
    elseif GetHasTech(self, kTechId.GrenadeTech) and not GetHasTech(self, kTechId.ShotgunTech) then
    techid = kTechId.ShotgunTech
    elseif GetHasTech(self, kTechId.ShotgunTech) and not self:isa("AdvancedArmory") then
    techid = kTechId.AdvancedArmoryUpgrade   
    elseif self:isa("AdvancedArmory") and not GetHasTech(self, kTechId.HeavyMachineGunTech) then
    techid = kTechId.HeavyMachineGunTech   
    else
       return  
    end
    local cost = 1 --LookupTechData(techid, kTechDataCostKey, 0)
    if TresCheck(cost) then
    DeductTres(cost)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
    self:SetResearching(techNode, self)
       else return true 
    end
end
function Armory:UpdateResearch(deltaTime)
 if not self.timeLastUpdateCheck or self.timeLastUpdateCheck + 15 < Shared.GetTime() then 
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
       local defaultresearch = false
       local projectedminutemarktounlock = 60    
         local researchDuration = 4
        local gameRules = GetGamerules()
        local currentroundlength = ( Shared.GetTime() - gameRules:GetGameStartTime() )
    if researchNode  then
   
                    if researchNode:GetTechId() == kTechId.AdvancedArmoryUpgrade then
                       researchDuration =  LookupTechData(researchNode:GetTechId(), kTechDataResearchTimeKey, 0.01)
                       defaultresearch = true
                    end
     if not defaultresearch then 
        if researchNode:GetTechId() == kTechId.MinesTech then
           projectedminutemarktounlock = math.random(30, 90)
        elseif researchNode:GetTechId() == kTechId.GrenadeTech then
          projectedminutemarktounlock = math.random(30, 60)
        elseif researchNode:GetTechId() == kTechId.ShotgunTech then
          projectedminutemarktounlock = math.random(60, 120)
        elseif researchNode:GetTechId() == kTechId.HeavyMachineGunTech then
           projectedminutemarktounlock = math.random(180, 300)
         end
        end
        local modified = Clamp(currentroundlength / projectedminutemarktounlock, 0, 1)
        local default = self.researchProgress + deltaTime / researchDuration
        local progress = not defaultresearch and modified or default
        //Print("%s", progress)
        if progress ~= self.researchProgress then
        
            self.researchProgress = progress
            researchNode:SetResearchProgress(self.researchProgress)
            
            local techTree = self:GetTeam():GetTechTree()
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
            
            // Update research progress
            if self.researchProgress == 1 then
                // Mark this tech node as researched
                researchNode:SetResearched(true)
                
                techTree:QueueOnResearchComplete(self.researchingId, self)
                
            end --
        
        end --
        
    end --
    end
    self.timeLastUpdateCheck = Shared.GetTime()

end

    
    