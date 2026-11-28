extends "res://scripts/whisper_cave.gd"

const RED := Color("#e7685d")
const BLUE := Color("#66c7ef")
var pieces:Array[MeshInstance3D]=[]
var homes:Array[Vector3]=[]
var socket:MeshInstance3D
var panels:Array[MeshInstance3D]=[]
var solution:int
var held:=-1
var finger:=-1
var targets:Array[MeshInstance3D]=[]
var swimmers:Array[MeshInstance3D]=[]
var expected:=0
var clicks:=0
var motion_time:=0.0
var second_hand:Node3D

func setup(owner_story) -> void:
	if owner_story.id() in ["crystal_hall","drip_tunnel"] and not owner_story.numbers.has("drops_won"):
		owner_story.numbers["drops_won"]=owner_story.marks
	super.setup(owner_story)
	match story.id():
		"pattern_door": build_pattern()
		"fish_pool": build_pool()
		"whisper_hands": build_hands()
		"whisper_legs": build_legs()
		"whisper_exit": build_exit()

func grant(index:int) -> void:
	story.numbers["cave_rewards"]=int(story.numbers.get("cave_rewards",0)) | (1<<(index-2))

func hall() -> void:
	story.go_to("crystal_hall",0,int(story.numbers.get("drops_won",0)))

func build_pattern() -> void:
	game.hud.text="Kryształowe drzwi"
	var sizes:bool=story.part%2==1
	var solved:bool=story.part>=2
	for side in [-1,1]:
		var panel=game.box(self,Vector3(side*1.80,1.1,-1.65),Vector3(3.55,2.4,.34),Color("#554766"))
		panels.append(panel)
	for i in 6:
		var parent:=panels[i/3]
		var at:=Vector3((i-2.5)*1.06,1.35,-1.26)
		if i==5 and not solved:
			socket=game.orb(self,at,.47,Color("#241d38"))
			socket.scale.z=.35
			continue
		var big:bool=i%3==0
		var gem:=crystal(at,(1.32 if big else .67) if sizes else 1.05)
		gem.material_override.albedo_color=BRIGHT if sizes else (RED if i%2==0 else BLUE)
		gem.reparent(parent,true)
	if solved:
		for panel in panels:
			panel.create_tween().tween_property(panel,"position:x",panel.position.x*1.8,.65)
		story.say("pattern_open")
		if sizes: story.button("Dalej",hall)
		else: story.button("Dalej",story.go_to.bind("pattern_door",1))
		return
	if not story.numbers.has("door_side_%d"%story.part):
		story.numbers["door_side_%d"%story.part]=randi_range(0,1)
		story.checkpoint()
	solution=story.numbers["door_side_%d"%story.part]
	for i in 2:
		var at:=Vector3((i-.5)*2.25,.75,.63)
		var gem:=crystal(at,(.67 if i==solution else 1.32) if sizes else 1.05)
		gem.material_override.albedo_color=BRIGHT if sizes else (BLUE if i==solution else RED)
		pieces.append(gem)
		homes.append(at)
	story.say("cave_size" if sizes else "cave_color")

func fit_piece(i:int) -> void:
	if i==solution:
		grant(2+story.part)
		story.go_to("pattern_door",story.part+2)
	else:
		clicks+=1
		pieces[i].rotation.z=.42
		pieces[i].create_tween().tween_property(pieces[i],"rotation:z",0,.4)
		if clicks>=2:
			var mat:=pieces[solution].material_override as StandardMaterial3D
			mat.emission=mat.albedo_color
			mat.emission_enabled=true
		story.say("cave_pattern_hint" if clicks>=2 else "cave_pattern_retry")

func build_pool() -> void:
	game.hud.text="Świecące rybki"
	game.orb(self,Vector3(0,.07,-.72),3.55,Color("#285978")).scale=Vector3(1.2,.04,.54)
	build_whisper()
	whisper.position=Vector3(-3.8,0,-1.8)
	torch.position=whisper.position+Vector3(-.32,.88,.34)
	for i in 6:
		var at:=Vector3((i%3-1)*1.68,.39,-1.65+(i/3)*1.45)
		var fish=game.orb(self,at,.40,Color("#93dfcb"),true)
		fish.scale=Vector3(1.30,.58,.68)
		game.orb(fish,Vector3(-.46,0,0),.22,Color("#70c2ba")).scale.y=1.4
		game.orb(fish,Vector3(.23,.12,.28),.083,Color("#1e3443"))
		swimmers.append(fish)
		if i<4: targets.append(fish)
		elif story.part>=2: fish.hide()
		elif story.part==1:
			var swim=fish.create_tween()
			swim.tween_interval(.32)
			swim.tween_property(fish,"position",at+Vector3(5,0,-2),.92)
			swim.tween_callback(fish.hide)
	if story.part==1:
		for palm in palms:
			var clap=palm.create_tween()
			clap.tween_property(palm,"position:x",0,.23)
			clap.tween_property(palm,"position:x",palm.position.x,.24)
	match story.part:
		0:
			story.say("cave_fish")
			story.button("Dalej",story.go_to.bind("fish_pool",1))
		1:
			story.effect("wood_tap")
			for i in [4,5]:
				swimmers[i].create_tween().tween_property(swimmers[i],"position",swimmers[i].position+Vector3(7,0,-3),1.35)
			story.say("cave_fish")
		2: ask(4,"cave_fish_ask")
		3:
			story.say("cave_lit")
			story.button("Dalej",hall)

