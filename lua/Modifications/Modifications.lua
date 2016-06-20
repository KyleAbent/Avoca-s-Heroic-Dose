Spectator.kKillCamEnabled = false
kPlayerResPerInterval = 0.5
Script.Load("lua/Modifications/ModelSize.lua")
Script.Load("lua/Modifications/Remixes.lua")
Script.Load("lua/Modifications/Criticisms.lua")
Script.Load("lua/Modifications/AvocaRules.lua")
Script.Load("lua/Modifications/CystAvoca.lua")
Script.Load("lua/Modifications/PowerPointAvoca.lua")
Script.Load("lua/Modifications/AutoBioMass.lua")
Script.Load("lua/Modifications/AutoEggEvolve.lua")
Script.Load("lua/Modifications/AvocaArc.lua")
Script.Load("lua/Modifications/HiveCrag.lua")



Script.Load("lua/Modifications/GameStart.lua")

Script.Load("lua/Modifications/AutoMacsArcs.lua")




if Server then
Script.Load("lua/Modifications/ArmoryArmor.lua")
Script.Load("lua/Modifications/LightSwitch.lua")




end

function GhostStructureMixin:__initmixin()

    -- init the entity in ghost structure mode
    if Server then
        self.isGhostStructure = self:isa("Extractor")
    end
    
end

function Harvester:GetCanAutoBuild()

return true

end

SetCachedTechData(kTechId.Harvester, kTechDataRequiresInfestation, false)
SetCachedTechData(kTechId.Crag, kTechDataRequiresInfestation, false)
SetCachedTechData(kTechId.Whip, kTechDataRequiresInfestation, false)
SetCachedTechData(kTechId.Egg, kTechDataRequiresInfestation, false)

if Server then

function CommandStructure:GetCanBeUsedConstructed(byPlayer)
    return false
end


function CommandStructure:OnUpdateAnimationInput(modelMixin)

    PROFILE("CommandStructure:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("occupied", true)
    
end
/*
function Location:GetTrackEntity(enterEnt)
    local boolean = GetAreEnemies(self, enterEnt) and HasMixin(enterEnt, "Live") and enterEnt:GetIsAlive()
    Print("%s returned %s for gettrackentity", enterEnt:GetClassName() or nil, boolean)
    return
end
*/
function PowerPoint:ModifyDamageTaken(damageTable, attacker, doer, damageType)
       if attacker and attacker:isa("PowerDrainer") then damageTable.damage = damageTable.damage * 1.3 end
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


/*
 function ConstructMixin:PreOnKill(attacker, doer, point, direction)
      if not self:isa("PowerPoint") and not self:isa("Extractor") and not self:isa("ARC") then
                  local gameRules = GetGamerules()
              if gameRules then
              
                 local origin = self:GetOrigin()
                 if self:isa("ArmsLab") then
                   local nearestCC = GetNearest(origin, "CommandStation", 1)  
                   if nearestCC then 
                     origin = nearestCC:FindFreeSpace()
                     end
                  end
  
                 gameRules:DelayedAllowance(origin, self:TypesOfSelfInRoomNonCredit(), self:GetTechId(), self:GetMapName())
               end
       end
    end
*/


end