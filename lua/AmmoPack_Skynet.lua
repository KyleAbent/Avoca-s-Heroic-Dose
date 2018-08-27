local orig = WeaponAmmoPack.OnTouch
function WeaponAmmoPack:OnTouch(recipient)

   orig(self,recipient)
   if not recipient:GetHasLayStructure() then
   local random = math.random(1,3)
   if random == 1 then
         recipient:GiveItem(NerveGasCloudThrower.kMapName)
   elseif random == 2 then
         recipient:GiveItem(ClusterGrenadeThrower.kMapName)
   elseif random == 3 then
         recipient:GiveItem(PulseGrenadeThrower.kMapName)
    end
    end
    
    
    
end