Change the directories in the arrays provided in the setup part of each script.
You must end the directory with a double backslash otherwise you will get an error (string manipulation stuff)

In LoadShortcuts you need to change the file names you are looking for too.

LoadShortcuts needs your keyboard shortcuts and ribbon files in the same folder.

LOAD_ALL_SCRIPTS needs all your max files in the same folder - it will ignore anything in any sub-folders,
if you have any instant load scripts (dragging onto viewport runs them instantly) it will run them - place these in subfolders to ignore them.
This script is designed to load in the scripts with the code enclosed as this will add it to your available commands to assign shortcuts to, or to a ribbon.

ie. the following is a script you can assign to a shortcut/ribbon.

macroScript ExampleScript
category:"Calvinatorr_Custom"
toolTip:"Example Script"
(
	-- code
)