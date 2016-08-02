Script.Load("lua/Modifications/ModelSize.lua")
Script.Load("lua/Modifications/Remixes.lua")
Script.Load("lua/Modifications/Criticisms.lua")
Script.Load("lua/Modifications/AvocaRules.lua")
Script.Load("lua/Modifications/CystAvoca.lua")
Script.Load("lua/Modifications/AvocaArc.lua")
Script.Load("lua/Modifications/MainRoomArc.lua")
Script.Load("lua/Modifications/HiveCrag.lua")
Script.Load("lua/Modifications/SentryAvoca.lua")
Script.Load("lua/Modifications/BaseSentry.lua")
Script.Load("lua/Modifications/BigArc.lua")

--Macs
Script.Load("lua/Modifications/Macs/BaseMac.lua")
Script.Load("lua/Modifications/Macs/BigMac.lua")
--

Script.Load("lua/Modifications/GameStart.lua")

Script.Load("lua/Modifications/AutoMacsArcs.lua")


Script.Load("lua/Modifications/DrifterAvoca.lua")
Script.Load("lua/Modifications/WhipAvoca.lua") 

Script.Load("lua/Modifications/PhaseAvoca.lua") 


if Server then
Script.Load("lua/Modifications/ArmoryArmor.lua")





end




--Thanks for the trick, modular exo



local orig_Whip_OnInit = Whip.OnInitialized
function Whip:OnInitialized()
    orig_Whip_OnInit(self)
  
       if Server then
        local targetTypes = { kAlienStaticTargets, kAlienMobileTargets }, { self.FilterTarget(self) }
        self.slapTargetSelector = TargetSelector():Init(self, Whip.kRange, true, targetTypes)
        self.bombardTargetSelector = TargetSelector():Init(self, Whip.kBombardRange, true, targetTypes)
        end
end

function Whip:FilterTarget()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end
function Whip:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("AvocaArc") and not target:GetInAttackMode() then
    return false
    end
    
    return true
    
end

local orig_Marine_OnCreate = Marine.OnCreate
function Marine:OnCreate()
    orig_Marine_OnCreate(self)
    if Client then
        GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar")  
    end
end
local orig_NS2Gamerules_OnCreate = NS2Gamerules.OnCreate
function NS2Gamerules:OnCreate()
    orig_NS2Gamerules_OnCreate(self)

end

local orig_Alien_OnCreate = Alien.OnCreate
function Alien:OnCreate()
    orig_Alien_OnCreate(self)
    if Client then
        GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar")  
    end
end

function Hive:GetBioMassLevel()
    return self.bioMassLevel
end

function Hive:OnConstructionComplete()
--biomass 0
    -- Play special tech point animation at same time so it appears that we bash through it.
    local attachedTechPoint = self:GetAttached()
    if attachedTechPoint then
        attachedTechPoint:SetIsSmashed(true)
    else
        Print("Hive not attached to tech point")
    end
    
    local team = self:GetTeam()
    
    if team then
        team:OnHiveConstructed(self)
    end
    
    if self.hiveType == 1 then
        self:OnResearchComplete(kTechId.UpgradeToCragHive)
    elseif self.hiveType == 2 then
        self:OnResearchComplete(kTechId.UpgradeToShadeHive)
    elseif self.hiveType == 3 then
        self:OnResearchComplete(kTechId.UpgradeToShiftHive)
    end

    local cysts = GetEntitiesForTeamWithinRange( "Cyst", self:GetTeamNumber(), self:GetOrigin(), self:GetCystParentRange())
    for _, cyst in ipairs(cysts) do
        cyst:ChangeParent(self)
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
SetCachedTechData(kTechId.Shift, kTechDataRequiresInfestation, false)
SetCachedTechData(kTechId.Shade, kTechDataRequiresInfestation, false)
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





--low grav with catpack for the lulz

function Marine:ModifyGravityForce(gravityTable)
      if self:GetIsOnGround() then
            gravityTable.gravity = 0
      elseif self:GetHasCatpackBoost() then
            gravityTable.gravity = -5
       end
end


--Thanks for the trick, modular exo
/*
local orig_GameInfo_SetStartTime = GameInfo.SetStartTime
function GameInfo:SetStartTime(startTime)
    orig_GameInfo_SetStartTime(self)
        local entityList = Shared.GetEntitiesWithClassname("Conductor")
    if entityList:GetSize() == 0 then
     local Conductor = CreateEntity(Conductor.kMapName)
     end
end
*/
local function LocationsMatch(who,whom)
   
  local whoname = GetLocationForPoint(who:GetOrigin())
  local whomname = GetLocationForPoint(whom:GetOrigin())
  return true --whoname == whomname
