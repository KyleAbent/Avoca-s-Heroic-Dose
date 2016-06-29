--Kyle 'Avoca' Abent

class 'Imaginator' (Conductor) --Because I dont want to spawn it other than when conductor is active and that file is already full. 
Imaginator.kMapName = "imaginator"


local networkVars = 

{
}

function Imaginator:OnCreate() 
   for i = 1, 8 do
     Print("Imaginator created")
   end
           if Server then
              --self:AddTimedCallback(Imaginator.PickMainRoom, 16)
              self:AddTimedCallback(Imaginator.Automations, 8)
            end
end
local function PowerPointStuff(who)
local team = 0
local location = GetLocationForPoint(who:GetOrigin())
local powerpoint =  location and GetPowerPointForLocation(location.name)
      if powerpoint ~= nil then 
              if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then 
                team = 1
             elseif powerpoint:GetIsDisabled() or  powerpoint:GetIsSocketed()  then
             -- local infestation = GetEntitiesWithMixinWithinRange("Infestation", who:GetOrigin(), 7) 
               -- if #infestation >= 1 then
                 team = 2
                -- end
               end
     end
     return team
end
local function WhoIsQualified(who)
   return PowerPointStuff(who)
end
local function Touch(who, where, what, number)
 local tower = CreateEntityForTeam(what, where, number, nil)
         if tower then
            who:SetAttached(tower)
            return tower
         end
end
local function Envision(who, which)
   if which == 1 then
     Touch(who, who:GetOrigin(), kTechId.Extractor, 1)
   elseif which == 2 then
     Touch(who, who:GetOrigin(), kTechId.Harvester, 2)
    end
end
local function AutoDrop(self,who)
  local which = WhoIsQualified(who)
  if which ~= 0 then Envision(who, which) end
end
function Imaginator:Automations() --Does not use tres *yet* ..??
              self:CystRooms()
              self:AutoBuildConstructs()
              self:AutoBuildResTowers()
              return true
end
local function GetSentryMinRangeReq(where)
local count = 0
            local ents = GetEntitiesForTeamWithinRange("Sentry", 1, where, 16)
            for index, ent in ipairs(ents) do
                  count = count + 1
           end
           
           count = Clamp(count, 1, 4)
           
           return count*8
                
end
local function FindRandomPerson(airlock, powerpoint)

  local ents = airlock:GetEntitiesInTrigger()
  
  if #ents == 0 then return powerpoint:GetOrigin() end
  
  for i = 1, #ents do
    local entity = ents[i]
    if entity:isa("Marine") and entity:GetIsAlive() then return entity:GetOrigin() end
  end

 return powerpoint:GetOrigin()
end
local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end
function Imaginator:AutoBuildConstructs()

Print("AutoBuildConstructs")
local randomspawn = nil
local airlocks = {}
local tospawn = {}
table.insert(tospawn, Armory.kMapName)
table.insert(tospawn, Observatory.kMapName)
table.insert(tospawn, Scan.kMapName)
table.insert(tospawn, PhaseGate.kMapName)
table.insert(tospawn, RoboticsFactory.kMapName)
table.insert(tospawn, SentryAvoca.kMapName)
table.insert(tospawn, PrototypeLab.kMapName)
--table.insert(tospawn, SentryBattery.kMapName) --BackupBattery

local tospawn = table.random(tospawn)

     for _, airlock in ientitylist(Shared.GetEntitiesWithClassname("AirLock")) do
            if airlock then
                local powerpoint = GetPowerPointForLocation(airlock.name)
             if powerpoint then
                local randomspawn = FindFreeSpace(FindRandomPerson(airlock, powerpoint))
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 1, function(ent) return ent:GetMapName() == tospawn end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      Print("range is %s", range)
                          local minrange = 12
                          if tospawn == PhaseGate.kMapName then minrange = 72 end
                          if tospawn == Observatory.kMapName then minrange = 32 end
                          if tospawn == RoboticsFactory.kMapName then minrange = 52 end
                          if tospawn == SentryAvoca.kMapName then minrange = GetSentryMinRangeReq(randomspawn) end
                          if tospawn == PrototypeLab.kMapName then minrange = 52 end
                          if range >=  minrange then
                           local entity = CreateEntity(tospawn, randomspawn, 1)
                               if entity:isa("Cyst") then
                                  entity:SetImmuneToRedeploymentTime(999)
                               end
                          end
                     end
               end   
            end 
            end
  end
    
  return true
  
end

function Imaginator:AutoBuildResTowers()
  for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
        if respoint:GetAttached() == nil then AutoDrop(self, respoint) end
    end
end

Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)