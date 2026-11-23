extends Node3D

const Props := preload("res://scripts/river_props.gd")
const Icons := preload("res://scripts/river_icons.gd")
const BACK_TIME := 2.5
const TURN_TIME := 1.0
const LOOK_TIME := 2.5
const GRACE := 0.25
const HAY_RADIUS := 1.0
const PARK_DISTANCE := 1.55
const HIDE_TIME := .22
const FLY_TIME := 2.4
const WALK_SPEED := 3.0
const FOLLOW_DISTANCE := 1.0
const HAND_REACH := 1.5
const HOME_REACH := 1.6
const LIFT_TIME := 0.4
const RETURN_TIME := 1.1
const LIFT_HEIGHT := 1.7
const STAR_TIME := 1.25
const REACH_HEIGHT := .68
const STRIDE_RATE := 10.0
const ORIGIN := Vector3(500,0,0)
const START := Vector3(-.8,0,2)
const TOBO := Vector3(-2,0,2.6)
const STACKS := [Vector3(-.8,0,0),Vector3(.8,0,-6.4),Vector3(-.8,0,-12.8),
	Vector3(.8,0,-19.6),Vector3(-.8,0,-26.4),Vector3(.8,0,-32.8)]
const TETHER := Vector3(.8,0,-37)
const TREE := TETHER+Vector3(1.3,0,-.3)
const WATCH := TETHER+Vector3(-2.4,0,-1.3)
const FIRE := WATCH+Vector3(-1.7,0,-.7)
const X_LIMIT := 4.5
const Z_MIN := -38.0
const Z_MAX := 4.0
const CAMERA_OFFSET := Vector3(0,16,12)
const VIEW_HEIGHT := 21.0
const EXPOSURE := .55
const WORDS := {
	"intro_stolen":"Bilbo! Troll Gapa ukradł mojego kucyka!",
	"intro_there":"Tam jest! Przy ognisku trolla.",
	"intro_run":"Idź po kucyka. Kiedy Gapa się odwraca i liczy, biegnij!",
	"intro_hide":"Kiedy Gapa mówi „Hmm?”, wskocz do stogu siana. W stogu cię nie zobaczy!",
	"intro_first":"Wejdź do stogu.",
	"intro_safe":"Widzisz? Nie zobaczył cię!",
	"count":"Raz… dwa… trzy…",
	"turn":"Hmm? Kto tu łazi?",
	"caught":"Aha! Widzę cię! Wracaj do stogu!",
	"caught_again":"Znowu ty? Hi, hi!",
	"hint":"Kiedy Gapa mówi „Hmm?”, szybko do stogu!",
	"pony":"Dotknij dłoni. Odwiąż kucyka i daj mu siana.",
	"follow":"Kucyk idzie za tobą! Wracaj do Toba.",
	"done":"Jest! Mój kucyk! Dziękuję, Bilbo!"
}
enum Phase { INTRO, FIRST, DEMO_TURN, DEMO_LOOK, BACK, TURN, LOOK, CAUGHT, DONE }
var host
var phase := Phase.INTRO
var elapsed := 0.0
var stride := 0.0
var catches := 0
var following := false
var last_cover := START
var hero:Node3D
var original_pose:Transform3D
var gapa:Node3D
var pony := Node3D.new()
var rope:MeshInstance3D
var hay:MeshInstance3D
var stacks:Array[Node3D]=[]
var eyes:=Node3D.new()
var flood:=DirectionalLight3D.new()
var beacon:=TextureRect.new()
var rustle:=AudioStreamPlayer.new()
var ground:=START
var inside:=-1
var dip:=0.0
var rustle_left:=0.0
var park_at:=Vector3.ZERO
var cap:=Node3D.new()
var intro_step:=0
const INTRO := ["intro_stolen","intro_there","intro_run","intro_hide"]

var camera := Camera3D.new()
var controls := Control.new()
var hand:Button
var replay:Button
var back:Button
var star := Label.new()
var caption := Label.new()
var cue := AudioStreamPlayer.new()
var message := "intro_stolen"
var speech_left := 0.0
var hint_pending := false
var near_pony := false
var finish_time := 0.0
var catch_from:Vector3
var pony_from:Vector3

