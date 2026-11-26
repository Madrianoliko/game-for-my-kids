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
var stable:=preload("res://scripts/pony_stable.gd").new()
var camp
const ReturnTrip := preload("res://scripts/troll_return.gd")
var return_trip:ReturnTrip
var stone_hill:=Node3D.new()
var hint_errors:=0
var hint_total:=0
var hint_lit:=0
var hint_delay:=0.0
var hint_display:=Callable()
var iskierka:Node3D
var dawn:Node3D
var fork_trail:Node3D
var fork_path:=""
var numbers:Dictionary={}

func pony_count() -> int:
	return 3 if numbers.get("camp",7)==7 else 2

var travel_apples:int:
	get: return numbers.get("apples",3)
var waving_paw:Node3D
var chapters:=0
var reward:=Label.new()
var curtain:=ColorRect.new()
var transition_time:=0.0
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
const GUARD_CUES := ["guard","guard_side","guard_sword"]
var ingredient_list := HBoxContainer.new()
var ingredient_ticks := {}
var voice:=""
var origin:=Vector3.ZERO

func id() -> String: return Data.ROUTE[index]

func roaming() -> bool: return (id() in ["pack","mill","coop","village","delivery"] and not bank.visible and not field.visible) or id() in ["dummy","guard"] or (id()=="dairy" and "Mleko" in items) or (id()=="door" and declined)

func setup(game) -> void:
	host=game
	add_child(square)
	square.setup(game)
	square.add_child(stable)
	stable.setup(game)
	stable.add_child(stone_hill)
	stone_hill.position=Vector3(5.5,.80,-2.8)
	var stone:=StandardMaterial3D.new()
	stone.albedo_color=Color("#9ca7b0")
	for i in 3:
		var statue:=Props.new()
		stone_hill.add_child(statue)
		statue.setup(game)
		statue.build("troll")
		statue.position=Vector3((i-1)*1.03,0,0)
		statue.rotation.z=[.42,-.36,.62][i]
		statue.scale=Vector3.ONE*.82
		for mesh in statue.find_children("*","MeshInstance3D",true,false): mesh.material_override=stone
	stone_hill.hide()
	stable.counted.connect(count_pen)
	host.ui.add_child(reward)
	reward.text="★"
	reward.modulate=Color.GOLD
	reward.add_theme_font_size_override("font_size",80)
	reward.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	reward.hide()
	host.ui.add_child(curtain)
	curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	curtain.mouse_filter=Control.MOUSE_FILTER_IGNORE
	curtain.color=Color(0,0,0,0)
	add_child(scene)
	add_child(props)
	props.setup(host)
	add_child(bank)
	bank.setup(host)
	bank.progress.connect(func(n,m):
		if id()!="fork": part=n+1 if id() in ["bridge","pack"] else n
		marks=m; checkpoint())
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
	field.instruction.connect(func(clip:String, words:String):
		if id()=="range" and clip=="enc_aim_cone": say("drawstring")
		else: prompt(clip,words))
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
	host.ui.add_child(ingredient_list)
	ingredient_list.mouse_filter=Control.MOUSE_FILTER_IGNORE
	for food in Square.FOOD.values():
		var icon:=TextureRect.new()
		icon.texture=Icons.picture(food)
		icon.custom_minimum_size=Vector2(62,62)
		icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
		ingredient_list.add_child(icon)
		var tick:=TextureRect.new()
		tick.texture=Icons.picture("Zebrane")
		tick.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		tick.position=Vector2(33,32)
		tick.size=Vector2(30,30)
		tick.mouse_filter=Control.MOUSE_FILTER_IGNORE
		icon.add_child(tick)
		ingredient_ticks[food]=tick
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

func checkpoint(ended:=false) -> void:
	var cfg:=ConfigFile.new()
	cfg.set_value("story","version",3)
	cfg.set_value("story","route",id())
	cfg.set_value("story","numbers",numbers)
	cfg.set_value("story","chapters_completed",chapters)
	cfg.set_value("story","ended",ended)
	cfg.set_value("story","stone_hill",stone_hill.visible)
	for key in ["part","marks","items","declined","traveling","village_pos","room_saves","fork_path"]: cfg.set_value("story",key,get(key))
	if cfg.save(FILE+".tmp")==OK:
		saved=DirAccess.rename_absolute(ProjectSettings.globalize_path(FILE+".tmp"),ProjectSettings.globalize_path(FILE))==OK and not ended

