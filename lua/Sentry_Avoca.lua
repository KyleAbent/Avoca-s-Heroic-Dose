function Sentry:GetFov()
    return 360
end
function Sentry:OnUpdateAnimationInput(modelMixin)

    PROFILE("Sentry:OnUpdateAnimationInput")    
    modelMixin:SetAnimationInput("attack", self.attacking)
   -- modelMixin:SetAnimationInput("powered", true)
    
end


if Server then
local origUpdate = Sentry.OnUpdate
 function Sentry:OnUpdate(deltaTime)
        origUpdate(self, deltaTime)  
        self.attachedToBattery = true
end

end

/*
   not powered by powerconsumer
	function Sentry:OnPowerOn(){
	 GetImaginator().activeSentrys += 1;  
}

function Sentry:OnPowerOff(){
	 GetImaginator().activeSentrys -= 1;  
}

 function Sentry:PreOnKill(attacker, doer, point, direction){
      
	  if self:GetIsPowered() then
	    GetImaginator().activeSentrys += 1;  
	  end
 }

 */