class 'BigMac' (MAC)
BigMac.kMapName = "bigmac"

local networkVars = {}

function BigMac:OnCreate()
 MAC.OnCreate(self)
 self:AdjustMaxHealth(kMACHealth * 4)
 self:AdjustMaxArmor(kMACArmor * 4)
 self:SetPhysicsGroup(PhysicsGroup.PlayerControllersGroup)
end


local function GetAutomaticOrder(self)

    local target = nil
    local orderType = nil

    if self.timeOfLastFindSomethingTime == nil or Shared.GetTime() > self.timeOfLastFindSomethingTime + 1 then

        local currentOrder = self:GetCurrentOrder()
        local primaryTarget = nil
        if currentOrder and currentOrder:GetType() == kTechId.FollowAndWeld then
            primaryTarget = Shared.GetEntity(currentOrder:GetParam())
        end

        if primaryTarget and (HasMixin(primaryTarget, "Weldable") and primaryTarget:GetWeldPercentage() < 1) and not primaryTarget:isa("MAC") then
            
            target = primaryTarget
            orderType = kTechId.AutoWeld
                    
        else

            -- If there's a friendly entity nearby that needs constructing, constuct it.
            
            local constructable =  GetNearestMixin(self:GetOrigin(), "Construct", 1, function(ent) return not GetIsPointInMarineBase(ent:GetOrigin()) and not ent:GetIsBuilt() and ent:GetCanConstruct(self) and self:CheckTarget(ent:GetOrigin())  end)
               if constructable then
                    target = constructable
                    orderType = kTechId.Construct
                end

            if not target then
            
            local weldable =  GetNearestMixin(self:GetOrigin(), "Weldable", 1, function(ent) return not GetIsPointInMarineBase(ent:GetOrigin()) and not ent:isa("Player") and ent:GetCanBeWelded(self) and ent:GetWeldPercentage() < 1  and self:CheckTarget(ent:GetOrigin())   end)
               if weldable then
                    target = constructable
                    orderType = kTechId.AutoWeld
                end
            
            end
        
        end

        self.timeOfLastFindSomethingTime = Shared.GetTime()

    end
    
    return target, orderType

end
local function FindSomethingToDo(self)

    local target, orderType = GetAutomaticOrder(self)
    if target and orderType then
        return self:GiveOrder(orderType, target:GetId(), target:GetOrigin(), nil, false, false) ~= kTechId.None    
    end
    
    return false
    
end
local function UpdateOrders(self, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
    
        local orderStatus = kOrderStatus.None        
        local orderTarget = Shared.GetEntity(currentOrder:GetParam())
        local orderLocation = currentOrder:GetLocation()
    
        if currentOrder:GetType() == kTechId.FollowAndWeld then
            orderStatus = self:ProcessFollowAndWeldOrder(deltaTime, orderTarget, orderLocation)    
        elseif currentOrder:GetType() == kTechId.Move then
            local closeEnough = 2.5
            orderStatus = self:ProcessMove(deltaTime, orderTarget, orderLocation, closeEnough)
            self:UpdateGreetings()

        elseif currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.AutoWeld then
            orderStatus = self:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, currentOrder:GetType() == kTechId.AutoWeld)
        elseif currentOrder:GetType() == kTechId.Build or currentOrder:GetType() == kTechId.Construct then
            orderStatus = self:ProcessConstruct(deltaTime, orderTarget, orderLocation)
        end
        
        if orderStatus == kOrderStatus.Cancelled then
            self:ClearCurrentOrder()
        elseif orderStatus == kOrderStatus.Completed then
            self:CompletedCurrentOrder()
        end
        
    end
    
end
function BigMac:GetDeathIconIndex()
    return kDeathMessageIcon.MAC
