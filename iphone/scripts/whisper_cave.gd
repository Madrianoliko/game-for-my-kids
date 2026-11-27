extends Node3D

const FLASH_TIME := 1.0
const DROP_INTERVAL := 1.38
const COUNTS := [3,5]
const DULL := Color("#3f4964")
const BRIGHT := Color("#74eef3")
var story
var game
var entrances:Array[Node3D]=[]
var wall_gems:Array[MeshInstance3D]=[]
var flashes:Array[MeshInstance3D]=[]
var answers:Array[Button]=[]
var listening:=false
var heard:=0
var elapsed:=0.0
var next_drop:=0.0
var counted:=0
var whisper:Node3D
var palms:Array[MeshInstance3D]=[]
var torch:Node3D
var theft_time:=0.0

func setup(owner_story) -> void:
	story=owner_story
	game=story.host
	game.hud.text="Jaskinie Szeptka"
	var focus:=global_position+Vector3(0,.4,1.8)
	game.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	game.camera.size=8.6
	game.camera.look_at_from_position(focus+Vector3(0,5,8),focus,Vector3.UP)
	game.box(self,Vector3(0,-.25,0),Vector3(26,.5,22),Color("#45455a"))
	game.box(self,Vector3(0,1,-3.8),Vector3(19,6,1),Color("#37354d"))
	game.leo.global_position=to_global(Vector3(-3.65,0,1.0))
	for i in 7:
		var gem:=crystal(Vector3((i-3)*1.05,2.55,-2.7),.83)
		wall_gems.append(gem)
		glow(gem,reward_lit(i))
	match story.id():
		"whisper_cave": build_encounter()
		"crystal_hall": build_hall()
		"drip_tunnel": build_drops()

func reward_lit(i:int) -> bool:
	if i<2:
		return i<story.numbers.get("drops_won",0)
	return (int(story.numbers.get("cave_rewards",0)) & (1<<(i-2)))!=0

func crystal(at:Vector3,height:float) -> MeshInstance3D:
	var cut:=SphereMesh.new()
	cut.radial_segments=5
	cut.rings=1
	cut.height=height
	cut.radius=height*.34
	var gem:MeshInstance3D=game.mesh(self,cut,at,DULL)
	gem.rotation.z=sin(at.x)*.12
	return gem

func glow(gem:MeshInstance3D,on:bool) -> void:
	var mat:=gem.material_override as StandardMaterial3D
	mat.albedo_color=BRIGHT if on else DULL
	mat.emission_enabled=on
	mat.emission=BRIGHT

func build_whisper() -> void:
	whisper=Node3D.new()
	add_child(whisper)
	game.orb(whisper,Vector3.UP*.72,.36,Color("#83aba0")).scale=Vector3(.72,1.85,.7)
	game.orb(whisper,Vector3.UP*1.54,.46,Color("#94bca8"))
	for side in [-1,1]:
		var eye=game.orb(whisper,Vector3(side*.19,1.62,.34),.16,Color.IVORY)
		game.orb(eye,Vector3(-.025,0,.13),.07,Color("#323447"))
		game.orb(whisper,Vector3(side*.24,.16,.1),.18,Color("#688a83"))
		palms.append(game.orb(whisper,Vector3(side*.31,.88,.18),.13,Color("#a9d0ae")))
	torch=Node3D.new()
	add_child(torch)
	game.box(torch,Vector3.ZERO,Vector3(.24,.28,.65),Color.GOLDENROD)
	game.orb(torch,Vector3(0,0,.35),.19,Color.LEMON_CHIFFON,true)
	whisper.position=Vector3(1.8,0,-.4)
	torch.position=Vector3(-3.16,.9,1.26)

func build_encounter() -> void:
	build_whisper()
	if story.part==0:
		story.say("whisper_steal")
		story.button("Dalej",finish_theft)
	else:
		torch.position=whisper.position+Vector3(-.32,.88,.34)
		story.say("whisper_game")
		story.button("Dalej",story.advance)

func finish_theft() -> void:
	story.items.erase("Latarka")
	story.go_to("whisper_cave",1)