end
local orig_PowerPoint_OnConstructionComplete = PowerPoint.OnConstructionComplete
    function PowerPoint:OnConstructionComplete()
        orig_PowerPoint_OnConstructionComplete(self)
       local nearestHarvester = GetNearest(self:GetOrigin(), "Harvester", 2, function(ent) return LocationsMatch(self,ent)  end)
       if nearestHarvester then
         nearestHarvester:Kill()
       end
end
local orig_PowerPoint_OnKill = PowerPoint.OnKill
    function PowerPoint:OnKill(attacker, doer, point, direction)
    orig_PowerPoint_OnKill(self)
       local nearestExtractor = GetNearest(self:GetOrigin(), "Extractor", 1, function(ent) return LocationsMatch(self,ent)  end)
       if nearestExtractor then
         nearestExtractor:Kill()
       end
        local location = GetLocationForPoint(self:GetOrigin())
        location = location and location.name 
       if Client then location:HideDank() end
       
    end
local function ToSpawnFormula(self,panicstospawn, where)
         for i = 1, panicstospawn do
                           local bitch = GetPayLoadArc()
                           if bitch and GetIsPointWithinHiveRadius(bitch:GetOrigin()) then
                           local spawnpoint = FindFreeSpace(bitch:GetOrigin(), 4, 8)
                              if spawnpoint then
                              local panicattack = CreateEntity(PanicAttack.kMapName, spawnpoint, 2)
                               panicattack:SetConstructionComplete()
                               panicattack:SetMature()
                               end
                           end
               end
            
end
local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end
local function SendAnxietyAttack(self, where, who)
         for i = 1, #who do
                           local panicattack = who[i]
                           local bitch = GetPayLoadArc()
                           if bitch and GetIsPointWithinHiveRadius(bitch:GetOrigin()) and GetRange(panicattack,bitch:GetOrigin()) >= 16 then                  
                           local spawnpoint = FindFreeSpace(bitch:GetOrigin(), 4, 8)
                              if spawnpoint then
                                    panicattack:SetOrigin(spawnpoint)
                               end
                           end
               end
end
local function PanicInitiate(self,where)
local panicattacks = {}

        for _, panicattack in ipairs(GetEntitiesWithinRange("PanicAttack", where, 9999)) do
                if panicattack:GetIsAlive() then
                       table.insert(panicattacks,panicattack) 
               end
       end
       
  local countofpanic = Clamp(table.count(panicattacks), 0, 8)
  local maxpanic = 4
  local panicstospawn = math.abs(maxpanic - countofpanic)
        panicstospawn = Clamp(panicstospawn, 1, 2)

            if panicstospawn >= 1 then ToSpawnFormula(self,panicstospawn, where) end
            
            if countofpanic >= 1 then
                SendAnxietyAttack(self, where, panicattacks) -- not sure
            end
            
end

local orig_Hive_OnTakeDamage = Hive.OnTakeDamage
function Hive:OnTakeDamage(damage, attacker, doer, point)

   if doer and doer:isa("ARC") then 
         Print("PanicAttack Initiated")
         PanicInitiate(self,self:GetOrigin())
        if self:GetIsBuilt() then  AddPayLoadTime(8)  end
    end
    
return orig_Hive_OnTakeDamage(self,damage, attacker, doer, point)
end
----

local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

local function BuildRoomPower(who)

     local nearestPower = GetNearest(who:GetOrigin(), "PowerPoint", 1, function(ent) return LocationsMatch(who,ent)  end)
       if nearestPower and nearestPower:GetIsDisabled() then
            local cheaptrick = CreateEntity(PowerPoint.kMapName, nearestPower:GetOrigin(), 1)
            cheaptrick:SetConstructionComplete()
                DestroyEntity(nearestPower) 
       end
       
       
     who:AddTimedCallback(function() 
     local bigarc = CreateEntity(BigArc.kMapName, who:GetOrigin(), 1)
     bigarc:GiveDeploy()
     end, 8)
     
end

function SentryBattery:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("BackupPower") )
return unitName
end  
local function GetTechPoint(where)
    for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", where, 8)) do
         if techpoint then return techpoint end
    end
end
local orig_Hive_OnKill = Hive.OnKill
function Hive:OnKill(attacker, doer, point, direction)
if self:GetIsBuilt() then AddPayLoadTime(180) end
local child = GetTechPoint(self:GetOrigin())
BuildRoomPower(child)
child:SetIsVisible(false)
 return orig_Hive_OnKill(self,attacker, doer, point, direction)
end
function Whip:OnKill(attacker, doer, point, direction)
 --if attacker and attacker:isa("ARC") then AddPayLoadTime(1) end
end



/*
function InfantryPortal:GetRequiresPower()
return true --why have this off if this is pretty much only way marines can lose with bots
end
function ArmsLab:GetRequiresPower()
return false
end
*/
function InfantryPortal:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil then
    
        damageTable.damage = 0 --I already know whips and hydras are still gonna try to attack. Gotta filter that elsewhere.
        
    end