end
function BigMac:OnUpdate(deltaTime)
  ScriptActor.OnUpdate(self, deltaTime)
    
    if Server and self:GetIsAlive() then

        -- assume we're not moving initially
        self.moving = false
    
        if not self:GetHasOrder() then
            FindSomethingToDo(self)
        else
            UpdateOrders(self, deltaTime)
        end
        
        self.constructing = Shared.GetTime() - self.timeOfLastConstruct < 0.5
        self.welding = Shared.GetTime() - self.timeOfLastWeld < 0.5

        if self.moving and not self.jetsSound:GetIsPlaying() then
            self.jetsSound:Start()
        elseif not self.moving and self.jetsSound:GetIsPlaying() then
            self.jetsSound:Stop()
        end
        
    -- client side build / weld effects
    elseif Client and self:GetIsAlive() then
    
        if self.constructing then
        
            if not self.timeLastConstructEffect or self.timeLastConstructEffect + MAC.kConstructRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_construct")
                self.timeLastConstructEffect = Shared.GetTime()
                
            end
            
        end
        
        if self.welding then
            local weldrate = MAC.kWeldRate * ConditionalValue(not self:GetIsInCombat(), 4, .4)
            if not self.timeLastWeldEffect or self.timeLastWeldEffect + weldrate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_weld")
                self.timeLastWeldEffect = Shared.GetTime()
                
            end
            
        end
        
        if self:GetHasOrder() ~= self.clientHasOrder then
        
            self.clientHasOrder = self:GetHasOrder()
            
            if self.clientHasOrder then
                self:TriggerEffects("mac_set_order")
            end
            
        end

        if self.jetsCinematics then

            for id,cinematic in ipairs(self.jetsCinematics) do
                self.jetsCinematics[id]:SetIsActive(self.moving and self:GetIsVisible())
            end

        end

    end
    
end
function BigMac:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.MAC
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end


function BigMac:GetMoveSpeed()
    local lulz = MAC.kMoveSpeed * ConditionalValue(not self:GetIsInCombat(), 4, .4)
    local maxSpeedTable = { maxSpeed = lulz }
    if self.rolloutSourceFactory then
        maxSpeedTable.maxSpeed = MAC.kRolloutSpeed
    end
    self:ModifyMaxSpeed(maxSpeedTable)

    return maxSpeedTable.maxSpeed
    
end
 function BigMac:OnAdjustModelCoords(modelCoords)
         local coords = modelCoords
        coords.xAxis = coords.xAxis * 2                          
        coords.yAxis = coords.yAxis * 2                             
        coords.zAxis = coords.zAxis * 2
   
    return coords
end
local function GetBackPosition(self, target)

    if not target:isa("Player") then
        return None
    end
    
    local coords = target:GetViewAngles():GetCoords()
    local targetViewAxis = coords.zAxis
    targetViewAxis.y = 0 -- keep it 2D
    targetViewAxis:Normalize()
    local fromTarget = self:GetOrigin() - target:GetOrigin()
    local targetDist = fromTarget:GetLengthXZ()
    fromTarget.y = 0
    fromTarget:Normalize()

    local weldPos = None    
    local dot = targetViewAxis:DotProduct(fromTarget)    
    -- if we are in front or not sufficiently away from the target, we calculate a new weldPos
    if dot > 0 or targetDist < MAC.kWeldDistance - 0.5 then
        -- we are in front, find out back positon
        local obstacleSize = 0
        if HasMixin(target, "Extents") then
            obstacleSize = target:GetExtents():GetLengthXZ()
        end
        -- we do not want to go straight through the player, instead we move behind and to the
        -- left or right
        local targetPos = target:GetOrigin()
        local toMidPos = targetViewAxis * (obstacleSize + MAC.kWeldDistance - 0.1)
        local midWeldPos = targetPos - targetViewAxis * (obstacleSize + MAC.kWeldDistance - 0.1)
        local leftV = Vector(-targetViewAxis.z, targetViewAxis.y, targetViewAxis.x)
        local rightV = Vector(targetViewAxis.z, targetViewAxis.y, -targetViewAxis.x)
        local leftWeldPos = midWeldPos + leftV * 2
        local rightWeldPos = midWeldPos + rightV * 2
        --[[
        DebugBox(leftWeldPos+Vector(0,1,0),leftWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 0, 0, 1)
        DebugBox(rightWeldPos+Vector(0,1,0),rightWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 1, 0, 1)
        DebugBox(midWeldPos+Vector(0,1,0),midWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 1, 1, 1)       
        --]]
        -- take the shortest route
        local origin = self:GetOrigin()
        if (origin - leftWeldPos):GetLengthSquared() < (origin - rightWeldPos):GetLengthSquared() then
            weldPos = leftWeldPos
        else
            weldPos = rightWeldPos
        end
    end
    
    return weldPos
        
