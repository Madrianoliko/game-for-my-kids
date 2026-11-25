extends Node3D

const Pony := preload("res://scripts/pony.gd")
const COATS := [Color.PERU, Color.IVORY, Color.TAN]
const MAP := "Mapa Dymiącej Góry"
const APPLES := "Jabłka herszta"
const PONY_GAP := 1.8
const SPEED := 2.65
const BRIDGE_START := -3.75
const HERO_START := -5.15
var story
var game
var ponies:Array[Node3D]=[]
var hero_z:float

func setup(owner_story) -> void:
	story=owner_story
	game=story.host
	if story.id()=="troll_cave": build_cave()
	elif story.part==2: build_crossing()
	else: meet_chief()

func build_cave() -> void:
	game.hud.text="Skrzynia trolli"
	game.box(self,Vector3(0,-.18,0),Vector3(13,.35,9),Color("#71696b"))
	for i in 9:
		var a:=PI*i/8
		game.orb(self,Vector3(4.6*cos(a),2.75*sin(a),-2),1.4,Color("#625f68")).scale.z=1.5
	var oak:=Color("#ac7543")
	game.box(self,Vector3(.3,.33,0),Vector3(2.8,.55,1.26),oak)
	for x in [-1.02,1.62]:
		game.box(self,Vector3(x,.65,0),Vector3(.12,.6,1.3),oak)
	game.box(self,Vector3(.3,.58,.61),Vector3(2.8,.45,.1),oak)
	var lid:=Node3D.new()
	add_child(lid)
	lid.position=Vector3(.3,.92,-.64)
	game.box(lid,Vector3(0,.07,.64),Vector3(2.86,.18,1.36),oak.darkened(.22))
	for x in [-.95,.95]:
		game.box(lid,Vector3(x,.17,.64),Vector3(.12,.04,1.33),Color.GOLDENROD)
	game.leo.position=global_position+Vector3(-1.9,0,.4)
	game.camera.look_at_from_position(global_position+Vector3(.2,3.5,5.8),global_position+Vector3(0,.35,.8),Vector3.UP)
	if story.part==0:
		story.button("Ręka",open_chest)
		story.say("cave_open")
	else:
		lid.rotation.x=-1.85
		for i in 3: story.make_apple(Vector3(-.68+i*.39,.95,.29))
		var paper:=Color("#ffdea0")
		game.box(self,Vector3(.95,.92,0),Vector3(1,.09,.95),paper)
		for x in [.45,1.45]:
			var roll:=CylinderMesh.new()
			roll.height=1.06
			roll.top_radius=.13
			roll.bottom_radius=.13
			game.mesh(self,roll,Vector3(x,1.04,0),paper).rotation.x=PI/2
		var peak:=PrismMesh.new()
		peak.size=Vector3(.56,.31,.12)
		game.mesh(self,peak,Vector3(.96,1.14,0),Color("#815941"))
		for i in 3:
			game.orb(self,Vector3(.95+.07*i,1.37+.14*i,0),.085+.018*i,Color("#696370"))
		story.button("Dalej",story.advance)
		story.say("cave_find")

func open_chest() -> void:
	if story.id()!="troll_cave" or story.part!=0: return
	story.items.append(APPLES)
	story.items.append(MAP)
	story.go_to("troll_cave",1)

func meet_chief() -> void:
	game.hud.text="Jabłka herszta"
	story.actor("chief",Vector3(1.05,0,-.4))
	for i in 3: Pony.make(game,self,Vector3(-2.6+i*1.7,0,-2.1),COATS[i])
	for row in 4:
		var rim:=TorusMesh.new()
		rim.inner_radius=.52+row*.045
		rim.outer_radius=rim.inner_radius+.10
		game.mesh(self,rim,Vector3(1,.14+row*.13,.63),Color("#9b693d"))
	for i in 3:
		story.make_apple(Vector3((-.92 if story.part==0 else .56)+i*.4,.62,.68))
	if story.part==0:
		story.button("Ręka",give_apples)
		story.say("chief_give")
	else:
		story.button("Dalej",func(): story.go_to("chief_happy",2))
		story.say("chief_happy")

func give_apples() -> void:
	if story.id()!="chief_happy" or story.part!=0: return
	var slot:int=story.items.find(APPLES)
	if slot<0: return
	story.items.remove_at(slot)
	story.go_to("chief_happy",1)

func build_crossing() -> void:
	game.hud.text="Kucyki wracają do stajni"
	story.dock.hide()
	game.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	game.camera.size=18.0
	var center:Vector3=game.point(-1.5)
	game.camera.look_at_from_position(center+Vector3(0,13,9),center,Vector3.UP)
	hero_z=HERO_START if story.marks==0 else BRIDGE_START+story.marks*PONY_GAP
	for coat in COATS: ponies.append(Pony.make(game,self,Vector3.ZERO,coat))
	game.marker.global_position=game.point(1.8+3*PONY_GAP)+Vector3.UP*.22
	game.marker.show()
	position_party()
	story.say("ponies_bridge")

func position_party() -> void:
	game.leo.global_position=trail_point(hero_z)
	game.leo.rotation.y=PI
	for i in ponies.size():
		var z:=hero_z-(i+1)*PONY_GAP
		ponies[i].global_position=trail_point(z)
		ponies[i].rotation.y=atan2(game.route(z+.1)-game.route(z),.1)

func trail_point(z:float) -> Vector3:
	return game.point(z)+Vector3.UP*(.34 if absf(z+2)<1.9 else .04)

func tick(dt:float) -> void:
	var input:Vector2=game.stick.vector
	if input.is_zero_approx(): input=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var stride:=maxf(0,input.y)
	hero_z+=stride*SPEED*dt
	position_party()
	for i in ponies.size(): ponies[i].position.y+=.065*absf(sin(hero_z*3.2-i))*stride
	for i in game.limbs.size(): game.limbs[i].rotation.x=.38*sin(hero_z*3.2+i*PI)*stride
	if story.marks<3 and hero_z-(story.marks+1)*PONY_GAP>=BRIDGE_START:
		story.marks+=1
		story.checkpoint()
		if game.sound: game.play_clip(game.chime,"count_%d"%story.marks)
	if hero_z>=1.8+3*PONY_GAP:
		for limb in game.limbs: limb.rotation.x=0
		story.advance()
