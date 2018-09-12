local networkVars = 

{   
  lastCheck = "time",
}

local origupdate = InfantryPortal.OnUpdate 

function InfantryPortal:OnUpdate(deltaTime)
  origupdate(self, deltaTime)
  
  if Server then
    if  self:GetIsBuilt() and not self:GetIsPowered() and GetIsTimeUp(self.lastCheck, 8)  then
        self:SetPowerSurgeDuration(16)
        self.lastCheck = Shared.GetTime()
    end
     
  end

end

function InfantryPortal:OnPowerOn()
	 GetImaginator().activeIPs = GetImaginator().activeIPs + 1  

end
function InfantryPortal:OnPowerOff()
	 GetImaginator().activeIPs = GetImaginator().activeIPs - 1  

end
 function InfantryPortal:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetImaginator().activeIPs  = GetImaginator().activeIPs - 1 
	  end
 end

Shared.LinkClassToMap("InfantryPortal", InfantryPortal.kMapName, networkVars)