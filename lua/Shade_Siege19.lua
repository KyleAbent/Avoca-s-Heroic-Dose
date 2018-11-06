
--Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/2019/DigestCommMixin.lua")

local networkVars = { 

 shouldInk = "boolean",
  lastInk = "time",
}


--AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(DigestCommMixin, networkVars)


local origcreate = Shade.OnCreate
function Shade:OnCreate()
   origcreate(self)
    InitMixin(self, DigestCommMixin)
 end
 

local origbuttons = Shade.GetTechButtons
function Shade:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[8] = kTechId.DigestComm
 return table

end


local originit = Shade.OnInitialized
function Shade:OnInitialized()
originit(self)
     //    InitMixin(self, LevelsMixin)
          -- InitMixin(self, InfestationMixin)
        --   InitMixin(self, AvocaMixin)
       -- self.salty = false
     self.lastInk = 0
     self.shouldInk = false
end
/*
function Whip:GetInfestationMaxRadius()
    return 1
end


function Whip:GetInfestationRadius()
   if not  GetIsPointOnInfestation(self:GetOrigin()) then 
    return 1
    else 
     return 0 
    end
end
*/

function Shade:GetMinRangeAC()
return ShadeAutoCCMR     
end


if Server then


function Shade:OnUpdate(deltaTime)
       if self.shouldInk and  GetIsTimeUp(self.lastInk, kShadeInkCooldown)  then
              CreateEntity(ShadeInk.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), 2) 
              self.lastInk = Shared.GetTime()
             -- self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - LookupTechData(kTechId.ShadeInk, kTechDataCostKey))
              self.shouldInk = false
       end

end

end


function Shade:OnConstructionComplete()
	 GetImaginator().activeShades = GetImaginator().activeShades + 1;  
end


 function Shade:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsBuilt() then
	    GetImaginator().activeShades  = GetImaginator().activeShades- 1;  
	  end
end



Shared.LinkClassToMap("Shade", Shade.kMapName, networkVars)