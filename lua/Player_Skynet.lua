Script.Load("lua/GlowMixin.lua")
local networkVars = {}
AddMixinNetworkVars(GlowMixin, networkVars)
local originit = Player.OnInitialized
function Player:OnInitialized()
    originit(self)
    InitMixin(self, GlowMixin)

end


Shared.LinkClassToMap("Player", Player.kMapName, networkVars)