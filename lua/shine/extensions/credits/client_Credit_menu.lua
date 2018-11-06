

Shine.VoteMenu:AddPage ("SpendStructuresCredit", function( self )
       local player = Client.GetLocalPlayer()
     if player:GetTeamNumber() == 1 then
		self:AddSideButton("Mac: "..gCreditStructureMacCost , function() Shared.ConsoleCommand ("sh_buy Mac credit")  end)
		self:AddSideButton("Arc: "..gCreditStructureArcCost , function() Shared.ConsoleCommand ("sh_buy Arc credit")  end)
		self:AddSideButton("Observatory: "..gCreditStructureObservatoryCost , function() Shared.ConsoleCommand ("sh_buy Observatory credit")  end)
		self:AddSideButton("Sentry: "..gCreditStructureSentryCost , function() Shared.ConsoleCommand ("sh_buy Sentry credit")  end)
		--self:AddSideButton("BackupBattery: "..gCreditStructureBackUpBatteryCost * kPresToStructureMult,  function() Shared.ConsoleCommand ("sh_buy BackupBattery credit")  end)
		self:AddSideButton("Armory: "..gCreditStructureArmoryCost , function() Shared.ConsoleCommand ("sh_buy Armory credit")  end)
    	self:AddTopButton("PhaseGate: "..gCreditStructurePhaseGateCost , function() Shared.ConsoleCommand ("sh_buy PhaseGate credit")  end)
		self:AddSideButton("BackupLight: "..gCreditStructureBackupLightCost , function() Shared.ConsoleCommand ("sh_buy BackupLight credit")  end)
		self:AddSideButton("InfantryPortal: "..gCreditStructureInfantryPortalCost , function() Shared.ConsoleCommand ("sh_buy InfantryPortal credit")  end)
        self:AddSideButton("RoboticsFactory: "..gCreditStructureRoboticsFactoryCost, function() Shared.ConsoleCommand ("sh_buy RoboticsFactory credit") end)
       -- self:AddSideButton("Wall: "..gCreditStructureWallCost, function() Shared.ConsoleCommand ("sh_buy Wall") end)    
   -- self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
    elseif player:GetTeamNumber() == 2 then
		if player:isa("Gorge") then
		self:AddTopButton("Tunnel@Hive: "..gCreditStructureCostTunnelToHive , function() Shared.ConsoleCommand ("sh_buycustom TunnelEntrance credit")  end)
        end
		--self:AddSideButton("PetDrifter: "..gCreditStructureCostPetDrifter, function() Shared.ConsoleCommand ("sh_buy PetDrifter")  end)
		self:AddSideButton("Drifter: "..gCreditStructureCostPerDrifter, function() Shared.ConsoleCommand ("sh_buy Drifter credit")  end)
		self:AddSideButton("Hydra: "..gCreditStructureCostHydra, function() Shared.ConsoleCommand ("sh_buy Hydra credit")  end)
		--self:AddSideButton("CredityEgg: "..gCreditStructureCostCredityEgg* kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy CredityEgg credit")  end)
		--self:AddSideButton("Drifter: "..gCreditStructureCostDrifter, function() Shared.ConsoleCommand ("sh_buy Drifter")  end)
		self:AddSideButton("Whip: "..gCreditStructureCostWhip, function() Shared.ConsoleCommand ("sh_buy Whip credit")  end)
		self:AddSideButton("Shift: "..gCreditStructureCostShift, function() Shared.ConsoleCommand ("sh_buy Shift credit")  end)
		self:AddSideButton("Shade: "..gCreditStructureCostShade, function() Shared.ConsoleCommand ("sh_buy Shade credit")  end)
		self:AddSideButton("Crag: "..gCreditStructureCostCrag, function() Shared.ConsoleCommand ("sh_buy Crag credit")  end)

   -- self:AddSideButton( "Clog(2)", function() Shared.ConsoleCommand ("sh_buy Clog")  end)
    --self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
   end

        self:AddBottomButton( "Back", function()self:SetPage("SpendCredit")end) 
end)
Shine.VoteMenu:AddPage ("SpendExpeniveCredit", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then
    elseif player:GetTeamNumber() == 2 then
		self:AddSideButton("EggBeacon: "..25, function() Shared.ConsoleCommand ("sh_buy EggBeacon credit")  end)
		self:AddSideButton("StructureBeacon: "..25, function() Shared.ConsoleCommand ("sh_buy StructureBeacon credit")  end)
    end
    self:AddBottomButton("Back", function()self:SetPage("SpendCredit")end)
end)

Shine.VoteMenu:AddPage ("SpendUpgradesCredit", function( self )
        local player = Client.GetLocalPlayer()
        
        if player.GetHasResupply and not player:GetHasResupply() then
        self:AddSideButton( "Resupply(5)", function() Shared.ConsoleCommand ("sh_buyupgrade Resupply credit")  end)
        end
        
        if player.GetHasLightArmor and not player:GetHasLightArmor() then
        self:AddSideButton( "LightArmor(5)", function() Shared.ConsoleCommand ("sh_buyupgrade LightArmor credit")  end)
        end
        
        if player.GetHasHeavyArmor and not player:GetHasHeavyArmor() then
        self:AddSideButton( "HeavyArmor(5)", function() Shared.ConsoleCommand ("sh_buyupgrade HeavyArmor credit")  end)
        end
        if player.GetHasNanoArmor and not player:GetHasNanoArmor() then
        self:AddSideButton( "RegenArmor(5)", function() Shared.ConsoleCommand ("sh_buyupgrade RegenArmor credit")  end)
        end
        
        if player.GetHasFireBullets and not player:GetHasFireBullets() then
        self:AddSideButton( "FireBullets(5)", function() Shared.ConsoleCommand ("sh_buyupgrade FireBullets credit")  end)
        end

        self:AddBottomButton( "Back", function()self:SetPage("SpendCredit")end) 
end)

Shine.VoteMenu:AddPage ("SpendGlowCredit", function( self )
        self:AddSideButton( "Purple(5)", function() Shared.ConsoleCommand ("sh_buyglow Purple credit")  end)
        self:AddSideButton( "Green(5)", function() Shared.ConsoleCommand ("sh_buyglow Green credit")  end)
        self:AddSideButton( "Gold(5)", function() Shared.ConsoleCommand ("sh_buyglow Gold credit")  end)
      --  self:AddSideButton( "Red(5)", function() Shared.ConsoleCommand ("sh_buyglow Red")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredit")end) 
end)

Shine.VoteMenu:AddPage ("SpendWeaponsCredit", function( self )
	    self:AddSideButton("Welder: "..gCreditWeaponCostWelder, function() Shared.ConsoleCommand ("sh_buywp Welder credit")  end)
	    self:AddSideButton("Cluster: "..gCreditWeaponCostGrenadeCluster, function() Shared.ConsoleCommand ("sh_buywp clustergrenade credit")  end)
	    self:AddSideButton("Stun: "..gCreditWeaponCostGrenadePulse, function() Shared.ConsoleCommand ("sh_buywp pulseGrenade credit")  end)
	    self:AddSideButton("NerveGas: "..gCreditWeaponCostGrenadeGas, function() Shared.ConsoleCommand ("sh_buywp gasgrenade credit")  end)
        self:AddSideButton("Mines: "..gCreditWeaponCostMines, function() Shared.ConsoleCommand ("sh_buywp Mines credit")  end)

        self:AddSideButton("FlameThrower: "..gCreditWeaponCostFlameThrower, function() Shared.ConsoleCommand ("sh_buywp FlameThrower credit")  end)
        self:AddSideButton("GrenadeLauncher: "..gCreditWeaponCostGrenadeLauncher, function() Shared.ConsoleCommand ("sh_buywp GrenadeLauncher credit")  end)
        self:AddSideButton("Shotgun: "..gCreditWeaponCostShotGun, function() Shared.ConsoleCommand ("sh_buywp Shotgun credit")  end)
       -- self:AddSideButton("HeavyRifle: "..gCreditWeaponCostHMG, function() Shared.ConsoleCommand ("sh_buywp HeavyRifle")  end)
        self:AddSideButton("HeavyMachineGun: "..gCreditWeaponCostHMG, function() Shared.ConsoleCommand ("sh_buywp HeavyMachineGun credit")  end)
       self:AddBottomButton("Back", function()self:SetPage("SpendCredit")end)

end)

Shine.VoteMenu:AddPage ("FastGestation", function( self )
		self:AddSideButton("Gorge: "..(gCreditClassCostGorge)*2, function() Shared.ConsoleCommand ("sh_buyclass Gorge credit fast")  end)
		self:AddSideButton("Lerk: "..(gCreditClassCostLerk)*2, function() Shared.ConsoleCommand ("sh_buyclass Lerk credit fast")  end)
		self:AddSideButton("Fade: "..(gCreditClassCostFade)*2, function() Shared.ConsoleCommand ("sh_buyclass Fade credit fast")  end)
        self:AddSideButton("Onos: "..(gCreditClassCostOnos)*2, function() Shared.ConsoleCommand ("sh_buyclass Onos credit fast") end)
       self:AddBottomButton("Back", function()self:SetPage("SpendClassesCredit")end)
end)


Shine.VoteMenu:AddPage ("SpendClassesCredit", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton("JetPack: "..gCreditClassCostJetPack, function() Shared.ConsoleCommand ("sh_buyclass JetPack credit") end) 
    self:AddSideButton("MiniGunExo: "..gCreditClassCostMiniGunExo, function() Shared.ConsoleCommand ("sh_buyclass MiniGun credit") end) 
    self:AddSideButton("RailGunExo: "..gCreditClassCostRailGunExo, function() Shared.ConsoleCommand ("sh_buyclass RailGun credit") end)  
    self:AddSideButton("FlamerExo: "..gCreditClassCostFlamerExo, function() Shared.ConsoleCommand ("sh_buyclass Flamer credit") end) 
    self:AddSideButton("WelderExo: "..gCreditClassCostFlamerExo+1, function() Shared.ConsoleCommand ("sh_buyclass Welder credit") end) 
    self:AddSideButton("WeldFlameExo: "..gCreditClassCostFlamerExo+2, function() Shared.ConsoleCommand ("sh_buyclass WeldFlame credit") end) 
    elseif player:GetTeamNumber() == 2 then
        self:AddSideButton( "FastGestation", function()self:SetPage("FastGestation")end)
		self:AddSideButton("Gorge: "..gCreditClassCostGorge, function() Shared.ConsoleCommand ("sh_buyclass Gorge credit")  end)
		self:AddSideButton("Lerk: "..gCreditClassCostLerk, function() Shared.ConsoleCommand ("sh_buyclass Lerk credit")  end)
		self:AddSideButton("Fade: "..gCreditClassCostFade, function() Shared.ConsoleCommand ("sh_buyclass Fade credit")  end)
        self:AddSideButton("Onos: "..gCreditClassCostOnos, function() Shared.ConsoleCommand ("sh_buyclass Onos credit") end)
    end
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredit")end) 
end)
/*
Shine.VoteMenu:AddPage ("SpendExpenive", function( self )
        self:AddSideButton( "OffensiveConcGrenade(100) (WIP)", function() Shared.ConsoleCommand ("sh_buywp OffensiveConcGrenade")  end)
             self:AddBottomButton( "Back", function()self:SetPage("SpendCredit")end) 

end)
*/
/*
Shine.VoteMenu:AddPage ("SpendFunCredit ", function( self )
        self:AddSideButton( "JediConcGrenade(5) (WIP)", function() Shared.ConsoleCommand ("sh_buywp JediConcGrenade")  end)
             self:AddBottomButton( "Back", function()self:SetPage("SpendCredit")end) 

end)
*/
Shine.VoteMenu:AddPage ("SpendCommAbilitiesCredit", function( self )
       local player = Client.GetLocalPlayer()
if player:GetTeamNumber() == 1 then
		self:AddSideButton ("Scan: "..gCreditAbilityCostScan, function()Shared.ConsoleCommand ("sh_buy Scan credit")end)
		self:AddSideButton ("Medpack: "..gCreditAbilityCostMedpack, function()Shared.ConsoleCommand ("sh_buy Medpack credit")end)
	else
		self:AddSideButton("NutrientMist: "..gCreditAbilityCostNutrientMist, function()Shared.ConsoleCommand ("sh_buy NutrientMist credit")end)
		self:AddSideButton("Mucous: "..gCreditAbilityCostMucous , function()Shared.ConsoleCommand ("sh_buy Mucous credit")end)
		self:AddSideButton("EnzymeCloud: "..gCreditAbilityCostEnzymeCloud, function() Shared.ConsoleCommand ("sh_buy EnzymeCloud credit")  end)
		self:AddSideButton("Ink: "..gCreditAbilityCostInk, function() Shared.ConsoleCommand ("sh_tbuy Ink")  end)
		self:AddSideButton("Hallucination: "..gCreditAbilityCostHallucination, function() Shared.ConsoleCommand ("sh_buy Hallucination credit")  end)
		self:AddSideButton("Contamination: "..gCreditAbilityCostContamination, function() Shared.ConsoleCommand ("sh_buy Contamination credit")  end)
end
     self:AddBottomButton( "Back", function()self:SetPage("SpendCredit")end) 
end)


Shine.VoteMenu:AddPage ("RemoveBadges", function( self )
        self:AddSideButton( "1 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 1 Credit")  end)
        self:AddSideButton( "2 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 2 Credit")  end)
        self:AddSideButton( "3 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 3 Credit")  end)
        self:AddSideButton( "4 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 4 Credit")  end)
        self:AddSideButton( "5 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 5 Credit")  end)
        self:AddSideButton( "6 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 6 Credit")  end)
        self:AddSideButton( "7 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 7 Credit")  end)
        self:AddSideButton( "8 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 8 Credit")  end)
        self:AddSideButton( "9 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 9 Credit")  end)
        self:AddSideButton( "10 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 10 Credit")  end)
          self:AddBottomButton( "Back", function()self:SetPage("SpendBadges")end) 
