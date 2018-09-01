--3.22.16 code to optimize

Cyst.MaxLevel = 99
Cyst.GainXP = 4
Cyst.ScaleSize = 2
Cyst.MinimumKingShifts = 4 



local networkVars =
{

  --  isKing = "boolean",
    level = "float (0 to " .. Cyst.MaxLevel .. " by .1)",
   -- wasking = "boolean",
   -- lastumbra = "time",
  --  MinKingShifts = "float (0 to " .. Cyst.MinimumKingShifts .. " by 1)",
    --UpdatedEggs = "boolean",
   -- occupiedid = "entityid",
   -- spawnedbabblers = "float"
}

local orig_Cyst_OnCreate = Cyst.OnCreate
function Cyst:OnCreate()
    orig_Cyst_OnCreate(self)
    self.level = Cyst.MaxLevel --for now until wiring into phases
  --  self.MinKingShifts = 0
   -- self.occupiedid =  Entity.invalidI
  --  self.spawnedbabblers = 0
end

if Server then
   function Cyst:GetIsActuallyConnected()
   return true
   end
end



function Cyst:GetLevel()
        return Round(self.level, 2)
end
function Cyst:GetExtentsOverride()
local kXZExtents = 0.2 * self:GetLevelPercentage()
local kYExtents = 0.1 * self:GetLevelPercentage()
local crouchshrink = 0
     return Vector(kXZExtents, kYExtents, kXZExtents)
end


function Cyst:GetLevelPercentage()
return self.level / Cyst.MaxLevel * Cyst.ScaleSize
end
function Cyst:GetMaxLevel()
return Cyst.MaxLevel
end
function Cyst:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end
function Cyst:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, Cyst.MaxLevel - self.level)
        self.level = self.level + xpReward
        local bonus = (420 * (self.level/100) + 420)
        bonus = Clamp(bonus, 420, 1000)
        bonus = bonus * 4 
        self:AdjustMaxHealth( bonus )
      //  self:AdjustMaxArmor(Clamp(420 * (self.level/100) + 420), 420, 500)
        
   
    return xpReward
    
end
function Cyst:LoseXP(amount)

        self.level = Clamp(self.level - amount, 0, 50)
        
        local bonus = (420 * (self.level/100) + 420)
        bonus = Clamp(bonus, 420, 1000)
        self:AdjustMaxHealth( bonus )
    
end

if Server then
     local onup = Cyst.OnUpdate
    function Cyst:OnUpdate(deltaTime)
        onup(self, deltaTime)
        if self:GetIsAlive() then
            local time = Shared.GetTime()
          --  if self.timeoflastkingdate == nil or (time > self.timeoflastkingdate + 1) then
               -- self:AddXP(Cyst.GainXP)
            -- end
        end
     end  

end 
                

function Cyst:GetInfestationRadius()
    return math.max(kInfestationRadius, kCystRedeployRange)
end

function Cyst:GetCystParentRange()
return 999
end
function Cyst:GetCanAutoBuild()

return true

end