end
function ArmsLab:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil then
    
        damageTable.damage = 0 --I already know whips and hydras are still gonna try to attack. Gotta filter that elsewhere.
        
    end

end
-- Find team start with team 0 or for specified team. Remove it from the list so other teams don't start there. Return nil if there are none.
function NS2Gamerules:ChooseTechPoint(techPoints, teamNumber)

    local validTechPoints = { }
    local totalTechPointWeight = 0
    
    -- Build list of valid starts (marked as "neutral" or for this team in map)
    for _, currentTechPoint in pairs(techPoints) do
    
        -- Always include tech points with team 0 and never include team 3 into random selection process
       -- local teamNum = currentTechPoint:GetTeamNumberAllowed()
       -- if (teamNum == 0 or teamNum == teamNumber) and teamNum ~= 3 then
        
            table.insert(validTechPoints, currentTechPoint)
            totalTechPointWeight = totalTechPointWeight + currentTechPoint:GetChooseWeight()
            
      --  end
        
    end
    
    local chosenTechPointWeight = self.techPointRandomizer:random(0, totalTechPointWeight)
    local chosenTechPoint = nil
    local currentWeight = 0
    for _, currentTechPoint in pairs(validTechPoints) do
    
        currentWeight = currentWeight + currentTechPoint:GetChooseWeight()
        if chosenTechPointWeight - currentWeight <= 0 then
        
            chosenTechPoint = currentTechPoint
            break
            
        end
        
    end
    
    -- Remove it from the list so it isn't chosen by other team
    if chosenTechPoint ~= nil then
        table.removevalue(techPoints, chosenTechPoint)
    else
        assert(false, "ChooseTechPoint couldn't find a tech point for team " .. teamNumber)
    end
    
    return chosenTechPoint
    
end
function Exo:PerformEjectOnPree()
    
        if self:GetIsAlive() then
       
            local reuseWeapons = self.storedWeaponsIds ~= nil
        
            local marine = self:Replace(self.prevPlayerMapName or Marine.kMapName, self:GetTeamNumber(), false, self:GetOrigin() + Vector(0, 0.2, 0))
            local health = Clamp(self.prevPlayerHealth or kMarineHealth-30, 1, 70)
            marine:SetHealth(health)
            marine:SetMaxArmor(self.prevPlayerMaxArmor or kMarineArmor)
            marine:SetArmor(self.prevPlayerArmor or kMarineArmor)
            
            --exosuit:SetOwner(marine)
            
            marine.onGround = false
            local initialVelocity = self:GetViewCoords().zAxis
            initialVelocity:Scale(4)
            initialVelocity.y = 9
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
                marine:SetFuel(0)
            end
        
        end
    
        return false
    
end
function Exo:PreOnKill(attacker, doer, point, direction)
          self:PerformEjectOnPree()
end
local function GetDestinationGate(self)
    local phaseGates = {} 
  -- Find next phase gate to teleport to
  
  if self:isa("PhaseAvoca") then  
  
    for index, payload  in ipairs( GetEntitiesForTeam("AvocaArc", self:GetTeamNumber()) ) do
        if GetIsUnitActive(payload) then
            return payload
        end
    end 
    
   end
   
    for index, phaseGate in ipairs( GetEntitiesForTeam("PhaseGate", self:GetTeamNumber()) ) do
        if GetIsUnitActive(phaseGate) and not phaseGate:isa("PhaseAvoca") then
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
function InfantryPortal:OhNoYouDidnt()

     for _, powerconsumer in ipairs(GetEntitiesWithMixinForTeamWithinRange("PowerConsumer", 1, self:GetOrigin(), 24)) do
          if powerconsumer ~= self and (powerconsumer:GetRequiresPower() and not powerconsumer:GetIsPowered()) then
          powerconsumer:SetPowerSurgeDuration(16)
          powerconsumer:TriggerEffects("arc_hit_secondary")
          end
     end
     
     self:TriggerEffects("arc_hit_primary")
     
 return not self:GetIsPowered()
 
end

    local orig_InfantryPortal_OnPowerOff = InfantryPortal.OnPowerOff
function InfantryPortal:OnPowerOff()
 orig_InfantryPortal_OnPowerOff(self)
   self:AddTimedCallback(InfantryPortal.OhNoYouDidnt, 8)
end
    
    
end--server



if Client then
/*
local orig_ActionFinder_OnProcessMove = MarineActionFinderMixin.OnProcessMove
    function MarineActionFinderMixin:OnProcessMove(input )
    orig_ActionFinder_OnProcessMove(self)
    end
 */
function MarineActionFinderMixin:OnProcessMove(input)
    return
end

end