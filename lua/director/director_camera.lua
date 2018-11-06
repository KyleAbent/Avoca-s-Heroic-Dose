local networkVars = 

{
} 
class 'DirectorCamera' (ScriptActor)
DirectorCamera.kMapName = "director_camera"


function DirectorCamera:OnInitialized()

    ScriptActor.OnInitialized(self)
    print("test")

end
function DirectorCamera:OnCreate()
 ScriptActor.OnCreate(self)
end

Shared.LinkClassToMap("DirectorCamera", DirectorCamera.kMapName, networkVars)