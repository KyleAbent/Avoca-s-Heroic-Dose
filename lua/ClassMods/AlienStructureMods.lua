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
if Server then

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
end
function Whip:OnKill(attacker, doer, point, direction)
 --if attacker and attacker:isa("ARC") then AddPayLoadTime(1) end
end

function Harvester:GetCanAutoBuild()

return true

end

function Hive:GetTechButtons()

    local techButtons = { kTechId.ShiftHatch, kTechId.None, kTechId.None, kTechId.LifeFormMenu,
                          kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    
    if self.bioMassLevel <= 1 then
        techButtons[2] = kTechId.ResearchBioMassOne
    elseif self.bioMassLevel == 2 then
        techButtons[2] = kTechId.ResearchBioMassTwo 
    elseif self.bioMassLevel == 3 then
        techButtons[2] = kTechId.ResearchBioMassThree 
    elseif self.bioMassLevel == 4 then
        techButtons[2] = kTechId.ResearchBioMassFour
    end
    
    return techButtons
    
end

if Server then



local function LocationsMatch(who,whom)
   
  local whoname = GetLocationForPoint(who:GetOrigin())
  local whomname = GetLocationForPoint(whom:GetOrigin())
  return true --whoname == whomname
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
        if self:GetIsBuilt() then  AddPayLoadTime(10)  end
    end
    
return orig_Hive_OnTakeDamage(self,damage, attacker, doer, point)
end



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

local function GetTechPoint(where)
    for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", where, 8)) do
         if techpoint then return techpoint end
    end
end
local function DestroyAvocaArcInRadius(where)
    for _, avocaarc in ipairs(GetEntitiesWithinRange("AvocaArc", where, kARCRange)) do
         if avocaarc then avocaarc:Kill() end
    end
end
local orig_Hive_OnKill = Hive.OnKill
function Hive:OnKill(attacker, doer, point, direction)
if self:GetIsBuilt() then AddPayLoadTime(8) end
local child = GetTechPoint(self:GetOrigin())
BuildRoomPower(child)
DestroyAvocaArcInRadius(self:GetOrigin())
child:SetIsVisible(false)
 return orig_Hive_OnKill(self,attacker, doer, point, direction)
end




    local orig_NutrientMist_Perform = NutrientMist.Perform
function NutrientMist:Perform()
 orig_NutrientMist_Perform(self)
 
     local entities = GetEntitiesWithMixinForTeamWithinRange("Webable", 1, self:GetOrigin(), NutrientMist.kSearchRange)
    
    for index, entity in ipairs(entities) do
        
        entity:SetWebbed(8)
        
    end
end 





end