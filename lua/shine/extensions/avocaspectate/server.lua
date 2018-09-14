--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin


Shine.Hook.SetupClassHook( "AvocaSpectator", "ChangeView", "OnChangeView", "Post" )

Plugin.Version = "1.0"

local function AutoSpectate(self)

    Shine.Timer.Create( "AutoSpectate", 8, -1, function() 
                   for index, player in ientitylist(Shared.GetEntitiesWithClassname("AvocaSpectator")) do
                              self:OnChangeView(player)
              end 
    end )
    
end


function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()
return true
end
function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Director]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifySand( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Director]",  255, 0, 0, String, Format, ... )
end
local function GetPregameView()
local choices = {}
 
              
                   for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                  if player ~= self and not player:isa("Spectator")  and not player:isa("ReadyRoomPlayer")  and not player:isa("Commander") and player:GetIsOnGround() then table.insert(choices, player) break end
              end 
            
              local random = table.random(choices)
              return random
              

end
local function GetIsBusy(who)
  local order = who:GetCurrentOrder()
local busy = false
   if order then
   busy = true
   end
return busy
end


local function GetLocationName(who)
        local location = GetLocationForPoint(who:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
local function FindEntNear(where)
                  local entity =  GetNearestMixin(where, "Combat", nil, function(ent) return ent:GetIsInCombat() and not ent:isa("Commander") end)
                    if entity then
                    return FindFreeSpace(entity:GetOrigin())
            end
            return where
end


local function lockTarget(self, client, vip)
          client:SetDesiredCameraDistance(0)
        -- Print("vip is %s", vip:GetClassName())
          if client:GetSpectatorMode() ~= kSpectatorMode.FreeLook then client:SetSpectatorMode(kSpectatorMode.FreeLook)  end
          local viporigin = vip:GetOrigin()
        //  local findfreespace = FindFreeSpace(viporigin, 1, 8)
        //  if findfreespace == viporigin then findfreespace.x = findfreespace.x - 2 return end
            //  client:SetOrigin(findfreespace)
              client:SetOrigin(viporigin)
             client:SetOffsetAngles(vip:GetAngles()) //if iscam
            
             local dir = GetNormalizedVector(viporigin - client:GetOrigin())
             local angles = Angles(GetPitchFromVector(dir), GetYawFromVector(dir), 0)
             client:SetOffsetAngles(angles)
             client:SetLockOnTarget(vip:GetId())
             //Sixteenth notes within eigth notes which is the other untilNext
             
             self:NotifyGeneric( client, "VIP is %s, location is %s", true, vip:GetClassName(), GetLocationName(client) )
end

 function Plugin:OnChangeView(client)
        
        if not client then return end
       local random = {} --table.random(choices)
       local vip = nil
        
        for i = 1, 2 do
             vip = GetNearestMixin(client:GetOrigin(), "Combat", i, function(ent) return ent:GetIsInCombat() end)
             if vip ~= nil then 
             table.insert(random, vip)
              end
        end
        
        local choice = table.random(random)
         if choice ~= nil then 
        lockTarget(self, client, vip)
        end
        
       --  Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.75,Text = "[Director] untilNext: %s",Duration = betweenLast or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, client )  

end




function Plugin:CreateCommands()



local function Direct( Client, Targets )
          AutoSpectate(self)
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
          Player:Replace(AvocaSpectator.kMapName, 3)
     end
end

local DirectCommand = self:BindCommand( "sh_direct", "direct", Direct)
DirectCommand:AddParam{ Type = "clients" }



end