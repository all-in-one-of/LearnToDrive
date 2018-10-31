macroScript PipeGenerator
category: "Calvinatorr_Custom"
tooltip: "Pipe Generator"
(
	global pipeList = for s in selection where SuperClassOf s == GeometryClass collect s;
	struct PipeComponent (mesh, originalRotation, newRotation)
	global creationList = #();
	
	global UI = NewRolloutFloater "Pipe Generator" 250 400;
	
	Rollout PipeListUI "List Of Pipes"
	(
		--controls
		ListBox PipeListPreview "Pipes:" items:(for p in pipeList collect p.name);
		Button AddSelected "Add Selected" align:#left across:2;
		Button Remove "Remove" align:#right across:2 type:#worldunits;
		
		--ImgTag Image "" bitmap:(bitmap 200 100);
		
		function UpdatePreview =
		(
			--Image.bitmap = Windows.Snapshot(viewport.GetHWnd index:1);
		)
		
		on PipeListUI open do
		(
			--Image.bitmap = Windows.Snapshot(viewport.GetHWnd index:1);
		)
		
		--subroutines
		function UpdatePipeListPreview = 
		(
			if (selection.count > 0) then
			(
				PipeListPreview.items = for p in pipeList collect p.name;
			)
		)
		
		on PipeListPreview selected arg do UpdatePreview();
		
		--control events
		on AddSelected pressed do
		(
			if (selection.count > 0) then
			(
				for s in selection do
				(
					Append pipeList s;
				)
			)
			
			PipeListPreview.items = for p in pipeList collect p.name;
		)
		
		on Remove pressed do
		(
			if ((PipeListPreview.items.count > 0) and (not PipeListPreview.selection == 0)) then 
			(
				DeleteItem pipeList PipeListPreview.selection;
				UpdatePipeListPreview();
			)
		)
	)
	AddRollout PipeListUI UI;
	
	Rollout ParametersUI "Parameters"
	(
		Spinner Spacing "Spacing" range:[0.0, 99999999, 0.64] align:#left width:100 across:1;
		Spinner RotationIncrement "Rotation Spacing" range:[0.0, 360.0, 22.5] align:#left width:100 across:1;
	)
	AddRollout ParametersUI UI;
	
	Rollout CreateUI "Create Pipe System"
	(
		Button CreatePipe "Create Pipe" across:2 align:#center;
		Button RemovePipe "Remove Pipe" across:2 align:#center;
		
		Spinner RotationX "X" range:[-360.0, 360.0, 0.0] type:#float across:3 align:#center width:60 scale:ParametersUI.RotationIncrement.value;
		Spinner RotationY "Y" range:[-360.0, 360.0, 0.0] type:#float across:3 align:#center width:60 scale:ParametersUI.RotationIncrement.value;
		Spinner RotationZ "Z" range:[-360.0, 360.0, 0.0] type:#float across:3 align:#center width:60 scale:ParametersUI.RotationIncrement.value;
		
		Spinner FlowX "X" range:[0.0, 1.0, 0.0] type:#float across:3 align:#center width:60 scale:ParametersUI.RotationIncrement.value;
		Spinner FlowY "Y" range:[0.0, 1.0, 0.0] type:#float across:3 align:#center width:60 scale:ParametersUI.RotationIncrement.value;
		Spinner FlowZ "Z" range:[0.0, 1.0, 1.0] type:#float across:3 align:#center width:60 scale:ParametersUI.RotationIncrement.value;
		
		--pipe rotation
		function UpdatePipeRotation newRotation = 
		(
			--creationList[creationList.count].mesh.rotation = creationList[creationList.count].originalRotation;
			
			--local revertRotation = EulerAngles (-creationList[creationList.count].newRotation.x) (-creationList[creationList.count].newRotation.y) (-creationList[creationList.count].newRotation.z);
			local delta = newRotation - creationList[creationList.count].newRotation;
			print delta;
			in coordsys local Rotate creationList[creationList.count].mesh (EulerAngles delta.x delta.y delta.z);
			
			--in coordsys local Rotate creationList[creationList.count].mesh (revertRotation as EulerAngles);
			--in coordsys local Rotate creationList[creationList.count].mesh (EulerAngles newRotation.x newRotation.y newRotation.z);
			creationList[creationList.count].newRotation = newRotation;
		)
		
		on RotationX changed arg do
		(
			if (creationList.count > 0) then UpdatePipeRotation [RotationX.value, RotationY.value, RotationZ.value];
		)
		on RotationY changed arg do
		(
			if (creationList.count > 0) then UpdatePipeRotation [RotationX.value, RotationY.value, RotationZ.value];
		)
		on RotationZ changed arg do
		(
			if (creationList.count > 0) then UpdatePipeRotation [RotationX.value, RotationY.value, RotationZ.value];
		)
		
		on CreatePipe pressed do
		(
			if (pipeList.count > 0) then
			(
				--create instance of pipe
				local newNodes;
				maxOps.CloneNodes pipeList[PipeListUI.PipeListPreview.selection] cloneType:#instance newNodes:&newNodes #nodialog;
				
				--create reference to be stored in array to the new pipe
				local newPipe = (PipeComponent mesh:newNodes[1] originalRotation:newNodes[1].rotation newRotation:[0.0, 0.0, 0.0]);
				
				if (creationList.count < 1) then --if first pipe
				(
					newPipe.mesh.pos = [0, 0, 0]; --place at 0 0 0 by default
				)
				else --else create ontop of last pipe
				(
					newPipe.mesh.pos = creationList[creationList.count].mesh.pos;
					newPipe.mesh.pos.z += creationList[creationList.count].mesh.max.z - creationList[creationList.count].mesh.min.z;
				)
				
				Select newPipe.mesh;
				Append creationList newPipe; --add new pipe to the list
				
				UpdatePipeRotation [RotationX.value, RotationY.value, RotationZ.value];
			)
		)
		
		on RemovePipe pressed do 
		(
			if (creationList.count > 0) then
			(
				Delete creationList[creationList.count].mesh;
				DeleteItem creationList creationList.count;
				
				if (creationList.count > 0) then
				(
					Select creationList[creationList.count].mesh; --if there is a last pipe then select it
					RotationX.value = creationList[creationList.count].newRotation.x;
					RotationY.value = creationList[creationList.count].newRotation.y;
					RotationZ.value = creationList[creationList.count].newRotation.z;
				)
			)
		)
	)
	AddRollout CreateUI UI;
)