end
local function CheckBehindBackPosition(self, orderTarget)
    local toTarget = (orderTarget:GetOrigin() - self:GetOrigin())
    local distanceToTarget = toTarget:GetLength()
                    
    if not self.timeOfLastBackPositionCheck or Shared.GetTime() > self.timeOfLastBackPositionCheck + MAC.kWeldPositionCheckInterval then
 
        self.timeOfLastBackPositionCheck = Shared.GetTime()
        self.backPosition = GetBackPosition(self, orderTarget)

    end

    return self.backPosition    
end
function BigMac:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, autoWeld)
    local weldrate = MAC.kWeldRate * ConditionalValue(not self:GetIsInCombat(), 4, 2)
    local time = Shared.GetTime()
    local canBeWeldedNow = false
    local orderStatus = kOrderStatus.InProgress

    if self.timeOfLastWeld == 0 or time > self.timeOfLastWeld + weldrate then
    
        -- Not allowed to weld after taking damage recently.
        if Shared.GetTime() - self:GetTimeLastDamageTaken() <= 4.0 then

            return kOrderStatus.InProgress
            
        end
    
        -- It is possible for the target to not be weldable at this point.
        -- This can happen if a damaged Marine becomes Commander for example.
        -- The Commander is not Weldable but the Order correctly updated to the
        -- new entity Id of the Commander. In this case, the order will simply be completed.
        if orderTarget and HasMixin(orderTarget, "Weldable") then
        
            local toTarget = (orderLocation - self:GetOrigin())
            local distanceToTarget = toTarget:GetLength()
            canBeWeldedNow = orderTarget:GetCanBeWelded(self)
            
            local obstacleSize = 0
            if HasMixin(orderTarget, "Extents") then
                obstacleSize = orderTarget:GetExtents():GetLengthXZ()
            end
            
            if autoWeld and distanceToTarget > 15 then
                orderStatus = kOrderStatus.Cancelled
            elseif not canBeWeldedNow then
                orderStatus = kOrderStatus.Completed
            else
                local forceMove = false
                local targetPosition = orderTarget:GetOrigin()
                
                local closeEnoughToWeld = distanceToTarget - obstacleSize < MAC.kWeldDistance
                
                if closeEnoughToWeld then
                    local backPosition = CheckBehindBackPosition(self, orderTarget)
                    if backPosition then
                        forceMove = true
                        targetPosition = backPosition
                    end          
                end
                
                -- If we're close enough to weld, weld (unless we must move to behind the player)
                if not forceMove and closeEnoughToWeld and not GetIsVortexed(self) then
                    local weldrate = MAC.kWeldRate * ConditionalValue(not self:GetIsInCombat(), 4, 2)
                    orderTarget:OnWeld(self, weldrate)
                    self.timeOfLastWeld = time
                    self.moving = false
                    
                else
                
                    -- otherwise move towards it
                    local hoverAdjustedLocation = GetHoverAt(self, targetPosition)
                    local doneMoving = self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime)
                    self.moving = not doneMoving
                    if doneMoving then
                        self.weldPosition = None
                    end
                end
                
            end    
            
        else
            orderStatus = kOrderStatus.Cancelled
        end
        
    end
    
    -- Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if not self.moving and orderLocation then
    
        local toOrder = (orderLocation - self:GetOrigin())
        self:SmoothTurn(deltaTime, GetNormalizedVector(toOrder), 0)
        
    end
    
    return orderStatus
    
end

Shared.LinkClassToMap("BigMac", BigMac.kMapName, networkVars)