macroScript ToggleMayaSelectionMode
category:"Calvinatorr_Custom"
toolTip:"Toggle Maya Selection Mode"
(
	MouseConfigManager.MayaSelectionMode = not MouseConfigManager.MayaSelectionMode
	
	if (MouseConfigManager.MayaSelectionMode) then
		Print "Maya Selection Mode ON"
	else
		Print "Maya Selection Mode OFF"
)