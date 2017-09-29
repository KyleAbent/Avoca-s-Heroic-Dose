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
function Conductor:FirePhaseCannons(powerpoint)
             
             local origin = FindFreeSpace(powerpoint:GetOrigin())
             CreateEntity(Contamination.kMapName, FindFreeSpace(origin, 1, 8), 2)
          
      local  Whip = GetEntitiesForTeam( "Whip", 2 )   
      if #Whip < 18 then
             for i = 1, math.random(1,4) do
               local whip = CreateEntity(Whip.kMapName, FindFreeSpace(origin, 1, 8), 2)
               whip.rooted = true
               whip:Root() 
               whip:SetConstructionComplete()
             end
      end
            
      local  Crag = GetEntitiesForTeam( "Crag", 2 )
      if #Crag < 18 then 
             for i = 1 , math.random(1,2) do
             local crag = CreateEntity(Crag.kMapName, FindFreeSpace(origin, 1, 8), 2)
             crag:SetConstructionComplete()
             end
      end     
             if math.random(1,2) == 1 then
              CreateEntity(NutrientMist.kMapName, FindFreeSpace(origin, 1, 8), 2)
             end
             
      if GetConductor():GetIsPhaseTwoBoolean() then
           if math.random(1,2) == 1 then
           --chance or phase three or phase four if too much movement from hives during marine rushing hives
             local structBeacon = CreateEntity(StructureBeacon.kMapName, FindFreeSpace(origin, 1, 8), 2)
           else
             local eggBeacon = CreateEntity(EggBeacon.kMapName, FindFreeSpace(origin, 1, 8), 2)
           end
      end    
    
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
        StartSoundEffectForPlayer(GetDroppackSoundName(techId), self)
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