-- Kyle 'Avoca' Abent
PrecacheAsset("materials/power/powered_decal.surface_shader")
local kAirLockMaterial = PrecacheAsset("materials/power/powered_decal.material")

local originit = Location.OnInitialized
function Location:OnInitialized()
originit(self)
end
local function IsPowerUp(self)
 local powerpoint = GetPowerPointForLocation(self.name)

   local boolean = false
 if powerpoint and powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then boolean = true end
   ---Print("IsPowerUp in %s is %s", self.name, boolean)
 return boolean 
end


function Location:GetIsPowerUp()
return IsPowerUp(self)
end
function Location:GetIsAirLock()
     local boolean = IsPowerUp(self)
    -- Print("%s airlock is %s", self.name, boolean)
     return boolean
end

if Server then 

local function GetCanSpawn(self)
          for _, conductor in ientitylist(Shared.GetEntitiesWithClassname("Conductor")) do
            return not conductor:CounterComplete()
          end
          return true
end


local function GetRandom(self, nameofwhich)

local lottery = {}
     for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, self:GetOrigin(), 24)) do
     
         local location = GetLocationForPoint(unit:GetOrigin())
         if location and location.name == nameofwhich then
              table.insert(lottery, unit)
         end
     end
     
     if table.count(lottery) ~= 0 then
        local entity = table.random(lottery)
        return entity:GetOrigin()
     end
     
     return nil
end

function Location:InitiateDefense()
   self:AddTimedCallback(Location.BaseDefense, 4)
end

function Location:BaseDefense() 
  --                Print("BaseDefense triggered")
          local spawnpoint = GetRandom(self, self.name)
            if spawnpoint ~= nil and IsPowerUp(self) then 
                 -- Print("SpawnDefense triggered")
              CreateEntity(FireFlameCloud.kMapName, spawnpoint, 1)
           end
     return GetCanSpawn(self)
end



function Location:GetRandomMarine()
--Because when round starts, room is empty. Have marine in room first to tell it to be eligable.
local lottery = {}
     for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 1, self:GetOrigin(), 24)) do
     
         local location = GetLocationForPoint(unit:GetOrigin())
         if location and location.name == self.name then
              table.insert(lottery, unit)
         end
     end
     
     if table.count(lottery) ~= 0 then
        local entity = table.random(lottery)
        return entity:GetOrigin()
     end
     
     return nil
end


end