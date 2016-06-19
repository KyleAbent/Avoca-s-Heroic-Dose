class 'CystAvoca' (Cyst)
CystAvoca.kMapName = "cystavoca"

function CystAvoca:OnCreate()
  Cyst.OnCreate(self)
  self:AddTimedCallback(CystAvoca.Heal, 4)
end
function CystAvoca:GetCystParentRange()
return 999
end
function CystAvoca:Heal()
   if self:GetHealth() == self:GetMatureMaxHealth() then return true end
   local gain = math.min(self:GetMatureMaxHealth() - self:GetHealth()) / math.random(4,8)
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
 
local function SynchronizeCystEntities(whips, crags, cyst, origin)
            local spawned = false 
          --  local tres = not self.doorsopened and kStructureDropCost * .5 or kStructureDropCost
           -- self.alienteamcanupgeggs = ConditionalValue(self.team2:GetTeamResources()>= 100, true,false)
     --   if self:GetCanSpawnAlienEntity(tres, nil, cyst:GetIsInCombat()) then
         
        
                    if #whips <= math.random(1,7) then
                       if not spawned then
                      local whip = CreateEntity(Whip.kMapName, origin, 2) 
                      --self.lastaliencreatedentity = Shared.GetTime()
                        spawned = true
                      end
                    end
                    
                    if #crags <= math.random(1,7) then
                       if not spawned then
                      local crag = CreateEntity(Crag.kMapName, origin, 2) 
                     -- self.lastaliencreatedentity = Shared.GetTime()
                        spawned = true
                      end
                    end
                    
      --  end   
        

         --   if not spawned then
         --        self.alienteamcanupgeggs = true
         --   else
         --     self.team2:SetTeamResources(self.team2:GetTeamResources()  - tres)
         --     cyst.MinKingShifts = Clamp(cyst.MinKingShifts + 1, 0, Cyst.MinimumKingShifts)
         --   end     
            
end
function CystAvoca:Synchronize()
                     local whips = GetEntitiesForTeamWithinRange("Whip", 2, self:GetOrigin(), 999999)
                     local crags = GetEntitiesForTeamWithinRange("Crag", 2, self:GetOrigin(), 999999)
                     SynchronizeCystEntities(whips, crags, self, FindFreeSpace(self:GetOrigin(), 4))
                     local cysts, ratio, tableof = GetCystsInLocation(GetLocationForPoint(self:GetOrigin()))
                     for i = 1, #tableof do
                        local autocyst = tableof[i]
                        if autocyst and autocyst:GetIsAlive() and autocyst:GetIsBuilt() then AttractWhipsCrags(autocyst) end
                     end
                    return true
end
function AttractWhipsCrags(who)
   local crags = #GetEntitiesWithinRange("Crag", who:GetOrigin(), 2) 
   local whips = #GetEntitiesWithinRange("Whip", who:GetOrigin(), 2)
    if not whips or crags then
                 MagnetizeStructures(who)
    end
end
function MagnetizeStructures(who)

          for index, crag in ipairs(GetEntitiesForTeam("Crag", 2)) do
               if crag:GetIsBuilt() and who:GetDistance(crag) >= 16 and not (crag:GetHasOrder() or crag.moving) then 
                 local success = crag:GiveOrder(kTechId.Move, who:GetId(), who:GetOrigin(), nil, true, true) 
                 if success then break end
                end
          end
          for index, whip in ipairs(GetEntitiesForTeam("Whip", 2)) do
               if whip:GetIsBuilt() and who:GetDistance(whip) >= 16 and not (whip:GetHasOrder() or whip.moving) then 
                local success = whip:GiveOrder(kTechId.Move, who:GetId(), who:GetOrigin(), nil, true, true) 
               if success then break end
                end

end
                
end       
function CystAvoca:GetMatureMaxHealth()
    return (math.max(kMatureCystHealth * self.healthScalar or 0, kMinMatureCystHealth)) * 4
end 

function CystAvoca:GetMatureMaxArmor()
    return kMatureCystArmor * 4
end 
function CystAvoca:GetInfestationRadius()
    return 0
end
/*
function CystAvoca:GetMaturityRate()

end
*/
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