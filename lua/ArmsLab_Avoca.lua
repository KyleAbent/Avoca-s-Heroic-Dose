
local originit = ArmsLab.OnInitialized
function ArmsLab:OnInitialized()

       originit(self)
       if not Server then return end
       if GetHasTech(self, kTechId.Armor3) then return end
       local techIds = {}
         table.insert(techIds, kTechId.Weapons1 )
         table.insert(techIds, kTechId.Weapons2 )
         table.insert(techIds, kTechId.Weapons3 )
         table.insert(techIds, kTechId.Armor1 )
         table.insert(techIds, kTechId.Armor2 )
         table.insert(techIds, kTechId.Armor3 )
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