   local function BreachAirLock(where, which)
  local airlock = CreateEntity(AirLock.kMapName, where)
  airlock.scale = which.scale
  airlock.name = which.name
  airlock:SetBox(airlock.scale)  -- Rather than trigger init?
 -- Print("Airlock @ %s", which.name)
end
function SealAirLock(nameofwhich)

          for _, airlock in ientitylist(Shared.GetEntitiesWithClassname("AirLock")) do
             DestroyEntity(airlock)
          end

end
local function LastMarineLeft(self)
                     local marines = 0
                     local entities = self:GetEntitiesInTrigger()
                     
                     if #entities == 0 then return boolean end
                     
                     for i = 1, #entities do
                     local ent = entities[i]
                     if ent:isa("Marine") and ent:GetIsAlive() and not ent:isa("Commander") then marines = marines + 1 end
                     end
return marines <= 1
end
local function HasAirLockInRoom(nameofwhich)
local boolean = false
            for _, airlock in ientitylist(Shared.GetEntitiesWithClassname("AirLock")) do
             if airlock and airlock.name == nameofwhich then boolean = true end
           end
--Print("HasAirLockInRoom in %s is %s", nameofwhich, boolean)    
return boolean
end
 function Location:OnTriggerEntered(entity, triggerEnt)
        ASSERT(self == triggerEnt)
        local powerpoint = GetPowerPointForLocation(self.name)
                  if powerpoint ~= nil then 
              if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then 
                    if entity:isa("Marine") and entity:GetIsAlive() and not entity:isa("Commander") and not HasAirLockInRoom(self.name) then
                         BreachAirLock(entity:GetOrigin(), self)
                    end
                 end
             end
      end
  function Location:OnTriggerExited(entity, triggerEnt)
          ASSERT(self == triggerEnt)
                    if entity:isa("Marine") and not entity:isa("Commander") and HasAirLockInRoom(self.name) and LastMarineLeft(self) then
                         SealAirLock(self.name)
                    end
    end