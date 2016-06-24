Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/OwnerMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/SleeperMixin.lua")

class 'Vaporizer' (ScriptActor) 
Vaporizer.kMapName = "vaporizer"

local networkVars = { }

Vaporizer.kModelName = PrecacheAsset("models/effects/proximity_force_field_noentry.model")

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)


function Vaporizer:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, CombatMixin)
    if Server then
    
        -- init after OwnerMixin since 'OnEntityChange' is expected callback
        InitMixin(self, EntityChangeMixin)
        InitMixin(self, SleeperMixin)
        
        
    end
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    self:UpdateModelStuffMaybe()
end

function Vaporizer:OnInitialized()
    ScriptActor.OnInitialized(self)
    self:SetModel(Vaporizer.kModelName)
end
function Vaporizer:UpdateModelStuffMaybe()
                self:UpdateModelCoords()
                self:UpdatePhysicsModel()
               if (self._modelCoords and self.boneCoords and self.physicsModel) then
              self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
               end  
               self:MarkPhysicsDirty()    
end
function Vaporizer:GetCanSleep()
return not self:GetIsInCombat()
end
function Vaporizer:OnAdjustModelCoords(coords)
    
        coords.xAxis = coords.xAxis * 32.22
        coords.yAxis = coords.yAxis * 14.36
        coords.zAxis = coords.zAxis * 24.14
        
    return coords
    
end

Shared.LinkClassToMap("Vaporizer", Vaporizer.kMapName, networkVars)