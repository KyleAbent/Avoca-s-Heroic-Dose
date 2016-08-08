function SentryBattery:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("BackupPower") )
return unitName
end  

function GhostStructureMixin:__initmixin()

    -- init the entity in ghost structure mode
    if Server then
        self.isGhostStructure = self:isa("Extractor")
    end
    
end
function RoboticsFactory:GetTechButtons(techId)

    local techButtons = {  kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
               kTechId.None, kTechId.None, kTechId.None, kTechId.None }
               
    if self:GetTechId() ~= kTechId.ARCRoboticsFactory then
        techButtons[5] = kTechId.UpgradeRoboticsFactory
    end           

    return techButtons
    
end
if Server then

local function LocationsMatch(who,whom)
   
  local whoname = GetLocationForPoint(who:GetOrigin())
  local whomname = GetLocationForPoint(whom:GetOrigin())
  return true --whoname == whomname
end

function CommandStructure:GetCanBeUsedConstructed(byPlayer)
    return false
end



function CommandStructure:OnUpdateAnimationInput(modelMixin)

    PROFILE("CommandStructure:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("occupied", true)
    
end
local function SpawnJanitorForEach(where)
  
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation:GetName() or ""
           if not wherelocation then return end
           
     for _, eligable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct", 1, where, 72)) do
         if not eligable:isa("PowerPoint") and not eligable:isa("Extractor") and not GetIsPointInMarineBase(eligable:GetOrigin()) then
           local location = GetLocationForPoint(eligable:GetOrigin())
           local locationName = location and location:GetName() or ""
           local sameLocation = locationName == wherelocation
          if sameLocation then 
                local Janitor = CreateEntity(Janitor.kMapName, FindFreeSpace(eligable:GetOrigin()), 2)
                Janitor:SetConstructionComplete()
                Janitor:SetMature()  
          end --
         end
     end--
     
end

local function SpawnSurgeForEach(where)
  
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation:GetName() or ""
           if not wherelocation then return end
           
     for _, eligable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct", 2, where, 72)) do
         if not eligable:isa("Harvester") and not eligable:isa("Cyst") and not eligable:isa("Hive") then --and not GetIsPointInMarineBase(eligable:GetOrigin()) then
           local location = GetLocationForPoint(eligable:GetOrigin())
           local locationName = location and location:GetName() or ""
           local sameLocation = locationName == wherelocation
          if sameLocation then 
                eligable:DeductHealth(100, nil, nil, false, false, true)
                eligable:TriggerEffects("arc_hit_primary")
                eligable:TriggerEffects("arc_hit_secondary")
          end --
         end
     end--
     
end
local orig_PowerPoint_StopDamagedSound = PowerPoint.StopDamagedSound
    function PowerPoint:StopDamagedSound()
    orig_PowerPoint_StopDamagedSound(self)
        if self:GetHealthScalar() ~= 1 then return end
         SpawnSurgeForEach(self:GetOrigin())
        local nearestHarvester = GetNearest(self:GetOrigin(), "Harvester", 2, function(ent) return LocationsMatch(self,ent)  end)
       if nearestHarvester then nearestHarvester:Kill() end
   end
   
local orig_PowerPoint_OnKill = PowerPoint.OnKill
    function PowerPoint:OnKill(attacker, doer, point, direction)
    orig_PowerPoint_OnKill(self)
    
    --if not GetIsPointInMarineBase(self:GetOrigin()) then KillAllStructuresInLocation(self:GetOrigin(), 1) end
      SpawnJanitorForEach(self:GetOrigin())
    
       local nearestExtractor = GetNearest(self:GetOrigin(), "Extractor", 1, function(ent) return LocationsMatch(self,ent)  end)
       if nearestExtractor then
         nearestExtractor:Kill()
       end
       
    end





local function GetIsVaporizing(where)
    for _, vape in ipairs(GetEntitiesWithinRange("Vaporizer", where, 16)) do
         if vape then return true end
    end
end
function CommandStation:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and GetIsVaporizing(self:GetOrigin()) then
    
        damageTable.damage = 0 --I already know whips and hydras are still gonna try to attack. Gotta filter that elsewhere.
        
    end

end
function InfantryPortal:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and GetIsVaporizing(self:GetOrigin()) then
    
        damageTable.damage = 0 --I already know whips and hydras are still gonna try to attack. Gotta filter that elsewhere.
        
    end

end
function InfantryPortal:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and GetIsVaporizing(self:GetOrigin()) then
    
        damageTable.damage = 0 --I already know whips and hydras are still gonna try to attack. Gotta filter that elsewhere.
        
    end

end
function ConstructMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if not self:isa("CommandStructure") and not self:isa("Cyst") and hitPoint ~= nil and (attacker ~= nil and attacker:isa("Player") or attacker:isa("Janitor") ) then
        local mult = 1
            local wherelocation = GetLocationForPoint(self:GetOrigin())
           if not wherelocation then return end
           
            if self:GetTeamNumber() == 1 then
              if not wherelocation:GetIsPowerUp() then 
                 if  attacker:isa("Janitor")  then mult = 8  else mult = 2 end 
              end
            elseif self:GetTeamNumber() == 2 then
                if wherelocation:GetIsPowerUp() then mult = 2 end
            
            end
        damageTable.damage = damageTable.damage * mult
        
    end

end
function ArmsLab:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil then
    
        damageTable.damage = 0 --I already know whips and hydras are still gonna try to attack. Gotta filter that elsewhere.
        
    end

end







local function GetDestinationGate(self)
    local phaseGates = {} 
  -- Find next phase gate to teleport to
  
  if self:isa("PhaseAvoca") then  
  
    for index, payload  in ipairs( GetEntitiesForTeam("AvocaArc", self:GetTeamNumber()) ) do
        if GetIsUnitActive(payload) then
            return payload
        end
    end 
    
   end
   
    for index, phaseGate in ipairs( GetEntitiesForTeam("PhaseGate", self:GetTeamNumber()) ) do
        if GetIsUnitActive(phaseGate) and not phaseGate:isa("PhaseAvoca") then
            table.insert(phaseGates, phaseGate)
        end
    end    
    
    
     
    if table.count(phaseGates) < 2 then
        return nil
    end
    -- Find our index and add 1
    local index = table.find(phaseGates, self)
    if (index ~= nil) then
    
        local nextIndex = ConditionalValue(index == table.count(phaseGates), 1, index + 1)
        ASSERT(nextIndex >= 1)
        ASSERT(nextIndex <= table.count(phaseGates))
        return phaseGates[nextIndex]
        
    end
    
    return nil 
end

--So that we can teleport to the payload without having to run to it all the time :P
local function ComputeDestinationLocationId(self, destGate)

    local destLocationId = Entity.invalidId
    if destGate then
    
        local location = GetLocationForPoint(destGate:GetOrigin())
        if location then
            destLocationId = location:GetId()
        end
        
    end
    
    return destLocationId
    
end
    function PhaseGate:Update()

        self.phase = (self.timeOfLastPhase ~= nil) and (Shared.GetTime() < (self.timeOfLastPhase + 0.3))

        local destinationPhaseGate = GetDestinationGate(self)
        if destinationPhaseGate ~= nil and GetIsUnitActive(self) and self.deployed and (destinationPhaseGate.deployed or destinationPhaseGate:isa("ARC") ) then        
        
            self.destinationEndpoint = destinationPhaseGate:GetOrigin()
            self.linked = true
            self.targetYaw = destinationPhaseGate:GetAngles().yaw
            self.destLocationId = ComputeDestinationLocationId(self, destinationPhaseGate)
            
        else
            self.linked = false
            self.targetYaw = 0
            self.destLocationId = Entity.invalidId
        end

        return true
        
    end
function InfantryPortal:OhNoYouDidnt()

     --for _, powerconsumer in ipairs(GetEntitiesWithMixinForTeamWithinRange("PowerConsumer", 1, self:GetOrigin(), 24)) do
       --   if powerconsumer ~= self and (powerconsumer:GetRequiresPower() and not powerconsumer:GetIsPowered()) then
          self:SetPowerSurgeDuration(16)
          --powerconsumer:TriggerEffects("arc_hit_secondary")
         -- end
    -- end
     
     self:TriggerEffects("arc_hit_primary")
     
 return not self:GetIsPowered()
 
end

    local orig_InfantryPortal_OnPowerOff = InfantryPortal.OnPowerOff
function InfantryPortal:OnPowerOff()
 orig_InfantryPortal_OnPowerOff(self)
   self:AddTimedCallback(InfantryPortal.OhNoYouDidnt, 8)
end




end