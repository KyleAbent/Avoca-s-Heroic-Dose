Script.Load("lua/StunMixin.lua")
Script.Load("lua/PhaseGateUserMixin.lua")
Script.Load("lua/Mixins/LadderMoveMixin.lua")
Script.Load("lua/Additions/StunWall.lua")
Script.Load("lua/Additions/ExoWelder.lua")


local networkVars = {   


  --isLockedEjecting = "private boolean",

  --  wallboots = "private boolean",
  --  wallWalking = "compensated boolean",
  --  timeLastWallWalkCheck = "private compensated time",

 }
  /*
local kNormalWallWalkFeelerSize = 0.25
local kNormalWallWalkRange = 0.3
local kJumpWallRange = 0.4
local kJumpWallFeelerSize = 0.1
local kWallJumpInterval = 0.4
local kWallJumpForce = 5.2 -- scales down the faster you are
local kMinWallJumpForce = 0.1
local kVerticalWallJumpForce = 4.3
*/

AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(PhaseGateUserMixin, networkVars)
AddMixinNetworkVars(LadderMoveMixin, networkVars)

local kDualWelderModelName = PrecacheAsset("models/marine/exosuit/exosuit_rr.model")
local kDualWelderAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_rr.animation_graph")

local kHoloMarineMaterialname = PrecacheAsset("cinematics/vfx_materials/marine_ip_spawn.material")



local origcreate = Exo.OnCreate
function Exo:OnCreate()
    origcreate(self)
    InitMixin(self, PhaseGateUserMixin)
    InitMixin(self, LadderMoveMixin)
   -- InitMixin(self, WallMovementMixin)
    --self.isLockedEjecting = false
  --  self.wallboots = true
   -- self.wallWalking = false
 --   self.wallWalkingNormalGoal = Vector.yAxis
--    self.timeLastWallJump = 0

end
/*
function Exo:GetIsWallWalking()
    return self.wallWalking and self.wallboots
end
function Exo:GetIsWallWalkingPossible() 
    return true--not self:GetRecentlyJumped() and not self:GetCrouching() -- and self.wallboots
end
function Exo:GetPerformsVerticalMove()
    return self:GetIsWallWalking()
end
function Exo:OverrideUpdateOnGround(onGround)
    return onGround or self:GetIsWallWalking()
end
local origangles = Marine.GetDesiredAngles
function Exo:GetDesiredAngles()

   if self:GetIsWallWalking() then return self.currentWallWalkingAngles end
       return origangles(self)
end
function Exo:GetIsUsingBodyYaw()
    return not self:GetIsWallWalking()
end
function Exo:GetIsUsingBodyYaw()
    return not self:GetIsWallWalking()
end
function Exo:GetAngleSmoothingMode()

    if self:GetIsWallWalking() then
        return "quatlerp"
    else
        return "euler"
    end

end
function Exo:OnWorldCollision(normal, impactForce, newVelocity)

    PROFILE("Exo:OnWorldCollision")

    self.wallWalking = self:GetIsWallWalkingPossible() and normal.y < 0.5
    
end
function Exo:PreUpdateMove(input, runningPrediction)
    PROFILE("Exo:PreUpdateMove")
    self.prevY = self:GetOrigin().y

    if self:GetIsWallWalking() then

        -- Most of the time, it returns a fraction of 0, which means
        -- trace started outside the world (and no normal is returned)           
        local goal = self:GetAverageWallWalkingNormal(kNormalWallWalkRange, kNormalWallWalkFeelerSize)
        if goal ~= nil then 
        
            self.wallWalkingNormalGoal = goal
            self.wallWalking = true
           -- self:SetEnergy(self:GetEnergy() - kWallWalkEnergyCost)

        else
            self.wallWalking = false
        end
    
    end
    
    if not self:GetIsWallWalking() then
        -- When not wall walking, the goal is always directly up (running on ground).
        self.wallWalkingNormalGoal = Vector.yAxis
    end
    
   

  --  if self.leaping and Shared.GetTime() > self.timeOfLeap + kLeapTime then
  --      self.leaping = false
  --  end
    
    self.currentWallWalkingAngles = self:GetAnglesFromWallNormal(self.wallWalkingNormalGoal or Vector.yAxis) or self.currentWallWalkingAngles


end
function Exo:GetMoveSpeedIs2D()
    return not self:GetIsWallWalking()
end
function Exo:GetCanStep()
    return not self:GetIsWallWalking()
end




local function HealSelf(self)


  local toheal = true
   --  Print("toheal is %s", toheal)
    if toheal then
    local amt = kNanoArmorHealPerSecond
    amt = amt * ConditionalValue(self:GetIsInCombat(), 0, 2)
    self:SetArmor(self:GetArmor() + amt, true) 
    end
    return true
end

*/

