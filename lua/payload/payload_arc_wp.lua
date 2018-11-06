
local networkVars = 
{
     nextND = "entityid", //link next
     prevND = "entityid"//link prev
} 
class 'PLArcWP' (ScriptActor)
PLArcWP.kMapName = "payload_arc_wp"


function PLArcWP:OnInitialized()

    ScriptActor.OnInitialized(self)
    print("test 2")

end

function PLArcWP:OnCreate()
 ScriptActor.OnCreate(self)
end

Shared.LinkClassToMap("PLArcWP", PLArcWP.kMapName, networkVars)