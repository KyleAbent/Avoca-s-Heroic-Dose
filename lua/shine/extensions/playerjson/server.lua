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
self.sessionIDs = {}

return true
end
 


function Plugin:AddClientToTable(id, name, addkarma)
   if not self.sessionIDs[ id ] then
     self.sessionIDs[ id ] = 
        { id = id,
          name = name,
          addKarma = addkarma,
          voted = false,
         }
        -- Print("AddClientToTable return true")
         return true
   end
      -- Print("AddClientToTable return false")
        return false
end
function Plugin:SetIDTable(id, name, addkarma, didvote)
   if self.sessionIDs[id ] then
     self.sessionIDs[ id ] = 
        { id = id,
          name = name,
          addKarma = self.sessionIDs[ id ].addKarma + addkarma,
          voted = didvote,
         }
   end
end
function Plugin:OnlyAddKarma(id, addkarma)
   if self.sessionIDs[id] then
     self.sessionIDs[ id ].addKarma = self.sessionIDs[ id ].addKarma + addkarma
   end
end
function Plugin:SetVoted(id, didvote)
   if self.sessionIDs[id] then
     self.sessionIDs[ id ].voted = didvote
   end
end
function Plugin:DidVote(id)
   if self.sessionIDs[id] then
     return self.sessionIDs[ id ].voted
   end
   return false
end
function Plugin:MapPostLoad()
--Print("Timer Created")
     self:CreateTimer( "SeedTimer", 600, -1, function()
              local Players = Shine.GetHumanPlayerCount()
              if Players >= 11 then return end
              
              local Clients, Count = Shine.GetAllClients()
              for i = 1, Count  do
               local Client = Clients[i]
              if not ( Client.GetIsVirtual and Client:GetIsVirtual() ) then
                    local ID = Client:GetUserId()
                    local name = ToString ( Client:GetControllingPlayer():GetName() )
                     if self:AddClientToTable(ID, name, 1) == false then --is in table
                 --      self:SetIDTable(ID, name, 1, false)
                         self:OnlyAddKarma(ID, 1)
                     end
                    Print("Seed Karma for %s", name)
                     Shine:NotifyDualColour( Client, 0, 255, 0, "[M>Proving Grounds>Karma]", 255, 255, 255, "You've gained 1 karma for helping to seed the server below 11 slot count. "  )
                     Shine:NotifyDualColour( Client, 0, 255, 0, "[M>Proving Grounds>Karma]", 255, 255, 255, "Your add karma amount for this session is now: " .. self.sessionIDs[ID].addKarma )
              end
              end
     end )
end
 
function Plugin:SaveInfos(ID, plnm, addkarma)
       --local shouldSave = false --isLast
       local Data = self:GetPlayerDataFromID( ID )
       if Data and Data.karma and Data.name then 
       
            if Data.name ~=  plnm then
              Data.name = plnm
            end      
           
           if addkarma ~= 0 then--If not 0 then has been adj.
             Data.karma = Data.karma + addkarma 
           end

           
       else 
       --if not self.PlayerData or not self.PlayerData.Users then
       --  self.PlayerData = { Users = {} }
       --end
     
          self.PlayerData.Users[ID] = {karma = self.sessionIDs[ ID ].addKarma, name = plnm }
          
       end
       

     
     
end


function Plugin:ClientConfirmConnect(Client)

local ID = Client:GetUserId()
local name = ToString ( Client:GetControllingPlayer():GetName() )
self:AddClientToTable(ID,name,0)
  
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

local DataFile = Shine.LoadJSONFile( PlayerInfoPath )
self.PlayerData = DataFile

    local function saveAll(key, value)
        Print("SaveAllInfo saveAll %s %s %s", value.id, value.name, value.addKarma)
        self:SaveInfos(value.id ,value.name, value.addKarma)
    end
    
    table.foreach(self.sessionIDs, saveAll)
    Print("Now Saving JSON")
    Shine.SaveJSONFile( self.PlayerData, PlayerInfoPath)
    HTTPRequest( "http://www.kyleabent.com/data/", "POST", {data = json.encode(self.PlayerData)})
         
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
          local ID = Player:GetClient():GetUserId()
          local name = ToString ( Player:GetName() )
                     if self:AddClientToTable(ID, name, Number) == false then --is in table
                       self:OnlyAddKarma(ID, Number)
                     end
   end
end

local AddKarmasCommand = self:BindCommand("sh_addkarma", "addkarma", AddKarma)
AddKarmasCommand:Help("sh_addkarma <player> <number> <display> <double> Choose not to display, or to double the amt if dbl crd is act.")
AddKarmasCommand:AddParam{ Type = "clients" }
AddKarmasCommand:AddParam{ Type = "number" }

local function KarmaTeam(Client, Number)
--This is not written well because at any time a player can activate a for loop of every other player on team up to 11. Worst case scenario for perf 11 players doing this.. * 11 loops?
--If I can set the vote option to be counted during mapchange instead. Then it will count votes after round. Well good for progress the way it is I suppose.

  if Number > 1 or Number < -1 or Number == 0 then
  Shine:NotifyDualColour( Client, 0, 255, 0, "[M>Proving Grounds>Karma]", 255, 255, 255, "Out of range expected -1 or 1."  )
   return 
  end
  
    local ID = Client:GetUserId()
    
    if self:DidVote(ID) then
      Shine:NotifyDualColour( Client, 0, 255, 0, "[M>Proving Grounds>Karma]", 255, 255, 255, "You've already voted this session."  )
     return
     else
     self:SetVoted(ID, true)
     end
     
  local clpl = Client:GetControllingPlayer()
  local teammates = Shine.GetTeamClients( clpl:GetTeamNumber() )
  local name = "derp"
  
    for i = 1, #teammates do
    local Player = teammates[ i ]:GetControllingPlayer()
           ID = Player:GetClient():GetUserId()
           name = ToString ( Player:GetName() )
          if not Player == clpl then
                     if self:AddClientToTable(ID, name, Number) == false then --is in table
                       self:OnlyAddKarma(ID, Number)
                       Shine:NotifyDualColour( Player, 0, 255, 0, "[M>Proving Grounds>Karma]", 255, 255, 255, "A teammate altered your karma.. "  )
                       Shine:NotifyDualColour( Player, 0, 255, 0, "[M>Proving Grounds>Karma]", 255, 255, 255, "Your add karma amount for this session is now: " .. self.sessionIDs[ID].addKarma )
                     end
         end
   end
end

local AddKarmasCommand = self:BindCommand("sh_karmateam", "karmateam", KarmaTeam)
AddKarmasCommand:Help("sh_karmateam <player> <number> <display> <double> Choose not to display, or to double the amt if dbl crd is act.")
AddKarmasCommand:AddParam{ Type = "number" }





local function SaveInfoCmd(Client)
self:SaveAllInfo(false)
end

local SaveInfoCmdCommand = self:BindCommand("sh_saveinfo", "saveinfo", SaveInfoCmd)


end