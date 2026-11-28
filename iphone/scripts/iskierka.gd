extends Node3D

const SHRUB := Vector3(-2,0,-1.4)
const LANTERN := Vector3(7,0,-1.4)
const START := SHRUB + Vector3.LEFT * 37
const BERRY_PATCH := LANTERN + Vector3.RIGHT * 9
const SPEED := 3.4
var demonstrated := false
var fire_button:Button
const LEAVES := [Vector3(-2.1,.28,-.9),Vector3(2.1,.28,-.9)]
var story
var game
var dragon:Node3D
var wings:Array[MeshInstance3D]=[]
var paw:MeshInstance3D
var brows:Array[MeshInstance3D]=[]
var head:Node3D
var spark:MeshInstance3D
var flame:MeshInstance3D
var leaves:Array[MeshInstance3D]=[]
var berries:Array[MeshInstance3D]=[]
var slots:Array[int]=[]
var finger:=-1
var held:=-1
var mistakes:=0
var pointing:=-1

func setup(owner_story) -> void:
	story=owner_story
	game=story.host
	game.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	game.camera.size=8.6
	var focus:=global_position+Vector3(0,0,1.45)
	game.camera.look_at_from_position(focus+Vector3(0,9,6),focus,Vector3.UP)
	if story.id()=="dragon_map":
		build_map()
		return
	game.box(self,Vector3(0,-.18,0),Vector3(18,.35,14),Color("#91aa63"))
	for x in [-4.4,4.4]:
		game.box(self,Vector3(x,1,-2.8),Vector3(.42,2,.45),Color.SADDLE_BROWN)
		game.orb(self,Vector3(x,2,-2.8),1.25,Color.DARK_OLIVE_GREEN)
		for i in 3: game.orb(self,Vector3(x-.6+i*.45,1.95,-1.8),.16,Color.INDIAN_RED)
	game.orb(self,SHRUB+Vector3.LEFT*.65,.85,Color("#507547"))
	dragon=Node3D.new()
	add_child(dragon)
	dragon.position=SHRUB
	build_dragon()
	if story.id()=="dragon_orchard": build_orchard()
	else: build_berries()

func build_map() -> void:
	game.hud.text="Mapa Dymiącej Góry"
	game.leo.global_position=to_global(Vector3(-1.5,0,0))
	game.box(self,Vector3(.38,.65,0),Vector3(2.4,.13,1.5),Color.SADDLE_BROWN)
	var paper=game.box(self,Vector3(.38,.77,0),Vector3(2,.06,1.18),Color.WHEAT)
	paper.scale.x=.15
	paper.create_tween().tween_property(paper,"scale:x",1.0,.75)
	var peak:=PrismMesh.new()
	peak.size=Vector3(.78,.55,.25)
	game.mesh(paper,peak,Vector3(0,.31,0),Color.SIENNA)
	for i in 3: game.orb(paper,Vector3(i*.12,.66+i*.16,0),.1+i*.025,Color.GRAY)
	story.say("dragon_map")
	story.button("Dalej",story.advance)

func build_dragon() -> void:
	var skin:=Color("#e68a57")
	game.orb(dragon,Vector3(0,.46,0),.47,skin).scale.z=1.25
	head=Node3D.new()
	dragon.add_child(head)
	head.position=Vector3(0,.93,.28)
	game.orb(head,Vector3.ZERO,.4,skin)
	game.orb(head,Vector3(0,-.08,.3),.26,Color("#ffd091"))
	for side in [-1,1]:
		game.orb(head,Vector3(side*.19,.08,.31),.065,Color("#322338"))
		brows.append(game.box(head,Vector3(side*.19,.18,.32),Vector3(.15,.035,.04),Color.SIENNA))
		game.orb(head,Vector3(side*.25,.36,-.05),.11,Color.WHEAT).scale.y=1.65
		var wing:=PrismMesh.new()
		wing.size=Vector3(.64,.61,.14)
		var blade=game.mesh(dragon,wing,Vector3(side*.47,.78,-.13),Color("#ba685c"))
		blade.rotation.z=-side*.55
		wings.append(blade)
		game.orb(dragon,Vector3(side*.3,.14,.2),.18,skin)
	paw=game.orb(dragon,Vector3(.29,.44,.32),.15,skin)
	spark=game.orb(head,Vector3(0,-.04,.61),.14,Color.ORANGE,true)
	spark.scale=Vector3.ONE*.6

