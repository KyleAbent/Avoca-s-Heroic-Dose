    function PhaseGate:GetMinRangeAC()
    return math.random(32, 54) 
      end
      
      
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


	function PhaseGate:OnPowerOn()
	 GetImaginator().activePGs = GetImaginator().activePGs  + 1  
   end

function PhaseGate:OnPowerOff()
	 GetImaginator().activePGs  = GetImaginator().activePGs  - 1  
end

 function PhaseGate:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetImaginator().activePGs  = GetImaginator().activePGs + 1  
	  end
end