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

# Poczekaj w sianie na przejście patrolu, uwzględniając czas dojścia do celu.
func safe_leg(target:Vector3, round_trip:bool) -> bool:
	var start:Vector3=camp.ground
	var duration:=start.distance_to(target)/float(camp.WALK_SPEED)
	var end_time:=duration*2+.18 if round_trip else duration
	for frame in ceili(end_time*30)+1:
		var t:=frame/30.0
		var position:=start.move_toward(target,camp.WALK_SPEED*t)
		if round_trip and t>duration+.18:
			position=target.move_toward(start,camp.WALK_SPEED*(t-duration-.18))
		if camp.cover(position)>=0: continue
		var angle:float=camp.patrol_angle+t*camp.PATROL_SPEED/camp.PATROL_RADIUS
		var offset:Vector3=position-camp.PATROL_CENTER-Vector3(cos(angle),0,sin(angle))*camp.PATROL_RADIUS
		if offset.length()<camp.LOOK_RANGE+.2 and offset.normalized().dot(Vector3(-sin(angle),0,cos(angle)))>cos(deg_to_rad(camp.LOOK_ANGLE*.5+5)): return false
	return true

func cross_to(target:Vector3, round_trip:=false) -> bool:
	for tick in 1500:
		if safe_leg(target,round_trip):
			await walk(target)
			return camp.ground.distance_to(target)<.12
		await tree.physics_frame
	return false

func rescue(i:int,click:Callable) -> bool:
	while camp.phase==camp.Phase.INTRO: await tree.physics_frame
	if camp.phase==camp.Phase.FIRST:
		await walk(camp.STACKS[0])
	while camp.phase!=camp.Phase.PATROL: await tree.physics_frame
	if camp.inside!=0 and not await cross_to(camp.STACKS[0]): return false
	var route:Array=[[1,4],[2,5],[3,6]][i]
	for j in route:
		if not await cross_to(camp.STACKS[j]): return false
	if not await cross_to(camp.TETHERS[i],true): return false
	await click.call(camp.hand)
	if not camp.following or camp.chosen!=i: return false
	route.reverse()
	await walk(camp.STACKS[route[0]])
	if camp.inside!=route[0]: return false
	if not await cross_to(camp.STACKS[route[1]]): return false
	if not await cross_to(camp.STACKS[0]): return false
	while not safe_leg(camp.TOBO,false): await tree.physics_frame
	var mask:int=camp.rescued_mask
	for tick in 150:
		var towards:Vector3=camp.ground.direction_to(camp.TOBO)
		game.stick.vector=Vector2(towards.x,towards.z)
		await tree.physics_frame
		if camp.rescued_mask!=mask:
			game.stick.vector=Vector2.ZERO
			return camp.rescued_mask==(mask | (1<<i))
	game.stick.vector=Vector2.ZERO
	return false
