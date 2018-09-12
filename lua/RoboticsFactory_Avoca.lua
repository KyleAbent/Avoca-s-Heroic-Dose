
local function GetArcsAmount()
    local total = 0
    
        for index, ARC in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
              total = total + 1
         end
    return  total
end


/*
function RoboticsFactory:OnConstructionComplete()

   self:UpgradeToTechId(kTechId.ARCRoboticsFactory)

end
*/

function RoboticsFactory:GetTechButtons(techId) 

    local techButtons = {  kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
               kTechId.None, kTechId.None, kTechId.None, kTechId.None }
               
    if self:GetTechId() ~= kTechId.ARCRoboticsFactory then
        techButtons[5] = kTechId.UpgradeRoboticsFactory
    end           
    if GetArcsAmount() < kHowManyArcsDoIWant then
       techButtons[1] = kTechId.ARC
    end
    return techButtons
    
end

function RoboticsFactory:GetMinRangeAC()
return 54 / 2    
end


local kOpenSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_open")
local kCloseSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_close")


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


if Server then
  function RoboticsFactory:OnUpdate()
   if self.timeOfLastMacCheck == nil or Shared.GetTime() > self.timeOfLastMacCheck + 8 then
           if self:GetIsBuilt() and self:GetIsPowered() and  self:GetTechId() == kTechId.ARCRoboticsFactory  and  GetArcsAmount() < kHowManyArcsDoIWant then
           self:OverrideCreateManufactureEntity(kTechId.ARC)
           --self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - cost)
           end
           
    self.timeOfLastMacCheck = Shared.GetTime()  
    end
end
end


function RoboticsFactory:OnPowerOn()
	 GetImaginator().activeRobos = GetImaginator().activeRobos + 1;  
end

function RoboticsFactory:OnPowerOff()
	 GetImaginator().activeRobos = GetImaginator().activeRobos - 1;  
end

 function RoboticsFactory:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetImaginator().activeRobos  = GetImaginator().activeRobos- 1;  
	  end
end