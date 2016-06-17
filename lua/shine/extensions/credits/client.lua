local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end


Shine.VoteMenu:AddPage ("SpendCredits", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 


elseif player:GetTeamNumber() == 2 then

end    


     
     self:AddBottomButton( "Back", function()self:SetPage("Main")end)
end)

Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "Credits", function() self:SetPage( "SpendCredits" ) end)
end)


