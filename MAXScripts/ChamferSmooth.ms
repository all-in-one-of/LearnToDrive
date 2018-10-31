macroScript ChamferSmooth
category: "Calvinatorr_Custom"
tooltip: "Chamfer Smooth"
(
	if (selection.count > 0) then
	(
		--chamfer by SG
		max modify mode; --open panel
		modPanel.AddModToSelection (Chamfer()) ui:on;
		local cham = modPanel.GetCurrentObject();
		cham.smoothingOption = 2;
		cham.amount = 0.1;
		
		--polish edges with turbosmooth
		modPanel.AddModToSelection (TurboSmooth()) ui:on;
		local turbo = modPanel.GetCurrentObject();
		turbo.iterations = 2;
	)
)