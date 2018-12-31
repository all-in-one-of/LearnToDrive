macroScript CenterPivotAndBottom
category: "Calvinatorr_Custom"
tooltip: "Center Pivot & Bottom"
(
	if (selection.count > 0) then
	(
		for s in selection do
		(
			CenterPivot s;
			s.pivot.z = s.min.z;
		)
	)
)