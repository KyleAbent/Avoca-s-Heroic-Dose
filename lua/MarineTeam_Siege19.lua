local orig_MarineTeam_InitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()
    local orig_PlayingTeam_InitTechTree = PlayingTeam.InitTechTree
    PlayingTeam.InitTechTree = function() end
    orig_PlayingTeam_InitTechTree(self)
    local orig_TechTree_SetComplete = self.techTree.SetComplete
    self.techTree.SetComplete = function() end
    orig_MarineTeam_InitTechTree(self)
    self.techTree.SetComplete = orig_TechTree_SetComplete
    
    --self.techTree:AddBuildNode(kTechId.DropMAC,     kTechId.None, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropExosuit,     kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.ExtractorArmor1,     kTechId.Armor3, kTechId.None)
    --self.techTree:AddResearchNode(kTechId.JetpackFuel1,     kTechId.JetpackTech, kTechId.None)
    self.techTree:AddActivation(kTechId.SiegeBeacon,           kTechId.Observatory)  
    self.techTree:AddResearchNode(kTechId.UnlockAdvancedBeacon, kTechId.Observatory) 
    self.techTree:AddActivation(kTechId.AdvancedBeacon, kTechId.UnlockAdvancedBeacon) 
    self.techTree:AddResearchNode(kTechId.RunSpeed1,     kTechId.InfantryPortal, kTechId.Armor3) --I'm proud of this!
    self.techTree:AddResearchNode(kTechId.MacDefenseBuff,     kTechId.RoboticsFactory, kTechId.MAC) --I'm proud of this!
    self.techTree:AddResearchNode(kTechId.ClipSize1,     kTechId.InfantryPortal, kTechId.Weapons3) --I'm proud of this!
    self.techTree:AddResearchNode(kTechId.ArmoryBuff1,     kTechId.Armory, kTechId.AdvancedArmory) --I'm proud of this!
    self.techTree:AddResearchNode(kTechId.MPresBuff1,     kTechId.Extractor, kTechId.None) --I'm proud of this!
    self.techTree:AddResearchNode(kTechId.MTresBuff1,     kTechId.Extractor, kTechId.None) --I'm proud of this!

    self.techTree:AddBuyNode(kTechId.DualWelderExosuit, kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddBuyNode(kTechId.DualFlamerExosuit, kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddBuyNode(kTechId.WeldFlamerExosuit, kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddBuyNode(kTechId.RailgunWelderExoSuit, kTechId.ExosuitTech, kTechId.None)
     self.techTree:AddBuyNode(kTechId.RailgunFlamerExoSuit, kTechId.ExosuitTech, kTechId.None)
      
     self.techTree:AddUpgradeNode(kTechId.BackupBattery, kTechId.SentryBattery, kTechId.None)
    -- self.techTree:AddResearchNode(kTechId.AdvBeacTech,          kTechId.PhaseTech) 
   --  self.techTree:AddActivation(kTechId.AdvancedBeacon, kTechId.None) 
  --  self.techTree:AddActivation(kTechId.MacSpawnOn,                kTechId.RoboticsFactory,          kTechId.None)
   -- self.techTree:AddActivation(kTechId.MacSpawnOff,                kTechId.RoboticsFactory,          kTechId.None)
   -- self.techTree:AddActivation(kTechId.ArcSpawnOn,                kTechId.ARCRoboticsFactory,          kTechId.None)
   -- self.techTree:AddActivation(kTechId.ArcSpawnOff, kTechId.ARCRoboticsFactory, kTechId.None)
   -- self.techTree:AddBuildNode(kTechId.BackupLight,            kTechId.None,                kTechId.None)
   -- self.techTree:AddBuyNode(kTechId.DualWelderExosuit, kTechId.ExosuitTech, kTechId.None)
  --  self.techTree:AddBuyNode(kTechId.DualFlamerExosuit, kTechId.ExosuitTech, kTechId.None)
  -- self.techTree:AddTargetedBuyNode(kTechId.JumpPack, kTechId.JetpackTech, kTechId.None)
    
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end


local origInitial = MarineTeam.SpawnInitialStructures
function MarineTeam:SpawnInitialStructures(techPoint)   --Not convenient to copy local function from marineteam exactly as written just to place more than default IP amount.
    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
	for i = 1, 3 do
              local spawnPoint = GetRandomBuildPosition( kTechId.InfantryPortal, techPointOrigin, kInfantryPortalAttachRange )
              spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
                  if spawnPoint then
                  local ip = CreateEntity(InfantryPortal.kMapName, spawnPoint, self:GetTeamNumber())
                  SetRandomOrientation(ip)
                  ip:SetConstructionComplete()
                  end
	end

return origInitial(self,techPoint)
end


