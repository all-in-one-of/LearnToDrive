cxoctoi-- Written by Calvin Simpson
-- csimpson@sumo-digital.com
-- Property of Sumo Digital Ltd
-- Commercial use only

macroScript SumoExporter
category: "Sumo Scripts"
tooltip: "Sumo Exporter (FBX)"
icon:#("standard", 1)
(
	-- =============================================================================================== UTILITY FUNCTIONS =================================================================================================
	
	function Clamp a minimum maximum = 
	(
		a = amax(#(a, 0.0))
		a = amin(#(a, 1.0))
		return a
	)
	
	function Saturate a = ( return Clamp a 0.0 1.0 )
	function Lerp a b alpha = ( return (a * (1.0 - alpha)) + (b * alpha) )
	function LerpColour a b alpha = ( return [(Lerp a.r b.r alpha), (Lerp a.g b.g alpha), (Lerp a.b b.b alpha)] )
	
	function LerpMultipleColour a b c alpha = 
	(
		alpha *= 2
		local result = Lerp a b (Saturate alpha)
		result = Lerp result c (Saturate (alpha - 1.0))
		return result
	)
	
	function BoolToInt bool = ( if (bool) then return 1 else return 0 )
	
	local errorColour = [183, 23, 23] as color
	local partialSuccessColour = [214, 134, 14] as color
	local successColour = [22, 190, 38] as color
	
	function LerpSuccess alpha = ( return LerpMultipleColour errorColour partialSuccessColour successColour alpha )
	
	function IntToString a = 
	(
		local str = a as string
		local strComps = FilterString str "."
		local result = strComps[1]
		if (strComps.count > 1) then result += "." + (strComps[2][1] as string)
		
		return result
	)
	
	function IsValid a = ( return a != undefined and a > 0 )
	
	-- ======================================================================================================================================================================================================================

	local buttonHeight = 25
	
	struct ExportedMesh
	(
		public
			name = "",
			dir = "",
			fileName = "",
		
			on create do ( fileName = name )
	)
	
	struct Cached
	(
		private
			fileName = "SumoExporterMeta.ini",
			initialDir = maxFilePath,
			function GetFileName = ( return initialDir + fileName ),
		
		public
			exportedMeshes = #(),
		
			function UpdateFile = 
			(
				--if exportedMeshes.count <= 0 then return undefined
					
				-- Create file if it doesn't exist
				local file = OpenFile (GetFileName())
				if file == undefined then file = CreateFile (GetFileName())
				Close file
					
				-- Get current contents of file
				file = OpenFile (GetFileName())
				local contents = #()
				while not EOF file do Append contents (ReadLine file)
				Close file
				
				local newContents = #()
				local startItem = false
					
				for line in contents do
				(
					if startItem then
					(
						local splitIndex = FindString line "="
						if not (IsValid splitIndex) then
						(
							startItem = false
							Append newContents line
						)
					)
					else
					(
						local item = FindString line (initialDir + maxFileName)
						startItem = IsValid item
						if not startItem then Append newContents line
					)
				)

				-- Write contents to file
				file = OpenFile (GetFileName()) mode:"w" -- Write mode
				
				-- Write this file's entries to disk
				if exportedMeshes.count > 0 then
				(
					Format "%" (((initialDir + maxFileName) as string) + "\n") to:file
					for m in exportedMeshes do
					(
						Format "%" ("	name=" + m.name + "\n") to:file
						Format "%" ("	dir=" + m.dir + "\n") to:file
						Format "%" ("	filename=" + m.fileName + "\n") to:file
					)
				)

				-- Write previous contents to file (excluding this file's entries)
				for line in newContents do
					Format "%" ((line as string) + "\n") to:file
				
				Close file
			),
						
			function AddExportedMesh obj dir fileName override:true = 
			(
				if obj == undefined then return undefined -- Null object
				
				local updateEntry = false
				
				for i = 1 to exportedMeshes.count do
				(
					if obj.name == exportedMeshes[i].name then -- If found existing entry then update
					(
						updateEntry = true
						
						if override then
						(
							exportedMeshes[i].dir = dir
							exportedMeshes[i].fileName = fileName
						)
						
						exit
					)
				)
				
				if not updateEntry then -- Add new entry
				(
					Append exportedMeshes (ExportedMesh())
					exportedMeshes[exportedMeshes.count].name = obj.name
					exportedMeshes[exportedMeshes.count].dir = dir
					exportedMeshes[exportedMeshes.count].fileName = fileName
				)
			),
		
			on create do
			(
				local file = OpenFile (GetFileName()) -- Try to open file
				if file == undefined then file = CreateFile (GetFileName()) -- Create file if it doesn't exist
				Close file -- File is now open so close it first
				
				file = OpenFile (GetFileName())
					
				local contents = #()
				while not EOF file do Append contents (ReadLine file)
				Close file
					
				if contents == undefined or contents.count == undefined or contents.count <= 1 then return undefined
				
				-- Fill out exportedMeshes array with meshes previously exported, their directories, and their fileName
				local startItem = false
				for line in contents do
				(
					if startItem then
					(
						local splitIndex = FindString line "="
						if not (IsValid splitIndex) then exit
						splitIndex += 1
						
						if IsValid (FindString line "filename=") then
						(
							exportedMeshes[exportedMeshes.count].fileName = SubString line splitIndex line.count
						)		
						else if IsValid (FindString line "dir=") then
						(
							exportedMeshes[exportedMeshes.count].dir = SubString line splitIndex line.count
						)
						else if IsValid (FindString line "name=") then
						(
							Append exportedMeshes (ExportedMesh())
							exportedMeshes[exportedMeshes.count].name = SubString line splitIndex line.count
						)
					)
					else
					(
						local item = FindString line (initialDir + maxFileName)
						startItem = IsValid item
					)
				)

				Close file
				UpdateFile()
			)
	)
	
	MyCached = Cached()
	
	-- =============================================================================================== STATISTICS HANDLING =================================================================================================
	-- ==========================================================================================================================================================================================================================
	
	local MyObject = selection
	
	struct Stats
	(
		private
			collisionPrefixes = #("UBX", "UCP", "USP", "UCX"),
		
		public
			target,
			targetName = "",
			grabViewportSize = [360, 200],
			grabViewport = bitmap grabViewportSize.x grabViewportSize.y,
			triangles = 0,
			vertices = 0,
			numUVs = 0,
			bounds = [0.0, 0.0, 0.0],
			density = 0.0,
			LODs = #(),
			colliders = #(),
		
			function GetNumUVChannels obj =
			(
				count = 0
				if classof obj == Editable_Poly or classof obj == PolyMeshObject then
				(
					for i in 1 to polyOp.getNumMaps obj do
						if polyOp.getMapSupport obj i then
							count += 1
				)
				else
				(
					for i in 1 to meshOp.getNumMaps obj do
						if meshOp.getMapSupport obj i then
							count += 1
				)
				
				return count
			),
		
			function GetRealNumVertices = 
			(
				if (target == undefined) then return 0
				
				Select target
				modPanel.AddModToSelection(Edit_Mesh()) -- Ensure object is always of EditableMesh type
					
				local UVs = GetNumUVChannels target
				local vertexColours = GetNumCPVVerts target
				
				modPanel.AddModToSelection(Edit_Normals()) -- Read the normals
				local normals = target.Edit_Normals.GetNumNormals()
				DeleteModifier $ 1 -- Delete Edit_Normals modifier
					
				DeleteModifier $ 1 -- Delete Edit_Mesh modifier
				
				return amax(#(vertices, UVs, normals))
			),
		
			function Update =
			(
				DisableSceneRedraw()
				undo Off()
				
				-- Init stats
				triangles = 0
				vertices = 0
				UVs = 0
				numUVs = 0
				bounds = [0.0, 0.0, 0.0]
				density = 0.0
				LODs = #()
				colliders = #()
				
				-- Populate stats
				local bufferSelection = #(target)
				for s in bufferSelection while SuperClassOf(s) == GeometryClass do
				(
					Select s
					max modify mode
					ResumeEditing()
					modPanel.AddModToSelection(Edit_Mesh()) -- Make EditableMesh type
					SuspendEditing()
					
					triangles += GetNumFaces s
					vertices += GetNumVerts s
					UVs += GetNumTVerts s
					numUVs = GetNumUVChannels s
						
					-- Calculate mesh density
					bounds = target.max - target.min
					local volume = (bounds.x + bounds.y + bounds.z) / 3.0
					density = vertices / volume
						
					-- Remove any LOD prefixes from name
					targetName = s.name
					local foundIndex = 0
					/*local foundIndex = FindString s.name "_LOD"
					if (foundIndex != 0 and foundIndex != undefined) then
					(
						targetName = ""
						for i = 1 to (foundIndex - 1) do targetName += s.name[i]
					)
					*/

					-- Find all colliders and LODs for the target
					local allObjects=  $*
					for obj in allObjects while SuperClassOf(obj) == GeometryClass do
					(
						Select obj
						local index = FindString $.name "_LOD"
						if (index != 0 and index != undefined) then
						(
							index = FindString $.name targetName
							if (index != 0 and index != undefined) then Append LODs $
						)
						
						for c in collisionPrefixes do
						(
							index = FindString $.name c
							if (index != 0 and index != undefined) then
							(
								index = FindString $.name targetName
								if (index != 0 and index != undefined) then
								(
									Append colliders $
									exit
								)
							)
						)
					)
					
					Select s						
					DeleteModifier $ 1 -- Delete Edit_Mesh modifier
				)
				
				-- Render thumbnail
				currentCamTransform = viewport.GetTM() -- Buffer camera transform
				actionMan.executeAction 0 "310"  -- Tools: Zoom Extents Selected
				Render to:grabViewport vfb:false antiAliasing:true
				viewport.SetTM currentCamTransform -- Reset to previous transform
				
				--if target != undefined then MyCached.AddExportedMesh target maxFilePath target.name override:false
				
				EnableSceneRedraw()
				undo On()
				ResumeEditing()
			),
			
			on create do
			(
				if selection.count > 0 then
					target = selection[1]
			)
	)
	
	MyStats = Stats()
	
	-- ==========================================================================================================================================================================================================================
	-- =============================================================================================== EXPORT HANDLING ======================================================================================================
	
	rollout StatsAndExportUI "Export Statistics"
	(
		group "  Target Mesh  "
		(
			ImgTag Thumbnail "" style:#bmp_center opacity:1 width:MyStats.grabViewportSize.x height:MyStats.grabViewportSize.y across:1 align:#left
			PickButton SelectTarget "Select Target" align:#left across:1 width:MyStats.grabViewportSize.x height:25 tooltip:"Select the target mesh you want to export"
		)
		
		group "  Mesh Statistics  "
		(
			Label Triangles "" align:#left across:2 tooltip:"The number of triangles (tris) in the export target"
			Label Vertices "" align:#left across:1 tooltip:"The number of vertices (verts) in the export target"
			Label RealVertices "" align:#left across:2 tooltip:"The real number of vertices in the export target. Takes into account normals (smoothing groups), UVs (including lightmap UVs), vertex colours, the base vertex count etc"
			Label UVs "" align:#left across:1 tooltip:"The number of UV channels - you should have at least 2"
			
			Label MeshDensityLabel "Average Density (vertices/cm³)" align:#left across:2 tooltip:"On average how dense is the mesh? Takes an average of all the vertices in the mesh relative to its real world bounds. *This is only a guideline!"
			ProgressBar MeshDensity value:100 color:errorColour
			
			Label HasLightmapUVsLabel "Has Lightmap UVs? " align:#left across:2 tooltip:"Do we have lightmap UVs? Lightmap UVs are in UV2 (the second UV channel)"
			ProgressBar HasLightmapUVs value:100 color:errorColour
			
			Label HasCollisionLabel "Number of Colliders: 0" align:#left across:2 tooltip:"Do we have collision objects? These will be prefixed with UBX, UCX etc"
			ProgressBar HasCollision value:100 color:errorColour
			DropDownList CollidersList "" items:#() align:#right
			on CollidersList selected s do
			(
				Select MyStats.colliders[s]
				actionMan.executeAction 0 "310"  -- Tools: Zoom Extents Selected
			)
		
			Label HasLODsLabel "Number of LODs: 0" align:#left across:2 tooltip:"Do we have any LODs? You should have 1-2 for real world assets. These will be prefixed with LOD#. For example; GardenChair_SM_LOD0"
			ProgressBar HasLODs value:100 color:errorColour
			DropDownList LODsList "" items:#() align:#right
			on LODsList selected s do
			(
				Select MyStats.LODs[s]
				actionMan.executeAction 0 "310"  -- Tools: Zoom Extents Selected
			)
			
			Button RefreshStats "Refresh Statistics" align:#left across:2 width:(MyStats.grabViewportSize.x / 2.0) height:buttonHeight iconName:@"MaxScript\ParamWiring\Refresh" iconSize:[20, 20] tooltip:"Refresh statistics"
			CheckButton ToggleBackfaceCulling "Toggle Backface Culling" align:#left across:1 width:(MyStats.grabViewportSize.x / 2.0) height:buttonHeight tooltip:"Toggle backface culling on/off" iconName:@"StateSets\BackFaceCull" iconSize:[20, 20]
		)
		
		local exporterClasses = exporterPlugin.classes
		local exporterIndex = 9 --fbx exporter
		
		group "  File Options  "
		(
			EditText Directory "" readOnly:true text:maxFilePath fieldWidth:300 align:#left across:2 tooltip:"Directory to export to" height:buttonHeight
			Button SelectFolder "Folder" align:#right across:2 width:50 height:buttonHeight tooltip:"Select the directory to export to" iconName:@"CivilView\Open"
			EditText FileName "" text:"" across:2 align:#left fieldWidth:300 tooltip:"File name" height:buttonHeight
			Button ResetFileName "Reset" align:#right width:50 height:buttonHeight tooltip:"Reset file name to the name of the mesh" iconName:@"CivilView\Reset"
			
			Button SaveFile "Save Max File" align:#left across:2 tooltip:"Saves the current max scene file in the selected version. Defaults to 2016." width:(MyStats.grabViewportSize.x / 2.0) height:buttonHeight iconName:@"MaterialEditor\SavePreview" iconSize:[20, 20]
			DropDownList Version items:#("2011", "2012", "2013", "2014", "2015", "2016", "2017") selection:6 width:(MyStats.grabViewportSize.x / 2.0) height:buttonHeight
			
			-- Save max file in selected version
			on SaveFile pressed do
			(
				local FileName = maxFilePath + maxFileName
				local v = Version.items[Version.selection] as integer
				
				if v != 2017 then
					SaveMaxFile (fileName) useNewFile:false saveAsVersion:v
				else
					SaveMaxFile (fileName) useNewFile:false
				
				Print ("Saving " + fileName + " in version: " + (v as string))
			)
			
			on SelectFolder pressed do
			(
				local dir = GetSavePath caption:"Choose Folder To Save Batch" initialDir:(Directory.text)
				if (dir != undefined and dir != "") then Directory.text = dir
			)
			
			on ClearFilename pressed do Filename.text = ""
		)
		
		group "  Export Options  "
		(
			CheckButton Triangulate "Triangulate?" across:3 align:#left tooltip:"Triangulate object on export? - Same as TurnToPoly" checked:true iconName:@"SnapTools\MaxSDK\Xmesh\EdgeSegment" 
			CheckButton MakeConvex "Make Convex?" align:#left tooltip:"Make object surface convex on export? - Same as TurnToPoly" checked:true iconName:@"SnapTools\EModel\SurfEdge" offset:[-90, 0]
			DropDownList PivotOptions "" align:#left items:#("LODs and Colliders use their own pivots", "LODs and Colliders pivots relative to the export target", "Use world space as pivot (no changes - export as is)") offset:[-175, 0] width:295 height:buttonHeight
			Button FBXSettings "FBX Settings" align:#left across:2 iconName:@"Common\Settings" height:(buttonHeight * 2) width:(buttonHeight * 2) iconSize:[32, 32] tooltip:"FBX settings - will force defaults on required for export!"
			Button Export "Export" align:#left tooltip:"Export the targeted mesh" width:(MyStats.grabViewportSize.x - 50) height:(buttonHeight * 2) offset:[-125, 0] iconName:@"CommandPanel\Motion\BipedRollout\MotionFlow\SaveClipFiles" iconSize:[32, 32]
		)
		
		function SetFBXDefaults = 
		(
			pluginManager.loadClass FbxExporter;
			FBXExporterSetParam "ScaleFactor" 1.0 -- Force the scale factor to be correct
			FBXEXporterSetParam "SmoothingGroups" true -- Export smoothing groups/normals
			FBXEXporterSetParam "TangentSpaceExport" false -- Don't export tangents as we want to use UE4's calculated MiKk tangent space
			FBXExporterSetParam "Animation" false -- We are only exporting static meshes
			FBXExporterSetParam "SmoothMeshExport" false -- We don't want subdivisions
		)
		
		on FBXSettings pressed do
		(
			SetFBXDefaults()
			OpenFBXSetting()
		)
		
		function GetLODButton buttonName press:true findType:false = 
		(
			max utility mode
			UtilityPanel.OpenUtility Level_of_Detail
			local window = Windows.GetChildrenHWND #max
			local LODpanel
			
			for w in window do
			(
				if w[5] == "Level of Detail Set:" then
					LODpanel = w
			)
			
			if LODpanel != undefined then
			(
				window = Windows.GetChildrenHWND #max parent:LODpanel[3]
				
				for w in window do
				(
					if (findType and w[4] == buttonName) or w[5] == buttonName then
					(
						if press then UIAccessor.PressButton w[1] -- Call press button event from Windows
						return w
					)
				)
			)
		)
		
		function ExportTarget showFBXSettings:false =
		(
			if (MyStats.target != undefined) then
			(
				max modify mode
				ResumeEditing()
				DisableSceneRedraw()
				undo Off()
				
				local LODgroup
			
				-- Select the target mesh and all its LODs and colliders
				if MyStats.LODs.count > 0 then
				(
					Select MyStats.target
					
					for l in MyStats.LODs do
						SelectMore l
					
					LODgroup = Group selection name:(UniqueName "SumoLODs")
					select LODgroup

					GetLODButton "Create New Set"
					max modify mode
				)
				
				-- Select all meshes to export
				Select MyStats.target
				for l in MyStats.LODs do SelectMore L
				for c in MyStats.colliders do SelectMore c
					
				local targetPivot = MyStats.target.pos
				local LODPivots = #()
				local colliderPivots = #()
					
				case PivotOptions.selection of
				(
					1:
					(
						MyStats.target.pos = [0, 0, 0]
						
						for l in MyStats.LODs do
						(
							Append LODPivots l.pos
							l.pos = [0, 0, 0]
						)
						
						for c in MyStats.colliders do
						(
							Append colliderPivots c.pos
							c.pos = [0, 0, 0]
						)
					)
					
					2:
					(
						MyStats.target.pos = [0, 0, 0]
						for l in MyStats.LODs do l.pos = l.pos - targetPivot				
						for c in MyStats.colliders do c.pos = c.pos - targetPivot
					)
				)

				-- Make all convex
				for s in selection while SuperClassOf(s) == GeometryClass do
				(
					modPanel.AddModToSelection(Turn_To_Poly())
					s.Turn_To_Poly.keepConvex = MakeConvex.checked
					s.Turn_To_Poly.limitPolySize = true
					if Triangulate.checked then s.Turn_To_Poly.maxPolySize = 3 else s.Turn_To_Poly.maxPolySize = 4
				)
				
			
				-- FBX Export
				if showFBXSettings then OpenFBXSetting()
				SetDir #export Directory.text
				ExportFile FileName.text #noPrompt selectedOnly:true using:exporterClasses[exporterIndex] --export selected mesh
				
				case PivotOptions.selection of
				(
					1:
					(
						MyStats.target.pos = targetPivot
						for i = 1 to MyStats.LODs.count do MyStats.LODs[i].pos = LODPivots[i]
						for i = 1 to MyStats.colliders.count do MyStats.colliders[i].pos = colliderPivots[i]
					)
					
					2:
					(
						MyStats.target.pos = targetPivot
						for l in MyStats.LODs do l.pos = l.pos + targetPivot
						for c in MyStats.colliders do c.pos = c.pos + targetPivot
					)
				)
				
				-- Remove LODs from Max's LOD system
				if MyStats.LODs.count > 0 then
				(
					ungroup LODgroup
					
					local listControl = GetLODButton "ListBox" press:false findType:true
					local removeFromSetButton = GetLODButton "Remove From Set" press:false findType:false
					
					local meshes = #()
					for l in MyStats.LODs do Append meshes l
					Append meshes MyStats.target
						
					for m in meshes do
					(
						local LB_MESSAGE = 0x0186 -- http://www.temblast.com/ref/wndmsg.htm
						Select m -- Select each mesh
						Windows.SendMessage listControl[1] LB_MESSAGE 0 1 -- Select first item in ListBox
						UIAccessor.PressButton removeFromSetButton[1]
					)

					max modify mode
				)
				
				-- Select all meshes to export
				Select MyStats.target
				for l in MyStats.LODs do SelectMore L
				for c in MyStats.colliders do SelectMore c
				for s in selection while SuperClassOf(S) == GeometryClass do DeleteModifier s 1 -- Remove Turn_To_Poly modifiers
				
				-- Update cached file
				MyCached.AddExportedMesh MyStats.target Directory.text FileName.text override:true
				MyCached.UpdateFile()

				EnableSceneRedraw()
				undo On()
			)
		)
		
		on Export pressed do ExportTarget()
		
		on Thumbnail mousedown do
		(
			if (MyStats.target != undefined) then
			(
				select MyStats.target
				actionMan.executeAction 0 "310"  -- Tools: Zoom Extents Selected
			)
		)
		
		on ResetFileName pressed do
		(
			if MyStats.target != undefined then
				FileName.text = MyStats.target.name
		)
		
		function UpdateStatsUI = 
		(
			MyStats.Update()
			RefreshStats.enabled = MyStats.target != undefined
			ToggleBackfaceCulling.enabled = MyStats.target != undefined
			
			if (MyStats.target != undefined) then
			(
				if MyStats.target.isHidden then MyStats.target.isHidden = false
				SelectTarget.text = "[ " + MyStats.target.name + " ]"
				ToggleBackfaceCulling.checked = MyStats.target.backFaceCull
				
				-- Update file name and directory input boxes
				local found = false
				for m in MyCached.exportedMeshes do
				(
					if m.name == MyStats.target.name then
					(
						Directory.text = m.dir
						FileName.text = m.fileName
						found = true
						exit
					)
				)
				
				if not found then
				(
					Directory.text = maxFilePath
					FileName.text = MyStats.target.name
				)
			)
			
			Thumbnail.bitmap = MyStats.grabViewport
			
			Triangles.text = "Triangles: " + (MyStats.triangles as string)
			Vertices.text = "Vertices: " + (MyStats.vertices as string)
			RealVertices.text = "Real Vertices: " + (MyStats.GetRealNumVertices() as string)
			UVs.text = "Number of UVs: " + (MyStats.numUVs as string)
				
			MeshDensity.color = LerpSuccess (1.0 - (Saturate (MyStats.density / 100.0)))
			MeshDensityLabel.text = "Average Density: " + (IntToString MyStats.density) + " vertices/cm³"
			HasLightmapUVs.color = LerpSuccess (BoolToInt (MyStats.numUVs > 1))
			
			HasCollisionLabel.text = "Number of Colliders: " + (MyStats.colliders.count as string)
			HasCollision.color = LerpSuccess (BoolToInt (MyStats.colliders.count > 0))
			CollidersList.items = for c in MyStats.colliders collect c.name
			CollidersList.enabled = MyStats.colliders.count > 0
				
			HasLODsLabel.text = "Number of LODs: " + (MyStats.LODS.count as string)
			HasLODs.color = LerpSuccess (MyStats.LODs.count / 2.0)
			LODsList.items = for l in MyStats.LODs collect l.name
			LODsList.enabled = MyStats.LODs.count > 0
			
			Export.enabled = MyStats.target != undefined
		)
		
		on SelectTarget picked obj do 
		(
			MyStats.target = obj
			UpdateStatsUI()
		)
		
		on StatsAndExportUI open do
		(
			SetFBXDefaults()
			UpdateStatsUI()
		)
		
		on RefreshStats pressed do UpdateStatsUI()
		on ToggleBackfaceCulling changed toggled do if (MyStats.target != undefined) then MyStats.target.backFaceCull = ToggleBackfaceCulling.checked -- Flip
	)
	
	-- =============================================================================================== PIVOT HANDLING =================================================================================================

	rollout PivotUI "Pivot Tools"
	(
		local buttonSize = 50
		
		Button MaxZ "+Z" align:#center across:1 width:buttonSize height:buttonHeight tooltip:"Set pivot to max bounds Z" iconName:@"Common\UIComponents\ArrowUp"
		on MaxZ pressed do if (MyStats.target != undefined) then MyStats.target.pivot.z = MyStats.target.max.z
		Button MinX "-X" align:#right across:3 width:buttonSize height:buttonHeight tooltip:"Set pivot to min bounds X" iconName:@"Common\ArrowHeadLeft"
		on MinX pressed do if (MyStats.target != undefined) then MyStats.target.pivot.x = MyStats.target.min.x
		Button Centre "Centre" align:#center width:buttonSize height:buttonHeight tooltip:"Set pivot to the centre of the object's bounds" iconName:@"EditUVW\PivotCenter"
		on Centre pressed do if (MyStats.target != undefined) then CenterPivot MyStats.target
		Button MaxX "+X" align:#left width:buttonSize height:buttonHeight tooltip:"Set pivot to max bounds X" iconName:@"Common\TreeView\Closed"
		on MaxX pressed do if (MyStats.target != undefined) then MyStats.target.pivot.x = MyStats.target.max.x
		Button MinY "-Y" align:#right across:3 width:buttonSize height:buttonHeight tooltip:"Set pivot to min bounds Y" iconName:@"EditUVW\PivotLowerLeft"
		on MinY pressed do if (MyStats.target != undefined) then MyStats.target.pivot.y = MyStats.target.min.y
		Button MinZ "-Z" align:#center width:buttonSize height:buttonHeight tooltip:"Set pivot to min bounds Z" iconName:@"Common\UIComponents\ArrowDown"
		on MinZ pressed do if (MyStats.target != undefined) then MyStats.target.pivot.z = MyStats.target.min.z
		Button MaxY "+Y" align:#left width:buttonSize height:buttonHeight tooltip:"Set pivot to max bounds Y" iconName:@"EditUVW\PivotLowerRight"
		on MaxY pressed do if (MyStats.target != undefined) then MyStats.target.pivot.y = MyStats.target.max.y
		
		PickButton StealPivot "Steal Pivot" align:#left across:2 width:(MyStats.grabViewportSize.x / 2.0) height:buttonHeight tooltip:"Steal pivot from target object"
		on StealPivot picked obj do if (MyStats.target != undefined) then MyStats.target.pivot = obj.pivot
		Button ZeroPivot "Zero Pivot" align:#right  width:(MyStats.grabViewportSize.x / 2.0) height:buttonHeight tooltip:"Set pivot to (0,0,0)"
		on ZeroPivot pressed do if (MyStats.target != undefined) then MyStats.target.pivot = [0.0, 0.0, 0.0]
	)
	
	
	UI = NewRolloutFloater "Sumo Exporter" 400 895
	AddRollout StatsAndExportUI UI
	AddRollout PivotUI UI
)

macros.run "Sumo Scripts" "SumoExporter" -- Run when dragged into the scene as well as add the MacroScript to the "Sumo Scripts" category