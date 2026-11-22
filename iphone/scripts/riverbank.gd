extends Node3D

signal progress(part: int, marks: int)
signal done
signal prompt(clip: String, words: String)
signal sound(clip: String)

const Props := preload("res://scripts/river_props.gd")
const STAGES := {
	"nailbox":["nails"], "dairy":["hay","milk_cow"],
	"snack":["serve"], "feast":["peek","supper"],
	"recipe":["scoop"], "eggs":["crack"], "milk":["pour","stir","flip"],
	"bridge":["fit","pegs"],
	"rope":["thread"], "crank":["turn"], "flour":["sack","cart"],
	"duck":["gaps","reeds","catch"],
	"tracks":["trail"],
	"blanket":["stones","hops"],
	"fork":["float","willow"]
}
const LINES := {
	"nails":"Do naprawy potrzebujemy ośmiu gwoździ. Przeciągaj je z pudełka do plecaka, po jednym.",
	"hay":"Krowy czekają na śniadanie. Przenieś siano do obu żłobów.",
	"milk_cow":"Podstawiliśmy wiaderko. Delikatnie pociągnij palcem w dół za strzyk trzy razy, żeby nalać mleka.",
	"peek":"Stuk, stuk! Słyszysz? Ktoś jest pod mostem. Dotknij deski przy złotym kółku i zajrzyj z Bilbem.",
	"supper":"To Tkacz! Je urodzinowy placek naszą łyżką. Stuk, stuk! Pestka aż się śmieje. To koniec naszej wyprawy.",
	"scoop":"Mamy już składniki z wioski. Wsyp do miski trzy porcje mąki. Dotknij każdego woreczka.",
	"crack":"Teraz dwa jajka. Stuknij palcem każde jajko, żeby je rozbić.",
	"pour":"Jeszcze jedna porcja mleka. Przesuń dzbanek nad miskę i puść, żeby wlać mleko.",
	"stir":"Pomieszaj ciasto! Rysuj palcem kółka w misce, aż żółtka znikną.",
	"flip":"Biszkopt się upiekł! Lekko potrząśnij telefonem albo dotknij foremki. Połóż ostatnią warstwę na torcie Tygryska!",
	"fit":"Tobo przyniósł trzy deski! Przesuń każdą na pasujący ciemny kształt. Spójrz, która jest najdłuższa.",
	"wobble":"Ojej, jedna deska się chwieje! Dotknij tej, która się kołysze. Widzisz ślad kciuka Toba?",
	"pegs":"Deski się kołyszą! Masz młotek i gwoździe z chatki. Przybij każdą deskę, żeby przestała się ruszać.",
	"bench":"Ta deseczka jest za krótka na most. Przesuń ją na dwie nóżki. To będzie ławka dla Pestki!",
	"launch":"Pestko, puść kaczkę! Dotknij jej i zobacz, kto pierwszy wypróbuje most.",
	"thread":"Bóbr przegryzł gałąź, a Tobo trzyma belkę! Przeciągnij koniec sznurka przez oba złote koła.",
	"turn":"Chwyć złotą rączkę i kręć w kółko. Gdy pływak dopłynie do rybki, puść korbę!",
	"sack":"Młyn znów miele! Pestka woła z okna: Tato, łap mąkę! Dotknij woreczka.",
	"cart":"Ale biały ogon! Baran zaprzęga się do wózka. Dotknij desek i ruszamy do mostu!",
	"gaps":"Pestka macha z młyna! Ile desek zniknęło? Dotknij każdej dziury w moście.",
	"reeds":"Szurrr… plusk! Rozsuń trzciny palcem. Co tam błyszczy?",
	"catch":"Drewniana kaczka! Złap ją. Jeśli odpłynie, poczeka przy kamieniu.",
	"trail":"Ojej, moja kaczka… Czyj to głos? Idź palcem po wielkich śladach aż do wierzb.",
	"stones":"Przenieś kamienie do pustych kręgów. Tobo przejdzie tędy z deskami do mostu.",
	"hops":"Teraz przeprowadź Bilba. Dotykaj po kolei kamieni, żeby po nich skakał.",
	"rescue":"Już blisko! Podnieś kocyk z ostatniej suchej wysepki.",
	"float":"Poprowadź kaczkę po wodzie do Toba. Przesuwaj ją palcem albo lekko przechyl telefon.",
	"willow":"Jedno koryto wyschło! Znajdź wierzbę, która przygniotła zastawkę młyna."
}
const STONE_FROM := [Vector3(-4.65,.26,-1.1),Vector3(-4.45,.26,.23),Vector3(-4.65,.26,1.45)]
const STONE_TO := [Vector3(-2.05,.22,.8),Vector3(-.12,.22,-.28),Vector3(1.9,.22,.56)]
const FOOT := [Vector3(-3.2,.21,.77),Vector3(-1.35,.21,-.30),Vector3(.43,.21,.72),Vector3(2.25,.21,-.42)]
const CHANNEL := [Vector3(-4,.24,.45),Vector3(-1.35,.24,-.89),Vector3(1.45,.24,-.90),Vector3(3.47,.24,.12)]
const ISLAND := Vector3(3.96,.36,.48)
const WATER := Color("#4f9b9d")
const GRASS := Color("#96ae65")
const STONE := Color("#9aa895")
const WOOD := Color("#ab794a")
const LIGHT := Color("#ffe6a1")

