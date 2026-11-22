extends Node

const Data := preload("res://scripts/river_story_data.gd")
const Props := preload("res://scripts/river_props.gd")
const Icons := preload("res://scripts/river_icons.gd")
const Village := preload("res://scripts/village_stops.gd")
const Repair := preload("res://scripts/bridge_repair.gd")
const FILE := "user://bystra-v1.cfg"
var host
var props:=Props.new()
const Square := preload("res://scripts/village_square.gd")
var square:=Square.new()
var village_pos:=Square.ENTRY
var room_saves:Dictionary={}
var outside:=Button.new()
var village_moving:=false
var scene:=Node3D.new()
var bank:=preload("res://scripts/riverbank.gd").new()
var field:=preload("res://scripts/field_encounter.gd").new()
var dock:=PanelContainer.new()
var options:=HBoxContainer.new()
var caption:=Label.new()
var actions:=HBoxContainer.new()
var replay:Button
var hand:Button
var sword:Button
var shield:Button
var bow:Button
var equipped_bow:=Node3D.new()
var light_filter:=CameraAttributesPractical.new()
var arc:=MeshInstance3D.new()
var held_shield:=Node3D.new()
var actors:Array[Node3D]=[]
var pickups:Array[Node3D]=[]
var visitor:Node3D
var foe:Node3D
var foe_shield:Node3D
var foe_sword:Node3D
var index:=0
var part:=0
var marks:=0
var items:=PackedStringArray()
var active:=false
var saved:=false
var busy:=false
var anim:Tween
var age:=0.0
var cooldown:=0.0
var attack_fired:=false
var blocking:=false
var guarding:=true
var fingers:Dictionary={}
var declined:=false
var traveling:=false
var voice:=""
var origin:=Vector3.ZERO

func id() -> String: return Data.ROUTE[index]
func roaming() -> bool: return (id() in ["pack","mill","coop","village","delivery"] and not bank.visible and not field.visible) or id() in ["dummy","guard"] or (id()=="dairy" and "Mleko" in items) or (id()=="door" and declined)

func setup(game) -> void:
	host=game
	add_child(square)
	square.setup(game)
	add_child(scene)
	add_child(props)
	props.setup(host)
	add_child(bank)
	bank.setup(host)
	bank.progress.connect(func(n,m): part=n+1 if id() in ["bridge","pack"] else n; marks=m; checkpoint())
	bank.done.connect(bank_done)
	bank.prompt.connect(prompt)
	bank.sound.connect(effect)
	host.ui.add_child(field)
	field.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	field.offset_left=-350
	field.offset_right=350
	field.offset_top=64
	field.anchor_bottom=1
	field.offset_bottom=-162
	field.instruction.connect(prompt)
	field.progressed.connect(func(n):
		part=n
		if id()=="mill": actors[0].hide()
		else: actors[0].rotation.z=PI*.45
		checkpoint())
	field.completed.connect(func():
		if id()=="mill":
			part=2
			checkpoint()
			render()
		else: advance())
	field.performed.connect(func(_action): effect("swoosh"))
	host.ui.add_child(dock)
	dock.add_theme_stylebox_override("panel",host.plate(Color("#203146f5")))
	dock.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	dock.offset_left=-350
	dock.offset_right=350
	dock.offset_top=-161
	dock.offset_bottom=-12
	var column:=VBoxContainer.new()
	dock.add_child(column)
	column.add_child(caption)
	caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	caption.custom_minimum_size=Vector2(650,48)
	caption.add_theme_font_size_override("font_size",21)
	column.add_child(options)
	options.alignment=BoxContainer.ALIGNMENT_CENTER
	replay=host.button(host.ui,"Posłuchaj",func(): prompt(voice,caption.text))
	Icons.apply(replay,"Posłuchaj")
	replay.custom_minimum_size=Vector2(76,72)
	host.ui.add_child(outside)
	Icons.apply(outside,"Wyjdź na plac")
	outside.accessibility_name="Wyjdź na plac"
	outside.tooltip_text="Wyjdź na plac"
	outside.custom_minimum_size=Vector2(76,72)
	outside.pressed.connect(leave_room)
	host.ui.add_child(actions)
	hand=control_button("Ręka",interact)
	sword=control_button("Machnij mieczem",strike)
	bow=control_button("Łuk",draw_bow)
	shield=control_button("Tarcza",func(): pass)
	shield.button_down.connect(func(): blocking=true)
	shield.button_up.connect(func(): blocking=false)
	host.leo.add_child(equipped_bow)
	equipped_bow.position=Vector3(-.37,.87,-.26)
	for i in 8:
		var angle:float=(i-3.5)*PI/9
		host.box(equipped_bow,Vector3(0,sin(angle)*.72,-cos(angle)*.46),Vector3(.06,.28,.07),Color("#ad824b")).rotation.x=angle*.69
	host.box(equipped_bow,Vector3(0,0,-.06),Vector3(.025,1.42,.025),Color.IVORY)
	host.leo.add_child(arc)
	var trail:=ImmediateMesh.new()
	var mat:=StandardMaterial3D.new()
	mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	mat.albedo_color=Color("#ffe593")
	trail.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP,mat)
	for i in 21:
		var angle:=lerpf(-1.15,1.15,i/20.0)
		for radius in [1.75,1.40]:
			trail.surface_add_vertex(Vector3(sin(angle)*radius,.95+.27*sin(angle),-cos(angle)*radius))
	trail.surface_end()
	arc.mesh=trail
	host.leo.add_child(held_shield)
	host.orb(held_shield,Vector3(-.43,.9,-.12),.44,Color("#688daf")).scale=Vector3(.85,1.15,.25)
	stop()
	saved=read_save()

