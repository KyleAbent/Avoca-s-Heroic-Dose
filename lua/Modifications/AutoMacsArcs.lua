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
    local arcs = 0
        for index, ARC in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
               if not ARC:isa("AvocaArc") then arcs = arcs + 1 end
         end
    return  arcs
end
local function HasPayLoad(where)

    local arcs = #GetEntitiesWithinRange("AvocaArc", where, 999)
    local ccs = #GetEntitiesWithinRange("CommandStation", where, 999)
    
    
    if not arcs or ccs>arcs then return false else return true end

end
local function ArcQualifications(self)
 local boolean = false
     if (GetArcsAmount() <= 7 and  self:GetTeam():GetTeamResources() >= kARCCost) or not HasPayLoad(self:GetOrigin())   and
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
                local entity = self.builtEntity
                   if not HasPayLoad(entity:GetOrigin()) then
                        self:ChangeTo(entity, AvocaArc.kMapName)
                   else
                        self:ChangeTo(entity, MainRoomArc.kMapName)
                   end
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
           self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - cost)
           end
           
    self.timeOfLastMacCheck = Shared.GetTime()  
    end
end
end