func build_orchard() -> void:
	game.hud.text="Ślady w sadzie"
	game.box(self,Vector3(-11,-.2,-1),Vector3(66,.36,12),Color("#91aa63"))
	for x in range(-40,19,4):
		game.box(self,Vector3(x,.9,-4),Vector3(.4,1.8,.45),Color.SADDLE_BROWN)
		game.orb(self,Vector3(x,2,-4),1.2,Color.DARK_OLIVE_GREEN)
		for i in 3: game.orb(self,Vector3(x-.5+i*.5,2,-3),.15,Color.INDIAN_RED)
	for i in 40:
		var at:=START+Vector3(i*.91,.04,.32 if i%2 else -.12)
		game.orb(self,at,.15,Color("#594431")).scale=Vector3(1,.2,.8)
		for toe in [-1,0,1]:
			game.orb(self,at+Vector3(.14,0,toe*.09),.055,Color("#594431")).scale.y=.35
	game.orb(self,BERRY_PATCH,.85,Color.DARK_OLIVE_GREEN)
	for i in 6: game.orb(self,BERRY_PATCH+Vector3((i%3-1)*.33,.3+floori(i/3.0)*.3,.6),.15,Color.DARK_SLATE_BLUE)
	game.box(self,LANTERN+Vector3.UP*.55,Vector3(.18,1.1,.18),Color.SADDLE_BROWN)
	flame=game.orb(self,LANTERN+Vector3.UP*1.25,.26,Color.GOLD,true)
	flame.visible=story.part==2
	game.orb(self,LANTERN+Vector3.UP*1.05,.33,Color("#67563d")).scale.y=.45
	var start:=START
	match story.part:
		0: story.say("dragon_tracks")
		1:
			start=SHRUB
			story.say("dragon_lost")
		2:
			start=LANTERN
			story.say("dragon_warm")
		3:
			start=LANTERN
			story.say("dragon_demo")
	if story.part in [2,3]: dragon.position=LANTERN+Vector3.LEFT
	if story.part!=3:
		game.mark_goal(to_global([SHRUB,LANTERN,BERRY_PATCH][story.part])+Vector3.UP*1.55)
	start=story.numbers.get("dragon_walk_position",start)
	if story.part in [1,2]: dragon.position=start+Vector3.LEFT*.8
	game.leo.global_position=to_global(start)
	follow_camera()
	story.dock.hide()

func follow_camera() -> void:
	var focus:Vector3=game.leo.global_position+Vector3.RIGHT*1.35
	game.camera.look_at_from_position(focus+Vector3(0,9,6),focus,Vector3.UP)

func walking_input() -> Vector2:
	var motion:Vector2=game.stick.vector
	if motion.is_zero_approx(): motion=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if motion.length()>.1: game.leo.rotation.y=atan2(-motion.x,-motion.y)
	return motion.limit_length()

func walk(dt:float) -> void:
	if story.part==3:
		if not demonstrated and story.age>=story.speech_end:
			demonstrated=true
			var show_fire=create_tween()
			puff_at(dragon.position+Vector3.UP*1.9)
			show_fire.tween_interval(.65)
			show_fire.tween_callback(offer_fire)
		return
	var motion:=walking_input()
	var pos:=to_local(game.leo.global_position)+Vector3(motion.x,0,motion.y)*dt*SPEED
	pos.x=clampf(pos.x,START.x-1,BERRY_PATCH.x+1)
	pos.z=clampf(pos.z,-3,.4)
	game.leo.global_position=to_global(pos)
	follow_camera()
	match story.part:
		0:
			if pos.distance_to(SHRUB)<.65: story.go_to("dragon_orchard",1)
		1:
			if story.voice=="route_dragon_lost" and story.age>=story.speech_end: story.say("dragon_near")
			var lead:=Vector3(clampf(pos.x+2,SHRUB.x,LANTERN.x-.8),0,LANTERN.z)
			dragon.position=dragon.position.move_toward(lead,dt*(SPEED+.6))
			if lead.distance_to(dragon.position)>.01: dragon.look_at(to_global(lead),Vector3.UP,true)
			if pos.distance_to(LANTERN)<.7 and dragon.position.distance_to(LANTERN)<1.5 and story.voice=="route_dragon_near" and story.age>=story.speech_end:
				story.go_to("dragon_orchard",3)
		2:
			dragon.position=dragon.position.move_toward(pos+Vector3.LEFT*.8,dt*SPEED)
			if pos.distance_to(BERRY_PATCH)<.65: story.advance()

