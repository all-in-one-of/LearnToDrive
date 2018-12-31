macroScript LoadShortcuts
category:"Calvinatorr_Custom"
toolTip:"Load Shortcuts"
(
	---------- SETUP ------------
	
	useMayaMode = true;						-- Set to false to use 3ds Max Mode
	shortcuts = "CoatsinkShortcuts.kbdx"; 	-- Name of the shortcut file - will always end with ".kbdx"
	ribbon = "CoatsinkRibbon.ribbon"; 		-- Name of the ribbon file - will always end with ".ribbon"
	directories = #( 						-- Array of directories you want to search within " " (minus the drive, i.e. without C:\\). Add new entry with "," at the end for new entry Add \\ (double \) before the end comma - VERY IMPORTANT
		"3DMisc\Resources\Preferences\\",
		"Documents\3DMisc\Resources\Preferences\\",
		"Users\csimpson\Documents\3DMisc\Resources\Preferences\\"
		);
	
	
	--------- END SETUP --------
	
	-- Don't touch the code - only change the setup variables
	
	---------    CODE   --------
	
	fn FileExist file = (Getfiles file).count != 0; --return whether the file exists
	
	fn FindFileDrive f = --return the drive where the directory is found
	(
		for i = 65 to 90 do
		(
			local checkFile = (bit.IntAsChar(i) + ":\\" + f);
			if (DoesFileExist checkFile) then
			(
				return checkFile; --return file with correct drive
			)
		)
		
		return undefined;
	)
	
	dir = undefined;
	for d in directories do --for each directory
	(
		Print ("Checking.. " + d); --check the directory
		dir = FindFileDrive d;
		if (dir != undefined) then --if it has found something
		(
			exit; --break if found
		)
	)
	
	if (dir != undefined) then --if the file exists
	(
		if (useMayaMode) then
		(
			IInteractionMode.CurrentMode = "MayaMode"; --switch to Maya Mode
			Print "Maya Mode";
		)
		else
		(
			IInteractionMode.CurrentMode = "3dsMaxMode"; --switch to 3ds Max Mode
			Print "3ds Max Mode";
		)
	
		actionMan.LoadKeyboardFile (dir + shortcuts); --file found, load it
		MaxRibbon.LoadRibbonConfig (dir + ribbon);
		Print ("Loaded shortcuts and ribbon from " + dir);
	)
	else
	(
		Print "Directory not found, shortcuts and ribbon not loaded!";
	)
)