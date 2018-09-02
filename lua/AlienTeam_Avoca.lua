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
    

 
   
--self.techTree:AddBuildNode(kTechId.EggBeacon, kTechId.CragHive)
--self.techTree:AddBuildNode(kTechId.StructureBeacon, kTechId.ShiftHive)
--self.techTree:AddPassive(kTechId.PrimalScream,              kTechId.Spores, kTechId.None, kTechId.AllAliens)

--self.techTree:AddPassive(kTechId.OnoGrow,              kTechId.None, kTechId.None, kTechId.AllAliens)

--self.techTree:AddPassive(kTechId.AcidRocket, kTechId.Stab, kTechId.None, kTechId.AllAliens) -- though linking 

--self.techTree:AddPassive(kTechId.LerkBileBomb, kTechId.Spores, kTechId.None, kTechId.AllAliens)

   
    self.techTree:AddPassive(kTechId.CragHiveTwo, kTechId.CragHive)
  --  self.techTree:AddPassive(kTechId.ShiftHiveTwo, kTechId.ShiftHive)
 self.techTree:AddBuyNode(kTechId.Rebirth, kTechId.Shell, kTechId.None, kTechId.AllAliens)
   self.techTree:AddBuyNode(kTechId.Redemption, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    --self.techTree:AddBuyNode(kTechId.Hunger, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    --self.techTree:AddBuyNode(kTechId.ThickenedSkin, kTechId.Spur, kTechId.None, kTechId.AllAliens)
    self.techTree:AddPassive(kTechId.PrimalScream,              kTechId.None, kTechId.None, kTechId.AllAliens)
        
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end

local origInitial = AlienTeam.SpawnInitialStructures
function AlienTeam:SpawnInitialStructures(techPoint)   --Not convenient to copy local function from marineteam exactly as written just to place more than default IP amount.
    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
	for i = 1, 4 do
              local spawnPoint = GetRandomBuildPosition( kTechId.Crag, techPointOrigin, Crag.kHealRadius )
              spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
                  if spawnPoint then
                  local crag = CreateEntity(Crag.kMapName, spawnPoint, self:GetTeamNumber())
               --   SetRandomOrientation(ip)
                  crag:SetConstructionComplete()
                  end
	end

return origInitial(self,techPoint)
end
