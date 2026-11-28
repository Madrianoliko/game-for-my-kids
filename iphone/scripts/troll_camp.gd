extends Node3D

const Props := preload("res://scripts/river_props.gd")
const Icons := preload("res://scripts/river_icons.gd")
const PATROL_CENTER := Vector3(0,0,-4)
const PATROL_SPEED := 1.425
const PATROL_RADIUS := 1.8
const CORNER_TIME := 1.25
const LEG_TIME := 2*PATROL_RADIUS/PATROL_SPEED
const LOOK_RANGE := 5.0
const LOOK_ANGLE := 80.0
const DEMO_TIME := 1.8
const HAY_RADIUS := 1.0
const PARK_DISTANCE := 1.55
const HIDE_TIME := .22
const FLY_TIME := 1.2
const WALK_SPEED := 3.0
const FOLLOW_DISTANCE := 1.0
const HAND_REACH := 1.5
const HOME_REACH := 1.6
const LIFT_TIME := 0.4
const RETURN_TIME := 1.1
const LIFT_HEIGHT := 1.7
const FADE_TIME := 1.25
const REACH_HEIGHT := .68
const STRIDE_RATE := 10.0
const ORIGIN := Vector3(500,0,0)
const START := Vector3(-.8,0,2)
const TOBO := Vector3(-2,0,3.6)
const STACKS := [Vector3.ZERO,Vector3(-4,0,0),Vector3(4,0,0),
	Vector3(0,0,-4),Vector3(-4,0,-4),Vector3(4,0,-4),
	Vector3(0,0,-8),Vector3(-4,0,-8),Vector3(4,0,-8)]
const TETHER := Vector3(0,0,-10.5)
const TETHERS := [Vector3(-6.2,0,-4),Vector3(6.2,0,-4),TETHER]
const TREE := TETHER+Vector3(1.3,0,-.3)
const WATCH := PATROL_CENTER+Vector3.BACK*PATROL_RADIUS
const FIRE := TETHER+Vector3(-2.2,0,-.5)
const X_LIMIT := 7.0
const Z_MIN := -11.5
const Z_MAX := 4.0
const CAMERA_OFFSET := Vector3(0,16,12)
const VIEW_HEIGHT := 19.5
const EXPOSURE := .55
const WORDS := {
	"intro_stolen":"Bilbo! Troll Gapa ukradł moje kucyki!",
	"intro_there":"Tam są! Przy drzewie, przy wozie i obok ogniska.",
	"intro_run":"To Gapa. Widzi tam, gdzie świeci latarnią.",
	"intro_first":"Wejdź do stogu. W sianie jesteś bezpieczny.",
	"intro_safe":"Widzisz? Nie zobaczył cię!",
	"caught":"Aha! Widzę cię! Wracaj do stogu!",
	"caught_again":"Znowu ty? Hi, hi!",
	"hint":"Schowaj się w stogu, kiedy światło się zbliża.",
	"pony":"Dotknij dłoni. Odwiąż kucyka i daj mu siana.",
	"follow":"Kucyk idzie za tobą! Wracaj do Toba.",
	"one":"Jeden kucyk jest już u mnie! Zostały jeszcze dwa.",
	"two":"Dwa kucyki! Został jeszcze jeden.",
	"tree_pair":"Tam są! Przy drzewie i obok ogniska.",
	"cart_pair":"Tam są! Przy wozie i obok ogniska.",
	"one_left":"Jeden kucyk jest już u mnie! Został jeszcze jeden.",
	"done_pair":"Oba kucyki są bezpieczne, Bilbo!",
	"done":"Wszystkie trzy kucyki są bezpieczne, Bilbo!"
}
enum Phase { INTRO, FIRST, DEMO, PATROL, CAUGHT, DONE }
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
signal rescued(mask:int)
signal closed(complete:bool)
var available:=7
var rescued_mask:=0
var chosen:=-1
var ponies:Array[Node3D]=[]
var ropes:Array[MeshInstance3D]=[]
var pony:Node3D
var fade:=ColorRect.new()
var stacks:Array[Node3D]=[]
var eyes:=Node3D.new()
var cone:=MeshInstance3D.new()
var patrol_time:=0.0
var catch_origin:=WATCH
var rustle:=AudioStreamPlayer.new()
var ground:=START
var inside:=-1
var dip:=0.0
var rustle_left:=0.0
var park_at:=Vector3.ZERO
var cap:=Node3D.new()
var intro_step:=0
const INTRO := ["intro_run","intro_first"]

