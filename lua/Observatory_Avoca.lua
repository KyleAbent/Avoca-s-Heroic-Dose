local originit = Observatory.OnInitialized
function Observatory:OnInitialized()

       originit(self)
       if not Server then return end
       if GetHasTech(self, kTechId.PhaseTech) then return end
       local techIds = {}
         table.insert(techIds, kTechId.PhaseTech )
         
        local techTree = self:GetTeam():GetTechTree()
      --  local researchNode = techTree:GetTechNode(kTechId.AdvancedWeaponry)
        
         for i = 1, #techIds do
            local single = techIds[i]
            local researchNode = techTree:GetTechNode(single)
            if researchNode then
            researchNode:SetResearchProgress(1)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 1))
            researchNode:SetResearched(true)
            techTree:QueueOnResearchComplete(single, self)
            end
        end
        

    
end

function Observatory:GetMinRangeAC()
return kScanRadius   
end

function Observatory:OnPowerOn()
	 GetImaginator().activeObs =  GetImaginator().activeObs + 1;  
end

function Observatory:OnPowerOff()
	 GetImaginator().activeObs =  GetImaginator().activeObs - 1;  
end

 function Observatory:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetImaginator().activeObs =  GetImaginator().activeObs - 1;  
	  end
end