macroScript QuickUnwrap
category: "Calvinatorr_Custom"
tooltip: "Quick Unwrap"
(
	if ($ != null) then
	(
		local polyCount = 0;
		
		/*
		local editableType = ClassOf(modPanel.GetCurrentObject());
		
		--get number of faces before adding unwrap modifier and account for editable types
		if (editableType == Editable_Poly or editableType == Unwrap_UVW) then
		(
			polyCount = PolyOp.getNumFaces($);
		)
		else if (editableType == Edit_Poly) then
		(
			polyCount = $.Edit_Poly.getNumFaces();
		)
		
		if (editableType != Unwrap_UVW) then --if unwrap not already present
		(
			AddModifier $ (Unwrap_UVW()); --add unwrap modifier
		)
		*/
		
		--currentModifier = modPanel.GetModifierIndex $ (modPanel.GetCurrentObject());
	
		--AddModifier $ (Edit_Poly()) after:currentModifier;
		modPanel.AddModToSelection (Edit_Poly());
		polyCount = $.Edit_Poly.GetNumFaces();
		currentModifier = modPanel.GetModifierIndex $ (modPanel.GetCurrentObject());
		--modPanel.SetCurrentObject($.modifiers[currentModifier]);
		--DeleteModifier $ $.modifiers[currentModifier];
		
		if (ClassOf(modPanel.GetCurrentObject()) != Unwrap_UVW) then
		(
			modPanel.AddModToSelection (Unwrap_UVW());
			--AddModifier $ (Unwrap_UVW());-- before:(currentModifier);
		)

		$.Unwrap_UVW.unwrap2.setTVSubObjectMode(3); --set suboejct mode to poly
		$.Unwrap_UVW.unwrap.SelectPolygons(#{1..(polyCount + 	1)}); --select all polygons
		$.Unwrap_UVW.unwrap5.MappingMode(1); --planar mapping mode
		$.Unwrap_UVW.unwrap5.MappingAlignToView();
		$.Unwrap_UVW.unwrap5.SetNormalizeMap(false);
		$.Unwrap_UVW.unwrap2.SetIgnoreBackfaceCull(false);
		$.Unwrap_UVW.unwrap5.MappingMode(0); --turn off mapping mode
		$.Unwrap_UVW.unwrap2.PackNoParams(); --pack into 0-1 uv space
		
		$.Unwrap_UVW.unwrap.DisplayMap false;
		$.Unwrap_UVW.unwrap.SetCurrentMap 2;
			
		DeleteModifier $ $.modifiers[currentModifier + 1]; --delete edit poly modifier
		
		modPanel.SetCurrentObject($.modifiers[currentModifier]); --open uvw modifier
		$.Unwrap_UVW.unwrap.Edit(); --open edit mode
	)
)