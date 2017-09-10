--New class eventually?

Script.Load("lua/InfestationMixin.lua")

local networkVars = 

{   
}

AddMixinNetworkVars(InfestationMixin, networkVars)

function Whip:GetMinRangeAC()
return 14/3       
end


function Whip:OnConstructionComplete()

    self:GiveUpgrade(kTechId.WhipBombard)

end


local orig_Whip_OnInit = Whip.OnInitialized
function Whip:OnInitialized()
    orig_Whip_OnInit(self)
  InitMixin(self, InfestationMixin)

end

  function  Whip:GetInfestationRadius()
     return kInfestationRadius
   end
   
if Server then

local origupdate = Whip.OnUpdate
function Whip:OnUpdate(deltaTime)
        origupdate(self, deltaTime)
        Whip.kDamage = kWhipSlapDamage * Clamp(self:GetHealthScalar(), .3, 1)
end

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