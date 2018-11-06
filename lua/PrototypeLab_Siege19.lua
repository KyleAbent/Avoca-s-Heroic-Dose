function PrototypeLab:GetMinRangeAC()
return ProtoAutoCCMR      
end

local oldfunc = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
        local  otherbuttons = { kTechId.Jetpack, kTechId.DualMinigunExosuit, kTechId.DualRailgunExosuit, 
                                kTechId.DualFlamerExosuit, kTechId.DualWelderExosuit, kTechId.WeldFlamerExosuit, kTechId.RailgunWelderExoSuit, kTechId.RailgunFlamerExoSuit,}
        
               
           return otherbuttons
end



--derp
/*
local oldfunc = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
        local  otherbuttons = { kTechId.Jetpack, kTechId.DualMinigunExosuit, kTechId.DualRailgunExosuit,  kTechId.DualWelderExosuit, kTechId.DualFlamerExosuit, kTechId.JumpPack }
        
              if (forPlayer.GetHasJumpPack and forPlayer:GetHasJumpPack()) or forPlayer:isa("JetpackMarine")  or forPlayer:isa("Exo")  then
              otherbuttons[6] = kTechId.None
           end
           return otherbuttons
end

*/

local origbuttons = PrototypeLab.GetTechButtons
function PrototypeLab:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 --table[2] = kTechId.JetpackFuel1
 table[2] = kTechId.DropExosuit
 return table

end
/*
if Server then

function PrototypeLab:OnResearchComplete(researchId)
  
  if researchId == kTechId.JetpackFuel1 then
   
       for _, ent in ientitylist(Shared.GetEntitiesWithClassname("JetpackMarine")) do 
         ent:applyBuffAlive()
       --  break
      end

   end

end

end
*/
