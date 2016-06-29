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
    
    if self.bioMassLevel <= 1 then
    techid = kTechId.ResearchBioMassOne
    elseif self.bioMassLevel <= 2 then
    techid =kTechId.ResearchBioMassTwo    --Prolly easier to just read techtree and their requirements no?
      elseif teambioMass >= 2 and not GetHasTech(self, kTechId.Charge) then
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
    else
       return  false
    end
    
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
   self:SetResearching(techNode, self)
   
   
end
function Hive:UpdateResearch(deltaTime)
 if not self.timeLastUpdateCheck or self.timeLastUpdateCheck + 15 < Shared.GetTime() then 
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
       local defaultresearch = false
       local projectedminutemarktounlock = 60
       local gameRules = GetGamerules()
       local currentroundlength = ( Shared.GetTime() - gameRules:GetGameStartTime() )
       local researchDuration = 4
    if researchNode then
                    if researchNode:GetTechId() == kTechId.ResearchBioMassOne then
                       elseif researchNode:GetTechId() == kTechId.ResearchBioMassTwo then
                       researchDuration = 200 -- 10 mins == biomass 9 == onos eggs avail and stomp avail == scale to difficulty as per flavor of personality
                       defaultresearch = true
                    end--
        if researchNode:GetTechId() == kTechId.BileBomb then
           projectedminutemarktounlock = math.random(180,240)
      elseif researchNode:GetTechId() == kTechId.MetabolizeEnergy then
        projectedminutemarktounlock = math.random(180, 240)
      elseif researchNode:GetTechId() == kTechId.Leap then
         projectedminutemarktounlock = math.random(180, 240)
      elseif researchNode:GetTechId() == kTechId.Spores then
         projectedminutemarktounlock = math.random(280, 300)
      elseif researchNode:GetTechId() == kTechId.Umbra then
         projectedminutemarktounlock = math.random(320, 360)
      elseif researchNode:GetTechId() == kTechId.MetabolizeHealth then
         projectedminutemarktounlock = math.random(320, 360)
      elseif researchNode:GetTechId() == kTechId.BoneShield then 
         projectedminutemarktounlock = math.random(360, 420)
      elseif researchNode:GetTechId() == kTechId.Stab then 
        projectedminutemarktounlock = math.random(360, 420)
      elseif researchNode:GetTechId() == kTechId.Stomp then 
        projectedminutemarktounlock = math.random(420, 480)
      elseif researchNode:GetTechId() == kTechId.Xenocide then 
        projectedminutemarktounlock = math.random(420, 500)
          
        end --
      end  --
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
        
    end  --
            self.timeLastUpdateCheck = Shared.GetTime()
end