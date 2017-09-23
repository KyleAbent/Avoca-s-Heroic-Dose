if Server then


local orig_Egg_OnResearchComplete = Egg.OnResearchComplete
function Egg:OnResearchComplete(researchId)
    self:AddTimedCallback(Egg.ResearchSpecifics, 4 )
  return orig_Egg_OnResearchComplete(self, researchId) 
end

local origInit = Egg.OnInitialized
function Egg:OnInitialized()
   origInit(self)
    self:AddTimedCallback(Egg.ResearchSpecifics, 8 )
end

function Egg:GetClassToGestate()
    return self:GetMapNameOf()
end

function Egg:GetMapNameOf()
    local techId = self:GetTechId()
    local mapanme = LookupTechData(self:GetGestateTechId(), kTechDataMapName, Skulk.kMapName)
    --Print("mapanme is %s", mapanme)
    
    if techId == kTechId.GorgeEgg then
   --  Print("GorgeEgg")
        return Gorge.kMapName
    elseif techId == kTechId.LerkEgg  then
      --   Print("LerkEgg")
        return Lerk.kMapName
    elseif techId == kTechId.FadeEgg then
       --      Print("FadeEgg")
        return Fade.kMapName
    elseif techId == kTechId.OnosEgg  then
       --      Print("OnosEgg")
        return Onos.kMapName
    end
        return Skulk.kMapName
end

function Egg:ResearchSpecifics()
     
      local techIds = {}
         local tree = GetTechTree(2)
         
       if self:GetTechId() == kTechId.Egg  then
       table.insert(techIds, kTechId.GorgeEgg )
       elseif self:GetTechId() == kTechId.GorgeEgg then
               table.insert(techIds, kTechId.LerkEgg )
        elseif self:GetTechId() == kTechId.LerkEgg and  GetHasTech(self, kTechId.BioMassNine) then
               table.insert(techIds, kTechId.FadeEgg )
         elseif  self:GetTechId() == kTechId.FadeEgg   and GetHasTech(self, kTechId.BioMassNine) then
               table.insert(techIds, kTechId.OnosEgg )
             end
               
                local random = table.random(techIds)
                local techNode = tree:GetTechNode(random)
           
           if techNode then
                self:SetResearching(techNode, self)
                self.Auto = false
          end
          
      
      return false
end

end