macroScript CreateRef
category: "Calvinatorr_Custom"
tooltip: "Create Reference Image"
(
	function CreateReferenceImage selectedMap distance:70 side:"Front" = 
	(
		--create and select texture map from file
		b = BitmapTexture();
		--selectedMap = SelectBitmap();
		
		if (selectedMap != null) then
		(
			--set viewport resolution
			NitrousGraphicsManager.SetTextureSizeLimit 4096 true;
			
			--create plane
			p = Plane length:100 width:100 lengthsegs:1 widthsegs:1;
			p.name = ("Reference_" + side);
			b.bitmap = selectedMap;
				
			--assign material
			p.material = StandardMaterial diffuseMap:(b) showInViewport:true;
			p.material.name = ("TX_" + p.name);
			
			--correct plane dimensions
			b = OpenBitmap p.material.diffuseMap.filename;
			--p.width = b.width / 10.0 as float
			--p.length = b.height / 10.0 as float
			
			gridSize = (GetGridSpacing() * gridPrefs.perspViewGridExtents) * 2.0;
			
			if (b.width >= b.height) then --horizontal
			(
				p.width = gridSize;
				p.length = (b.height as float) / (b.width / p.width);
			)
			else --vertical
			(
				p.width = gridSize;
				p.length = (b.height as float) / (b.width / p.width);
			)
			
			--rotate reference image upright, place pivot at the bottom
			p.pivot.y = p.min.y;
			p_rot = eulerangles 90 0 0;
			
			rotate p p_rot
			p.pos = [0, distance, 0] --default to front
			p.pivot = [0, 0, (p.max.z - p.min.z) / 2.0];
		
			--handle which side reference is on
			if (side == "Front") then
			(
				p_rot = EulerAngles 0 0 0;
			)
			else if (side == "Back") then
			(
				p_rot = EulerAngles 0 0 180;
			)
			else if (side == "Right") then
			(
				p_rot = EulerAngles 0 0 -90;
			)
			else if (side == "Left") then
			(
				p_rot = EulerAngles 0 0 90;
			)
			else if (side == "Top") then
			(
				p_rot = EulerAngles 90 0 0;
			)
			else if (side == "Bottom") then
			(
				p_rot = EulerAngles -90 0 0;
			)
			
			rotate p p_rot; --rotate p by appropiate rotation
			
			--reset pivot
			CenterPivot p;
			p.pivot.z = p.min.z;
		)
	)
	
	rollout UI "Create Reference Image" 
	(
		spinner DistanceSpinner "Distance From Center" width:80 range:[0, 10000, (GetGridSpacing() * gridPrefs.perspViewGridExtents)] align:#left;
		
		button LeftButton "Left" width:75 height:25 align:#center across:3;
		button FrontButton "Front" width:75 height:25 align:#center across:3;
		button RightButton "Right" width:75 height:25 align:#center across:3;
		button BackButton "Back" width:75 height:25 align:#center across:3;
		button BottomButton "Bottom" width:75 height:25 align:#center across:3;
		button TopButton "Top" width:75 height:25 align:#center across:3;
		
		function SelectSide side =
		(
			local selectedMap = SelectBitmap();
			
			if (selectedMap != null) then
			(
				CreateReferenceImage(selectedMap) distance:DistanceSpinner.value side:side
				DestroyDialog UI;
			)
		)
		
		on LeftButton pressed do SelectSide(LeftButton.caption);
		on FrontButton pressed do SelectSide(FrontButton.caption);
		on RightButton pressed do SelectSide(RightButton.caption);
		on BackButton pressed do SelectSide(BackButton.caption);
		on BottomButton pressed do SelectSide(BottomButton.caption);
		on TopButton pressed do SelectSide(TopButton.caption);
	)
	
	createDialog UI 225 90
)