macroScript WeightedNormals
category: "Sumo Scripts"
tooltip: "Weighted Normals"

/* ==================================================================================================================================================================================================================================== */

(
	-- WEIGHTEDNORMALS.MS

	-- Computes Weighted Vertex Normals
	-- by Martijn Buijs, 2014
	-- www.bytehazard.com

	-- 3DSMAX bugs encountered:
	-- 1) .modifiers[#Edit_Normals] doesn't work on renamed modifiers for no
	--     apparant reason
	-- 2) We can only ever modify the topmost Edit_Normals modifier, even if we
	--    properly access it through its handle. So if there's another Edit_Normals
	--    modifier on the stack, we add a new modifier, so the user won't have his
	--    changes overwritten.
	-- 3) During testing, the script twice crashed on some geometry lacking
	--    smoothing groups. Unable to reproduce.
	
	-- Returns angle between two vectors
	function AngleBetweenVectors v1 v2 = ( return acos(dot (normalize v1) (normalize v2)) ) -- A . B = cos(theta) => theta = acos(A . B)
	
	-- Get weighted normals modifier
	function GetModifier obj =
	(
		for i = 1 to obj.modifiers.count do
		(
			local currentModifier = obj.modifiers[i]
			
			if (ClassOf currentModifier) == Edit_Normals then
				if currentModifier.name == modifierName then return currentModifier
			else return undefined
		)
		
		return undefined
	)
	
/* ==================================================================================================================================================================================================================================== */

	rollout WeightedNormalsUI "Sumo FWN"
	(
		local buttonHeight = 25
		
		--CheckButton UseCoplanar "Use co-planar?" iconName:@"EditUVW\AlignToPlanarMap" iconSize:[24, 24] tooltip:"Use co-planar?" checked:true width:35 height:35 align:#left across:2
		Label CoplanarLabel "Face Exponent: " across:1 align:#left
		Spinner CoplanarExponent "" range:[1.0, 32.0, 8.0] type:#float align:#left fieldWidth:75 tooltip:"Increase exponent to give larger faces even larger weightings"
		Button Generate "Generate" width:125 height:buttonHeight align:#center across:1

/* ==================================================================================================================================================================================================================================== */
		
		local modifierName = "Weighted Normals"

		-- Generates weighted normals
		function GenWeightedNormals obj =
		(
			if (SuperClassOf obj) != GeometryClass do return false -- Filter only by geometry
			
			Undo Off()
			max modify mode

			if (ClassOf obj) != Editable_Mesh do AddModifier obj (Edit_Mesh()) -- Add EditMesh modifier
			local currentModifier = GetModifier obj -- Get the current modifier
			Select obj
			 
			-- Build array of the area of all faces
			local faceAreas = #()
			faceAreas.count = obj.numFaces
			for i = 1 to obj.numFaces do faceAreas[i] = MeshOp.GetFaceArea obj i
			 
			-- Build face angle array
			local faceAngles = #()
			faceAngles.count = obj.numFaces -- Number of faces (tris)
			for i = 1 to obj.numFaces do
			(
				local f = GetFace obj i -- Get the current face (tri)
				
				-- Get all 3 vertices in current tri
				local v1 = GetVert obj f[1]
				local v2 = GetVert obj f[2]
				local v3 = GetVert obj f[3]
				
				-- Get angles between each vertex (each edge)
				local a1 = AngleBetweenVectors (v2 - v1) (v3 - v1) -- To Do: optimize
				local a2 = AngleBetweenVectors (v1 - v2) (v3 - v2)
				local a3 = AngleBetweenVectors (v1 - v3) (v2 - v3)
				faceAngles[i] = [a1, a2, a3] -- Append to our array
			)
			
			-- If modifier is not found, create one
			if currentModifier == undefined do
			(
				AddModifier obj (Edit_Normals())
				currentModifier = obj.modifiers[#Edit_Normals]
				currentModifier.name = modifierName
			)
			
			-- Get number of normals and initialize array of our new normals
			local numOfNormals = currentModifier.GetNumNormals()
			local normals = #()
			normals.count = numOfNormals
			for i = 1 to numOfNormals do normals[i] = [0, 0, 0] -- Initialize normals
			
			-- For each face (tri)
			for i = 1 to obj.numFaces do
			(
				in coordsys local n = GetFaceNormal obj i -- Get the current face normal in local space
				--Print ("Face: " + (i as string))
				--Print ("	Area: " + (faceAreas[i] as string))
				
				/*
				-- If we are checking for co-planar faces
				if UseCoplanar.checked then
				(
					-- Get this current face and all its vertices
					local f = GetFace obj i
					local v1 = GetVert obj f[1]
					local v2 = GetVert obj f[2]
					local v3 = GetVert obj f[3]
					
					
					for k = 1 to obj.NumFaces do -- For each face (tri) *again*
					(
						in coordsys local neighbourN = GetFaceNormal obj k -- Get neighbouring normal
						local neighbourF = GetFace obj k -- Get neighbouring face
						
						local neighbourV1 = GetVert obj neighbourF[1]
						local neighbourV2 = GetVert obj neighbourF[2]
						local neighbourV3 = GetVert obj neighbourF[3]
						
						local b = (v1 == neighbourV1 or v1 == neighbourV2 or v1 == neighbourV3 or v2 == neighbourV1 or v2 == neighbourV2 or v2 == neighbourV3 or v3 == neighbourV1 or v3 == neighbourV2 or v3 == neighbourV3)
						if b then
						(
							local a = AngleBetweenVectors N neighbourN
							if a <= CoplanarWeight.value then -- If within the weight threshold
							(
								
								
								for l = 1 to 3 do
								(
									--local id = currentModifier.GetNormalID k l
									local id = currentModifier.GetNormalID i l
									normals[id] = normals[id] + (neighbourN * faceAreas[k] * faceAngles[k][l])
								)
							)
						)
					)
				)
				*/
				 
				-- Accumulate for each vertex
				for j = 1 to 3 do
				(
					local id = currentModifier.GetNormalID i j
					normals[id] = normals[id] + (n * (Pow faceAreas[i] CoplanarExponent.value) * faceAngles[i][j])
					--Print ("	Vert: " + (j as string) + " | Angle: " + (faceAngles[i][j] as string))
				)
			)
			
			DeleteModifier obj 2 -- Delete Edit_Mesh modifier
			
			-- Set normals
			for i = 1 to numOfNormals do
			(
				currentModifier.SetNormalExplicit i explicit:true
				currentModifier.SetNormal i (Normalize normals[i])
			)
			
			Undo On()
		)
		
/* ==================================================================================================================================================================================================================================== */
		
		on Generate pressed do
		(
			local currentSelection = for s in selection collect s -- Buffer selection
			for s in currentSelection do GenWeightedNormals s -- For each in the current selection, generate face weighted normals

			-- Reset to previous selection
			ClearSelection()
			for s in currentSelection do SelectMore s
		)
	)
	
/* ==================================================================================================================================================================================================================================== */
	
	try ( DestroyDialog WeightedNormalsUI ) catch()	
	CreateDialog WeightedNormalsUI width:150 height:80 style:#(#style_toolwindow, #style_sysmenu) 
)

/* ==================================================================================================================================================================================================================================== */

Macros.Run "Sumo Scripts" "WeightedNormals"