local networkVars = 

{   
  lastCheck = "time",
}

local origupdate = InfantryPortal.OnUpdate 

function InfantryPortal:OnUpdate(deltaTime)
  origupdate(self, deltaTime)
  
  if Server then
    if  not self:GetIsPowered() and GetIsTimeUp(self.lastCheck, 8)  then
        self:SetPowerSurgeDuration(16)
        self.lastCheck = Shared.GetTime()
    end
     
  end

end
local function SpawnPlayer(self)

    if self.queuedPlayerId ~= Entity.invalidId then
    
        local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
        local team = queuedPlayer:GetTeam()
        
        
        local rand  =  nil
        
           if GetConductor():GetIsPhaseTwo() then 
                rand = GetMAINArc():GetOrigin()
            else
                rand = GetRandomActivePower():GetOrigin() 
            end
            
          if not rand then 
         rand = self:GetAttachPointOrigin("spawn_point")
          else
          rand = FindFreeSpace(rand)
          end
        local spawnOrigin = rand  
        
        local success, player = team:ReplaceRespawnPlayer(queuedPlayer, spawnOrigin, queuedPlayer:GetAngles())
        if success then
            
            local weapon = player:GetWeapon(Rifle.kMapName)
            if weapon then
                weapon.deployed = true -- start the rifle already deployed
                weapon.skipDraw = true
            end
            
            player:SetCameraDistance(0)
            
            if HasMixin( player, "Controller" ) and HasMixin( player, "AFKMixin" ) then
                
                if player:GetAFKTime() > self:GetSpawnTime() - 1 then
                    
                    player:DisableGroundMove(0.1)
                    player:SetVelocity( Vector( GetSign( math.random() - 0.5) * 2.25, 3, GetSign( math.random() - 0.5 ) * 2.25 ) )
                    
                end
                
            end
            
            self.queuedPlayerId = Entity.invalidId
            self.queuedPlayerStartTime = nil
            
            player:ProcessRallyOrder(self)

            self:TriggerEffects("infantry_portal_spawn")            
            
            return true
            
        else
            Print("Warning: Infantry Portal failed to spawn the player")
        end
        
    end
    
    return false

end
local function StopSpinning(self)

    self:TriggerEffects("infantry_portal_stop_spin")
    self.timeSpinUpStarted = nil
    
end
    function InfantryPortal:FinishSpawn()
    
        SpawnPlayer(self)
        StopSpinning(self)
        self.timeSpinUpStarted = nil
        
    end
    

Shared.LinkClassToMap("InfantryPortal", InfantryPortal.kMapName, networkVars)