var host
const Mechanism := preload("res://scripts/mill_mechanism.gd")
const Bridge := preload("res://scripts/birthday_bridge.gd")
const Kitchen := preload("res://scripts/pancake_kitchen.gd")
const Finale := preload("res://scripts/birthday_finale.gd")
var finale:Finale
const Farm := preload("res://scripts/farm_tasks.gd")
var farm:Farm
var kitchen:Kitchen
var bridge:Bridge
var mechanism:Mechanism
var decor := Node3D.new()
var actors := Node3D.new()
var ring: MeshInstance3D
var duck: Node3D
var porter: Node3D
var bilbo: Node3D
var blanket: Node3D
var reeds: Array[Node3D] = []
var stones: Array[Node3D] = []
var markers: Array[Node3D] = []
var ripples: Array[Node3D] = []
var id := ""
var part := 0
var marks := 0
var clock := 0.0
var finger := -1
var start := Vector2.ZERO
var drag_index := -1
var jump := -1.0
var jump_from := Vector3.ZERO
var jump_to := Vector3.ZERO
var splash := 0.0
var float_next := 1
var neutral := Vector3.ZERO
var tilt_ready := false
var closing := false
var old_projection := Camera3D.PROJECTION_PERSPECTIVE
var old_aspect := Camera3D.KEEP_HEIGHT
var old_size := 1.0

func setup(game) -> void:
	host=game
	position=Vector3(180,0,0)
	add_child(decor)
	add_child(actors)
	hide()

func begin(step_id:String,saved_part:int,saved_marks:int) -> void:
	id=step_id
	part=clampi(saved_part,0,STAGES[id].size()-1)
	marks=maxi(0,saved_marks)
	old_projection=host.camera.projection
	old_aspect=host.camera.keep_aspect
	old_size=host.camera.size
	host.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	host.camera.keep_aspect=Camera3D.KEEP_WIDTH
	show()
	build()

func leave() -> void:
	if not visible: return
	hide()
	finger=-1
	host.camera.projection=old_projection
	host.camera.keep_aspect=old_aspect
	host.camera.size=old_size

func mode() -> String: return STAGES[id][part]

func place_camera() -> void:
	var viewport_size:Vector2=get_viewport().get_visible_rect().size
	var camera:Camera3D=host.camera
	camera.size=maxf(13.6,7.5*viewport_size.aspect())
	if id=="feast" and mode()=="supper":
		camera.size=maxf(8.8,5.55*viewport_size.aspect())
		camera.look_at_from_position(global_position+Vector3(.4,2.55,8),global_position+Vector3(0,1.22,.62),Vector3.UP)
	else:
		camera.look_at_from_position(global_position+Vector3(0,8.6,6),global_position,Vector3.UP)
	camera.position-=camera.global_basis.y*.98

func rock(parent:Node3D, at:Vector3, radius:float,color:Color,scale_to:Vector3) -> MeshInstance3D:
	var object:MeshInstance3D=host.orb(parent,at,radius,color)
	object.scale=scale_to
	return object

func character(kind:String,at:Vector3,amount:float) -> Node3D:
	var actor:=Props.new()
	actors.add_child(actor)
	actor.setup(host)
	actor.build(kind)
	actor.position=at
	actor.scale=Vector3.ONE*amount
	return actor

