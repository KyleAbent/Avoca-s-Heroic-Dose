

--local orig consOn = ConstructMixin.OnConstructionComplete
function PowerConsumerMixin:OnPowerOff()
   --   consOn(self, builder)
      if self:isa("InfantryPortal") then return end  -- lol 
      if not GetConductor() or GetConductor().phase < 1 then return end
      local  PanicAttackCount = GetEntitiesForTeam( "PanicAttack", 2 )
      if #PanicAttackCount < 19 then 
             for i = 1 ,math.random(1, ( 19 - #PanicAttackCount )  ) do
             local panicattack = CreateEntity(PanicAttack.kMapName, FindFreeSpace(self:GetOrigin(), 8, 24), 2)
            -- panicattack:SetConstructionComplete()
             end
      end   
      
end