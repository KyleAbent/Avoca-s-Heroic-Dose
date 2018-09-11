local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end


Script.Load("lua/shine/extensions/credits/client_Credit_menu.lua")
Shine.VoteMenu:AddPage ("SpendCredit", function( self )
       local player = Client.GetLocalPlayer()
          self:AddSideButton( "CommAbilities", function() self:SetPage( "SpendCommAbilitiesCredit" ) end) 
       
       
  if player:GetTeamNumber() == 1 then 
        self:AddSideButton( "Weapons", function() self:SetPage( "SpendWeaponsCredit" ) end)
      end  


    

     self:AddSideButton( "Classes", function() self:SetPage( "SpendClassesCredit" ) end) 
     self:AddSideButton( "Structures", function() self:SetPage( "SpendStructuresCredit" ) end)
             --  self:AddSideButton( "Fun", function() self:SetPage( "SpendFun" ) end)
               self:AddSideButton( "Expensive", function() self:SetPage( "SpendExpeniveCredit" ) end)
               
       if player:GetTeamNumber() == 1 then 
        self:AddSideButton( "Upgrades", function() self:SetPage( "SpendUpgradesCredit" ) end)
      end  
        --self:AddSideButton( "Glow", function() self:SetPage( "SpendGlowCredit" ) end)
        self:AddBottomButton( "Back", function()self:SetPage("Main")end)  
end)
     
     
Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "Credit", function()  self:SetPage( "SpendCredit" ) end)
end)


