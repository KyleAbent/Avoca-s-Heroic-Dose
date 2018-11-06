

local originit = EvolutionChamber.OnInitialized
function EvolutionChamber:OnInitialized()
        
       originit(self)
       if not Server then return end
       local techIds = {}
               table.insert(techIds, kTechId.Charge )
               table.insert(techIds, kTechId.BileBomb )
               table.insert(techIds, kTechId.MetabolizeEnergy )
               table.insert(techIds, kTechId.Leap )
               table.insert(techIds, kTechId.Spores )
               table.insert(techIds, kTechId.Umbra )
               table.insert(techIds, kTechId.MetabolizeHealth )
               table.insert(techIds, kTechId.BoneShield )
               table.insert(techIds, kTechId.Stab )
               table.insert(techIds, kTechId.Stomp )
               table.insert(techIds, kTechId.Xenocide )
         
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