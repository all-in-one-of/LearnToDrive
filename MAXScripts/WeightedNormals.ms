macroScript WeightedNormals
category: "Sumo Scripts"
tooltip: "Weighted Normals"
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

	global wnmodname = "Weighted Normals"

	-- Returns angle between two vectors
	function AngleBetweenVectors v1 v2 =
	(
	 return (acos (dot (normalize v1) (normalize v2) ) )
	)

	-- Get weighted normals modifier
	function GetModifier obj =
	(
		for i=1 to obj.modifiers.count do
		(
			local mf = obj.modifiers[i]
			if (classof mf) == Edit_Normals then
			(
				if mf.name == wnmodname then
					return mf
			)
			else
				return undefined
		)
		
		return undefined
	)


	-- generates weighted normals
	function GenWeightedNormals obj =
	(
		-- filter
		if (SuperClassOf obj) != GeometryClass do return false
		
		Undo Off()
		max modify mode
		
		--DisableSceneRedraw()
		--Undo Off()
		--SuspendEditing()
		
		if (ClassOf obj) != Editable_Mesh do AddModifier obj (Edit_Mesh()) -- Add EditMesh modifier
		local mf = GetModifier obj
		
		-- Workaround for 3dsmax bug
		Select obj
		 
		-- build face area array
		local facearea = #()
		facearea.count = obj.numFaces
		for i=1 to obj.numFaces do
			facearea[i] = MeshOp.GetFaceArea obj i
		 
		-- Build face angle array
		local faceangle = #()
		faceangle.count = obj.numFaces
		for i=1 to obj.numFaces do
		(
			local f = GetFace obj i
			local v1 = GetVert obj f[1]
			local v2 = GetVert obj f[2]
			local v3 = GetVert obj f[3]
			local a1 = AngleBetweenVectors (v2-v1) (v3-v1) -- todo: optimize
			local a2 = AngleBetweenVectors (v1-v2) (v3-v2)
			local a3 = AngleBetweenVectors (v1-v3) (v2-v3)
			faceangle[i] = [a1,a2,a3]
		)
		
		--DeleteModifier obj 1
		
		-- modifier not found, create one
		if mf == undefined do
		(
			AddModifier obj (Edit_Normals())
			mf = obj.modifiers[#Edit_Normals]
			mf.name = wnmodname
		)
		
		-- get number of normals
		local normNum = mf.GetNumNormals()
		
		-- allocate array
		local norms = #()
		norms.count = normNum
		for i=1 to normNum do
			norms[i] = [0,0,0]
		
		-- Loop faces
		for i=1 to obj.numFaces do
		(
			-- get face normal
			in coordsys local n = GetFaceNormal obj i
			 
			-- accumulate
			for j=1 to 3 do
			(
				local id = mf.GetNormalID i j
				norms[id] = norms[id] + (n * facearea[i] * faceangle[i][j])
			)
		)
		
		DeleteModifier obj 2 -- Delete Edit_Mesh modifier
		
		-- set normals
		for i=1 to normNum do
		(
			mf.SetNormalExplicit i explicit:true
			mf.SetNormal i (normalize norms[i])
		)
		
		Undo On()
	)


	--- GUI ------------------------------------------------------------------------

	/*
	-- Close existing floater
	if WeightedNormals != undefined do CloseRolloutFloater WeightedNormals
	WeightedNormals = newRolloutFloater "Weighted Normals" 180 150

	-- Generate rollout
	rollout rWNGenerate "Weighted Normals"
	(
		Button cmdCreate "Generate" width:140 height:25

		on cmdCreate pressed do
		(
			local sel = for s in selection collect s -- Buffer selection

			for i=1 to sel.count do
				GenWeightedNormals sel[i]

			-- Reset to previous selection
			ClearSelection()
			for s in sel do SelectMore s
		)
	)
	AddRollout rWNGenerate WeightedNormals

	-- About
	rollout rWNAbout "About"
	(
		Label lab1 "Weighted Normals 1.0.0"
		Label lab2 "by Martijn Buijs"
		Label lab3 "www.bytehazard.com"
	)
	AddRollout rWNAbout WeightedNormals*/
	
	local sel = for s in selection collect s -- Buffer selection
	for s in sel do GenWeightedNormals s

	-- Reset to previous selection
	ClearSelection()
	for s in sel do SelectMore s
)

Macros.Run "Sumo Scripts" "WeightedNormals"