func begin(game) -> void:
	host=game
	position=ORIGIN
	hero=host.leo
	original_pose=hero.transform
	hero.global_position=to_global(START)
	host.atlas.hide()
	host.stick.reset()
	host.stick.show()
	build_camp()
	add_child(camera)
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.size=VIEW_HEIGHT
	frame_path(START)
	var night:=CameraAttributesPractical.new()
	night.exposure_multiplier=EXPOSURE
	camera.attributes=night
	var sky:=Environment.new()
	sky.background_mode=Environment.BG_COLOR
	sky.background_color=Color("#142643")
	sky.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	sky.ambient_light_color=Color("#a0bfea")
	sky.ambient_light_energy=.85
	camera.environment=sky
	camera.make_current()
	add_child(cue)
	build_controls()
	back.disabled=true
	add_child(rustle)
	rustle.stream=AudioStreamMP3.load_from_file("res://audio/story/camp_rustle.mp3")
	var hat:=CylinderMesh.new()
	hat.top_radius=.06
	hat.bottom_radius=.35
	hat.height=.42
	hero.add_child(cap)
	host.mesh(cap,hat,Vector3.UP*1.69,Color("#ae6540"))
	speak(INTRO[0])

func troll(at:Vector3, amount:float) -> Node3D:
	var actor:=Props.new()
	add_child(actor)
	actor.setup(host)
	actor.build("troll")
	actor.position=at
	actor.scale=Vector3.ONE*amount
	return actor

func build_camp() -> void:
	host.box(self,Vector3(0,-.23,-19),Vector3(42,.44,68),Color("#36554f"))
	# Ciemna linia lasu obramowuje jaśniejszą, grywalną polanę.
	for side in [-1,1]:
		for z in range(-47,10,3):
			var edge:=Vector3(side*(6.8+.45*cos(z)),0,z)
			host.box(self,edge+Vector3.UP,Vector3(.38,2,.42),Color("#654a43"))
			host.orb(self,edge+Vector3.UP*2.2,1.25,Color("#274c4d")).scale.y=1.35
	var previous:=START
	for at:Vector3 in STACKS:
		path_to(previous,at)
		add_stack(at)
		previous=at
	path_to(previous,TETHER)
	var tobo:=troll(TOBO,.86)
	for i in 3:
		host.box(tobo,Vector3(-.55,.85+i*.12,0),Vector3(.32,.1,1.35),Color("#bb905e"))
	gapa=troll(WATCH,1.35)
	gapa.rotation.y=PI
	gapa.add_child(eyes)
	for side in [-1,1]:
		host.orb(eyes,Vector3(side*.19,1.44,.51),.085,Color("#ff9a36"),true)
	add_child(flood)
	flood.rotation_degrees=Vector3(-68,15,0)
	flood.light_color=Color("#ff842e")
	flood.light_energy=3.8
	watching(false)
	var gold:=Color("#ffbe5b")
	host.orb(gapa,Vector3(.6,1,.36),.24,gold,true)
	host.box(gapa,Vector3(.6,1.24,.36),Vector3(.35,.1,.35),Color("#665343"))
	for side in [-1,1]:
		host.box(self,FIRE+Vector3(0,.15,0),Vector3(1.3,.2,.22),Color.SADDLE_BROWN).rotation.y=side*.65
		host.orb(self,FIRE+Vector3(side*.23,.39,0),.34,gold,true).scale.y=1.6
	host.orb(self,FIRE+Vector3.UP*.96,.52,Color("#464659")).scale.y=.73
	var rim:=TorusMesh.new()
	rim.inner_radius=.37
	rim.outer_radius=.47
	host.mesh(self,rim,FIRE+Vector3.UP*1.18,Color("#818191"))
	host.orb(self,FIRE+Vector3.UP*1.18,.39,Color("#9c8055")).scale.y=.10
	var light:=OmniLight3D.new()
	add_child(light)
	light.position=FIRE+Vector3.UP*1.4
	light.light_color=gold
	light.light_energy=3
	light.omni_range=8
	host.box(self,TREE+Vector3.UP,Vector3(.48,2,.48),Color("#97724c"))
	host.box(self,TREE+Vector3(.34,1.64,0),Vector3(.95,.18,.23),Color("#97724c")).rotation.z=.45
	add_child(pony)
	pony.position=TETHER
	pony.rotation.y=-1.1
	var coat:=Color("#cb945c")
	host.orb(pony,Vector3(0,.67,0),.52,coat).scale=Vector3(.74,.86,1.28)
	host.orb(pony,Vector3(0,1.12,.43),.36,coat)
	host.orb(pony,Vector3(0,1.08,.24),.21,Color("#805039")).scale.y=1.72
	host.orb(pony,Vector3(0,1,.66),.24,Color("#efd8af"))
	host.orb(pony,Vector3(0,.58,-.64),.19,Color("#78523e")).scale.y=1.6
	for side in [-1,1]:
		host.orb(pony,Vector3(side*.18,1.46,.40),.105,coat).scale.y=1.8
		host.orb(pony,Vector3(side*.26,1.2,.59),.045,Color("#211e21"))
		for z in [-.35,.35]:
			host.box(pony,Vector3(side*.22,.25,z),Vector3(.15,.5,.16),coat.darkened(.18))
	var tie:=TREE-TETHER
	rope=host.box(self,(TREE+TETHER)*.5+Vector3.UP*.74,Vector3(.055,.055,tie.length()),Color.WHEAT)
	rope.rotation.y=atan2(tie.x,tie.z)
	hay=host.box(self,TETHER+Vector3(0,.17,.75),Vector3(.5,.33,.44),gold)
	hay.hide()

