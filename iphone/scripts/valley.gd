extends Node3D

enum State { HOME, WALK, STORY, MATH, FIGHT, INSIDE, END }
var state := State.HOME
var stage := 0
var best := 0
var stars := 0
var sound := true
var paused := false
var targets: Array[Vector3] = []
var answer := 0
var step_time := 0.0
const BridgeRepair := preload("res://scripts/bridge_repair.gd")
var groups := Vector2i(2,3)
var apples: Array[Node3D] = []
var boards: Array[Node3D] = []
var lanterns: Array[Node3D] = []
var stones: Array[Node3D] = []
var trail_marks: Array[Node3D] = []
var limbs: Array[Node3D] = []
var leo: Node3D
var camera := Camera3D.new()
var marker := Node3D.new()
var ui := Control.new()
var panel := VBoxContainer.new()
var overlay := ColorRect.new()
var hud := Label.new()
var cottage := preload("res://scripts/cottage.gd").new()
var action_button: Button
var pause_button := Button.new()
var stick = preload("res://scripts/stick.gd").new()
var bystra := preload("res://scripts/river_story.gd").new()
var beaver := Node3D.new()
var atlas := preload("res://scripts/atlas.gd").new()
var narrator := AudioStreamPlayer.new()
var chime := AudioStreamPlayer.new()
const Icons := preload("res://scripts/river_icons.gd")
const VOICE_CLIPS := {
	"Jesteśmy w chatce. Połóż jabłka na stole.": "inside",
	"Orkowie uciekli! Podejdź do okrągłych drzwi": "door",
	"Orkowie na ścieżce! Dotknij miecza, żeby ich przepłoszyć.": "orcs",
	"Zanieś jabłka do chatki": "deliver",
	"W wiosce zapada zmrok. Pomóż mi policzyć latarenki, żebyśmy mogli je zapalić!": "fox",
	"Przejdź przez most": "crossing",
	"Przejdź po kamieniach": "stones",
	"Wejdź do wioski": "village",
	"Zbierz trzy jabłka na placek": "apples",
	"Ile desek potrzeba na most?": "planks",
	"Ile jest razem latarenek?": "lanterns",
	"Spójrz jeszcze raz i policz.": "retry",
	"Brawo! Hobbici zapraszają Leo na placek z jabłkami.": "feast",
}
var hint: Label
var save := ConfigFile.new()

func route(z: float) -> float: return 1.45*sin(z*.102)+.6*sin(z*.173)
func point(z: float, x := 0.0) -> Vector3: return Vector3(route(z)+x,0,z)

func mesh(parent: Node3D, shape: Mesh, pos: Vector3, color: Color, glow := false) -> MeshInstance3D:
	var obj := MeshInstance3D.new()
	obj.mesh = shape
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = .79
	if glow:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 1.4
	obj.material_override = mat
	parent.add_child(obj)
	obj.position = pos
	return obj

func box(parent: Node3D,pos: Vector3, extent: Vector3, color: Color) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = extent
	return mesh(parent,shape,pos,color)

func orb(parent: Node3D,pos: Vector3,r: float,color: Color,glow := false) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = r
	shape.height = 2*r
	shape.radial_segments = 12
	shape.rings = 6
	return mesh(parent,shape,pos,color,glow)

