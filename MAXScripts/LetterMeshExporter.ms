macroScript LetterMeshExporter
category: "Calvinatorr_Custom"
tooltip: "Letter Mesh Exporter"
(
	--check if file exists
	function FileExists fileName =
	(
		(GetFiles fileName).count != 0
	)
	
	Rollout UI "Letter Mesh Exporter"
	(
		local letterText
		local exporterClasses = exporterPlugin.classes;
		
		Label ASCIILAbel "ASCII " across:3 align:#left
		Spinner ASCIIMin "Min" range:[0, 255, 33] across:3 align:#left type:#integer
		Spinner ASCIIMax "Max" range:[0, 255, 126] across:3 align:#right type:#integer
		EditText ASCIIDisplay "" readOnly:true text:"" fieldWidth:220 align:#right
		
		Button Export "Export" align:#center
		
		
		function UpdateASCII =
		(
			ASCIIDisplay.text = ""
			for i = ASCIIMin.value to ASCIIMax.value do
			(
				ASCIIDisplay.text = ASCIIDisplay.text + (bit.IntAsChar i)
			)
		)
		
		on ASCIIMin changed arg do
		(
			UpdateASCII()
			letterText.text = ASCIIDisplay.text
		)
		
		on ASCIIMax changed arg do
		(
			UpdateASCII()
			letterText.text = ASCIIDisplay.text
		)
		
		on Export pressed do
		(
			Select letterText
			MakeDir (maxFilePath + "/LetterMeshes") all:true
			SetDir #export (maxFilePath + "/LetterMeshes") --else default to the working directory
			
			pluginManager.loadClass FbxExporter
			FBXExporterSetParam "ScaleFactor" 1.0
			FBXEXporterSetParam "SmoothingGroups" true
			FBXEXporterSetParam "TangentSpaceExport" true
			FBXExporterSetParam "Animation" false
			FBXExporterSetParam "SmoothMeshExport" false
			OpenFBXSetting()
			
			local minVal = ASCIIMin.value
			local maxVal = ASCIIMax.value

			for i = minVal to maxVal do
			(
				letterText.text = (bit.IntAsChar i)
				CenterPivot letterText
				letterText.pos = [0, 0, 0]
				Select letterText
				
				ExportFile ("SM_LetterMesh_" + letterText.text) #noPrompt selectedOnly:true using:exporterClasses[9]
			)
			
			Delete letterText
			DestroyDialog UI
		)
		
		on UI open do
		(
			letterText = text size:100 kerning:0 leading:0 pos:[0, 0, 0] isSelected:on name:"Letter Mesh"
			actionMan.executeAction 0 "50001"
			
			max modify mode
			select letterText
			modPanel.AddModToSelection(Shell())
			modPanel.AddModToSelection(Turn_To_Poly())
			$.Turn_To_Poly.keepConvex = true
			$.Turn_To_Poly.maxPolySize = 4 --limit to 3 polygons on currently selected object
			$.Turn_To_Poly.limitPolySize = true --toggle limit poly size so it triangulates mesh
			
			UpdateASCII()
			letterText.text = ASCIIDisplay.text
		)
	)
	
	CreateDialog UI 250 75
)

macros.run "Calvinatorr_Custom" "LetterMeshExporter"