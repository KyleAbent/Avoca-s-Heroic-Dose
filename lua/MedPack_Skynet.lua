local orig = MedPack.OnTouch
function MedPack:OnTouch(recipient)


    orig(self, recipient)
    recipient:AddArmor(MedPack.kHealth)--not in sync with timer delay of add health orig
    
end