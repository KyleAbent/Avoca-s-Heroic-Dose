--New class eventually?

local orig_Whip_OnInit = Whip.OnInitialized
function Whip:OnInitialized()
    orig_Whip_OnInit(self)
  
       if Server then
        local targetTypes = { kAlienStaticTargets, kAlienMobileTargets }, { self.FilterTarget(self) }
        self.slapTargetSelector = TargetSelector():Init(self, Whip.kRange, true, targetTypes)
        self.bombardTargetSelector = TargetSelector():Init(self, Whip.kBombardRange, true, targetTypes)
        end
end

function Whip:FilterTarget()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end
function Whip:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("AvocaArc") and not target:GetInAttackMode() then
    return false
    end
    
    return true
    
end
if Server then

function Whip:UpdateRootState()
    
    local infested = true --self:GetGameEffectMask(kGameEffect.OnInfestation)
    local moveOrdered = self:GetCurrentOrder() and self:GetCurrentOrder():GetType() == kTechId.Move
    -- unroot if we have a move order or infestation recedes
    if self.rooted and (moveOrdered or not infested) then
        self:Unroot()
    end
    
    -- root if on infestation and not moving/teleporting
    if not self.rooted and infested and not (moveOrdered or self:GetIsTeleporting()) then
        self:Root()
    end
    
end
end
function Whip:OnKill(attacker, doer, point, direction)
 --if attacker and attacker:isa("ARC") then AddPayLoadTime(1) end
end