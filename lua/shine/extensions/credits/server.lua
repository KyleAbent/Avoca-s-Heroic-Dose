/*Kyle Abent SiegeModCommands 
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb
*/
local Shine = Shine
local Plugin = Plugin

Shine.CreditData = {}
Shine.LinkFile = {}
Shine.BadgeFile = {}
Plugin.Version = "10.28"

local CreditsPath = "config://shine/plugins/credits.json"

Shine.Hook.SetupClassHook( "ScoringMixin", "AddScore", "OnScore", "PassivePost" )
Shine.Hook.SetupClassHook( "NS2Gamerules", "ResetGame", "OnReset", "PassivePost" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyMist", "BecauseFuckSpammingCommanders", "Replace" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyMed", "BuyMed", "Replace" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyAmmo", "BuyAmmo", "Replace" )
Shine.Hook.SetupClassHook( "Alien", "TunnelFailed", "FailMessage", "Replace" )
Shine.Hook.SetupClassHook( "Alien", "TunnelGood", "GoodMessage", "Replace" )




function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
self.GameStarted = false
self.CreditAmount = 0
self.CreditUsers = {}
self.BuyUsersTimer = {}
self.marinebonus = 0
self.alienbonus = 0

self.UserStartOfRoundCredits = {}
self.MarineTotalSpent = 0
self.AlienTotalSpent = 0
self.Refunded = false

self.PlayerSpentAmount = {}

return true
end


function Plugin:OnScore( Player, Points, Res, WasKill )
if Points ~= nil and Points ~= 0 and Player and GetGamerules():GetGameStarted() then
 local client = Player:GetClient()
 if not client then return end
         
    local addamount = Points/(10/kCreditMultiplier)      
 local controlling = client:GetControllingPlayer()
         
self.CreditUsers[ controlling:GetClient() ] = self:GetPlayerCreditsInfo(controlling:GetClient()) + addamount
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(controlling:GetClient()) ), controlling:GetClient()) 
end
end
function Plugin:NotifySiege( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Siege]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end

function Plugin:OnFirstThink() 
local CreditsFile = Shine.LoadJSONFile( CreditsPath )
self.CreditData = CreditsFile

        kCreditMultiplier = 1


end
function Plugin:SaveCredits(Client)
       local Data = self:GetCreditData( Client )
       if Data and Data.credits then 
         if not Data.name or Data.name ~= Client:GetControllingPlayer():GetName() then
           Data.name = Client:GetControllingPlayer():GetName()
           end        
       Data.credits = self:GetPlayerCreditsInfo(Client) 
       else 
      self.CreditData.Users[Client:GetUserId() ] = {credits = self:GetPlayerCreditsInfo(Client), name = Client:GetControllingPlayer():GetName() }
       end
     Shine.SaveJSONFile( self.CreditData, CreditsPath  )
end
function Plugin:ClientDisconnect(Client)
self:SaveCredits(Client)
 //self:AdjustMarineBuildSpeed()
end
function Plugin:GetPlayerCreditsInfo(Client)
   local Credits = 0
       if self.CreditUsers[ Client ] then
          Credits = self.CreditUsers[ Client ]
       elseif not self.CreditUsers[ Client ] then 
          local Data = self:GetCreditData( Client )
           if Data and Data.credits then 
           Credits = Data.credits 
           end
       end
return math.round(Credits, 2)
end
local function GetIDFromClient( Client )
	return Shine.IsType( Client, "number" ) and Client or ( Client.GetUserId and Client:GetUserId() ) // or nil //or nil was blocked but im testin
 end
function Plugin:GetCreditData(Client)
  if not self.CreditData then return nil end
  if not self.CreditData.Users then return nil end
  local ID = GetIDFromClient( Client )
  if not ID then return nil end
  local User = self.CreditData.Users[ tostring( ID ) ] 
  if not User then 
     local SteamID = Shine.NS2ToSteamID( ID )
     User = self.CreditData.Users[ SteamID ]
     if User then
     return User, SteamID
     end
     local Steam3ID = Shine.NS2ToSteam3ID( ID )
     User = self.CreditData.Users[ ID ]
     if User then
     return User, Steam3ID
     end
     return nil, ID
   end
return User, ID
end
 function Plugin:ClientConnect(Client)
     --SO I can seed and AFK  without being randomized onteam while afk :P
     if Client:GetUserId() == 22542592 then
     
     self:SimpleTimer( 4, function() 
     Shared.ConsoleCommand(string.format("sh_setteam %s 1", Client:GetUserId())) 
      end)

     end
 
 
 end
 function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end
 
 //self:AdjustMarineBuildSpeed()
 /*
  if Client then
  Sabot.SendChatMessage("/help")
   end
   */

