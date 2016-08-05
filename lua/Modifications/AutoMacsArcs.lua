--arcs/macs spawning without robo
if Server then

local function GetMacsAmount()
    local basemac = 0
    local bigmac = 0
    local total = 0
        for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
             if mac:isa("BaseMac") then
             basemac = basemac + 1
             elseif mac:isa("BigMac") then
             basemac = basemac + 1
             end
             
         end
         total = basemac + bigmac
    return  basemac, bigmac, total
end
local function MacQualifications(self)
    local basemac,bigmac, total = GetMacsAmount()
 local boolean = false
     if total <= 7 then
            boolean = true
      end
      
      return boolean
        
end
local function GetMacMapName()
   local basemac,bigmac, total = GetMacsAmount()
   if basemac<= 7 then
       return BaseMac.kMapName
   elseif bigmac <= 3 then
        return  BigMac.kMapName
   end

end
function Conductor:CheckAndMaybeBuildMac()
  local chair = nil
            for _, mainent in ientitylist(Shared.GetEntitiesWithClassname("CommandStructure")) do
                    if mainent:GetTeamNumber() == 1 then chair = mainent break end
             end
             
           if MacQualifications(self) then
           local mac = CreateEntity(GetMacMapName(), FindFreeSpace(chair:GetOrigin()), 1 )
           end
           
           return true
end

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
              elseif ARC:isa("MainRoomArc") then
              mainroomarc = mainroomarc + 1
              elseif ARC:isa("LocationArc") then
              locationarc = locationarc + 1 
              elseif ARC:isa("AvocaArc") then
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
function RoboticsFactory:ChangeTo(who,mapname)
                      if Server then  
                      self:AddTimedCallback(function() 
                      local newentity = CreateEntity(mapname, who:GetOrigin(), 1)
                    --  if newentity:isa("LocationArc") then newentity:SetArcLocation() end
                      if newentity.BeginTimer then newentity:BeginTimer() end
                      DestroyEntity(who)
                     end, 4) 
                     end
end

function RoboticsFactory:OnTag(tagName)
    
    PROFILE("RoboticsFactory:OnTag")

    if self.open and self.researchId ~= Entity.invalidId and tagName == "end" then

        self.builtEntity:Rollout(self, RoboticsFactory.kRolloutLength)
          
           if Server then
            local bigarcs, mainroomarc, locationarc, avocaarc, total = GetArcsAmount()
            local HasPayLoad = avocaarc >=1 + bigarcs 
            local success = false
                local entity = self.builtEntity
                   if not HasPayLoad then
                        self:ChangeTo(entity, AvocaArc.kMapName)
                        success = true
                   end
                   if mainroomarc <= 7 and not success then
                        self:ChangeTo(entity, MainRoomArc.kMapName)
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