end)
Shine.VoteMenu:AddPage ("SpendBadges", function( self )
        self:AddTopButton( "RemoveBadges", function() self:SetPage( "RemoveBadges" ) end)
        self:AddSideButton( "cockatiel (5k)", function() Shared.ConsoleCommand ("sh_buybadge cockatiel Credit")  end)
        self:AddSideButton( "weed (5k)", function() Shared.ConsoleCommand ("sh_buybadge weed Credit")  end)
        self:AddSideButton( "pepe (5k)", function() Shared.ConsoleCommand ("sh_buybadge pepe Credit")  end)
        self:AddSideButton( "trump (5k)", function() Shared.ConsoleCommand ("sh_buybadge trump Credit")  end)
        self:AddSideButton( "sonic (5k)", function() Shared.ConsoleCommand ("sh_buybadge sonic Credit")  end)
        self:AddSideButton( "finger (5k)", function() Shared.ConsoleCommand ("sh_buybadge finger Credit")  end)
        self:AddSideButton( "pistol (5k)", function() Shared.ConsoleCommand ("sh_buybadge pistol Credit")  end)
        self:AddSideButton( "peter (5k)", function() Shared.ConsoleCommand ("sh_buybadge peter Credit")  end)
        self:AddSideButton( "feels (5k)", function() Shared.ConsoleCommand ("sh_buybadge feels Credit")  end)
        self:AddSideButton( "heart (5k)", function() Shared.ConsoleCommand ("sh_buybadge heart Credit")  end)
        

        
      --  self:AddSideButton( "Badge 2(5)", function() Shared.ConsoleCommand ("sh_buybadge Badge2 Credit")  end)
      --  self:AddSideButton( "Badge 3(5)", function() Shared.ConsoleCommand ("sh_buybadge Badge3 Credit")  end)
      --  self:AddSideButton( "Red(5)", function() Shared.ConsoleCommand ("sh_buyglow Red")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredit")end) 
end)





Shine.VoteMenu:AddPage ("SpendGlowCredit", function( self )
        self:AddSideButton( "Purple(5)", function() Shared.ConsoleCommand ("sh_buyglow Purple sand")  end)
        self:AddSideButton( "Green(5)", function() Shared.ConsoleCommand ("sh_buyglow Green sand")  end)
        self:AddSideButton( "Gold(5)", function() Shared.ConsoleCommand ("sh_buyglow Gold sand")  end)
      --  self:AddSideButton( "Red(5)", function() Shared.ConsoleCommand ("sh_buyglow Red")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredit")end) 
end)
