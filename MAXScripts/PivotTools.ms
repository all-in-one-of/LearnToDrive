macroScript PivotTools
category: "Sumo Scripts"
tooltip: "Pivot Tools"
(
	rollout PivotUI "Pivot Tools"
	(
		local buttonSize = 50
		local buttonHeight = 50
		
		Button MaxZ "+Z" align:#center across:1 width:buttonSize height:buttonHeight tooltip:"Set pivot to max bounds Z" iconName:@"Common\UIComponents\ArrowUp"
		on MaxZ pressed do
			if selection.count > 0 then
				for s in selection do
					s.pivot.z = s.max.z
			
		Button MinX "-X" align:#right across:3 width:buttonSize height:buttonHeight tooltip:"Set pivot to min bounds X" iconName:@"Common\ArrowHeadLeft"
		on MinX pressed do
			if selection.count > 0 then
				for s in selection do
					s.pivot.x = s.min.x
			
		Button Centre "Centre" align:#center width:buttonSize height:buttonHeight tooltip:"Set pivot to the centre of the object's bounds" iconName:@"EditUVW\PivotCenter"
		on Centre pressed do
			if selection.count > 0 then
				for s in selection do
					CenterPivot s
			
		Button MaxX "+X" align:#left width:buttonSize height:buttonHeight tooltip:"Set pivot to max bounds X" iconName:@"Common\TreeView\Closed"
		on MaxX pressed do
			if selection.count > 0 then
				for s in selection do
					s.pivot.x = s.max.x
		
		Button MinY "-Y" align:#right across:3 width:buttonSize height:buttonHeight tooltip:"Set pivot to min bounds Y" iconName:@"EditUVW\PivotLowerLeft"
		on MinY pressed do
			if selection.count > 0 then
				for s in selection do
					s.pivot.y = s.min.y
		
		Button MinZ "-Z" align:#center width:buttonSize height:buttonHeight tooltip:"Set pivot to min bounds Z" iconName:@"Common\UIComponents\ArrowDown"
		on MinZ pressed do
			if selection.count > 0 then
				for s in selection do
					s.pivot.z = s.min.z
		
		Button MaxY "+Y" align:#left width:buttonSize height:buttonHeight tooltip:"Set pivot to max bounds Y" iconName:@"EditUVW\PivotLowerRight"
		on MaxY pressed do
			if selection.count > 0 then
				for s in selection do
					s.pivot.y = s.max.y
		
		PickButton StealPivot "Steal Pivot" align:#right across:2 width:90 height:buttonHeight tooltip:"Steal pivot from target object"
		on StealPivot picked obj do
			if selection.count > 0 then
				for s in selection do s.pivot = obj.pivot
			
		Button ZeroPivot "Zero Pivot" align:#left width:90 height:buttonHeight tooltip:"Set pivot to (0,0,0)"
		on ZeroPivot pressed do
			if selection.count > 0 then
				for s in selection do s.pivot = [0.0, 0.0, 0.0]
	)
	
	--UI = NewRolloutFloater "Pivot Tools" 250 250
	--AddRollout PivotUI UI
	CreateDialog PivotUI width:235 height:235
)

Macros.Run "Sumo Scripts" "PivotTools"