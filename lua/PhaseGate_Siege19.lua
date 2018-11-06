
//local kNanoshieldMaterial = PrecacheAsset("Glow/green/green.material")


local networkVars = 

{
    channel = "float (1 to 3 by 1)",
}
    
  local kNanoshieldMaterial = PrecacheAsset("cinematics/vfx_materials/karma.material")

  local origcreate = PhaseGate.OnCreate
  function PhaseGate:OnCreate()
      origcreate(self)

  end
local originit = PhaseGate.OnInitialized
    function PhaseGate:OnInitialized()
        originit(self)
		      self.channel = 1
    end
	function PhaseGate:OnConstructionComplete()
	self.channel = 1
	end
  function PhaseGate:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
	if self.channel == 1 then
	    unitName = string.format(Locale.ResolveString("PhaseGate(Comm)"))
	else 
	    unitName = string.format(Locale.ResolveString("PhaseGate(Karma)"))
	end

return unitName
end 


     local origr = PhaseGate.OnUpdateRender
    function PhaseGate:OnUpdateRender()
	     origr(self)
	--if Client then
          //local showMaterial = self.channel != 1 //simple 
    
        local model = self:GetRenderModel()
        if model then

            //model:SetMaterialParameter("glowIntensity", 4)

            if self.channel == 2 then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kNanoshieldMaterial)
                end
                
              //  self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
               // self:SetOpacity(1, "hallucination")
            
            end //showma
            end -- client
       -- end//omodel
end //up render


function PhaseGate:GetMinRangeAC()
return PGAutoCCMR  
end


function PhaseGate:OnPowerOn()
	 GetImaginator().activePGs = GetImaginator().activePGs + 1;  
end

function PhaseGate:OnPowerOff()
	 GetImaginator().activePGs = GetImaginator().activePGs - 1;  
end

 function PhaseGate:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetImaginator().activePGs  = GetImaginator().activePGs- 1;  
	  end
end


Shared.LinkClassToMap("PhaseGate", PhaseGate.kMapName, networkVars)