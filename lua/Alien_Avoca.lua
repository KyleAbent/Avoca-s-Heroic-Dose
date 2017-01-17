
local orig_Alien_OnCreate = Alien.OnCreate
function Alien:OnCreate()
    orig_Alien_OnCreate(self)
    if Server then
     self:AddTimedCallback(function() UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId()) end, .8) 
    elseif Client then
        GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar")  
    end
end

if Server then





function Alien:HiveCompleteSoRefreshTechsManually()
UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId())
end


end
