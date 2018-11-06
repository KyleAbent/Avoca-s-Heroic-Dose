--@Override
function PlayingTeam:GetHasTeamLost()

    PROFILE("PlayingTeam:GetHasTeamLost")

    if GetGamerules():GetGameStarted() then
    

        local activePlayers = self:GetHasActivePlayers()
        local numAliveCommandStructures = self:GetNumAliveCommandStructures()
        
        if  ( numAliveCommandStructures == 0 and not activePlayers ) or
            self:GetHasConceded() then
            
            return true
            
        end
        
    end
    
    return false
    
end