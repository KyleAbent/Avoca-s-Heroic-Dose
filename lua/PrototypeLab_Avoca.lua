local originit = PrototypeLab.OnInitialized
function PrototypeLab:OnInitialized()

       originit(self)
       if not Server then return end
       if GetHasTech(self, kTechId.JetpackTech) then return end
       local techIds = self:GetTechButtons()
         
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

--derp

function PrototypeLab:GetMinRangeAC()
return 35 / 3      
end 

local oldfunc = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
        local  otherbuttons = { kTechId.Jetpack, kTechId.DualMinigunExosuit, kTechId.DualRailgunExosuit, 
                                kTechId.DualFlamerExosuit, kTechId.DualWelderExosuit, kTechId.WeldFlamerExosuit, kTechId.RailgunWelderExoSuit, kTechId.RailgunFlamerExoSuit,}
        
               
           return otherbuttons
end
