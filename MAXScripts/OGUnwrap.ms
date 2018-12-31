macroScript OGUnwrap category: "Calvinatorr_Custom" tooltip: "OG Unwrap"
(
	max modify mode;
	
	modPanel.AddModToSelection (Unwrap_UVW());
	local sel = selection as array;
	select sel[1]; -- select first
	
	if ($ != null and selection.count != 0) then
	(
		--currentModifier = modPanel.GetModifierIndex $ (modPanel.GetCurrentObject());
		
		$.Unwrap_UVW.unwrap2.setTVSubObjectMode(3); --set suboejct mode to poly
		$.Unwrap_UVW.unwrap2.SetIgnoreBackfaceCull(false);
		$.Unwrap_UVW.unwrap5.setNormalizeMap off;
		
		$.Unwrap_UVW.unwrap.DisplayMap on;
		$.Unwrap_UVW.unwrap.SetCurrentMap 3;
		
		--modPanel.SetCurrentObject($.modifiers[currentModifier]); --open uvw modifier
	)
	
	select sel;
	
	setCommandPanelTaskMode #modify
	local currentMod = modpanel.getCurrentObject()
	currentMod.unwrap.Edit();
	
	$.Unwrap_UVW.unwrap.SetCurrentMap 3;
)

macros.run "Calvinatorr_Custom" "OGUnwrap"