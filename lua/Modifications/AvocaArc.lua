--Kyle 'Avoca' Abent
/*class 'AvocaArc' (ARC)
AvocaArc.kMapName = "avocaarc"


function AvocaArc:OnCreate()
 ARC.OnCreate(self)
 self:MoveToHives()
end
*/
local function MoveToHives(who)

local hives = {}

           for _, hiveent in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             table.insert(hives, hiveent)
          end
         
        local hive = table.random(hives)
        local origin = FindArcSpace(hive:GetOrigin())
        who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
             
    /*
local origin = GetClosestHiveFromCC(who:GetOrigin()):GetOrigin()
      origin = FindArcSpace(origin)
who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
*/
end

function ARC:MoveToHives()
           self:AddTimedCallback(ARC.DoACheck, 4)
end


if Server then


function ARC:DoACheck() --To keep busy. Fire, shoot.. move.
         --Moving
        if self.mode == ARC.kMode.Moving then return true end
        
        --Not moving, not in attack mode, in range of closest hive.
        if self.mode ~= ARC.kMode.Moving and not self:GetInAttackMode() and GetIsPointWithinHiveRadius(self:GetOrigin()) then
        self:GiveOrder(kTechId.ARCDeploy, self:GetId(), self:GetOrigin(), nil, false, false)
        return true
        end
        
        --In attack mode, not nearest hive.
        if self:GetInAttackMode() and not GetIsPointWithinHiveRadius(self:GetOrigin()) then
        self:GiveOrder(kTechId.ARCUnDeploy, self:GetId(), self:GetOrigin(), nil, false, false) 
        return true
        end
        
        MoveToHives(self)
        return true
end


end



--Shared.LinkClassToMap("AvocaArc", AvocaArc.kMapName, networkVars)