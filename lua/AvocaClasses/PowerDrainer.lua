class 'PowerDrainer' (Whip)
PowerDrainer.kMapName = "powerdrainer"


local kHallucinationMaterial = PrecacheAsset("materials/power/powered_decal.material")

PowerDrainer.kAnimationGraph = PrecacheAsset("models/alien/powerdrainer/powerdrainer.animation_graph")

function PowerDrainer:OnCreate()
 Whip.OnCreate(self)
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
end
function PowerDrainer:GetMaxHealth()
    return kMatureWhipHealth * 1.3
end 

function PowerDrainer:GetMaxArmor()
    return kMatureWhipArmor * 1.3
end 

function PowerDrainer:OnInitialized()
  Whip.OnInitialized(self)
      self:SetModel(Whip.kModelName, PowerDrainer.kAnimationGraph)
      
  
  if Server then
        local targetTypes = { kAlienStaticTargets, kAlienMobileTargets }
        self.slapTargetSelector = TargetSelector():Init(self, Whip.kRange + 4, true, targetTypes,  { self.FilterTarget(self) })
        self.bombardTargetSelector = TargetSelector():Init(self, Whip.kBombardRange + 4, true, targetTypes, { self.FilterTarget(self) })
  end
      
end

function PowerDrainer:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Whip
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function PowerDrainer:UpdateRootState()
    
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
function PowerDrainer:ActivateSelfDestruct()
              self:AddTimedCallback(PowerDrainer.Killme, 1)
end
function PowerDrainer:GetSendDeathMessageOverride()
return false
end
function PowerDrainer:Killme()
 --self:Kill()
    self:DeductHealth(90)

     return true
end
function PowerDrainer:FilterTarget()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end
function PowerDrainer:GetCanFireAtTargetActual(target, targetPoint)    
   return target:isa("PowerPoint") and target.health ~= 0 
    
end

function PowerDrainer:ModifyDamageTaken(damageTable, attacker, doer, damageType)
     local damage = 1.3
        if attacker and attacker:isa("MainRoomArc") then damage = damage * .25 end
        
        damageTable.damage = damageTable.damage * damage
end
if Client then

    function PowerDrainer:OnUpdateRender()
          local showMaterial = true --not GetAreEnemies(self, Client.GetLocalPlayer()) --and self.isbeacon --and not self.flying
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kHallucinationMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client
Shared.LinkClassToMap("PowerDrainer", PowerDrainer.kMapName, networkVars)