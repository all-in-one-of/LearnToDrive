macroScript VertexGradientWorldSpace
category: "Calvinatorr_Custom"
tooltip: "Vertex Gradient World Space"
(
	function ClearVertexColours channel:-2 components:#{} colour:#() =
	(
		if (selection.count > 0) then
		(
			for s in selection while SuperClassOf(s) == GeometryClass do
			(
				for i = 1 to (polyOp.GetNumVerts s) do --for each vertex
				(
					s.SetSelection #Vertex #{i};
					local vertexColour = (s.GetVertexColor channel) as Point3;
					
					for c in components do
					(
						vertexColour[c] = colour[c];
					)
					
					PolyOp.setVertColor s channel #{i} (vertexColour as Color); --clear vertex colours
				)
			)
		)
	)
	
	function ApplyVertexGradient channel:-2 components:#{} = 
	(
		if (selection.count > 0) then --if anything is selected
		(
			max modify mode; --open panel
			
			for s in selection while SuperClassOf(s) == GeometryClass do --for each mesh in the selection
			(
				--modPanel.AddModToSelection(VertexPaint());
				--local mesh = s.VertexPaint;
				--mesh.mapChannel = channel;
					
				local delta = sqrt((s.max.z - s.min.z) * (s.max.z - s.min.z));
				
				for i = 1 to (polyOp.GetNumVerts s) do --for each vertex
				(
					s.SetSelection #Vertex #{i};
					local vertexColour = (s.GetVertexColor channel) as Point3;
					
					local v = polyOp.GetVert s i; --vertex
					local height = ((v.z - s.min.z)/ delta) * 255;
					
					for c in components do
					(
						vertexColour[c] = height;
					)
					
					polyOp.SetVertColor s channel #{i} (vertexColour as Color);
				)
				
				--DeleteModifier s s.modifiers[1];
			)
		)
	)
	
	local channels = #("-2 Alpha", "-1 Illumination", "0 Colour", "1 UV", "2 UV2");
	
	function EnableVertexColours channel:0 = 
	(
		for s in selection while SuperClassOf s == GeometryClass do 
		(
			s.showVertexColors = on;
			s.vertexColorsShaded = on;
			s.vertexColorType = 5;
			s.vertexColorMapChannel = channel;
			
			nodeInvalRect s;
		)
		
		RedrawViews();
	)
	
	UI = NewRolloutFloater "Vertex Gradient" 250 340;
	
	Rollout ColourUI "Vertex Colour Channels"
	(
		ListBox ColourChannel "Colour Channel:" items:channels selection:3 height:6;
		--MultiListBox ColourComponents "Colour Components:" items:#("R", "G", "B") selection:1 tooltip:"For Alpha select any" height:4;
		Checkbox R  "Red" checked:true tooltip:"Red Channel" across:3 align:#center;
		Checkbox G  "Green" checked:true tooltip:"Green Channel" across:3 align:#center;
		Checkbox B  "Blue" checked:true tooltip:"Blue Channel" across:3 align:#center;
		
		function GetColourComponents = 
		(
			local colour = #{1..3};
			
			if (R.checked) then colour[1] = true else colour[1] = false;
			if (G.checked) then colour[2] = true else colour[2] = false;
			if (B.checked) then colour[3] = true else colour[3] = false;
			
			return colour;
		)
		
		on ColourUI open do
		(
			EnableVertexColours channel:(ColourChannel.selection - 3);
		)
		
		on ColourChannel selected arg do
		(
			EnableVertexColours channel:(ColourChannel.selection - 3);
		)
	)
	AddRollout ColourUI UI;
	
	Rollout ClearColourUI "Clear Colour"
	(
		ColorPicker ClearColour "" color:[255, 255, 255] across:2 tooltip:"Colour to clear with";
		Button ClearToColour "Clear To Colour" align:#right across:2 tooltip:"Set selected colour components in channel to selected clear colour (limited by selected colour components)";
		
		on ClearToColour pressed do
		(
			ClearVertexColours channel:(ColourUI.ColourChannel.selection - 3) components:(ColourUI.GetColourComponents()) colour:(ClearColourUI.ClearColour.color as point3);
			EnableVertexColours channel:(ColourUI.ColourChannel.selection - 3);
		)
	)
	AddRollout ClearColourUI UI;
	
	Rollout ApplyGradientUI "Apply Gradient"
	(
		Button OKButton "Apply Gradient" align:#center across:1 tooltip:"Collapse to Editable Poly first if mesh changes have been made";
		
		on ColourChannel selected a do EnableVertexColours channel:(ColourUI.ColourChannel.selection - 3);
		
		on OKButton pressed do
		(
			ApplyVertexGradient channel:(ColourUI.ColourChannel.selection - 3) components:(ColourUI.GetColourComponents());
			EnableVertexColours channel:(ColourUI.ColourChannel.selection - 3);
		)
	)
	AddRollout ApplyGradientUI UI;
)