func read_save() -> bool:
	var cfg:=ConfigFile.new()
	if cfg.load(FILE)!=OK: return false
	numbers=cfg.get_value("story","numbers",{})
	chapters=int(cfg.get_value("story","chapters_completed",0))
	stone_hill.visible=bool(cfg.get_value("story","stone_hill",chapters>=2 or cfg.get_value("story","route","")=="stable_home"))
	var old_berry_end:bool=cfg.get_value("story","ended",false) and cfg.get_value("story","route","")=="dragon_berries"
	if cfg.get_value("story","ended",false) and not old_berry_end:
		items=cfg.get_value("story","items",PackedStringArray())
		if chapters>=2 and ReturnTrip.MAP not in items: items.append(ReturnTrip.MAP)
		return false
	village_pos=Square.ENTRY
	room_saves={}
	fork_path=str(cfg.get_value("story","fork_path",""))
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
		if id()=="stable_home" and ReturnTrip.MAP not in items: items.append(ReturnTrip.MAP)
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
	if old_berry_end:
		index=Data.ROUTE.find("mountain_fork")
		part=0
		marks=0
	return true

func begin(resume:bool, start_step:="door") -> void:
	if resume:
		if not read_save(): return
	else:
		numbers=Data.draw_numbers()
		index=Data.ROUTE.find(start_step)
		part=0
		marks=0
		items.clear()
		if start_step=="dragon_map": items.append(ReturnTrip.MAP)
		room_saves.clear()
		fork_path=""
		village_pos=Square.ENTRY
		declined=false
		traveling=false
	active=true
	host.prepare_valley()
	host.atlas.hide()
	host.hud.show()
	host.pause_button.show()
	checkpoint()
	render()

func stop() -> void:
	clear_hint()
	host.camera.environment=null
	host.camera.v_offset=0
	host.beaver.show()
	stable.set_pens(false,0,false)
	curtain.color.a=0
	reward.hide()
	if is_instance_valid(camp) and not camp.is_queued_for_deletion(): camp.dispose()
	camp=null
	if active and id()=="village": checkpoint()
	active=false
	host.camera.projection=Camera3D.PROJECTION_PERSPECTIVE
	if anim: anim.kill()
	busy=false
	blocking=false
	fingers.clear()
	host.camera.attributes=null
	bank.leave()
	for node in [ingredient_list,square,outside,scene,props,field,dock,actions,replay,held_shield,equipped_bow,arc]: node.hide()
	host.cottage.sword.hide()
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
	if label.is_valid_int(): dock.offset_top=-206
	var b:Button=host.button(options,label,fn)
	Icons.apply(b,label)
	return b

func show_controls() -> void:
	if active and id()=="camp" and is_instance_valid(camp):
		host.stick.visible=not host.paused and camp.phase!=camp.Phase.DONE
		return
	host.stick.visible=active and (roaming() or traveling or (id()=="chief_happy" and part==2) or id() in ["cross","night_bridge","dragon_orchard"] or (id()=="fork" and part!=2)) and not host.paused
	actions.visible=active and not host.paused and (host.stick.visible or (id()=="range" and not field.visible))
	replay.visible=actions.visible and id()!="cross"
	if id() in ["night_bridge","fork","chief_happy","dragon_orchard"]: actions.hide()
	if id()=="dragon_orchard": replay.hide()
	replay.position=host.pause_button.position-Vector2(replay.size.x+12,0)
	actions.position=Vector2(host.pause_button.position.x+host.pause_button.size.x-actions.size.x,host.stick.position.y+48)
	bow.disabled="Łuk" not in items
	sword.disabled="Miecz" not in items
	shield.disabled="Tarcza" not in items