func torus(at:Vector3,r:float,col:Color) -> MeshInstance3D:
	var mesh:=TorusMesh.new()
	mesh.inner_radius=r-.045
	mesh.outer_radius=r+.045
	var obj:MeshInstance3D=host.mesh(actors,mesh,at,col,true)
	return obj

func build() -> void:
	for parent in [actors,decor]:
		for child in parent.get_children():
			parent.remove_child(child)
			child.queue_free()
	reeds.clear()
	stones.clear()
	markers.clear()
	ripples.clear()
	duck=null
	bilbo=null
	porter=null
	blanket=null
	finale=null
	kitchen=null
	farm=null
	bridge=null
	mechanism=null
	ring=null
	finger=-1
	drag_index=-1
	jump=-1
	clock=0
	splash=0
	closing=false
	place_camera()
	if id in ["nailbox","dairy"]:
		farm=Farm.new()
		actors.add_child(farm)
		farm.setup(self)
		prompt.emit("bank_"+mode(),LINES[mode()])
		return
	if id in ["snack","feast"]:
		finale=Finale.new()
		actors.add_child(finale)
		if id=="feast": host.box(decor,Vector3(0,-.33,0),Vector3(32,.62,22),WATER)
		finale.setup(self)
		if id=="snack":
			var lines:Array=Finale.SERVE_LINES if marks==0 else Finale.PASS_LINES
			var prefix:="serve_" if marks==0 else "pass_"
			prompt.emit(prefix+str(finale.snack),lines[finale.snack])
		else: prompt.emit("bank_"+mode(),LINES[mode()])
		return
	if id in ["recipe","eggs","milk"]:
		kitchen=Kitchen.new()
		actors.add_child(kitchen)
		kitchen.setup(self)
		prompt.emit("bank_"+mode(),LINES[mode()])
		return
	host.box(decor,Vector3(0,-.35,0),Vector3(32,.62,22),WATER)
	for side in [-1,1]:
		rock(decor,Vector3(side*8,-.13,0),3.2,GRASS,Vector3(1.15,.25,2.8))
	for i in 20:
		var x:=fmod(i*2.91,10.3)-5.15
		var z:=fmod(i*1.63,6.8)-3.4
		ripples.append(host.box(decor,Vector3(x,-.015,z),Vector3(.32+i%4*.11,.012,.031),Color("#a1d5ca")))
	match mode():
		"fit","wobble","pegs","bench","launch":
			bridge=Bridge.new()
			actors.add_child(bridge)
			bridge.setup(self)
		"thread","turn","sack","cart":
			mechanism=Mechanism.new()
			actors.add_child(mechanism)
			mechanism.setup(self)
		"gaps":
			for z in [-.57,.57]:
				host.box(decor,Vector3(0,.18,z),Vector3(11,.22,.16),WOOD)
			for x in [-5.1,-4.2,4.2,5.1]:
				host.box(decor,Vector3(x,.32,0),Vector3(.84,.18,1.78),WOOD)
			for i in 5:
				var marker:=torus(Vector3((i-2)*1.45,.24,0),.40,LIGHT)
				markers.append(marker)
				if marks & (1<<i): mark_gap(i,false)
			host.box(decor,Vector3(3.7,.83,-2.4),Vector3(2,1.55,1.1),Color("#ebce96"))
			host.box(decor,Vector3(3.7,1.68,-2.4),Vector3(2.36,.23,1.45),WOOD)
			host.box(decor,Vector3(3.7,1.03,-1.83),Vector3(.85,.74,.06),Color("#57493c"))
			character("beaver",Vector3(3.7,.67,-1.8),.42)
		"reeds","catch":
			duck=character("duck",Vector3(-.72,.05,0),.82)
			rock(decor,Vector3(3.5,.01,.18),.72,STONE,Vector3(1,.7,.8))
			if mode()=="reeds":
				for side in [-1,1]:
					var clump:=Node3D.new()
					actors.add_child(clump)
					clump.position=Vector3(-.72+side*.31,0,.42)
					reeds.append(clump)
					for i in 7:
						var stalk:MeshInstance3D=host.box(clump,Vector3((i-3)*.13,.63,0),Vector3(.08,1.5,.08),Color("#74914d"))
						stalk.rotation.z=(i-3)*.09
						rock(clump,Vector3((i-3)*.19,1.35,.04),.10,WOOD,Vector3(.72,2.6,.7))
		"trail":
			rock(decor,Vector3(0,-.12,0),4.45,Color("#a69168"),Vector3(1.15,.09,.49))
			for i in FOOT.size():
				var footprint:=Node3D.new()
				actors.add_child(footprint)
				footprint.position=FOOT[i]
				footprint.rotation.y=.45 if i%2 else .9
				rock(footprint,Vector3.ZERO,.28,WOOD.darkened(.32),Vector3(1,.21,1.42))
				for j in 3: rock(footprint,Vector3((j-1)*.20,.01,-.32),.12,WOOD.darkened(.32),Vector3(1,.34,1))
				markers.append(footprint)
			ring=torus(FOOT[clampi(marks,0,3)]+Vector3.UP*.03,.49,LIGHT)
			for i in 3:
				host.box(decor,Vector3(3.8+i*.38,1,-1.1),Vector3(.13,2.2,.2),WOOD).rotation.z=.16*i
				rock(decor,Vector3(3.6+i*.39,2,-1.1),.75,GRASS,Vector3(.62,1.3,1))
		"stones","hops","rescue":
			rock(decor,ISLAND-Vector3.UP*.52,1.17,GRASS,Vector3(1.13,.48,.87))
			for i in 3:
				var destination:=((marks>>(2*i)) & 3)-1
				var at:Vector3=STONE_TO[i] if mode()!="stones" else (STONE_TO[destination] if destination>=0 else STONE_FROM[i])
				stones.append(rock(actors,at,.52,STONE,Vector3(1.25,.52,1)))
				if mode()=="stones" and not occupied(i):
					markers.append(torus(STONE_TO[i],.58,LIGHT))
				else: markers.append(null)
			porter=character("troll",Vector3(-4.6,.26,-.15),.65)
			for i in 3:
				host.box(porter,Vector3(-.6,1.02+i*.13,0),Vector3(.48,.12,2.25),WOOD)
			host.box(porter,Vector3(-.6,1.42,0),Vector3(.50,.06,.13),Color("#dbc298"))
			if mode()!="stones":
				bilbo=preload("res://art/leo.glb").instantiate()
				actors.add_child(bilbo)
				bilbo.scale=Vector3.ONE*.75
				bilbo.position=ISLAND if mode()=="rescue" else hop_origin()
				porter.position=bilbo.position+Vector3(-.46,0,-.40)
				if mode()=="hops": ring=torus(next_hop(),.55,LIGHT)
		"float":
			float_next=clampi(marks+1,1,3)
			duck=character("duck",CHANNEL[float_next-1],.77)
			duck.rotation.y=0
			for x in [-.35,.6]: rock(decor,Vector3(x,.01,.65),.60,STONE,Vector3(1,.8,1))
			character("troll",CHANNEL[3]+Vector3(.54,-.22,-.1),.83)
			ring=torus(CHANNEL[float_next]-Vector3.UP*.13,.58,LIGHT)
			neutral=Input.get_gravity()
			tilt_ready=neutral.length()>2
		"willow":
			host.box(decor,Vector3(0,.035,-.52),Vector3(14,.08,2.15),Color("#b5a67a"))
			host.box(decor,Vector3(-.2,.14,-.36),Vector3(1.25,.23,.52),WOOD)
			var tree:MeshInstance3D=host.box(decor,Vector3(-.2,.42,-.36),Vector3(3.4,.37,.44),Color("#805533"))
			tree.rotation.y=.62
			rock(decor,Vector3(-1.75,.44,.43),.63,GRASS,Vector3(1.15,1,.83))
			character("troll",Vector3(3,.0,.8),.68)
			ring=torus(Vector3(-.2,.64,-.36),.6,LIGHT)
	prompt.emit("bank_"+mode(),LINES[mode()])