var camera := Camera3D.new()
var controls := Control.new()
var hand:Button
var replay:Button

var caption := Label.new()
var message := "intro_stolen"
var speech_left := 0.0
var hint_pending := false
var near_pony := false
var finish_time := 0.0
var catch_from:Vector3
var pony_from:Vector3

func begin(game, saved_mask:int, pony_mask:=7) -> void:
	available=pony_mask
	rescued_mask=saved_mask
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
	build_controls()
	add_child(rustle)
	rustle.stream=AudioStreamMP3.load_from_file("res://audio/story/camp_rustle.mp3")
	var hat:=CylinderMesh.new()
	hat.top_radius=.06
	hat.bottom_radius=.35
	hat.height=.42
	hero.add_child(cap)
	host.mesh(cap,hat,Vector3.UP*1.69,Color("#ae6540"))
	if rescued_mask==available:
		finish_camp()
	elif rescued_mask!=0:
		ground=STACKS[0]
		begin_patrol()
		speak("two" if count_rescued()==2 else "one")
	else: speak(INTRO[0])

func troll(at:Vector3, amount:float) -> Node3D:
	var actor:=Props.new()
	add_child(actor)
	actor.setup(host)
	actor.build("troll")
	actor.position=at
	actor.scale=Vector3.ONE*amount
	return actor

func build_camp() -> void:
	host.box(self,Vector3(0,-.23,-4),Vector3(32,.44,32),Color("#36554f"))
	# Ciemna linia lasu obramowuje jaśniejszą, grywalną polanę.
	for side in [-1,1]:
		for z in range(-15,9,3):
			var edge:=Vector3(side*(9.5+.45*cos(z)),0,z)
			host.box(self,edge+Vector3.UP,Vector3(.38,2,.42),Color("#654a43"))
			host.orb(self,edge+Vector3.UP*2.2,1.25,Color("#274c4d")).scale.y=1.35
	for at:Vector3 in STACKS: add_stack(at)
	var tobo:=troll(TOBO,.86)
	for i in 3:
		host.box(tobo,Vector3(-.55,.85+i*.12,0),Vector3(.32,.1,1.35),Color("#bb905e"))
	gapa=troll(WATCH,1.35)
	gapa.rotation.y=PI
	gapa.add_child(eyes)
	for side in [-1,1]:
		host.orb(eyes,Vector3(side*.19,1.44,.51),.085,Color("#ff9a36"),true)
	build_cone()
	watching(true)
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
	var tree:Vector3=TETHERS[0]+Vector3.LEFT
	host.box(self,tree+Vector3.UP,Vector3(.45,2,.45),Color.SADDLE_BROWN)
	host.orb(self,tree+Vector3.UP*2.4,1.05,Color.DARK_SEA_GREEN)
	var cart:Vector3=TETHERS[1]+Vector3.RIGHT
	host.box(self,cart+Vector3.UP*.75,Vector3(1.4,.65,1.9),Color.PERU)
	for side in [-1,1]:
		for end in [-1,1]:
			host.orb(self,cart+Vector3(side*.74,.42,end*.63),.38,Color.SADDLE_BROWN).scale.x=.28
	for i in TETHERS.size():
		var at:Vector3=TETHERS[i]
		var horse:=preload("res://scripts/pony.gd").make(host,self,at,[Color.TAN,Color.FLORAL_WHITE,Color.PERU][i])
		ponies.append(horse)
		horse.rotation.y=-1.1
		var post:Vector3=[tree,cart,TREE][i]
		var tie:=post-at
		var line:MeshInstance3D=host.box(self,(post+at)*.5+Vector3.UP*.74,Vector3(.055,.055,tie.length()),Color.WHEAT)
		line.rotation.y=atan2(tie.x,tie.z)
		ropes.append(line)
		horse.visible=bool(available & (1<<i))
		line.visible=horse.visible
		if rescued_mask & (1<<i): park_pony(i)

