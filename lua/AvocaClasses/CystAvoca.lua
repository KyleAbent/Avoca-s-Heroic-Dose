class 'CystAvoca' (Cyst)
CystAvoca.kMapName = "cystavoca"


Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/AlienStructureMoveMixin.lua")


local networkVars = {}
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(AlienStructureMoveMixin, networkVars)


function CystAvoca:OnCreate()
  Cyst.OnCreate(self)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, AlienStructureMoveMixin, { kAlienStructureMoveSound = Whip.kWalkingSound })
end
function CystAvoca:GetCystParentRange()
return 999
end
function CystAvoca:GetCystParentRange()
return 999
end

function CystAvoca:GetMaxSpeed()
    return 3 * self:GetHealthScalar()
end
if Server then


   function CystAvoca:GetIsActuallyConnected()
   return true
   end
   
   

    
    
end
function CystAvoca:OnConstructionComplete()
    self:AddTimedCallback(CystAvoca.EnergizeInRange, 4)
    self:AddTimedCallback(CystAvoca.Synchronize, 4)
end
function CystAvoca:EnergizeInRange()
    if self:GetIsBuilt() and not self:GetIsOnFire() and self:GetMaturityFraction() == 1 then
    
        local energizeAbles = GetEntitiesWithMixinForTeamWithinRange("Energize", self:GetTeamNumber(), self:GetOrigin(), kEnergizeRange)
        
        for _, entity in ipairs(energizeAbles) do
        
            if entity ~= self then
                entity:Energize(self)
                entity:SetMucousShield()
            end
            
        end
    
    end
    
    return self:GetIsAlive()
end
 local function GetCanSpawnAlienEntity(trescount)
    return GetGamerules().team2:GetTeamResources() >= trescount
end
function CystAvoca:KillWhipAvoca()
                     local whips = GetEntitiesForTeamWithinRange("WhipAvoca", 2, self:GetOrigin(), 999999)
                     
                     if #whips == 0 then return end
                     
                     for i = 1, #whips do
                     local whip = whips[i]
                      whip:ActivateSelfDestruct()
                     end
end       
function CystAvoca:MoveWhipAvoca(where)
                     local whips = GetEntitiesForTeamWithinRange("WhipAvoca", 2, self:GetOrigin(), 999999)
                     
                     if #whips == 0 then return end
                     
                     for i = 1, #whips do
                     local whip = whips[i]
                        whip:GiveOrder(kTechId.Move, nil, FindFreeSpace(where, .5,8), nil, true, true) 
                     end
end  
function CystAvoca:TeleportWhipAvoca(where)
                     local whips = GetEntitiesForTeamWithinRange("WhipAvoca", 2, self:GetOrigin(), 999999)
                     
                     if #whips == 0 then return end
                     
                     for i = 1, #whips do
                     local whip = whips[i]
                       whip:SetOrigin(FindFreeSpace(where))
                     end
end  
function CystAvoca:PreOnKill(attacker, doer, point, direction)
       self:KillWhipAvoca()
end
function CystAvoca:SpawnWhipsAtKing(whips, crags, cyst, origin)
            --local spawned = false 
          --  local tres = not self.doorsopened and kStructureDropCost * .5 or kStructureDropCost
           -- self.alienteamcanupgeggs = ConditionalValue(self.team2:GetTeamResources()>= 100, true,false)
     --   if self:GetCanSpawnAlienEntity(tres, nil, cyst:GetIsInCombat()) then
         local maxwhips = 8
         local currentwhips = Clamp(#whips, 0, maxwhips)
  --       Print("Currentwhips is %s", currentwhips)
         local whipstospawn = math.abs(maxwhips - currentwhips)
        -- Print("whipstospawn is %s", whipstospawn)
          whipstospawn = Clamp(whipstospawn, 0, 4)
        -- Print("whipstospawn is %s", whipstospawn)
         
         if whipstospawn >= 1 then
         
         for i = 1, whipstospawn do
                -- local tres = kWhipCost / 2
               --  if GetCanSpawnAlienEntity(tres) then  
                     local whip = CreateEntity(WhipAvoca.kMapName, FindFreeSpace(origin), 2) 
                     local random = math.random(1,4)
                     
                     if random == 4 then
                        whip:SetConstructionComplete()
                     end
                      
                     -- whip:GetTeam():SetTeamResources(whip:GetTeam():GetTeamResources() - tres)
                      -- end
                     --end, 4)

         end
        
        
        end
         
        /*
                    if #whips <= math.random(1,15) then
                       if not spawned then
                      local whip = CreateEntity(Whip.kMapName, origin, 2) 
                      --self.lastaliencreatedentity = Shared.GetTime()
                        spawned = true
                      end
                    end
                    
                    if crags <= math.random(1,15) then
                       if not spawned then
                      local crag = CreateEntity(Crag.kMapName, origin, 2) 
                     -- self.lastaliencreatedentity = Shared.GetTime()
                        spawned = true
                      end
                    end
                   */ 
      --  end   
        

         --   if not spawned then
         --        self.alienteamcanupgeggs = true
         --   else
         --     self.team2:SetTeamResources(self.team2:GetTeamResources()  - tres)
         --     cyst.MinKingShifts = Clamp(cyst.MinKingShifts + 1, 0, Cyst.MinimumKingShifts)
         --   end     
            
