-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/
/*
 Needs Dynamic Siege Timer based on powerpoint count? Scenario for if marines lose all but last room. I would rather
 have Siege open in this instance than camp for 5 minutes knowing the eventual outcome.
  
  This would require GUI rather than Shine for on screen countdown display. To be able to change
  the timer dynamically.
  
*/

class 'Timer' (ScriptActor)
Timer.kMapName = "timer"


if Server then

Timer.kSiegeDoorSound = PrecacheAsset("sound/siegeroom.fev/door/siege")
Timer.kFrontDoorSound = PrecacheAsset("sound/siegeroom.fev/door/frontdoor")

end


local networkVars = 

{
   SiegeTimer = "integer",
   FrontTimer = "integer",
   frontOpened = "boolean",
   siegeOpened = "boolean",
   siegeBeaconed = "boolean",
}
local function GetFrontTime()
//Specific timing for each door? IE all configurable? For now one setting for all.
               for index, fr in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                if  fr.time ~= 0 then 
                  return fr.time  
                 end
         end 
              return 330             
end
local function GetSiegeTime()
//Specific timing for each door? IE all configurable? For now one setting for all.
               for index, sg in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                  if not sg:isa("FrontDoor") and sg.time ~= 0  then //damn children taking names
                    return sg.time
                   end
              end 
              return 960 
            
end
function Timer:TimerValues()
   //if kSiegeTimer == nil then kSiegeTimer = GetFrontTime() end//960 end
  // if kFrontTimer == nil then kFrontTimer = GetSiegeTime() end//330 end
  --kSiegeTimer = GetSiegeTime() 
  --kFrontTimer = GetFrontTime()
   self.SiegeTimer =  kSiegeDoorTime--GetSiegeTime() 
   self.FrontTimer = kFrontDoorTime --GetFrontTime()
   self.siegeOpened = false
   self.frontOpened = false

   self.siegeBeaconed = false
   self.powerlighth = nil

   --self.MSCPPC = 0
   
end

function Timer:OnReset() 
   self:TimerValues()
end
function Timer:GetIsMapEntity()
return true
end

function Timer:GetHasSiegeBeaconed()
return self.siegeBeaconed
end
function Timer:SetSiegeBeaconed(boolean)
 self.siegeBeaconed = boolean
end
function Timer:ClearAttached()
return 
end
function Timer:OnCreate()
  self:TimerValues()
      self:SetUpdates(true)
end
local function DoubleCheckLocks(who)
               for index, door in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                 door:CloseLock()
              end 
end
function Timer:OnRoundStart() 
  self:TimerValues()
  DoubleCheckLocks(self)
  GetGamerules():SetDamageMultiplier(0)
end
function Timer:GetSiegeLength()
 return self.SiegeTimer
end
function Timer:SetSiegeOpenBoolean(option)
 self.siegeOpened = option
end

function Timer:GetSiegeOpenBoolean()
  //Print("Timer siege open is %s", self.siegeOpened)
 return self.siegeOpened 
end
function Timer:GetFrontOpenBoolean()
 return self.frontOpened
end
function Timer:GetFrontLength()
 return self.FrontTimer 
end
local function OpenEightTimes(who)

if not who then return end

for i = 1, math.max(9 / 2, 16) do //more than 8 //kDoorMoveUpVect
                who:Open()
                who.isvisible = false
end

end
function Timer:OpenSiegeDoors()

     self.SiegeTimer = 0
               for index, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                 if not siegedoor:isa("FrontDoor") then OpenEightTimes(siegedoor) end
              end 
              
              if GetGameStarted() then
                  GetGamerules():DisplaySiege()
              
                for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
              StartSoundEffectForPlayer(Timer.kSiegeDoorSound, player)
              end
              
              
              end  
              
              self.siegeOpened = true
              
              
end

local function CloseAllBreakableDoors()
  for _, door in ientitylist(Shared.GetEntitiesWithClassname("BreakableDoor")) do 
           door.open = false
           door:SetHealth(door:GetHealth() + 10)
  end
end

function Timer:OpenFrontDoors()
         self.frontOpened = true
     
           GetGamerules():SetDamageMultiplier(1) 
           CloseAllBreakableDoors()
           self.FrontTimer = 0
               for index, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                      OpenEightTimes(frontdoor)
              end 
               if GetGameStarted() then 
                GetGamerules():DisplayFront()
              
              for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
              StartSoundEffectForPlayer(Timer.kFrontDoorSound, player)
              end
              

               end
               
               
               
end
function Timer:GetIsSiegeOpen()
           local gamestarttime = GetGameInfoEntity():GetStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.SiegeTimer
end
function Timer:GetIsFrontOpen()
           local gamestarttime = GetGameInfoEntity():GetStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.FrontTimer
end
function Timer:CountSTimer()
       if  self:GetIsSiegeOpen() then
               self:OpenSiegeDoors()
       end
       
end

function Timer:ResetLight()
if not self.powerlighth then return false end 
self.powerlighth:RestoreColorDerp()
return false
end

function Timer:PerformDisco()
//local powerpoints = {}
Print("Que?")


         for index, powerPoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
         if Client then //Not good. lol
         if powerPoint.lightHandler then
                     powerPoint.lightHandler:DiscoLights()
                     end
            end
          end
    
end


function Timer:gamerulesUpdate(deltatime) --flawed here not in sync with gamerules time. I forgot where to disable onupdate for now other than name change.

  if Server then 
    local gamestarted = GetGamerules():GetGameStarted()
      if gamestarted then 
       if not self.timelasttimerup or self.timelasttimerup + 1 <= Shared.GetTime() then
            if self.FrontTimer ~= 0 then 
                self:FrontDoorTimer()
             end
             if self.SiegeTimer ~= 0 then
                self:CountSTimer() 
             end 
        end
      end
  end
  
  
  
  
end
/*
function Timer:AutoConstructEligable()
    if not self.primaryOpened then 
   for _, entity in ipairs( GetEntitiesWithMixinWithinRange("Construct", self:GetOrigin(), 99999)) do
      if not entity:isa("PowerPoint") and not entity:GetIsBuilt() and not GetIsInSiege(entity) and (entity:GetTeamNumber() == 1 and GetIsRoomPowerUp(entity) ) or ( entity:GetTeamNumber() == 2 and GetIsRoomPowerDown(entity) ) then
       entity:Construct(0.1)
      end
    end
    end
end
*/

function Timer:FrontDoorTimer()
    if self:GetIsFrontOpen() then
         boolean = true
         self:OpenFrontDoors() -- Ddos!
     else
    //  self:AutoConstructEligable()
       end

end

function Timer:OnPreGame()
   for i = 1, 4 do
     Print("Timer OnPreGame")
   end
   
   for i = 1, 8 do
   self:OpenSiegeDoors()
   self:OpenFrontDoors()
   end
   
end

Shared.LinkClassToMap("Timer", Timer.kMapName, networkVars)





