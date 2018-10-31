macroScript MatchPivot
category: "Calvinatorr_Custom"
tooltip: "Match Pivot"
(
	if (selection.count > 0) then
	(
		local transferFrom = PickObject prompt:"Pick object to match pivot from";
		
		if (not transferFrom == undefined) then
		(
			for s in selection do s.pivot = transferFrom.pivot;
		)
	)
)