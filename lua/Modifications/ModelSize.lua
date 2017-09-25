-- Kyle 'Avoca' Abent :P 
  --Inspired by 'Dragon' 'GorgeZilla' mod which led to 'Modelsize' in 'SiegeModCommands' which I wrote, also 'RTD' roll, etc.

function Embryo:OnAdjustModelCoords(coords)
---Adjust Embryo modelsize with gestation percentage
    coords.origin = coords.origin - Embryo.kSkinOffset
    
    	local scale = Clamp(self.evolvePercentage / 100, .05, 1)
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
        
    return coords
    
end
function RoboticsFactory:OnAdjustModelCoords(coords)
    
    	local scale = 0.5
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
        
    return coords
    
end
function ARC:OnAdjustModelCoords(coords)
    
    	local scale = not self:GetInAttackMode() and 0.5 or 1
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
        
    return coords
    
end
function PrototypeLab:OnAdjustModelCoords(coords)
    
    	local scale = 0.5
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
        
    return coords
    
end
function Armory:OnAdjustModelCoords(coords)
    
    	local scale = 0.5
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
        
    return coords
    
end
function InfantryPortal:OnAdjustModelCoords(coords)
    
    	local scale = 0.5
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
        
    return coords
    
end
 function LiveMixin:OnAdjustModelCoords(modelCoords)
         local coords = modelCoords
    if self:GetTeamNumber() == 2 and not self:isa("PowerDrainer") and not self:isa("Hive") then
    local isplayer = self:isa("Alien")
        local value = Clamp(self:GetHealthScalar(), .3, 1)
    	local scale = Clamp(value + (isplayer and .8 or 0), value, 1)  --Because I dont want 70%hp to drop to 70% size 
        coords.xAxis = coords.xAxis * scale                             --But instead have the drop enable at 70% hp and be 
        coords.yAxis = coords.yAxis * scale                              -- 100% size at 70% hp, but at 60% hp be 90% size, etc.
        coords.zAxis = coords.zAxis * scale
     end
   
    return coords
end


