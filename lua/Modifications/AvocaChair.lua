class 'AvocaChair' (CommandStation)
AvocaChair.kMapName = "avocachair"

Script.Load("lua/DamageMixin.lua")


function CommandStation:GetRequiresPower()
 return true
end
function CommandStation:OhNoYouDidnt()

     for _, powerconsumer in ipairs(GetEntitiesWithMixinForTeamWithinRange("PowerConsumer", 1, self:GetOrigin(), 24)) do
          if powerconsumer ~= self and (powerconsumer:GetRequiresPower() and not powerconsumer:GetIsPowered()) then
          powerconsumer:SetPowerSurgeDuration(8)
          powerconsumer:TriggerEffects("arc_hit_secondary")
          end
     end
     
     self:TriggerEffects("arc_hit_primary")
 return not self:GetIsPowered()
end
function CommandStation:OnPowerOff()
        self:AddTimedCallback(CommandStation.OhNoYouDidnt, 8)
end
function AvocaChair:OnCreate()
 CommandStation.OnCreate(self)
 InitMixin(self, DamageMixin)
   if Server then
 self:AddTimedCallback(AvocaChair.SelfDefense, 8)
 end

end
function AvocaChair:GetDamageType()
return kDamageType.StructuresOnly
end

function AvocaChair:GetRequiresPower()
 return false
end

function AvocaChair:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.CommandStation
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

if Server then

function AvocaChair:OnConstructionComplete()
    self:TriggerEffects("deploy")  
    self:AddTimedCallback(AvocaChair.BaseThisBitchUp, math.random(4,8))  
end


function AvocaChair:BaseThisBitchUp()
local techPointOrigin = self:GetOrigin()
    CreateEntity(InfantryPortal.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    CreateEntity(InfantryPortal.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    CreateEntity(Armory.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    CreateEntity(ArmsLab.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    CreateEntity(PrototypeLab.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    CreateEntity(PhaseGate.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    CreateEntity(Observatory.kMapName, FindFreeSpace(techPointOrigin,8), 1)
    return false
end

function AvocaChair:SelfDefense()
 local hitEntities = {}

         for _, target in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct", 2, self:GetOrigin(), 24)) do
           table.insert(hitEntities,target)
        end
        
     if table.count(hitEntities) >=1  then
     RadiusDamage(hitEntities, self:GetOrigin(), 24, 800, self,true)
     self:TriggerEffects("arc_hit_primary")
      
        for index, target in ipairs(hitEntities) do
            if HasMixin(target, "Effects") then
                target:TriggerEffects("arc_hit_secondary")
            end 
        end
      
      
   end

  return true

end


end

Shared.LinkClassToMap("AvocaChair", AvocaChair.kMapName, networkVars)