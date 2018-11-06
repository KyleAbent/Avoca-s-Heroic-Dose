local origInit = ConstructMixin.__initmixin
function ConstructMixin:__initmixin()

origInit(self)
self.level = 0
self.MaxLevel = 19
self.GainXP = 1
end

function ConstructMixin:GetIsACreditStructure()
return false
end

function ConstructMixin:GetAddXPAmount()
return 0.025
end
function ConstructMixin:GetMaxLevel()
return self.MaxLevel
end
function ConstructMixin:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, self.MaxLevel - self.level)
        self.level = self.level + xpReward
        
        self:AdjustMaxArmor( self:GetMaxArmor() * (self.level/100) + self:GetMaxArmor() ) 
   
    return xpReward
    
end
function ConstructMixin:GetLevel()
        return Round(self.level, 2)
end
  function ConstructMixin:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("%s (Lvl %s more armor)"), self:GetClassName(), self:GetLevel())
    return unitName
end 

