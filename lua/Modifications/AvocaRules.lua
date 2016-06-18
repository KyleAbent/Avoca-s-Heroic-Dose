class 'AvocaRules' (NS2Gamerules)
AvocaRules.kMapName = "avocarules"

--Uh oh, be careful. Avoca no longer has to rely on overwriting ns2gamerules. This is a dangerous idea. Actually, well.. yeah
--lets go with that, dangerous. Watch out ladies!

--Btw if I where to 'redo' siege without overwriting. This is how I will do it. This Avoca's Heroic Dose mod is an example
--to demonstrate what I learned. Incase you haven't notice I never touched lua before September 2014 and writing ns2siege
--and filling servers and being paid to do it. So here I am paying back because what I did also was take ideas
--which already worked and implemented them in 'hackish' ways. So this is my attempt to 'write' a mod the 'correct' way in
--terms of 'collaberation' behind the scenes of how the lua is actually written compared to how its played. Make sense? Prolly not
-- But dont worry ill keep trying my best to explain whats in my head the best i can because for me this all makes sense :s





Shared.LinkClassToMap("AvocaRules", AvocaRules.kMapName, networkVars)