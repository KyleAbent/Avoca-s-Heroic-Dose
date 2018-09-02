

--local orig consOn = ConstructMixin.OnConstructionComplete
function PowerConsumerMixin:OnPowerOff()
   --   consOn(self, builder)
   
      local  PanicAttackCount = GetEntitiesForTeam( "PanicAttack", 2 )
      if #PanicAttackCount < 19 then 
             for i = 1 ,math.random(1, ( 19 - #PanicAttackCount )  ) do
             local panicattack = CreateEntity(PanicAttack.kMapName, FindFreeSpace(self:GetOrigin(), 8, 24), 2)
            -- panicattack:SetConstructionComplete()
             end
      end   
      
end