func _ready() -> void:
	save.load("user://valley.cfg")
	best = int(save.get_value("valley","stars",0))
	sound = bool(save.get_value("valley","sound",true))
	var landscape := preload("res://art/valley.glb").instantiate()
	add_child(landscape)
	var terrain_material := ShaderMaterial.new()
	terrain_material.shader = preload("res://art/valley.gdshader")
	var surfaces = landscape.find_children("*","MeshInstance3D",true,false)
	if landscape is MeshInstance3D: surfaces.append(landscape)
	for surface in surfaces: surface.material_override = terrain_material
	leo = preload("res://art/leo.glb").instantiate()
	add_child(leo)
	for id in ["Leg0","Leg1","Arm0","Arm1"]:
		var limb = leo.find_child(id,true,false)
		if limb: limbs.append(limb)
	atmosphere()
	populate()
	add_child(cottage)
	cottage.build(self)
	add_child(camera)
	camera.fov = 54
	add_child(marker)
	var ring := TorusMesh.new()
	ring.inner_radius = .56
	ring.outer_radius = .7
	mesh(marker,ring,Vector3.ZERO,Color("#ffc73d"),true)
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(ui)
	add_child(narrator)
	add_child(chime)
	ui.add_child(atlas)
	atlas.play_requested.connect(open_story)
	atlas.resume_requested.connect(func(): bystra.begin(true))
	atlas.classic_requested.connect(start)
	atlas.camp_requested.connect(func():
		var camp:=preload("res://scripts/troll_camp.gd").new()
		add_child(camp)
		camp.begin(self))
	atlas.sound_requested.connect(toggle_sound)
	atlas.exit_requested.connect(exit_game)
	ui.add_child(hud)
	hud.add_theme_stylebox_override("normal",plate(Color("#1a2c40df")))
	pause_button.add_theme_stylebox_override("normal",plate(Color("#1a2c40e8")))
	hud.add_theme_font_size_override("font_size",23)
	hud.add_theme_constant_override("outline_size",0)
	ui.add_child(stick)
	stick.size = Vector2(136,136)
	ui.add_child(pause_button)
	pause_button.text = "Pauza"
	pause_button.custom_minimum_size = Vector2(96,50)
	pause_button.pressed.connect(pause_game)
	action_button = button(ui,"Miecz",act)
	action_button.hide()
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color("#0c192baf")
	var center := CenterContainer.new()
	overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#203146f5")
	style.set_corner_radius_all(22)
	for side in [SIDE_LEFT,SIDE_RIGHT,SIDE_TOP,SIDE_BOTTOM]: style.set_content_margin(side,18)
	card.add_theme_stylebox_override("panel",style)
	center.add_child(card)
	card.add_child(panel)
	panel.add_theme_constant_override("separation",9)
	add_child(bystra)
	bystra.setup(self)
	ui.resized.connect(layout)
	layout()
	home()

func layout() -> void:
	var inset := Vector2(22,16)
	if OS.get_name()=="iOS":
		var display := Vector2(DisplayServer.screen_get_size())
		var safe := DisplayServer.get_display_safe_area()
		if display.x>0 and display.y>0:
			inset += Vector2(maxi(safe.position.x,int(display.x)-safe.end.x),maxi(safe.position.y,int(display.y)-safe.end.y))*ui.size/display
	if action_button:
		action_button.position = ui.size-inset-action_button.size
	atlas.set_insets(inset)
	hud.position = inset
	stick.position = Vector2(inset.x,ui.size.y-inset.y-136)
	pause_button.position = Vector2(ui.size.x-inset.x-96,inset.y)

func atmosphere() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("#4593c2")
	sky_mat.sky_horizon_color = Color("#ecddae")
	sky.sky_material = sky_mat
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = .68
	env.fog_enabled = true
	env.fog_light_color = Color("#c8d9c1")
	env.fog_density = .006
	env.fog_sky_affect = .16
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45,-32,0)
	sun.light_color = Color("#ffebc7")
	sun.light_energy = 1.05
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 43
	add_child(sun)

