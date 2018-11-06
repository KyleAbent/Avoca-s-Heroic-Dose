local orig_AlienTeam_InitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()
    local orig_PlayingTeam_InitTechTree = PlayingTeam.InitTechTree
    PlayingTeam.InitTechTree = function() end
    orig_PlayingTeam_InitTechTree(self)
    local orig_TechTree_SetComplete = self.techTree.SetComplete
    self.techTree.SetComplete = function() end
    orig_AlienTeam_InitTechTree(self)
    self.techTree.SetComplete = orig_TechTree_SetComplete
    
 
 self.techTree:AddPassive(kTechId.CragHiveTwo, kTechId.CragHive)

//self.techTree:AddBuildNode(kTechId.EggBeacon, kTechId.CragHive)
//self.techTree:AddBuildNode(kTechId.CommTunnel, kTechId.None)
//self.techTree:AddBuildNode(kTechId.StructureBeacon, kTechId.ShiftHive)
self.techTree:AddPassive(kTechId.PrimalScream,              kTechId.None, kTechId.None, kTechId.AllAliens)
self.techTree:AddPassive(kTechId.Onocide,              kTechId.None, kTechId.None, kTechId.AllAliens)
self.techTree:AddPassive(kTechId.AcidRocket, kTechId.Stab, kTechId.None, kTechId.AllAliens) -- though linking 

 self.techTree:AddResearchNode(kTechId.CragHeals1, kTechId.Shell, kTechId.None)
    self.techTree:AddResearchNode(kTechId.WhipBuff1, kTechId.Whip, kTechId.Spur)
    self.techTree:AddUpgradeNode(kTechId.DigestComm, kTechId.None, kTechId.None)
    self.techTree:AddResearchNode(kTechId.AlienHealth1,     kTechId.Shell, kTechId.BioMassNine) --Requirements WIP
    self.techTree:AddResearchNode(kTechId.SkulkRage,     kTechId.Spur, kTechId.BioMassSix) -- Six?? IDK!
    self.techTree:AddResearchNode(kTechId.GorgeBombBuff,     kTechId.Spur, kTechId.BioMassThree) 
    self.techTree:AddResearchNode(kTechId.HydraBuff1,     kTechId.Spur, kTechId.BioMassFour) --idk req.
    self.techTree:AddResearchNode(kTechId.APresBuff1,     kTechId.Harvester, kTechId.None) --I'm proud of this!
    self.techTree:AddResearchNode(kTechId.ATresBuff1,     kTechId.Harvester, kTechId.None) --I'm proud of this!

	 self.techTree:AddBuyNode(kTechId.Rebirth, kTechId.Shell, kTechId.None, kTechId.AllAliens)
     self.techTree:AddBuyNode(kTechId.Redemption, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    
    
   -- self.techTree:AddResearchNode(kTechId.StructureHealth1,     kTechId.Shell, kTechId.BioMassNine)

    
--self.techTree:AddResearchNode(kTechId.LerkHealth,     kTechId.Shell, kTechId.None)
--self.techTree:AddResearchNode(kTechId.FadeHealth,     kTechId.Shell, kTechId.None)
--self.techTree:AddResearchNode(kTechId.OnosHealth,     kTechId.Shell, kTechId.None)
--self.techTree:AddBuildNode(kTechId.PlaceTechPoint, kTechId.BioMassTen)



//self.techTree:AddPassive(kTechId.OnoGrow,              kTechId.None, kTechId.None, kTechId.AllAliens)
    
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end

/*
function AlienTeam:AddTeamResources(amount, isIncome)


    
    if GetHasTech(self,kTechId.ATresBuff1) and amount > 0 and isIncome then
     Print("(1)amounts is %s",amount)
     Print("(2)amounts is %s", amount * 1.05)

        self.totalTeamResourcesCollected = self.totalTeamResourcesCollected + (amount * 1.05)
        self:SetTeamResources(self.teamResources + amount)
    else
        PlayingTeam.AddTeamResources(self, amount, isIncome)
    end
    

    
end
*/


//overwrite to remove scale with player count.
function AlienTeam:UpdateEggGeneration()

    if not self.timeLastEggUpdate then
        self.timeLastEggUpdate = Shared.GetTime()
    end

    if self.timeLastEggUpdate + kEggGenerationRate < Shared.GetTime() then

        local hives = GetEntitiesForTeam("Hive", self:GetTeamNumber())
        local builtHives = {}

        -- allow only built hives to spawn eggs
        for _, hive in ipairs(hives) do

            if hive:GetIsBuilt() and hive:GetIsAlive() then
                table.insert(builtHives, hive)
            end

        end

        for _, hive in ipairs(builtHives) do
            hive:UpdateSpawnEgg()
        end

        self.timeLastEggUpdate = Shared.GetTime()
    end

end




