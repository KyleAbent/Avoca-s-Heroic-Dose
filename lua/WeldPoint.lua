Script.Load("lua/LiveMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/WeldableMixin.lua")
//Script.Load("lua/PowerConsumerMixin.lua") ??
//Script.Load("lua/MapBlipMixin.lua") ??
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/WeldableMixin.lua")
class 'WeldPoint' (ScriptActor)

local networkVars =
{
    flipped = "boolean",
}


WeldPoint.kMapName = "weldpoint"
WeldPoint.kModelName = PrecacheAsset("models/props/refinery/mining_wallmods_01_powerbox.model")

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function WeldPoint:OnCreate()

    ScriptActor.OnCreate(self)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    self.flipped = false

      //self.teamNumber = 2 //if I want a breakable
      self.teamNumber = 1
end

function WeldPoint:OnInitialized()

    ScriptActor.OnInitialized(self)
    InitMixin(self, WeldableMixin)
    //Not in techData
    self:AdjustMaxArmor(420)
    self:SetArmor(0)
    self:SetModel(WeldPoint.kModelName)
        if Client then
        InitMixin(self, UnitStatusMixin)
        end
   
    
end
function WeldPoint:GetIsMapEntity()
    return true
end
function WeldPoint:GetHealthbarOffset()
    return gArmoryHealthHeight
end

function WeldPoint:OnHealed()
  Print(self:GetHealthScalar())
 if self:GetHealthScalar() >= 0.98 and not self.flipped then
   self.flipped = true
    Print("100% Scalar broseph dawgity dawg")
  //if Server then
  //local blockade = nil
          //  blockade = GetNearest(self:GetOrigin() + Vector(0, 100, 0) , "weldComplete_Door_toOrigin", 0 )
              //   if blockade  then 
                  // Print("blockade found")
                    // blockade:SetOrigin(blockade:GetOrigin() - Vector(0, 100, 0) ) //digging holes
              //  end
            //frontdoor = frontdoor or GetIsRoomPowerUp(who) -- if it doesnt cause problems with maps. Power shouldn't be up alien side.
    //end
      //  Print("BRO")

end
//   ScriptActor.OnWeld(self, doer, elapsedTime, player)
end

Shared.LinkClassToMap("WeldPoint", WeldPoint.kMapName, networkVars)