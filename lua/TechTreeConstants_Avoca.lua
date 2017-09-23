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

local kAvoca_TechIds =
{
  --  'PrimalScream',
  -- 'EggBeacon',
  --  'StructureBeacon',
  --  'OnoGrow',
  --  'CommVortex',
 --   'AcidRocket',
 --   'Redemption',
  --  'Rebirth',
  --  'CragHiveTwo',
  -- 'ThickenedSkin',
  --  'Hunger',
  --  'ShiftHiveTwo',
  --  'LayStructures',
  --  'Onocide',
    'DualWelderExosuit',
    'DualFlamerExosuit',
 --   'LerkBileBomb',
  --  'ElectrifyStructure',
   -- 'HeavyArmor',
   -- 'Resupply',
    'StructureBeacon',
    'EggBeacon',
    'Redemption',
    'Rebirth',
    'CragHiveTwo',
    
}

for i = 1, #kAvoca_TechIds do
    table.insert(techIdStrings, kAvoca_TechIds[i])
end

techIdStrings[#techIdStrings + 1] = 'Max'

kTechId = createTechIdEnum(techIdStrings)
kTechIdMax  = kTechId.Max
