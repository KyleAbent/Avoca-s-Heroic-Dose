function AlienTeam:GetMaxBioMassLevel()
    return 12
end

function AlienTeam:GetHive()
    for _, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
        if hive:GetIsBuilt() then
        
           return hive
        end

    end
    return nil
end

local orig_AlienTeam_InitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()
    local orig_PlayingTeam_InitTechTree = PlayingTeam.InitTechTree
    PlayingTeam.InitTechTree = function() end
    orig_PlayingTeam_InitTechTree(self)
    local orig_TechTree_SetComplete = self.techTree.SetComplete
    self.techTree.SetComplete = function() end
    orig_AlienTeam_InitTechTree(self)
    self.techTree.SetComplete = orig_TechTree_SetComplete
    

 
   
//self.techTree:AddBuildNode(kTechId.EggBeacon, kTechId.CragHive)
//self.techTree:AddBuildNode(kTechId.StructureBeacon, kTechId.ShiftHive)
//self.techTree:AddPassive(kTechId.PrimalScream,              kTechId.Spores, kTechId.None, kTechId.AllAliens)

--self.techTree:AddPassive(kTechId.OnoGrow,              kTechId.None, kTechId.None, kTechId.AllAliens)

//self.techTree:AddPassive(kTechId.AcidRocket, kTechId.Stab, kTechId.None, kTechId.AllAliens) -- though linking 

//self.techTree:AddPassive(kTechId.LerkBileBomb, kTechId.Spores, kTechId.None, kTechId.AllAliens)

   
    self.techTree:AddPassive(kTechId.CragHiveTwo, kTechId.CragHive)
  --  self.techTree:AddPassive(kTechId.ShiftHiveTwo, kTechId.ShiftHive)
 self.techTree:AddBuyNode(kTechId.Rebirth, kTechId.Shell, kTechId.None, kTechId.AllAliens)
   self.techTree:AddBuyNode(kTechId.Redemption, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    --self.techTree:AddBuyNode(kTechId.Hunger, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    --self.techTree:AddBuyNode(kTechId.ThickenedSkin, kTechId.Spur, kTechId.None, kTechId.AllAliens)
        
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end