func control_button(icon:String,fn:Callable) -> Button:
	var b:Button=host.button(actions,icon,fn)
	Icons.apply(b,icon)
	b.custom_minimum_size=Vector2(78,76)
	return b

func prompt(clip:String,words:String) -> void:
	voice=clip
	caption.text=words
	if host.sound: host.play_clip(host.narrator,"story/"+clip)

func say(key:String) -> void:
	prompt("route_"+key,Data.WORDS[key])

func effect(clip:String) -> void:
	if host.sound: host.play_clip(host.chime,clip)

func checkpoint() -> void:
	var cfg:=ConfigFile.new()
	cfg.set_value("story","version",3)
	cfg.set_value("story","route",id())
	for key in ["part","marks","items","declined","traveling","village_pos","room_saves"]: cfg.set_value("story",key,get(key))
	if cfg.save(FILE+".tmp")==OK:
		saved=DirAccess.rename_absolute(ProjectSettings.globalize_path(FILE+".tmp"),ProjectSettings.globalize_path(FILE))==OK

func read_save() -> bool:
	var cfg:=ConfigFile.new()
	if cfg.load(FILE)!=OK: return false
	village_pos=Square.ENTRY
	room_saves={}
	index=Data.ROUTE.find(cfg.get_value("story","route",""))
	if index<0:
		var old:=int(cfg.get_value("story","index",-1))
		if old<0 or old>=34: return false
		var stage:String
		if old<3: stage="door"
		elif old<10: stage="range"
		elif old<12: stage="chief"
		elif old<26: stage="tobo"
		elif old==26: stage="bridge"
		elif old<30: stage=["recipe","eggs","milk"][old-27]
		else: stage="homecoming"
		index=Data.ROUTE.find(stage)
		items=PackedStringArray() if index==0 else PackedStringArray(Data.GEAR)
		part=0
		marks=0
		declined=false
		traveling=false
	else:
		part=int(cfg.get_value("story","part",0))
		marks=int(cfg.get_value("story","marks",0))
		if id()=="recipe" and int(cfg.get_value("story","version",1))==1: marks=(1<<clampi(marks,0,2))-1
		items=cfg.get_value("story","items",PackedStringArray())
		declined=bool(cfg.get_value("story","declined",false))
		traveling=bool(cfg.get_value("story","traveling",false))
		village_pos=cfg.get_value("story","village_pos",Square.ENTRY)
		room_saves=cfg.get_value("story","room_saves",{})
		if int(cfg.get_value("story","version",1))<3 and Square.FOOD.has(id()):
			if not traveling: room_saves[id()]=Vector2i(part,marks)
			index=Data.ROUTE.find("invitation")
			traveling=false
			part=0
			marks=0
	return true

