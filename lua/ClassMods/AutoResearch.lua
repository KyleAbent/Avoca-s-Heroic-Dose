
--Kyle 'Avoca Abent'
kMarineResearchDelay = 15

function Conductor:AutoBioMass()
          for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             hive:AddTimedCallback(Hive.UpdateManually, 15)
          end
end
function Hive:GetBioMassLevel()
    return self.bioMassLevel
end

