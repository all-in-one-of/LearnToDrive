macroScript CloneAppendName
category: "Calvinatorr_Custom"
tooltip: "Clone & Append Name"
(
	global rol_Clone
	try(destroyDialog rol_Clone)catch()
	rollout rol_Clone ""
	(
		edittext et_suffix "Suffix:" text:""
		edittext et_layerName "Layer Name:" text:""
		group "Offset:"
		(
			spinner spn_offsetX "X:" range:[-1e9,1e9,0] type:#worldunits
			spinner spn_offsetY "Y:" range:[-1e9,1e9,0]  type:#worldunits
			spinner spn_offsetZ "Z:" range:[-1e9,1e9,0]  type:#worldunits
		)
	
		button btn_clone "Clone" across:3 align:#left;
		button InstanceButton "Instance" across:3 align:#center;
		button ReferenceButton "Ref" across:3 align:#right;
		
		function Clone cloneType:#copy = 
		(
			local objToCloneArr = selection as array
			local newObjsArr = #()
			for o in objToCloneArr do
			(
				local newNodesArr = #()
				maxOps.CloneNodes o offset:[spn_offsetX.value,spn_offsetY.value,spn_offsetZ.value] expandHierarchy:false cloneType:cloneType newNodes:&newNodesArr
				newNodesArr[1].name = o.name + et_suffix.text
				append newObjsArr newNodesArr[1]
			)
			if newObjsArr.count != 0 do
			(
				if et_layerName.text != "" then
				(
					if LayerManager.getLayerFromName et_layerName.text == undefined 	then
					(
						newLayer = LayerManager.newLayerFromName et_layerName.text
						for o in newObjsArr do newLayer.addNode o
					)
					else
					(
						newLayer = LayerManager.getLayerFromName et_layerName.text
						for o in newObjsArr do newLayer.addNode o
					)
				)
			)
		)
 
		on btn_clone pressed do
		(
			Clone cloneType:#copy;
		)		
		
		on ReferenceButton pressed do
		(
			Clone cloneType:#reference;
		)
		
		on InstanceButton pressed do
		(
			Clone cloneType:#instance;
		)
	)
	createdialog rol_Clone width:180;
)