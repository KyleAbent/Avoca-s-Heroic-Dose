--Kyle 'Avoca' Abent

class 'Researcher' (Entity) 
Researcher.kMapName = "researcher"


local networkVars = 
{
}
function Researcher:OnCreate() 
   for i = 1, 8 do
     Print("reseearcher created")
   end
           if Server then
              self:AddTimedCallback(Researcher.Calculate, 16)
            end
end
--help from commanderbrain.lua
local function ResearchEachTechButton(who)
local techIds = who:GetTechButtons() or {}
                       for _, techId in ipairs(techIds) do
                     if techId ~= kTechId.None then
                        if who:GetCanResearch(techId) then
                          local tree = GetTechTree(who:GetTeamNumber())
                         local techNode = tree:GetTechNode(techId)
                          assert(techNode ~= nil)
                        if tree:GetTechAvailable(techId) then who:SetResearching(techNode, who) end
                         end
                      end
                  end
end
function Researcher:Calculate()
            for _, researchable in ipairs(GetEntitiesWithMixinForTeam("Research", 1)) do
                 ResearchEachTechButton(researchable) 
             end
              return true
end



Shared.LinkClassToMap("Researcher", Researcher.kMapName, networkVars)