function Armory:GetMinRangeAC()
return ArmoryAutoCCMR 
end

local originit = Armory.OnInitialized
function Armory:OnInitialized()

originit(self)
    --The new one does the oninit global, fantastic!
    --if Armory.kHealAmount == 25 then --if global then why call all the time and not when necessary? ill figure it out for later
    Armory.kHealAmount = ConditionalValue( GetHasTech(self, kTechId.ArmoryBuff1), 25 * 1.10, 25)  
    Armory.kResupplyInterval = ConditionalValue( GetHasTech(self, kTechId.ArmoryBuff1), .8 * .9, .8) --not 110%! 90%!
    Armory.kResupplyUseRange = ConditionalValue( GetHasTech(self, kTechId.ArmoryBuff1), 2.5 * 1.10, 2.5) 
    --OnInit because it won't reset to buffed values such as onresearch would do?
    --If armory dies then it will have the tech if armory is respawned lol. 
  --  end
    
end


if Server then
local origr = Armory.OnResearchComplete
function Armory:OnResearchComplete(researchId)
  
   origr(self, researchId)
   
  if researchId == kTechId.ArmoryBuff1 then
   
       for _, ent in ientitylist(Shared.GetEntitiesWithClassname("Armory")) do --Messy, oh well. 
             Armory.kHealAmount =  25 * 1.10
             Armory.kResupplyInterval =  .8 * .9
             Armory.kResupplyUseRange =  2.5 * 1.10
       --  break
      end

   end

end

end



local origbuttons = Armory.GetTechButtons
function Armory:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)
 table[4] = kTechId.ArmoryBuff1
 return table

end


function Armory:OnPowerOn()
	 GetImaginator().activeArmorys = GetImaginator().activeArmorys + 1;  
end

function Armory:OnPowerOff()
	 GetImaginator().activeArmorys = GetImaginator().activeArmorys - 1;  
end

 function Armory:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetImaginator().activeArmorys  = GetImaginator().activeArmorys- 1;  
	  end
end
