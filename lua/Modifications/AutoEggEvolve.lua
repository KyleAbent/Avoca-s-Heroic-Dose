function Egg:OnUpdate(deltaTime) 
  
    if Server then
      if not self.lastupdate or Shared.GetTime() > self.lastupdate + 15 then
          if self:GetTechId() == kTechId.Egg and not self:GetIsResearching() then
         self:UpdateToGorgeEgg()
         end
     end
     --    self.lastupdate = Shared.GetTime()
    end
  
end


if Server then
function Egg:UpdateToGorgeEgg()
       --    if self:GetTeamCanAfford(4) then
          --  self:DeductTres(4)
          local techNode = self:GetTeam():GetTechTree():GetTechNode( kTechId.GorgeEgg ) 
         self:SetResearching(techNode, self)
      --   else
            return self:GetTechId() == kTechId.Egg
        -- end

   
end
function Egg:UpdateToLerkEgg()
           --      if self:GetTeamCanAfford(8) then
         --   self:DeductTres(8)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( kTechId.LerkEgg ) 
         self:SetResearching(techNode, self)
      --    else
 --  return not self:isa("LerkEgg")
 --  end
   return self:GetTechId() ~= kTechId.Egg
end
function Egg:UpdateToFadeEgg()
      --             if self:GetTeamCanAfford(12) then
        --    self:DeductTres(12)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( kTechId.FadeEgg ) 
         self:SetResearching(techNode, self)
    --     end
   return not self:isa("FadeEgg")
end
function Egg:UpdateToOnosEgg()
      --  if self:GetTeamCanAfford(20) then
       --     self:DeductTres(20)
   local techNode = self:GetTeam():GetTechTree():GetTechNode( kTechId.OnosEgg ) 
         self:SetResearching(techNode,self)
       --   end
   return not self:isa("OnosEgg")
end

function Egg:OnResearchComplete(techId)
    
    local success = false    

    if techId == kTechId.GorgeEgg then
            self:UpgradeToTechId(techId)
           self:AddTimedCallback(Egg.UpdateToLerkEgg, 4)
     elseif techId == kTechId.LerkEgg then
             self:UpgradeToTechId(techId)
             self:AddTimedCallback(Egg.UpdateToFadeEgg, 4)
    elseif techId == kTechId.FadeEgg then
            self:UpgradeToTechId(techId)
            self:AddTimedCallback(Egg.UpdateToOnosEgg, 4)
    elseif techId == kTechId.OnosEgg then
        self:UpgradeToTechId(techId)
    end
    
    return success
    
end

/*
function Egg:UpdateResearch(deltaTime)
 if not self.timeLastUpdateCheck or self.timeLastUpdateCheck + 4 < Shared.GetTime() then 
   //Kyle Abent Siege 10.25.15 morning writing twtich.tv/kyleabent
   //11.10 updating to improve - Add in the adition of dynamic timers rather than set static timers
   //11.10 updating to improve - Performance via adding 15 seconds delay between reseearch updates rather than 25x per second.
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
    if researchNode then
        local gameRules = GetGamerules()
        local projectedminutemarktounlock = 60
        local currentroundlength = ( Shared.GetTime() - gameRules:GetGameStartTime() )
        if researchNode:GetTechId() == kTechId.GorgeEgg then
           projectedminutemarktounlock = math.random(30, 60)
        elseif researchNode:GetTechId() == kTechId.LerkEgg then
           projectedminutemarktounlock = math.random(120, 240)
          elseif researchNode:GetTechId() == kTechId.FadeEgg then
           projectedminutemarktounlock =  math.random(240,300)
         elseif researchNode:GetTechId() == kTechId.OnosEgg then
           projectedminutemarktounlock = math.random(310, 400)
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
*/
end