func begin(resume:bool) -> void:
	if resume:
		if not read_save(): return
	else:
		index=0
		part=0
		marks=0
		items.clear()
		room_saves.clear()
		village_pos=Square.ENTRY
		declined=false
		traveling=false
	active=true
	host.prepare_valley()
	host.atlas.hide()
	host.hud.show()
	host.pause_button.show()
	for fruit in host.apples: fruit.hide()
	checkpoint()
	render()

func stop() -> void:
	if active and id()=="village": checkpoint()
	active=false
	host.camera.projection=Camera3D.PROJECTION_PERSPECTIVE
	if anim: anim.kill()
	busy=false
	blocking=false
	fingers.clear()
	host.camera.attributes=null
	bank.leave()
	for node in [square,outside,scene,props,field,dock,actions,replay,held_shield,equipped_bow,arc]: node.hide()
	host.cottage.sword.hide()
	host.cottage.slit.hide()
	host.cottage.sword.position=Vector3(.45,.92,.16)
	host.cottage.sword.rotation=Vector3.ZERO

func actor(kind:String,at:Vector3,amount:=1.0) -> Node3D:
	var a:=Props.new()
	scene.add_child(a)
	a.setup(host)
	a.build(kind)
	a.position=at
	a.scale=Vector3.ONE*amount
	return a

func button(label:String,fn:Callable) -> Button:
	var b:Button=host.button(options,label,fn)
	Icons.apply(b,label)
	return b

func show_controls() -> void:
	host.stick.visible=active and (roaming() or traveling or id()=="cross") and not host.paused
	actions.visible=active and not host.paused and (host.stick.visible or (id()=="range" and not field.visible))
	replay.visible=actions.visible and id()!="cross"
	replay.position=host.pause_button.position-Vector2(replay.size.x+12,0)
	actions.position=Vector2(host.pause_button.position.x+host.pause_button.size.x-actions.size.x,host.stick.position.y+48)
	bow.disabled="Łuk" not in items
	sword.disabled="Miecz" not in items
	shield.disabled="Tarcza" not in items