func render() -> void:
	clear_hint()
	host.camera.environment=null
	host.camera.v_offset=0
	host.beaver.show()
	stable.set_pens(false,0,false)
	curtain.color.a=0
	reward.hide()
	ingredient_list.visible=id() in ["invitation","village","mill","coop","dairy","delivery"] and not (id()=="delivery" and part==1)
	ingredient_list.position=host.hud.position+Vector2(0,host.hud.size.y+6)
	for food in ingredient_ticks:
		ingredient_ticks[food].visible=food in items
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
	host.stick.reset()
	host.narrator.stop()
	host.state=host.State.STORY
	blocking=false
	fingers.clear()
	held_shield.hide()
	host.cottage.sword.hide()
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
	var indoors:=id() in ["dragon_map","door","pack","delivery","homecoming"]
	host.cottage.room.visible=indoors
	origin=host.cottage.room.position if indoors else host.point(8.6)
	if id() in ["guard","chief"]: origin=host.point(4.4)
	if id() in ["dragon_orchard","dragon_berries","mountain_fork","mountain_steps","warm_cave"]: origin=Vector3(400,0,90)
	if id()=="troll_cave": origin=Vector3(324,0,100)
	if id()=="chief_happy": origin=host.point(-7)
	if id()=="troll_dawn": origin=Vector3(310,0,100)
	if id()=="fork": origin=Vector3(260,0,90)
	if id()=="chief_sad": origin=host.point(-7)
	if id()=="tobo": origin=host.point(1.25,-1.5)
	if id() in ["lanterns","invitation","village","stable","stable_home"]:
		origin=square.position
		square.show()
		square.arrange_lamps(numbers.get("lamps",5))
		square.show_lamps(0 if id()=="lanterns" and part==0 else numbers.get("lamps",5))
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
			say(GUARD_CUES[clampi(marks,0,2)])
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
				for n in Data.number_choices(numbers.get("lamps",5)): button(str(n),lantern_answer.bind(n))
				say({4:"lanterns_four",5:"lanterns",6:"lanterns_alt"}[numbers.get("lamps",5)])
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
			for x in [-1.8,-1.23,1.5,2.1].slice(0,numbers.get("chief",3)): pickups.append(make_apple(Vector3(x,.35,0)))
			for n in Data.number_choices(numbers.get("chief",3)): button(str(n),answer.bind(n))
			say("chief" if numbers.get("chief",3)==3 else "chief_alt")
		"tobo":
			actor("troll",Vector3(1,0,-1))
			for i in numbers.get("boards",3): host.box(scene,Vector3(1,.15+i*.11,0),Vector3(2,.11,.4),Color("#ca985e"))
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
		"night_bridge":
			dock.hide()
			light_filter.exposure_multiplier=.42
			host.camera.attributes=light_filter
			host.leo.position=host.point(2)
			host.camera.position=host.leo.position+Vector3(0,3.05,5.9)
			visitor=actor("troll",host.leo.position-origin+Vector3(1,0,.6),.85)
			var beaver:=actor("beaver",host.point(-2,-2.3)-origin+Vector3.DOWN*.32)
			host.beaver.hide()
			waving_paw=Node3D.new()
			beaver.add_child(waving_paw)
			waving_paw.position=Vector3(.35,.78,.2)
			host.orb(waving_paw,Vector3(.15,.19,0),.17,Color("#8e582f")).scale.y=1.45
			var flame=host.orb(scene,host.point(-8,1)-origin+Vector3.UP*.45,.3,Color.ORANGE_RED,true)
			var flicker=flame.create_tween().set_loops()
			flicker.tween_property(flame,"scale:y",1.65,.31)
			flicker.tween_property(flame,"scale:y",1.1,.23)
			host.walk([host.point(-6)],"Nocny most")
			say("night_bridge")
			show_controls()
		"fork":
			light_filter.exposure_multiplier=.68
			host.camera.attributes=light_filter
			host.hud.text="Dwie drogi do obozu"
			if part==2:
				bank.begin("fork",0,marks)
			else:
				dock.hide()
				fork_trail=preload("res://scripts/forest_fork.gd").new()
				scene.add_child(fork_trail)
				fork_trail.setup(self)
		"troll_cave","chief_happy":
			if id()=="chief_happy" and part==2: dock.hide()
			return_trip=ReturnTrip.new()
			scene.add_child(return_trip)
			return_trip.setup(self)
		"mountain_fork","mountain_steps","warm_cave":
			iskierka=preload("res://scripts/dragon_mountain.gd").new()
			scene.add_child(iskierka)
			iskierka.setup(self)
		"dragon_map","dragon_orchard","dragon_berries":
			iskierka=preload("res://scripts/iskierka.gd").new()
			scene.add_child(iskierka)
			iskierka.setup(self)
		"troll_dawn":
			host.hud.text="Kłótnia przy ognisku"
			dawn=preload("res://scripts/troll_dawn.gd").new()
			scene.add_child(dawn)
			dawn.setup(self)
		"chief_sad": render_apple_chief()
		"stable","stable_home":
			render_stable()
		"camp":
			dock.hide()
			host.hud.hide()
			host.pause_button.hide()
			camp=preload("res://scripts/troll_camp.gd").new()
			add_child(camp)
			camp.rescued.connect(func(mask): marks=mask; checkpoint())
			camp.closed.connect(func(complete):
				camp=null
				if complete:
					host.hud.show()
					host.pause_button.show()
					advance()
				else: host.home())
			camp.begin(host,marks,numbers.get("camp",7))
		"homecoming":
			actor("squirrel",Vector3(1.55,0,-.7))
			host.hud.text="Urodziny Tygryska"
			actor("tiger",Vector3(-1.12,.22,-.64),1.10)
			actor("birthday_cake",Vector3(.35,.92,0))
			if part==0:
				button("Dalej",func():
					chapters=maxi(chapters,1)
					go_to("homecoming",1))
			else: dock.hide()
			if part==0: say("homecoming")
	if Square.FOOD.has(id()) or id()=="delivery":
		outside.show()
		outside.position=host.pause_button.position+Vector2(0,host.pause_button.size.y+8)
	if dock.visible and id()=="troll_dawn":
		button("Posłuchaj",dawn.narrate)
	elif dock.visible:
		button("Posłuchaj",func(): prompt(voice,caption.text))