func add_stack(at:Vector3) -> void:
	var stack:=Node3D.new()
	add_child(stack)
	stack.position=at
	stacks.append(stack)
	var bale:=CylinderMesh.new()
	bale.bottom_radius=HAY_RADIUS
	bale.top_radius=HAY_RADIUS
	bale.height=.95
	var straw:=Color("#dca83b")
	host.mesh(stack,bale,Vector3.UP*.48,straw)
	host.orb(stack,Vector3.UP*.96,HAY_RADIUS,straw.lightened(.12)).scale.y=.38
	var binding:=TorusMesh.new()
	binding.inner_radius=.965
	binding.outer_radius=1.025
	host.mesh(stack,binding,Vector3.UP*.51,Color("#a87939"))
	for i in 22:
		var angle:=TAU*i/22
		var stalk:MeshInstance3D=host.box(stack,Vector3(sin(angle)*1.01,.68,cos(angle)*1.01),Vector3(.035,1.05,.035),Color("#efca78") if i%3 else Color("#ac7c37"))
		stalk.rotation.z=.16*sin(angle)
		stalk.rotation.x=.16*cos(angle)
		var tip:=Vector3(sin(angle)*.67,1.19,cos(angle)*.67)
		var tuft:MeshInstance3D=host.box(stack,tip,Vector3(.05,.48,.05),straw.darkened(.13))
		tuft.rotation.z=-.68*sin(angle)
		tuft.rotation.x=.68*cos(angle)

func build_cone() -> void:
	var fan:=ImmediateMesh.new()
	var mat:=StandardMaterial3D.new()
	mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	mat.albedo_color=Color(1,.47,.09,.54)
	fan.surface_begin(Mesh.PRIMITIVE_TRIANGLES,mat)
	for i in 32:
		fan.surface_add_vertex(Vector3.ZERO)
		for edge in [i,i+1]:
			var angle:float=deg_to_rad(LOOK_ANGLE)*(edge/32.0-.5)
			fan.surface_add_vertex(Vector3(sin(angle),0,cos(angle))*LOOK_RANGE)
	fan.surface_end()
	cone.mesh=fan
	add_child(cone)
	cone.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	face_light(STACKS[0]-gapa.position)

func face_light(direction:Vector3) -> void:
	gapa.rotation.y=atan2(direction.x,direction.z)
	cone.position=gapa.position+Vector3.UP*.045
	cone.rotation.y=gapa.rotation.y

func in_light(at:Vector3) -> bool:
	var delta:=at-gapa.position
	return delta.length_squared()<=LOOK_RANGE*LOOK_RANGE and (delta.is_zero_approx() or delta.normalized().dot(cone.basis.z)>=cos(deg_to_rad(LOOK_ANGLE*.5)))

func watching(enabled:bool) -> void:
	eyes.visible=enabled
	cone.visible=enabled

func frame_path(at:Vector3) -> void:
	var focus:=Vector3(at.x*.10,.6,-4+at.z*.05)
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
	controls.add_child(caption)
	caption.visible=host.subtitles
	host.subtitles_changed.connect(caption.set_visible)
	caption.add_theme_stylebox_override("normal",host.plate(Color("#162535ed")))
	caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_size_override("font_size",21)
	controls.add_child(fade)
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.color=Color(0,0,0,0)
	fade.mouse_filter=Control.MOUSE_FILTER_IGNORE
	layout()
	controls.resized.connect(layout,CONNECT_DEFERRED)