func render() -> void:
	bank.leave()
	square.hide()
	outside.hide()
	dock.offset_top=-161
	host.camera.projection=Camera3D.PROJECTION_PERSPECTIVE
	village_moving=false
	host.camera.attributes=null
	equipped_bow.hide()
	arc.hide()
	field.hide()
	host.overlay.hide()
	host.marker.hide()
	host.action_button.hide()
	host.stick.reset()
	host.narrator.stop()
	host.state=host.State.STORY
	blocking=false
	fingers.clear()
	held_shield.hide()
	host.cottage.sword.hide()
	host.cottage.slit.hide()
	hand.modulate=Color.WHITE
	busy=false
	age=0
	cooldown=0
	attack_fired=false
	for child in scene.get_children():
		scene.remove_child(child)
		child.queue_free()
	for child in options.get_children():
		options.remove_child(child)
		child.queue_free()
	actors.clear()
	pickups.clear()
	foe=null
	props.hide()
	scene.show()
	var indoors:=id() in ["door","pack","delivery","homecoming"]
	host.cottage.room.visible=indoors
	origin=host.cottage.room.position if indoors else host.point(8.6)
	if id() in ["guard","chief"]: origin=host.point(4.4)
	if id()=="tobo": origin=host.point(1.25,-1.5)
	if id() in ["lanterns","invitation","village"]:
		origin=square.position
		square.show()
		square.lit_lanterns.visible=id()!="lanterns" or part==1
		square.unlit_lanterns.visible=not square.lit_lanterns.visible
	elif id() in ["mill","coop","dairy"]: origin=Vector3(220,0,{"mill":20,"coop":40,"dairy":60}[id()])
	scene.position=origin
	host.leo.position=origin+Vector3(-.8,0,1.2)
	host.camera.look_at_from_position(origin+Vector3(0,5.6,6.9),origin+Vector3(0,.48,0),Vector3.UP)
	for board in host.boards: board.visible=index>=Data.ROUTE.find("cross")
	host.hud.text="Most dla Pestki"
	dock.show()
	show_controls()
	if traveling:
		var to_guard:=id()=="guard"
		actor("shield" if to_guard else "troll",Vector3.ZERO)
		host.leo.position=host.point(9 if to_guard else 5)
		host.camera.position=host.leo.position+Vector3(0,3.05,5.9)
		host.walk([origin],"Droga do mostu" if to_guard else "Tobo i deski")
		host.hud.text="Droga do mostu" if to_guard else "Tobo i deski"
		dock.hide()
		say("trail_guard" if to_guard else "trail_tobo")
		show_controls()
		return
	if id() in ["door","pack"]:
		var door=host.orb(scene,Vector3(0,1.24,-2.78),1.12,Color("#547348"))
		door.scale=Vector3(1,1.12,.1)
		host.orb(scene,Vector3(.65,1.16,-2.62),.11,Color.GOLD)
	if id() in ["delivery","homecoming"]:
		host.box(scene,Vector3(.1,.012,.2),Vector3(3.8,.024,2.14),Color("#92a678"))
		var oak=host.orb(scene,Vector3(.68,1.98,-2.77),.41,Color("#c58d55"))
		oak.scale=Vector3(.85,1,.21)
		host.orb(scene,Vector3(.68,2.23,-2.74),.41,Color("#856541")).scale=Vector3(1,.55,.22)
	match id():
		"door":
			visitor=actor("beaver",Vector3(0,0,-1.9))
			if declined:
				dock.hide()
				say("wait")
			else:
				var arrival:=visitor.create_tween()
				visitor.position.z-=.65
				arrival.tween_property(visitor,"position:z",-1.9,.5)
				button("Tak",accept_help)
				button("Nie teraz",decline)
				say("door")
		"pack":
			dock.hide()
			visitor=actor("beaver",Vector3(0,0,-2.45),.75)
			if part==1:
				dock.show()
				bank.begin("nailbox",0,marks)
				show_controls()
				button("Posłuchaj",func(): prompt(voice,caption.text))
				return
			for i in Data.GEAR.size():
				Village.shelf(host,scene,Data.POSITIONS[i])
				var item:=actor("gear_"+str(i),Data.POSITIONS[i]+Vector3.UP*.69,.88)
				pickups.append(item)
				item.visible=Data.GEAR[i] not in items
			host.hud.text="Plecak   %d / 7"%items.size()
			say("exit" if items.size()==7 else "pack")
		"range","dummy":
			for x in [-2.0,-1.1]:
				var kid:Node3D=preload("res://art/leo.glb").instantiate()
				scene.add_child(kid)
				kid.scale=Vector3.ONE*.55
				kid.position=Vector3(x,0,-1)
				var run:=kid.create_tween()
				kid.position.z-=2
				run.tween_property(kid,"position:z",-1,.7)
			if id()=="range":
				actors.append(actor("barrel",Vector3(1,0,-.45)))
				actors.append(actor("barrel",Vector3(1.85,0,-.8)))
				if part>0: actors[0].rotation.z=PI*.45
				props.position=origin+Vector3(1,0,-.45)
				props.build("barrel")
				if part>0: props.position=origin+Vector3(1.85,0,-.8)
				dock.hide()
			else:
				if marks==3:
					advance()
					return
				for i in 2:
					actors.append(actor("dummy",Vector3(1.8-i*2.9,0,-.25)))
					actors[i].visible=(marks & (1<<i))==0
				dock.hide()
			say(id())
		"guard":
			dock.hide()
			foe=actor("shield",Vector3(.45,0,-.45))
			foe_shield=foe.prop.get_child(-1)
			foe_sword=host.box(foe,Vector3(-.6,.85,.25),Vector3(.14,1,.12),Color("#c8d6dc"))
			say("guard")
		"invitation":
			var porch:Vector3=Square.DOORS.delivery
			actor("squirrel",porch+Vector3(-.85,0,.62),1.1)
			host.leo.position=origin+porch+Vector3(.8,0,1.05)
			dock.offset_top=-202
			host.hud.text="Urodziny Tygryska"
			host.camera.look_at_from_position(origin+porch+Vector3(-1.3,3.8,4.1),origin+porch+Vector3(-.42,.78,.54),Vector3.UP)
			button("Dalej",advance)
			say("invitation")
		"village":
			dock.hide()
			host.leo.position=origin+village_pos
			actor("squirrel",Square.DOORS.delivery+Vector3(-1.09,0,.46),.82)
			square.camera_at(village_pos)
			say("return_home" if ingredients_ready() else "village")
			village_hint()
		"delivery":
			dock.hide()
			visitor=actor("squirrel",Vector3(1.45,.03,-.60))
			host.hud.text="Podaj składniki Wiewiórce"
			if part==1:
				for i in 3: actor("flour",Vector3(-.82+i*.28,.9,-.24),.4)
				actor("eggs",Vector3(.05,.9,-.26),.67)
				actor("milk",Vector3(.73,.9,-.17),.65)
				dock.show()
				button("Dalej",func(): go_to("recipe"))
				host.stick.hide()
				actions.hide()
				replay.hide()
				say("thanks")
			elif ingredients_ready(): say("delivery")
			else: missing_hint()
		"lanterns":
			light_filter.exposure_multiplier=.30 if part==0 else 1.0
			host.camera.attributes=light_filter
			if part==0:
				for n in Data.number_choices(5): button(str(n),lantern_answer.bind(n))
				say("lanterns")
			else:
				button("Dalej",advance)
				say("lit")
		"mill","coop":
			dock.hide()
			Village.interior(self,id())
			if id()=="mill":
				for i in 2:
					var spider:=actor("spider",Village.TARGETS[i]-Vector3.UP*.48,.76)
					spider.visible=i>=part
					actors.append(spider)
				if "Mąka" not in items:
					for i in 3: actor("flour",Vector3(.35+i*.64,0,-.85),.57)
				for i in 2:
					if actors[i].tool: actors[i].tool.hide()
				if "Mąka" in items: farm_exit_prompt()
				else: say("take_flour" if part==2 else "mill")
			else:
				foe=host.cottage.fox.duplicate()
				scene.add_child(foe)
				foe.position=Vector3(1.25,0,-.35)
				foe.rotation.y=-.35
				foe.visible=part==0
				for x in ([] if "Jajka" in items else [.54,1.24]): host.orb(scene,Vector3(x,.30,-.66),.24,Color.IVORY).scale.y=1.23
				if "Jajka" in items: farm_exit_prompt()
				else: say("take_eggs" if part==1 else "coop")
		"dairy":
			if "Mleko" in items:
				dock.hide()
				Village.interior(self,"dairy")
				var stall:=bank.Farm.new()
				scene.add_child(stall)
				stall.bank=bank
				stall.host=host
				for x in [-2.15,1.48]: stall.cow(Vector3(x,0,-1.47),.84)
				actor("milk",Vector3(.7,0,-.7))
				farm_exit_prompt()
			else: start_bank()
		"chief":
			actor("chief",Vector3(0,0,-1))
			for x in [-1.8,-1.23,1.5]: host.orb(scene,Vector3(x,.35,0),.30,Color("#d2543c"))
			for n in Data.number_choices(3): button(str(n),answer.bind(n))
			say("chief")
		"tobo":
			actor("troll",Vector3(1,0,-1))
			for i in 3: host.box(scene,Vector3(1,.15+i*.11,0),Vector3(2,.11,.4),Color("#ca985e"))
			button("Dalej",advance)
			say("tobo")
		"bridge":
			if part==0:
				show_count()
			else: start_bank()
		"blanket","recipe","eggs","milk": start_bank()
		"cross":
			dock.hide()
			host.leo.position=host.point(2)
			actor("beaver",host.point(-6,1)-origin,.64)
			actor("beaver",host.point(-6,-1)-origin)
			host.walk([host.point(-6)],"Przejdź przez most")
			show_controls()
		"homecoming":
			actor("squirrel",Vector3(1.55,0,-.7))
			host.hud.text="Urodziny Tygryska"
			actor("tiger",Vector3(-1.12,.22,-.64),1.10)
			actor("birthday_cake",Vector3(.35,.92,0))
			button("Wróć do mapy",finish)
			say("homecoming")
	if Square.FOOD.has(id()) or id()=="delivery":
		outside.show()
		outside.position=host.pause_button.position+Vector2(0,host.pause_button.size.y+8)
	if dock.visible:
		button("Posłuchaj",func(): prompt(voice,caption.text))

