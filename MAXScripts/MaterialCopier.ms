macroScript MaterialCopier category: "Calvinatorr_Custom" tooltip: "Material Copier"
(
	target = PickObject prompt:"Pick object to copy material from";
	if (target != undefined and $ != undefined) then
	(
		$.material = target.material;
	)
)