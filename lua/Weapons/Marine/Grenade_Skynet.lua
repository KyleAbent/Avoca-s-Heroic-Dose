--Change grenade type by right clicking and display to player which is setting before primary clicking. 
--One day on the workshop by another author. Idea by TriggerHappy Stoner && Transcribed by Avoca -- Siege Developer

Grenade.kClearOnImpact = true
local networkVars = 
{   

grenadeType = "integer (1 to 4)",

}

local og = Grenade.OnCreate
function Grenade:OnCreate()
og(self)
self.grenadeType = 1
end

function Grenade:SetType(num)
 self.grenadeType = num
end


if Server then

local og = Grenade.Detonate

function Grenade:Detonate()

   if self.grenadeType == 1 then
       og(self) 
       return
   elseif self.grenadeType == 2 then
     local nervegascloud = CreateEntity(NerveGasCloud.kMapName, self:GetOrigin(), self:GetTeamNumber())
     DestroyEntity(self)
   elseif self.grenadeType == 3 then
     local cluster = CreateEntity(ClusterGrenade.kMapName, self:GetOrigin(), self:GetTeamNumber())   
     DestroyEntity(self)
   elseif self.grenadeType == 4 then
     local pulse = CreateEntity(PulseGrenade.kMapName, self:GetOrigin(), self:GetTeamNumber())  
     DestroyEntity(self)
    end
end

end--server


Shared.LinkClassToMap("Grenade", Grenade.kMapName, networkVars)