func populate() -> void:
	# The bridge builder waits on the bank with the rolled plan.
	add_child(beaver)
	beaver.position=point(.75,-2.45)
	beaver.rotation.y=.58
	var tail := orb(beaver,Vector3(-.25,.17,-.57),.55,Color("#70432e"))
	tail.scale=Vector3(.64,.24,1.52)
	orb(beaver,Vector3(0,.55,0),.5,Color("#a56a3b")).scale=Vector3(.86,1.13,.86)
	orb(beaver,Vector3(0,1.17,.08),.43,Color("#b37a46"))
	for side in [-1,1]:
		orb(beaver,Vector3(side*.3,1.48,.08),.13,Color("#89542f"))
		orb(beaver,Vector3(side*.19,1.23,.44),.056,Color("#25272b"))
		orb(beaver,Vector3(side*.12,1.04,.45),.15,Color("#dab887"))
		box(beaver,Vector3(side*.048,.94,.54),Vector3(.085,.14,.065),Color("#fff1c9"))
		orb(beaver,Vector3(side*.32,.68,.28),.15,Color("#8e582f"))
	orb(beaver,Vector3(0,1.13,.55),.095,Color("#493327"))
	var plan := box(beaver,Vector3(0,.66,.4),Vector3(.59,.04,.36),Color("#b4d7db"))
	plan.rotation.x=.27
	# Two banks of flowers and windblown grass are drawn in one instanced meadow.
	var grass := QuadMesh.new()
	grass.size = Vector2(.45,.56)
	var material := ShaderMaterial.new()
	material.shader = preload("res://art/meadow.gdshader")
	grass.material = material
	var meadow := MultiMesh.new()
	meadow.transform_format = MultiMesh.TRANSFORM_3D
	meadow.mesh = grass
	meadow.instance_count = 2200
	var rng := RandomNumberGenerator.new()
	rng.seed = 7285
	for i in meadow.instance_count:
		var z := rng.randf_range(-55,14)
		if absf(z+2)<2.4: z-=5.0
		var x := route(z)+rng.randf_range(2.7,11)*(1 if i%2 else -1)
		meadow.set_instance_transform(i,Transform3D(Basis(Vector3.UP,rng.randf_range(-1.3,1.3)),Vector3(x,.26,z)))
	var field := MultiMeshInstance3D.new()
	field.multimesh = meadow
	field.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(field)
	# Small pockets of gold and violet blossoms cluster along both banks.
	var blossom := SphereMesh.new()
	blossom.radius=.105
	blossom.height=.13
	blossom.radial_segments=6
	blossom.rings=2
	var petals := StandardMaterial3D.new()
	petals.vertex_color_use_as_albedo=true
	blossom.material=petals
	var flowers := MultiMesh.new()
	flowers.transform_format=MultiMesh.TRANSFORM_3D
	flowers.use_colors=true
	flowers.mesh=blossom
	flowers.instance_count=720
	for patch in 60:
		var z := rng.randf_range(-51,13)
		if absf(z+2)<2.8: z-=6.0
		var center := point(z,rng.randf_range(2.1,5.5)*(1 if patch%2 else -1))
		for j in 12:
			var pos := center+Vector3(rng.randf_range(-.65,.65),rng.randf_range(.15,.29),rng.randf_range(-.55,.55))
			flowers.set_instance_transform(patch*12+j,Transform3D(Basis.IDENTITY,pos))
			flowers.set_instance_color(patch*12+j,[Color("#ffd953"),Color("#eeb4ff"),Color("#ffe7ae")][patch%3])
	var bloom := MultiMeshInstance3D.new()
	bloom.multimesh=flowers
	bloom.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(bloom)
	var water := PlaneMesh.new()
	water.size = Vector2(56,3.35)
	var stream := MeshInstance3D.new()
	stream.mesh = water
	stream.position = Vector3(0,.09,-2)
	var ripple := ShaderMaterial.new()
	ripple.shader = preload("res://art/stream.gdshader")
	stream.material_override = ripple
	add_child(stream)
	for i in 6:
		var pos := point(-7.0-(i+1)*11.0/6,1.35*sin((i+1)*PI/3))
		var stone := orb(self,pos+Vector3.UP*.08,.65,Color("#b7af8e"))
		stone.scale.y = .32
		stones.append(stone)
		var previous := point(-7) if i==0 else stones[i-1].position
		var segment := pos-previous
		var rail := box(self,(pos+previous)*.5+Vector3.UP*.15,Vector3(.12,.055,segment.length()),Color("#ffcd52"))
		rail.rotation.y=atan2(segment.x,segment.z)
		trail_marks.append(rail)
	for side in [-1,1]:
		box(self,point(-24,2.05*side)+Vector3.UP*1.55,Vector3(.35,3.1,.35),Color("#875b36"))
	box(self,point(-24)+Vector3.UP*3.1,Vector3(4.5,.32,.45),Color("#b98852"))
	for i in 3:
		var fruit := Node3D.new()
		add_child(fruit)
		fruit.position = point(-34-i*4,[1.6,-1.5,0][i])+Vector3.UP*.64
		orb(fruit,Vector3.ZERO,.44,Color("#eb4228"))
		box(fruit,Vector3(.03,.47,0),Vector3(.08,.27,.08),Color("#684127"))
		orb(fruit,Vector3(.18,.5,0),.17,Color("#85bc38")).scale.y=.45
		apples.append(fruit)

func clear_panel() -> void:
	for child in panel.get_children():
		panel.remove_child(child)
		child.queue_free()
	overlay.show()