func start_bank() -> void:
	bank.begin(id(),part-1 if id()=="bridge" else part,marks)

func show_count() -> void:
	dock.hide()
	host.clear_panel()
	host.label_line("Most dla Pestki",28)
	var repair:=Repair.new()
	repair.story_order=true
	var code:=marks
	while code>0:
		repair.counted.push_front(code%6-1)
		code=floori(code/6.0)
	repair.counted_slot.connect(func():
		marks=marks*6+repair.counted.back()+1
		checkpoint())
	repair.voice.connect(func(clip):
		if host.sound: host.play_clip(host.narrator,clip))
	repair.ordered.connect(func():
		part=1
		marks=0
		checkpoint()
		render())
	host.panel.add_child(repair)

func accept_help() -> void:
	declined=false
	advance()

func decline() -> void:
	declined=true
	checkpoint()
	render()

func answer(n:int) -> void:
	if n==3: advance()
	else: effect("story/again")

func finish() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	saved=FileAccess.file_exists(FILE)
	host.home()

func advance() -> void:
	if id()=="invitation": village_pos=Square.DOORS.delivery+Vector3.BACK*.95
	index+=1
	traveling=id() in ["guard","tobo"]
	part=0
	marks=0
	checkpoint()
	render()

func arrived() -> void:
	if traveling:
		traveling=false
		checkpoint()
		render()
	elif id()=="cross": advance()