local kPhaseDelay = 2

function Exo:GetCanPhase()

    if Server then
        return self:GetIsAlive() and Shared.GetTime() > self.timeOfLastPhase + kPhaseDelay and not GetConcedeSequenceActive() 
    else
        return self:GetIsAlive() and Shared.GetTime() > self.timeOfLastPhase + kPhaseDelay 
    end
end

local oninit = Exo.OnInitialized
function Exo:OnInitialized()

oninit(self)
    InitMixin(self, StunMixin)
   self:SetTechId(kTechId.Exo)
  -- self:AddTimedCallback(function() HealSelf(self) return true end, 1) 
  --  self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)
 --   self.timeLastWallJump = 0
end
local origmodel = Exo.InitExoModel

function Exo:InitExoModel()

    local hasWelders = false
    local modelName = kDualWelderModelName
    local graphName = kDualWelderAnimationGraph
    
  if self.layout == "WelderWelder" or self.layout == "FlamerFlamer" or self.layout == "WelderFlamer" then --!= Minigun, != Railgun
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
        end
        
        
        

        origweapons(self)

    
end



function Exo:GetIsStunAllowed()
    return not self.timeLastStun or self.timeLastStun + 8 < Shared.GetTime() 
end

function Exo:OnStun()    --so the stunwall places the exo in the air making him unable to shoot. not good. 
         if Server then
                local stunwall = CreateEntity(StunWall.kMapName, self:GetOrigin(), 2)    
                StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, self)
        end
end

    /*
function Exo:EjectExo()

    if self:GetCanEject() then
         
        if Server then
            self:PerformDelayedEject()
        end
    
    end

end
if Server then

    function Exo:PerformDelayedEject()
          self:SetCameraDistance(3)
          if Client then CreateSpinEffect(self) end
          self.isLockedEjecting = true
          self:AddTimedCallback(function() self.isLockedEjecting = false self:SetCameraDistance(0) Exo.PerformEject(self)  end, 1)
    
    end
end
*/

    function Exo:OnKill(attacker, doer, point, direction)
        
            
           local reuseWeapons = self.storedWeaponsIds ~= nil
        
            local marine = self:Replace(self.prevPlayerMapName or Marine.kMapName, self:GetTeamNumber(), false, self:GetOrigin() + Vector(0, 0.2, 0), { preventWeapons = reuseWeapons })
            marine:SetHealth(self.prevPlayerHealth or kMarineHealth)
            marine:SetMaxArmor(self.prevPlayerMaxArmor or kMarineArmor)
            marine:SetArmor(self.prevPlayerArmor or kMarineArmor)
            
            --exosuit:SetOwner(marine) --explode lol
            
            marine.onGround = false
            local initialVelocity = self:GetViewCoords().zAxis
            initialVelocity:Scale(4)
            initialVelocity.y = math.max(0,initialVelocity.y) + 9
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
                marine:SetFuel(0.25)
            end
        

        return false
    
end


Shared.LinkClassToMap("Exo", Exo.kMapName, networkVars)