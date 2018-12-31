---------- SETUP ------------

directories = #( 								-- Array of directories you want to search within " " (minus the drive, i.e. without C:\\). Add new entry with "," at the end for new entry. Add \\ (double \) before the end comma - VERY IMPORTANT
	"3DMisc\Resources\MAXScripts\\",
	"Documents\3DMisc\Resources\MAXScripts\\",
	"Users\csimpson\Documents\3DMisc\Resources\MAXScripts\\",
	"Users\csimpson\Documents\3DMisc\Resources\MAXScripts\\"
	);
	
	--eg. "3DMisc\Resources\MAXScripts\\" will search every drive, eg. it will find it on drive E if you have that directory at E:\Documents\3DMisc\Resources\MAXScripts

--------- END SETUP --------

-- Don't touch the code - only change the setup variables

---------    CODE   --------

fn FindFileDrive f = 
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
for d in directories do
(
	Print ("Checking directory.. " + d);
	dir = FindFileDrive d;
	if (dir != undefined) then
	(
		exit; --break if found
	)
)

if (dir != undefined) then --if the file exists
(
	Print ("Searching for scripts at.. " + dir);
	scripts = GetFiles (dir + "*.ms"); --get list of all script names from dir

	for s in scripts do
	(
		if (s != GetThisScriptFilename()) then --if not this script
		(
			FileIn s; --load in script
			Print("Loaded in script: " + s);
		)
	)

	macros.run "Calvinatorr_Custom" "LoadShortcuts"; --load in shortcuts via separate script file
)
else
(
	Print "Directory not found";
)