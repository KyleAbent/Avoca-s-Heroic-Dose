
function RoboticsFactory:GetTechButtons(techId) --so researcher doesn't spawn mac or arc
--maybe add arc conditional if less than 12. But then seperate method for setting avoca and main

    local techButtons = {  kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
               kTechId.None, kTechId.None, kTechId.None, kTechId.None }
               
    if self:GetTechId() ~= kTechId.ARCRoboticsFactory then
        techButtons[5] = kTechId.UpgradeRoboticsFactory
    end           

    return techButtons
    
end

function RoboticsFactory:GetMinRangeAC()
return 54 / 2    
end


local kOpenSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_open")
local kCloseSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_close")

local function GetArcsAmount()
    local bigarcs = 0
    local mainroomarc = 0
    local locationarc = 0
    local avocaarc = 0
    local total = 0
    
        for index, ARC in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
              if ARC:isa("BigArc") then
              bigarcs = bigarcs + 1
              elseif  ARC.mainroom then
              mainroomarc = mainroomarc + 1
              elseif ARC.avoca then
              avocaarc = avocaarc + 1
              end
         end
         total = bigarcs + mainroomarc + locationarc + avocaarc
    return  bigarcs, mainroomarc, locationarc, avocaarc, total
end
local function GetLocationsCount()
 /*
  local locations = {}
          for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
               local locationName = location and location:GetName() or ""
               table.insertunique(locations,locationName)  
          end
          
          return table.count(locations)
  */
  return 0
           
end
local function ArcQualifications(self)
 local boolean = false
 local bigarcs, mainroomarc, locationarc, avocaarc, total = GetArcsAmount()
            local HasPayLoad = avocaarc >=1 + bigarcs
     if (total <= (5+GetLocationsCount()) and  self:GetTeam():GetTeamResources() >= kARCCost) or not HasPayLoad   and
            self.deployed and 
            GetIsUnitActive(self) and 
           self:GetResearchProgress() == 0 and
          not self.open then
            boolean = true
      end
      
      return boolean
end

function RoboticsFactory:OnTag(tagName)
    
    PROFILE("RoboticsFactory:OnTag")

    if self.open and self.researchId ~= Entity.invalidId and tagName == "end" then

      if self.builtEntity then  self.builtEntity:Rollout(self, RoboticsFactory.kRolloutLength) end
          
           if Server then
            local bigarcs, mainroomarc, locationarc, avocaarc, total = GetArcsAmount()
            local HasPayLoad = avocaarc >=1 + bigarcs 
            local success = false
                local entity = self.builtEntity
                   if not HasPayLoad then
                        entity.avoca = true
                        success = true
                   end
                   if mainroomarc <= 7 and not success then
                        entity.mainroom = true
                        success = true
                   end
                --   if GetLocationsCount() > locationarc and not success then 
                  --      self:ChangeTo(entity, LocationArc.kMapName)
                   --     success = true
                   --end
                 self.builtEntity = nil
end
          
    end
    
    if tagName == "open_start" then
        StartSoundEffectAtOrigin(kOpenSound, self:GetOrigin())
    elseif tagName == "close_start" then
        StartSoundEffectAtOrigin(kCloseSound, self:GetOrigin())
    end
    
end


if Server then
  function RoboticsFactory:OnUpdate()
   if self.timeOfLastMacCheck == nil or Shared.GetTime() > self.timeOfLastMacCheck + 8 then
           if self:GetTechId() == kTechId.ARCRoboticsFactory  and ArcQualifications(self) then
           self:OverrideCreateManufactureEntity(kTechId.ARC)
           --self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - cost)
           end
           
    self.timeOfLastMacCheck = Shared.GetTime()  
    end
end
end