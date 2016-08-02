local function GetTechPoint(where)
    for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", where, 8)) do
         if techpoint then return techpoint end
    end
end
local function BuildAlienHive(who)
     who:AddTimedCallback(function() 
     local hive = who:SpawnCommandStructure(2)
     
          local nearestPower = GetNearest(who:GetOrigin(), "PowerPoint", 1)
       if nearestPower and not nearestPower:GetIsDisabled() then
              nearestPower:Kill()
       end
       
     end, 8)
end
function CommandStation:OnKill(attacker, doer, point, direction)
local child = GetTechPoint(self:GetOrigin())
BuildAlienHive(child)
end

end

if Server then

function CommandStation:BaseThisBitchUp()
local techPointOrigin = self:GetOrigin()
    CreateEntity(InfantryPortal.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    CreateEntity(InfantryPortal.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    --CreateEntity(Armory.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    CreateEntity(ArmsLab.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    --CreateEntity(PrototypeLab.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    CreateEntity(PhaseGate.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    CreateEntity(PhaseAvoca.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    --CreateEntity(Observatory.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    return false
end



end

