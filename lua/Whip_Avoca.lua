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


local orig_Whip_OnInit = Whip.OnInitialized
function Whip:OnInitialized()
    orig_Whip_OnInit(self)
  InitMixin(self, InfestationMixin)
  



    if  GetConductor():GetIsPhaseFourBoolean()  then 
        self.damageRes = 30
       
    elseif  GetConductor():GetIsPhaseThreeBoolean()  then 
       self.damageRes = 20
      
    elseif GetConductor():GetIsPhaseTwoBoolean()  then 
       self.damageRes = 10
       
    else
        self.damageRes = 1
    end
    
end


   /*
   
   if I do dmgres then do it as a networkvar amt gradually increased by the current phase
     or just gradually increase maxhp on init based on round
   
function Whip:GetWhipsInRange()
      local whip = GetEntitiesWithinRange("Whip", self:GetOrigin(), Whip.kBombardRange)
      return Clamp(#whip - 1, 0.1, 7)
end
  */

function Whip:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil then
        damageTable.damage = damageTable.damage - (self.damageRes/100) * damageTable.damage
    end

end


function Whip:GetUnitNameOverride(viewer) --Triggerhappy stoner
    local unitName = GetDisplayName(self)   
    --unitName = string.format(Locale.ResolveString("Crag (+%sS 0%)"), self:GetCragsInRange()) --, self:GetBonusAmt() )
    unitName = "Whip (+"..self.damageRes.."% dmgres)" --, self:GetBonusAmt() )
return unitName
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


    
local origupdate = Whip.OnUpdate
function Whip:OnUpdate(deltaTime)
        origupdate(self, deltaTime)
        self.kDamage = kWhipSlapDamage * Clamp(self:GetHealthScalar(), .3, 1)
        self.kRange = 7 * Clamp(self:GetHealthScalar(), .3, 1)
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