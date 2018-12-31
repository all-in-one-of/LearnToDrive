macroScript SwapInteractionMode
category:"Calvinatorr_Custom"
toolTip:"Interaction Mode Switch"
(
	if (IInteractionMode.CurrentMode == #3dsMaxMode) then
	(
		IInteractionMode.CurrentMode = "MayaMode";
		
		macros.run "Calvinatorr_Custom" "LoadShortcuts"
		
		Print "Activated Maya Mode";
	)
	else if (IInteractionMode.CurrentMode == #MayaMode or IInteractionMode.CurrentMode == #CustomizedMode) then
	(
		IInteractionMode.CurrentMode = "3dsMaxMode";
		Print "3ds Max Mode";
	)
)