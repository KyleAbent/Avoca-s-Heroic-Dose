Script.Load("lua/Additions/PowerDrainer.lua")
Script.Load("lua/Additions/Conductor.lua")
Script.Load("lua/Additions/Imaginator.lua")
Script.Load("lua/Additions/AirLock.lua")       
Script.Load("lua/Additions/AutoCyst.lua")   
Script.Load("lua/Additions/Functions.lua")      
Script.Load("lua/Additions/Balancer.lua")   
Script.Load("lua/Additions/HiveDefense.lua") 
Script.Load("lua/Additions/Convars.lua") 
Script.Load("lua/Additions/PanicAttack.lua") 
Script.Load("lua/Additions/FireGrenade.lua") 
Script.Load("lua/Additions/Janitor.lua") 

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

    
    
    
    if Server then
    local function FreeOfRange(who)
   local crags = #GetEntitiesWithinRange("Crag", who:GetOrigin(), 8) 
   local whips = #GetEntitiesWithinRange("Whip", who:GetOrigin(), 8)
    if not whips and not crags or (whips + crags <= 3) then return true end
    return false
    end
    local function MoveElseWhereFree(who)
        local eligableparent = nil 
        local nearestcyst = GearNearest(who:GetOrigin(), "Cyst", 2, function(ent) return ent:GetIsBuilt() and FreeOfRange(ent) end)
               if nearestcyst then
                 local where = FindFreeSpace(nearestcyst:GetOrigin(), .5, 8)
                 who:GiveOrder(kTechId.Move, nearestcyst:GetId(), where, nil, true, true) 
                end
          
    end
     function Crag:OnOrderComplete(currentOrder)
        if currentOrder == kTechId.Move then
        local crags = #GetEntitiesWithinRange("Crag", who:GetOrigin(), 4) 
        if crags and  #crags >= 4 then
                 MoveElseWhereFree(self)
           end
        end
     end
     
     function Whip:OnOrderComplete(currentOrder)
        if self:isa("WhipAvoca") then return end
        if currentOrder == kTechId.Move then
        local whips = #GetEntitiesWithinRange("Whip", who:GetOrigin(), 8)
        if whips  and #whips  >= 4 then
                 MoveElseWhereFree(self)
         end
        end
     
     end
    
    end
    