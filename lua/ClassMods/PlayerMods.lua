 --Thanks for the trick, modular exo
local orig_Marine_GetMaxSpeed = Marine.GetMaxSpeed
function Marine:GetMaxSpeed(possible)
 local original = orig_Marine_GetMaxSpeed(self)
 local moveSpeed = (self:GetGameEffectMask(kGameEffect.OnInfestation) ) and original * 0.65 or original
 
 return moveSpeed



end 



local orig_Alien_OnCreate = Alien.OnCreate
function Alien:OnCreate()
    orig_Alien_OnCreate(self)
    if Server then
     self:AddTimedCallback(function() UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId()) end, .8) 
    elseif Client then
        GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar")  
    end
end


if Server then


local orig_Marine_InitWeapons = Marine.InitWeapons
function Marine:InitWeapons()
    orig_Marine_InitWeapons(self)
    self:GiveItem(Welder.kMapName)
    self:SetQuickSwitchTarget(Pistol.kMapName)
    self:SetActiveWeapon(Rifle.kMapName)
end


function Alien:HiveCompleteSoRefreshTechsManually()
UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId())
end

function Marine:ModifyGravityForce(gravityTable)
      if self:GetIsOnGround() then
            gravityTable.gravity = 0
      elseif self:GetHasCatpackBoost() then
            gravityTable.gravity = -5
       end
end



function Exo:PerformEjectOnPree()
    
        if self:GetIsAlive() then
       
            local reuseWeapons = self.storedWeaponsIds ~= nil
        
            local marine = self:Replace(self.prevPlayerMapName or Marine.kMapName, self:GetTeamNumber(), false, self:GetOrigin() + Vector(0, 0.2, 0))
            local health = Clamp(self.prevPlayerHealth or kMarineHealth-30, 1, 70)
            marine:SetHealth(health)
            marine:SetMaxArmor(self.prevPlayerMaxArmor or kMarineArmor)
            marine:SetArmor(self.prevPlayerArmor or kMarineArmor)
            
            --exosuit:SetOwner(marine)
            
            marine.onGround = false
            local initialVelocity = self:GetViewCoords().zAxis
            initialVelocity:Scale(4)
            initialVelocity.y = 9
            marine:SetVelocity(initialVelocity)
            
            if reuseWeapons then
         
                for _, weaponId in ipairs(self.storedWeaponsIds) do
                
                    local weapon = Shared.GetEntity(weaponId)
                    if weapon then
                        marine:AddWeapon(weapon)
                    end
                    
                end
            
            end
            
            marine:SetHUDSlotActive(1)
            
            if marine:isa("JetpackMarine") then
                marine:SetFuel(0)
            end
        
        end
    
        return false
    
end
function Exo:PreOnKill(attacker, doer, point, direction)
          self:PerformEjectOnPree()
end









end



if Client then
function MarineActionFinderMixin:OnProcessMove(input)
    return
end

function AlienActionFinderMixin:OnProcessMove(input)
    return
end

end
