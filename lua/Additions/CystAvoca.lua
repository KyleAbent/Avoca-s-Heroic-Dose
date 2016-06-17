class 'CystAvoca' (Cyst)
CystAvoca.kMapName = "cystavoca"

function CystAvoca:OnCreate()
  Cyst.OnCreate(self)
  self:AddTimedCallback(CystAvoca.Heal, 4)
end
function CystAvoca:GetCystParentRange()
return 999
end
function CystAvoca:Heal()
   if self:GetHealth() == self:GetMatureMaxHealth() then return true end
   local gain = math.min(self:GetMatureMaxHealth() - self:GetHealth()) / math.random(4,8)
   self:AddHealth(gain, false, false, false)
   return self:GetIsAlive() and not self:GetIsDestroyed()
end
function CystAvoca:GetCystParentRange()
return 999
end

if Server then
   function CystAvoca:GetIsActuallyConnected()
   return true
   end
end

function CystAvoca:GetMatureMaxHealth()
    return (math.max(kMatureCystHealth * self.healthScalar or 0, kMinMatureCystHealth)) * 4
end 

function CystAvoca:GetMatureMaxArmor()
    return kMatureCystArmor * 4
end 
/*
function CystAvoca:GetMaturityRate()

end
*/
function CystAvoca:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
        local scale = Clamp( 4 * (self:GetHealthScalar() * self:GetMaturityFraction()), .5, 4)
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end


Shared.LinkClassToMap("CystAvoca", CystAvoca.kMapName, networkVars)