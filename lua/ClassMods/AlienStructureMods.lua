

function Harvester:GetCanAutoBuild()

return true

end


if Server then


    local orig_NutrientMist_Perform = NutrientMist.Perform
function NutrientMist:Perform()
 orig_NutrientMist_Perform(self)
 
     local entities = GetEntitiesWithMixinForTeamWithinRange("Webable", 1, self:GetOrigin(), NutrientMist.kSearchRange)
    
    for index, entity in ipairs(entities) do
        
        entity:SetWebbed(4)
        
    end
end 





end