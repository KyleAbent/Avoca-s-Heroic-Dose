--Script.Load("lua/Weapons/Alien/PrimalScream.lua")
--Script.Load("lua/Additions/OnoGrow.lua")
--Script.Load("lua/Additions/Onocide.lua")
--Script.Load("lua/Additions/CragUmbra.lua")
--Script.Load("lua/Additions/CommVortex.lua")
--Script.Load("lua/Weapons/Alien/AcidRocket.lua")
--Script.Load("lua/Additions/LerkBileBomb.lua")
--Script.Load("lua/Additions/LayStructures.lua")
Script.Load("lua/Additions/ExoFlamer.lua")
Script.Load("lua/Additions/EggBeacon.lua")
Script.Load("lua/Additions/StructureBeacon.lua")
Script.Load("lua/Additions/ExoWelder.lua")
Script.Load("lua/Weapons/Alien/PrimalScream.lua")



local kAvoca_TechData =
{   


                  { [kTechDataId] = kTechId.Rebirth, 
       [kTechDataCategory] = kTechId.CragHiveTwo,  
        [kTechDataDisplayName] = "Rebirth", 
      [kTechDataSponitorCode] = "A",  
      [kTechDataCostKey] = kRebirthCost, 
     [kTechDataTooltipInfo] = "Replaces death with gestation if cooldown is reached", },

      -- Lifeform purchases
        { [kTechDataId] = kTechId.Redemption, 
       [kTechDataCategory] = kTechId.CragHiveTwo,  
        [kTechDataDisplayName] = "Redemption", 
      [kTechDataSponitorCode] = "B",  
      [kTechDataCostKey] = kRedemptionCost, 
     [kTechDataTooltipInfo] = "a 3 second timer checks if your health is a random value less than or equal to 15-30% of your max hp. If so, then randomly tp to a egg spawn 1-4 seconds after.", },
   

   
     


         { [kTechDataId] = kTechId.DualFlamerExosuit,    
 [kTechIDShowEnables] = false,     
  [kTechDataDisplayName] = "Dual Exo Flamer", 
[kTechDataMapName] = "exo",         
      [kTechDataCostKey] = kDualExosuitCost - 5, 
[kTechDataHotkey] = Move.E,
 [kTechDataTooltipInfo] = "Dual Welders yo", 
[kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},


         { [kTechDataId] = kTechId.DualWelderExosuit,    
 [kTechIDShowEnables] = false,     
  [kTechDataDisplayName] = "Dual Exo Welders", 
[kTechDataMapName] = "exo",         
      [kTechDataCostKey] = kDualExosuitCost - 10, 
[kTechDataHotkey] = Move.E,
 [kTechDataTooltipInfo] = "Dual Welders yo", 
[kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},


         { [kTechDataId] = kTechId.WeldFlamerExosuit,    
 [kTechIDShowEnables] = false,     
  [kTechDataDisplayName] = "Welder Flamer Exo", 
[kTechDataMapName] = "exo",         
      [kTechDataCostKey] = kDualExosuitCost - 5, 
[kTechDataHotkey] = Move.E,
 [kTechDataTooltipInfo] = "Welder Flamer Exo Yo", 
[kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},


                  --Thanks dragon ns2c
       { [kTechDataId] = kTechId.PrimalScream,  
         [kTechDataCategory] = kTechId.Lerk,
       [kTechDataDisplayName] = "Primal Scream",
        [kTechDataMapName] =  Primal.kMapName,
         --[kTechDataCostKey] = kPrimalScreamCostKey, 
       -- [kTechDataResearchTimeKey] = kPrimalScreamTimeKey, 
 [kTechDataTooltipInfo] = "+Energy to teammates, enzyme cloud"},
 
        /*
                { [kTechDataId] = kTechId.DamageResistance, 
       [kTechDataCategory] = kTechId.ShiftHiveTwo,  
        [kTechDataDisplayName] = "Damage Resistance", 
      [kTechDataSponitorCode] = "A",  
      [kTechDataCostKey] = kDamageResistanceCost,
     [kTechDataTooltipInfo] = "5% damage resistance", },
     */


/*
                { [kTechDataId] = kTechId.ThickenedSkin, 
       [kTechDataCategory] = kTechId.ShiftHiveTwo,  
        [kTechDataDisplayName] = "Thickened Skin", 
      [kTechDataSponitorCode] = "A",  
      [kTechDataCostKey] = kThickenedSkinCost,
     [kTechDataTooltipInfo] = "Another layer of +hp for each biomass level", },


 
   
   
                     { [kTechDataId] = kTechId.Hunger, 
       [kTechDataCategory] = kTechId.CragHiveTwo,   
        [kTechDataDisplayName] = "Hunger", 
      [kTechDataSponitorCode] = "B",  
      [kTechDataCostKey] = kHungerCost, 
     [kTechDataTooltipInfo] = "10% health / energy gain, and effects of Enzyme on player kill (if gorge then structures not players) ", },
   
  */



/*
             { [kTechDataId] = kTechId.JumpPack,
        [kTechDataCostKey] = kJumpPackCost,
        [kTechDataDisplayName] = "Jump Pack", 
        [kTechDataHotkey] = Move.Z, 
      [kTechDataTooltipInfo] = "Mimics the NS1/HL1 JumpPack (With Attempted Balance Modifications WIP) - Press DUCK + Jump @ the same time to mindfuck the alien team."},

          
     




 { [kTechDataId] = kTechId.AcidRocket,        
  [kTechDataCategory] = kTechId.Fade,   
     [kTechDataMapName] = AcidRocket.kMapName,  
[kTechDataCostKey] = kStabResearchCost,
 [kTechDataResearchTimeKey] = kStabResearchTime, 
    [kTechDataDamageType] = kDamageType.Corrode,  
     [kTechDataDisplayName] = "AcidRocket",
 [kTechDataTooltipInfo] = "Ranged Projectile dealing damage only to armor and structures"},
  
   { [kTechDataId] = kTechId.LerkBileBomb,        
  [kTechDataCategory] = kTechId.Lerk,   
     [kTechDataMapName] = LerkBileBomb.kMapName,  
[kTechDataCostKey] = kStabResearchCost,
 [kTechDataResearchTimeKey] = kStabResearchTime, 
    [kTechDataDamageType] = kDamageType.Corrode,  
     [kTechDataDisplayName] = "LerkBileBomb",
 [kTechDataTooltipInfo] = "Derp"},


     
                 { [kTechDataId] = kTechId.CommVortex, 
        [kTechDataMapName] = CommVortex.kMapName, 
       [kTechDataAllowStacking] = true,
       [kTechDataIgnorePathingMesh] = true, 
       [kTechDataCollideWithWorldOnly] = true,
       [kTechDataRequiresInfestation] = true, 
      [kTechDataDisplayName] = "Etheral Gate", 
        [kTechDataCostKey] = kCommVortexCost, 
     [kTechDataCooldown] = kCommVortexCoolDown, 
      [kTechDataTooltipInfo] =  "Temporarily places marine structures/macs/arcs in another dimension rendering them unable to function correctly. "},
        */
        	/*
        
            { [kTechDataId] = kTechId.CragUmbra,
         [kTechDataDisplayName] = "UMBRA",
      --[kVisualRange] = Crag.kHealRadius, 
     [kTechDataCooldown] = kCragUmbraCooldown, 
     [kTechDataCostKey] = kCragUmbraCost,  
[kTechDataTooltipInfo] = "CRAG_UMBRA_TOOLTIP"},

    



   { [kTechDataId] = kTechId.OnoGrow,        
  [kTechDataCategory] = kTechId.Onos,   
     [kTechDataMapName] = OnoGrow.kMapName,  
[kTechDataCostKey] = kStabResearchCost,
 [kTechDataResearchTimeKey] = kStabResearchTime, 
 --   [kTechDataDamageType] = kStabDamageType,  
     [kTechDataDisplayName] = "OnoGrow",
[kTechDataTooltipInfo] = "wip"},

   { [kTechDataId] = kTechId.Onocide,        
  [kTechDataCategory] = kTechId.Onos,   
     [kTechDataMapName] = Onocide.kMapName,  
[kTechDataCostKey] = 10,
 [kTechDataResearchTimeKey] = 10, 
 --   [kTechDataDamageType] = kStabDamageType,  
     [kTechDataDisplayName] = "Onicide",
[kTechDataTooltipInfo] = "wip"},

*/


			
							
				        { [kTechDataId] = kTechId.EggBeacon, 
        [kTechDataCooldown] = kEggBeaconCoolDown, 
         [kTechDataTooltipInfo] = "Eggs Spawn approximately at the placed Egg Beacon. Be careful as infestation is required.", 
        [kTechDataGhostModelClass] = "AlienGhostModel",   
           [kTechDataBuildRequiresMethod] = GetCheckEggBeacon,
            [kTechDataMapName] = EggBeacon.kMapName,        
                 [kTechDataDisplayName] = "Egg Beacon",
           [kTechDataCostKey] = kEggBeaconCost,   
            [kTechDataRequiresInfestation] = true, 
          [kTechDataHotkey] = Move.C,   
         [kTechDataBuildTime] = kEggBeaconBuildTime, 
        [kTechDataModel] = EggBeacon.kModelName,   
           [kTechDataBuildMethodFailedMessage] = "1 at a time not in siege",
         [kVisualRange] = 8,
[kTechDataMaxHealth] = kEggBeaconHealth, [kTechDataMaxArmor] = kEggBeaconArmor},


        { [kTechDataId] = kTechId.StructureBeacon, 
        [kTechDataCooldown] = kStructureBeaconCoolDown, 
         [kTechDataTooltipInfo] = "Structures move approximately at the placed location", 
        [kTechDataGhostModelClass] = "AlienGhostModel",   
            [kTechDataMapName] = StructureBeacon.kMapName,        
                 [kTechDataDisplayName] = "Structure Beacon",  [kTechDataCostKey] = kStructureBeaconCost,   
            [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.C,   
         [kTechDataBuildTime] = kStructureBeaconBuildTime, 
        [kTechDataModel] = StructureBeacon.kModelName,  
            [kTechDataBuildMethodFailedMessage] = "1 at a time not in siege",
         [kVisualRange] = 8,
[kTechDataMaxHealth] = kStructureBeaconHealth, [kTechDataMaxArmor] = kStructureBeaconArmor},
               

		/*

                  --Thanks dragon ns2c
       { [kTechDataId] = kTechId.PrimalScream,  
         [kTechDataCategory] = kTechId.Lerk,
       [kTechDataDisplayName] = "Primal Scream",
        [kTechDataMapName] =  Primal.kMapName,
         --[kTechDataCostKey] = kPrimalScreamCostKey, 
       -- [kTechDataResearchTimeKey] = kPrimalScreamTimeKey, 
 [kTechDataTooltipInfo] = "+Energy to teammates, enzyme cloud"},
 
  
     */
          

      
  
}   



local buildTechData = BuildTechData
function BuildTechData()

    local defaultTechData = buildTechData()
    local moddedTechData = {}
    local usedTechIds = {}
    
    for i = 1, #kAvoca_TechData do
        local techEntry = kAvoca_TechData[i]
        table.insert(moddedTechData, techEntry)
        table.insert(usedTechIds, techEntry[kTechDataId])
    end
    
    for i = 1, #defaultTechData do
        local techEntry = defaultTechData[i]
        if not table.contains(usedTechIds, techEntry[kTechDataId]) then
            table.insert(moddedTechData, techEntry)
        end
    end
    
    return moddedTechData

end


