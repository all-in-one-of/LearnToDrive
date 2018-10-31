macroscript AppendName
category:"Calvinatorr_Custom"
tooltip:"Append Name"
(
	function RenameObjects prefix suffix =
	(
		if (selection.count > 0) then
		(
			for s in selection as array do
			(
				s.name = prefix + s.name + suffix;
			)
		)
	)
	
	rollout UI "Append Name"
	(
		EditText prefix "Prefix:" text:"" align:#left;
		Label objNameLabel "" align:#center;
		EditText suffix "Suffix:" text:"" align:#right;
		Button OKButton "OK" align:#centre
		
		on UI open do objNameLabel.caption = selection[1].name;
		
		on prefix changed arg do
		(
			objNameLabel.caption = prefix.text + selection[1].name + suffix.text;
		)
		
		on suffix changed arg do
		(
			objNameLabel.caption = prefix.text + selection[1].name + suffix.text;
		)
		
		
		on OKButton pressed do
		(
			RenameObjects prefix.text suffix.text;
			actionMan.executeAction 0 "59231" --unlock selection
			DestroyDialog UI;
		)
	)
	
	if (selection.count > 0) then
	(
		actionMan.executeAction 0 "59231" --lock selection
		
		CreateDialog UI 300 100
	)
)