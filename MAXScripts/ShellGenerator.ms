macroScript ShellGenerator category:"Calvinatorr_Custom" buttontext:"Shell Generator" tooltip:"Shell Generator"
(
	rollout ShellUI "Shell Generator"
	(
		--------------------------------------------------------------------- Controls ----------------------------------------------------------------------------
		
		local channels = #("-2 Alpha", "-1 Illumination", "0 Colour", "1 UV", "2 Second UV") --, "1 UVW", "2 UVW Second Pass")
		
		listBox colourChannel "Colour Channel:" items:channels selection:1 height:6
		checkbox R  "Red" checked:true tooltip:"Red Channel" across:3 align:#center
		checkbox G  "Green" checked:true tooltip:"Green Channel" across:3 align:#center
		checkbox B  "Blue" checked:true tooltip:"Blue Channel" across:3 align:#center
		
		spinner numOfShells "Shells" range:[2, 100, 8] type:#integer across:2 align:#left tooltip:"Number of shells to generate"
		checkbox useSelection "Use Selection" checked:true align:#right across:2
		button generateShells "Generate Shells" across:2 align:#right
		
		function GetColourComponents = 
		(
			local colour = #{1..3};
			
			if (R.checked) then colour[1] = true else colour[1] = false;
			if (G.checked) then colour[2] = true else colour[2] = false;
			if (B.checked) then colour[3] = true else colour[3] = false;
			
			return colour;
		)
		
		function ApplyVertexColour components:#{} shellNum:0 = 
		(
				for i = 1 to (polyOp.GetNumVerts $) do --for each vertex
				(
					$.SetSelection #Vertex #{i}
					local vertexColour = ($.GetVertexColor (colourChannel.selection - 3)) as Point3

					for c in components do
					(
						vertexColour[c] = ((shellNum as float) / ((numOfShells.value - 1) as float)) * 255.0
					)
					
					polyOp.SetVertColor $ (colourChannel.selection - 3) #{i} (vertexColour as Color)
				)
		)
		
		function GenShell obj:node = 
		(
			max modify mode
			select obj
			
			--edit edit poly modifier and rename it
			suspendEditing which:#modify
			local polyMod = Edit_Poly()
			addModifier $ polyMod
			polyMod.name = "Fur Shells TMP"
			resumeEditing which:#modify
			
			subObjectLevel = 4 --face/poly selection
			if (useSelection.checked) then
			(
				actionMan.executeAction 0 "40021"  -- Selection: Select All
			)
			
			local shellName = uniqueName ($.name + "_Fur_Shell")
			polyMod.DetachToObject shellName
			deleteModifier $ polyMod; --delete temp modifier
			
			--select newly created shell
			max select none
			select (getNodeByName shellName)
			
			--buffer this as the master shell and colour it black
			ApplyVertexColour components:(GetColourComponents()) shellNum:0
			local masterShell = $
			local shells = #()
				
			for i = 1 to numOfShells.value - 1 do
			(
				local nnl
				maxOps.cloneNodes $ cloneType:#copy newNodes:&nnl
				select nnl
				
				ApplyVertexColour components:(GetColourComponents()) shellNum:i
				append shells $
			)
			
			for s in shells do
			(
				masterShell.attach s s
			)
		)
		
		on generateShells pressed do
		(
			local selectedObjects = for s in selection collect s;
			
			for s in selectedObjects do
			(
				GenShell obj:s
			)
		)
	)

	CreateDialog ShellUI 250 200
)

macros.run "Calvinatorr_Custom" "ShellGenerator"