local function BreachAirLock(where, which)

          for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
           if location.name == which.name then 
              local airlock = CreateEntity(AirLock.kMapName, location:GetOrigin())
              airlock.scale = location.scale
              airlock.name = which.name
              airlock:SetBox(airlock.scale) 
           end
      end
      

end
function SealAirLock(nameofwhich)

          for _, airlock in ientitylist(Shared.GetEntitiesWithClassname("AirLock")) do
             DestroyEntity(airlock)
          end

end
local function RoomIsEmpty(self)
                     local marines = 0
                     local entities = self:GetEntitiesInTrigger()
                     
                     if #entities == 0 then return true end
                     
                     for i = 1, #entities do
                     local ent = entities[i]
                     if ent:isa("Marine") and ent:GetIsAlive() and not ent:isa("Commander") then return false end
                     end

end
local function IsPowerDown(self)
 local powerpoint = GetPowerPointForLocation(self.name)
 if powerpoint then return powerpoint:GetIsDisabled() and not powerpoint:GetIsBuilt()  end
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
                    if not GetIsPointInMarineBase(self:GetOrigin()) and HasAirLockInRoom(self.name) and ( RoomIsEmpty(self) or IsPowerDown(self) ) then
                         SealAirLock(self.name)
                    end
    end