func puff_at(target:Vector3) -> void:
	var puff=game.orb(self,to_local(spark.global_position),.27,Color.ORANGE_RED,true)
	var flight=create_tween()
	flight.tween_property(puff,"position",target,.32)
	flight.tween_callback(puff.queue_free)

func offer_fire() -> void:
	story.say("dragon_fire")
	story.dock.show()
	fire_button=story.button("Płomień",sneeze)
	var pulse=fire_button.create_tween().set_loops()
	pulse.tween_property(fire_button,"self_modulate",Color(1,.82,.62),.55)
	pulse.tween_property(fire_button,"self_modulate",Color.WHITE,.55)

func sneeze() -> void:
	if story.part!=3 or game.paused or fire_button.disabled: return
	fire_button.disabled=true
	puff_at(LANTERN+Vector3.UP*1.25)
	var flight=create_tween()
	flight.tween_interval(.32)
	flight.tween_callback(story.go_to.bind("dragon_orchard",2))

func build_berries() -> void:
	game.hud.text="Jagody dla Iskierki"
	game.leo.global_position=to_global(Vector3(-3.4,0,-1.9))
	dragon.position=Vector3(0,0,-2.25)
	for at in LEAVES:
		var leaf=game.orb(self,at,1.15,Color("#629649"))
		leaf.scale=Vector3(1.3,.13,.85)
		game.box(leaf,Vector3(0,.7,0),Vector3(.05,.03,1.55),Color("#a9ce74"))
		leaves.append(leaf)
	for i in 6:
		slots.append((story.marks>>(2*i))&3)
		var berry=game.orb(self,Vector3.ZERO,.26,Color("#584098"))
		game.orb(berry,Vector3(0,.23,0),.09,Color.DARK_OLIVE_GREEN)
		berries.append(berry)
	arrange()
	if story.part==1:
		spark.scale=Vector3.ONE*2.2
		head.rotation.z=.16
		story.say("dragon_full")
		story.button("Dalej",story.advance)
	else: story.say("dragon_share")

func arrange() -> void:
	var occupied:=[0,0,0]
	for i in 6:
		var side:=slots[i]
		var at:=Vector3((i-2.5)*.66,.31,.95)
		if side>0:
			var n:int=occupied[side]
			at=LEAVES[side-1]+Vector3((n%3-1)*.56,.35,(floori(n/3.0)-.5)*.52)
			occupied[side]+=1
		berries[i].position=at

func _input(event:InputEvent) -> void:
	if not is_visible_in_tree() or game.paused or story.id()!="dragon_berries" or story.part!=0: return
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag): return
	if event is InputEventScreenTouch and event.pressed:
		if finger!=-1 or story.dock.get_global_rect().has_point(event.position): return
		for i in 6:
			var xy:Vector2=game.camera.unproject_position(berries[i].global_position)
			if xy.distance_to(event.position)<22:
				finger=event.index
				held=i
				break
	elif finger==event.index:
		if event is InputEventScreenDrag:
			var hit=Plane(Vector3.UP,.67).intersects_ray(game.camera.project_ray_origin(event.position),game.camera.project_ray_normal(event.position))
			if hit!=null: berries[held].global_position=hit
		else:
			if not event.canceled:
				for side in 2:
					var at:Vector2=game.camera.unproject_position(leaves[side].global_position)
					if at.distance_to(event.position)<60:
						drop(side+1)
						break
			finger=-1
			held=-1
			arrange()

func drop(side:int) -> void:
	slots[held]=side
	story.marks=(story.marks & ~(3<<(2*held))) | (side<<(2*held))
	story.checkpoint()
	if 0 in slots:
		if game.sound: game.play_clip(game.chime,"count_%d"%slots.count(side))
		return
	if slots.count(1)==3:
		story.go_to("dragon_berries",1,story.marks)
	else:
		mistakes+=1
		pointing=0 if slots.count(1)<3 else 1
		for i in 2: brows[i].rotation.z=.40 if i==0 else -.40
		paw.position.x=-.4 if pointing==0 else .4
		paw.rotation.z=.85 if pointing==0 else -.85
		paw.scale.y=2.3
		head.rotation.x=.38
		head.rotation.z=.25 if pointing==0 else -.25
		leaves[pointing].material_override.emission_enabled=true
		leaves[pointing].material_override.emission=Color.YELLOW_GREEN
		leaves[1-pointing].material_override.emission_enabled=false
		story.say("dragon_hint" if mistakes>=2 else "dragon_less")

func finish() -> void:
	story.checkpoint(true)
	game.home()
