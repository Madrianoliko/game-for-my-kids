extends Node3D

const Props := preload("res://scripts/river_props.gd")
const Icons := preload("res://scripts/river_icons.gd")
const BACK_TIME := 3.5
const TURN_TIME := 0.6
const LOOK_TIME := 2.5
const GRACE := 0.25
const STILL_THRESHOLD := 0.15
const LOOK_RANGE := 10.5
const LOOK_ANGLE := 84.0 # Pełny kąt stożka w stopniach.
const HIDE_RADIUS := 1.3
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
const START := Vector3(-1.6,0,4.7)
const TOBO := Vector3(-2.8,0,4.8)
const BUSHES := [Vector3(-1.35,0,2.1), Vector3(0.6,0,-1.35)]
const TREE := Vector3(2.5,0,-4.2)
const TETHER := Vector3(1.15,0,-3.9)
const WATCH := Vector3(-0.65,0,-6.0)
const FIRE := Vector3(-2.6,0,-6.4)
const X_LIMIT := 4.5
const Z_MIN := -5.2
const Z_MAX := 5.5
const CAMERA_AT := Vector3(0,.5,-.6)
const CAMERA_FROM := Vector3(0,14,12)
const VIEW_HEIGHT := 12.8
const BUSH_SIZE := 1.35
const EXPOSURE := .30
const WORDS := {
	"start":"Ciii… To Gapa. Kiedy troll się odwraca, idź. Kiedy patrzy, stój jak posąg!",
	"count":"Raz… dwa… trzy…",
	"turn":"Hmm? Kto tu łazi?",
	"caught":"Aha! Mysz w kapeluszu! Wracaj do krzaczka!",
	"hint":"Kiedy troll patrzy, stój jak posąg.",
	"pony":"Dotknij dłoni. Odwiąż kucyka i daj mu siana.",
	"follow":"Kucyk idzie za tobą! Wracaj do Toba.",
	"done":"Jest! Mój kucyk! Dziękuję, Bilbo!"
}
enum Phase { INTRO, BACK, TURN, LOOK, CAUGHT, DONE }
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
var cone := MeshInstance3D.new()
var camera := Camera3D.new()
var controls := Control.new()
var hand:Button
var replay:Button
var back:Button
var star := Label.new()
var caption := Label.new()
var cue := AudioStreamPlayer.new()
var message := "start"
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
	camera.look_at_from_position(to_global(CAMERA_FROM),to_global(CAMERA_AT))
	var night:=CameraAttributesPractical.new()
	night.exposure_multiplier=EXPOSURE
	camera.attributes=night
	camera.make_current()
	add_child(cue)
	build_controls()
	speak("start")

func troll(at:Vector3, amount:float) -> Node3D:
	var actor:=Props.new()
	add_child(actor)
	actor.setup(host)
	actor.build("troll")
	actor.position=at
	actor.scale=Vector3.ONE*amount
	return actor

func build_camp() -> void:
	host.box(self,Vector3.DOWN*.23,Vector3(42,.44,32),Color("#557465"))
	for at:Vector3 in BUSHES:
		var leaves:MeshInstance3D=host.orb(self,at+Vector3.UP*.9,BUSH_SIZE,Color("#598357"))
		leaves.scale=Vector3(1,.96,.92)
		for side in [-1,1]:
			host.orb(self,at+Vector3(.78*side,.65,.18),.78,Color("#719961"))
	host.orb(self,TOBO+Vector3(-.4,.35,.35),.78,Color("#628454"))
	var tobo:=troll(TOBO,.86)
	for i in 3:
		host.box(tobo,Vector3(-.55,.85+i*.12,0),Vector3(.32,.1,1.35),Color("#bb905e"))
	gapa=troll(WATCH,1.35)
	gapa.rotation.y=PI
	var gold:=Color("#ffbe5b")
	host.orb(gapa,Vector3(.6,1,.36),.24,gold,true)
	host.box(gapa,Vector3(.6,1.24,.36),Vector3(.35,.1,.35),Color("#665343"))
	for side in [-1,1]:
		host.box(self,FIRE+Vector3(0,.15,0),Vector3(1.3,.2,.22),Color.SADDLE_BROWN).rotation.y=side*.65
		host.orb(self,FIRE+Vector3(side*.23,.39,0),.34,gold,true).scale.y=1.6
	host.orb(self,FIRE+Vector3.UP*.96,.52,Color("#464659")).scale.y=.73
	var light:=OmniLight3D.new()
	add_child(light)
	light.position=FIRE+Vector3.UP*1.4
	light.light_color=gold
	light.light_energy=3
	light.omni_range=8
	host.box(self,TREE+Vector3.UP,Vector3(.48,2,.48),Color("#97724c"))
	host.orb(self,TREE+Vector3.UP*2.45,1.08,Color("#658858"))
	add_child(pony)
	pony.position=TETHER
	var coat:=Color("#cb945c")
	host.orb(pony,Vector3(0,.67,0),.52,coat).scale=Vector3(.74,.86,1.28)
	host.orb(pony,Vector3(0,1.12,.43),.36,coat)
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
	var fan:=ImmediateMesh.new()
	var mat:=StandardMaterial3D.new()
	mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color=Color(1,.49,.1,.47)
	fan.surface_begin(Mesh.PRIMITIVE_TRIANGLES,mat)
	for i in 32:
		fan.surface_add_vertex(Vector3.ZERO)
		for j in [i,i+1]:
			var angle:=deg_to_rad(LOOK_ANGLE*(j/32.0-.5))
			fan.surface_add_vertex(Vector3(sin(angle),0,cos(angle))*LOOK_RANGE)
	fan.surface_end()
	cone.mesh=fan
	add_child(cone)
	cone.position=WATCH+Vector3.UP*.035
	cone.hide()

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
	caption.position=Vector2(inset.x+back.size.x+8,inset.y)
	caption.size=Vector2(replay.position.x-caption.position.x-8,back.size.y)
	star.position=(controls.size-star.get_minimum_size())*.5