func path_to(a:Vector3,b:Vector3) -> void:
	var strip:MeshInstance3D=host.box(self,(a+b)*.5,Vector3(2.35,.035,a.distance_to(b)+.3),Color("#927554"))
	strip.rotation.y=atan2(b.x-a.x,b.z-a.z)

func add_stack(at:Vector3) -> void:
	var stack:=Node3D.new()
	add_child(stack)
	stack.position=at
	stacks.append(stack)
	var bale:=CylinderMesh.new()
	bale.bottom_radius=HAY_RADIUS
	bale.top_radius=HAY_RADIUS
	bale.height=.95
	var straw:=Color("#f2be4b")
	host.mesh(stack,bale,Vector3.UP*.48,straw)
	host.orb(stack,Vector3.UP*.96,HAY_RADIUS,straw.lightened(.12)).scale.y=.38
	for i in 22:
		var angle:=TAU*i/22
		var stalk:MeshInstance3D=host.box(stack,Vector3(sin(angle)*.94,.78,cos(angle)*.94),Vector3(.035,1.05,.035),Color("#ffdf84"))
		stalk.rotation.z=.16*sin(angle)
		stalk.rotation.x=.16*cos(angle)

func watching(enabled:bool) -> void:
	eyes.visible=enabled
	flood.visible=enabled
	beacon.modulate=Color("#ff933c") if enabled else Color("#ffe6a4")

func frame_path(at:Vector3) -> void:
	var focus:=Vector3(at.x*.3,.6,at.z)
	camera.look_at_from_position(to_global(focus+CAMERA_OFFSET),to_global(focus))

func build_controls() -> void:
	host.ui.add_child(controls)
	controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	controls.mouse_filter=Control.MOUSE_FILTER_IGNORE
	hand=host.button(controls,"Ręka",untie)
	Icons.apply(hand,"Ręka")
	hand.disabled=true
	replay=host.button(controls,"Posłuchaj",func(): speak(message))
	Icons.apply(replay,"Posłuchaj")
	back=host.button(controls,"Wróć do mapy",leave)
	Icons.apply(back,"Wróć do mapy")
	controls.add_child(caption)
	caption.add_theme_stylebox_override("normal",host.plate(Color("#162535ed")))
	caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_size_override("font_size",21)
	controls.add_child(beacon)
	# Pokazuje światło rzeczywistej latarni przy krawędzi ekranu, gdy Gapa jest poza kadrem.
	var gradient:=Gradient.new()
	gradient.colors=PackedColorArray([Color.WHITE,Color(1,.72,.24,.75),Color(1,.5,.15,0)])
	var glow:=GradientTexture2D.new()
	glow.gradient=gradient
	glow.fill=GradientTexture2D.FILL_RADIAL
	glow.fill_from=Vector2(.5,.5)
	glow.fill_to=Vector2(1,.5)
	beacon.texture=glow
	beacon.mouse_filter=Control.MOUSE_FILTER_IGNORE
	controls.add_child(star)
	star.text="★"
	star.modulate=Color.GOLD
	star.add_theme_font_size_override("font_size",96)
	star.hide()
	layout()
	controls.resized.connect(layout,CONNECT_DEFERRED)

func layout() -> void:
	var inset:Vector2=host.hud.position
	back.position=inset
	replay.position=Vector2(controls.size.x-inset.x-replay.size.x,inset.y)
	hand.position=controls.size-inset-hand.size
	caption.position=Vector2(host.stick.position.x+host.stick.size.x+8,controls.size.y-inset.y-back.size.y)
	caption.size=Vector2(hand.position.x-caption.position.x-8,back.size.y)
	star.position=(controls.size-star.get_minimum_size())*.5

