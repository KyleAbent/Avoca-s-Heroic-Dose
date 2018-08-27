local networkVars = 

{   
  lastCheck = "time",
}

local origupdate = InfantryPortal.OnUpdate 

function InfantryPortal:OnUpdate(deltaTime)
  origupdate(self, deltaTime)
  
  if Server then
    if  not self:GetIsPowered() and GetIsTimeUp(self.lastCheck, 8)  then
        self:SetPowerSurgeDuration(16)
        self.lastCheck = Shared.GetTime()
    end
     
  end

end

Shared.LinkClassToMap("InfantryPortal", InfantryPortal.kMapName, networkVars)