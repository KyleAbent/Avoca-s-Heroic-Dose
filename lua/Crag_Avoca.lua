Script.Load("lua/InfestationMixin.lua")


local networkVars = 

{   
}

AddMixinNetworkVars(InfestationMixin, networkVars)

local originit = Crag.OnInitialized
function Crag:OnInitialized()
originit(self)
InitMixin(self, InfestationMixin)
end

  function Crag:GetInfestationRadius()
     return kInfestationRadius
   end



function Crag:GetMinRangeAC()
return 14/3 
end

Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)

