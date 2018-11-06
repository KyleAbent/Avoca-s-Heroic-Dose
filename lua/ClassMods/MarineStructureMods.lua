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









