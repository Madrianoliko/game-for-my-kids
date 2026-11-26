extends Node3D

const SHRUB := Vector3(-2,0,-1.4)
const LANTERN := Vector3(2.6,0,-1.0)
const REACH := 1.85
const LEAVES := [Vector3(-2.1,.28,-.9),Vector3(2.1,.28,-.9)]
var story
var game
var dragon:Node3D
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
		game.mesh(dragon,wing,Vector3(side*.47,.78,-.13),Color("#ba685c")).rotation.z=-side*.55
		game.orb(dragon,Vector3(side*.3,.14,.2),.18,skin)
	paw=game.orb(dragon,Vector3(.29,.44,.32),.15,skin)
	spark=game.orb(head,Vector3(0,-.04,.61),.14,Color.ORANGE,true)
	spark.scale=Vector3.ONE*.6

func build_orchard() -> void:
	game.hud.text="Ślady w sadzie"
	game.leo.global_position=to_global(Vector3(-.2,0,1.8) if story.part==0 else SHRUB+Vector3.RIGHT*.7)
	for i in 5:
		var at:=Vector3(-.3-i*.32,.05,1.25-i*.48)
		game.orb(self,at,.13,Color("#564432")).scale=Vector3(.72,.18,1)
		game.orb(self,at+Vector3(.28,0,-.17),.095,Color("#564432")).scale.y=.2
	for x in [.25,.75]:
		game.orb(self,Vector3(x,.16,1.35),.13,Color("#63523d")).scale.y=1.5
		for y in [.08,.34]: game.orb(self,Vector3(x,y,1.35),.16,Color("#663e30")).scale.y=.4
	game.box(self,LANTERN+Vector3.UP*.55,Vector3(.18,1.1,.18),Color.SADDLE_BROWN)
	flame=game.orb(self,LANTERN+Vector3.UP*1.25,.26,Color.GOLD,true)
	flame.visible=story.part==2
	game.orb(self,LANTERN+Vector3.UP*1.05,.33,Color("#67563d")).scale.y=.45
	match story.part:
		0: story.say("dragon_tracks")
		1:
			story.say("dragon_lost")
			story.button("Płomień",sneeze)
		2:
			story.say("dragon_warm")
			story.button("Dalej",story.advance)

	if story.part==1:
		story.button("Płomień",sneeze)
		story.say("dragon_lost")
	elif story.part==2:
		game.leo.global_position=to_global(LANTERN+Vector3.RIGHT)
		dragon.position=LANTERN+Vector3.LEFT
		flame.show()
		story.button("Dalej",story.advance)
		story.say("dragon_warm")
	else: story.say("dragon_tracks")

func walk(dt:float) -> void:
	if story.part==2: return
	var motion:Vector2=game.stick.vector
	if motion.is_zero_approx(): motion=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var pos:=to_local(game.leo.global_position)+Vector3(motion.x,0,motion.y)*dt*3.4
	pos.x=clampf(pos.x,-3.65,3.65)
	pos.z=clampf(pos.z,-2.5,2.5)
	game.leo.global_position=to_global(pos)
	if motion.length()>.1: game.leo.rotation.y=atan2(-motion.x,-motion.y)
	if story.part==0:
		if pos.distance_to(SHRUB)<1.2: story.go_to("dragon_orchard",1)
	elif dragon.position.distance_to(pos)>.75:
		dragon.position=dragon.position.move_toward(pos,dt*3.6)
		dragon.look_at(to_global(pos),Vector3.UP,true)
	if story.part==1 and story.voice=="route_dragon_lost" and story.age>6: story.say("dragon_near")
	if story.part==1 and story.voice=="route_dragon_near" and dragon.position.distance_to(LANTERN)<=REACH: story.say("dragon_fire")

func sneeze() -> void:
	if story.part!=1 or game.paused: return
	var puff=game.orb(self,dragon.position+Vector3.UP,.24,Color.ORANGE_RED,true)
	var toward:=dragon.position.direction_to(LANTERN)
	var flight=puff.create_tween()
	flight.tween_property(puff,"position",puff.position+toward*REACH,.3)
	flight.tween_callback(puff.queue_free)
	if dragon.position.distance_to(LANTERN)<=REACH:
		flame.show()
		story.part=2
		story.checkpoint()
		flight.tween_callback(story.render)
	else: story.say("dragon_near")

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
		story.button("Dalej",finish)
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
