extends RefCounted

var camp
var tree:SceneTree
var game

func _init(active_camp) -> void:
	camp=active_camp
	tree=camp.get_tree()
	game=camp.host

func walk(target:Vector3) -> void:
	for tick in 500:
		var delta:Vector3=target-camp.ground
		if delta.length()<.08: break
		game.stick.vector=Vector2(delta.x,delta.z).normalized()
		await tree.physics_frame
	game.stick.vector=Vector2.ZERO

func next_window() -> void:
	while camp.phase!=camp.Phase.LOOK: await tree.physics_frame
	while camp.phase!=camp.Phase.BACK: await tree.physics_frame

func rescue(i:int,click:Callable) -> bool:
	while camp.phase==camp.Phase.INTRO: await tree.physics_frame
	if camp.phase==camp.Phase.FIRST:
		while camp.phase==camp.Phase.FIRST:
			var delta:Vector3=camp.STACKS[0]-camp.ground
			game.stick.vector=Vector2(delta.x,delta.z).normalized()
			await tree.physics_frame
		game.stick.vector=Vector2.ZERO
	while camp.phase!=camp.Phase.BACK: await tree.physics_frame
	var last:int=[2,4,5][i]
	for j in range(1,last+1):
		await walk(camp.STACKS[j])
		if camp.inside!=j: return false
		await next_window()
	if i<2:
		await walk(camp.SIDE_STACKS[i])
		await next_window()
	await walk(camp.TETHERS[i])
	await click.call(camp.hand)
	if not camp.following or camp.chosen!=i: return false
	if i<2:
		await walk(camp.SIDE_STACKS[i])
		await next_window()
	for j in range(last,-1,-1):
		await walk(camp.STACKS[j])
		if camp.inside!=j: return false
		await next_window()
	var mask:int=camp.rescued_mask
	for tick in 150:
		var delta:Vector3=camp.TOBO-camp.ground
		game.stick.vector=Vector2(delta.x,delta.z).normalized()
		await tree.physics_frame
		if camp.rescued_mask!=mask: break
	game.stick.vector=Vector2.ZERO
	return camp.rescued_mask==(mask | (1<<i))
