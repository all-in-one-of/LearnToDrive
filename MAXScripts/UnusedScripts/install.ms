--  installer for 'EditablePoly_RegularizeEdgeLoop.mcr' version 1.1 april 2011
(
 	local macro = "$userMacros\\EditablePoly_RegularizeEdgeLoop.mcr"
 	if doesFileExist macro do 
 	(
 		fileIn macro
 
        if (local quadMenu = menuMan.getViewportRightClickMenu #nonePressed) != undefined do
        if (local menu = quadMenu.getMenu 4) != undefined do
        (
            local num = menu.numItems()
            local noItem = true
            local theTitle = "Regularize"
            
            for i = 1 to num while noItem do noItem = ((menu.getItem i).getTitle() != theTitle)
                    
            if noItem do
            (
                local theItem = menuMan.createActionItem "EditablePoly_RegularizeEdgeLoop" "Editable Polygon Object"
                theItem.setTitle theTitle
                theItem.setUseCustomTitle true
                menu.addItem theItem -1
            )
        )
 	)
)
