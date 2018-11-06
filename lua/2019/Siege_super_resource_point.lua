class 'Siege_Super_ResourcePoint' (ResourcePoint)

Siege_Super_ResourcePoint.kPointMapName = "siege_superresource_point"

local networkVars =
{
}

function ResourcePoint:OnCreate()
end

function ResourcePoint:OnInitialized()
end

Shared.LinkClassToMap("Siege_Super_ResourcePoint", Siege_Super_ResourcePoint.kPointMapName, networkVars)