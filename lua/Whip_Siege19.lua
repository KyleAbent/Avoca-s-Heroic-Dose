

Script.Load("lua/2019/DigestCommMixin.lua")

  local kKarmaMaterialAlien = PrecacheAsset("cinematics/vfx_materials/karma.material")

local networkVars = { 

  lastCyst = "time",
}

AddMixinNetworkVars(DigestCommMixin, networkVars)


local originit = Whip.OnInitialized
function Whip:OnInitialized()

originit(self)

    Whip.kMoveSpeed = ConditionalValue( GetHasTech(self, kTechId.WhipBuff1), 3.5 * 1.05, 3.5)  
    Whip.kMaxMoveSpeedParam = ConditionalValue( GetHasTech(self, kTechId.WhipBuff1), 10 * 1.05, 10)
    Whip.kRange = ConditionalValue( GetHasTech(self, kTechId.WhipBuff1), 7 * 1.05, 7) 
    Whip.kBombardRange = ConditionalValue( GetHasTech(self, kTechId.WhipBuff1), 20 * 1.05, 20) 
    Whip.kBombSpeed = ConditionalValue( GetHasTech(self, kTechId.WhipBuff1), 20 * 1.05, 20) 

end

local origcreate = Whip.OnCreate
function Whip:OnCreate()
   origcreate(self)
    InitMixin(self, DigestCommMixin)
    self.lastCyst = 0
 end
 
 
local origbuttons = Whip.GetTechButtons
function Whip:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

  table[3] = kTechId.WhipBuff1
 table[8] = kTechId.DigestComm
 return table

end

local originit = Whip.OnInitialized
function Whip:OnInitialized()
originit(self)

end


function Whip:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("BreakableDoor") and target.health == 0 then
    return false
    end
    
    return true
    
end


function Whip:OnConstructionComplete()
	 GetImaginator().activeWhips = GetImaginator().activeWhips + 1;  
end


 function Whip:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsBuilt() then
	    GetImaginator().activeWhips  = GetImaginator().activeWhips- 1;  
	  end
end


if Server then

function Whip:UpdateRootState()


        self:Root()

end

function Whip:OnUpdate(deltaTime)
       if self.moving and GetIsTimeUp(self.lastCyst, 6)  then
              doChain(self)
              self.lastCyst = Shared.GetTime()
       end
       
       if self.moving then
         if self:GetIsInCombat() then
            self:ClearOrders()
         end
       end

end

end



Shared.LinkClassToMap("Whip", Whip.kMapName, networkVars)