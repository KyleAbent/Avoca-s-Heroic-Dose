--thank you last stand
local gTechIdToString = {}

local function createTechIdEnum(table)

    for i = 1, #table do
        gTechIdToString[table[i]] = i
    end
    
    return enum(table)

end

function StringToTechId(string)
    return gTechIdToString[string] or kTechId.None
end

local techIdStrings = {}

for i = 1, #kTechId do
    if kTechId[i] ~= "Max" then
        table.insert(techIdStrings, kTechId[i])
    end
end    

local kSiege_TechIds =
{
  //  'MacSpawnOn',
  //  'MacSpawnOff',
  //  'ArcSpawnOn',
  //  'ArcSpawnOff',
    'PrimalScream',
    'ExtractorArmor1',
    --'LerkHealth',
    --'FadeHealth',
    --'OnosHealth',
   -- 'PlaceTechPoint',
    'DigestComm',
    'WhipBuff1',
    'CragHeals1',
    'WhipHealthArmor1',
    'AdvancedBeacon',
    'SiegeBeacon',
    'JetpackFuel1',
    'AlienHealth1',
    'RunSpeed1',
    'MacDefenseBuff',
    'ClipSize1',
    'ArmoryBuff1',
    'SkulkRage',
    'GorgeBombBuff',
    'HydraBuff1',
    'Onocide',
    'DualWelderExosuit',
    'RailgunWelderExoSuit',
     'RailgunFlamerExoSuit',
    'DualFlamerExosuit',
    'WeldFlamerExosuit',
    'AcidRocket',
    'UnlockAdvancedBeacon',
    'APresBuff1',
    'ATresBuff1',
    'MPresBuff1',
    'MTresBuff1',
   // 'BackupLight',
  //  'AdvancedBeacon',
  //  'EggBeacon',
  //  'StructureBeacon',
  //  'CommTunnel',
  //  'OnoGrow',
      'CragHiveTwo',
	  'Rebirth',
	  'Redemption',
	  'BackupBattery',
	  
}

for i = 1, #kSiege_TechIds do
    table.insert(techIdStrings, kSiege_TechIds[i])
end

techIdStrings[#techIdStrings + 1] = 'Max'

kTechId = createTechIdEnum(techIdStrings)
kTechIdMax  = kTechId.Max
