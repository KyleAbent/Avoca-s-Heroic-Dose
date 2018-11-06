Script.Load("lua/Convars19.lua")
//Script.Load("lua/Additions/EggBeacon.lua")
//Script.Load("lua/Additions/StructureBeacon.lua")
Script.Load("lua/Weapons/Alien/PrimalScream.lua")
//Script.Load("lua/BackupBattery.lua")
//Script.Load("lua/Additions/BackupLight.lua")
//Script.Load("lua/Additions/CommTunnel.lua")
//Script.Load("lua/Additions/OnoGrow.lua")

Script.Load("lua/2019/DigestCommMixin.lua")
Script.Load("lua/Weapons/Alien/Onocide.lua")

Script.Load("lua/2019/ExoFlamer.lua")
Script.Load("lua/2019/ExoWelder.lua")
Script.Load("lua/Weapons/Alien/AcidRocket.lua")



if Server then

function GetCheckCommandStationLimit(techId, origin, normal, commander)

    local num = 0

        
       for _, cc in ipairs(GetEntitiesWithinRange("CommandStation", origin, 9999)) do
        
                num = num + 1
            
    end
    
    return num < 3
end
end

SetCachedTechData(kTechId.CommandStation, kTechDataAttachOptional, true)

SetCachedTechData(kTechId.CommandStation, kTechDataBuildRequiresMethod, GetCheckCommandStationLimit)







/*
function CheckCommTunnelReq(techId, origin, normal, commander)
local tunnelEntrances = 0 
for index, tunnelEntrance in ientitylist(Shared.GetEntitiesWithClassname("CommTunnel")) do 
tunnelEntrances = tunnelEntrances + 1 
end

   local cyst = GetEntitiesWithinRange("Cyst", origin, 7)
   
   if #cyst >= 1 then 
   
         for i = 1, #cyst do
            local cysty = cyst[i]
                if cysty:GetCurrentInfestationRadius() == kInfestationRadius then
                return tunnelEntrances < 2
                 end
         end
   

   end
   
                return false


end

function GetCheckEggBeacon(techId, origin, normal, commander)
    local num = 0

        
        for index, shell in ientitylist(Shared.GetEntitiesWithClassname("EggBeacon")) do
        
           -- if not spur:isa("StructureBeacon") then 
                num = num + 1
          --  end
            
    end
    
    return num < 1
    
end

function GetCheckStructureBeacon(techId, origin, normal, commander)
    local num = 0

        
        for index, shell in ientitylist(Shared.GetEntitiesWithClassname("EggBeacon")) do
        
           -- if not spur:isa("StructureBeacon") then 
                num = num + 1
          --  end
            
    end
    
    return num < 1
    
end
*/