func interact() -> void:
	if not active or busy or host.paused: return
	if id() in ["pack","door"] and host.leo.position.distance_to(visitor.global_position)<1.45:
		if declined:
			declined=false
			checkpoint()
			render()
			return
		if items.size()==7:
			advance()
			return
	if traveling or bank.visible or field.visible: return
	if id()=="village":
		var door:=square.near_door(village_pos)
		if door=="": return
		var progress:Vector2i=room_saves.get(door,Vector2i.ZERO)
		go_to(door,progress.x,progress.y)
		return
	if id()=="delivery":
		if host.leo.position.distance_to(visitor.global_position)<1.8:
			if not ingredients_ready():
				missing_hint()
				return
			if part==0:
				part=1
				checkpoint()
				render()
			else: go_to("recipe")
		return
	if Square.FOOD.has(id()) and Square.FOOD[id()] in items:
		if host.leo.position.distance_to(origin+Vector3(0,0,2.13))<1.32: leave_room()
		return
	if id() in ["mill","coop"]:
		if ((id()=="mill" and part==2) or (id()=="coop" and part==1)) and host.leo.position.distance_to(origin+Vector3(.9,0,-.75))<1.65:
			items.append("Mąka" if id()=="mill" else "Jajka")
			effect("chime")
			checkpoint()
			render()
		return
	if id()!="pack": return
	var nearest:=-1
	var distance:=1.25
	for i in pickups.size():
		var d:float=pickups[i].global_position.distance_to(host.leo.position)
		if pickups[i].visible and d<distance:
			nearest=i
			distance=d
	if nearest<0: return
	if nearest==3:
		part=1
		marks=0
		checkpoint()
		render()
		return
	var object:=pickups[nearest]
	items.append(Data.GEAR[nearest])
	checkpoint()
	busy=true
	effect("chime")
	anim=create_tween()
	anim.tween_property(object,"global_position",host.leo.position+Vector3.UP,.28)
	anim.tween_callback(func():
		object.hide()
		busy=false
		show_controls()
		host.hud.text="Plecak   %d / 7"%items.size()
		if items.size()==7: say("exit"))

