Script.Load("lua/Additions/Conductor.lua")
Script.Load("lua/Additions/Imaginator.lua")
Script.Load("lua/Additions/AirLock.lua")       
Script.Load("lua/Additions/AutoCyst.lua")   

Script.Load("lua/Additions/Functions.lua")       

function Location:MakeSureRoomIsntEmpty()
          --So that the room lights being changed are actually observed, otherwise useless :)
          --Of course this varies on playercount. 1v1 will always have the active players room lit
          --12v12 will have only the 'main' room being lit, where all the action is, signifying players to 'BE THERE' 
          --by actually making it EXCITING, you derp head!!!
                     local entities = self:GetEntitiesInTrigger()
                     for i = 1, #entities do
                     local ent = entities[i]
                     if ent:isa("Player") and ent:GetIsAlive() and not ent:isa("Commander") then return true end
                     end
                     return false
    end
       --Really tired of copy and pasting this formula all over the place so why not take what I've learned
       --From reading others organization of such mass amounts of information regarding dictionaries and functions
       --of all these creative solutions I could never imagine myself.
    function SimpleCClass(classname, builtrequirement)
    
      local count = 0
      for _, ent in ientitylist(Shared.GetEntitiesWithClassname(classname)) do
            if builtrequirement and ent:GetIsBuilt() then
               count = count + 1
             end
        end
        return count
        
    end
    
    
    
    function Lerk:OnTakeDamage(damage, attacker, doer, point)
           --Woah close I almost touched balance again
    end
    
    
    function GetAirLocks()
    return EntityListToTable(Shared.GetEntitiesWithClassname("AirLock"))
   end

    function GetIsPointInAirLock(point)  --Maybe a 'workaround' for other entities than players
                                                      --to use this airlock entity rather than relying onupdate, maybe.. who knows.

    local ents = GetAirLocks()
    
    for index, airlock in ipairs(ents) do
    
        if airlock and airlock:GetIsPointInside(point) then
        
            return airlock
            
        end    
        
    end
    
    return nil

end
    
    