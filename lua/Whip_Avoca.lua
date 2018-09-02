--New class eventually?

Script.Load("lua/InfestationMixin.lua")

local networkVars = 

{   
    damageRes = "integer (0 to 30)",
}

AddMixinNetworkVars(InfestationMixin, networkVars)

function Whip:GetMinRangeAC()
return 14/5    
end


function Whip:OnConstructionComplete()

    self:GiveUpgrade(kTechId.WhipBombard)

end


 
  function  Whip:GetInfestationRadius()
     if  GetConductor():GetIsPhaseTwoBoolean() then
     return kInfestationRadius
     elseif  GetConductor():GetIsPhaseOneBoolean() then
     return kInfestationRadius/3
     else
     return kInfestationRadius /4
     end
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
