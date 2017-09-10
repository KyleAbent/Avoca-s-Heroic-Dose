Script.Load("lua/InfestationMixin.lua")


local networkVars = 

{   
 shouldInk = "boolean",
  lastInk = "time",
}

AddMixinNetworkVars(InfestationMixin, networkVars)

local origInit = Shade.OnInitialized

function Shade:OnInitialized()
    origInit(self)
     self.lastInk = 0
     self.shouldInk = false
InitMixin(self, InfestationMixin)
end


  function Shade:GetInfestationRadius()
     return kInfestationRadius
   end
   
function Shade:GetMinRangeAC()
return 17     
end

if Server then


function Shade:OnUpdate(deltaTime)
       if self.shouldInk and  GetIsTimeUp(self.lastInk, kShadeInkCooldown)  then
              CreateEntity(ShadeInk.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), 2) 
              self.lastInk = Shared.GetTime()
              self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - LookupTechData(kTechId.ShadeInk, kTechDataCostKey))
              self.shouldInk = false
       end

end

end

Shared.LinkClassToMap("Shade", Shade.kMapName, networkVars)