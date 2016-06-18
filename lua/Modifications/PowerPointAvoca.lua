class 'PowerPointAvoca' (PowerPoint)

PowerPointAvoca.kMapName = "powerpointavoca"



function PowerPointAvoca:OnCreate()
   self.startSocketed = true
   PowerPoint.OnCreate(self)
end


Shared.LinkClassToMap("PowerPointAvoca", PowerPointAvoca.kMapName, networkVars)