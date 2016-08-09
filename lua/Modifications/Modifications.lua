Script.Load("lua/Modifications/ModelSize.lua")
Script.Load("lua/Modifications/Remixes.lua")
Script.Load("lua/Modifications/Criticisms.lua")
Script.Load("lua/Modifications/GameStart.lua")




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
function UpdateAvocaAvailability(forAlien, tierOneTechId, tierTwoTechId, tierThreeTechId)
        

        local team = forAlien:GetTeam()
        if team and team.GetTechTree then
        
            local hasOneHiveNow = GetGamerules():GetAllTech() or (tierOneTechId ~= nil and tierOneTechId ~= kTechId.None and GetIsTechUnlocked(forAlien, tierOneTechId))
            local oneHive = forAlien.oneHive
            -- Don't lose abilities unless you die.
            forAlien.oneHive = forAlien.oneHive or hasOneHiveNow

            if forAlien.oneHive then
                UnlockAbility(forAlien, tierOneTechId)
            else
                LockAbility(forAlien, tierOneTechId)
            end
            
            local hasTwoHivesNow = GetGamerules():GetAllTech() or (tierTwoTechId ~= nil and tierTwoTechId ~= kTechId.None and GetIsTechUnlocked(forAlien, tierTwoTechId))
            local hadTwoHives = forAlien.twoHives
            -- Don't lose abilities unless you die.
            forAlien.twoHives = forAlien.twoHives or hasTwoHivesNow

            if forAlien.twoHives then
                UnlockAbility(forAlien, tierTwoTechId)
            else
                LockAbility(forAlien, tierTwoTechId)
            end
            
            local hasThreeHivesNow = GetGamerules():GetAllTech() or (tierThreeTechId ~= nil and tierThreeTechId ~= kTechId.None and GetIsTechUnlocked(forAlien, tierThreeTechId))
            local hadThreeHives = forAlien.threeHives
            -- Don't lose abilities unless you die.
            forAlien.threeHives = forAlien.threeHives or hasThreeHivesNow

            if forAlien.threeHives then
                UnlockAbility(forAlien, tierThreeTechId)
            else
                LockAbility(forAlien, tierThreeTechId)
            end
            
        end
          return false
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



