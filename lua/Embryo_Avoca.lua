function Embryo:GetGestationTime(gestationTypeTechId)
    local orig = LookupTechData(gestationTypeTechId, kTechDataGestateTime)
    return ConditionalValue( GetConductor():GetIsPhaseTwoBoolean(),orig/2, orig)
end