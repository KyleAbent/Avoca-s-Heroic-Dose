local kOpenSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_open")
local kCloseSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_close")

local function GetMacsAmount()
    local macavoca = 0
    local basemac = 0
    local playermac = 0
    local bigmac = 0
    local total = 0
        for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
             if mac:isa("BaseMac") then
             basemac = basemac + 1
             elseif mac:isa("PlayerMac") then
             playermac = playermac + 1
             elseif mac:isa("BigMac") then
             basemac = basemac + 1
             elseif mac:isa("MacAvoca") then
             macavoca = macavoca + 1
             end
             
         end
         total = macavoca + basemac + playermac + bigmac
    return  macavoca, basemac, playermac, bigmac, total
end
local function GetArcsAmount()
    local arcs = 0
        for index, ARC in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
               if not ARC:isa("AvocaArc") then arcs = arcs + 1 end
         end
    return  arcs
end
local function ArcQualifications(self)
 local boolean = false
     if GetArcsAmount() <= 7 and
       -- self:GetTeam():GetTeamResources() >= kARCCost and 
      --    ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.ARC, kTechDataSupply, 0)) and 
            self.deployed and 
            GetIsUnitActive(self) and 
           self:GetResearchProgress() == 0 and
          not self.open then
            boolean = true
      end
      
      return boolean
end
local function MacQualifications(self)
    local macavoca,basemac, playermac,bigmac, total = GetMacsAmount()
 local boolean = false
     if total <= 7 and
      --  self:GetTeam():GetTeamResources() >= kMACCost and 
       --   ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.MAC, kTechDataSupply, 0)) and 
            self.deployed and 
            GetIsUnitActive(self) and 
           self:GetResearchProgress() == 0  and
          not self.open then
            boolean = true
      end
      
      return boolean
        
end
local function HasPayLoad(where)

        for _, avocaarc in ipairs(GetEntitiesWithinRange("AvocaArc", where, 999)) do
            if avocaarc then return true end
       end
       return false
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
function RoboticsFactory:ChangeMacsAccordinglyHere(entity)
   local macavoca,basemac, playermac,bigmac, total = GetMacsAmount()
   if macavoca <= 2 then
   self:ChangeTo(entity, MacAvoca.kMapName)
   elseif basemac<= 2 then
   self:ChangeTo(entity, BaseMac.kMapName)
   elseif playermac <=2 then
   self:ChangeTo(entity, PlayerMac.kMapName)
   elseif bigmac == 0 then
   self:ChangeTo(entity, BigMac.kMapName)
   end

end
function RoboticsFactory:OnTag(tagName)
    
    PROFILE("RoboticsFactory:OnTag")

    if self.open and self.researchId ~= Entity.invalidId and tagName == "end" then

        self.builtEntity:Rollout(self, RoboticsFactory.kRolloutLength)
          
           if Server then
                local entity = self.builtEntity
                if entity:isa("ARC") then
                   if not HasPayLoad(entity:GetOrigin()) then
                        self:ChangeTo(entity, AvocaArc.kMapName)
                   else
                        self:ChangeTo(entity, MainRoomArc.kMapName)
                   end
               elseif entity:isa("MAC") then
                    self:ChangeMacsAccordinglyHere(entity)
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
           if MacQualifications(self) then
           self:OverrideCreateManufactureEntity(kTechId.MAC)
           --self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kMACCost )
           elseif ArcQualifications(self) then
           self:OverrideCreateManufactureEntity(kTechId.ARC)
           end
           
    self.timeOfLastMacCheck = Shared.GetTime()  
    end
end
end