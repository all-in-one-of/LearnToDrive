macroScript RenameInstances
category: "Calvinatorr_Custom"
tooltip: "Rename Instances"
(
	fn RenameInstances name = 
	(
		if (selection.count > 0) then
		(
			instances = #();
			InstanceMgr.GetInstances $ &instances;
			
			for i = 2 to instances.count do
			(
				instances[i].name = (name + ((i - 1) as string));
			)
		)
	)
	
	rollout UI "Rename Instances"
	(
		EditText NameText "New Name: " text:"";
		EditText InstSuffix "Inst Suffix: " text:"_Inst";
		Button Rename "Rename" align:#center;
		
		on Rename pressed do
		(
			if (selection.count > 0) then
			(
				selection[1].name = NameText.text;
				RenameInstances (NameText.text + InstSuffix.text);
				DestroyDialog UI;
			)
		)
	)
	
	CreateDialog UI;
)