local orig = AmmoPack.OnTouch
function AmmoPack:OnTouch(recipient)


    for i = 0, recipient:GetNumChildren() - 1 do
    
        local child = recipient:GetChildAtIndex(i)
        if child:isa("ClipWeapon") then
        
            if child:GiveAmmo(AmmoPack.kNumClips, true) then
                consumedPack = true
            end
            
        end
        
    end  
    /*
   orig(self,recipient)
   if not recipient:GetHasLayStructure() then
   local random = math.random(1,3)
   if random == 1 then
      --   recipient:GiveItem(NerveGasCloudThrower.kMapName)
   elseif random == 2 then
     --    recipient:GiveItem(ClusterGrenadeThrower.kMapName)
   elseif random == 3 then
       --  recipient:GiveItem(PulseGrenadeThrower.kMapName)
    end
    end
    */
    
    
    
end