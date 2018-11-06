Script.Load("lua/GlowMixin.lua")
local networkVars = {}
AddMixinNetworkVars(GlowMixin, networkVars)
local originit = Player.OnInitialized
function Player:OnInitialized()
    originit(self)
    InitMixin(self, GlowMixin)

end


function Player:HookWithShineToBuyMist(player)

end

function Player:HookWithShineToBuyMed(player)
 
       end
function Player:HookWithShineToBuyAmmo(player)

end


Shared.LinkClassToMap("Player", Player.kMapName, networkVars)