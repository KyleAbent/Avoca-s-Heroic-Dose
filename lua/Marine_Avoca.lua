 --Thanks for the trick, modular exo
local orig_Marine_GetMaxSpeed = Marine.GetMaxSpeed
function Marine:GetMaxSpeed(possible)
 local original = orig_Marine_GetMaxSpeed(self)
 local moveSpeed = (self:GetGameEffectMask(kGameEffect.OnInfestation) ) and original * 0.65 or original
 
 return moveSpeed



end 

local orig_Marine_OnCreate = Marine.OnCreate
function Marine:OnCreate()
    orig_Marine_OnCreate(self)
    if Server then
    elseif Client then
        GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar")  
    end
end

local orig_Marine_InitWeapons = Marine.InitWeapons
function Marine:InitWeapons()
    orig_Marine_InitWeapons(self)
    self:GiveItem(Welder.kMapName)
    self:SetQuickSwitchTarget(Pistol.kMapName)
    self:SetActiveWeapon(Rifle.kMapName)
end


function Marine:ModifyGravityForce(gravityTable)
      if self:GetIsOnGround() then
            gravityTable.gravity = 0
      elseif self:GetHasCatpackBoost() then
            gravityTable.gravity = -5
       end
end

