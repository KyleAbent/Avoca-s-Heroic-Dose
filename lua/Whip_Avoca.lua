--New class eventually?

Script.Load("lua/InfestationMixin.lua")

local networkVars = 

{   
}

AddMixinNetworkVars(InfestationMixin, networkVars)
local kRangeSquared        = Whip.kBombardRange^2

function Whip:GetMinRangeAC()
return 12/4       
end


function Whip:OnConstructionComplete()

    self:GiveUpgrade(kTechId.WhipBombard)

end


local orig_Whip_OnInit = Whip.OnInitialized
function Whip:OnInitialized()
    orig_Whip_OnInit(self)
  InitMixin(self, InfestationMixin)
end


   
function Whip:GetWhipsInRange()
      local whip = GetEntitiesWithinRange("Whip", self:GetOrigin(), Whip.kBombardRange)
      return Clamp(#whip - 1, 0.1, 7)
end

function Whip:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil then
        damageTable.damage = damageTable.damage - (self:GetWhipsInRange()*10/100) * damageTable.damage
    end

end

function Whip:GetDmgResAmt()
return (self:GetWhipsInRange()/7)
end

function Whip:GetUnitNameOverride(viewer) --Triggerhappy stoner
    local unitName = GetDisplayName(self)   
    --unitName = string.format(Locale.ResolveString("Crag (+%sS 0%)"), self:GetCragsInRange()) --, self:GetBonusAmt() )
    unitName = "Whip (+"..self:GetWhipsInRange().."0% dmgres)" --, self:GetBonusAmt() )
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


function Whip:Instruct()
   --Print("Whip instructing")
   -- CheckHivesForScan(self)
   self:SpecificRules()
   return true
end

local function CheckForAndActAccordingly(who)
local stopandroot = false
 local selector = (who.slapping and who.slapTargetSelector or who.bombardTargetSelector)
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 1, who:GetOrigin(), Whip.kBombardRange)) do
              //local distToTarget = (enemy:GetOrigin() - who:GetOrigin()):GetLengthXZ()
              if not enemy:isa("PowerPoint") and who:GetCanAttackTarget(selector, enemy, kRangeSquared) then
             stopandroot = true
             break
             end
          end
        --Print("stopanddeploy is %s", stopanddeploy)
       return stopandroot
end
local function CanMoveTo(self, target)    
    
    return true
    
end
local function GetRandomEligable(self)
 local eligable = {}
      //  for index, target in ipairs(GetEntitiesWithMixinWithinRange("Construct", self:GetOrigin(), 9999 )) do
      
          local target =  GetNearestMixin(self:GetOrigin(), "Live", 1, 
          function(ent) 
          return ent:GetIsAlive() 
          and CanMoveTo(self, ent)  
          and  ( not ent:isa("PowerPoint")  or ent:isa("PowerPoint") and not ent:GetIsDisabled() ) 
          and not ent:isa("ARC")
          end)
          
             if not target then
               return nil
             else
              return target
              end
         // end
       //   if #eligable == 0 then return nil end
        //  local ent = table.random(eligable)
        --  Print("GetRandomEligable is %s", ent:GetMapName())
         // return  ent
end
local function MoveToMainRoom(self)
      local ent = GetRandomEligable(self)
             -- Print("MoveToMainRoom ent is %s", ent:GetMapName())
      if not ent then return end
      local where = ent:GetOrigin()
      if not where then return end
      self:GiveOrder(kTechId.Move, nil, FindFreeSpace(where), nil, true, true)

end
local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 2, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end
local function GiveAttack(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.Attack, who:GetId(), who:GetOrigin(), nil, true, true)

end
function Whip:SpecificRules()
--BuffPlayers(self)

local moving = self.moving    
//Print("moving is %s", moving) 
        
local attacking = self.slapping or self.bombarding
//Print("attacking is %s", attacking) 
local inradius =  CheckForAndActAccordingly(self)  
//Print("inradius is %s", inradius) 
local shouldstop =  moving and ( self:GetIsInCombat() or inradius )
//Print("shouldstop is %s", shouldstop) 
local shouldmove = not shouldstop and not inradius
//Print("shouldmove is %s", shouldmove) 
      shouldstop = moving and shouldstop
//Print("shouldstop is %s",   shouldstop) 
local shouldattack = inradius and not attacking 
//Print("shouldattack is %s", shouldattack) 
  
  if moving then
           if shouldstop and shouldattack then 
           FindNewParent(self)
          //  Print("StopOrder")
          self:GiveOrder(kTechId.Stop, nil, self:GetOrigin(), nil, true, true)
      //   self:SetMode(ARC.kMode.Stationary)
            end 
 elseif not moving then
      
            if shouldmove and not shouldattack  then
             //   Print("MoveToMainRoom")
             MoveToMainRoom(self)
            end 
 end
 
    
end

