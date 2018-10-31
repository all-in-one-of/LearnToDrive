plugin modifier ChamferBySG
name:"Chamfer By SG"
classID:#(0x31316d6c, 0x51eea459)
extends:Chamfer replaceUI:false version:1
(
	parameters main rollout:params
	(
		--bendamt type:#float animatable:true ui:bendamt default:0.0
		--on bendamt set val do delegate.angle = val
		
		--amount type:#worldUnits default:2.0
		--on amount set val do delegate.amount = val;
		
		amount type:#worldUnits default:10;
		on amount set val do delegate.amount = val;
		
		tension type:#float default:0.5;
		on tension set val do delegate.tension = val;
			
		segments type:#integer default:3;
		on segments set val do delegate.segments = val;
		
		smoothingGroup type:#integer ui:spinSG default:5;
		--on smoothingGroup set val do delegate.smoothingGroup = val;
	)

	rollout params "ChamferBySG Parameters"
	(
		--spinner bendamt "Bendiness: "
		spinner spinSG "Smoothing Group" type:#integer range:[1, 32, 5];
		on spinSG changed arg do print arg;
	)
)