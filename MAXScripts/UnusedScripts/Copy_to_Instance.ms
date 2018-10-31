------------------------------------------------------------------------------------------------------
--Copy to Instance Script.
--(C) Sam O'Hare, Pixelpollen.com, 2004
--Email sam@pixelpollen.com
--Version 0.1
--Current Functionality
--Turn copies back into instances, based on object type, keeping all transforms.
--
--Proposed Functionality:
--Deal happily with all hierarchies too. Return numbers for successful and rejected objects.
------------------------------------------------------------------------------------------------------

--Variables--
global master
global count_good
global count_bad

-- Function to replace the object
fn ReplaceObj obj =
(
	print (classOf(obj))
	instanceReplace obj master
	count_good += 1
--	Succeeded.value = count_good
)

-- Function which checks the type of current object
fn ObjectSort obj =
(
	if classOf(obj) == classOf(master) then
		ReplaceObj obj
		else (
		count_bad += 1
	--	Failed.value = count_bad
	)
)	

--Functions--

-- Function which Checks for Groups
fn ObjectSetSort objs =
(
	for obj in objs do
	if classof obj == ObjectSet then
		for i in obj do
			ObjectSetSort obj
	else
	(
		ObjectSort obj
	)
)

--Define utility
rollout Copy_Instance "Copy to Instance"
(
	group "Pick Master Object"
	(
		pickbutton picker "Master Object" toolTip:"Object to be instanced"
		edittext master_type "Object Type:" text:"Select Object"
	)
	on picker picked obj do
	(
		picker.text = obj.name
		master_type.text = classOf(obj) as string
		master = obj
	)
	group "Convert Objects"
	(
		button go "Instance"
--		spinner Suceeded "Instanced:" type:#integer
--		spinner Failed "Rejected:" type:#integer
	)	
	on go pressed do
	(
		if master == undefined then
		(
			alert "No master object selected!"
		)
		else
		(
			count_good = 0
			count_bad = 0
			cs = getcurrentselection()
			ObjectSetSort cs
		)
	)		
)--End Utility

CreateDialog Copy_Instance;

print "Run";