func build_hall() -> void:
	for i in 3:
		var gate:=Node3D.new()
		add_child(gate)
		gate.position=Vector3((i-1)*2.85,.85,-1.8)
		entrances.append(gate)
		if reward_lit([1,3,4][i]):
			game.orb(gate,Vector3(0,1.45,.35),.18,BRIGHT,true)
		game.orb(gate,Vector3.ZERO,1.08,Color("#171727")).scale=Vector3(1,1.28,.32)
		for j in 7:
			var a:=PI*j/6.0
			game.orb(gate,Vector3(cos(a)*1.06,sin(a)*1.20,.02),.32,Color("#635b75"))
		if i==1:
			for j in 3:
				var shard:=crystal(gate.position+Vector3((j-1)*.42,.1,.50),.65)
				shard.material_override.albedo_color=Color.SALMON if j%2==0 else Color.SKY_BLUE
		elif i==2:
			game.orb(gate,Vector3(0,0,.5),.45,Color.AQUAMARINE).scale=Vector3(1.4,.7,.5)
			game.orb(gate,Vector3(-.59,0,.50),.23,Color.TEAL)
		else:
			game.orb(gate,Vector3(0,-.67,.55),.62,Color("#4496ab")).scale=Vector3(1,.11,.52)
			var drop=game.orb(gate,Vector3(0,.64,.57),.15,BRIGHT,true)
			drop.scale.y=1.55
			var drip=drop.create_tween().set_loops()
			drip.tween_property(drop,"position:y",-.55,.70).from(.64)
			drip.tween_interval(.50)
	if reward_lit(1) and reward_lit(3) and reward_lit(4):
		story.say("cave_last")
		story.button("Dalej",story.go_to.bind("whisper_hands"))
	else: story.say("cave_choose")

func build_drops() -> void:
	game.hud.text="Kapiące krople"
	var round_index:int=story.marks-1 if story.part==3 else story.marks
	var amount:int=COUNTS[round_index]
	for i in amount:
		var at:=Vector3((i-(amount-1)*.5)*1.18,.89,-.65)
		flashes.append(crystal(at,1.15))
		game.orb(self,at+Vector3.DOWN*.78,.48,Color("#34586b")).scale.y=.13
	if story.part==3:
		if int(story.numbers.get("cave_rewards",0))!=0: story.say("cave_lit")
		else: story.say("whisper_first" if story.marks==1 else "whisper_done")
		if story.marks==1: story.button("Dalej",story.go_to.bind("drip_tunnel",0,1))
		else: story.button("Dalej",story.go_to.bind("crystal_hall",0,2))
		return
	for n in story.Data.number_choices(amount):
		answers.append(story.button(str(n),answer.bind(n)))
	listen()

func listen() -> void:
	if game.paused: return
	if story.part==3:
		story.prompt(story.voice,story.caption.text)
		return
	story.say(["whisper_drops","whisper_again","whisper_help"][story.part])
	elapsed=0
	heard=0
	counted=0
	next_drop=game.narrator.stream.get_length()+.22 if game.sound else .45
	listening=true
	story.curtain.color.a=.38
	for gem in flashes: glow(gem,false)
	for button in answers: button.disabled=true

func _process(dt:float) -> void:
	if not is_visible_in_tree() or game.paused: return
	if story.id()=="whisper_cave" and story.part==0:
		theft_time+=dt
		var approach:=smoothstep(.3,1.45,theft_time)
		var retreat:=smoothstep(1.63,2.8,theft_time)
		whisper.position=Vector3(1.8,0,-.4).lerp(Vector3(-2.85,0,.94),approach*(1-retreat))
		if theft_time>=1.45: torch.position=whisper.position+Vector3(-.32,.88,.34)
	if not listening: return
	elapsed+=dt
	if heard>0 and story.part<2 and elapsed>=next_drop-DROP_INTERVAL+FLASH_TIME:
		glow(flashes[heard-1],false)
	if elapsed<next_drop: return
	if heard==flashes.size():
		listening=false
		story.curtain.color.a=.12
		for button in answers: button.disabled=false
		return
	story.effect("story/water_drop")
	glow(flashes[heard],true)
	heard+=1
	next_drop=elapsed+DROP_INTERVAL

func answer(n:int) -> void:
	if listening or game.paused or story.part==3: return
	if n==COUNTS[story.marks]:
		story.numbers["drops_won"]=story.marks+1
		story.go_to("drip_tunnel",3,story.marks+1)
	else:
		story.part=mini(2,story.part+1)
		story.checkpoint()
		listen()

func _input(event:InputEvent) -> void:
	if not is_visible_in_tree() or game.paused: return
	if not (event is InputEventScreenTouch and event.pressed): return
	if story.dock.get_global_rect().has_point(event.position): return
	if story.id()=="crystal_hall":
		for i in entrances.size():
			var door:Vector2=game.camera.unproject_position(entrances[i].global_position)
			if door.distance_to(event.position)<50 and not reward_lit([1,3,4][i]):
				story.go_to(["drip_tunnel","pattern_door","fish_pool"][i],int(reward_lit(2)) if i==1 else 0,story.numbers.get("drops_won",0) if i==0 else 0)
				return
	elif story.id()=="drip_tunnel" and not listening and story.part==2:
		for i in flashes.size():
			var xy:Vector2=game.camera.unproject_position(flashes[i].global_position)
			if xy.distance_to(event.position)<28 and not (counted & (1<<i)):
				counted|=1<<i
				var total:=0
				for j in flashes.size():
					if counted & (1<<j): total+=1
				story.effect("count_%d"%total)
				break
