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



end