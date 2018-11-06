local origbuttons = RoboticsFactory.GetTechButtons
function RoboticsFactory:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[3] = kTechId.MacDefenseBuff
 return table

end


function RoboticsFactory:GetMinRangeAC()
return RoboAutoCCMR    
end

function RoboticsFactory:OnPowerOn()
	 GetImaginator().activeRobos = GetImaginator().activeRobos + 1;  
end

function RoboticsFactory:OnPowerOff()
	 GetImaginator().activeRobos = GetImaginator().activeRobos - 1;  
end

 function RoboticsFactory:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetImaginator().activeRobos  = GetImaginator().activeRobos- 1;  
	  end
end