func strike() -> void:
	if traveling or not active or host.paused or busy or cooldown>0 or "Miecz" not in items or blocking: return
	cooldown=.36
	host.cottage.sword.position.z=-.48
	host.cottage.sword.rotation.x=-1.14
	host.cottage.sword.show()
	arc.show()
	equipped_bow.hide()
	host.cottage.sword.rotation.z=-1.08
	effect("swoosh")
	if id()=="coop" and part==0 and host.leo.position.distance_to(foe.global_position)<1.8:
		busy=true
		anim=create_tween()
		anim.tween_property(foe,"position",Vector3(4,.05,-1.7),.5)
		anim.tween_callback(func():
			part=1
			checkpoint()
			render())
	if id()=="dummy":
		for i in actors.size():
			if actors[i].visible and host.leo.position.distance_to(actors[i].global_position)<1.72:
				marks|=1<<i
				checkpoint()
				busy=true
				anim=create_tween()
				anim.tween_property(actors[i],"rotation:z",1.45,.27)
				anim.tween_callback(func():
					actors[i].hide()
					busy=false
					if marks==3: advance())
				break
	if id()=="guard" and host.leo.position.distance_to(foe.global_position)<1.88:
		var offset:Vector3=host.leo.position-foe.global_position
		if guarding and offset.z>0 and absf(offset.x)<absf(offset.z):
			effect("wood_tap")
		else:
			busy=true
			anim=create_tween()
			anim.tween_property(foe,"position",foe.position+Vector3(1.35,0,-1),.34)
			anim.tween_callback(advance)

func _physics_process(dt:float) -> void:
	if not active or host.paused: return
	age+=dt
	if cooldown>0:
		cooldown-=dt
		host.cottage.sword.rotation.y=lerpf(1.1,-1.1,1-cooldown/.36)
		arc.rotation.y=lerpf(.48,-.48,1-cooldown/.36)
		arc.scale.x=.8+.2*sin(PI*cooldown/.36)
		if cooldown<=0:
			arc.hide()
			host.cottage.sword.hide()
			host.cottage.slit.hide()
	if traveling or not roaming() or busy or (id()=="delivery" and part==1): return
	show_controls()
	var motion:Vector2=host.stick.vector
	if motion.is_zero_approx(): motion=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var pos:Vector3=host.leo.position-origin
	pos+=Vector3(motion.x,0,motion.y)*dt*(2.75 if blocking else 4.2)
	if id()=="village":
		var previous:=village_pos
		if square.can_walk(Vector3(pos.x,0,previous.z)): village_pos.x=pos.x
		if square.can_walk(Vector3(village_pos.x,0,pos.z)): village_pos.z=pos.z
		pos=village_pos
		square.camera_at(pos)
		village_hint()
		if motion.is_zero_approx() and village_moving: checkpoint()
		village_moving=not motion.is_zero_approx()
	else:
		pos.x=clampf(pos.x,-3.4,3.4)
		pos.z=clampf(pos.z,-2.45,2.5)
	# The cottage table occupies the middle of the floor.
	if id() in ["door","pack","delivery"] and absf(pos.x)<1.45 and absf(pos.z)<.84:
		var previous:Vector3=host.leo.position-origin
		if absf(previous.x)>=1.45: pos.x=previous.x
		else: pos.z=previous.z
	host.leo.position=origin+pos
	if motion.length()>.05: host.leo.rotation.y=atan2(-motion.x,-motion.y)
	for i in host.limbs.size(): host.limbs[i].rotation.x=sin(age*12)*(1 if i in [0,3] else -1)*motion.length()*.44
	if id()=="pack":
		host.marker.hide()
		var nearest_distance:=1.25
		for i in pickups.size():
			var d:float=pickups[i].global_position.distance_to(host.leo.position)
			if pickups[i].visible and d<nearest_distance:
				host.marker.position=pickups[i].global_position+Vector3.UP*.08
				host.marker.show()
				host.hud.text="%s    %d / 7"%[Data.GEAR[i],items.size()]
				nearest_distance=d
		if not host.marker.visible: host.hud.text="Plecak   %d / 7"%items.size()
	held_shield.visible=blocking and "Tarcza" in items
	if id()=="guard":
		var phase:=fmod(age,4.5)
		guarding=phase<2.15
		foe_shield.position.y=.98 if guarding else .35
		foe_shield.rotation.z=0 if guarding else .95
		foe_sword.rotation.z=-.9 if phase<2.15 else 1.1
		if host.leo.position.distance_to(foe.global_position)>1.45:
			foe.global_position=foe.global_position.move_toward(host.leo.position,dt*.65)
		if phase<2.15: attack_fired=false
		elif not attack_fired:
			attack_fired=true
			if host.leo.position.distance_to(foe.global_position)<2:
				effect("wood_tap")
				if not blocking:
					var push:Vector3=(host.leo.position-foe.global_position).normalized()
					host.leo.position+=push*.95

