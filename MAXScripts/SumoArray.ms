plugin simpleMeshMod SumoArray
	name:"SumoArray"
	classID:#(0x7A7B3105, 0x7BC2637F)
	category:"Max Creation Graph"
	usePBValidity:true
(
	local pluginDefinitionFile -- the plugin definition file
	local pluginInstance -- the plugin instance created from the plugin definition
	local _meshWrapper -- the dotnet wrapper around the stack mesh pointer
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject
	local tmHandler
	--simulation locals
	local _lastTime = 0.0
	local interactiveMode = false

	-- function wrappers
	local _meshWrapper_SetValue
	local pluginInstance_UpdateMesh

	-- value wrapper local and function wrapper declarations
	local paramsOpen = false
	local meshWrapper, meshWrapper_SetValue
	local TranslationWrapper, TranslationWrapper_SetValue
	local RotationWrapper, RotationWrapper_SetValue


	parameters main rollout:params
	(
		Count ui:Count default:1 type:#integer animatable:true
		Translation type:#point3 default:[0,0,0]
		on Translation set val do 
		( 
			if paramsOpen then (
				this.params.Translation_XSpinner.value = val.X
				this.params.Translation_YSpinner.value = val.Y
				this.params.Translation_ZSpinner.value = val.Z 
			)
		)
		Rotation type:#point3 default:[0,0,0]
		on Rotation set val do 
		( 
			if paramsOpen then (
				this.params.Rotation_XSpinner.value = val.X
				this.params.Rotation_YSpinner.value = val.Y
				this.params.Rotation_ZSpinner.value = val.Z 
			)
		)
		_dummy type:#boolean -- this exists to enable easy invalidation of the object
		pluginGraph type:#filename assettype:#MaxCreationGraph readOnly:true enumAsAsset:true 
		pluginGraphDependencies type:#filenametab assettype:#MaxCreationGraph readOnly:true enumAsAsset:true tabSize:0 tabSizeVariable:true
	)



	fn RunSimLoop updateFxn = (
		local result = ok
		try (
			result = updateFxn ()
		)
		catch()
		return result
	)

	fn initialize = 
	(
		pluginDefinitionFile = @"E:/Documents/PostUniversity/LearnToDrive/MAXScripts/SumoArray.maxtool"
		local c = dotNetClass "Viper3dsMaxBridge.ModifierPluginInstance"
		local cid = this.classId
		local refMakerWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.ReferenceMaker"
		refMakerWrapper = refMakerWrapperClass._CreateWrapper this
		pluginInstance = c.CreateInstance cid[1] cid[2] pluginDefinitionFile refMakerWrapper
		pluginInstance_UpdateMesh = pluginInstance.UpdateMesh
		local meshWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.Mesh"
		_meshWrapper = meshWrapperClass._CreateWrapper undefined
		_meshWrapper_SetValue = _meshWrapper._SetValue
		pluginGraph = pluginDefinitionFile
		pluginGraphDependencies = #(@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\CloneAndTransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local TranslationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		TranslationWrapper = TranslationWrapperClass._CreateWrapper ([0,0,0])
		TranslationWrapper_SetValue = TranslationWrapper._SetValue
		local RotationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		RotationWrapper = RotationWrapperClass._CreateWrapper ([0,0,0])
		RotationWrapper_SetValue = RotationWrapper._SetValue

	)

	on create do 
	(
		initialize()
	)

	on clone fromObj do 
	(
		initialize()
	)

	on load do 
	(
		initialize()
	)

	on update do 
	(
		initialize()
	)

	rollout params "Parameters"
	(
		spinner Count "Count" range:[1, 500, 1] type:#integer
		label Translation_Label "Translation" align:#left
		spinner Translation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner Translation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner Translation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on Translation_XSpinner changed val do ( Translation.X = val ; _dummy = not _dummy )
		on Translation_YSpinner changed val do ( Translation.Y = val ; _dummy = not _dummy )
		on Translation_ZSpinner changed val do ( Translation.Z = val ; _dummy = not _dummy )

		label Rotation_Label "Rotation" align:#left
		spinner Rotation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner Rotation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner Rotation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on Rotation_XSpinner changed val do ( Rotation.X = val ; _dummy = not _dummy )
		on Rotation_YSpinner changed val do ( Rotation.Y = val ; _dummy = not _dummy )
		on Rotation_ZSpinner changed val do ( Rotation.Z = val ; _dummy = not _dummy )

		on params open do
		(
			paramsOpen = true

			Translation_XSpinner.value = Translation.X
			Translation_YSpinner.value = Translation.Y
			Translation_ZSpinner.value = Translation.Z

			Rotation_XSpinner.value = Rotation.X
			Rotation_YSpinner.value = Rotation.Y
			Rotation_ZSpinner.value = Rotation.Z

		)
		on params close do
		(

			paramsOpen = false
		)
	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, Count, TranslationWrapper, RotationWrapper) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		TranslationWrapper_SetValue Translation
		if (paramsOpen) then (
		 	params.Translation_XSpinner.value = Translation.X
		 	params.Translation_YSpinner.value = Translation.Y
		 	params.Translation_ZSpinner.value = Translation.Z
		)
		RotationWrapper_SetValue Rotation
		if (paramsOpen) then (
		 	params.Rotation_XSpinner.value = Rotation.X
		 	params.Rotation_YSpinner.value = Rotation.Y
		 	params.Rotation_ZSpinner.value = Rotation.Z
		)
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