func speak(key:String) -> void:
	message=key
	caption.text=WORDS[key]
	cue.stop()
	if host.sound:
		host.play_clip(host.narrator,"story/camp_"+key)
		speech_left=host.narrator.stream.get_length()
	else:
		speech_left=2.5 if phase==Phase.INTRO or phase==Phase.DEMO_LOOK else 0.0

func cycle_voice(key:String) -> void:
	if host.sound:
		cue.volume_db=-12 if speech_left>0 else 0
		host.play_clip(cue,"story/camp_"+key)

func begin_back() -> void:
	phase=Phase.BACK
	elapsed=0
	watching(false)
	gapa.position=WATCH
	gapa.rotation.y=PI
	cycle_voice("count")

func cover(at:Vector3) -> int:
	for i in STACKS.size():
		if at.distance_to(STACKS[i])<=HAY_RADIUS: return i
	return -1

func show_cover(dt:float) -> void:
	var next:=cover(ground)
	if next!=inside:
		inside=next
		if inside>=0:
			last_cover=STACKS[inside]
			rustle_left=HIDE_TIME*2
			if host.sound: rustle.play()
			var approach:=pony.position-last_cover
			if approach.is_zero_approx(): approach=Vector3.BACK
			park_at=last_cover+approach.normalized()*PARK_DISTANCE
	dip=move_toward(dip,1 if inside>=0 else 0,dt/HIDE_TIME)
	var visual:=ground.lerp(last_cover,dip)
	visual.y=-.42*dip+.24*sin(PI*dip)
	hero.global_position=to_global(visual)
	rustle_left=maxf(0,rustle_left-dt)
	for i in stacks.size():
		stacks[i].rotation.z=.075*sin(rustle_left*48) if i==inside and rustle_left>0 else 0
		stacks[i].scale=Vector3.ONE*(1+.05*sin(elapsed*4)) if phase==Phase.FIRST and i==0 else Vector3.ONE

func introduction() -> void:
	var t:=smoothstep(0,1,minf(1,elapsed/FLY_TIME))
	if intro_step==1: frame_path(START.lerp(TETHER,t))
	elif intro_step==2:
		frame_path(TETHER.lerp(START,t))
		if elapsed>=FLY_TIME and message=="intro_there":
			speak("intro_run")
			return
	if speech_left>0 or (intro_step in [1,2] and elapsed<FLY_TIME): return
	elapsed=0
	intro_step+=1
	if intro_step==INTRO.size():
		phase=Phase.FIRST
		host.stick.reset()
		speak("intro_first")
	elif intro_step!=2: speak(INTRO[intro_step])

func untie() -> void:
	if following or phase not in [Phase.BACK,Phase.TURN,Phase.LOOK]: return
	if ground.distance_to(TETHER)>HAND_REACH: return
	following=true
	rope.hide()
	hay.show()
	hand.disabled=true
	hand.modulate=Color.WHITE
	speak("follow")

func caught(at:Vector3) -> void:
	phase=Phase.CAUGHT
	catches+=1
	if catches==2: hint_pending=true
	catch_from=at
	pony_from=pony.position
	elapsed=0
	hand.disabled=true
	watching(false)
	speak("caught" if catches%2 else "caught_again")

func recover() -> void:
	var lift:=catch_from+Vector3.UP*LIFT_HEIGHT
	var t:=clampf(elapsed/LIFT_TIME,0,1)
	var slide:=smoothstep(0,1,clampf((elapsed-LIFT_TIME)/RETURN_TIME,0,1))
	hero.global_position=to_global(catch_from.lerp(lift,sin(t*PI*.5)).lerp(last_cover,slide))
	# Gapa wyciąga łapę pod Bilba, a potem odstawia go do siana.
	var reach:=catch_from+Vector3.FORWARD*REACH_HEIGHT
	gapa.position=WATCH.lerp(reach,sin(t*PI*.5)).lerp(WATCH,slide)
	gapa.rotation.z=.22*sin(t*PI)
	hero.rotation.z=.3*sin(t*PI)
	if following: pony.position=pony_from.lerp(last_cover+Vector3.BACK*PARK_DISTANCE,slide)
	if elapsed>=LIFT_TIME+RETURN_TIME:
		ground=last_cover
		host.stick.reset()
		begin_back()

