
	-- SlideNormalThief

	-- Created by Slide Ltd 2010-06-26
	-- contact@slidelondon.com

	-- Based on Normal Thief 1.0 By Mauricio B. G. (mbg@southlogic.com)

	fn DrawLine pointA pointB =
	(
		ss = SplineShape pos:pointA
		addNewSpline ss
		addKnot ss 1 #corner #line PointA
		addKnot ss 1 #corner #line PointB
		updateShape ss
	)


	rollout SlideNormalThief "SlideNormalThief" width:160
	(
		group "Info :"
		(
			label sntInfo1 "Created by Slide Ltd" align:#left
			label sntInfo2 "contact@slidelondon.com" align:#left
			label sntInfo3 "v2010.06.30" align:#left
		)
		group "Steal normals from"
		(
			pickbutton refPick "Reference Object" width:140 align:#left
		)
		group "Give normals to"
		(
			pickbutton objPick "Target Object" width:140 align:#left
		)
		group "Steal"
		(
			button sntSteal "Steal" width:140 align:#left

			label sntCurrentVertLabel "[Idle]" align:#left
			progressbar sntCurrentVertProgress color:(color 0 100 240) 
		)

		on refPick picked refmesh do
		(
			if (refmesh != undefined) do
				 refPick.text = refmesh.name
		)
		
		on objPick picked objmesh do
		(
			if (objmesh != undefined) do
				 objPick.text = objmesh.name
		)

		on sntSteal pressed  do
		(
			-- Make sure there are Edit_Normal modifiers applied to the ref and target objects
			if(refPick.object.modifiers[#Edit_normals] == undefined) do
			(
				messagebox "Please ensure the reference object has an Edit Normals modifier"
				return 0
			)
			if(objPick.object.modifiers[#Edit_normals] == undefined) do
			(
				messagebox "Please ensure the target object has an Edit Normals modifier"
				return 0
			)
			
			-- Save existing selection
			oldSelection = $
			
			max modify mode
			subObjectLevel = 0
			
			xStart = timestamp()

			-- Setup the reference object
			thisPickObject = refPick.object
			refTransform = thisPickObject.objecttransform
			select thisPickObject
			thisPickObjectEditNormals = thisPickObject.modifiers[#Edit_Normals].EditNormalsMod
			thisPickObjectEditNormals.Unify()
			thisPickObjectEditNormals.MakeExplicit()
			refNumVerts = thisPickObjectEditNormals.GetNumVertices()
			
			format "Ref object : % (numVerts : %)\n" thisPickObject.name refNumVerts

			-- Create lookup tables for the reference object
			sntCurrentVertLabel.caption = "Creating ref object LUT"
			sntCurrentVertProgress.value = 0
			refVertIDtoPos = #()
			refVertIDtoNormID = #()
			refNormIDtoNorm = #()
			for i = 1 to refNumVerts do
			(
				-- Map vertID to vert position
				refVertIDtoPos[i] = (thisPickObjectEditNormals.GetVertex i) * refTransform

				-- Map vertID to normalID
				normal_array = #{}
				thisPickObjectEditNormals.ConvertVertexSelection #{i} normal_array
				normal_result = normal_array as array
				normID = normal_result[1]
				refVertIDtoNormID[i] = normID
				
				-- Map normalID to normal
				refNormIDtoNorm[normID] = thisPickObjectEditNormals.Getnormal normID
				
				-- Update progress
				sntCurrentVertProgress.value = 100.*i/refNumVerts
			)

			-- Setup the current selection object
			thisSelObject = objPick.object
			objTransform = thisSelObject.objecttransform
			select thisSelObject
			thisSelObjectEditNormals = thisSelObject.modifiers[#Edit_Normals].EditNormalsMod
			thisSelObjectEditNormals.Unify()
			thisSelObjectEditNormals.MakeExplicit()
			objNumVerts = thisSelObjectEditNormals.GetNumVertices()
			
			format "Sel object : % (numVerts : %)\n" thisSelObject.name objNumVerts

			-- Create lookup tables for the selected object
			sntCurrentVertLabel.caption = "Creating target obj LUT"
			sntCurrentVertProgress.value = 0
			objVertIDtoPos = #()
			objVertIDtoNormID = #()
			objNormIDtoNorm = #()
			for i = 1 to objNumVerts do
			(
				-- Map vertID to vert position
				objVertIDtoPos[i] = (thisSelObjectEditNormals.GetVertex i) * objTransform

				-- Map vertID to normalID
				normal_array = #{}
				thisSelObjectEditNormals.ConvertVertexSelection #{i} normal_array
				normal_result = normal_array as array
				normID = normal_result[1]
				objVertIDtoNormID[i] = normID
				
				-- Map normalID to normal
				objNormIDtoNorm[normID] = thisSelObjectEditNormals.Getnormal normID
				
				-- Update progress
				sntCurrentVertProgress.value = 100.*i/objNumVerts
			)
			
			-- Loop through the verts in the selected object
			sntCurrentVertLabel.caption = "Current Vert:"
			sntCurrentVertProgress.value = 0
			for x=1 to objNumVerts do
			(
				-- Get the position of the vert in the selected mesh
				cb = objVertIDtoPos[x]

				-- Initialise a couple of things
				menordist = 9999999999
				normalt = [0,0,0]
				
				saveI = 0
				
				-- Loop through the verts in the reference object
				for i=1 to refNumVerts do
				(
					-- Get the position of the vert in the reference mesh
					ct = refVertIDtoPos[i]
					
					-- Calculate its distance from the vert in the selected mesh
					offset = cb - ct
					dist = length offset

					-- Is it closer than the last closest one?
					if dist < menordist then
					(
						menordist = dist
						
						-- Get the NormalID corresponding to this reference vert, and use it to look up the actual normal
						normID = refVertIDtoNormID[i] 
						normalt = refNormIDtoNorm[normID]
						saveI = i
					)
				)
				
				-- Draw a debug line
				--DrawLine objVertIDtoPos[x] refVertIDtoPos[saveI]
				
				-- Get the NormalID corresponding to this selecion vert, and use it to set the actual normal
				normID = objVertIDtoNormID[x]
				thisSelObjectEditNormals.SetNormal normID normalt

				-- Update the progress bar
				sntCurrentVertLabel.caption = "Current Vert:" + (x as string) + "/" + (objNumVerts as string)
				sntCurrentVertProgress.value = 100.*x/objNumVerts
			)

			sntCurrentVertLabel.caption = "[Idle]"
			sntCurrentVertProgress.value = 0
			
			xEnd = timestamp()
			format "Stole normals in % seconds\n" ((xEnd - xStart) / 1000.0)
			
			-- Reinstate original selection
			clearSelection()
			if(oldSelection != undefined) do
				select oldSelection
		)
	)

	-- Kill any existing instances of the tool and make a new one
	try(destroyDialog SlideNormalThief)catch()
	createDialog SlideNormalThief style:#(#style_toolwindow, #style_sysmenu) 