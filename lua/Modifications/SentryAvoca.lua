
class 'SentryAvoca' (Sentry) --Because I dont want to spawn it other than when conductor is active and that file is already full. 
SentryAvoca.kMapName = "sentryavoca"



function SentryAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Sentry
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function SentryAvoca:GetFov()
    return 360
end
function SentryAvoca:OnUpdateAnimationInput(modelMixin)

    PROFILE("Sentry:OnUpdateAnimationInput")    
    modelMixin:SetAnimationInput("attack", self.attacking)
    modelMixin:SetAnimationInput("powered", true)
    
end

--Sentry retarded accuracy idea from someone that playtested NS2:Combat and came onto NS2Siege one day while playtesting
--ns2_tinysiege. Basically the concept of Taking the 'Hydra' inaccuracy and putting that into the Sentry, to mimic
--ns1 sentrys where one could circle the sentry to avoid the bullets rather than having ns2's concept of perfect aim 24/7
function SentryAvoca:GetDeathIconIndex()
    return kDeathMessageIcon.Sentry
end
function SentryAvoca:FireBullets()

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

 function SentryAvoca:OnUpdate(deltaTime)
        Sentry.OnUpdate(self, deltaTime)  
        self.attachedToBattery = true
end

end
Shared.LinkClassToMap("SentryAvoca", SentryAvoca.kMapName, networkVars)