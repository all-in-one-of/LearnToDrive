macroScript PivotToBottom
category: "Calvinatorr_Custom"
tooltip: "Pivot To Bottom"
(
	if (selection.count > 0) then
	(
		for s in selection do s.pivot.z = s.min.z;
	)
)