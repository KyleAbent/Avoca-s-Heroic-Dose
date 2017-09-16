function GhostStructureMixin:__initmixin()

    -- init the entity in ghost structure mode
    if Server then
        self.isGhostStructure = false
    end
    
end 

local function GetHasSentryBatteryInRadius(self)
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), 6)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end

function PowerConsumerMixin:GetIsPowered() 
    return self.powered or self.powerSurge or GetHasSentryBatteryInRadius(self)
end


if Server then


function ConstructMixin:AdjustHPArmor()
 if GetIsRoomPowerUp(self) then --if phase 1?
  if not self:GetIsInCombat() then self:AddHealth(100) self:AddArmor(25) end
else
  self:DeductHealth(100)  
 end
  return self:GetIsBuilt()
end

local orig consOn = ConstructMixin.OnConstructionComplete
function ConstructMixin:OnConstructionComplete(builder)
      consOn(self, builder)
      if self:GetTeamNumber() == 1 then
      self:AddTimedCallback(ConstructMixin.AdjustHPArmor, 4)
      end
end

function ConstructMixin:OnUpdate(deltaTime)
  if ( self.GetIsInCombat  ) and not self:GetIsInCombat() and not self:isa("PowerPoint") and self:GetTeamNumber() == 1 and not self:GetIsBuilt() and GetIsRoomPowerUp(self) then
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