func start_bank() -> void:
	bank.begin(id(),part-1 if id()=="bridge" else part,marks)

func show_count() -> void:
	dock.hide()
	host.clear_panel()
	host.label_line("Most dla Pestki",28)
	var repair:=Repair.new()
	repair.on_hand=5-numbers.get("boards",3)
	repair.story_order=true
	repair.wrong.connect(func(): hint_miss(repair.SPANS-repair.on_hand,repair.highlight_gaps))
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

func clear_hint() -> void:
	if hint_display.is_valid(): hint_display.call(0)
	if hint_errors>=2: host.chime.stop()
	hint_errors=0
	hint_lit=0
	hint_total=0
	hint_display=Callable()

func hint_miss(total:int,display:Callable) -> void:
	hint_errors+=1
	if hint_errors!=2: return
	hint_total=total
	hint_display=display
	display.call(0)
	hint_delay=.45
	host.narrator.stop()

func glow_pickups(total:int) -> void:
	for i in pickups.size():
		var material:StandardMaterial3D=pickups[i].material_override
		material.emission_enabled=i<total
		material.emission=Color("#ffcd62")

func answer(n:int) -> void:
	if n==numbers.get("chief",3): advance()
	else:
		if hint_errors==0: effect("story/again")
		hint_miss(numbers.get("chief",3),glow_pickups)

func make_apple(at:Vector3) -> Node3D:
	var apple=host.orb(scene,at,.25,Color("#de4939"))
	host.box(apple,Vector3(0,.25,0),Vector3(.045,.14,.045),Color("#674324"))
	host.orb(apple,Vector3(.08,.28,0),.09,Color("#76ab49")).scale=Vector3(1.3,.36,.7)
	return apple

func render_apple_chief() -> void:
	host.hud.text="Kosz herszta"
	light_filter.exposure_multiplier=.66
	host.camera.attributes=light_filter
	var chief:=actor("chief",Vector3(.75,0,-.8))
	if part<3:
		chief.scale.y=.76
		chief.rotation.x=.12
		for x in [-.29,.29]:
			host.orb(chief,Vector3(x,.22,.43),.24,Props.GREEN)
	var basket:=Vector3(.85,0,.56)
	for row in 4:
		var rim:=TorusMesh.new()
		rim.inner_radius=.49+row*.055
		rim.outer_radius=rim.inner_radius+.1
		var hoop=host.mesh(scene,rim,basket+Vector3.UP*(.12+row*.11),Props.WOOD)
		hoop.scale.x=1.45
	var given:=travel_apples-items.count("Jabłko")
	for i in travel_apples:
		var at:=basket+Vector3((i-(travel_apples-1)*.5)*.51,.55,.02)
		if i>=given: at=Vector3(-2.2+(i-given)*.55,.45,.34)
		pickups.append(make_apple(at))
	match part:
		0: say("sad_loss")
		1:
			if given<travel_apples: button("Ręka",give_apple)
			if given==0: say("sad_give")
			elif given<travel_apples: say("sad_next")
			else: say("sad_question")
		2:
			for n in Data.number_choices(travel_apples): button(str(n),apple_answer.bind(n))
			say("sad_question")
			if marks>0:
				hint_errors=1
				if marks>=2: hint_miss(travel_apples,glow_pickups)
		3:
			button("Dalej",advance)
			say("sad_thanks" if travel_apples==3 else "sad_thanks_alt")
	transition_time=(host.narrator.stream.get_length() if host.sound and host.narrator.stream else 2.0)+.25

