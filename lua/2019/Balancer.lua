if Server then


function Conductor:CountUnBuiltNodes()
local unbuilt = 0
                 for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                   if powerpoint:GetIsBuilt() and powerpoint:GetIsDisabled() then
                     unbuilt = unbuilt + 1
                   end
                end
                return unbuilt

end


 /*
 function AlienTeam:DeployBeacons(powerorigin)
     --Same as Phase cannons. Though rather inside siegeroom. To mimic the action
     -- of Alien Commander trying to gain control of Siegeroom, as the comm would do
     -- back in the December 2014 builds with Egg Beacon and Structure Beacon manually placed.
 
 end
 */
  local function GetHasThreeHives() --gethastech biomass 9?
  local count = 0
            for _, hv in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
                if hv:GetIsBuilt()  then 
                 count = count + 1
                end
             end

 return count >=3 --return a hive has tech biomass9 
end

function Conductor:FirePhaseCannons(powerpoint)

              if not GetHasThreeHives() or not GetFrontDoorOpen() then return end -- although not requiring biomass. Maybe later.
              
             
              
             -- for i = 1, GetConductor():getPhase()  do
              local origin = FindFreeSpace(powerpoint:GetOrigin())
              CreateEntity(Contamination.kMapName, FindFreeSpace(origin, 1, 8), 2)
              local egg = CreateEntity(Egg.kMapName, FindFreeSpace(origin, 1, 8), 2)
                    egg:SetHive(GetRandomHive())
              --phase four egg spawn?
             -- end
              
            

          
       /*
       
      local  WhipCount = GetEntitiesForTeam( "Whip", 2 )   
     -- local doCons = GetConductor():GetIsPhaseFourBoolean()
      if #WhipCount < 18 then
             for i = 1, math.random(1, GetConductor().phase ) do  --( 18 - #WhipCount )  )  do
               local whip = CreateEntity(Whip.kMapName, FindFreeSpace(origin, 1, 8), 2)
              -- if doCons then
             --  whip:SetConstructionComplete() -- chance < 100% ?
              -- end
               whip.rooted = true
               whip:Root() 
             end
      end
            
      local  CragCount = GetEntitiesForTeam( "Crag", 2 )
      if #CragCount < 18 then 
             for i = 1 ,math.random(1, GetConductor().phase  ) do
             local crag = CreateEntity(Crag.kMapName, FindFreeSpace(origin, 1, 8), 2)
             --crag:SetConstructionComplete()-- chance < 100% ?
             end
      end     
      
      local  ShadeCount = GetEntitiesForTeam( "Shade", 2 )   --withinradius?
      if #ShadeCount < 8 then
             for i = 1, math.random(1, GetConductor().phase ) do
               local shade = CreateEntity(Shade.kMapName, FindFreeSpace(origin, 1, 8), 2)
               --shade:SetConstructionComplete()-- chance < 100% ?
             end
      end
      */
     
     /*
      local  PanicAttackCount = GetEntitiesForTeam( "PanicAttack", 2 )   --withinradius?
      if #PanicAttackCount < 18 then
             for i = 1, math.random(1, 18 - #PanicAttackCount ) do
               local pannicattack = CreateEntity(PanicAttack.kMapName, FindFreeSpace(origin, 1, 8), 2)
               --shade:SetConstructionComplete()-- chance < 100% ?
             end
      end 
      */
     



    
end


local function GetDroppackSoundName(techId)

    if techId == kTechId.MedPack then
        return MedPack.kHealthSound
    elseif techId == kTechId.AmmoPack then
        return AmmoPack.kPickupSound
    elseif techId == kTechId.CatPack then
        return CatPack.kPickupSound
    end 
   
end
local function PackRulesHere(who, origin, techId, self)  

/*
 local donotadd = false
      if self.team1:GetTeamResources() == 0 then return end
    if self.marinepacksdropped == 4 then
       self.team1:SetTeamResources(self.team1:GetTeamResources()  - 1)
       donotadd = true
       self.marinepacksdropped = 0
    end
 */
   
    local mapName = LookupTechData(techId, kTechDataMapName)
   -- local success = false
    
    if mapName then
      --Print("DropMarineSupport test")
        local desired = FindFreeSpace(origin, 0, 4)
         if desired ~= nil then
         position = desired
         end
        local droppack = CreateEntity(mapName, position, 1)
      --  StartSoundEffectForPlayer(GetDroppackSoundName(techId), self)
       // self:ProcessSuccessAction(techId)
       -- success = true
        
      --  if not donotadd then
      --  self.marinepacksdropped = Clamp(self.marinepacksdropped + 1, 1, 4)
      --  end
        
    end

--return success
end
local function PackQualificationsHere(who, self)
       local weapon = who:GetActiveWeapon()
       local medpacks = GetEntitiesForTeamWithinRange("MedPack", 1, who:GetOrigin(), 8)
       local ammopacks = GetEntitiesForTeamWithinRange("AmmoPack", 1, who:GetOrigin(), 8)
            if who:GetHealth() <= 90 and #medpacks <= 4 then 
             PackRulesHere(who, who:GetOrigin(), kTechId.MedPack, self)
             elseif  weapon and weapon.GetAmmoFraction and weapon:GetAmmoFraction() <= .65 and #ammopacks <= 4  then                     
             PackRulesHere(who, who:GetOrigin(), kTechId.AmmoPack, self)
             elseif who:GetIsInCombat() then
                local random = math.random(1,2)
                if random == 1 then
                 PackRulesHere(who, who:GetOrigin(), kTechId.CatPack, self)
                else
                  who:ActivateNanoShield()
                end
             end
end
function Conductor:HandoutMarineBuffs()
            for _, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
            if marine:GetIsAlive() and not marine:isa("Commander") then 
                 PackQualificationsHere(marine, self)
                end
             end
             return true
end






end //of server