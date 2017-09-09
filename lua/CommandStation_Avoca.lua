function CommandStation:OnUpdate(deltatime)
  if not self:GetIsBuilt() then
  Print("derp")
  self:Construct(0.1)
  end
end

 function CommandStation:OnAdjustModelCoords(modelCoords)
         local coords = modelCoords
    	local scale = 0.5 
        coords.xAxis = coords.xAxis * scale                       
        coords.yAxis = coords.yAxis * scale                           
        coords.zAxis = coords.zAxis * scale
   
    return coords
end