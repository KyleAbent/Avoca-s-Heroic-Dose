function Sentry:GetFov()
    return 360
end
function Sentry:OnUpdateAnimationInput(modelMixin)

    PROFILE("Sentry:OnUpdateAnimationInput")    
    modelMixin:SetAnimationInput("attack", self.attacking)
    modelMixin:SetAnimationInput("powered", true)
    
end

--Sentry retarded accuracy idea from someone that playtested NS2:Combat and came onto NS2Siege one day while playtesting
--ns2_tinysiege. Basically the concept of Taking the 'Hydra' inaccuracy and putting that into the Sentry, to mimic
--ns1 sentrys where one could circle the sentry to avoid the bullets rather than having ns2's concept of perfect aim 24/7
function Sentry:GetDeathIconIndex()
    return kDeathMessageIcon.Sentry
end
function Sentry:FireBullets()

    local startPoint = self:GetBarrelPoint()
    local directionToTarget = self.target:GetEngagementPoint() - self:GetEyePos()
    local targetDistanceSquared = directionToTarget:GetLengthSquared()
    local theTimeToReachEnemy = targetDistanceSquared / (10 * 10)
    local engagementPoint = self.target:GetEngagementPoint()
    if self.target.GetVelocity then
    
        local targetVelocity = self.target:GetVelocity()
        --no levels on here
        local chance = math.random(1, 100)/100
        engagementPoint = self.target:GetEngagementPoint() - ((targetVelocity:GetLength() * 0.5 - (chance) * 1 * theTimeToReachEnemy) * GetNormalizedVector(targetVelocity))
        
    end
    
    local fireDirection = GetNormalizedVector(engagementPoint - startPoint)
    local fireCoords = Coords.GetLookIn(startPoint, fireDirection)    
    local spreadDirection = CalculateSpread(fireCoords, Math.Radians(15), math.random)
    --no levels on here
    local chance = math.random(1, 100)/100
    local endPoint = startPoint + spreadDirection * (Sentry.kRange * (chance) + Sentry.kRange)
    
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))
    
    if trace.fraction < 1 then
    
        local surface = nil
        
        // Disable friendly fire.
        local validtarget = GetAreEnemies(trace.entity, self)
        trace.entity = (not trace.entity or validtarget) and trace.entity or nil
        
        if not trace.entity then
            surface = trace.surface
        end
        
        local direction = (trace.endPoint - startPoint):GetUnit()
        local damage = 5 
        --no levels on here
        local chance = math.random(1, 100)/100
        self:DoDamage(damage * (chance) + damage, trace.entity, trace.endPoint, fireDirection, surface, false, true)
        
    end
    
        
    end



if Server then
local origUpdate = Sentry.OnUpdate
 function Sentry:OnUpdate(deltaTime)
        origUpdate(self, deltaTime)  
        self.attachedToBattery = true
end

end