end
local function SlowMarinesNearMist(where)
 local marines = GetEntitiesForTeamWithinRange("Player", 1, where, 10)
 
   if #marines == 0 then return end
   
    for i = 1, #marines do
     local ent = marines[i]
     if ent:GetIsAlive() and ent.SetWebbed then ent:SetWebbed(8) end
    end
    
end

local function ChanceMist(where)
    local chance = math.random(1,4)
    
      if chance == 4 then
      if Server then 
        CreateEntity(NutrientMist.kMapName, FindFreeSpace(where), 2)
         SlowMarinesNearMist(where)
         end
      end
end
local function MoveEggs(self)
          for index, egg in ipairs(GetEntitiesForTeam("Egg", 2)) do
               if self:GetDistance(egg) >= 16 and egg:GetIsFree() then 
                local toplace = GetRandomBuildPosition( kTechId.Egg, self:GetOrigin(), 8 )
                   if toplace then
                        toplace = GetGroundAtPosition(toplace, nil, PhysicsMask.AllButPCs, extents)
                             if toplace then
                             egg:SetOrigin(toplace)
                             ChanceMist(toplace)
                             end
                     end
                end
           end
end
local function GetCragsCount()
local crags = 0
          for _, crag in ientitylist(Shared.GetEntitiesWithClassname("Crag")) do
             if crag:GetIsAlive() and not crag:isa("HiveCrag") then crags = crags + 1 end
          end
          return crags

end
/*
function CystAvoca:OnMaturityComplete()

end

function CystAvoca:OnOrderComplete(currentOrder)
  self:Synchronize()
end
*/
function Cyst:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if doer ~= nil and doer:isa("ARC") then
        damageTable.damage = 10
    end

end
function CystAvoca:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if doer ~= nil and doer:isa("ARC") then
        damageTable.damage = 100
    end

end
function CystAvoca:Synchronize()
    if self.moving or not self:GetIsAlive() then return true end
       Print("Calling to sync")
                     MoveEggs(self)
                     local whips = GetEntitiesForTeamWithinRange("WhipAvoca", 2, self:GetOrigin(), 999999)
                     local crags = GetCragsCount()
                     self:SpawnWhipsAtKing(whips, crags, self, self:GetOrigin())
                     local location = GetLocationForPoint(self:GetOrigin()) or GetNearest(self:GetOrigin(), "Location") or nil
                     if location == nil then return true end
                     local cysts, tableof = GetCystsInLocation(location)
                     for i = 1, #tableof do
                        local autocyst = tableof[i]
                        if autocyst and autocyst:GetIsAlive() and autocyst:GetIsBuilt() then AttractCrags(autocyst) end
                     end
                    return true
end
function AttractCrags(who)
   local crags = #GetEntitiesWithinRange("Crag", who:GetOrigin(), 8) 
    if not crags or  crags <= 3 then
                 MagnetizeStructures(who)
    end
end
function MagnetizeStructures(who)

          for index, crag in ipairs(GetEntitiesForTeam("Crag", 2)) do
               if not crag:isa("HiveCrag") and crag:GetIsBuilt() and who:GetDistance(crag) >= 16 and not (crag:GetHasOrder() or crag.moving) then 
                 local where = FindFreeSpace(who:GetOrigin(), .5, 8)
                 local success = crag:GiveOrder(kTechId.Move, who:GetId(), where, nil, true, true) 
                 if success then break end
                end
          end          

end
                    
function CystAvoca:GetMatureMaxHealth()
    return (math.max(kMatureCystHealth * self.healthScalar or 0, kMinMatureCystHealth)) * 8
end 

function CystAvoca:GetMatureMaxArmor()
    return kMatureCystArmor * 8
end 
function CystAvoca:GetInfestationRadius()
    return 0
end

function CystAvoca:GetMaturityRate()
  return 8
end

function CystAvoca:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
        local scale =  Clamp(4 * self:GetHealthScalar(), 1, 4)
        scale = ConditionalValue(self:GetMaxHealth() == 8191, scale * 2, scale) -- lulz
        scale = Clamp(scale, 2, 8)
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end


Shared.LinkClassToMap("CystAvoca", CystAvoca.kMapName, networkVars)