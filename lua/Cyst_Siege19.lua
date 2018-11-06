/*

not necessary
local networkVars = 

{
    lastNearby = "private time",
}
local origC = Cyst.OnCreate
function Cyst:OnCreate()
 origC(self)
  self.lastNearby = 0

end

if Server then
local origU = Cyst.OnUpdate
    function Cyst:OnUpdate(deltaTime)
        origU(self, deltaTime)
         if not self.connected and GetIsTimeUp(self.lastNearby,6 ) then
              local Cyst = GetEntitiesForTeamWithinRange("Cyst", 2, self:GetOrigin(), 7)
              if not #Cyst then
              CreateEntity(Cyst.kMapName, FindFreeSpace(self:GetOrigin(), 7, 13), 2)
              end
           self.lastNearby = Shared.GetTime()
        end
    end
 end
  
Shared.LinkClassToMap("Cyst", Cyst.kMapName, networkVars)


*/