macroScript AtlasingTool
category: "Calvinatorr_Custom"
tooltip: "Atlasing Tool"
(
	function ApplyUnwrapModifier noOfTiles:4 = 
	(
		if (selection.count > 0) then
		(
			local polyCount = 0;
			local currentModifier = 1;

			if (ClassOf(modPanel.GetCurrentObject()) != Unwrap_UVW) then
			(
				modPanel.AddModToSelection (Edit_Poly());
				polyCount = $.Edit_Poly.GetNumFaces();
				currentModifier = modPanel.GetModifierIndex $ (modPanel.GetCurrentObject());
				modPanel.AddModToSelection (Unwrap_UVW());
			)

			$.Unwrap_UVW.unwrap5.MappingAlignToView();
			$.Unwrap_UVW.unwrap2.SetIgnoreBackfaceCull false;
			$.Unwrap_UVW.unwrap2.SetGridSize (1.0 / (noOfTiles as float));
			$.Unwrap_UVW.unwrap2.SetGridSnap true;
			$.Unwrap_UVW.unwrap.SetCurrentMap 2;
			actionMan.executeAction 2077580866 "40133"; --show grid
				
			if (ClassOf(modPanel.GetCurrentObject()) != Unwrap_UVW) then
			(
				DeleteModifier $ $.modifiers[currentModifier + 1]; --delete edit poly modifier
			)
			
			modPanel.SetCurrentObject($.modifiers[currentModifier]); --open uvw modifier
			$.Unwrap_UVW.unwrap.Edit(); --open edit mode
		)
	)
	
	function GetMinMax = 
	(
		local s = $.Unwrap_UVW.unwrap.GetSelectedVertices();
		local minPos = $.Unwrap_UVW.unwrap.GetVertexPosition 0 1;
		local maxPos = $.Unwrap_UVW.unwrap.GetVertexPosition 0 2;
		
		local selected = 0;
		
		for i = 1 to s.count do
		(
			print s[i];
			if (s[i]) then --if vertex is selected
			(
				selected += 1;
				local pos = $.Unwrap_UVW.unwrap.GetVertexPosition 0 i;
				
				if (pos.x <= minPos.x and pos.y <= minPos.y) then
				(
					minPos = pos;
				)
				else if (maxPos.x <= pos.x and maxPos.y <= pos.y) then
				(
					maxPos = pos;
				)
			)
		)
		
		if (selected == 0) then
		(
			for i = 1 to s.count do
			(
				s[i] = true; --select vertex
				
				local pos = $.Unwrap_UVW.unwrap.GetVertexPosition 0 i;
				
				if (pos.x <= minPos.x and pos.y <= minPos.y) then
				(
					minPos = pos;
				)
				else if (maxPos.x <= pos.x and maxPos.y <= pos.y) then
				(
					maxPos = pos;
				)
			)
			
			$.Unwrap_UVW.unwrap.SelectVertices s; --select all vertices
		)
		
		return [minPos.x, minPos.y, maxPos.x, maxPos.y];
	)
	
	function GetUVGizmo = 
	(
		minMaxPos = GetMinMax();
	
		local centre = [(minMaxPos.z - minMaxPos.x) / 2.0, (minMaxPos.w - minMaxPos.y) / 2.0];
		local gizmo = [minMaxPos.x + centre.x, minMaxPos.y + centre.y, centre.x, centre.y]; --z and w = centre
	)
	
	function MoveUV pos:[0, 0] = 
	(
		local gizmo = GetUVGizmo();
		print gizmo;
		$.Unwrap_UVW.unwrap2.MoveSelected [-gizmo.x, -gizmo.y, 0.0]; --reset to 0 0
		$.Unwrap_UVW.unwrap2.MoveSelected [pos.x - gizmo.z, pos.y - gizmo.w, 0.0];
	)
	
	UI = NewRolloutFloater "Atlasing Tool" 250 340;
	
	Rollout SettingsUI "Settings"
	(
		local powerOfTwo = #(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192);
		local displayMap = true;
		local defaultTile = 4;

		DropDownList uiTexResolution "Texture Resolution" selection:13 across:2;
		DropDownList uiNoOfTiles "Number Of Tiles" selection:3 across:2;
		
		Button uiToggleGrid "Toggle Grid" across:3;
		on uiToggleGrid pressed do actionMan.executeAction 2077580866 "40133"; --toggle grid
		Button uiToggleGridSnap "Toggle Grid Snap" across:3;
		on uiToggleGridSnap pressed do $.Unwrap_UVW.unwrap2.SetGridSnap (not $.unwrap_UVW.unwrap2.GetGridSnap());
		Button uiToggleMap "Toggle Map" across:3;
		
		Spinner uiTileX "U" range:[1, defaultTile, 1] type:#integer across:3 align:#left;
		Spinner uiTileY "V" range:[1, defaultTile, 1] type:#integer across:3 align:#left;
		Button uiSetTile "Set Tile" align:#right;
			
		Button ScaleUVs "Scale UVs" tooltip:"Scale UVs by 0.99 - this will heavily reduce seams";
		
		on uiNoOfTiles selected arg do
		(
			local tile = (powerOfTwo[uiNoOfTiles.selection]) as float;
			$.Unwrap_UVW.unwrap2.SetGridSize (1.0 / tile);
			
			uiTileX.range = [1, tile, uiTileX.value];
			uiTileY.range = [1, tile, uiTileY.value];
		)
		
		on uiToggleMap pressed do
		(
			$.Unwrap_UVW.unwrap.DisplayMap (not displayMap);
			displayMap = not displayMap;
			$.Unwrap_UVW.unwrap.UpdateView();
		)
		

		on uiSetTile pressed do
		(
			GetUVGizmo();
			
			
			
			MoveUV pos:[(uiTileX.value as float) / (powerOfTwo[uiNoOfTiles.selection] as float), (uiTileY.value as float) / (powerOfTwo[uiNoOfTiles.selection] as float)];
		)
			
		on ScaleUVs pressed do
		(
			$.Unwrap_UVW.unwrap2.ScaleSelectedCenter 0.99 0;
		)
		
		on SettingsUI open do --init
		(
			local selection = for i in powerOfTwo collect i as string;
			uiTexResolution.items = selection;
			uiNoOfTiles.items = selection;
			
			ApplyUnwrapModifier noOfTiles:powerOfTwo[uiNoOfTiles.selection];
		)
	)
	
	AddRollout SettingsUI UI;
)