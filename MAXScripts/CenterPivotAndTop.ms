macroScript CenterPivotAndTop
category: "Calvinatorr_Custom"
tooltip: "Center Pivot &Top"
(
	if (selection.count > 0) then
	(
		for s in selection do
		(
			CenterPivot s;
			s.pivot.z = s.max.z;
		)
	)
)