func give_apple() -> void:
	var slot:=items.find("Jabłko")
	if slot<0: return
	items.remove_at(slot)
	marks+=1
	checkpoint()
	render()
	var apple:=pickups[marks-1]
	var end:=apple.position
	apple.position=Vector3(-2.2,.72,.34)
	apple.create_tween().tween_property(apple,"position",end,.36)
	var count_clip:="count_%d"%marks
	if host.sound: host.play_clip(host.narrator,count_clip)
	transition_time=(host.narrator.stream.get_length() if host.sound else .65)+.12
	for b in options.get_children():
		if b.accessibility_name=="Ręka": b.disabled=true

func apple_answer(n:int) -> void:
	if n==travel_apples:
		go_to("chief_sad",3)
		return
	marks+=1
	checkpoint()
	hint_miss(travel_apples,glow_pickups)
	if marks>=2: return
	say("sad_retry")
	for i in pickups.size():
		var apple:=pickups[i]
		var pulse:=apple.create_tween()
		pulse.tween_interval(.08)
		if i>=n:
			pulse.tween_property(apple,"position:y",.93,.2)
			pulse.tween_property(apple,"position:y",.55,.3)
		pulse.tween_property(apple,"scale",Vector3.ONE*1.45,.2)
		pulse.tween_property(apple,"scale",Vector3.ONE,.25)

	if n>travel_apples:
		for i in range(travel_apples,n):
			var ring:=TorusMesh.new()
			ring.inner_radius=.19
			ring.outer_radius=.24
			var empty=host.mesh(scene,ring,Vector3(.85+(i-3)*.58,.68,1.4),Color.WHEAT)
			var fade=empty.create_tween()
			fade.tween_interval(1.0)
			fade.tween_property(empty,"scale",Vector3.ZERO,.3)
			fade.tween_callback(empty.queue_free)

func _unhandled_input(event:InputEvent) -> void:
	if not active or host.paused or id()!="chief_sad" or part!=2: return
	if not ((event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT)) and event.pressed): return
	for i in pickups.size():
		var pos:Vector2=host.camera.unproject_position(pickups[i].global_position)
		if pos.distance_to(event.position)<maxf(18,host.camera.unproject_position(pickups[i].global_position+Vector3.RIGHT*.28).distance_to(pos)):
			if host.sound: host.play_clip(host.narrator,"count_%d"%(i+1))
			get_viewport().set_input_as_handled()
			return

func render_stable() -> void:
	var home:=id()=="stable_home"
	var focus:=stable.global_position
	host.leo.global_position=focus+Vector3(-4.3,0,2.5)
	visitor=actor("troll",stable.position+Vector3(4.4,0,1.1),.9)
	host.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	host.camera.size=maxf(8.8,12.8/host.ui.size.aspect())
	host.camera.look_at_from_position(focus+Vector3(0,6.2,9),focus+Vector3(0,.1,1.2),Vector3.UP)
	host.hud.text="Stajnia Toba"
	stable.empty_mask=22 if pony_count()==3 else 18
	var counting:=part==0 if home else part==1
	stable.set_pens(home,marks,counting)
	if home:
		var pestka=actor("beaver",stable.position+stable.horses[2].position+Vector3(0,1.0,-.08),.46)
		pestka.rotation.y=.18
		if part==0: say("stable_home")
		else:
			reward.show()
			say("stable_thanks" if pony_count()==3 else "stable_thanks_alt")
	elif part==0:
		say("evening")
		curtain.color.a=.88
	elif part==1:
		if marks==stable.empty_mask:
			for n in Data.number_choices(pony_count()): button(str(n),stable_answer.bind(n))
		say(("stable" if pony_count()==3 else "stable_alt") if marks==0 or marks==stable.empty_mask else "empty_pens")
	elif part==2:
		stable.smoke.show()
		visitor.look_at(stable.smoke.global_position,Vector3.UP,true)
		var smoke_focus:=focus.lerp(stable.smoke.global_position,.62)
		host.camera.look_at_from_position(smoke_focus+Vector3(0,5.5,9),smoke_focus,Vector3.UP)
		say("stable_ok" if pony_count()==3 else "stable_ok_alt")
	elif part==3:
		for i in travel_apples:
			make_apple(stable.position+Vector3(2.5+i*.48,.36,1.25))
		button("Ręka",func():
			for i in travel_apples: items.append("Jabłko")
			go_to("stable",4,marks))
		say("travel_apples")
	else:
		button("Dalej",advance)
		say("stable_go")
	transition_time=(host.narrator.stream.get_length() if host.sound and host.narrator.stream else 2.0)+.4

