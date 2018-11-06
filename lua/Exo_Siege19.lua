Script.Load("lua/2019/ExoWelder.lua")


local networkVars = {   



 }

--AddMixinNetworkVars(LadderMoveMixin, networkVars)

local kDualWelderModelName = PrecacheAsset("models/marine/exosuit/exosuit_rr.model")
local kDualWelderAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_rr.animation_graph")

local kHoloMarineMaterialname = PrecacheAsset("cinematics/vfx_materials/marine_ip_spawn.material")



local origcreate = Exo.OnCreate
function Exo:OnCreate()
    origcreate(self)

end

local oninit = Exo.OnInitialized
function Exo:OnInitialized()

oninit(self)
  --  InitMixin(self, StunMixin)
     self:SetTechId(kTechId.Exo)
end
local origmodel = Exo.InitExoModel

function Exo:InitExoModel()

    local hasWelders = false
    local modelName = kDualWelderModelName
    local graphName = kDualWelderAnimationGraph
    
  if self.layout == "WelderWelder" or self.layout == "FlamerFlamer" or self.layout == "WelderFlamer" or self.layout == "RailGunWelder" 
    or self.layout == "RailgunFlamerExoSuit"  then --!= Minigun, != Railgun
         modelName = kDualWelderModelName
        graphName = kDualWelderAnimationGraph
        self.hasDualGuns = true
        hasWelders = true
        self:SetModel(modelName, graphName)
    end
    
    
    
    if hasWelders then 
    else
    origmodel(self)
    end

     
  

  
end
local origweapons = Exo.InitWeapons
function Exo:InitWeapons()
     
    local weaponHolder = self:GetWeapon(ExoWeaponHolder.kMapName)
    if not weaponHolder then
        weaponHolder = self:GiveItem(ExoWeaponHolder.kMapName, false)   
    end    
    
  
        if self.layout == "WelderWelder" then
        weaponHolder:SetWelderWeapons()
        self:SetHUDSlotActive(1)
        return
        elseif self.layout == "FlamerFlamer" then
        weaponHolder:SetFlamerWeapons()
        self:SetHUDSlotActive(1)
        return
        elseif self.layout == "WelderFlamer" then
        weaponHolder:SetWelderFlamer()
        self:SetHUDSlotActive(1)
        return
        elseif self.layout == "RailGunWelder" then
        weaponHolder:SetRailgunWelder()
        self:SetHUDSlotActive(1)
        return
        elseif self.layout == "RailgunFlamer" then
        weaponHolder:SetRailgunFlamer()
        self:SetHUDSlotActive(1)
        return
        
        end
        
        

        origweapons(self)

    
end
 
Shared.LinkClassToMap("Exo", Exo.kMapName, networkVars)