func hop_origin() -> Vector3:
	return Vector3(-4.3,.45,1) if marks==0 else Vector3(STONE_TO[clampi(marks-1,0,2)])+Vector3.UP*.27

func next_hop() -> Vector3:
	return Vector3(STONE_TO[marks])+Vector3.UP*.28 if marks<3 else ISLAND+Vector3.UP*.18

func screen(at:Vector3) -> Vector2:
	return host.camera.unproject_position(to_global(at))

func water(at:Vector2) -> Vector3:
	var camera:Camera3D=host.camera
	var hit=Plane(Vector3.UP,global_position.y+.24).intersects_ray(camera.project_ray_origin(at),camera.project_ray_normal(at))
	return to_local(hit) if hit!=null else Vector3.ZERO

func near(at:Vector2,target:Vector3) -> bool:
	return at.distance_to(screen(target))<=clampf(get_viewport().get_visible_rect().size.x*.042,36,53)

func mark_gap(i:int,play:bool) -> void:
	markers[i].hide()
	var number:=Label3D.new()
	number.text="✓"
	number.font_size=84
	number.pixel_size=.009
	number.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	actors.add_child(number)
	number.position=markers[i].position+Vector3.UP*.23
	if play:
		var n:=0
		for bit in 5:
			if marks & (1<<bit): n+=1
		sound.emit("count_%d"%n if n<5 else "story/bank_five")

