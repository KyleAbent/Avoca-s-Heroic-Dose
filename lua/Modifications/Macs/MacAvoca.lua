class 'MacAvoca' (MAC)
MacAvoca.kMapName = "macavoca"

local networkVars = {}

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
            local constructables = GetEntitiesWithMixinForTeamWithinRange("Construct", self:GetTeamNumber(), self:GetOrigin(), MAC.kOrderScanRadius)
            for c = 1, #constructables do
            
                local constructable = constructables[c]
                if constructable:GetCanConstruct(self) then
                
                    target = constructable
                    orderType = kTechId.Construct
                    break
                    
                end
                
            end
            
            if not target then
            
                -- Look for entities to heal with weld.
                local weldables = GetEntitiesWithMixinForTeamWithinRange("Weldable", self:GetTeamNumber(), self:GetOrigin(), MAC.kOrderScanRadius)
                for w = 1, #weldables do
                
                    local weldable = weldables[w]
                    -- There are cases where the weldable's weld percentage is very close to
                    -- 100% but not exactly 100%. This second check prevents the MAC from being so pedantic.
                    if weldable:GetCanBeWelded(self) and weldable:GetWeldPercentage() < 1 and not weldable:isa("MAC") then
                    
                        target = weldable
                        orderType = kTechId.AutoWeld
                        break

                    end
                    
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
function MacAvoca:GetDeathIconIndex()
    return kDeathMessageIcon.MAC
end
function MacAvoca:OnUpdate(deltaTime)
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
        
            if not self.timeLastWeldEffect or self.timeLastWeldEffect + MAC.kWeldRate < Shared.GetTime()  then
            
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
function MacAvoca:OnGetMapBlipInfo()
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
Shared.LinkClassToMap("MacAvoca", MacAvoca.kMapName, networkVars)