func label_line(text: String, pixels: int) -> Label:
	var item := Label.new()
	item.text = text
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item.add_theme_font_size_override("font_size",pixels)
	panel.add_child(item)
	return item

func plate(color:Color) -> StyleBoxFlat:
	var style:=StyleBoxFlat.new()
	style.bg_color=color
	style.set_corner_radius_all(14)
	style.set_content_margin(SIDE_LEFT,16)
	style.set_content_margin(SIDE_RIGHT,16)
	style.set_content_margin(SIDE_TOP,7)
	style.set_content_margin(SIDE_BOTTOM,7)
	return style

func button(parent: Control, text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text=text
	b.add_theme_stylebox_override("normal",plate(Color("#efc666")))
	b.add_theme_color_override("font_color",Color("#382b15"))
	b.custom_minimum_size=Vector2(88,56)
	b.add_theme_font_size_override("font_size",24)
	parent.add_child(b)
	b.pressed.connect(action)
	return b

func say(text: String) -> void:
	if sound and VOICE_CLIPS.has(text):
		play_clip(narrator, VOICE_CLIPS[text])

func play_clip(player: AudioStreamPlayer, clip: String) -> void:
	var path := "res://audio/%s.mp3" % clip
	player.stream = AudioStreamMP3.load_from_file(path)
	player.play()

func toggle_sound() -> void:
	sound = not sound
	save.set_value("valley","sound",sound)
	save.save("user://valley.cfg")
	if sound:
		play_clip(chime,"chime")
	else:
		narrator.stop()
		chime.stop()
	atlas.update_status(best,sound)

func exit_game() -> void:
	narrator.stop()
	chime.stop()
	if OS.get_name()=="iOS":
		# The embedded iOS renderer ignores the quit result of Main::iteration().
		# Checkpoints are written synchronously before a new step opens.
		OS.kill(OS.get_process_id())
	else:
		get_tree().quit()

func open_story() -> void:
	if not bystra.saved:
		bystra.begin(false)
		return
	var confirm := ConfirmationDialog.new()
	confirm.title="Nowa wyprawa"
	confirm.dialog_text="Zacząć od norki Bilba i zastąpić zapis tej wyprawy?"
	confirm.ok_button_text="Zacznij od nowa"
	confirm.cancel_button_text="Wróć"
	ui.add_child(confirm)
	confirm.confirmed.connect(func(): confirm.queue_free(); bystra.begin(false))
	confirm.canceled.connect(confirm.queue_free)
	confirm.popup_centered()

func home() -> void:
	bystra.stop()
	atlas.can_resume=bystra.saved
	cottage.reset()
	action_button.hide()
	state=State.HOME
	paused=false
	narrator.stop()
	stick.reset()
	stick.hide()
	pause_button.hide()
	hud.hide()
	overlay.hide()
	atlas.select_world(0)
	atlas.update_status(best,sound)
	atlas.show()

func prepare_valley() -> void:
	cottage.reset()
	action_button.hide()
	stage=0
	stars=0
	groups=Vector2i(randi_range(1,3+mini(best,3)),randi_range(1,4+mini(best,3)))
	for item in boards+lanterns: item.queue_free()
	boards.clear()
	lanterns.clear()
	for fruit in apples: fruit.show()
	for mark in trail_marks: mark.hide()
	for i in BridgeRepair.SPANS:
		var plank := box(self,point(-2)+Vector3(0,.23,1.76-(i+.5)*3.52/BridgeRepair.SPANS),Vector3(4.1,.2,3.4/BridgeRepair.SPANS),Color("#c39760"))
		boards.append(plank)
		plank.hide()
	for i in groups.x+groups.y:
		var side := -1 if i<groups.x else 1
		var rank := i if side<0 else i-groups.x
		var p := point(-24+rank*.82,side*2.1)+Vector3.UP*1.5
		box_lantern(p)

func start() -> void:
	prepare_valley()
	leo.position=point(9)
	camera.position=leo.position+Vector3(0,3.05,5.9)
	atlas.hide()
	if sound: play_clip(chime,"chime")
	hud.show()
	pause_button.show()
	walk([point(4)],"Podejdź do mostu")

func box_lantern(pos: Vector3) -> void:
	var lamp := orb(self,pos,.22,Color("#ffd56a"),true)
	lanterns.append(lamp)
	lamp.hide()

func walk(points: Array, objective: String) -> void:
	state=State.WALK
	targets.assign(points)
	overlay.hide()
	stick.reset()
	stick.show()
	hud.text="★ %d/4   %s"%[stars,objective]
	say(objective)
	move_marker()

func move_marker() -> void:
	marker.position=targets[0]+Vector3.UP*.39
	marker.visible=true

func give_star() -> void:
	if sound: play_clip(chime,"chime")
	stars+=1
	best=maxi(best,stars)
	save.set_value("valley","stars",best)
	save.save("user://valley.cfg")

func arrive() -> void:
	if bystra.active:
		bystra.arrived()
		return
	if stage==4: apples[3-targets.size()].hide()
	targets.pop_front()
	if not targets.is_empty():
		move_marker()
		return
	marker.hide()
	match stage:
		0: repair_bridge()
		2: fox_intro()
		1:
			stage=2
			for mark in trail_marks: mark.show()
			var path: Array=[]
			for item in stones: path.append(item.position)
			walk(path,"Przejdź po kamieniach")
		3:
			stage=4
			var fruit_path:Array=[]
			for fruit in apples: fruit_path.append(fruit.position)
			walk(fruit_path,"Zbierz trzy jabłka na placek")
		4:
			give_star()
			stage=5
			walk([point(-46)],"Zanieś jabłka do chatki")
		5:
			state=State.FIGHT
			stick.hide()
			cottage.ambush()
			set_action("Machnij mieczem")
			hud.text="Przepłosz orków!"
			say("Orkowie na ścieżce! Dotknij miecza, żeby ich przepłoszyć.")
		6:
			state=State.INSIDE
			stick.hide()
			cottage.enter()
			hud.text="Chatka hobbitów"
			set_action("Połóż jabłka na stole")
			say("Jesteśmy w chatce. Połóż jabłka na stole.")

func set_action(text: String) -> void:
	Icons.apply(action_button,text)
	action_button.disabled=false
	action_button.reset_size()
	action_button.show()
	layout()

func act() -> void:
	if paused or action_button.disabled: return
	if state==State.INSIDE:
		cottage.basket.show()
		state=State.END
		pause_button.hide()
		hud.text="Placek dla całej doliny!   ★ %d/4" % stars
		set_action("Ekran startowy")
		say("Brawo! Hobbici zapraszają Leo na placek z jabłkami.")
	elif state==State.END:
		home()
	elif state==State.FIGHT:
		action_button.disabled=true
		cottage.strike()
		if sound: play_clip(chime,"swoosh")
		cottage.swing.finished.connect(strike_finished,CONNECT_ONE_SHOT)

func strike_finished() -> void:
	if state!=State.FIGHT: return
	if cottage.remaining>0:
		action_button.disabled=false
		return
	stage=6
	cottage.sword.hide()
	action_button.hide()
	walk([point(-50.7)],"Orkowie uciekli! Podejdź do okrągłych drzwi")

func fox_intro() -> void:
	state=State.STORY
	stick.reset()
	stick.hide()
	give_star()
	clear_panel()
	label_line("Lis przy bramie",30)
	label_line("W wiosce zapada zmrok. Pomóż mi policzyć latarenki,\nżebyśmy mogli je zapalić!",23)
	Icons.apply(button(panel,"Pomogę!",quiz),"Pomogę!")
	say("W wiosce zapada zmrok. Pomóż mi policzyć latarenki, żebyśmy mogli je zapalić!")

func repair_bridge() -> void:
	state=State.MATH
	stick.reset()
	stick.hide()
	clear_panel()
	label_line("Bóbr nad Bystrą Wodą",30)
	var repair := BridgeRepair.new()
	repair.voice.connect(func(clip):
		if sound: play_clip(narrator,clip))
	repair.hammer_hit.connect(func():
		if sound: play_clip(chime,"wood_tap"))
	repair.repaired.connect(func():
		if stage!=0 or state!=State.MATH: return
		for board in boards: board.show()
		give_star()
		stage=1
		walk([point(-7)],"Przejdź przez most"))
	panel.add_child(repair)

func quiz() -> void:
	if paused: return
	state=State.MATH
	stick.reset()
	stick.hide()
	clear_panel()
	var prompt := "Ile jest razem latarenek?"
	label_line("Brama wioski",20)
	label_line(prompt,30)
	var diagram = preload("res://scripts/diagram.gd").new()
	diagram.counts = groups
	diagram.custom_minimum_size=Vector2(720,180)
	panel.add_child(diagram)
	answer=groups.x+groups.y
	hint=label_line("Wybierz liczbę.",19)
	var row := HBoxContainer.new()
	row.alignment=BoxContainer.ALIGNMENT_CENTER
	panel.add_child(row)
	var picks := [answer]
	var distance := 1
	while picks.size()<4:
		for n in [answer-distance,answer+distance]:
			if n>=1 and n<=15 and picks.size()<4: picks.append(n)
		distance+=1
	picks.shuffle()
	for n in picks: Icons.apply(button(row,str(n),choose.bind(n)),str(n))
	var listen:=button(row,"Posłuchaj",say.bind(prompt))
	Icons.apply(listen,"Posłuchaj")
	say(prompt)

func choose(n:int) -> void:
	if state!=State.MATH or paused: return
	if n!=answer:
		hint.text="Spójrz jeszcze raz i policz."
		say(hint.text)
		return
	give_star()
	for lamp in lanterns: lamp.show()
	stage=3
	walk([point(-30)],"Wejdź do wioski")

func pause_game() -> void:
	if paused or state not in [State.WALK,State.STORY,State.MATH,State.FIGHT,State.INSIDE]: return
	paused=true
	if bystra.active:
		bystra.blocking=false
		bystra.show_controls()
		if bystra.busy: bystra.anim.pause()
	if state==State.FIGHT and cottage.swing: cottage.swing.pause()
	action_button.hide()
	stick.reset()
	stick.hide()
	pause_button.hide()
	# Keep the current puzzle and its random answer choices underneath the pause layer.
	var menu := AcceptDialog.new()
	menu.title="Przerwa w wyprawie"
	menu.dialog_text="Leo poczeka tutaj."
	menu.ok_button_text="Graj dalej"
	menu.add_button("Mapa",true,"map")
	menu.add_button("Wyjdź",true,"exit")
	ui.add_child(menu)
	var resume := func():
		menu.queue_free()
		paused=false
		if bystra.active and bystra.busy: bystra.anim.play()
		action_button.visible=state in [State.FIGHT,State.INSIDE]
		if state==State.FIGHT and cottage.swing and cottage.swing.is_valid(): cottage.swing.play()
		stick.visible=state==State.WALK
		if bystra.active: bystra.show_controls()
		pause_button.show()
	menu.confirmed.connect(resume)
	menu.canceled.connect(resume)
	menu.custom_action.connect(func(id):
		menu.queue_free()
		if id == "exit": exit_game()
		else: home())
	menu.popup_centered()

func _notification(what:int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready(): pause_game()

func _physics_process(dt:float) -> void:
	if state!=State.WALK or paused: return
	var motion:Vector2=stick.vector
	if motion.is_zero_approx():
		motion=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
		var pads := Input.get_connected_joypads()
		if motion.is_zero_approx() and not pads.is_empty():
			motion=Vector2(Input.get_joy_axis(pads[0],JOY_AXIS_LEFT_X),Input.get_joy_axis(pads[0],JOY_AXIS_LEFT_Y))
			if motion.length()<.18: motion=Vector2.ZERO
	motion=motion.limit_length(1)
	var to := targets[0]
	leo.position.z=clampf(leo.position.z+motion.y*dt*4.2,to.z-.65,10)
	leo.position.x=clampf(leo.position.x+motion.x*dt*4.2,route(leo.position.z)-3.7,route(leo.position.z)+3.7)
	leo.position.y=.31 if absf(leo.position.z+2)<1.9 else .19 if stage==2 else .035
	if motion.length()>.05:
		leo.rotation.y=lerp_angle(leo.rotation.y,atan2(-motion.x,-motion.y),1-exp(-12*dt))
		step_time+=dt*12*motion.length()
	for i in limbs.size():
		limbs[i].rotation.x=sin(step_time)*(1 if i in [0,3] else -1)*.48*motion.length()
	camera.position=camera.position.lerp(leo.position+Vector3(0,3.05,5.9),1-exp(-8*dt))
	camera.look_at(leo.position+Vector3(0,1.42,-1.8))
	if Vector2(leo.position.x-to.x,leo.position.z-to.z).length()<.86: arrive()