/*
self:NotifyCredits( Client, "Hi! Welcome To Siege! Around here, we run a custom Plugin titled Credits. ", true )
self:NotifyCredits( Client, "What Are Credits? Credits are points that allow you to purchase in game items, in return for playing Siege!", true )
self:NotifyCredits( Client, "It's simple, really. 10 in game score = 1 credit. You earn score by killing enemies, building structures, basically playing the game", true )
self:NotifyCredits( Client, "At the end of each round, there's a credit bonus based on how well your team performed.. and sometimes there's double credit weekends.", true )
self:NotifyCredits( Client, "To spend credits, press M and click Cerdits, or bind a key to sh_buy <item> - This message will go away once you start spending! Thanks & Enjoy Siege :D", true )
*/

  if GetGamerules():GetGameStarted() then

  Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.85,Text = string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Client )
    self.PlayerSpentAmount[Client] = 0
    
end
    
 end
function Plugin:SetGameState( Gamerules, State, OldState )
       if State == kGameState.Countdown then
      
        self.GameStarted = true
        self.Refunded = false
              Shine.ScreenText.End(80)
              Shine.ScreenText.End(81)  
              Shine.ScreenText.End(82)  
              Shine.ScreenText.End(83)  
              Shine.ScreenText.End(84)  
              Shine.ScreenText.End(85)  
              Shine.ScreenText.End(86)
              Shine.ScreenText.End(87)  
          Shine.ScreenText.End("Credits")    
              self.marinebonus = 0
              self.alienbonus = 0
              self.MarineTotalSpent = 0
              self.AlienTotalSpent = 0
              self.PlayerSpentAmount = {}
              
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self.PlayerSpentAmount[Player:GetClient()] = 0
                  //Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.95,Text = "Loading Credits...",Duration = 1800,R = 255, G = 0, B = 0,Alignment = 0,Size = 3,FadeIn = 0,}, Player )
                  Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.95,Text = string.format( "%s Credits", self:GetPlayerCreditsInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
              
      end        
              
     if State == kGameState.Team1Won or State == kGameState.Team2Won or State == kGameState.Draw then
     
      self.GameStarted = false

          
        self:SimpleTimer(4, function ()
        self:SaveCredits(player:GetClient())
        end)

       self:SimpleTimer(3, function ()
       
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self:SaveCredits(Player:GetClient())
                     if Player:GetTeamNumber() == 1 or Player:GetTeamNumber() == 2 then
                    Shine.ScreenText.Add( 80, {X = 0.40, Y = 0.15,Text = "Total Credits Earned:".. math.round((Player:GetScore() / 10 + ConditionalValue(Player:GetTeamNumber() == 1, self.marinebonus, self.alienbonus)), 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                    Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.20,Text = "Total Credits Spent:".. self.PlayerSpentAmount[Player:GetClient()], Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                     end
                  end
             end
      end)
    //  self:SimpleTimer(3, function ()    
    //  Shine.ScreenText.Add( 82, {X = 0.40, Y = 0.10,Text = "End of round Stats:",Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    // Shine.ScreenText.Add( 83, {X = 0.40, Y = 0.25,Text = "(Server Wide)Total Credits Earned:".. math.round((self.marinecredits + self.aliencredits), 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 84, {X = 0.40, Y = 0.25,Text = "(Marine)Total Credits Earned:".. math.round(self.marinecredits, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 85, {X = 0.40, Y = 0.30,Text = "(Alien)Total Credits Earned:".. math.round(self.aliencredits, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 86, {X = 0.40, Y = 0.35,Text = "(Marine)Total Credits Spent:".. math.round(self.MarineTotalSpent, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 87, {X = 0.40, Y = 0.40,Text = "(Alien)Total Credits Spent:".. math.round(self.AlienTotalSpent, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
  //    end)
  end
     
end

function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyLerkLift( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Lerk Lift]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyMarine( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[Credits]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyAlien( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[Credits]", 144, 238, 144, String, Format, ... )
end
function Plugin:NotifyCredits( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Credits]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyBuy( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[NS2Siege]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end

function Plugin:CreateCommands()

local function Credits(Client, Targets)
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self:NotifyCredits( Client, "%s has a total of %s credits", true, Player:GetName(), self:GetPlayerCreditsInfo(Player:GetClient()))
end
end

local CreditsCommand = self:BindCommand("sh_credits", "credits", Credits, true, false)
CreditsCommand:Help("sh_credits <name>")
CreditsCommand:AddParam{ Type = "clients" }

local function AddCredits(Client, Targets, Number, Display)
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self.CreditUsers[ Player:GetClient() ] = self:GetPlayerCreditsInfo(Player:GetClient()) + Number
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Player:GetClient()) ), Player:GetClient()) 
   if Display == true then
   self:NotifyGeneric( nil, "gave %s credits to %s (who now has a total of %s)", true, Number, Player:GetName(), self:GetPlayerCreditsInfo(Player:GetClient()))
   end
end
end

local AddCreditsCommand = self:BindCommand("sh_addcredits", "addcredits", AddCredits)
AddCreditsCommand:Help("sh_addcredits <player> <number>")
AddCreditsCommand:AddParam{ Type = "clients" }
AddCreditsCommand:AddParam{ Type = "number" }
AddCreditsCommand:AddParam{ Type = "boolean", Optional = true, Default = true }
end