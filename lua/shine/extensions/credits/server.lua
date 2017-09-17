/*Kyle 'Avoca' Abent Credits Season 4
KyleAbent@gmail.com 
*/

Script.Load("lua/Additions/CreditMixin.lua")
local Shine = Shine
local Plugin = Plugin
local HTTPRequest = Shared.SendHTTPRequest
local TableInsertUnique = table.InsertUnique



Plugin.HasConfig = true
Plugin.ConfigName = "CreditsConfig.json"

Plugin.DefaultConfig  = { kCreditMultiplier = 1, kCreditsCapPerRound = 200 }

Shine.CreditData = {}
Shine.BadgeData = {}
Shine.LinkFile = {}
Shine.BadgeFile = {}
Plugin.Version = "911"

local CreditsPath = "config://shine/plugins/credits.json"
local URLPath = "config://shine/CreditsLink.json"
--local BadgeURLPath = "config://shine/BadgesLink.json"
local BadgesPath = "config://shine/UserConfig.json"


Shine.Hook.SetupClassHook( "ScoringMixin", "AddScore", "OnScore", "PassivePost" )

Shine.Hook.SetupClassHook( "OnoGrow", "OnoEggFilled", "OnOnEggFilled", "PassivePost" )

Shine.Hook.SetupClassHook( "NS2Gamerules", "ResetGame", "OnReset", "PassivePost" )

Shine.Hook.SetupClassHook( "DoConcedeSequence", "OnConcede", "SaveAllCredits", "pre" )

Shine.Hook.SetupClassHook( "Player", "CopyPlayerDataFrom", "EnsureBeteenSpawn", "PassivePost" )

function Plugin:EnsureBeteenSpawn(player, origin, angles, mapName)
 --if not player:isa("Marine") or not player:isa("Alien") then return end
 local client = player:GetClient()
 if not client then return end
 local controlling = client:GetControllingPlayer()
 --local size = self.playersize[controlling:GetClient()]
 local Time = Shared.GetTime()
 local Glow = self.GlowClientsTime[controlling:GetClient()]

           if Glow and Glow > Time then   
           local color = self.GlowClientsColor[controlling:GetClient()]
                 color = Clamp(tonumber(color), 1, 4)
                  player:GlowColor(color, Glow - Time)    
                end

end
function Plugin:OnoEggFilled(player)
  self:NotifyCredit( player:GetClient(), "You farted.", true )
end

function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
self.GameStarted = false
self.CreditAmount = 0
self.CreditUsers = {}
self.BuyUsersTimer = {}
self.marinecredits = 0
self.aliencredits = 0
self.marinebonus = 0
self.alienbonus = 0
self.CredityPlayers = {} --To toggle spending between pres and credit in an easy way....
self.UserStartOfRoundCredits = {}
self.MarineTotalSpent = 0
self.AlienTotalSpent = 0
self.Refunded = false

self.PlayerSpentAmount = {}

self.ShadeInkCoolDown = 0

self.GlowClientsTime = {}
self.GlowClientsColor = {} -- 2 tables rather than 1, i know.

return true
end


