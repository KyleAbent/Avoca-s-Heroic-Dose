Spectator.kKillCamEnabled = false
kPlayerResPerInterval = 0.5
Script.Load("lua/Modifications/ModelSize.lua")
Script.Load("lua/Modifications/Remixes.lua")
Script.Load("lua/Modifications/Criticisms.lua")
Script.Load("lua/Modifications/AvocaRules.lua")
Script.Load("lua/Modifications/CystAvoca.lua")
Script.Load("lua/Modifications/PowerPointAvoca.lua")
Script.Load("lua/Modifications/AutoBioMass.lua")
Script.Load("lua/Modifications/AvocaArc.lua")
Script.Load("lua/Modifications/MainRoomArc.lua")
Script.Load("lua/Modifications/HiveCrag.lua")
Script.Load("lua/Modifications/SentryAvoca.lua")


--Macs
Script.Load("lua/Modifications/Macs/MacAvoca.lua")
Script.Load("lua/Modifications/Macs/BaseMac.lua")
Script.Load("lua/Modifications/Macs/PlayerMac.lua")
Script.Load("lua/Modifications/Macs/BigMac.lua")
--

Script.Load("lua/Modifications/GameStart.lua")

Script.Load("lua/Modifications/AutoMacsArcs.lua")





if Server then
Script.Load("lua/Modifications/ArmoryArmor.lua")
Script.Load("lua/Modifications/LightSwitch.lua")




end


--Thanks for the trick, modular exo
local orig_Marine_OnCreate = Marine.OnCreate
function Marine:OnCreate()
    orig_Marine_OnCreate(self)
    if Client then
        GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar")  
    end
end
local orig_Alien_OnCreate = Alien.OnCreate
function Alien:OnCreate()
    orig_Alien_OnCreate(self)
    if Client then
        GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar")  
    end
end




function GhostStructureMixin:__initmixin()

    -- init the entity in ghost structure mode
    if Server then
        self.isGhostStructure = self:isa("Extractor")
    end
    
end

function Harvester:GetCanAutoBuild()

return true

end

SetCachedTechData(kTechId.Harvester, kTechDataRequiresInfestation, false)
SetCachedTechData(kTechId.Crag, kTechDataRequiresInfestation, false)
SetCachedTechData(kTechId.Whip, kTechDataRequiresInfestation, false)
SetCachedTechData(kTechId.Egg, kTechDataRequiresInfestation, false)

if Server then

function CommandStructure:GetCanBeUsedConstructed(byPlayer)
    return false
end


function CommandStructure:OnUpdateAnimationInput(modelMixin)

    PROFILE("CommandStructure:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("occupied", true)
    
end
/*
function Location:GetTrackEntity(enterEnt)
    local boolean = GetAreEnemies(self, enterEnt) and HasMixin(enterEnt, "Live") and enterEnt:GetIsAlive()
    Print("%s returned %s for gettrackentity", enterEnt:GetClassName() or nil, boolean)
    return
end
*/


function Whip:UpdateRootState()
    
    local infested = true --self:GetGameEffectMask(kGameEffect.OnInfestation)
    local moveOrdered = self:GetCurrentOrder() and self:GetCurrentOrder():GetType() == kTechId.Move
    -- unroot if we have a move order or infestation recedes
    if self.rooted and (moveOrdered or not infested) then
        self:Unroot()
    end
    
    -- root if on infestation and not moving/teleporting
    if not self.rooted and infested and not (moveOrdered or self:GetIsTeleporting()) then
        self:Root()
    end
    
end
/*
local function InstaRespawn(who, where)
CreateEntity(who, where, 1)
end
local function GetIsMarineBase(where)
            local cc =  GetNearest(where, "CommandStation", 1)
               if cc then
               
               local origin = self:GetOrigin()
               local location = GetLocationForPoint(origin)
               local name = location.name
               
               local ccorigin = cc:GetOrigin()
               local cclocation = GetLocationForPoint(ccorigin)
               local ccname = cclocation.name
               
               local boolean = name == ccname
               return boolean
            end
            return false
end

 function ConstructMixin:PreOnKill(attacker, doer, point, direction)
      if self:GetTeamNumber() == 1 then
        if not self:isa("PowerPoint") and not self:isa("CommandStation") and not self:isa("Extractor") and not self:isa("ARC") then
           local origin = self:GetOrigin()
         if GetIsMarineBase(origin) then
           InstaRespawn(self:GetMapName(), origin)
            end
       end
       end
    end
*/

local function GetDestinationGate(self)
    local phaseGates = {} 
    
    for index, payload  in ipairs( GetEntitiesForTeam("AvocaArc", self:GetTeamNumber()) ) do
        if GetIsUnitActive(payload) then
            table.insert(phaseGates, payload)
        end
    end    
    
  -- Find next phase gate to teleport to
   
    for index, phaseGate in ipairs( GetEntitiesForTeam("PhaseGate", self:GetTeamNumber()) ) do
        if GetIsUnitActive(phaseGate) then
            table.insert(phaseGates, phaseGate)
        end
    end    
    
    if table.count(phaseGates) < 2 then
        return nil
    end
    
    -- Find our index and add 1
    local index = table.find(phaseGates, self)
    if (index ~= nil) then
    
        local nextIndex = ConditionalValue(index == table.count(phaseGates), 1, index + 1)
        ASSERT(nextIndex >= 1)
        ASSERT(nextIndex <= table.count(phaseGates))
        return phaseGates[nextIndex]
        
    end
    
    return nil
    

    
end

--So that we can teleport to the payload without having to run to it all the time :P
local function ComputeDestinationLocationId(self, destGate)

    local destLocationId = Entity.invalidId
    if destGate then
    
        local location = GetLocationForPoint(destGate:GetOrigin())
        if location then
            destLocationId = location:GetId()
        end
        
    end
    
    return destLocationId
    
end
    function PhaseGate:Update()

        self.phase = (self.timeOfLastPhase ~= nil) and (Shared.GetTime() < (self.timeOfLastPhase + 0.3))

        local destinationPhaseGate = GetDestinationGate(self)
        if destinationPhaseGate ~= nil and GetIsUnitActive(self) and self.deployed and (destinationPhaseGate.deployed or destinationPhaseGate:isa("ARC") ) then        
        
            self.destinationEndpoint = destinationPhaseGate:GetOrigin()
            self.linked = true
            self.targetYaw = destinationPhaseGate:GetAngles().yaw
            self.destLocationId = ComputeDestinationLocationId(self, destinationPhaseGate)
            
        else
            self.linked = false
            self.targetYaw = 0
            self.destLocationId = Entity.invalidId
        end

        return true
        
    end




--low grav with catpack for the lulz

function Marine:ModifyGravityForce(gravityTable)
      if self:GetIsOnGround() then
            gravityTable.gravity = 0
      elseif self:GetHasCatpackBoost() then
            gravityTable.gravity = -5
       end
end


--Thanks for the trick, modular exo




local orig_Hive_OnTakeDamage = Hive.OnTakeDamage
function Hive:OnTakeDamage(damage, attacker, doer, point)

if attacker and attacker:isa("AvocaArc") then AddPayLoadTime(4) end
return orig_Hive_OnTakeDamage(self,damage, attacker, doer, point)
end
----
local orig_Hive_OnKill = Hive.OnKill
function Hive:OnKill(attacker, doer, point, direction)
AddPayLoadTime(360)
 return orig_Hive_OnKill(self,attacker, doer, point, direction)
end

end--server
