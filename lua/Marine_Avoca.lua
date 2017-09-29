 --Thanks for the trick, modular exo
local orig_Marine_GetMaxSpeed = Marine.GetMaxSpeed
function Marine:GetMaxSpeed(possible)
 local original = orig_Marine_GetMaxSpeed(self)
 local moveSpeed = (self:GetGameEffectMask(kGameEffect.OnInfestation) ) and original * 0.65 or original
 
 return moveSpeed



end 

local orig_Marine_OnCreate = Marine.OnCreate
function Marine:OnCreate()
    orig_Marine_OnCreate(self)
end

/*
local orig_Marine_InitWeapons = Marine.InitWeapons
function Marine:InitWeapons()
    orig_Marine_InitWeapons(self)
    self:GiveItem(Welder.kMapName)
    self:SetQuickSwitchTarget(Pistol.kMapName)
    self:SetActiveWeapon(Rifle.kMapName)
end
*/

function Marine:ModifyGravityForce(gravityTable)
      if self:GetIsOnGround() then
            gravityTable.gravity = 0
      elseif self:GetHasCatpackBoost() then
            --self:AddArmor(1)
            gravityTable.gravity = -5
       end
end

function Marine:GetCanBotPhase()
    if Server then
        return self:GetIsAlive() and Shared.GetTime() > self.timeOfLastPhase + (2*3) and not GetConcedeSequenceActive()
    else
        return self:GetIsAlive() and Shared.GetTime() > self.timeOfLastPhase + (2*3)
    end
    
end

function Marine:GetHasLayStructure()
        local weapon = self:GetWeaponInHUDSlot(5)
        local builder = false
    if (weapon) then
            builder = true
    end
    
    return builder
end

function Marine:GiveLayStructure(techid, mapname)
  --  if not self:GetHasLayStructure() then
           local laystructure = self:GiveItem(LayStructures.kMapName)
           self:SetActiveWeapon(LayStructures.kMapName)
           laystructure:SetTechId(techid)
           laystructure:SetMapName(mapname)
  -- else
   --  self:TellMarine(self)
  -- end
end


function Marine:GetWeaponsToStore()
local toReturn = {}
            local weapons = self:GetWeapons()
            
          if weapons then
          
            for i = 1, #weapons do            
                weapons[i]:SetParent(nil)     
                local weapon
                table.insert(toReturn, weapons[i]:GetId())       
            end
            
           end
           
           return toReturn
end
function Marine:GiveExo(spawnPoint)
    local random = math.random(1,2)
    if random == 1 then 
        local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "MinigunMinigun", storedWeaponsIds = self:GetWeaponsToStore()  })
    return exo
    else
        local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "RailgunRailgun", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    end

    
end

function Marine:GiveDualExo(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "MinigunMinigun", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    
end
function Marine:GiveDualFlamer(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "FlamerFlamer", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    
end
function Marine:GiveClawRailgunExo(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "ClawRailgun", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    
end

function Marine:GiveDualRailgunExo(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "RailgunRailgun", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    
end
kIsExoTechId = { [kTechId.DualFlamerExosuit] = true, [kTechId.DualMinigunExosuit] = true,
                 [kTechId.DualRailgunExosuit] = true }
                 
local function BuyExo(self, techId)

    local maxAttempts = 100
    for index = 1, maxAttempts do
    
        -- Find open area nearby to place the big guy.
        local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
        local extents = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents)

        local spawnPoint        
        local checkPoint = self:GetOrigin() + Vector(0, 0.02, 0)
        
        if GetHasRoomForCapsule(extents, checkPoint + Vector(0, extents.y, 0), CollisionRep.Move, PhysicsMask.Evolve, self) then
            spawnPoint = checkPoint
        else
            spawnPoint = GetRandomSpawnForCapsule(extents.y, extents.x, checkPoint, 0.5, 5, EntityFilterOne(self))
        end    
            
        local weapons 

        if spawnPoint then
        
            self:AddResources(-GetCostForTech(techId))
            
            local exo = nil
            
            if techId == kTechId.DualFlamerExosuit then
                exo = self:GiveDualFlamer(spawnPoint)
            elseif techId == kTechId.DualMinigunExosuit then
                exo = self:GiveDualExo(spawnPoint)
            elseif techId == kTechId.DualWelderExosuit then
                exo = self:GiveDualWelder(spawnPoint)
            elseif techId == kTechId.DualRailgunExosuit then
                exo = self:GiveDualRailgunExo(spawnPoint)
            end
            

            
            exo:TriggerEffects("spawn_exo")
            
            return
            
        end
        
    end
    
    Print("Error: Could not find a spawn point to place the Exo")
    
end
local function GetHostSupportsTechId(forPlayer, host, techId)

    if Shared.GetCheatsEnabled() then
        return true
    end
    
    local techFound = false
    
    if host.GetItemList then
    
        for index, supportedTechId in ipairs(host:GetItemList(forPlayer)) do
        
            if supportedTechId == techId then
            
                techFound = true
                break
                
            end
            
        end
        
    end
    
    return techFound
    
end



local origattemptbuy = Marine.AttemptToBuy
function Marine:AttemptToBuy(techIds)

  local techId = techIds[1]
  
           /*
               if techId == kTechId.JumpPack then
              --  StartSoundEffectForPlayer(Marine.activatedsound, self)
            //    self:AddResources(-GetCostForTech(techId))
                self.hasjumppack = true
              --  Print("Bought jump pack")
                return true
             elseif techId == kTechId.Resupply then
                self.hasresupply = true
                self:AdjustDisplayRessuply(self:GetClient():GetControllingPlayer(), 5, self.hasresupply)
               -- Print("bought resupply boolean is %s", self.hasresupply)
                return true
              elseif techId == kTechId.HeavyArmor then
               self.heavyarmor = true
               self.lightarmor = false
               return true
               elseif techId == kTechId.FireBullets then
                self.hasfirebullets = true
                return true
               elseif techId == kTechId.RegenArmor then
                 self.nanoarmor = true
                 return true
               elseif techId == kTechId.WallWalk then
                 self.wallboots = true
                 return true
               elseif techId == kTechId.LightArmor then
                 self.lightarmor = true
                 self.heavyarmor = false
                 return true
                end
            */    
    local hostStructure = GetHostStructureFor(self, techId)

    if hostStructure then
    
        local mapName = LookupTechData(techId, kTechDataMapName)
        
        if mapName then
        
            Shared.PlayPrivateSound(self, Marine.kSpendResourcesSoundName, nil, 1.0, self:GetOrigin())
            
            if self:GetTeam() and self:GetTeam().OnBought then
                self:GetTeam():OnBought(techId)
            end
            
                 
              if kIsExoTechId[techId] then
                BuyExo(self, techId)    
               else
                if hostStructure:isa("Armory") then self:AddResources(-GetCostForTech(techId)) end
                origattemptbuy(self, techIds)
            end
       end
   end
    

end


if Client then



local orig_Marine_UpdateGhostModel = Marine.UpdateGhostModel
function Marine:UpdateGhostModel()

orig_Marine_UpdateGhostModel(self)

 self.currentTechId = nil
 
    self.ghostStructureCoords = nil
    self.ghostStructureValid = false
    self.showGhostModel = false
    
    local weapon = self:GetActiveWeapon()

    if weapon then
       if weapon:isa("LayStructures") then
        self.currentTechId = weapon:GetDropStructureId()
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
        elseif weapon:isa("LayMines") then
        self.currentTechId = kTechId.Mine
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
         end
    end




end --function


function Marine:AddGhostGuide(origin, radius)

return

end




end -- client

