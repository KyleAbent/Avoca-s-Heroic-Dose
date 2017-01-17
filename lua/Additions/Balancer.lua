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
function Conductor:FirePhaseCannons(powerpoint, force)
               local powerdrains = 4 --not force and 4 or 2
               --powerdrains = self:GetCanVape() and powerdrains * 2 or powerdrains
                 local origin = GetRandomBuildPosition( kTechId.Whip, powerpoint:GetOrigin(), 8 )
                 local braindrain = CreateEntity(PowerDrainer.kMapName, origin, 2)
                  braindrain:SetConstructionComplete()
                  braindrain:ActivateSelfDestruct()
                  braindrain:SetMature()
    
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