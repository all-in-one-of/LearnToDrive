macroScript BatchExport
category: "Calvinatorr_Custom"
tooltip: "Batch Export"
(
	fn GetRoot node = if isvalidnode node.parent then getRoot node.parent else node
	
	fn SelectAllChildren =
	(
		for obj in selection do
		(
			if obj.children != undefined do
			(
				selectmore obj.children
			)
		)
	)
	
	--check if file exists
	function FileExists fileName =
	(
		(GetFiles fileName).count != 0
	)
	
	local exporterClasses = exporterPlugin.classes;
	
	function ExportSingle mesh prompt:false resetToOrigin:true exporterIndex:9 = 
	(
		Select mesh; --select mesh
		max modify mode;
		local bufferPos = mesh.pos;
		if (resetToOrigin) then mesh.pos = [0, 0, 0]; --reset to origin

		SelectAllChildren();
		
		--local meshList = for s in selection where SuperClassOf s == GeometryClass collect s;
		--local meshList = for c in currentMesh.children collect c;
		local meshList = for s in selection collect s;
		
		for m in meshList do
		(
			Select m;
			
			if (SuperClassOf m == GeometryClass) then
			(
				modPanel.AddModToSelection (Turn_To_Poly());
				$.Turn_To_Poly.keepConvex = true;
				$.Turn_To_Poly.maxPolySize = 4; --limit to 3 polygons on currently selected object
				$.Turn_To_Poly.limitPolySize = true; --toggle limit poly size so it triangulates mesh
			)
		)
		
		for m in meshList do
		(
			SelectMore m;
		)
		
		--select Mesh;
		--max modify mode;
		--modPanel.AddModToSelection (Turn_To_Poly());
		--$.Turn_To_Poly.keepConvex = true;
		--$.Turn_To_Poly.maxPolySize = 4; --limit to 3 polygons on currently selected object
		--$.Turn_To_Poly.limitPolySize = true; --toggle limit poly size so it triangulates mesh
		
		if (prompt) then
		(
			if (exporterIndex == 9) then
			(
				pluginManager.loadClass FbxExporter;
				--FBXExporterSetParam "ConvertUnit" "in";
				FBXExporterSetParam "ScaleFactor" 1.0;
				FBXEXporterSetParam "SmoothingGroups" true;
				FBXEXporterSetParam "TangentSpaceExport" true;
				FBXExporterSetParam "Animation" false;
				FBXExporterSetParam "SmoothMeshExport" false;
				
				OpenFBXSetting();
				ExportFile mesh.name #noPrompt selectedOnly:true using:exporterClasses[exporterIndex]; --export selected mesh
			)
			else
			(
				ExportFile mesh.name selectedOnly:true using:exporterClasses[exporterIndex]; --export selected mesh
			)
		)
		else
		(
			ExportFile mesh.name #noPrompt selectedOnly:true using:exporterClasses[exporterIndex]; --export selected mesh
		)
		
		for m in meshList do
		(
			if (SuperClassOf m == GeometryClass) then
			(
				Select m;
				DeleteModifier $ 1; --delete turn to poly
			)	
		)
		
		--DeleteModifier $ 1; --delete turn to poly
		mesh.pos = bufferPos; --reset back to original position
		Select mesh;
	)

	rollout UI "Batch Export"
	(
		DropDownList ExporterList "Exporter:" items:(for e in exporterClasses collect (e as string)) selection:9;
		Button SelectFolder "Folder" align:#left across:2;
		EditText Directory "" readOnly:true text:maxFilePath fieldWidth:220 align:#right across:2;

		CheckBox ResetToOrigin "Reset To (0, 0, 0)" tooltip:"Resets only on export" checked:true across:3 align:#left;
		CheckBox ExportLink "Export Hierarchy" tooltip:"Exports from the top most parent" checked:true across:3 align:#left;
		Button Export "Export Batch" across:3 align:#right tooltip:"BUG: Incorrect scale factor on first exported object using FBX. FIX: Change unit conversion to automatic (scale factor will become 1.0)";
			
		ProgressBar Progress value:0 align:#center;
			
		function CalcProgress minimum maximum = 
		(
			Progress.value = minimum / maximum * 100;
		)
			
		on SelectFolder pressed do
		(
			Directory.text = GetSavePath caption:"Choose Folder To Save Batch" initialDir:(maxFilePath);
		)
		
		on Export pressed do
		(
			--local meshList = for s in selection where SuperClassOf s == GeometryClass collect s;
			local meshList = for s in selection collect s;
				
			if (Directory.text != null) then --if directory isn't blank
			(
				SetDir #export Directory.text; --set the current directory
			)
			else
			(
				SetDir #export maxFilePath; --else default to the working directory
			)

			if (meshList.count > 0) then 
			(
				ExportSingle meshList[1] prompt:true resetToOrigin:ResetToOrigin.checked exporterIndex:ExporterList.selection; --export first mesh with settings so it works across any exporter
				CalcProgress 1 meshList.count;
			)
				
			if (meshList.count > 1) then
			(
				for i = 2 to meshList.count do
				(
					ExportSingle meshList[i] prompt:false resetToOrigin:ResetToOrigin.checked exporterIndex:ExporterList.selection; --export the rest of the meshes with those settings and no prompt
					CalcProgress i meshList.count;
				)
			)
				
			DestroyDialog UI;
		)
	)
	CreateDialog UI 325 125;
)