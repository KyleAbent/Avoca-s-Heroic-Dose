--Kyle 'Avoca' Abent

local kNanoshieldMaterial = PrecacheAsset("cinematics/vfx_materials/nanoshield.material")


local function SoTheGameCanEnd(self, who) --Although HiveDefense prolongs it
   local arc = GetEntitiesWithinRange("ARC", who:GetOrigin(), ARC.kFireRange)
   if #arc >= 1 then CreateEntity(Scan.kMapName, who:GetOrigin(), 1) end
end
local function CheckHivesForScan()
local hives = {}
           for _, hiveent in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             table.insert(hives, hiveent)
          end
          if #hives == 0 then return end
          --Scan hive if arc in range, only 1 check per hive.. not per arc.. or whatever. 
          for i = 1, #hives do
             local ent = hives[i]
             SoTheGameCanEnd(self, ent)
          end
end
local function MoveToHives(who)

local hives = {}

           for _, hiveent in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             table.insert(hives, hiveent)
          end
         
        local hive = table.random(hives)
        local origin = FindArcSpace(hive:GetOrigin())
        who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
             
end

local function CheckForAndActAccordingly(who)
local stopanddeploy = false
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, who:GetOrigin(), kARCRange)) do
             if who:GetCanFireAtTargetActual(enemy, enemy:GetOrigin()) then
             stopanddeploy = true
             break
             end
          end
        --Print("stopanddeploy is %s", stopanddeploy)
       return stopanddeploy
end

local function GiveDeploy(who)
    Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
end
local function GiveUnDeploy(who)
     Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end
local function ShouldStop(who)

local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 4)
if #players >=1 then return false end
return true
end
function ARC:SpecificRules()
--local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) --or CheckForAndActAccordingly(self)  
Print("SpecificRules")

local moving = self.mode == ARC.kMode.Moving     
Print("moving is %s", moving) 
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
Print("attacking is %s", moving) 
local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) or CheckForAndActAccordingly(self)  
Print("inradius is %s", inradius) 

local shouldstop = ShouldStop(self)
Print("shouldstop is %s", shouldstop) 
local shouldmove = not moving and not inradius
Print("shouldmove is %s", shouldmove) 
local shouldstop = moving and ShouldStop(self)
Print("shouldstop is %s", shouldstop) 
local shouldattack = inradius and not attacking 
Print("shouldattack is %s", shouldattack) 
local shouldundeploy = attacking and not inradius and not moving
Print("shouldundeploy is %s", shouldundeploy) 

    if shouldstop or (moving and shouldattack) then 
     Print("StopOrder")
     self:ClearOrders()
     self:SetMode(ARC.kMode.Stationary)
    elseif shouldmove and not shouldattack  then
        if shouldundeploy then
         Print("ShouldUndeploy")
         GiveUnDeploy(self)
       else
       Print("GiveMove")
       MoveToHives(self)
       end
   elseif shouldattack then
     Print("ShouldAttack")
     GiveDeploy(self)
    return true
    end
    
end
function ARC:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
      if  not self:GetInAttackMode() then
    unitName = string.format(Locale.ResolveString("PAYLOAD") )
    else
    unitName = string.format(Locale.ResolveString("AvocaArc") )
    end
return unitName
end  
function ARC:ModifyDamageTaken(damageTable, attacker, doer, damageType)
local damage = self:GetInAttackMode() and 0.7 or 0 
        damageTable.damage = damageTable.damage * damage
end

if Client then

    function ARC:OnUpdateRender()
          local showMaterial = not self:GetInAttackMode()
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kNanoshieldMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client

function ARC:BeginTimer()
           self:AddTimedCallback(ARC.Instruct, 4)
end


function ARC:Instruct()
   CheckHivesForScan()
   self:SpecificRules()
   return true
end