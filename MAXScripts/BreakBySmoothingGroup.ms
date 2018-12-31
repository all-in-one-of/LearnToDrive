macroScript BreakBySmoothingGroup
category: "Sumo Scripts"
tooltip: "Break By Smoothing Group"
(
	local u = modPanel.GetCurrentObject()
	
	if ClassOf u == Unwrap_UVW then --object selected with unwrap applied
	(
		subobjectLevel = 3;

		for i = 1 to 32 do
		(
			u.unwrap2.SelectBySG i
			u.unwrap.BreakSelected()
		)
	)
)

macros.run "Sumo Scripts" "BreakBySmoothingGroup"