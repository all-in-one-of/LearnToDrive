macroScript RenderImposterCard
category: "Calvinatorr_Custom"
tooltip: "Render Imposter Card"
(
	--camera
	local camTarget = Point axisTripod:true box:true;
	local cam = TargetCamera name:"Imposter_Camera" target:camTarget pos:[0, -250, 0];
	local defaultNumOfFrames = 16;
	freeze camTarget;
	freeze cam;
	
	fn GetCenterZ obj =
	(
		return obj.min.z + (obj.max.z - obj.min.z) / 2.0;
	)
	
	fn SetUpCamTarget target =
	(
		cam.pos.z = GetCenterZ target;
		camTarget.pos.z = GetCenterZ target;
	)
	
	fn SetUpCamKeys numOfFrames = 
	(
		local r = Distance camTarget cam;
		
		with animate on
		(
			for i = 0 to (numOfFrames - 1) do
			(
				local progress = (i as float)  / (numOfFrames as float);
				local x = r * cos(progress * 360.0) + camTarget.pos.x;
				local y = r * sin(progress * 360.0) + camTarget.pos.y;
				
				at time i cam.pos = [x, y, cam.pos.z];
			)
		)
	)
	
	fn IsSquare A = 
	(
		local B = sqrt (A as float);
		return (mod A B) == 0;
	)
	
	--WSN lights
	local lightList = #();
	
	fn SetUpWSLight colour rot = 
	(
		local newLight = Directionallight rgb:colour shadowColor:(color 0 0 0) multiplier:1 contrast:0 softenDiffuseEdge:0 nearAttenStart:0 nearAttenEnd:40 farAttenStart:80 farAttenEnd:200 decayRadius:40 atmosOpacity:100 atmosColorAmt:100 shadowMultiplier:1 hotspot:43 falloff:45 aspect:1 isSelected:off;
		newLight.overShoot = true;
		newLight.castShadows = false;
		newLight.rotation.x_rotation = rot.x;
		newLight.rotation.y_rotation = rot.y;
		newLight.rotation.z_rotation = rot.z;
		freeze newLight;
		
		Append lightList newLight;
	)
	
	fn RenderBuffer columns rows renderSize directory:"" fileName:"" extension:"" element:diffuse renderAlpha:true = 
	(
		renderMgr = MaxOps.GetCurRenderElementMgr();
		renderMgr.removeAllRenderElements();
		local elem = element elementName:(element as string);
		
		if (element == lighting) then
		(
			elem.shadowsOn = false;
		)
		
		renderMgr.AddRenderElement elem;

		if (renderAlpha) then
		(
			elem = alpha elementName:(alpha as string);
			renderMgr.AddRenderElement elem;
		)

		local diffBuffer = Bitmap (columns *  renderSize) (rows * renderSize);
		diffBuffer.fileName = directory + fileName + extension + ".png";
		
		local frame = 0;
		for y = 0 to (rows - 1) do --across y - for each row down
		(
			for x = 0 to (columns - 1) do --across x - for each row across
			(
				local bmps = #();
				local img = render camera:cam frame:frame vfb:true width:renderSize height:renderSize renderElements:true renderElementBitmaps:&bmps; --renderType:#selection channels:#(#UVCoords)

				for pixelY = 0 to renderSize do --get row of pixels down
				(
					local pixelX = x * renderSize;
					local pixels = GetPixels (bmps[1])[0, pixelY] renderSize;
					
					/*pixels = #((color 0 0 0 0));
					
					for pixX = 1 to renderSize + 1 do
					(
						local p = GetChannel img [pixX, pixelY] #UVCoords;
						pixels[pixX] = [p[1], p[2], 0.0, 0.0];
					)*/
					
					if (renderAlpha) then
					(
						local alphaPixels = GetPixels (bmps[2])[0, pixelY] renderSize;
						for i = 1 to pixels.count do
						(
							pixels[i].A = alphaPixels[i].A;
						)
					)
					
					SetPixels diffBuffer[pixelX, y * renderSize + pixelY] pixels;
				)
				
				frame += 1;
			)
		)
		
		save diffBuffer; --save bitbuffer as bitmap
	)
	
	fn RenderSheet numOfFrames renderSize directory fileName =
	(
		local rows = sqrt (numOfFrames as float);
		local columns;
		
		--calculate rows/columns
		if (IsSquare numOfFrames) then --square number
		(
			columns = rows;
		)
		else --divide by 4
		(
			rows = numOfFrames / 4;
			columns = 4;
		)
		
		--render settings
		renderWidth = renderSize;
		renderHeight = renderSize;
		scanlineRender.enablePixelSampler = true;
		setSilentMode = true;
		pngio.setType(#true24);
		pngio.setAlpha(true);
		
		--render diffuse buffer
		RenderBuffer columns rows renderSize directory:directory fileName:fileName extension:"_D" element:diffuse renderAlpha:true;
		
		--set up world space normal lighting - direction and colour of light simulates the WORLD SPACE NORMAL
		SetUpWSLight (Color 127 0 0) (EulerAngles 90 0 -90); -- -X
		SetUpWSLight (Color 255 0 0) (EulerAngles 0 90 0); -- +X
		SetUpWSLight (Color 0 127 0) (EulerAngles 90 0 0); -- -Y
		SetUpWSLight (Color 0 255 0) (EulerAngles 90 0 180); -- +Y
		SetUpWSLight (Color 0 0 127) (EulerAngles 180 0 0); -- -Z
		SetUpWSLight (Color 0 0 255) (EulerAngles 0 0 90); -- +Z

		RenderBuffer columns rows renderSize directory:directory fileName:fileName extension:"_WSN" element:lighting renderAlpha:false; --render world space normal
	)
	
	fn FormatFileName s = 
	(
		s = Replace s 1 2 "TX";
		s += "_IMPCARD";
		return s;
	)
	
	--begin
	local defaultFileName = "";
	if (selection.count > 0) then
	(
		defaultFileName = FormatFileName($.name);
		SetUpCamTarget $;
	)
	SetUpCamKeys defaultNumOfFrames;
	
	--UI
	rollout UI "Render Imposter Card"
	(
		Button button_SelectTarget "Select Target" align:#left;
		
		--file I/O
		Button button_SelectFolder "Folder" align:#left across:2;
		EditText editText_Directory "" readOnly:true text:maxFilePath fieldWidth:250 align:#right across:2;
		EditText editText_FileName "" text:defaultFileName fieldWidth:125 align:#right;
		
		Slider slider_CameraDist "Camera Distance" orient:"left:";
		Spinner spinner_RenderSize "Render Size: " range:[8, 2048, 256] type:#integer; align:#left;
		Spinner spinner_NumOfFrames "Number of Frames:" range:[1, 96, defaultNumOfFrames] type:#integer align:#left scale:2;
		Button button_Render "Render" align:#center;
		
		on button_SelectTarget pressed do
		(
			local target = PickObject prompt:"Pick target";
			if (target != undefined) then
			(
				defaultFileName = FormatFileName(target.name);
				editText_FileName.text = defaultFileName;
				SetUpCamTarget target;
			)
		)
		
		on button_SelectFolder pressed do
		(
			local newDir = GetSavePath caption:"Choose Folder To Save Batch" initialDir:(maxFilePath);
			if (newDir != undefined) then
				editText_Directory.text = newDir;
		)
		
		on slider_CameraDist changed arg do
		(
			
		)
		
		on spinner_NumOfFrames changed arg do
		(
			if ((not (IsSquare arg)) and (mod arg 2 != 0)) then --odd number
				spinner_NumOfFrames.value += 1;
			
			SetUpCamKeys spinner_NumOfFrames.value;
		)
		
		on button_Render pressed do
		(
			RenderSheet spinner_NumOfFrames.value spinner_RenderSize.value editText_Directory.text editText_FileName.text;
		)
		
		--cleanup objects when finished
		on UI close do
		(
			delete camTarget;
			for l in LightList do
				delete l;
		)
	)
	
	CreateDialog UI width:400;
)