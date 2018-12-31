macroScript CoatsinkExporter
category: "Coatsink"
tooltip: "AEMesh Exporter"
(
	--file I/O
	global currentDir = maxFilePath; --current directory
	global currentFileName = "";
	global currentFile;
	global FILE_EXTENSION = "AEMesh";
	global debug = false;
	
	--misc
	global MAX_NUM_OF_UV_CHANNELS = 100;
	--global numOfUVChannels = 2;
	global resetToCenter = false;
	
	global meshList;
	
	if (selection.count > 0) then
	(
		meshList = for o in selection where superclassof o == GeometryClass collect o;
	)
	else if (objects.count > 0) then
	(
		meshList = for o in objects where superclassof o == GeometryClass collect o;
	)
	
	--check if file exists
	function FileExists fileName =
	(
		return (GetFiles fileName).count != 0;
	)
	
	function FormatFileName fileName = 
	(
		return (currentDir + "\\" + fileName + "." + FILE_EXTENSION);
	)
	
	function AppendDebug tag:"" =
	(
		if (debug and tag != "" and tag != undefined) then
		(
			Format(" #" + tag) to:currentFile;
		)
	)
	
	function WriteNumToFile num: tag:"" =
	(
		Format (num as string) to:currentFile; --write number to file
		
		AppendDebug tag:tag; --append debug tag if debug is toggled
		
		Format "\n" to:currentFile;
	)
	
	function WriteStrToFile str: tag:"" =
	(
		Format str to:currentFile; --write number to file
		
		AppendDebug tag:tag; --append debug tag if debug is toggled
		
		Format "\n" to:currentFile;
	)
	
	function WriteVectorToFile vec: tag:"" =
	(
		line = (vec as string); --cast vector to string - will become the line written to file
		
		for char = 1 to line.count do --for each character
		(
			if (line[char] == ",") then --if a separater
			(
				AppendDebug tag:tag;
				Format "\n" to:currentFile;
				--Format " " to:currentFile; --write a whitespace to file instead
			)
			else if (line[char] != "[" and line[char] != "]") then --else if not an invalid character
			(
				Format line[char] to:currentFile; --write character to file
			)
		)
		
		AppendDebug tag:tag; --append debug tag if debug is toggled
	)

	struct Vertex (pos, normal, tangent, colour, UV = #())
	--struct NewMesh (Vertex = #(), indices = #(), 
		
	function CompareVertex a b = 
	(
		--local equal = ((a.pos == b.pos) and (a.normal == b.normal) and (a.tangent == b.tangent) and (a.colour == b.colour) and (a.UV.count == b.UV.count));
		local equal = ((a.pos == b.pos) and (a.normal == b.normal) and (a.colour == b.colour) and (a.UV.count == b.UV.count));
		
		if (equal) then --if equal so far then find if UVs are equal or not
		(
			for i = 1 to a.UV.count while (not equal) do --for each UV channel
			(
				equal = (equal and (a.UV[i] == b.UV[i]));
			)
		)
		
		equal;
	)
	
	function SwapYZ vec = 
	(
		local buffer = vec;
		vec.y = buffer.z;
		vec.z = buffer.y;
		vec;
	)

	--export single mesh
	function ExportSingleAEMesh mesh =
	(
		Select mesh; --select mesh to export, current selection now pointed to by $ or selection[1]
		
		--triangulate mesh before exporting
		modPanel.AddModToSelection(Turn_To_Poly());
		$.Turn_To_Poly.maxPolySize = 3; --limit to 3 polygons on currently selected object
		$.Turn_To_Poly.limitPolySize = true; --toggle limit poly size so it triangulates mesh
			
		--add modifier to access mesh data
		modPanel.AddModToSelection (Edit_Mesh());
		local meshData = $; 
			
		--modPanel.AddModToSelection(Unwrap_UVW());
			
		--get specific mesh data
		local numOfVertices = GetNumVerts meshData; --get number of vertices
		local numOfFaces = GetNumFaces meshData; --number of faces - indices = faces * 3
			
		--get normals
		modPanel.AddModToSelection (Edit_Normals());
		meshData.Edit_Normals.MakeExplicit();
		local numOfNormals = meshData.Edit_Normals.GetNumNormals();
			
		--vertex colours
		--local enableUVs = (meshOp.GetMapSupport meshData 1); --if there are UV channels
		local enableVertexColours = (meshOp.GetMapSupport meshData 0); --if there are vertex colours
		local enableVertexAlphas = (meshOp.GetMapSupport meshData -2); --if there are vertex alphas
		
		--UV/texture coordinates
		local numOfUVChannels = (meshOp.GetMapSupport meshData 1); --number of UV channels
		if (numOfUVChannels) then numOfUVChannels = (meshOp.GetNumMaps meshData) - 1;
			
		--create mesh in format which can be written to file
		local newMesh = #();
		local indices = #();
		indices[numOfFaces * 3] = 0; --init array
			
		local optimisedVertices = 0;
		
		--construct mesh
		for i = 1 to numOfFaces do --for each face
		(
			--get colour face
			local colourFace;
			if (enableVertexColours) then colourFace = meshOp.GetMapFace meshData 0 i;
			
			--get each UV face for each UV channel
			local texFaces = #();
			texFaces[numOfUVChannels] = [0, 0];
		
			--collect each texture face for each UV channel from the current face
			for UVChannel = 1 to numOfUVChannels do --for each UV map channel
			(
				texFaces[UVChannel] = (meshOp.GetMapFace meshData UVChannel i);
			)
			
			local verticesUV = for i = 1 to 3 collect meshOp.GetMapVert meshData 1 texFaces[1][i]; --get all UV coordinates in triangle for map channel 1 for use in tangents
			local tangentsToAverage = #(0, 0, 0); --list of indices to vertices which tangents need averaging
			local verticesUsed = #(0, 0, 0); --a list of indices to vertices which have been iterated on
			
			for corner = 1 to 3 do --for each corner
			(
				local newVertex = Vertex(); --create new vertex
				
				--fill in mesh data
				local posID = meshData.Edit_Normals.GetVertexID i corner;
				newVertex.pos = GetVert meshData posID;
				
				local normalID = meshData.Edit_Normals.GetNormalID i corner;
				newVertex.normal = meshData.Edit_Normals.GetNormal normalID;
				newVertex.UV[numOfUVChannels] = [0, 0]; --init new UV
				
				newVertex.colour = [0, 0, 0, 1];
				
				if (enableVertexColours) then
				(
					local vertID = colourFace[corner] as integer;
					local vertColour = meshOp.GetMapVert meshData 0 vertID;
					newVertex.colour.x = vertColour.x;
					newVertex.colour.y = vertColour.y;
					newVertex.colour.z = vertColour.z;
				)
				
				if (enableVertexAlphas) then
				(
					local vertAlpha = meshOp.GetMapVert meshData -2 vertID;
					newVertex.colour.w = vertAlpha.x;
				)
				
				--add UV data
				for UVChannel = 1 to numOfUVChannels do --for each UV map channel
				(
					local face = texFaces[UVChannel];
					local vertID = face[corner] as integer;
					local newUV = (meshOp.GetMapVert meshData UVChannel vertID);
					
					newVertex.UV[UVChannel] = [0, 0];
					newVertex.UV[UVChannel].x = newUV.x;
					newVertex.UV[UVChannel].y = newUV.y;
				)
				
				newVertex.tangent = [0, 0, 0, 1];
				
				--optimisation by finding if the newly constructed vertex already exists
				local appendVertex = true; --append new vertex by default
				for ii = 1 to newMesh.count while 	appendVertex do
				(
					if (CompareVertex newVertex newMesh[ii]) then
					(
						indices[(i - 1) * 3 + corner] = ii; --append new index pointing to original of duplicate vertex
						appendVertex = false; --do not append the new vertex as it is a duplicate
						optimisedVertices += 1; --log an optimised vertex
						
						tangentsToAverage[corner] = ii; --average the duplicated vertex tangent with the to be calculated tangent
						verticesUsed[corner] = ii; --this vertex has been iterated and used in this iteration
					)
				)
				
				if (appendVertex) then --if no optimisation has took place then append new vertex
				(
					Append newMesh newVertex;
					indices[(i - 1) * 3 + corner] = newMesh.count;
					verticesUsed[corner] = newMesh.count;
				)
			)
			
			--calculate tangents
			--calculate per-face tangent
			--calculate E1 and E2 from newly constructed face(tri) in mesh
			local edge1 = newMesh[newMesh.count - 1].pos - newMesh[newMesh.count].pos; --pos2 - pos1
			local edge2 = newMesh[newMesh.count - 2].pos - newMesh[newMesh.count].pos; --pos3 - pos1
			
			--calculate delta in map channel 1
			local deltaUV1 = newMesh[newMesh.count - 1].UV[1] - newMesh[newMesh.count].UV[1]; --UV2 - UV1
			local deltaUV2 = newMesh[newMesh.count - 2].UV[1] - newMesh[newMesh.count].UV[1]; --UV3 - UV1
			
			local f = 1.0 / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);
			
			local tangent = [0, 0, 0];
			tangent.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
			tangent.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
			tangent.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);
			tangent = normalize(tangent);
			--tangent.w = 1.0; --default to 1, 1 or 0 to determine orientation of bitangent
			
			--TAKE FACE TANGENT AND APPLY TO EACH VERTEX AND AVERAGE FOR SMOOTH RESULT
			for i = 1 to verticesUsed.count do --for each pointer to the used vertex in this iteration
			(
				if (tangentsToAverage[i] == 0) then --if no tangent to average
				(
					newMesh[verticesUsed[i]].tangent = [tangent.x, tangent.y, tangent.z, 1.0]; --apply new tangent
				)
				else --else there is a tangent to average
				(
					local averagedTangent = [newMesh[verticesUsed[i]].tangent.x, newMesh[verticesUsed[i]].tangent.y, newMesh[verticesUsed[i]].tangent.z]; --get old tangent in xyz
					averagedTangent += tangent; --add newly calculated tangent
					averagedTangent /= 2; --average it
					
					newMesh[verticesUsed[i]].tangent = [averagedTangent.x, averagedTangent.y, averagedTangent.z, 1.0];
				)
			)
		)
		
		--log export statistics
		print ("Exported " + mesh.name + " to " + currentFileName);
		print ("Total vertices: " + (newMesh.count as string));
		print ("Optimised Vertices: " + (optimisedVertices as string));
		print ("Indices: " + (indices.count as string));
		
		--write vertices
		WriteStrToFile str:mesh.name tag:"mesh name";
		WriteNumToFile num:numOfUVChannels tag:"number of UV channels";
		WriteNumToFile num:newMesh.count tag:"number of vertices";

		for v in newMesh do --for each vertex in newly constructed mesh data
		(
			
			
			--write mesh data to file
			WriteVectorToFile vec:(SwapYZ v.pos) tag:"XYZ pos";
			Format "\n" to:currentFile;
			WriteVectorToFile vec:(SwapYZ v.pos) tag:"XYZ normal";	
			Format "\n" to:currentFile;
			WriteVectorToFile vec:(SwapYZ v.pos)  tag:"XYZW tangent";
			Format "\n" to:currentFile;
			WriteVectorToFile vec:v.colour tag:"RGBA colour";
			Format "\n" to:currentFile;
			
			--write UV channels to file
			for i = 1 to numOfUVChannels do
			(
				WriteVectorToFile vec:v.UV[i] tag:("UV " + (i as string));
				Format "\n" to:currentFile;
			)
			
			--Format "\n" to:currentFile; --new vertex
		)
		
		--write indices
		WriteNumToFile num:(indices.count) tag:"number of indices";
		for i in indices do
		(
			WriteVectorToFile vec:i tag:"index";
			Format "\n" to:currentFile;
		)
			
		--remove edit_normals, edit_mesh, and turn_to_poly modifiers
		for i = 1 to 3 do DeleteModifier mesh mesh.modifiers[1];
	)
	
	function BeginExport fileName:"" = 
	(
		currentFileName = fileName;
		DisableSceneRedraw(); --disable scene redraw to increase performance
		currentFile = CreateFile (currentFileName); --if so then create a new file
		max modify mode;
	)
	
	function EndExport = 
	(
		--renable scene redrawing
		Close currentFile;
		EnableSceneRedraw();
		RedrawViews();
	)
	
	function ExportToFile overwrite:false fileName:"" =
	(
		if (currentDir != undefined and currentDir != "") then --if there is a file path
		(
			local fileExist = FileExists(fileName);

			if (overwrite or (not fileExist) or (fileExist and (QueryBox "File exists, overwrite?"))) then --if file doesn't exist, or if it does and the user wants to overwrite it then
			(
				BeginExport fileName:fileName;
				WriteNumToFile num:meshList.count tag:"number of meshes";
				--Format "\n" to:currentFile;
				
				for m in meshList do --for each mesh in list
				(
					local bufferPos = m.pos; --reset to 0 0 0 if toggled
					if (resetToCenter) then m.pos = [0, 0, 0];
					
					ExportSingleAEMesh m;
					
					if (resetToCenter) then m.pos = bufferPos;
				)
				
				EndExport();
			)
			else
			(
				false;
			)
		)
		else --export directory is invalid
		(
			MessageBox "Directory is invalid!";
			false;
		)
		
		true; --success
	)
	
	rollout UI "AEMesh Exporter"
	(
		--file I/O
		EditText FileNameInput "File Name:" text:"" align:#left across:1;
		Button SelectDirectoryButton "<<Select Directory>>" align:#left across:2;
		EditText SelectedDirectoryPreview "" text:(currentDir) readOnly:true align:#right across:2;
		
		--export settings
		Checkbox ResetToCenterToggle "Reset To Center" align:#left checked:resetToCenter across:1 checked:true tooltip:"Reset to [0, 0, 0] on export - non-destructive";
		--Spinner UVChannelsSpinner "UV Channels:" align:#right across:2 type:#integer range:[0, MAX_NUM_OF_UV_CHANNELS, numOfUVChannels];
		Checkbox OverwriteAllCheckbox "Overwrite All" align:#left across:2 tooltip:"Overwrite all existing files with the same name";
		Checkbox DebugToggle "Debug" align:#left across:2 checked:debug tooltip:"Write tags to file for debugging purposes";
		
		--export options
		Button ExportSelected "Export Selected" align:#left across:2 tooltip:"Export selected as one file";
		Button ExportAll "Export All" align:#left across:2 tooltip:"Expor selected meshes to one file";
		Button ExportList "Export From List" align:#left across:2 tooltip:"Export meshes from list to one file";
		Button ExportListAsBatch "Export From List As Batch" align:#left across:2 tooltip:"Export selected meshes in list as a batch (individual files) where file name = mesh name";

		--UI events
		on UI open do
		(
			currentDir = maxFilePath;
			
			if (selection.count > 0) then
			(
				FileNameInput.text = selection[1].name;
			)
			else if (objects.count > 0) then
			(
				FileNameInput.text = objects[1].name;
			)
			
			currentFileName = FileNameInput.text;
		)
		
		--folder events
		on SelectDirectoryButton pressed do
		(
			local newDir = GetSavePath caption:"Choose folder to save to" initialDir:(maxFilePath); --get save directory as string
			
			if (newDir != undefined) then --if chosen directory is valid
			(
				currentDir = newDir;
				SelectedDirectoryPreview.text = currentDir;
			)
		)
		
		--settings events
		on DebugToggle changed arg do
		(
			debug = arg;
		)
		
		/*on UVChannelsSpinner entered do
		(
			numOfUVChannels = UVChannelsSpinner.value;
		)*/
		
		on ResetToCenterToggle changed arg do
		(
			resetToCenter = arg;
		)

		
		--export button events
		on ExportSelected pressed do
		(
			meshList = for o in selection where superclassof o == GeometryClass collect o; --add selection to mesh list
			
			if (meshList.count > 0) then --meshes to export
			(
				if (ExportToFile overwrite:OverwriteAllCheckbox.checked fileName:(FormatFileName(FileNameInput.text))) then --if meshes successfully exported
				(
					DestroyDialog UI; --destroy interface as meshes have been exported
				)
			)
			else
			(
				MessageBox "No meshes to export!" --error
			)
		)
		
		on ExportAll pressed do
		(
			meshList = for o in objects where superclassof o == GeometryClass collect o; --add selection to mesh list
			
			if (meshList.count > 0) then --meshes to export
			(
				if (ExportToFile overwrite:OverwriteAllCheckbox.checked fileName:(FormatFileName(FileNameInput.text))) then --if meshes successfully exported
				(
					DestroyDialog UI; --destroy interface as meshes have been exported
				)
			)
			else
			(
				MessageBox "No meshes to export!" --error
			)
		)
		
		on ExportList pressed do
		(
			meshList = SelectByName title:"Select Meshes To Export";
			
			if (meshList != undefined and meshList.count > 0) then --meshes to export
			(
				if (ExportToFile overwrite:OverwriteAllCheckbox.checked fileName:(FormatFileName(FileNameInput.text))) then --if meshes successfully exported
				(
					DestroyDialog UI; --destroy interface as meshes have been exported
				)
			)
			else
			(
				MessageBox "No meshes to export!" --error
			)
		)
		
		--batch export
		on ExportListAsBatch pressed do
		(
			meshList = SelectByName title:"Select Meshes To Export";

			if (meshList != undefined and meshList.count > 0) then --meshes to export
			(
				if (currentDir != undefined and currentDir != "") then --if there is a file path
				(
					for m in meshList do
					(
						local fileName = (m.name + "." + FILE_EXTENSION);
						local fileExist = FileExists(fileName);

						if (OverwriteAllCheckbox.checked or (not fileExist) or (fileExist and (QueryBox "File exists, overwrite?"))) then --if file doesn't exist, or if it does and the user wants to overwrite it then
						(
							BeginExport fileName:fileName;
							WriteNumToFile num:1 tag:"number of meshes";
							ExportSingleAEMesh m;
							EndExport();
						)
					)
					
					DestroyDialog UI;
				)
				else --export directory is invalid
				(
					MessageBox "Directory is invalid!";
				)
			)
			else
			(
				MessageBox "No meshes to export!";
			)
		)
	)
	
	CreateDialog UI 300 150 style:#(#style_titlebar, #style_border, #style_sysmenu) ;
)