func _physics_process(dt:float) -> void:
	if not host or is_queued_for_deletion(): return
	elapsed+=dt
	speech_left=maxf(0,speech_left-dt)
	if phase==Phase.INTRO:
		introduction()
		return
	if phase==Phase.DEMO_TURN or phase==Phase.DEMO_LOOK:
		show_cover(dt)
		if phase==Phase.DEMO_TURN:
			gapa.rotation.y=lerpf(PI,0,minf(1,elapsed/TURN_TIME))
			if elapsed>=TURN_TIME:
				phase=Phase.DEMO_LOOK
				elapsed=0
				watching(true)
				speak("intro_safe")
		elif elapsed>=LOOK_TIME and speech_left<=0:
			back.disabled=false
			begin_back()
		return
	if phase==Phase.CAUGHT:
		recover()
		frame_path(to_local(hero.global_position))
		return
	if phase==Phase.DONE:
		star.visible=speech_left<=0
		if elapsed>=finish_time: leave()
		return
	if hint_pending and speech_left<=0:
		hint_pending=false
		speak("hint")
	match phase:
		Phase.BACK:
			if elapsed>=BACK_TIME:
				phase=Phase.TURN
				elapsed=0
				cycle_voice("turn")
		Phase.TURN:
			gapa.rotation.y=lerpf(PI,0,minf(1,elapsed/TURN_TIME))
			if elapsed>=TURN_TIME:
				phase=Phase.LOOK
				elapsed=0
				watching(true)
		Phase.LOOK:
			if elapsed>=LOOK_TIME: begin_back()
	var motion:Vector2=host.stick.vector
	if motion.is_zero_approx(): motion=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var at:=ground
	var moving:=not motion.is_zero_approx()
	if moving:
		at.x=clampf(at.x+motion.x*WALK_SPEED*dt,-X_LIMIT,X_LIMIT)
		var north:float=STACKS[0].z if phase==Phase.FIRST else Z_MIN
		at.z=clampf(at.z+motion.y*WALK_SPEED*dt,north,Z_MAX)
		hero.rotation.y=atan2(-motion.x,-motion.y)
		ground=at
		stride+=dt*STRIDE_RATE
	for i in host.limbs.size():
		host.limbs[i].rotation.x=sin(stride)*(.48 if i in [0,3] else -.48) if moving else 0
	show_cover(dt)
	frame_path(at)
	if phase==Phase.FIRST:
		if inside==0:
			phase=Phase.DEMO_TURN
			elapsed=0
			cycle_voice("turn")
		return
	if inside<0 and phase==Phase.LOOK and elapsed>=GRACE:
		caught(at)
		return
	if following:
		var gap:=at-pony.position
		if inside>=0:
			pony.position=pony.position.move_toward(park_at,WALK_SPEED*dt)
		elif moving and gap.length()>FOLLOW_DISTANCE:
			pony.position=pony.position.move_toward(at,minf(WALK_SPEED*dt,gap.length()-FOLLOW_DISTANCE))
			pony.rotation.y=atan2(gap.x,gap.z)
		if at.distance_to(TOBO)<=HOME_REACH and pony.position.distance_to(TOBO)<=HOME_REACH+FOLLOW_DISTANCE:
			phase=Phase.DONE
			elapsed=0
			watching(false)
			host.stick.reset()
			host.stick.hide()
			hand.hide()
			replay.hide()
			speak("done")
			finish_time=speech_left+STAR_TIME
	else:
		var reachable:=at.distance_to(TETHER)<=HAND_REACH
		hand.disabled=not reachable
		hand.modulate=Color.GOLD if reachable else Color.WHITE
		if reachable and not near_pony: speak("pony")
		near_pony=reachable

func _process(_dt:float) -> void:
	if not camera.current or not beacon.is_inside_tree(): return
	var lamp:=camera.unproject_position(gapa.to_global(Vector3(.6,1,.36)))
	var margin:=Vector2(48,42)
	beacon.size=Vector2(82,82) if flood.visible else Vector2(54,54)
	beacon.position=lamp.clamp(margin,controls.size-margin)-beacon.size*.5
	beacon.visible=not Rect2(Vector2.ZERO,controls.size).has_point(lamp)

func leave() -> void:
	if is_queued_for_deletion(): return
	cue.stop()
	cap.queue_free()
	hero.transform=original_pose
	for limb in host.limbs: limb.rotation.x=0
	host.camera.make_current()
	controls.hide()
	controls.queue_free()
	host.home()
	queue_free()
