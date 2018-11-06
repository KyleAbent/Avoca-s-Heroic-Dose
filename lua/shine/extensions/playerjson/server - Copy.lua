/*Kyle 'Avoca' Abent Karmas Season 4
kyle@kyleabent.com
*/
local Shine = Shine
local Plugin = Plugin
local HTTPRequest = Shared.SendHTTPRequest




Shine.PlayerData = {}
Shine.LinkFile = {}
Shine.BadgeFile = {}
Plugin.Version = "11.16"

local PlayerInfoPath = "config://shine/plugins/playersinfo.json"


function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
self.KarmaAmount = 0
self.KarmaUsers = {}

return true
end
 
 function Plugin:OnFirstThink() 
local DataFile = Shine.LoadJSONFile( PlayerInfoPath )
self.PlayerData = DataFile
end

function Plugin:MapPostLoad()
--Print("Timer Created")
     self:CreateTimer( "SeedTimer", 600, -1, function()
              local Players = Shine.GetAllPlayers()
              if #Players >= 11 then return end
                 for _, playerInfo in ipairs( EntityListToTable(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) ) do
                 local plid = playerInfo.steamId
                 self.KarmaUsers[ plid ] = self:GetPlayerDataInfoFromID( plid   ) + 1
                 Print("Seed Karma for %s", playerInfo.playerName)
                 end
     end )
end
 
function Plugin:SaveInfos(ID, plnm, disconnected)
       local shouldSave = false
       local Data = self:GetPlayerDataFromID( ID )
       if Data and Data.karma and Data.name then 
       
         if Data.name ~=  plnm then
           Data.name = plnm
           shouldSave = true
           end      
           
           local karm = self:GetPlayerDataInfoFromID(ID)
           if Data.karma ~=  karm then
             Data.karma = karm 
             shouldSave = true
           end

           
       else 
       if not self.PlayerData or not self.PlayerData.Users then
         self.PlayerData = { Users = {} }
       end
       shouldSave = true
      self.PlayerData.Users[ID ] = {karma = self:GetPlayerDataInfoFromID(ID), name = plnm }
       end
       
     if disconnected == true and shouldSave == true then 
      Shine.SaveJSONFile( self.PlayerData, PlayerInfoPath  ) 
     end
     
     
end

/*
--Im replacing gamerules (and not using shine hook for client disconnect) because I want to work with playerinfoentity
--@@override
Shine.Hook.SetupClassHook( "Gamerules", "OnClientDisconnect", "doDisc", "Replace" )
function Plugin:doDisc(Client)
  Print("doDisc")
    local clientIndex = Client:GetId()
    
    for _, playerInfo in ipairs( EntityListToTable(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) ) do
    
        if playerInfo.clientIndex == clientIndex then
        Print("Found yo")
            self:SaveInfos(playerInfo.steamId , playerInfo.playerName, true)
            DestroyEntity(playerInfo)
            break
            
        end    
    end

end
*/

function Plugin:ClientDisconnect(Client)
     --  if #Players >= 11 then return end --hm?
       local id = Client:GetUserId()
       local name = Client:GetControllingPlayer():GetName()
       self:SaveInfos(id , name, true)
end

function Plugin:GetPlayerDataInfoFromID(ID)
   local Karmas = 0
       if self.KarmaUsers[ ID ] then
          Karmas = self.KarmaUsers[ ID ]
       elseif not self.KarmaUsers[ ID ] then 
          local Data = self:GetPlayerDataFromID( ID )
           if Data and Data.karma then 
           Karmas = Data.karma 
           end
       end
return math.round(Karmas, 2)
end



local function GetIDFromClient( Client )
	return Shine.IsType( Client, "number" ) and Client or ( Client.GetUserId and Client:GetUserId() ) // or nil //or nil was blocked but im testin
 end
 function Plugin:GetPlayerDataFromID(ID)
  if not self.PlayerData then return nil end
  if not self.PlayerData.Users then return nil end
  if not ID then return nil end
  local User = self.PlayerData.Users[ tostring( ID ) ] 
  if not User then 
     local SteamID = Shine.NS2ToSteamID( ID )
     User = self.PlayerData.Users[ SteamID ]
     if User then
     return User, SteamID
     end
     local Steam3ID = Shine.NS2ToSteam3ID( ID )
     User = self.PlayerData.Users[ ID ]
     if User then
     return User, Steam3ID
     end
     return nil, ID
   end
return User, ID
end



function Plugin:SaveAllInfo()

           for _, playerInfo in ipairs( EntityListToTable(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) ) do
                 local plid = playerInfo.steamId
                 self:SaveInfos(plid, playerInfo.playerName, false)
          end
                 
         Shine.SaveJSONFile( self.PlayerData, PlayerInfoPath  )
end
function Plugin:MapChange()
   self:SaveAllInfo()
end


function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end


function Plugin:CreateCommands()


local function AddKarma(Client, Targets, Number)

  
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self.KarmaUsers[ Player:GetClient():GetUserId() ] = self:GetPlayerDataInfoFromID(Player:GetClient():GetUserId() ) + Number
end
end

local AddKarmasCommand = self:BindCommand("sh_addkarma", "addkarma", AddKarma)
AddKarmasCommand:Help("sh_addkarma <player> <number> <display> <double> Choose not to display, or to double the amt if dbl crd is act.")
AddKarmasCommand:AddParam{ Type = "clients" }
AddKarmasCommand:AddParam{ Type = "number" }



local function SaveInfoCmd(Client)
self:SaveAllInfo(false)
end

local SaveInfoCmdCommand = self:BindCommand("sh_saveinfo", "saveinfo", SaveInfoCmd)


end