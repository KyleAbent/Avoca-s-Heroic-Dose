Script.Load("lua/2019/Shared.lua")


local function GetHasSentryBatteryInRadius(self)
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), kBatteryPowerRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return battery.canBackup end
           end      
 
   return false
end

function PowerConsumerMixin:GetIsPowered() 
    return self.powered or self.powerSurge or ( not self:isa("SentryBattery") and GetHasSentryBatteryInRadius(self) )
end

function LoadPathing(mapName, groupName, values)


    if mapName == "nav_point" then
        Pathing.AddFillPoint(values.origin) 
    end


end
Event.Hook("MapLoadEntity", LoadPathing)





/*

function LoadPathing(mapName, groupName, values)


    if mapName == "nav_point" then
        Pathing.AddFillPoint(values.origin) 
    end


end
Event.Hook("MapLoadEntity", LoadPathing)
*/