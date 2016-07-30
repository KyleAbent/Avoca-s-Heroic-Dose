class 'CystAvoca' (Cyst)
CystAvoca.kMapName = "cystavoca"

function CystAvoca:OnCreate()
  Cyst.OnCreate(self)
  self:AddTimedCallback(CystAvoca.Heal, 8)
end
function CystAvoca:GetCystParentRange()
return 999
end
function CystAvoca:Heal()
   if self:GetHealth() == self:GetMatureMaxHealth() then return true end
   local gain = math.min(self:GetMatureMaxHealth() - self:GetHealth()) / math.random(2,4)
   self:AddHealth(gain, false, false, false)
   return self:GetIsAlive() and not self:GetIsDestroyed()
end
function CystAvoca:GetCystParentRange()
return 999
end


if Server then


   function CystAvoca:GetIsActuallyConnected()
   return true
   end
   
   

    
    
end
function CystAvoca:OnConstructionComplete()
    self:AddTimedCallback(CystAvoca.EnergizeInRange, 4)
    self:AddTimedCallback(CystAvoca.Synchronize, 8)
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
                     local whip = whip[i]
                      whip:ActivateSelfDestruct()
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
         Print("Currentwhips is %s", currentwhips)
         local whipstospawn = math.abs(maxwhips - currentwhips)
         Print("whipstospawn is %s", whipstospawn)
          whipstospawn = Clamp(whipstospawn, 0, 4)
         Print("whipstospawn is %s", whipstospawn)
         
         if whipstospawn >= 1 then
         
         for i = 1, whipstospawn do
                 local tres = kWhipCost / 2
                 if GetCanSpawnAlienEntity(tres) then  
                     local autoconstructspawnchance = math.random(1,2)
                     local whip = CreateEntity(WhipAvoca.kMapName, FindFreeSpace(origin), 2) 
                      if autoconstructspawnchance == 1 then
                        whip:SetConstructionComplete()
                      end
                      whip:GetTeam():SetTeamResources(whip:GetTeam():GetTeamResources() - tres)
                       end
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
local function ChanceMist(where)
    local chance = math.random(1,100)
    
      if chance <= 30 then
      if Server then CreateEntity(NutrientMist.kMapName, FindFreeSpace(where), 2) end
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
function CystAvoca:Synchronize()
    if not self:GetIsMature() then return true end
                     MoveEggs(self)
                     local whips = GetEntitiesForTeamWithinRange("WhipAvoca", 2, self:GetOrigin(), 999999)
                     local crags = GetCragsCount()
                     self:SpawnWhipsAtKing(whips, crags, self, self:GetOrigin())
                     local cysts, tableof = GetCystsInLocation(GetLocationForPoint(self:GetOrigin()))
                     for i = 1, #tableof do
                        local autocyst = tableof[i]
                        if autocyst and autocyst:GetIsAlive() and autocyst:GetIsBuilt() then AttractWhipsCrags(autocyst) end
                     end
                    return true
end
function AttractWhipsCrags(who)
   local crags = #GetEntitiesWithinRange("Crag", who:GetOrigin(), 8) 
   local whips = #GetEntitiesWithinRange("WhipAvoca", who:GetOrigin(), 8)
    if not whips and not crags or (whips + crags <= 3) then
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
          for index, whip in ipairs(GetEntitiesForTeam("WhipAvoca", 2)) do
               if not whip:isa("PowerDrainer") and whip:GetIsBuilt() and who:GetDistance(whip) >= 8 and not  whip.moving then 
                local success = whip:GiveOrder(kTechId.Move, who:GetId(), who:GetOrigin(), nil, true, true) 
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
  return 60 * 1.3
end

function CystAvoca:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
      local matureamt = not self:GetIsMature() and self:GetMaturityFraction() or 1
        local scale = Clamp( 4 * (self:GetHealthScalar() *  matureamt), .5, 4)
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end


Shared.LinkClassToMap("CystAvoca", CystAvoca.kMapName, networkVars)