func layout() -> void:
	var inset:Vector2=host.hud.position
	replay.position=Vector2(host.pause_button.position.x-12-replay.size.x,inset.y)
	hand.position=controls.size-inset-hand.size
	caption.position=Vector2(inset.x,inset.y)
	caption.size=Vector2(replay.position.x-inset.x-12,46)
	caption.mouse_filter=Control.MOUSE_FILTER_IGNORE

func speak(key:String) -> void:
	if available!=7:
		if key=="intro_there": key="tree_pair" if available==5 else "cart_pair"
		if key=="one": key="one_left"
		if key=="done": key="done_pair"
	message=key
	caption.text=WORDS[key]
	if host.sound:
		host.play_clip(host.narrator,"story/camp_"+key)
		speech_left=host.narrator.stream.get_length()
	else:
		speech_left=2.5 if phase==Phase.INTRO or phase==Phase.DEMO else 0.0

func begin_patrol() -> void:
	phase=Phase.PATROL
	if not following: mark_next_pony()
	elapsed=0
	watching(true)
	update_patrol(0)

func update_patrol(dt:float) -> void:
	patrol_time=fmod(patrol_time+dt,4*(LEG_TIME+CORNER_TIME))
	var pose:=patrol_pose(patrol_time)
	gapa.position=pose.origin
	face_light(pose.basis.z)

static func patrol_pose(time:float) -> Transform3D:
	var side:=floori(time/(LEG_TIME+CORNER_TIME))%4
	var elapsed_on_side:=fmod(time,LEG_TIME+CORNER_TIME)
	var corners:=[Vector3(-1,0,1),Vector3(-1,0,-1),Vector3(1,0,-1),Vector3(1,0,1)]
	var from:Vector3=PATROL_CENTER+corners[side]*PATROL_RADIUS
	var toward:Vector3=PATROL_CENTER+corners[(side+1)%4]*PATROL_RADIUS
	var at:=from.move_toward(toward,minf(elapsed_on_side,LEG_TIME)*PATROL_SPEED)
	var turn:=clampf((elapsed_on_side-LEG_TIME)/CORNER_TIME,0,1)
	var angle:=side*PI/2+turn*PI/2+deg_to_rad(65)*sin(TAU*turn)
	return Transform3D(Basis(Vector3.UP,PI-angle),at)

func cover(at:Vector3) -> int:
	for i in stacks.size():
		if at.distance_to(stacks[i].position)<=HAY_RADIUS: return i
	return -1

func show_cover(dt:float) -> void:
	var next:=cover(ground)
	if next!=inside:
		inside=next
		if inside>=0:
			last_cover=stacks[inside].position
			rustle_left=HIDE_TIME*2
			if host.sound: rustle.play()
			var approach:=pony.position-last_cover if following else Vector3.BACK
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
	frame_path(START.lerp(TETHER,t) if intro_step==0 else TETHER.lerp(START,t))
	if speech_left>0 or elapsed<FLY_TIME: return
	elapsed=0
	intro_step+=1
	if intro_step==INTRO.size():
		phase=Phase.FIRST
		host.stick.reset()
		host.mark_goal(to_global(STACKS[0]+Vector3.UP*1.9))
	else: speak(INTRO[intro_step])

func untie() -> void:
	if host.paused or following or phase!=Phase.PATROL: return
	chosen=nearby_pony()
	if chosen<0: return
	pony=ponies[chosen]
	following=true
	host.mark_goal(to_global(TOBO+Vector3.UP*2))
	ropes[chosen].hide()
	host.box(self,TETHERS[chosen]+Vector3.UP*.16,Vector3(.5,.32,.45),Color.GOLD)
	hand.disabled=true
	hand.modulate=Color.WHITE
	speak("follow")