func speak(key:String) -> void:
	message=key
	caption.text=WORDS[key]
	cue.stop()
	if host.sound:
		host.play_clip(host.narrator,"story/camp_"+key)
		speech_left=host.narrator.stream.get_length()
	else:
		speech_left=0

func cycle_voice(key:String) -> void:
	if host.sound and speech_left<=0:
		host.play_clip(cue,"story/camp_"+key)

func begin_back() -> void:
	phase=Phase.BACK
	elapsed=0
	cone.hide()
	gapa.position=WATCH
	gapa.rotation.y=PI
	cycle_voice("count")

func in_light(at:Vector3) -> bool:
	var offset:=Vector2(at.x-WATCH.x,at.z-WATCH.z)
	return offset.length()<=LOOK_RANGE and offset.y>=cos(deg_to_rad(LOOK_ANGLE*.5))*offset.length()

func cover(at:Vector3) -> int:
	for i in BUSHES.size():
		if at.distance_to(BUSHES[i])<=HIDE_RADIUS: return i
	return -1

func untie() -> void:
	if following or phase not in [Phase.BACK,Phase.TURN,Phase.LOOK]: return
	if to_local(hero.global_position).distance_to(TETHER)>HAND_REACH: return
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
	cone.hide()
	speak("caught")

func recover() -> void:
	var lift:=catch_from+Vector3.UP*LIFT_HEIGHT
	var t:=clampf(elapsed/LIFT_TIME,0,1)
	var slide:=smoothstep(0,1,clampf((elapsed-LIFT_TIME)/RETURN_TIME,0,1))
	hero.global_position=to_global(catch_from.lerp(lift,sin(t*PI*.5)).lerp(last_cover,slide))
	# Gapa wyciąga łapę pod Bilba, a potem odstawia go za krzak.
	var reach:=catch_from+Vector3.FORWARD*REACH_HEIGHT
	gapa.position=WATCH.lerp(reach,sin(t*PI*.5)).lerp(WATCH,slide)
	gapa.rotation.z=.22*sin(t*PI)
	hero.rotation.z=.3*sin(t*PI)
	if following: pony.position=pony_from.lerp(last_cover+Vector3.BACK*FOLLOW_DISTANCE,slide)
	if elapsed>=LIFT_TIME+RETURN_TIME:
		host.stick.reset()
		begin_back()

func _physics_process(dt:float) -> void:
	if not host or is_queued_for_deletion(): return
	elapsed+=dt
	speech_left=maxf(0,speech_left-dt)
	if phase==Phase.INTRO:
		if speech_left<=0: begin_back()
		return
	if phase==Phase.CAUGHT:
		recover()
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
				cone.show()
		Phase.LOOK:
			if elapsed>=LOOK_TIME: begin_back()
	var motion:Vector2=host.stick.vector
	if motion.is_zero_approx(): motion=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var at:=to_local(hero.global_position)
	var moving:=motion.length()>STILL_THRESHOLD
	if moving:
		at.x=clampf(at.x+motion.x*WALK_SPEED*dt,-X_LIMIT,X_LIMIT)
		at.z=clampf(at.z+motion.y*WALK_SPEED*dt,Z_MIN,Z_MAX)
		hero.rotation.y=atan2(-motion.x,-motion.y)
		hero.global_position=to_global(at)
		stride+=dt*STRIDE_RATE
	for i in host.limbs.size():
		host.limbs[i].rotation.x=sin(stride)*(.48 if i in [0,3] else -.48) if moving else 0
	var bush:=cover(at)
	if bush>=0: last_cover=BUSHES[bush]
	elif moving and phase==Phase.LOOK and elapsed>=GRACE and in_light(at):
		caught(at)
		return
	if following:
		var gap:=at-pony.position
		if moving and gap.length()>FOLLOW_DISTANCE:
			pony.position=pony.position.move_toward(at,minf(WALK_SPEED*dt,gap.length()-FOLLOW_DISTANCE))
			pony.rotation.y=atan2(gap.x,gap.z)
		if at.distance_to(TOBO)<=HOME_REACH and pony.position.distance_to(TOBO)<=HOME_REACH+FOLLOW_DISTANCE:
			phase=Phase.DONE
			elapsed=0
			cone.hide()
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

func leave() -> void:
	if is_queued_for_deletion(): return
	cue.stop()
	hero.transform=original_pose
	for limb in host.limbs: limb.rotation.x=0
	host.camera.make_current()
	controls.hide()
	controls.queue_free()
	host.home()
	queue_free()
