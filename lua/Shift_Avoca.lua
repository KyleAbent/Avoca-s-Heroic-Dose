Script.Load("lua/InfestationMixin.lua")

local networkVars = 

{   
}


AddMixinNetworkVars(InfestationMixin, networkVars)

local originit = Shift.OnInitialized
function Shift:OnInitialized()
originit(self)
InitMixin(self, InfestationMixin)
end

  function Shift:GetInfestationRadius()
     if  GetConductor():GetIsPhaseTwoBoolean() then
     return kInfestationRadius
     elseif  GetConductor():GetIsPhaseOneBoolean() then
     return kInfestationRadius/3
     else
     return kInfestationRadius /4
     end
   end

function Shift:GetMinRangeAC()
return 14    
end

Shared.LinkClassToMap("Shift", Shift.kMapName, networkVars)
/*
Script.Load("lua/Additions/SaltMixin.lua")
Script.Load("lua/InfestationMixin.lua")

local networkVars = {calling = "boolean", receiving = "boolean"} 

AddMixinNetworkVars(InfestationMixin, networkVars)
local origcreate = Shift.OnCreate
function Shift:OnCreate()
   origcreate(self)
  InitMixin(self, SaltMixin)
 end
  
  


local originit = Shift.OnInitialized
function Shift:OnInitialized()
originit(self)
self.calling = false
self.receiving = false
InitMixin(self, InfestationMixin)
end
  function Shift:GetInfestationRadius()
    if self:GetIsACreditStructure() then
    return 1
    else
    return 0
    end
end

function Shift:AutoCommCall()
--   if GetSiegeDoorOpen() then self.calling = false end
   if not self.calling then return end 
   --Maybe require 0 struct to to receive and x+ to call? or as is :p
  if GetIsOriginInHiveRoom(self:GetOrigin()) then return end --Maybe disable later? hm.
   local location = GetLocationForPoint(self:GetOrigin())
   local conslocation = nil
       local constructs = GetEntitiesWithMixinForTeamWithinRange("Construct", 2, self:GetOrigin(), 72)
       if not constructs then return end
         for _, construct in ipairs(constructs) do
             if construct.GetCanShiftCallRec and construct:GetCanShiftCallRec() then
                conslocation = GetLocationForPoint(construct:GetOrigin())
                if construct ~= self and self:GetDistance(construct) > kEchoRange and conslocation == location then
                construct:GiveOrder(kTechId.Move, self:GetId(), FindFreeSpace(self:GetOrigin(), .5, 7), nil, true, true) 
                end
             end
         end
end
function Shift:GetCanShiftCallRec()
 return self:GetIsBuilt() and not self.receiving
end
  function Shift:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
      if self.calling then
   unitName = string.format(Locale.ResolveString("%s (Calling!)"), unitName)
    elseif self.receiving then
   unitName = string.format(Locale.ResolveString("%s (Receiving!!)"), unitName)
   end
return unitName
end 

function Shift:CheckForAndActOn() -- Insta Teleport with 0 tres cost OP? Add limit? Time Delay? if 12 then take 3 at a time?
 --Print("Calling 3")
local receivingOrigin = nil
local origins = {}

      for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Shift")) do
            if entity.receiving then table.insert(origins, entity:GetOrigin()) end --Print("Calling 4") break  end
      end
      
      
     for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Contamination")) do
      --    local ARC = #GetEntitiesWithinRange( "ARC", entity:GetOrigin(), 18 )
       --   if  not ARC  then
           table.insert(origins, entity:GetOrigin())
        --   end
      end
      
      receivingOrigin = table.random(origins)

 if not receivingOrigin then return end
    --Print("Calling 5")
    local eligable = {}
     local teleportAbles = GetEntitiesWithMixinForTeamWithinRange("Construct", 2, self:GetOrigin(), kEchoRange)
       if not teleportAbles then return end
         for _, teleportable in ipairs(teleportAbles) do
             if teleportable.GetCanShiftCallRec and teleportable:GetCanShiftCallRec() and self ~= teleportable then
              table.insert(eligable, teleportable)
             end
         end

                 
      for _, egg in ipairs(GetEntitiesForTeamWithinRange("Egg", 2, self:GetOrigin(), kEchoRange)) do
            if egg then table.insert(eligable, egg) end
      end
   --Print("Calling 6")
    for _, teleportable in ipairs(eligable) do
    
          --Print("Calling 7")
              teleportable:SetOrigin( FindFreeSpace(receivingOrigin, 1, kEchoRange, true)) 
                    if HasMixin(teleportable, "Orders") then
                   --  Print("Calling 8")
                        teleportable:ClearCurrentOrder()
                    end
                   --  Print("Calling 9")
                    success = true
                    self.echoActive = true
    end
    if success then  self:TriggerEffects("shift_echo") end
    self.echoActive = false -- ?
 
end
local origupdate = Shift.OnUpdate
function Shift:OnUpdate(deltaTime)
  origupdate(self, deltaTime)
 if Server then
  if self.calling then
     --Print("Calling 1")
    if not self.timelastCallCheck or self.timelastCallCheck + 4 < Shared.GetTime() then
      self:CheckForAndActOn()
      self.timelastCallCheck = Shared.GetTime()
     --  Print("Calling 2")
    end
  --elseif self.receiving then
  
  end
  end
end

*/




--Shared.LinkClassToMap("Shift", Shift.kMapName, networkVars)