local kSiege_TechData =
{        

  
  

          { [kTechDataId] = kTechId.DigestComm,   
            [kTechDataDisplayName] = "Digest",
 [kTechDataCostKey] = 0,   
 [kTechIDShowEnables] = false,     
  [kTechDataResearchTimeKey] = kRecycleTime,
 [kTechDataHotkey] = Move.R, 
[kTechDataTooltipInfo] =  "Sometimes a commander may not want a specific entity, eh."},

          { [kTechDataId] = kTechId.WhipBuff1,   
            [kTechDataDisplayName] = "WhipBuff1",
 [kTechDataCostKey] = 10,   
 [kTechIDShowEnables] = false,     
  [kTechDataResearchTimeKey] = 30,
 [kTechDataHotkey] = Move.R, 
[kTechDataTooltipInfo] = "5% increase of movespeed, max speed, range, bombard range, bomb speed"},

  
                  --Thanks dragon ns2c
       { [kTechDataId] = kTechId.PrimalScream,  
         [kTechDataCategory] = kTechId.Lerk,
       [kTechDataDisplayName] = "Primal Scream",
        [kTechDataMapName] =  Primal.kMapName,
         --[kTechDataCostKey] = kPrimalScreamCostKey, 
       -- [kTechDataResearchTimeKey] = kPrimalScreamTimeKey, 
 [kTechDataTooltipInfo] = "+Energy to teammates, enzyme cloud"},
 
 
           { [kTechDataId] = kTechId.UnlockAdvancedBeacon,   
            [kTechDataDisplayName] = "UnlockAdvancedBeacon",
 [kTechDataCostKey] = 10,   
 [kTechIDShowEnables] = false,     
  [kTechDataResearchTimeKey] = 15,
 [kTechDataHotkey] = Move.R, 
[kTechDataTooltipInfo] = "This is so you don't accidentally trigger AdvancedBeacon thinking it's a research."},

 
    { [kTechDataId] = kTechId.AdvancedBeacon,   
   [kTechDataBuildTime] = 0.1,   
   [kTechDataCooldown] = kAdvancedBeaconCoolDown,
    [kTechDataDisplayName] = "Advanced Beacon",   
   [kTechDataHotkey] = Move.B, 
    [kTechDataCostKey] = kAdvancedBeaconCost, 
[kTechDataTooltipInfo] = "Revives Dead Players as well. Powers off Observatory for a short duration after beaconing."},

       { [kTechDataId] = kTechId.SiegeBeacon,  
        [kTechDataBuildTime] = 0.1,   
        [kTechDataDisplayName] = "SiegeBeacon", 
      [kTechDataHotkey] = Move.B, 
      [kTechDataCostKey] = kAdvancedBeaconCost, 
    [kTechDataTooltipInfo] =  "Once per game, advanced beacon located inside Siege Room rather than closest CC. Choose your timing wisely."},
    
    
       { [kTechDataId] = kTechId.Onocide,        
  [kTechDataCategory] = kTechId.Onos,   
     [kTechDataMapName] = Onocide.kMapName,  
[kTechDataCostKey] = 10,
 [kTechDataResearchTimeKey] = 10, 
 --   [kTechDataDamageType] = kStabDamageType,  
     [kTechDataDisplayName] = "Onicide",
[kTechDataTooltipInfo] = "wip"},
    
    
    
     
         { [kTechDataId] = kTechId.RailgunFlamerExoSuit,    
 [kTechIDShowEnables] = false,     
  [kTechDataDisplayName] = "RailgunFlamerExoSuit  ", 
[kTechDataMapName] = "exo",         
      [kTechDataCostKey] = kDualExosuitCost - 5, 
[kTechDataHotkey] = Move.E,
 [kTechDataTooltipInfo] = "RailgunFlamerExoSuit", 
[kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},
     
     
         { [kTechDataId] = kTechId.RailgunWelderExoSuit,    
 [kTechIDShowEnables] = false,     
  [kTechDataDisplayName] = "RailgunWelderExoSuit  ", 
[kTechDataMapName] = "exo",         
      [kTechDataCostKey] = kDualExosuitCost - 5, 
[kTechDataHotkey] = Move.E,
 [kTechDataTooltipInfo] = "RailgunWelderExoSuit", 
[kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},



         { [kTechDataId] = kTechId.WeldFlamerExosuit,    
 [kTechIDShowEnables] = false,     
  [kTechDataDisplayName] = "Welder Flamer Exo", 
[kTechDataMapName] = "exo",         
      [kTechDataCostKey] = kDualExosuitCost - 5, 
[kTechDataHotkey] = Move.E,
 [kTechDataTooltipInfo] = "Welder Flamer Exo Yo", 
[kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},




         { [kTechDataId] = kTechId.DualWelderExosuit,    
 [kTechIDShowEnables] = false,     
  [kTechDataDisplayName] = "Dual Exo Welders", 
[kTechDataMapName] = "exo",         
      [kTechDataCostKey] = kDualExosuitCost - 10, 
[kTechDataHotkey] = Move.E,
 [kTechDataTooltipInfo] = "Dual Welders yo", 
[kTechDataSpawnHeightOffset] = kCommanderEquipmentDropSpawnHeight},


         { [kTechDataId] = kTechId.DualFlamerExosuit,    
 [kTechIDShowEnables] = false,     
  [kTechDataDisplayName] = "Dual Exo Flamer", 
[kTechDataMapName] = "exo",         
      [kTechDataCostKey] = kDualExosuitCost - 5, 
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




          { [kTechDataId] = kTechId.APresBuff1,   
            [kTechDataDisplayName] = "APresBuff1",
 [kTechDataCostKey] = 10,   
 [kTechIDShowEnables] = false,     
  [kTechDataResearchTimeKey] = 30,
 [kTechDataHotkey] = Move.R, 
[kTechDataTooltipInfo] = "5% increase of alien pres gain amount"},

          { [kTechDataId] = kTechId.ATresBuff1,   
            [kTechDataDisplayName] = "ATresBuff1",
 [kTechDataCostKey] = 10,   
 [kTechIDShowEnables] = false,     
  [kTechDataResearchTimeKey] = 30,
 [kTechDataHotkey] = Move.R, 
[kTechDataTooltipInfo] = "5% increase of alien tres gain amount"},

          { [kTechDataId] = kTechId.APresBuff1,   
            [kTechDataDisplayName] = "APresBuff1",
 [kTechDataCostKey] = 10,   
 [kTechIDShowEnables] = false,     
  [kTechDataResearchTimeKey] = 20,
 [kTechDataHotkey] = Move.R, 
[kTechDataTooltipInfo] = "5% increase of alien pres gain amount"},


          { [kTechDataId] = kTechId.MTresBuff1,   
            [kTechDataDisplayName] = "MTresBuff1",
 [kTechDataCostKey] = 10,   
 [kTechIDShowEnables] = false,     
  [kTechDataResearchTimeKey] = 30,
 [kTechDataHotkey] = Move.R, 
[kTechDataTooltipInfo] = "5% "},

          { [kTechDataId] = kTechId.MPresBuff1,   
            [kTechDataDisplayName] = "MPresBuff1",
 [kTechDataCostKey] = 10,   
 [kTechIDShowEnables] = false,     
  [kTechDataResearchTimeKey] = 30,
 [kTechDataHotkey] = Move.R, 
[kTechDataTooltipInfo] = "5% increase of marine pres gain amount"},

    
          
        { [kTechDataId] = kTechId.ExtractorArmor1,   
          [kTechDataCostKey] = kExtractorArmor1Cost,  
          [kTechDataResearchTimeKey] = kExtractorArmor1ResearchTime,   
           [kTechDataDisplayName] = "Exxtractor Armor 1",  
           [kTechDataTooltipInfo] = ""},
           
          { [kTechDataId] = kTechId.CragHeals1,   
          [kTechDataCostKey] = 50,  
          [kTechDataResearchTimeKey] = 60,   
           [kTechDataDisplayName] = "CragHeals1",  
           [kTechDataTooltipInfo] = "Increase: HealPercent, Min Heal, Max Heal by 10%."},   

          { [kTechDataId] = kTechId.BackupBattery,   
          [kTechDataCostKey] = 5,  
          [kTechDataResearchTimeKey] = 10,   
           [kTechDataDisplayName] = "BackupBattery",  
           [kTechDataTooltipInfo] = "Indesct. while powerpoint alive. Extends power to struct. in radius while powerpoint offline"},    
           
           
           
        
         { [kTechDataId] = kTechId.AlienHealth1,   
          [kTechDataCostKey] = 50,  
          [kTechDataResearchTimeKey] = 60,   
           [kTechDataDisplayName] = "Increase Alien max hp 10%. ",  
           [kTechDataTooltipInfo] = "Be careful, this goes away if all shells die!"},
          
         { [kTechDataId] = kTechId.RunSpeed1,   
          [kTechDataCostKey] = 50,  
          [kTechDataResearchTimeKey] = 60,   
           [kTechDataDisplayName] = "Marine walk/run speed",  
           [kTechDataTooltipInfo] = "Walking and running speed increase by 4%. 10 too fast, 5 too noticeable. Try 4!"}, 
            
            
         { [kTechDataId] = kTechId.MacDefenseBuff,   
          [kTechDataCostKey] = 30,  
          [kTechDataResearchTimeKey] = 25, --Hogging a robotics factory is not good
           [kTechDataDisplayName] = "Mac Buff 1 ",  
           [kTechDataTooltipInfo] = "15% increase of weld rate, construct rate"}, 
           
           
         { [kTechDataId] = kTechId.ClipSize1,   
          [kTechDataCostKey] = 50,  
          [kTechDataResearchTimeKey] = 60,   
           [kTechDataDisplayName] = "Increase Rifle Clipsize  10%. ",  
           [kTechDataTooltipInfo] = "Notice the requirements!"}, 

         { [kTechDataId] = kTechId.ArmoryBuff1,   
          [kTechDataCostKey] = 50,  
          [kTechDataResearchTimeKey] = 60,   
           [kTechDataDisplayName] = "Armory Buff 1. ",  
           [kTechDataTooltipInfo] = "Increase HealAmount, Interval, Range by 10%. (Global)"}, 
           
         
          --Convars WIP
    
       { [kTechDataId] = kTechId.SkulkRage,  
         [kTechDataCostKey] = 30,  
        [kTechDataDisplayName] = "SkulkRage", 
      [kTechDataResearchTimeKey] = 30,   
    [kTechDataTooltipInfo] =  "10% faster skulk primary attack animation"},
    
           { [kTechDataId] = kTechId.GorgeBombBuff,  
         [kTechDataCostKey] = 30,  
        [kTechDataDisplayName] = "Gorge Bomb Buff", 
      [kTechDataResearchTimeKey] = 30,   
    [kTechDataTooltipInfo] =  "10% radius increase for bile bomb"},
    
    
    
               { [kTechDataId] = kTechId.HydraBuff1,  
         [kTechDataCostKey] = 30,  
        [kTechDataDisplayName] = "Hydra Buff1", 
      [kTechDataResearchTimeKey] = 30,   
    [kTechDataTooltipInfo] =  "5% increase in dmg(does it need range too?)"},
    
   
 { [kTechDataId] = kTechId.AcidRocket,        
  [kTechDataCategory] = kTechId.Fade,   
     [kTechDataMapName] = AcidRocket.kMapName,  
[kTechDataCostKey] = kStabResearchCost,
 [kTechDataResearchTimeKey] = kStabResearchTime, 
    [kTechDataDamageType] = kDamageType.Corrode,  
     [kTechDataDisplayName] = "AcidRocket",
 [kTechDataTooltipInfo] = "Ranged Projectile dealing damage only to armor and structures"},
 
  
   
              /*
        { [kTechDataId] = kTechId.FadeHealth,   
          [kTechDataCostKey] = kExtractorArmor1Cost,  
          [kTechDataResearchTimeKey] = kExtractorArmor1ResearchTime,   
           [kTechDataDisplayName] = "FadeHealth  1",  
           [kTechDataTooltipInfo] = ""},
           
        { [kTechDataId] = kTechId.OnosHealth,   
          [kTechDataCostKey] = kExtractorArmor1Cost,  
          [kTechDataResearchTimeKey] = kExtractorArmor1ResearchTime,   
           [kTechDataDisplayName] = "OnosHealth  1",  
           [kTechDataTooltipInfo] = ""},
          
        { [kTechDataId] = kTechId.PlaceTechPoint,   
          [kTechDataCostKey] = 80,  
       --   [kTechDataResearchTimeKey] = kExtractorArmor1ResearchTime,   
           [kTechDataDisplayName] = "PlaceTechPoint",  
           [kTechDataTooltipInfo] = "WIP"},
       */

	               { [kTechDataId] = kTechId.Rebirth, 
       [kTechDataCategory] = kTechId.CragHiveTwo,  
        [kTechDataDisplayName] = "Rebirth", 
      [kTechDataSponitorCode] = "A",  
      [kTechDataCostKey] = kRebirthCost, 
     [kTechDataTooltipInfo] = "Replaces death with gestation if cooldown is reached", },

      // Lifeform purchases
        { [kTechDataId] = kTechId.Redemption, 
       [kTechDataCategory] = kTechId.CragHiveTwo,  
        [kTechDataDisplayName] = "Redemption", 
      [kTechDataSponitorCode] = "B",  
      [kTechDataCostKey] = kRedemptionCost, 
     [kTechDataTooltipInfo] = "a 3 second timer checks if your health is a random value less than or equal to 15-30% of your max hp. If so, then randomly tp to a egg spawn 1-4 seconds after.", },

  
}   

local kSiege_TechIdToMaterialOffset = {}
//kSiege_TechIdToMaterialOffset[kTechId.MacSpawnOn] = 1

local getmaterialxyoffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)

    local index
    index = kSiege_TechIdToMaterialOffset[techId]
    
    if not index then
        return getmaterialxyoffset(techId)
    end
    
    local columns = 12
    index = kSiege_TechIdToMaterialOffset[techId]
    
    if index == nil then
        Print("Warning: %s did not define kTechIdToMaterialOffset ", EnumToString(kTechId, techId) )
    end

    if(index ~= nil) then
    
        local x = index % columns
        local y = math.floor(index / columns)
        return x, y
        
    end
    
    return nil, nil
    
end

local buildTechData = BuildTechData
function BuildTechData()

    local defaultTechData = buildTechData()
    local moddedTechData = {}
    local usedTechIds = {}
    
    for i = 1, #kSiege_TechData do
        local techEntry = kSiege_TechData[i]
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

