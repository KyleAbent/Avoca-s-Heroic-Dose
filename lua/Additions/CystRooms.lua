local function GetDisabledPowerPoints()
 local nodes = {}
 
            for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
                    local powernode = GetPowerPointForLocation(location)
                    if powernode and powernode:GetIsDisabled() then
                    table.insdert(nodes, powernode)
                    end
                    
             end

return nodes

end
local function FindRandomPerson(location, powerpoint)

  local ents = location:GetEntitiesInTrigger()
  
  if #ents == 0 then return powerpoint:GetOrigin() end
  
  for i = 1, #ents do
    local entity = ents[i]
    if entity:isa("Alien") and entity:GetIsAlive() then return entity:GetOrigin() end
  end

 return powerpoint:GetOrigin()
end
local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end
function Imaginator:CystRooms()
Print("AutoBuildConstructs")
local randomspawn = nil
local powerpoints = {}--GetDisabledPowerPoints()
local tospawn = {}
table.insert(tospawn, AutoCyst.kMapName)
table.insert(tospawn, Shade.kMapName)

local tospawn = table.random(tospawn)

     for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
                local powerpoint = GetPowerPointForLocation(location.name)
             if powerpoint and powerpoint:GetIsDisabled() then
                local randomspawn = FindFreeSpace(FindRandomPerson(location, powerpoint))
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 2, function(ent) return ent:GetMapName() == tospawn end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      Print("range is %s", range)
                          local minrange = 12
                          if tospawn == Cyst.kMapName then minrange = kCystRedeployRange end
                          if tospawn == Shade.kMapName then minrange = 32 end
                          if range >=  minrange then
                           CreateEntity(tospawn, randomspawn, 2)
                          end
                     else -- it tonly takes 1!
                        CreateEntity(tospawn, randomspawn, 2)
                     end
               end   
            end
  end
    
  return true
 end