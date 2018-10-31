macroScript AlignToSurface

        category:"ClaverTech"

        toolTip:"AlignToSurface"

(

           

tool AlignToSurfaceTool

            (

                        local somethin=undefined

                        local OrgPos=undefined

                        local OrgRot=undefined

                        local target_mesh=undefined

                        local StartDragging=0

                        local posy=undefined

                        local roty=undefined

                        local OrgViewY=undefined

                       

                        fn g_filter o =

                        (

                                    if o!=somethin then

                                    (

                                    superclassof o == Geometryclass

                                    )

                                    else

                                    (

                                                false

                                    )

                        )

                                    fn ResetStuff str=

                        (

                                    somethin.pos = OrgPos

                                    somethin.dir = OrgRot

                        )

                        fn DoMyStuff str=

                        (

                                    local myRay=mapScreenToWorldRay viewPoint   -- make a ray from active viewport

                                    local tempRay=intersectRay target_mesh myRay --see if the ray hits the picked object

                                                                        if tempRay!=undefined then --if we actually hit the picked object set to surface

                                                                        (

                                                                                    somethin.pos = tempRay.pos

                                                                                    somethin.dir = tempRay.dir

                                                                        )

                                                                        else -- otherwise make it reset

                                                                        (

                                                                                    ResetStuff now

                                                                        )

                                                                        str --functions need to return somethin right

                        )

                       

                        on start do

                        (

                                   

                                    --if something is selected

                                    if $!=undefined then

                                    (

                                                somethin=$

                                                OrgPos=somethin.pos  --save original position

                                                OrgRot=somethin.dir --save original rotation

                                                target_mesh = pickObject message:"Pick Target Surface" forceListenerFocus:false filter:g_filter

                                    )

                                    else -- if nothing is selected

                                    (

                                                messageBox "Start this tool with an object selected"

                                                #stop

                                    )

                        )

                        on mouseAbort clicker do 

                        (                       --reset position and rotation

                                    ResetStuff now

                        )

                        on mousePoint clickno do

                        (

                                    if (clickno == 1 and target_mesh!=undefined)then

                                    (

                                                DoMyStuff now -- function calls dont seem to work without a parameter

                                    )

                                    else

                                    (

                                                #stop --bail

                                    )

                        )

                        on freeMove do

                        (

                                    if target_mesh!=undefined then

                                    (

                                    DoMyStuff now --this way it actually shows it is workin

                                    )

                                    else

                                    (

                                                #stop --bail

                                    )

                        )

                        on mouseMove clickno do

                        (

                                    if StartDragging==0 then

                                    (

                                                posy = somethin.pos -- dont ask why i need this

                                                roty = somethin.rotation -- dont ask why i need this

                                                OrgViewY=viewPoint.y -- store click loc for later

                                                StartDragging=1 -- make sure this dont happen again

                                    )

                                    somethin.rotation = roty -- dont ask why setting rotation moves the object

                                    somethin.pos = posy -- but now we got to move it back... theres got to be a better way

                                    local tempRot = eulerangles 0 0 0   -- make a blank euler

                                    tempRot.z=((viewPoint.y-OrgViewY)/2) -- make it only rotate more or less by initial screen click loc

                                    in coordsys local rotate somethin tempRot -- and finally rotate locally

                                    --somethin.pos = posy

                        )

            )

 

            startTool AlignToSurfaceTool

)