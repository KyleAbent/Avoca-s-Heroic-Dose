Spectator.kKillCamEnabled = false
kPlayerResPerInterval = 0.5
Script.Load("lua/Modifications/ModelSize.lua")
Script.Load("lua/Modifications/Remixes.lua")
Script.Load("lua/Modifications/Criticisms.lua")
Script.Load("lua/Modifications/AvocaRules.lua")
Script.Load("lua/Modifications/CystAvoca.lua")
Script.Load("lua/Modifications/PowerPointAvoca.lua")
Script.Load("lua/Modifications/AutoBioMass.lua")


Script.Load("lua/Modifications/GameStart.lua")

Script.Load("lua/Modifications/AutoMacs.lua")


if Server then

Script.Load("lua/Modifications/LightSwitch.lua")


function CommandStructure:GetCanBeUsedConstructed(byPlayer)
    return false
end


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

if Server then

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