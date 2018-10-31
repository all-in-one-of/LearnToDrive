fn SetPivot align = 
	(
		for s in selection do
		(
			if (align == "Top") then
			(
				s.pivot.z = s.max.z;
			)
			else 	if (align == "Left") then
			(
				s.pivot.x = s.min.x;
			)
			else 	if (align == "Centre") then
			(
				CenterPivot s;
			)
			else 	if (align == "Right") then
			(
				s.pivot.x = s.max.x;
			)
			else 	if (align == "Bottom") then
			(
				s.pivot.z = s.min.z;
			)
			else 	if (align == "Back") then
			(
				s.pivot.y = s.max.y;
			)
			else 	if (align == "Front") then
			(
				s.pivot.y = s.min.y;
			)
		)
	)
	
	rollout UI "Pivot Tools"
	(
		button Top "Top" align:#center across:1 					--images:#("enss_tools_16i.bmp", "enss_tools_16a.bmp", 8, 1, 8, 1, 1);
		button Left "Left" align:#left across:3 						--images:#("enss_tools_16i.bmp", "enss_tools_16a.bmp", 8, 1, 8, 1, 1);
		button Centre "Centre" align:#center across:3  			--images:#("centerPivot_16.bmp", "centerPivot_16.bmp", 8, 3, 8, 1, 1);
		button Right "Right" align:#right across:3  					--images:#("enss_tools_16i.bmp", "enss_tools_16a.bmp", 8, 4, 8, 1, 1);
		button Bottom "Bottom" align:#center across:1  			--images:#("enss_tools_16i.bmp", "enss_tools_16a.bmp", 8, 5, 8, 1, 1);
		button Back "Back" align:#left across:2  						--images:#("enss_tools_16i.bmp", "enss_tools_16a.bmp", 8, 6, 8, 1, 1);
		button Front "Front" align:#right across:2 					--images:#("enss_tools_16i.bmp", "enss_tools_16a.bmp", 8, 7, 8, 1, 1);
		Button MatchPivot "MatchPivot" align:#center across:1 --images:#("enss_tools_16i.bmp", "enss_tools_16a.bmp", 8, 8, 8, 1, 1);
		
		on Top pressed do SetPivot "Top";
		on Left pressed do SetPivot "Left";
		on Centre pressed do SetPivot "Centre";
		on Right pressed do SetPivot "Right";
		on Bottom pressed do SetPivot "Bottom";
		on Back pressed do SetPivot "Back";
		on Front pressed do SetPivot "Front";
			
		on MatchPivot pressed do
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
	)
	
	CreateDialog UI;