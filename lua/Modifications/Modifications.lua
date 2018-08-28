Script.Load("lua/Modifications/ModelSize.lua")
Script.Load("lua/Modifications/Remixes.lua")
Script.Load("lua/Modifications/Criticisms.lua")
Script.Load("lua/Modifications/GameStart.lua")


function BotTeamController:RemoveBot(teamIndex)
   return --/ OnConsoleRemoveBots(nil, 1, teamIndex)
end

/*
kMarineHealth = 200
kJetpackHealth = 200


kSkulkGestateTime = 1
kGorgeGestateTime = 1
kLerkGestateTime = 1
kFadeGestateTime = 1
kOnosGestateTime = 1
*/

/*

if Server then


local origkill = LiveMixin.Kill
function LiveMixin:Kill(attacker, doer, point, direction)
  if self:GetIsAlive() and self:GetCanDie() then
          ---Rebirth
          
         if self:isa("Alien") then
         
           Print("Alien On Kill")
          if GetConductor():GetIsPhaseOneBoolean() and math.random(1,3) == 3  then
             Print("Alien On Kill Phase One 30% chance")
            if self:isa("Skulk") and math.random(1,3) == 3 then
             Print("Alien On Kill Phase One SKulk Trigger Xeno")
              self:TriggerXenocide()
            end
             
          
                    if attacker and attacker:isa("Player")  then 
                      local points = self:GetPointValue()
                       attacker:AddScore(points)
                     end 
                       Print("Alien On Kill Rebirth")
                self:TriggerRebirth()
                return
                end
              
             

             
         end
            
            --Hunger
            /*
      if self:GetTeamNumber() == 1 then 
         if self:isa("Player")  then
              if attacker and attacker:isa("Alien") and attacker:isa("Player") and GetHasHungerUpgrade(attacker) then
                  local duration = 6
                     if attacker:isa("Onos") then
                       duration = duration * .7
                       end
                    attacker:TriggerEnzyme(duration)

          attacker:AddEnergy(attacker:GetMaxEnergy() * .10 )
          attacker:AddHealth(attacker:GetHealth() * (10/100))
        end
      elseif ( HasMixin(self, "Construct") or self:isa("ARC") or self:isa("MAC") ) and attacker and attacker:isa("Player") then 
              if GetHasHungerUpgrade(attacker) and attacker:isa("Gorge") and doer:isa("DotMarker") then 
                        attacker:TriggerEnzyme(5)
                        attacker:AddEnergy(attacker:GetMaxEnergy() * .10)
               end
          end
     end 
     */
            
    /*
        
   end     
return origkill(self, attacker, doer, point, direction)
end

end

*/




if Server then


local function UnlockAbility(forAlien, techId)
    local mapName = LookupTechData(techId, kTechDataMapName)
    if mapName and forAlien:GetIsAlive() then
    
        local activeWeapon = forAlien:GetActiveWeapon()
        local tierWeapon = forAlien:GetWeapon(mapName)
        if not tierWeapon then
        
            forAlien:GiveItem(mapName)
            
            if activeWeapon then
                forAlien:SetActiveWeapon(activeWeapon:GetMapName())
            end
            
        end
    
    end
end
local function LockAbility(forAlien, techId)
    local mapName = LookupTechData(techId, kTechDataMapName)    
    if mapName and forAlien:GetIsAlive() then
    
        local tierWeapon = forAlien:GetWeapon(mapName)
        local activeWeapon = forAlien:GetActiveWeapon()
        local activeWeaponMapName = nil
        
        if activeWeapon ~= nil then
            activeWeaponMapName = activeWeapon:GetMapName()
        end
        
        if tierWeapon then
            forAlien:RemoveWeapon(tierWeapon)
        end
        
        if activeWeaponMapName == mapName then
            forAlien:SwitchWeapon(1)
        end
        
    end    
    
end

/*
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

*/


    

function LeapMixin:GetHasSecondary(player)
    return GetHasTech(player, kTechId.Leap)
end
function StompMixin:GetHasSecondary(player)
    return  GetHasTech(player, kTechId.Stomp)
end


/*
function Shade:OnScan()
local chance = math.random(1,100) 
 if chance <= 30  and self.lastink == nil or Shared.GetTime() > (self.lastink + kShadeInkCooldown) then
   self:TriggerInk()
   self.lastink = Shared.GetTime()
   end
end
  */  
end--server


if Server then
	
	local function RewardAchievement(player, name)

	end
	
	function AchievementReceiverMixin:CheckWeldedPowerNodes()

	end

	function AchievementReceiverMixin:CheckWeldedPlayers()

	end

	function AchievementReceiverMixin:CheckBuildResTowers()

	end

	function AchievementReceiverMixin:CheckKilledResTowers()

	end

	function AchievementReceiverMixin:CheckDefendedResTowers()

	end

	function AchievementReceiverMixin:CheckFollowedOrders()

	end

	function AchievementReceiverMixin:CheckParasitedPlayers()

	end

	function AchievementReceiverMixin:CheckStructureDamageDealt()

	end

	function AchievementReceiverMixin:CheckPlayerDamageDealt()

	end

	function AchievementReceiverMixin:CheckDestroyedRessources()

	end

	function AchievementReceiverMixin:OnPhaseGateEntry()
		
	end

	function AchievementReceiverMixin:OnUseGorgeTunnel()

	end

	function AchievementReceiverMixin:AddWeldedPowerNodes()

	end

	function AchievementReceiverMixin:AddWeldedPlayers()

	end

	function AchievementReceiverMixin:AddBuildResTowers()

	end

	function AchievementReceiverMixin:AddKilledResTowers()

	end

	function AchievementReceiverMixin:AddDefendedResTowers()

	end

	function AchievementReceiverMixin:AddParsitedPlayers()
	end

	function AchievementReceiverMixin:AddStructureDamageDealt(amount)
	end

	function AchievementReceiverMixin:AddPlayerDamageDealt(amount)
	end

	function AchievementReceiverMixin:AddDestroyedRessources(amount)
	end

	function AchievementReceiverMixin:CompletedCurrentOrder()
	end

	function AchievementReceiverMixin:ResetScores()

	end

	function AchievementReceiverMixin:CopyPlayerDataFrom(player)
	end

end

if Client then

	function AchievementReceiverMixin:GetMaxPlayer()
	end

	function AchievementReceiverMixin:OnUpdatePlayer(deltaTime)
    end
end

if Server then

	function AchievementGiverMixin:PreUpdateMove(input, runningPrediction)

	end

	function AchievementGiverMixin:OnTaunt()

	end

	function AchievementGiverMixin:OnAddHealth()

	end

	function AchievementGiverMixin:OnCommanderStructureLogout(hive)
	
	end

	function AchievementGiverMixin:SetGestationData(techIds, previousTechId, healthScalar, armorScalar)

	end

	function AchievementGiverMixin:SetParasited(fromPlayer)

	end

	function AchievementGiverMixin:OnWeldTarget(target)

	end

	function AchievementGiverMixin:OnConstruct(builder, newFraction, oldFraction)

	end

	function AchievementGiverMixin:OnConstructionComplete(builder)

	end

	function AchievementGiverMixin:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)

	end

	function AchievementGiverMixin:PreOnKill(attacker, doer, point, direction)
     end
end


