macroScript SuperSmartCreate
category:"Pedro Scripts"
toolTip:"Super Smart Create"

(
	local curObj = modPanel.getCurrentObject()

	function PressButton btnName =
	(
		max modify mode
		df = #max -- docked command panel
		--	df = 0 -- float command panel
		for child in (windows.getChildrenHWND dF) where child[4] == "#32770" do
		(
			for classN in (windows.getChildrenHWND child[1]) where (classN[4] == "ModifyTask") do
			(
				for btn in (windows.getChildrenHWND classN[1]) where (btn[5] == btnName) do
				(
					UIAccessor.PressButton btn[1]
				)
			)
		)
	)

	function GetVertUsingEdge edgesBA =
	(
		edgeVertsBA = #{}
		for i in edgesBA do
		(
			edgeVertsBA[curObj.GetEdgeVertex i 1 node:$] = true
			edgeVertsBA[curObj.GetEdgeVertex i 2 node:$] = true
		)
		--
		edgeVertsBA
	)


	Case (classOf curObj) of
	(
		Edit_Poly:
		(
			Case subobjectlevel of
			(
				1: (curObj.ButtonOp #ConnectVertices)

				2:
				(
					Edgs = curObj.GetSelection #edge as array
					case (Edgs.count) of
					(
						0: (PressButton "Create")
						1:
						(
							--Inserts a vertex in the selected edge
							curObj.divideEdge (Edgs[1]) 0.5
							curObj.commit()
							subobjectLevel = 1
						)
						2:
						(
							edgeAvertsBA = (GetVertUsingEdge #{Edgs[1]})
							edgeBvertsBA = (GetVertUsingEdge #{Edgs[2]})
							--	3dsMax 2012 +
-- 							PolyToolsModeling.CreateFace (EdgA + EdgB)
							if (edgeVertsBA = (edgeAvertsBA + edgeBvertsBA)).numberset == 3 then
								curObj.CreateFace (edgeVertsBA as array)
							else
							(
								facesCnt = $.NumFaces
								curObj.bridgeSelected = 1
								curObj.BridgeEdges Edgs[1] Edgs[2] node:$
								curObj.commit()
								if $.NumFaces - facesCnt == 0 do
								(
									--curObj.connectEdgeSegments = 1
									--curObj.ButtonOp #ConnectEdges
									curbObj.SetOperation #ConnectEdges
								)
							)
						)
						default:
						(
							facesCnt = $.NumFaces
							curObj.bridgeSelected = 1
							--curObj.ButtonOp #BridgeEdge
							curObj.SetOperation #BridgePolygon
							curObj.commit()
							if $.NumFaces - facesCnt == 0 do
							(
								--curObj.connectEdgeSegments = 1
								--curObj.ButtonOp #ConnectEdges
								curbObj.SetOperation #ConnectEdges
							)
						)
					)
				)

				3:	(curObj.ButtonOp #Cap)

				4:
				(
					if (((curObj.getSelection #face) as array).count < 2) then
						PressButton "Create"
					else
					(
						curObj.ButtonOp #BridgePolygon
					)
				)

				5:	()
			)
		)




		Editable_poly:
		(Case subobjectlevel of
			(
			 1: (curObj.EditablePoly.ConnectVertices ())

			 2:	(if (((polyop.getEdgeSelection $.baseobject) as array).count == 0) then
				 (
					 macros.run "Editable Polygon Object" "EPoly_ECreate"
				 )
				 local doBridgeConnect = false
				 Edgs = polyop.GetEdgeSelection curObj as array
				 case (Edgs.count) of
				 (
					1: (
						--Inserts a vertex in the selected edge
						curObj.EditablePoly.divideEdge (Edgs[1]) 0.5 select:on
						subobjectLevel = 1
					)
					2: (
						(
							EdgA = PolyOp.getEdgeVerts  curObj Edgs[1]
							EdgB = PolyOp.getEdgeVerts  curObj Edgs[2]
							if (EdgA[2]==EdgB[1]) then
							(
								curObj.CreateFace #(EdgA[1],EdgA[2],EdgB[2])
							) else
							if (EdgB[2] == EdgA[1]) then
							(
								curObj.CreateFace #(EdgB[1],EdgB[2],EdgA[2])
							) else
							  (
								  doBridgeConnect = true
							  )
						)
					)
					default: ( doBridgeConnect = true )
				 )
				 if doBridgeConnect then
				 (
					 curObj.bridgeSelected = 1
					 if not (curObj.EditablePoly.Bridge()) then
					 (
						 curObj.connectEdgeSegments = 1
						 curObj.EditablePoly.ConnectEdges ()
					 )
				 )
			 )

			 3:	(curObj.EditablePoly.capHoles #Edge)

			 4:	(if ((($.GetSelection #Face) as array).count < 2) then
					 macros.run "Editable Polygon Object" "EPoly_Create"
                 else
					(
						$.bridgeSelected = 1
						$.EditablePoly.Bridge ()
					)
                )

			 5:	()
			)
		)



		unwrap_uvw:
		(Case SubobjectLevel of
			(
			1:  ()
			2: 	()
			3: 	()
			)
		)
	)
)