function Plugin:BecauseFuckSpammingCommanders(player)
if not GetGamerules():GetGameStarted() then return end
local CreditCost = 10
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
if  player:GetResources() < CreditCost then
self:NotifyCredit( Client, "%s costs %s pres, you have %s pres. Purchase invalid.", true, String, CreditCost, player:GetResources() )
return
end
player:SetResources( player:GetResources() - CreditCost)
--self.CreditUsers[ Client ] = self:GetPlayerCreditInfo(Client) - CreditCost
//self:NotifyCredit( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
player:GiveItem(NutrientMist.kMapName)
  -- Shine.ScreenText.SetText("Credit", string.format( "%s Credit", self:GetPlayerCreditInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 3 
     self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
return
end

     
function Plugin:GenereateTotalCreditAmount()
local credit = 0


    for variant, data in pairs(self.CreditData.Users) do
       credit = credit + self.CreditData.Users[variant].credits
    end
    local count = table.Count(self.CreditData.Users)

   self:NotifyGeneric( nil, "Credit Stats: %s users and %s Credit", true, count, credit )
   
end

function Plugin:AdjustCredit()
local credits = 0
Print("%s users", table.Count(self.CreditData.Users))

    for variant, data in pairs(self.CreditData.Users) do
       self.CreditData.Users[variant].credits = self.CreditData.Users[variant].credits * 10
       credits = credits + self.CreditData.Users[variant].credits
    end
    self:SaveAllCredits(false)
Print("%s credit",credits)
end


local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end

function Plugin:HasLimitOfCragInHive(Player, mapname, teamnumbber, limit, Client)
--3 crag outside of hive and 5 inside hive
local entitycount = 0
local entities = {}
if limitMod == true then limit = 8 end
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", teamnumbber)) do
        if entity:GetMapName() == mapname and entity:GetOwner() == Player and GetIsOriginInHiveRoom( entity:GetOrigin() ) then entitycount = entitycount + 1 table.insert(entities, entity) end 
    end
    
     //             <
    if entitycount ~= limit then return false end
     return true
end
function Plugin:HasLimitOfCragOutHive(Player, mapname, teamnumbber, limit, Client)
local entitycount = 0
local entities = {}
if limitMod == true then limit = 8 end
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", teamnumbber)) do
        if entity:GetMapName() == mapname and entity:GetOwner() == Player and not GetIsOriginInHiveRoom( entity:GetOrigin() )  then entitycount = entitycount + 1 table.insert(entities, entity) end 
    end
    
     //             <
    if entitycount ~= limit then return false end
     return true
end

function Plugin:HasLimitOf(Player, mapname, teamnumbber, limit, Client)

local entitycount = 0
local entities = {}
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", teamnumbber)) do
        if entity:GetMapName() == mapname and entity:GetOwner() == Player then entitycount = entitycount + 1 table.insert(entities, entity) end 
    end
    

   local delete = true --GetSetupConcluded()
      if delete then
            if #entities >= limit then
            local entity = table.random(entities)
             if mapname == Sentry.kMapName or entity:GetMapName() == Wall.kMapName or entity:GetMapName() == Observatory.kMapName or entity:GetMapName() == ARC.kMapName  then return true end
                DestroyEntity(entity)
                 self:NotifyCredit( Client, "(Logic Fallacy, Limit Reached):Deleted your old %s so you can spawn a new one.", true, mapname)
                 return false  
            end
      end
      
      if mapname == Sentry.kMapName then
          if not GetCheckSentryLimit(techId, Player:GetOrigin(), normal, commander) then
                 self:NotifyCredit( Client, "(Logic Fallacy):%s Sentrys are allowed per location.", true, Credit)
                 return  false
          end
      end
      
     return entitycount >= limit
end
function Plugin:PregameLimit(teamnum)
local entitycount = 0
local entities = {}
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", teamnum)) do
       entitycount = entitycount + 1  
    end
       if entitycount <= 99 then return false end
       return false --EH?
end

local function AddOneScore(Player,Points,Res, WasKill)
            local points = Points
            local wasKill = WasKill
            local displayRes = ConditionalValue(type(res) == "number", res, 0)
            Server.SendNetworkMessage(Server.GetOwner(Player), "ScoreUpdate", { points = points, res = displayRes, wasKill = wasKill == true }, true)
            Player.score = Clamp(Player.score + points, 0, 100)

            if not Player.scoreGainedCurrentLife then
                Player.scoreGainedCurrentLife = 0
            end

            Player.scoreGainedCurrentLife = Player.scoreGainedCurrentLife + points   

end

/*
function Plugin:PrimalScreamPointBonus(who, Points)
  local lerk = Shared.GetEntity( who.primaledID ) 
  if lerk ~= nil then
      local client = lerk.getClient and lerk:GetClient()
      if client then 
        local player = client:GetControllingPlayer()
         if player then
          player:AddScore(Points * 0.3)
          end
      end
  end
end
*/

function Plugin:OnScore( Player, Points, Res, WasKill )
if Points ~= nil and Points ~= 0 and Player and not Shared.GetCheatsEnabled() then
   --if not self.GameStarted then Points = 1  AddOneScore(Player,Points,Res, WasKill) end
  --if WasKill and Player:isa("Alien") then self:PrimalScreamPointBonus(Player, Points) end
 local client = Player:GetClient()
 if not client then return end
         
    local addamount = Points * 0.10     
 local controlling = client:GetControllingPlayer()
 
         if Player:GetTeamNumber() == 1 then
         self.marinecredits = self.marinecredits + addamount 
        elseif Player:GetTeamNumber() == 2 then
         self.aliencredits = self.aliencredits + addamount 
         end
         
self.CreditUsers[ controlling:GetClient() ] = self:GetPlayerCreditInfo(controlling:GetClient()) + addamount
Shine.ScreenText.SetText("Credit", string.format( "%s Credit", self:GetPlayerCreditInfo(controlling:GetClient()) ), controlling:GetClient()) 
end
end
function Plugin:NotifySiege( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Siege]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end




function Plugin:OnReset()
  if self.GameStarted and not self.Refunded then
       self:NotifyCredit( nil, "Did you spend any credits only for the round to reset? If so, then no worries! - You have just been refunded!", true )
       
              Shine.ScreenText.End("Credit")  
              Shine.ScreenText.End(80)
              Shine.ScreenText.End(81)  
              Shine.ScreenText.End(82)  
              Shine.ScreenText.End(83)  
              Shine.ScreenText.End(84)  
              Shine.ScreenText.End(85)  
              Shine.ScreenText.End(86)   
              Shine.ScreenText.End(87)  
              self.marinecredits = 0
              self.aliencredits = 0
              self.marinebonus = 0
              self.alienbonus = 0
              self.MarineTotalSpent = 0 
              self.AlienTotalSpent = 0
              self.CreditUsers = {}
              self.PlayerSpentAmount = {}
          
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  Shine.ScreenText.Add( "Credit", {X = 0.20, Y = 0.95,Text = string.format( "%s Credit", self:GetPlayerCreditInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
    self.Refunded = true
   end     
end

function Plugin:OnFirstThink() 
local CreditsFile = Shine.LoadJSONFile( CreditsPath )
self.CreditData = CreditsFile

local BadgeFile = Shine.LoadJSONFile( BadgesPath )
self.BadgeData = BadgeFile

end

 local function GetCreditsToSave(self, Client, savedamount)
            local cap = self.Config.kCreditsCapPerRound 
          local creditstosave = self:GetPlayerCreditInfo(Client)
          local earnedamount = creditstosave - savedamount
          if earnedamount > cap then 
          creditstosave = savedamount + cap
          self:NotifyCredit( Client, "%s Credit cap per round exceeded. You earned %s Credit this round. Only %s are saved. So your new total is %s", true, self.Config.kCreditsCapPerRound, earnedamount, self.Config.kCreditsCapPerRound, creditstosave )
          Shine.ScreenText.SetText("Credit", string.format( "%s Credit", creditstosave ), Client) 
           end
    return creditstosave
 end
function Plugin:SaveCredits(Client, disconnected)
       local Data = self:GetCreditData( Client )
       if Data and Data.credits then 
         if not Data.name or Data.name ~= Client:GetControllingPlayer():GetName() then
           Data.name = Client:GetControllingPlayer():GetName()
           end        
       Data.credits = GetCreditsToSave(self, Client, Data.credits)
       else 
      self.CreditData.Users[Client:GetUserId() ] = {credits = self:GetPlayerCreditInfo(Client), name = Client:GetControllingPlayer():GetName() }
       end
     if disconnected == true then Shine.SaveJSONFile( self.CreditData, CreditsPath  ) end
end

function Plugin:JoinTeam( Gamerules, Player, NewTeam, Force ) 

    if not Player:isa("Commander") and Gamerules:GetGameStarted() and NewTeam == 0 then
     self:DestroyAllCreditStructFor(Player:GetClient())
    end

end

function Plugin:DestroyAllCreditStructFor(Client)
//Intention: Kill Credit Structures if client f4s, otherwise 'limit' becomes nil and infinite 
local Player = Client:GetControllingPlayer()
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Credit", Player:GetTeamNumber())) do
        if entity:GetIsACreditStructure() and not entity:isa("Commander") and not entity:isa("AdvancedArmory") and not (entity.GetIsResearching and entity:GetIsResearching() ) and entity:GetOwner() == Player then entity:Kill() end 
      end
    
end
function Plugin:ClientDisconnect(Client)
self:SaveCredits(Client, true)
self:DestroyAllCreditStructFor(Client)
end
function Plugin:GetPlayerCreditInfo(Client)
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
  function Plugin:GetBadgeData(Client)
  if not self.BadgeData then return nil end
  if not self.BadgeData.Users then return nil end
  local ID = GetIDFromClient( Client )
  if not ID then return nil end
  local User = self.BadgeData.Users[ tostring( ID ) ] 
  if not User then 
     local SteamID = Shine.NS2ToSteamID( ID )
     User = self.BadgeData.Users[ SteamID ]
     if User then
     return User, SteamID
     end
     local Steam3ID = Shine.NS2ToSteam3ID( ID )
     User = self.BadgeData.Users[ ID ]
     if User then
     return User, Steam3ID
     end
     return nil, ID
   end
return User, ID
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

 function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end
 
  Shine.ScreenText.Add( "Credit", {X = 0.20, Y = 0.85,Text = string.format( "%s Credit", self:GetPlayerCreditInfo(Client) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Client )
    self.PlayerSpentAmount[Client] = 0
    
    
 end
function Plugin:SaveAllCredits()
               local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self:SaveCredits(Player:GetClient(), false)
                  end
             end
         /*                 
            local LinkFiley = Shine.LoadJSONFile( URLPath )
            self.LinkFile = LinkFiley                
                 self:SimpleTimer( 2, function() 
                 Shine.SaveJSONFile( self.CreditData, CreditsPath  )
                 end)
                             
                 self:SimpleTimer( 4, function() 
                 HTTPRequest( self.LinkFile.LinkToUpload, "POST", {data = json.encode(self.CreditData)})
                 end)
                 
               --  self:SimpleTimer( 12, function() 
               --  self:LoadBadges()
               --  end)
               
            
                 self:SimpleTimer( 14, function() 
                 self:NotifyCredit( nil, "http://credits.ns2siege.com - credit ranking updated", true)
                 end)        
               */  

end
function Plugin:DeductCreditIfNotPregame(self, who, amount, delayafter, isCredit)
        --Print("DeductCreditIfNotPregame, amount is %s", amount)
 if ( GetGamerules():GetGameStarted() and not GetGamerules():GetCountingDown() )  then
     if isCredit == true then
         Print("Cost is %s", amount)
        -- amount = amount * kPrestoCreditMul
        -- Print("Cost is %s", amount)
         self.CreditUsers[ who:GetClient() ] = self:GetPlayerCreditInfo(who:GetClient()) - amount
         self.PlayerSpentAmount[who:GetClient()] = self.PlayerSpentAmount[who:GetClient()]  + amount
         Shine.ScreenText.SetText("Credit", string.format( "%s Credit", self:GetPlayerCreditInfo(who:GetClient()) ), who) 
    else
         who:SetResources( who:GetResources() - amount )
    end
   self.BuyUsersTimer[who:GetClient()] = Shared.GetTime() + delayafter
 else
 self:NotifyCredit(who, "Pregame purchase free of charge", true) 
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
          Shine.ScreenText.End("Credit")    
              self.marinecredits = 0
              self.aliencredits = 0
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
                  Shine.ScreenText.Add( "Credit", {X = 0.20, Y = 0.95,Text = string.format( "%s Credit", self:GetPlayerCreditInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
              
      end        
              
     if State == kGameState.Team1Won or State == kGameState.Team2Won or State == kGameState.Draw then
     
      self.GameStarted = false
          
                 self:SimpleTimer(4, function ()
       
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                 // self:SaveCredits(Player:GetClient())
                     if Player:GetTeamNumber() == 1 or Player:GetTeamNumber() == 2 then
                    Shine.ScreenText.Add( 80, {X = 0.40, Y = 0.15,Text = "Total Credit Mined:".. math.round((Player:GetScore()  + ConditionalValue(Player:GetTeamNumber() == 1, self.marinebonus, self.alienbonus)), 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                    Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.20,Text = "Total Credit Spent:".. self.PlayerSpentAmount[Player:GetClient()], Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                     end
                  end
             end
      end)
      
      
            self:SimpleTimer( 8, function() 
       local LinkFiley = Shine.LoadJSONFile( URLPath )
        self.LinkFile = LinkFiley
            self:SaveAllCredits()
            end)
            
            
           //   local Time = Shared.GetTime()
          //   if not Time > kMaxServerAgeBeforeMapChange then
                 self:SimpleTimer( 25, function() 
               --  self:LoadBadges()
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
function Plugin:NotifyCredit( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Credit]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyPres( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Pres]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyCreditDC( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Double Credit Weekend]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
 function Plugin:TunnelExistsNearHiveFor(who)
  self:NotifyCredit( who:GetClient(), "You already have a tunnelentrance at hive, you derp! YOU MADE ME TYPE THIS STATEMENT 4 U!", true)
end
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end
local function GetIsAlienInSiege(Player)
   if  Player.GetLocationName and 
   string.find(Player:GetLocationName(), "siege") or string.find(Player:GetLocationName(), "Siege") then
   return true
    end
    return false
 end
local function PerformBuy(self, who, String, whoagain, cost, reqlimit, reqground,reqpathing, setowner, delayafter, mapname,limitof, techid, isCredit)
   local autobuild = false 
   local success = false
   --Print(" PerformBuy isCredit is %s", isCredit)
if whoagain:GetHasLayStructure() then 
self:NotifyCredit(who, "Empty hudslot 5 please.", true)
return
end

 
if whoagain:isa("Alien") and mapname == Crag.kMapName then 


   if  GetIsOriginInHiveRoom( whoagain:GetOrigin() ) then
     limitof = 5 
if self:HasLimitOfCragInHive(whoagain, mapname, whoagain:GetTeamNumber(), limitof, who) then 
self:NotifyCredit(who, "Limit of %s %s inside hive room.", true, limitof, mapname)
return
end
    end
limitof = 8

if self:HasLimitOfCragOutHive(whoagain, mapname, whoagain:GetTeamNumber(), limitof, who) then 
self:NotifyCredit(who, "Limit of %s %s outside hive room.", true, limitof, mapname)
return
end

else

if self:HasLimitOf(whoagain, mapname, whoagain:GetTeamNumber(), limitof, who) then 
self:NotifyCredit(who, "Limit of %s per %s per player ya noob", true, limitof, mapname)
return
end

end

if reqground then

if not whoagain:GetIsOnGround() then
 self:NotifyCredit( who, "You must be on the ground to purchase %s", true, mapname)
 return
 end
 
 end
 
 if reqpathing then 
 if not GetPathingRequirementsMet(Vector( whoagain:GetOrigin() ),  GetExtents(kTechId.MAC) ) then
self:NotifyCredit( who, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
 end
 

self:DeductCreditIfNotPregame(self, whoagain, cost, delayafter, isCredit)


local entity = nil 

         if not whoagain:isa("Exo") and ( mapname ~= NutrientMist.kMapName and mapname ~= EnzymeCloud.kMapName 
         and mapname ~= HallucinationCloud.kMapName   and mapname ~= MucousMembrane.kMapName  ) then 
          whoagain:GiveLayStructure(techid, mapname)
        else
           entity = CreateEntity(mapname, FindFreeSpace(whoagain:GetOrigin(), 1, 4), whoagain:GetTeamNumber()) 
           if entity.SetOwner then entity:SetOwner(whoagain) end
          if entity.SetConstructionComplete then  entity:SetConstructionComplete() end
             
             
        end


if entity then 
local supply = LookupTechData(entity:GetTechId(), kTechDataSupply, nil) or 0
whoagain:GetTeam():RemoveSupplyUsed(supply)
end
   local delaytoadd = delayafter
  -- Shine.ScreenText.SetText("Credit", string.format( "%s Credit", self:GetPlayerCreditInfo(who) ), who) 
self.BuyUsersTimer[who] = Shared.GetTime() + delaytoadd
--Shared.ConsoleCommand(string.format("sh_addpool %s", cost)) 
  



end
local function FirstCheckRulesHere(self, Client, Player, String, cost, isastructure, isCredit)
local Time = Shared.GetTime()
local NextUse = self.BuyUsersTimer[Client]
if NextUse and NextUse > Time and not Shared.GetCheatsEnabled() then
self:NotifyCredit( Client, "Please wait %s seconds before purchasing %s. Thanks.", true, string.TimeToString( NextUse - Time ), String)
return true
end
   if isastructure then 
if ( not GetGamerules():GetGameStarted() and self:PregameLimit(Player:GetTeamNumber()) ) then
self:NotifyCredit( Client, "live count reached for pregame", true)
return true
end

end


/*
local gameRules = GetGamerules()
if gameRules:GetGameStarted() and gameRules:GetIsSuddenDeath() then
self:NotifyCredit( Client, "Buying in suddendeath is not supported right now.", true)
return
end
*/
if Player:isa("Commander") or not Player:GetIsAlive() then 
      self:NotifyCredit( Client, "Either you're dead, or a commander... Really no difference between the two.. anyway, no credit spending for you.", true)
return true
end

/*
if Player then
 self:NotifyCredit( Client, "Purchases currently disabled. ", true)
 return
end
*/

if ( GetGamerules():GetGameStarted() and not GetGamerules():GetCountingDown()  )  then  

    if isCredit and self:GetPlayerCreditInfo(Player:GetClient()) < cost  then 
   self:NotifyCredit( Client, "%s costs %s Credit, you have %s Credit. Purchase invalid.", true, String, cost, self:GetPlayerCreditInfo(Player:GetClient()) )
    return true
    end
    
 if not isCredit and Player:GetResources() < cost then 
   --Print("player has %s, cost is %s", playeramt,cost)
self:NotifyPres( Client, "%s costs %s pres, you have %s pres. Purchase invalid.", true, String, cost, Player:GetResources() )
return true
end

end

end



local function DeductBuy(self, who, cost, delayafter, isCredit)
  return self:DeductCreditIfNotPregame(self, who, cost, delayafter, isCredit)
end


local function TeamOneBuyRules(self, Client, Player, String, isCredit)

local mapnameof = nil
local delay = 12
local reqpathing = false
local CreditCost = 10
local reqground = false
local limit = 3
local techid = nil

if String == "Scan" then
mapnameof = Scan.kMapName
techid = kTechId.Scan
delay = 10
CreditCost = gCreditAbilityCostScan
elseif String == "Medpack" then
mapnameof = MedPack.kMapName
techid = kTechId.MedPack
CreditCost = gCreditAbilityCostMedpack
delay = 10
elseif String == "Observatory"  then
mapnameof = Observatory.kMapName
techid = kTechId.Observatory
CreditCost = gCreditStructureObservatoryCost
elseif String == "Armory"  then
CreditCost = gCreditStructureArmoryCost
mapnameof = Armory.kMapName
techid = kTechId.Armory
--elseif String == "Wall"  then
--CreditCost = gCreditStructureWallCost
--mapnameof = Wall.kMapName
--techid = kTechId.Wall
--limit = gCreditStructureWallLimit
elseif String == "Sentry"  then
mapnameof = Sentry.kMapName
techid = kTechId.Sentry
limit = gCreditStructureSentryLimit
CreditCost = gCreditStructureSentryCost
elseif String == "BackupBattery"  then
mapnameof = SentryBattery.kMapName
techid = kTechId.SentryBattery
limit = gCreditStructureBackUpBatteryLimit
CreditCost = gCreditStructureBackUpBatteryCost
elseif String == "BackupLight"  then
mapnameof = BackupLight.kMapName
techid = kTechId.BackupLight
limit = gCreditStructureBackupLightLimit
CreditCost = gCreditStructureBackupLightCost
elseif String == "PhaseGate" then
CreditCost = gCreditStructurePhaseGateCost
limit = gCreditStructurePhaseGateLimit
mapnameof = PhaseGate.kMapName
techid = kTechId.PhaseGate
elseif String == "InfantryPortal" then
mapnameof = InfantryPortal.kMapName
techid = kTechId.InfantryPortal
CreditCost = gCreditStructureInfantryPortalCost
limit = gCreditStructureInfantryPortalLimit
elseif  String == "RoboticsFactory" then
mapnameof = RoboticsFactory.kMapName
techid = kTechId.RoboticsFactory
CreditCost = gCreditStructureRoboticsFactoryCost
limit = gCreditStructureRoboticsFactoryLimit
elseif String == "Mac" then
techid = kTechId.MAC
CreditCost = gCreditStructureMacCost
mapnameof = MACCredit.kMapName --can be networkvar instead
limit = gCreditStructureMacLimit
elseif String == "Arc" then 
techid = kTechId.ARC
CreditCost = gCreditStructureArcCost
mapnameof = ARC.kMapName --can be networkvar instead
limit = gCreditStructureArcLimit
elseif String == "Extractor" then 
techid = kTechId.Extractor
CreditCost = gCreditStructureExtractorCost
mapnameof = Extractor.kMapName
limit = gCreditStructureExtractorLimit
elseif string == nil then
end
return mapnameof, delay, reqground, reqpathing, CreditCost, limit, techid

end

local function TeamTwoBuyRules(self, Client, Player, String, isCredit)

local mapnameof = nil
local delay = 12
local reqpathing = false
local reqground = false
local CreditCost = 20
local limit = 3
local techid = nil


if String == "NutrientMist" then 
CreditCost = gCreditAbilityCostNutrientMist
mapnameof = NutrientMist.kMapName
reqground = true
delay = gCreditAbilityDelayNutrientMist
elseif String == "Contamination"  then
CreditCost = gCreditAbilityCostContamination
delay = gCreditAbilityDelayContamination
mapnameof = Contamination.kMapName    
techid = kTechId.Contamination
elseif String == "Mucous" then
CreditCost = gCreditAbilityCostMucous
mapnameof = MucousMembrane.kMapName
delay = gCreditAbilityDelayEnzymeCloud
elseif String == "EnzymeCloud" then
CreditCost = gCreditAbilityCostEnzymeCloud
mapnameof = EnzymeCloud.kMapName
delay = gCreditAbilityDelayEnzymeCloud
elseif String == "Hallucination" then
CreditCost =gCreditAbilityCostHallucination  
delay = gCreditAbilityDelayHallucination
reqpathing = false
 mapnameof = HallucinationCloud.kMapName
elseif String == "Shade" then
CreditCost = gCreditStructureCostShade
mapnameof = Shade.kMapName
techid = kTechId.Shade
delay = gCreditStructureDelayShade
elseif String == "Crag" then
CreditCost = gCreditStructureCostCrag
mapnameof = Crag.kMapName
techid = kTechId.Crag
delay = gCreditStructureDelayCrag
elseif String == "Whip" then
CreditCost = gCreditStructureCostWhip
mapnameof = Whip.kMapName
techid = kTechId.Whip
delay = gCreditStructureDelayWhip
elseif String == "Shift" then
CreditCost = gCreditStructureCostShift
mapnameof = Shift.kMapName
techid = kTechId.Shift
delay = gCreditStructureDelayShift
elseif String == "EggBeacon" then
CreditCost = 25
mapnameof = EggBeacon.kMapName
techid = kTechId.EggBeacon
delay = gCreditStructureDelayShift
elseif String == "StructureBeacon" then
CreditCost = 25
mapnameof = StructureBeacon.kMapName
techid = kTechId.StructureBeacon
delay = gCreditStructureDelayShift
elseif String == "Hydra" then
CreditCost = gCreditStructureCostHydra
mapnameof = Hydra.kMapName
techid = kTechId.Hydra
delay = gCreditStructureDelayHydra
elseif String == "CredityEgg" then
CreditCost = gCreditStructureCostCredityEgg
mapnameof = PoopEgg.kMapName
techid = kTechId.Egg
limit = 4
delay = gCreditStructureDelayCredityEgg
--elseif String == "PetDrifter" then
elseif String == "Drifter" then
CreditCost = gCreditStructureCostPetDrifter
mapnameof = Drifter.kMapName
techid = kTechId.Drifter
limit = 2
delay = 4
elseif String == "Harvester" then
CreditCost = gCreditStructureCostHarvesterExtractor
mapnameof = Harvester.kMapName
techid = kTechId.Harvester
limit = gCreditStructureLimitHarvesterExtractor
end
return mapnameof, delay, reqground, reqpathing, CreditCost, limit, techid

end
local function DeductBuy(self, who, cost, delayafter, isCredit)
  return self:DeductCreditIfNotPregame(self, who, cost, delayafter, isCredit)
end


function Plugin:CreateCommands()


local function TBuy(Client, String, StringTwo)
local Player = Client:GetControllingPlayer()
local mapname = nil
local delayafter = 60
local cost = 1
if not Player then return end
local isCredit = StringTwo == "Credit"

 
local Time = Shared.GetTime()
local NextUse = self.ShadeInkCoolDown
Print("NextUse is %s", NextUse)
if NextUse and NextUse > Time and not Shared.GetCheatsEnabled() then
self:NotifyCredit( Client, "Team Cooldown on Ink: %s", true, string.TimeToString( NextUse - Time ), String)
return true
end

   

 
    if String  == "Ink" then cost = 1.5 mapname = ShadeInk.kMapName
   end
   
    if FirstCheckRulesHere(self, Client, Player, String, cost, false, isCredit ) == true then return end
   
      self:DeductCreditIfNotPregame(self, Player, cost, 8, isCredit)


 
  Player:GiveItem(mapname)
   
   self.ShadeInkCoolDown = Shared.GetTime() + delayafter
   
end

local TBuyCommand = self:BindCommand("sh_tbuy", "tbuy", TBuy, true)
TBuyCommand:Help("sh_tbuy <team buy string>")
TBuyCommand:AddParam{ Type = "string" }
TBuyCommand:AddParam{ Type = "string", Optional = true }


local function BuyWP(Client, String, StringTwo)
local Player = Client:GetControllingPlayer()
local mapname = nil
local delayafter = 8 
local cost = 1
if not Player then return end
local isCredit = StringTwo == "credit"
 

   

 
    if String  == "Mines" then cost = gCreditWeaponCostMines mapname = LayMines.kMapName
   elseif String == "Welder" then cost = gCreditWeaponCostWelder mapname = Welder.kMapName
   elseif String == "HeavyMachineGun" then cost = gCreditWeaponCostHMG mapname = HeavyMachineGun.kMapName
   elseif String == "HeavyRifle" then cost = gCreditWeaponCostHeavyRifle mapname = HeavyRifle.kMapName
    elseif String  == "Shotgun" then cost = gCreditWeaponCostShotGun mapname = Shotgun.kMapName 
   elseif String == "FlameThrower" then  cost = gCreditWeaponCostFlameThrower mapname = Flamethrower.kMapName 
   elseif String == "GrenadeLauncher" then  cost = gCreditWeaponCostGrenadeLauncher mapname = GrenadeLauncher.kMapName 
   elseif String == "clustergrenade" then cost = gCreditWeaponCostGrenadeCluster mapname =   ClusterGrenadeThrower.kMapName
   elseif String == "pulseGrenade" then cost = gCreditWeaponCostGrenadePulse mapname =   PulseGrenadeThrower.kMapName
   elseif String == "gasgrenade" then cost = gCreditWeaponCostGrenadeGas mapname =   GasGrenadeThrower.kMapName
   end
   
    if FirstCheckRulesHere(self, Client, Player, String, cost, false, isCredit ) == true then return end
    
     self:DeductCreditIfNotPregame(self, Player, cost, delayafter, isCredit)

 
  Player:GiveItem(mapname)
   
end



local BuyWPCommand = self:BindCommand("sh_buywp", "buywp", BuyWP, true)
BuyWPCommand:Help("sh_buywp <weapon name>")
BuyWPCommand:AddParam{ Type = "string" }
BuyWPCommand:AddParam{ Type = "string", Optional = true }


local function BuyCustom(Client, String, StringTwo)
local Player = Client:GetControllingPlayer()
local cost = 40
local delayafter = 8
local isCredit = StringTwo == "credit"
 if FirstCheckRulesHere(self, Client, Player, String, cost, false, isCredit) == true then return end
      local exit, nearhive, count = FindPlayerTunnels(Player)
              if not exit then
              --  Print("No Exit Found!")
             elseif nearhive or ( nearhive and count == 2) then
            -- Print("Tunnel nearhive already exists.")
               self:TunnelExistsNearHiveFor(Player)
             return
             end
     if String == "TunnelEntrance" and Player:isa("Gorge") then
       GorgeWantsEasyEntrance(Player, exit, nearhive)
       DeductBuy(self, Player, cost, delayafter, isCredit)
     end
end

local function LowBlow(Player, mapname)
                  local newPlayer = Player:Replace(mapname, Player:GetTeamNumber(), nil, nil, extraValues)
                  if newPlayer.lastUpgradeList then
                    newPlayer.upgrade1 = newPlayer.lastUpgradeList[1] or 1
                    newPlayer.upgrade2 = newPlayer.lastUpgradeList[2] or 1
                    newPlayer.upgrade3 = newPlayer.lastUpgradeList[3] or 1
                   end

end
local BuyCustomCommand = self:BindCommand("sh_buycustom", "buycustom", BuyCustom, true)
BuyCustomCommand:Help("sh_buycustom <custom function> because I want these fine tuned accordingly")
BuyCustomCommand:AddParam{ Type = "string" }
BuyCustomCommand:AddParam{ Type = "string", Optional = true }

local function BuyClass(Client, String, StringTwo, StringThree)

local Player = Client:GetControllingPlayer()
local delayafter = 8 
local cost = 1
local isCredit =  StringTwo == "credit"
local isFast = StringThree == "fast"

if not Player then return end

 if String == "JetPack" and not Player:isa("Exo") and not Player:isa("JetPack") then cost = gCreditClassCostJetPack 
  elseif String == "RailGun" and not Player:isa("Exo") then cost = gCreditClassCostRailGunExo delayafter = gCreditClassDelayRailGun   
  elseif String == "MiniGun" and not Player:isa("Exo") then  cost = gCreditClassCostMiniGunExo  delayafter = gCreditClassDelayRailGun 
  elseif String == "Welder" and not Player:isa("Exo") then  cost = gCreditClassCostWelderExo  delayafter = gCreditClassDelayRailGun 
   elseif String == "Flamer" and not Player:isa("Exo") then  cost = gCreditClassCostFlamerExo delayafter = gCreditClassDelayRailGun 
  elseif String == "Gorge" then cost = gCreditClassCostGorge delayafter = gCreditClassDelayGorge delayafter = 8 
  elseif String == "Lerk" then   cost = gCreditClassCostLerk delayafter = gCreditClassDelayLerk delayafter = 8 
 elseif String == "Fade" then  cost = gCreditClassCostFade delayafter = gCreditClassDelayFade delayafter = 8 
  elseif String == "Onos" then cost = gCreditClassCostOnos delayafter = gCreditClassDelayOnos delayafter = 8 
         
  end
    if isFast then cost = cost * 2 end
    if FirstCheckRulesHere(self, Client, Player, String, cost, false, isCredit ) == true then return end
    DeductBuy(self, Player, cost, delayafter, isCredit)

         if Player:GetTeamNumber() == 1 then --ugh... messy...
              if cost == gCreditClassCostJetPack   then  Player:GiveJetpack()
             elseif cost == gCreditClassCostMiniGunExo   then Player:GiveDualExo(Player:GetOrigin())
             elseif cost == gCreditClassCostRailGunExo   then  Player:GiveDualRailgunExo(Player:GetOrigin())
             elseif cost == gCreditClassCostWelderExo   then  Player:GiveDualWelder(Player:GetOrigin())
             elseif cost == gCreditClassCostFlamerExo  then Player:GiveDualFlamer(Player:GetOrigin())
             end 
         elseif Player:GetTeamNumber() == 2 then
 
              if cost == gCreditClassCostGorge  then 
                  if isCredit and isFast then LowBlow(Player, Gorge.kMapName)
                 else
                  Player:CreditBuy(kTechId.Gorge)  
                  end
              elseif cost == gCreditClassCostLerk  then  
                 if isCredit and isFast then LowBlow(Player, Lerk.kMapName) 
                 else
                 Player:CreditBuy(kTechId.Lerk)
                 end
              elseif cost == gCreditClassCostFade  then
                 if isCredit and isFast then LowBlow(Player, Fade.kMapName) 
                 else 
                 Player:CreditBuy(kTechId.Fade)
                 end
              elseif cost == gCreditClassCostOnos  then 
               if isCredit and isFast then LowBlow(Player, Onos.kMapName) 
                else
                 Player:CreditBuy(kTechId.Onos) 
                 end
              end
         end
      
   

 
   
end


local BuyClassCommand = self:BindCommand("sh_buyclass", "buyclass", BuyClass, true)
BuyClassCommand:Help("sh_buyclass <class name>")
BuyClassCommand:AddParam{ Type = "string" }
BuyClassCommand:AddParam{ Type = "string", Optional = true }
BuyClassCommand:AddParam{ Type = "string", Optional = true }

local function BuyGlow(Client, String, StringTwo)

local Player = Client:GetControllingPlayer()
local delayafter = 8 
local cost = 5
local color = 0
local isCredit =  StringTwo == "Credit"
if not Player then return end

if Player:GetIsGlowing() then
self:NotifyCredit( Client, "You're already glowing. Wait until you cease to glow.", true)
 return
end

 if String == "Purple" then color = 1 
  elseif String == "Green" then color = 2
  elseif String == "Gold" then color = 3
  elseif String == "Red" then color = 4
  end
  
 if FirstCheckRulesHere(self, Client, Player, String, cost, false, isCredit ) == true then return end
            if color == 0 then return end
            
            DeductBuy(self, Player, cost, delayafter, isCredit)  
            Player:GlowColor(color, 300)
            self.GlowClientsTime[Player:GetClient()] = Shared.GetTime() + 300
            self.GlowClientsColor[Player:GetClient()] = color
   
end


local BuyGlowCommand = self:BindCommand("sh_buyglow", "buyglow", BuyGlow, true)
BuyGlowCommand:Help("sh_buyglow <color number> ")
BuyGlowCommand:AddParam{ Type = "string" }
BuyGlowCommand:AddParam{ Type = "string", Optional = true }

/*

local function BuyUpgrade(Client, String, StringTwo)

local Player = Client:GetControllingPlayer()
local delayafter = 1
local cost = 5
local color = 1
local isCredit =  StringTwo == "Credit"
if not Player then return end

 if FirstCheckRulesHere(self, Client, Player, String, cost, false, isCredit ) == true then return end
  
 if String == "Resupply" then   Player.hasresupply = true
  elseif String == "HeavyArmor" then  Player.heavyarmor = true Player.lightarmor = false
    elseif String == "LightArmor" then  Player.lightarmor = true Player.heavyarmor = false
  elseif String == "FireBullets" then  Player.hasfirebullets = true
  elseif String == "RegenArmor" then  Player.nanoarmor = true
  end
  DeductBuy(self, Player, cost, delayafter, isCredit)
   
end


local BuyUpgradeCommand = self:BindCommand("sh_buyupgrade", "buyupgrade", BuyUpgrade, true)
BuyUpgradeCommand:Help("sh_buyupgrade <string> ")
BuyUpgradeCommand:AddParam{ Type = "string" }
BuyUpgradeCommand:AddParam{ Type = "string", Optional = true }

*/

local function Buy(Client, String, StringTwo)

local Player = Client:GetControllingPlayer()
local mapnameof = nil
local Time = Shared.GetTime()
local NextUse = self.BuyUsersTimer[Client]
local reqpathing = true
local reqground = true
if not Player then return end
local CreditCost = 10
local techid = nil
local isCredit =  StringTwo == "credit"
--Print("StringTwo is %s, isCredit is %s", StringTwo, isCredit)


if Player:GetTeamNumber() == 1 then 
  mapnameof, delay, reqground, reqpathing, CreditCost, limit, techid = TeamOneBuyRules(self, Client, Player, String, isCredit)
elseif Player:GetTeamNumber() == 2 then
reqground = false
  mapnameof, delay, reqground, reqpathing, CreditCost, limit, techid  = TeamTwoBuyRules(self, Client, Player, String, isCredit)
end // end of team numbers

if mapnameof and ( not FirstCheckRulesHere(self, Client, Player, String, CreditCost, true, isCredit ) == true ) then
 PerformBuy(self, Client, String, Player, CreditCost, true, reqground,reqpathing, true, delay, mapnameof, limit, techid, isCredit) 
end

end



local BuyCommand = self:BindCommand("sh_buy", "buy", Buy, true)
BuyCommand:Help("sh_buy <item name> <credit> <- if u wanna buy with credit else pres by default")
BuyCommand:AddParam{ Type = "string" }
BuyCommand:AddParam{ Type = "string", Optional = true }


local function Credit(Client, Targets)
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self:NotifyCredit( Client, "%s has a total of %s Credit", true, Player:GetName(), self:GetPlayerCreditInfo(Player:GetClient()))
end
end

local CreditsCommand = self:BindCommand("sh_Credit", "Credit", Credit, true, false)
CreditsCommand:Help("sh_Credit <name>")
CreditsCommand:AddParam{ Type = "clients" }

local function SetCredit(Client, Targets, Number, Display, Double) --TriggerHappyStoner




for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self.CreditUsers[ Player:GetClient() ] = Number
Shine.ScreenText.SetText("Credit", string.format("%s Credit", self:GetPlayerCreditInfo(Player:GetClient()) ), Player:GetClient())
   if Display == true then
   self:NotifyGeneric( nil, "set %s's  Credit to %s", true, Player:GetName(), Number )
   end
end

end


local SetCreditCommand = self:BindCommand("sh_setCredit", "setCredit", SetCredit)
SetCreditCommand:Help("sh_setCredit <player> <number> <display>")
SetCreditCommand:AddParam{ Type = "clients" }
SetCreditCommand:AddParam{ Type = "number" }
SetCreditCommand:AddParam{ Type = "boolean", Optional = true, Default = true }
SetCreditCommand:AddParam{ Type = "boolean", Optional = true, Default = false }


local function GetCredit(Client)

 self:GenereateTotalCreditAmount()
end


local GetCreditCommand = self:BindCommand("sh_getCredit", "getCredit", GetCredit)
GetCreditCommand:Help("sh_getCredit - pasts amount of users and Credit.")

local function AddCredit(Client, Targets, Number, Display, Double)

  
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
if Double == true then Number = Number * self.Config.kCreditMultiplier end
self.CreditUsers[ Player:GetClient() ] = self:GetPlayerCreditInfo(Player:GetClient()) + Number
Shine.ScreenText.SetText("Credit", string.format( "%s Credit", self:GetPlayerCreditInfo(Player:GetClient()) ), Player:GetClient()) 
   if Display == true then
   self:NotifyGeneric( nil, "gave %s Credit to %s (who now has a total of %s)", true, Number, Player:GetName(), self:GetPlayerCreditInfo(Player:GetClient()))
   end
end
end

local AddCreditsCommand = self:BindCommand("sh_addcredit", "addcredit", AddCredit)
AddCreditsCommand:Help("sh_addcredit <player> <number> <display> <double> Choose not to display, or to double the amt if dbl crd is act.")
AddCreditsCommand:AddParam{ Type = "clients" }
AddCreditsCommand:AddParam{ Type = "number" }
AddCreditsCommand:AddParam{ Type = "boolean", Optional = true, Default = true }
AddCreditsCommand:AddParam{ Type = "boolean", Optional = true, Default = false }



local function SaveCreditsCmd(Client)
self:SaveAllCredits(false)
end

local SaveCreditsCommand = self:BindCommand("sh_savecredits", "savecredits", SaveCreditsCmd)
SaveCreditsCommand:Help("sh_savecredits saves all credits online")

end