func build_hands() -> void:
	game.hud.text="Palce Szeptka"
	build_whisper()
	whisper.position=Vector3(0,0,-2.0)
	torch.position=whisper.position+Vector3(-.32,.88,.34)
	for side in [-1,1]:
		var hand:=Node3D.new()
		add_child(hand)
		hand.position=Vector3(side*1.65,.48,-.62)
		game.orb(hand,Vector3.ZERO,.73,Color("#80ad99")).scale=Vector3(1,.9,.38)
		for j in 3:
			var tip=game.orb(hand,Vector3((j-1)*.54,.76,.06),.22,Color("#a8ceaa"))
			tip.scale.y=2.25
			targets.append(tip)
		if side==1: second_hand=hand
	second_hand.visible=story.part!=0
	match story.part:
		0:
			story.say("cave_palms")
			story.button("Dalej",story.go_to.bind("whisper_hands",1))
		1: ask(6,"cave_palms")
		2:
			story.say("cave_lit")
			story.button("Dalej",story.go_to.bind("whisper_legs"))

func build_legs() -> void:
	game.hud.text="Bilbo i kucyk Toba"
	var bilbo:Node3D=preload("res://art/leo.glb").instantiate()
	add_child(bilbo)
	bilbo.position=Vector3(-1.8,.24,-.6)
	bilbo.scale=Vector3.ONE*1.5
	game.leo.global_position=to_global(Vector3(-16,0,0))
	var pony:=preload("res://scripts/pony.gd").make(game,self,Vector3(1.5,.15,-.85),Color.PERU)
	pony.scale=Vector3.ONE*1.68
	pony.rotation.y=.75
	if story.part!=1:
		for side in [-1,1]:
			var boot=game.orb(bilbo,Vector3(side*.23,.10,.08),.17,Color.SADDLE_BROWN)
			targets.append(boot)
	if story.part!=0:
		for side in [-1,1]:
			for z in [-.35,.35]:
				var hoof=game.orb(pony,Vector3(side*.22,.08,z),.12,Color("#694831"))
				targets.append(hoof)
	ask([2,4,6][story.part],["cave_boots","cave_hooves","cave_together"][story.part])

func ask(total:int,key:String) -> void:
	expected=total
	story.say(key)
	for n in story.Data.number_choices(total): story.button(str(n),respond.bind(n))

func show_count(n:int) -> void:
	for i in targets.size():
		var mat:=targets[i].material_override as StandardMaterial3D
		mat.emission_enabled=i<n
		mat.emission=Color.GOLD

func respond(n:int) -> void:
	if n!=expected:
		story.say("cave_count")
		story.hint_miss(expected,show_count)
		return
	match story.id():
		"fish_pool":
			grant(4)
			story.go_to("fish_pool",3)
		"whisper_hands":
			grant(5)
			story.go_to("whisper_hands",2)
		"whisper_legs":
			if story.part<2: story.go_to("whisper_legs",story.part+1)
			else:
				grant(6)
				if "Latarka" not in story.items: story.items.append("Latarka")
				story.go_to("whisper_exit")

func build_exit() -> void:
	build_whisper()
	story.say("cave_final")
	torch.position=whisper.position+Vector3(-.32,.88,.34)
	torch.create_tween().tween_property(torch,"position",Vector3(-3.30,1,1.18),1.15)
	var lamp:=OmniLight3D.new()
	add_child(lamp)
	lamp.position=Vector3(0,2,1)
	lamp.omni_range=12
	lamp.light_color=Color("#ffdea3")
	lamp.light_energy=0
	lamp.create_tween().tween_property(lamp,"light_energy",2.4,1.15)

func finish_chapter() -> void:
	story.chapters=maxi(4,story.chapters)
	story.advance()

func _process(dt:float) -> void:
	super._process(dt)
	if not is_visible_in_tree() or game.paused: return
	if story.id()=="whisper_exit" and story.age>=maxf(1.5,story.speech_end):
		finish_chapter()
		return
	if story.id()=="fish_pool" and story.part==1:
		motion_time+=dt
		if motion_time>=1.4: story.go_to("fish_pool",2)

func _input(event:InputEvent) -> void:
	super._input(event)
	if not is_inside_tree() or not is_visible_in_tree() or game.paused: return
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag): return
	if event is InputEventScreenTouch and event.pressed:
		if story.dock.get_global_rect().has_point(event.position): return
		if finger!=-1: return
		for i in pieces.size():
			if screen_at(pieces[i]).distance_to(event.position)<36:
				held=i
				finger=event.index
				return
		if expected==0: return
		var nearest:=-1
		var radius:=30.0
		for i in targets.size():
			var d:=screen_at(targets[i]).distance_to(event.position)
			if d<radius:
				radius=d
				nearest=i
		if nearest>=0 and not (counted & (1<<nearest)):
			counted|=1<<nearest
			clicks+=1
			Count.mark(targets[nearest],clicks,false,.38)
			story.effect("count_%d"%clicks)
	elif finger==event.index and held>=0:
		if event is InputEventScreenDrag:
			var at=Plane(Vector3.UP,.75).intersects_ray(game.camera.project_ray_origin(event.position),game.camera.project_ray_normal(event.position))
			if at!=null: pieces[held].global_position=at
		else:
			var i:=held
			held=-1
			finger=-1
			pieces[i].position=homes[i]
			if not event.canceled and screen_at(socket).distance_to(event.position)<42: fit_piece(i)

func screen_at(node:Node3D) -> Vector2:
	return game.camera.unproject_position(node.global_position)
