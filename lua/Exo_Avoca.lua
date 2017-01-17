
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
