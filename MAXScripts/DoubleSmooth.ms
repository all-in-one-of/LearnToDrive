macroScript DoubleSmooth
category: "Calvinatorr_Custom"
tooltip: "Double Smooth"
(
	if (selection.count > 0) then
	(
		max modify mode; --open panel
		modPanel.AddModToSelection (TurboSmooth()) ui:on;
			
		local turbo = modPanel.GetCurrentObject();
			
		--smoothing group smooth
		turbo.iterations = 3;
		turbo.sepBySmGroups = true;
			
		modPanel.AddModToSelection (TurboSmooth()) ui:on;
	)
)