func save_marks(value:int) -> void:
	marks=value
	progress.emit(part,marks)

func next_part() -> void:
	finger=-1
	if part+1>=STAGES[id].size():
		closing=true
		done.emit()
		return
	part+=1
	marks=0
	progress.emit(part,marks)
	build()

func _process(dt:float) -> void:
	if not visible or not host or closing: return
	if host.paused:
		if finger!=-1: cancel()
		return
	clock+=dt
	place_camera()
	for i in ripples.size(): ripples[i].position.x=fmod(i*2.91+clock*.32,10.3)-5.15
	if ring: ring.scale=Vector3.ONE*(1+.08*sin(clock*4))
	if finale:
		finale.animate(dt)
		return
	if kitchen:
		kitchen.animate(dt)
		return
	if bridge:
		bridge.animate(dt)
		return
	if mode()=="sack": mechanism.bag.position=mechanism.bag_at(clock)
	if mode()=="catch":
		duck.position=Vector3(lerpf(-.72,2.82,minf(clock/4.8,1)),.07+.045*sin(clock*3),.20*sin(minf(clock,4.8)))
	if mode()=="hops" and jump>=0:
		jump=minf(1,jump+dt*2)
		bilbo.position=jump_from.lerp(jump_to,jump)+Vector3.UP*sin(jump*PI)*.74
		porter.position=bilbo.position+Vector3(-.46,0,-.40)
		if jump==1:
			jump=-1
			if marks==3: next_part()
			else:
				save_marks(marks+1)
				ring.position=next_hop()
	if mode()=="float" and finger==-1 and OS.get_name()=="iOS":
		var gravity:=Input.get_gravity()
		if not tilt_ready and gravity.length()>2:
			neutral=gravity
			tilt_ready=true
		if tilt_ready:
			var delta:=Vector2(gravity.x-neutral.x,neutral.y-gravity.y)
			if delta.length()>.8: steer(duck.position+Vector3(delta.x,0,delta.y).limit_length(3)*dt)

func steer(destination:Vector3) -> void:
	var target:=Vector3(clampf(destination.x,-4.6,4.1),.24,clampf(destination.z,-1.9,1.7))
	# Sweep the segment so a fast drag cannot pass through a rock or skip the bend.
	var from:=duck.position
	for j in range(1,ceili(from.distance_to(target)/.12)+1):
		var pos:=from.move_toward(target,j*.12)
		if Vector2(pos.x+.35,pos.z-.65).length()<.63 or Vector2(pos.x-.6,pos.z-.65).length()<.63:
			return
		duck.position=pos
		if pos.distance_to(CHANNEL[float_next])<.55:
			if float_next==3:
				next_part()
				return
			save_marks(float_next)
			float_next+=1
			ring.position=CHANNEL[float_next]-Vector3.UP*.13

func pressed(at:Vector2,which:int) -> void:
	if finger!=-1 or jump>=0: return
	finger=which
	start=at
	drag_index=-1
	if finale and not finale.press(at): finger=-1
	if farm and not farm.press(at): finger=-1
	if kitchen and not kitchen.press(at): finger=-1
	if bridge and not bridge.press(at): finger=-1
	if mechanism and not mechanism.press(at): finger=-1
	if mode()=="stones":
		for i in stones.size():
			if ((marks>>(2*i)) & 3)==0 and near(at,stones[i].position):
				drag_index=i
				break
	elif mode()=="float" and not near(at,duck.position):
		finger=-1

