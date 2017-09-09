function GhostStructureMixin:__initmixin()

    -- init the entity in ghost structure mode
    if Server then
        self.isGhostStructure = false
    end
    
end 



if Server then


function ConstructMixin:HealWPower()
  if GetIsRoomPowerUp(self) then self:AddHealth(100) self:AddArmor(25) end
  return self:GetIsBuilt()
end

local orig consOn = ConstructMixin.OnConstructionComplete
function ConstructMixin:OnConstructionComplete(builder)
      consOn(self, builder)
      if self:GetTeamNumber() == 1 then
      self:AddTimedCallback(ConstructMixin.HealWPower, 4)
      end
end

function ConstructMixin:OnUpdate(deltaTime)
  if not self:isa("PowerPoint") and self:GetTeamNumber() == 1 and not self:GetIsBuilt() and GetIsRoomPowerUp(self) then
 -- Print("derp")
  self:Construct(0.0125)
  end
end


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






/*

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

    if not self:isa("CommandStructure") and not self:isa("Cyst") and hitPoint ~= nil and (attacker ~= nil and attacker:isa("Player")  ) then
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

*/





local function GetDestinationGate(self)
    local phaseGates = {} 
  -- Find next phase gate to teleport to
  
  if self:isa("PhaseAvoca") then  
  
    for index, ARC  in ipairs( GetEntitiesForTeam("ARC", self:GetTeamNumber()) ) do
        if ARC.avoca == true and GetIsUnitActive(ARC) then
            return ARC
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