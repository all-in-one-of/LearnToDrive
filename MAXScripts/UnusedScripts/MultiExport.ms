macroScript MultiExport
category: "Calvinatorr_Custom"
tooltip: "Multi Export"
(
	pluginManager.LoadClass FBXEXP;
	pluginManager.LoadClass FBXEXPORTER;
	global exporter = FindItem exporterPlugin.classes FBXEXP;
	global theClasses = exporterPlugin.classes;

	--get renamed material based on a given prefix
	function GetRenamedMaterial mesh prefixLength =
	(
		meshName = "TX";
		
		for i = (prefixLength + 1) to mesh.name.count do
		(
			meshName += mesh.name[i];
		)
		
		return meshName;
	)
	
	--check if file exists
	function FileExists fileName =
	(
		(GetFiles fileName).count != 0
	)
	
	--main export algorithm
	function ExportMultiple exportList:(for o in selection where superclassof o == GeometryClass collect o) openSettingsOnEachExport:false resetToCenter:true overwriteFile:true materialName:"" renameMaterial:true = --export selected by default
	(
		if (exportList.count > 0) then --if not cancelled then export all objects
		(
			FBXExporterSetParam "Animation" false;
			FBXExporterSetParam "SmoothingGroups" true;
			FBXExporterSetParam "TangentSpaceExport" true;
			
			if (not openSettingsOnEachExport) then
			(
				if (not OpenFBXSetting()) then return false;
			)
			
			local bufferPos;
			local s;
			
			print (exportList.count as string);
			
			for s in exportList do
			(
				Select s;
				
				if (resetToCenter) then
				(
					bufferPos = s.pos;
					s.pos = [0, 0, 0];
				)
				
				local currentFileName = s.name + ".FBX";

				if (overwriteFile or (FileExists(currentFileName) and (QueryBox(currentFileName + ".fbx already exists, overwrite?")))) then --overwrite file or if file exists then query whether to overwrite
				(
					if ((not materialName == "") and (renameMaterial)) then --rename material if given a name
					(
						s.material.name = materialName;
					)
					
					if (openSettingsOnEachExport) then
					(
						ExportFile (s.name) selectedOnly:true;-- using:theClasses[exporter];
					)
					else
					(
						ExportFile (s.name) #noPrompt selectedOnly:true;-- using:theClasses[exporter];
					)
					
					Print(currentFileName + " exported");
				)
				else
				(
					Print(currentFileName + " export aborted");
				)
			
				s.pos = bufferPos;
			)
		)
	)
	
	rollout UI "Export Settings" --main interface
	(
		--DropDownList ExporterType "Exporter Plugin" items:#("FBX", "Wavefront OBJ") align:#left tooltip:"Choose an exporter, FBX by default" height:3;
		
		Checkbox ResetToCenterCheckbox "Reset To [0, 0, 0] World Space" checked:true align:#left tooltip:"Temporarily resets to world space [0, 0, 0] based on pivot for exporting";
		Checkbox OpenSettingsCheckbox "Open Export Settings On Each Export (Legacy Pre-2016)" checked:false align:#left tooltip:"Check if using a version of 3ds Max older than 2016"
		Checkbox OverwriteCheckbox "Overwrite Existing Files!" checked:true align:#true;
		
		Button SelectFolderButton "<<Select Folder>>" align:#left across:2;
		EditText FolderDirPreview "" readOnly:true align:#right text:maxFilePath across:2 fieldWidth:200;
		
		Checkbox RenameMaterialsCheckbox "Rename Materials" checked:false align:#left across:2 tooltip:"Replaces prefix with TX, eg. SM_Props_Sword material becomes TX_Props_Sword";
		Spinner PrefixLengthSpinner "Prefix Length:" align:#left across:2 range:[0, 10, 2] scale:1 type:#integer tooltip:"eg. SM_Props_Sword - SM is the prefix";
		EditText MaterialNamePreview "Material Name Preview: " align:#left readOnly:true;
		
		Button ExportSelectedButton "Export Selected" align:#left tooltip:"Exports only selected objects" across:3;
		Button ExportAllButton "Export All" align:#center tooltip:"Exports all objects in the scene" across:3;
		Button ExportVisibleButton "Export Visible" align:#right tooltip:"Exports all visible objects in the scene" across:3;
		
		function CalcMaterialNamePreview prefixLength =
		(
			if (selection.count > 0) then
			(
				if (not RenameMaterialsCheckbox.checked) then
				(
					if (not selection[1].material == undefined) then MaterialNamePreview.text = selection[1].material.name;
				)
				else
				(
					MaterialNamePreview.text = (GetRenamedMaterial selection[1] prefixLength);
				)
			)
			else if (objects.count > 0) then
			(
				if (not RenameMaterialsCheckbox.checked) then
				(
					MaterialNamePreview.text = objects[1].material.name;
				)
				else
				(
					MaterialNamePreview.text = (GetRenamedMaterial objects[1] prefixLength);
				)
			)
			else
			(
				MaterialNamePreview.text = "No Objects In Scene!";
			)
		)
		
		on UI open do
		(
			CalcMaterialNamePreview PrefixLengthSpinner.value;
			overwriteFile = OverwriteCheckbox.checked;
			RenameMaterialsCheckbox.checked = false;
			SetDir #export maxFilePath;
		)
		
		on RenameMaterialsCheckbox changed arg do
		(m
			CalcMaterialNamePreview PrefixLengthSpinner.value;
		)
		
		on PrefixLengthSpinner entered do
		(
			CalcMaterialNamePreview PrefixLengthSpinner.value;
		)
		
		on SelectFolderButton pressed do
		(
			dir = GetSavePath caption:"Choose Folder To Save Batch" initialDir:(maxFilePath)
			
			if (dir != null) then
			(
				SetDir #export dir;
				FolderDirPreview.text = dir;
			)
		)
		
		function LocalExport exportList =
		(
			ExportMultiple exportList:exportList resetToCenter:ResetToCenterCheckbox.checked openSettingsOnEachExport:OpenSettingsCheckbox.checked\
			overwriteFile:OverwriteCheckbox.checked materialName:(CalcMaterialNamePreview PrefixLengthSpinner.value) renameMaterial:RenameMaterialsCheckbox.checked;
			
			DestroyDialog UI;
		)
		
		on ExportSelectedButton pressed do 
		(
			if (selection.count <= 0) then
			(
				MessageBox "No objects selected!" title:"ERROR";
			)
			else
			(
				LocalExport (for o in selection where superclassof o == GeometryClass collect o);
			)
		)
		on ExportAllButton pressed do
		(
			if ($*.count > 0) then
			(
				LocalExport objects;
			)
		)
		on ExportVisibleButton pressed do
		(
			LocalExport (for o in objects where (superclassof o == GeometryClass and not o.isHidden) collect o);
		)
	)
	
	--pluginManager.LoadClass(FBXExporter);
	CreateDialog UI 350 170;
)