func _input(event:InputEvent) -> void:
	if not active or host.paused or not actions.visible or not event is InputEventScreenTouch: return
	if event.pressed and not event.canceled:
		for b in [hand,sword,bow,shield]:
			if b.disabled or not b.get_global_rect().has_point(event.position): continue
			fingers[event.index]=b
			if b==shield: blocking=true
			elif b==hand: interact()
			elif b==bow: draw_bow()
			else: strike()
			get_viewport().set_input_as_handled()
			return
	elif fingers.has(event.index):
		var b:Button=fingers[event.index]
		fingers.erase(event.index)
		if b==shield: blocking=shield in fingers.values()
		get_viewport().set_input_as_handled()

func bank_done() -> void:
	if id()=="pack":
		items.append("Gwoździe")
		part=0
		marks=0
		checkpoint()
		render()
	else:
		if id()=="dairy":
			items.append("Mleko")
			checkpoint()
			render()
		else: advance()

func lantern_answer(n:int) -> void:
	if n!=5:
		effect("story/again")
		return
	part=1
	checkpoint()
	render()

func draw_bow() -> void:
	if not active or host.paused or busy or traveling or "Łuk" not in items: return
	equipped_bow.show()
	if id() in ["range","mill"] and part<2:
		dock.show()
		if options.get_child_count()==0: button("Posłuchaj",func(): prompt(voice,caption.text))
		field.begin(self,"pine",0,part)
		host.stick.reset()
		host.stick.hide()
		actions.hide()
		replay.hide()

func go_to(stage:String,saved_part:=0,saved_marks:=0) -> void:
	index=Data.ROUTE.find(stage)
	part=saved_part
	marks=saved_marks
	traveling=false
	checkpoint()
	render()

func leave_room() -> void:
	if not active or host.paused or busy: return
	var room:=id()
	if not Square.DOORS.has(room): return
	room_saves[room]=Vector2i(part,marks)
	village_pos=Square.DOORS[room]+Vector3.BACK*.82
	go_to("village")

func ingredients_ready() -> bool:
	for food in Square.FOOD.values():
		if food not in items: return false
	return true

func village_hint() -> void:
	var door:=square.near_door(village_pos)
	host.hud.text=Square.NAMES.get(door,"Wioska Tygryska")
	hand.modulate=Color("#ffe3a4") if door!="" else Color.WHITE

func missing_hint() -> void:
	for place in Square.FOOD:
		if Square.FOOD[place] not in items:
			say("need_"+place)
			return

func farm_exit_prompt() -> void:
	var mat=host.box(scene,Vector3(0,.045,2.13),Vector3(1.65,.08,.76),Color("#ccac74"))
	for side in [-1,1]:
		host.box(mat,Vector3(side*.18,.05,.03),Vector3(.12,.05,.42),Color.IVORY).rotation.y=-side*.63
	say("leave_"+id())
