macroScript LiquidToMesh
category: "Calvinatorr_Custom"
tooltip: "Liquid To Mesh"
(
	Rollout UI "Liquid To Mesh"
	(
		local channels = #("-2 Alpha", "-1 Illumination", "0 Colour") --, "1 UVW", "2 UVW Second Pass")
		
		listBox colourChannel "Colour Channel:" items:channels selection:1 height:6
		checkbox R  "Red" checked:true tooltip:"Red Channel" across:3 align:#center
		checkbox G  "Green" checked:true tooltip:"Green Channel" across:3 align:#center
		checkbox B  "Blue" checked:true tooltip:"Blue Channel" across:3 align:#center
		
		function GetColourComponents = 
		(
			local colour = #{1..3};
			
			if (R.checked) then colour[1] = true else colour[1] = false;
			if (G.checked) then colour[2] = true else colour[2] = false;
			if (B.checked) then colour[3] = true else colour[3] = false;
			
			return colour;
		)
		
		function ApplyVertexColour components:#{} value:1 = 
		(
				for i = 1 to (polyOp.GetNumVerts $) do --for each vertex
				(
					$.SetSelection #Vertex #{i}
					local vertexColour = ($.GetVertexColor (colourChannel.selection - 3)) as Point3

					for c in components do
					(
						vertexColour[c] = (value as float) * 255.0
					)
					
					polyOp.SetVertColor $ (colourChannel.selection - 3) #{i} (vertexColour as Color)
				)
		)

		function BlobMeshFilter obj = ClassOf obj == BlobMesh
		Spinner MinTime "Min" range:[0, 999, 0] across:2 align:#left type:#float
		Spinner MaxTime "Max" range:[0, 999, 0] across:2 align:#right type:#float
		PickButton ObjPicker "Select Object" across:2
		Button BakeToMesh "Bake To Mesh" across:2
		
		on UI open do
		(
			MinTime.value = animationRange.start
			MaxTime.value = animationRange.end
			if (selection.count > 0) then
			(
				ObjPicker.object = selection[1]
				ObjPicker.text = ObjPicker.object.name
			)
		)
		
		on ObjPicker picked obj do
		(
			ObjPicker.text = obj.name
		)
		
		on BakeToMesh pressed do
		(
			if (ObjPicker.object != null) then
			(
				for i = MinTime.value to MaxTime.value do
				(
					sliderTime = i
					--sleep 0.2
					
					local nnl
					maxOps.cloneNodes $ cloneType:#copy newNodes:&nnl
					select nnl
					maxOps.CollapseNode $ off
				)
			)
		)
	)
	
	CreateDialog UI 250 200
)

macros.run "Calvinatorr_Custom" "LiquidToMesh"