func caught(at:Vector3) -> void:
	phase=Phase.CAUGHT
	catches+=1
	if catches==2: hint_pending=true
	catch_origin=gapa.position
	catch_from=at
	if following: pony_from=pony.position
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
	gapa.position=catch_origin.lerp(reach,sin(t*PI*.5)).lerp(catch_origin,slide)
	gapa.rotation.z=.22*sin(t*PI)
	hero.rotation.z=.3*sin(t*PI)
	if following: pony.position=pony_from.lerp(last_cover+Vector3.BACK*PARK_DISTANCE,slide)
	if elapsed>=LIFT_TIME+RETURN_TIME:
		ground=last_cover
		host.stick.reset()
		begin_patrol()

func _physics_process(dt:float) -> void:
	if not host or host.paused or is_queued_for_deletion(): return
	elapsed+=dt
	speech_left=maxf(0,speech_left-dt)
	if phase==Phase.INTRO:
		update_patrol(dt)
		introduction()
		return
	if phase==Phase.DEMO:
		show_cover(dt)
		if elapsed>=DEMO_TIME and speech_left<=0:
			begin_patrol()
		return
	if phase==Phase.CAUGHT:
		recover()
		frame_path(to_local(hero.global_position))
		return
	if phase==Phase.DONE:
		fade.color.a=clampf((elapsed-finish_time+FADE_TIME)/FADE_TIME,0,1)
		if elapsed>=finish_time: leave(true)
		return
	if hint_pending and speech_left<=0:
		hint_pending=false
		speak("hint")
	if phase in [Phase.FIRST,Phase.PATROL]: update_patrol(dt)
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
			phase=Phase.DEMO
			elapsed=0
			watching(true)
			face_light(at-gapa.position)
		return
	if inside<0 and phase==Phase.PATROL and in_light(at):
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
			following=false
			host.marker.hide()
			rescued_mask|=1<<chosen
			park_pony(chosen)
			rescued.emit(rescued_mask)
			if rescued_mask==available: finish_camp()
			else:
				near_pony=false
				mark_next_pony()
				host.stick.reset()
				speak("one" if count_rescued()==1 else "two")

	else:
		var reachable:=nearby_pony()>=0
		hand.disabled=not reachable
		hand.modulate=Color.GOLD if reachable else Color.WHITE
		if reachable and not near_pony: speak("pony")
		near_pony=reachable

func mark_next_pony() -> void:
	var target:=-1
	for i in TETHERS.size():
		if available & (1<<i) and not (rescued_mask & (1<<i)):
			if target<0 or ground.distance_to(TETHERS[i])<ground.distance_to(TETHERS[target]): target=i
	if target>=0: host.mark_goal(to_global(TETHERS[target]+Vector3.UP*1.9))

func nearby_pony() -> int:
	for i in TETHERS.size():
		if (available & (1<<i)) and not (rescued_mask & (1<<i)) and ground.distance_to(TETHERS[i])<=HAND_REACH: return i
	return -1

func count_rescued() -> int:
	return int(bool(rescued_mask&1))+int(bool(rescued_mask&2))+int(bool(rescued_mask&4))

func park_pony(i:int) -> void:
	ropes[i].hide()
	ponies[i].position=TOBO+Vector3(i*1.05-1,0,1)
	ponies[i].rotation.y=.4

func finish_camp() -> void:
	phase=Phase.DONE
	elapsed=0
	watching(false)
	host.stick.reset()
	host.stick.hide()
	hand.hide()
	replay.hide()
	speak("done")
	finish_time=speech_left+FADE_TIME

func leave(complete:=false) -> void:
	if is_queued_for_deletion(): return
	dispose()
	closed.emit(complete)

func dispose() -> void:
	host.marker.hide()
	cap.queue_free()
	hero.transform=original_pose
	for limb in host.limbs: limb.rotation.x=0
	host.camera.make_current()
	controls.hide()
	controls.queue_free()
	queue_free()
