if Server then


function Hive:UpdateAliensWeaponsManually() ///Seriously this makes more sense than spamming some complicated formula every 0.5 seconds no?
 for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do 
        alien:HiveCompleteSoRefreshTechsManually() 
end
end

local function LocationsMatch(who,whom)
   
  local whoname = GetLocationForPoint(who:GetOrigin())
  local whomname = GetLocationForPoint(whom:GetOrigin())
  return true --whoname == whomname
end


local function ToSpawnFormula(self,panicstospawn, where)
         for i = 1, panicstospawn do
                           local bitch = GetPayLoadArc()
                           if bitch and GetIsPointWithinHiveRadius(bitch:GetOrigin()) then
                           local spawnpoint = FindFreeSpace(bitch:GetOrigin(), 4, 8)
                              if spawnpoint then
                              local panicattack = CreateEntity(PanicAttack.kMapName, spawnpoint, 2)
                               panicattack:SetConstructionComplete()
                               panicattack:SetMature()
                               end
                           end
               end
            
end
local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end
local function SendAnxietyAttack(self, where, who)
         for i = 1, #who do
                           local panicattack = who[i]
                           local bitch = GetDeployedPayLoadArc()
                           if bitch and GetIsPointWithinHiveRadius(bitch:GetOrigin()) and GetRange(panicattack,bitch:GetOrigin()) >= 16 then                  
                           local spawnpoint = FindFreeSpace(bitch:GetOrigin(), 4, 8)
                              if spawnpoint then
                                    panicattack:SetOrigin(spawnpoint)
                               end
                           end
               end
end
local function PanicInitiate(self,where)
local panicattacks = {}

        for _, panicattack in ipairs(GetEntitiesWithinRange("PanicAttack", where, 9999)) do
                if panicattack:GetIsAlive() then
                       table.insert(panicattacks,panicattack) 
               end
       end
       
  local countofpanic = Clamp(table.count(panicattacks), 0, 8)
  local maxpanic = 4
  local panicstospawn = math.abs(maxpanic - countofpanic)
        panicstospawn = Clamp(panicstospawn, 1, 2)

            if panicstospawn >= 1 then ToSpawnFormula(self,panicstospawn, where) end
            
            if countofpanic >= 1 then
                SendAnxietyAttack(self, where, panicattacks) -- not sure
            end
            
end

local orig_Hive_OnTakeDamage = Hive.OnTakeDamage
function Hive:OnTakeDamage(damage, attacker, doer, point)

   if doer and doer.avoca == true then 
         Print("PanicAttack Initiated")
         PanicInitiate(self,self:GetOrigin())
        if self:GetIsBuilt() then  AddPayLoadTime(10)  end
    end
    
return orig_Hive_OnTakeDamage(self,damage, attacker, doer, point)
end







/*

local function DestroyAvocaArcInRadius(where)
    for _, avocaarc in ipairs(GetEntitiesWithinRange("AvocaArc", where, kARCRange)) do
         if avocaarc then avocaarc:Kill() end
    end
end
*/

local function GetTechPoint(where)
    for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", where, 8)) do
         if techpoint then return techpoint end
    end
end



local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

local function BuildRoomPower(who)

     local nearestPower = GetNearest(who:GetOrigin(), "PowerPoint", 1, function(ent) return LocationsMatch(who,ent)  end)
       if nearestPower and nearestPower:GetIsDisabled() then
            local cheaptrick = CreateEntity(PowerPoint.kMapName, nearestPower:GetOrigin(), 1)
            cheaptrick:SetConstructionComplete()
                DestroyEntity(nearestPower) 
       end
       
       
     who:AddTimedCallback(function() 
--     local bigarc = CreateEntity(BigArc.kMapName, who:GetOrigin(), 1)
 --    bigarc:GiveDeploy()
       local cc = CreateEntity(CommandStation.kMapName, who:GetOrigin(), 1)
       cc:SetConstructionComplete()
     end, 8)
     
end



local orig_Hive_OnKill = Hive.OnKill
function Hive:OnKill(attacker, doer, point, direction)
 self:UpdateAliensWeaponsManually()
if self:GetIsBuilt() then AddPayLoadTime(16) end
local child = GetTechPoint(self:GetOrigin())
BuildRoomPower(child)
--DestroyAvocaArcInRadius(self:GetOrigin())
child:SetIsVisible(false)
 return orig_Hive_OnKill(self,attacker, doer, point, direction)
end
/*
local orig_Hive_OnResearchComplete = Hive.OnResearchComplete
function Hive:OnResearchComplete(researchId)
 self:UpdateAliensWeaponsManually()
 return orig_Hive_OnResearchComplete(researchId, self)
end
*/


local orig_Hive_OnDestroy = Hive.OnDestroy
function Hive:OnDEstroy()
orig_Hive_OnDestroy(self)
self:UpdateAliensWeaponsManually()
end




end