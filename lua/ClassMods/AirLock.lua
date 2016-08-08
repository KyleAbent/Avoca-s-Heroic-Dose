-- Kyle 'Avoca' Abent
PrecacheAsset("materials/power/powered_decal.surface_shader")
local kAirLockMaterial = PrecacheAsset("materials/power/powered_decal.material")

local function IsPowerUp(self)
 local powerpoint = GetPowerPointForLocation(self.name)

   local boolean = false
 if powerpoint and not powerpoint:GetIsDisabled() then boolean = true end
  -- Print("IsPowerUp in %s is %s", self.name, boolean)
 return boolean 
end


function Location:GetIsPowerUp()
return IsPowerUp(self)
end
function Location:InitiateDefense()
   self:AddTimedCallback(Location.BaseDefense, 4)
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
local function GetCanSpawn(self)
          for _, conductor in ientitylist(Shared.GetEntitiesWithClassname("Conductor")) do
            return not conductor:CounterComplete()
          end
          return true
end
function Location:BaseDefense() 
  if Server then  
  --                Print("BaseDefense triggered")
          local spawnpoint = GetRandom(self, self.name)
            if spawnpoint ~= nil and IsPowerUp(self) then 
                 -- Print("SpawnDefense triggered")
              CreateEntity(FireFlameCloud.kMapName, spawnpoint, 1) --oh fuck i had this set as team 2 LOL 
           end
   end
     return GetCanSpawn(self)
end
function Location:GetIsAirLock(ask)
  local marine = false
    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        if entity:isa("Player") and entity:GetTeamNumber() == 1 and entity:GetIsAlive() then marine = true break end 
    end
    local poweron = IsPowerUp(self)
    local boolean = marine and poweron
     --if ask then  Print("%s GetIsAirLock is %s", self.name, boolean) end
     return boolean
end

if Client then

    function Location:HideDank()
          --nevermind
    end
    
   
end
