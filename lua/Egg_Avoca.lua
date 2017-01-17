function Egg:GetClassToGestate()
    local class = LookupTechData(self:GetGestateTechId(), kTechDataMapName, Skulk.kMapName)
   -- Print("Egg Class to gestate is %s", class)
    return class
end
