--Change grenade type by right clicking and display to player which is setting before primary clicking. 
--One day on the workshop by another author. Idea by TriggerHappy Stoner && Transcribed by Avoca -- Siege Developer
local networkVars = 

{   

grenadeType = "integer (1 to 4)",

}

local ogc = GrenadeLauncher.OnCreate

function GrenadeLauncher:OnCreate()
ogc(self)
self.grenadeType = 1 
    
end

local kGrenadeSpeed = 25

local function ShootGrenade(self, player)

    PROFILE("ShootGrenade")
    
    self:TriggerEffects("grenadelauncher_attack")

    if Server or (Client and Client.GetIsControllingPlayer()) then

        local viewCoords = player:GetViewCoords()
        local eyePos = player:GetEyePos()

        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis, 0.2, 0, CollisionRep.Move, PhysicsMask.PredictedProjectileGroup, EntityFilterTwo(self, player))
        local startPoint = startPointTrace.endPoint

        local direction = viewCoords.zAxis
        
        if startPointTrace.fraction ~= 1 then
            direction = GetNormalizedVector(direction:GetProjection(startPointTrace.normal))
        end
              local grenade = player:CreatePredictedProjectile("Grenade", startPoint, direction * kGrenadeSpeed, 0.7, 0.45)
              
              if Server then
              grenade:SetType(self.grenadeType)
              /*
                          local owner = self:GetOwner()
            if owner then
                nervegascloud:SetOwner(owner)
            end
              */
              end
    
    end

end


function GrenadeLauncher:FirePrimary(player)
    ShootGrenade(self, player)    
end

function GrenadeLauncher:GetHasSecondary(player)
    return true
end
function GrenadeLauncher:OnSecondaryAttack(player)
     
     --ugh
      if self.grenadeType == 1 then
         self.grenadeType = 2
      elseif self.grenadeType == 2 then
         self.grenadeType = 3
      elseif self.grenadeType == 3 then
         self.grenadeType = 4
      elseif self.grenadeType == 4 then
         self.grenadeType = 1
      end
end


Shared.LinkClassToMap("GrenadeLauncher", GrenadeLauncher.kMapName, networkVars)