func follow_track(at:Vector2) -> void:
	if near(at,FOOT[marks]):
		if marks==3: next_part()
		else:
			save_marks(marks+1)
			ring.position=FOOT[marks]+Vector3.UP*.03

func dragged(at:Vector2,which:int) -> void:
	if which!=finger: return
	if finale:
		finale.drag(at)
		return
	if farm:
		farm.drag(at)
		return
	if kitchen:
		kitchen.drag(at)
		return
	if bridge:
		bridge.drag(at)
		return
	if mechanism:
		mechanism.drag(at)
		return
	match mode():
		"trail": follow_track(at)
		"reeds":
			var distance:=absf(at.x-start.x)
			if near(start,Vector3(-.72,.65,.42)):
				for i in 2: reeds[i].rotation.z=(1 if i==0 else -1)*minf(distance/100,.94)
		"stones":
			if drag_index>=0: stones[drag_index].position=water(at)+Vector3.UP*.1
		"float": steer(water(at))

func released(at:Vector2,which:int) -> void:
	if finger!=which: return
	finger=-1
	if finale:
		finale.release(at)
		return
	if farm:
		farm.release(at)
		return
	if kitchen:
		kitchen.release(at)
		return
	if bridge:
		bridge.release(at)
		return
	if mechanism:
		mechanism.release(at)
		return
	match mode():
		"gaps":
			for i in 5:
				if (marks & (1<<i))==0 and near(at,markers[i].position) and near(start,markers[i].position):
					save_marks(marks | (1<<i))
					mark_gap(i,true)
					if marks==31: next_part()
					break
		"reeds":
			if near(start,Vector3(-.72,.65,.42)) and absf(at.x-start.x)>64: next_part()
			else:
				for reed in reeds: reed.rotation.z=0
		"catch":
			if near(at,duck.position+Vector3.UP*.32): next_part()
		"trail":
			follow_track(at)
		"stones":
			if drag_index>=0:
				var i:=drag_index
				drag_index=-1
				stones[i].position=STONE_FROM[i]
				for target in 3:
					if occupied(target) or not near(at,STONE_TO[target]): continue
					stones[i].position=STONE_TO[target]
					markers[target].hide()
					sound.emit("wood_tap")
					save_marks(marks | ((target+1)<<(2*i)))
					if occupied(0) and occupied(1) and occupied(2): next_part()
					break
		"hops":
			if near(at,next_hop()):
				jump_from=bilbo.position
				jump_to=next_hop()
				bilbo.rotation.y=atan2(jump_to.x-jump_from.x,jump_to.z-jump_from.z)
				jump=0
		"rescue":
			if near(at,blanket.position+Vector3.UP*.24): next_part()
		"float": steer(water(at))
		"willow":
			if near(at,ring.position): next_part()

func occupied(target:int) -> bool:
	for i in 3:
		if ((marks>>(2*i)) & 3)==target+1: return true
	return false

func cancel() -> void:
	if farm: farm.cancel()
	if finale: finale.cancel()
	if kitchen: kitchen.cancel()
	if bridge: bridge.cancel()
	if mechanism and mode()=="thread": mechanism.reset_rope()
	if drag_index>=0 and mode()=="stones": stones[drag_index].position=STONE_FROM[drag_index]
	drag_index=-1
	finger=-1

func _input(event:InputEvent) -> void:
	if not visible or closing or host.paused: return
	var point:Vector2
	if event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouse:
		point=event.position
	else: return
	if not is_inside_tree(): return
	if host.bystra.dock.get_global_rect().has_point(point) or host.pause_button.get_global_rect().has_point(point) or (host.bystra.outside.visible and host.bystra.outside.get_global_rect().has_point(point)):
		if finger!=-1: cancel()
		return
	if event is InputEventScreenTouch:
		if event.canceled:
			if finger==event.index: cancel()
		elif event.pressed: pressed(point,event.index)
		else: released(point,event.index)
	elif event is InputEventScreenDrag: dragged(point,event.index)
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.device!=InputEvent.DEVICE_ID_EMULATION:
		if event.pressed: pressed(point,-2)
		else: released(point,-2)
	elif event is InputEventMouseMotion: dragged(point,-2)
	else: return
	get_viewport().set_input_as_handled()