func count_pen(i:int) -> void:
	if host.paused or not active or marks & (1<<i): return
	var home:=id()=="stable_home"
	if not ((home and part==0) or (id()=="stable" and part==1 and (stable.empty_mask & (1<<i)) != 0)): return
	marks|=1<<i
	checkpoint()
	var total:=0
	for bit in 5:
		if marks & (1<<bit): total+=1
	stable.set_pens(home,marks,true)
	if host.sound: host.play_clip(host.narrator,"count_%d"%total)
	if marks==(stable.FULL_MASK if home else stable.empty_mask):
		age=0
		transition_time=1.1

func stable_answer(n:int) -> void:
	if n!=pony_count():
		if hint_errors==0: effect("story/again")
		hint_miss(pony_count(),stable.highlight_empty)
		return
	go_to("stable",2,marks)

func stable_tick() -> void:
	if id()=="stable" and part==0: curtain.color.a=.88*(1-smoothstep(.4,transition_time,age))
	if age<transition_time: return
	if id()=="stable":
		if part==0: go_to("stable",1)
		elif part==1 and marks==stable.empty_mask and options.get_child_count()==1: render()
		elif part==1 and marks==0 and voice=="route_stable": say("empty_pens")
		elif part==2: go_to("stable",3,marks)
	elif part==0 and marks==stable.FULL_MASK: go_to("stable_home",1,marks)
	elif part==1:
		chapters=2
		checkpoint(true)
		host.home()

func advance() -> void:
	if id()=="troll_dawn": stone_hill.show()
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
	elif id() in ["cross","night_bridge"]: advance()

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
	if id()=="dragon_orchard":
		if part<2: iskierka.walk(dt)
		return
	if hint_lit<hint_total:
		hint_delay-=dt
		if hint_delay<=0:
			hint_lit+=1
			hint_display.call(hint_lit)
			effect("count_%d"%hint_lit)
			hint_delay=.85
	if id()=="chief_happy" and part==2:
		return_trip.tick(dt)
		return
	if id()=="troll_dawn":
		dawn.tick(dt)
		return
	if id()=="fork":
		if part!=2: fork_trail.tick(dt)
		return
	if id()=="night_bridge":
		waving_paw.rotation.z=.25+.6*sin(age*6)
		var target:Vector3=host.leo.global_position+Vector3(.85,0,.55)
		visitor.global_position=visitor.global_position.move_toward(target,4.5*dt)
		return
	if id()=="chief_sad":
		if age>=transition_time:
			if part==0: go_to("chief_sad",1)
			elif part==1 and marks==travel_apples: go_to("chief_sad",2)
			elif part==1 and marks>0:
				options.get_child(0).disabled=false
		return
	if id()=="homecoming" and part==1:
		curtain.color.a=clampf(age/.65,0,1)
		if age>=.65: advance()
		return
	if id() in ["stable","stable_home"]:
		stable_tick()
		return
	if cooldown>0:
		cooldown-=dt
		host.cottage.sword.rotation.y=lerpf(1.1,-1.1,1-cooldown/.36)
		arc.rotation.y=lerpf(.48,-.48,1-cooldown/.36)
		arc.scale.x=.8+.2*sin(PI*cooldown/.36)
		if cooldown<=0:
			arc.hide()
			host.cottage.sword.hide()
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
				if blocking and marks==0:
					marks=1
					checkpoint()
					say("guard_side")
				elif not blocking:
					var push:Vector3=(host.leo.position-foe.global_position).normalized()
					host.leo.position+=push*.95
		var offset:Vector3=host.leo.position-foe.global_position
		if marks==1 and offset.length()<1.88 and (absf(offset.x)>absf(offset.z) or offset.z<0):
			marks=2
			checkpoint()
			say("guard_sword")

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
	if id()=="fork":
		go_to("fork",1)
		return
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
	if n!=numbers.get("lamps",5):
		if hint_errors==0: square.show_lamps(n)
		hint_miss(numbers.get("lamps",5),square.show_lamps)
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
		field.begin(self,"pine",part)
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
