-- Kyle 'Avoca' Abent
  --Though pretty much EEM and Location / Basic Triggers 'etc' :P

Script.Load("lua/Trigger.lua")

class 'AirLock' (Trigger)
AirLock.kMapName = "airlock"

PrecacheAsset("materials/power/powered_decal.surface_shader")
local kAirLockMaterial = PrecacheAsset("materials/power/powered_decal.material")

local networkVars =
{
}
 function GetIsInAirLock(who)  --I don't want to rely on networkvars.
local boolean = false
if who:isa("Spectator") then return false end

            for _, airlock in ientitylist(Shared.GetEntitiesWithClassname("AirLock")) do
               local location = GetLocationForPoint(who:GetOrigin())
               boolean = location and airlock.name == location.name -- Smart ! -- Better than OnUpdate too.
               break
          end
   
 --Print("who in airlock is %s", boolean)
return boolean

end
local function AliensInAirLock()
    local aliens = GetGamerules():GetTeam2():GetNumPlayers()
  local count = 0
  local bonusper = 1
   for _, player in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do 
        if player:GetIsAlive() and GetIsInAirLock(player) then
         count = count + 1
           --Print("aliens count is %s", count)
         end
   end
      local total = (count/aliens)*bonusper
      --Print("aliens total is %s", total)
     return (count/aliens)*bonusper
end

local function PowerSurgeMarines(self)
    --Print("PowerSurgeMarines being called")
        for _, entity in ipairs(self:GetEntitiesInTrigger()) do
            if HasMixin(entity, "PowerConsumer") then
             entity:SetPowerSurgeDuration(4) Print("PowerSurged structure") 
          end
    end
end

function AirLock:OnInitialized()
   Trigger.OnInitialized(self) 
   self:SetUpdates(true)
   self:SetTriggerCollisionEnabled(true)
   self:SetPropagate(Entity.Propagate_Always)


   
end

local function ForTheLulz(self, who)
               local direction = Vector(math.random(-900,900),math.random(-900,900),math.random(-900,900))
               local current = who:GetVelocity()
               who:SetVelocity( current  +  direction )
end
local function ThanksEEM(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
           if entity:isa("Player") then
             local location = GetLocationForPoint(entity:GetOrigin()) --hack
           --  Print("player is in AirLock located at %s", location.name )
           -- ForTheLulz
          end
    end
    
end

function AirLock:OnUpdate(deltaTime) 
  /*
    if Server then
      if not self.lastupdate or Shared.GetTime() > self.lastupdate + 1 then
         PowerSurgeMarines(self)
     end
     --    self.lastupdate = Shared.GetTime()
    end
  */
end
function GetAirLocks()
    return EntityListToTable(Shared.GetEntitiesWithClassname("AirLock"))
end
function AirLock:MarinesInAirLock()
  -- local marines = GetGamerules():GetTeam1():GetNumPlayers()
  local count = 0
  --local bonusper = 1
   for _, player in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do 
        if player:GetIsAlive() and GetIsInAirLock(player) then
         count = count + 1
        --Print("marines count is %s", count)
         end
   end
      --local total = (count/marines)*bonusper
      --Print("marines total is %s", total)
     return count --(count/marines)*bonusper
end
function GetIsPointInAirLock(point)  --Maybe a 'workaround' for other entities than players
                                                      --to use this airlock entity rather than relying onupdate, maybe.. who knows.

    local ents = GetAirLocks()
    
    for index, airlock in ipairs(ents) do
    
        if airlock and airlock:GetIsPointInside(point) then
        
            return airlock
            
        end    
        
    end
    
    return nil

end

function Player:GetIsInAirLock()  --I don't want to rely on networkvars.
local boolean = GetIsPointInAirLock(self:GetOrigin())
 Print("player inairlock is %s", boolean)
return boolean

end

function AirLock:OnDestroy()

    Entity.OnDestroy(self)
if Client then
    self:HideDank() 
end 
    
end

if Server then

    function AirLock:OnTriggerEntered(entity, triggerEnt)
        ASSERT(self == triggerEnt)
        if entity:isa("Player") then
        -- ForTheLulz(self, entity)
        end
            
    end
    
    function AirLock:OnTriggerExited(entity, triggerEnt)
        ASSERT(self == triggerEnt)
        if entity:isa("Player")  then
       -- ForTheLulz(self, entity)
        end            
    end

elseif Client then



    function AirLock:ShowDank()

        if not self.highDecal then
            self.materialLoaded = nil  
        end

        
            if self.materialLoaded ~= "lit" then
            
                if self.highDecal then
                    Client.DestroyRenderDecal(self.highDecal)
                    Client.DestroyRenderMaterial(self.dankMaterial)
                end
                
                self.highDecal = Client.CreateRenderDecal()

                local material = Client.CreateRenderMaterial()
                material:SetMaterial(kAirLockMaterial)
        
                self.highDecal:SetMaterial(material)
                self.materialLoaded = "lit"
                self.dankMaterial = material
                
            end
        
    end

    function AirLock:HideDank()

        if self.highDecal then
            Client.DestroyRenderDecal(self.highDecal)
            Client.DestroyRenderMaterial(self.dankMaterial)
            self.highDecal = nil
            self.dankMaterial = nil
        end

    end
    
    function AirLock:OnUpdateRender()
    
        PROFILE("AirLock:OnUpdateRender")
        
        local player = Client.GetLocalPlayer()  
        local showMeTheMoney = player    
        local powerPoint = GetPowerPointForLocation(self.name)  
        if not powerPoint then return end 
        --Print("powerPoint is %s", powerPoint)
      
            self:ShowDank()
            if self.highDecal then
            
                -- TODO: Doesn't need to be updated every frame, only setup on creation.
            
                local coords = self:GetCoords()
                local extents = self.scale * 0.2395
                extents.y = 10
                coords.origin.y = powerPoint:GetOrigin().y - 2
                
                -- Get the origin in the object space of the decal.
                local osOrigin = coords:GetInverse():TransformPoint( powerPoint:GetOrigin() )
                self.dankMaterial:SetParameter("osOrigin", osOrigin)

                self.highDecal:SetCoords(coords)
                self.highDecal:SetExtents(extents)
                
            end
        
    end
    
end

Shared.LinkClassToMap("AirLock", AirLock.kMapName, networkVars)