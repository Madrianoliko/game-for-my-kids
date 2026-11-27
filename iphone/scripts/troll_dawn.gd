extends Node3D

const Count := preload("res://scripts/touch_count.gd")

enum Beat { CAUGHT, DISHES, BET, ACCEPT, ROCKS, ARGUE_ROCKS, SKEWER, SAUSAGES, ARGUE_FOOD, CONES, ARGUE_CONES, SUN, STONE, END }
var answers := {Beat.ROCKS:4, Beat.SAUSAGES:3, Beat.CONES:6}
const CLIPS := ["caught","dishes","bet","accept","rocks","argue_rocks","skewer","sausages","argue_food","cones","argue_cones","sun","stone","end"]
const SKY := [Color("#293759"), Color("#65567d"), Color("#ba8191"), Color("#ffce85")]
const POS := [Vector3(0,0,-.9), Vector3(-2.3,0,-.5), Vector3(2.3,0,-.5)]
var story
var game
var beat:int
var trolls:Array[Node3D]=[]
var objects:Array[MeshInstance3D]=[]
var deadline:float
var catching_arm:Node3D
var eaten_from:Vector3
var counted:Array[int]=[]
var chuckle:=0.0
var daylight:=0
var sun:Node3D

func setup(owner_story) -> void:
	story=owner_story
	game=story.host
	beat=story.part
	answers[Beat.ROCKS]=story.numbers.get("rocks",4)
	answers[Beat.SAUSAGES]=story.numbers.get("sausages",3)
	answers[Beat.CONES]=story.numbers.get("cones",6)
	daylight=int(beat>=Beat.ARGUE_ROCKS)+int(beat>=Beat.ARGUE_FOOD)+int(beat>=Beat.ARGUE_CONES)
	var env:=Environment.new()
	env.background_mode=Environment.BG_COLOR
	env.background_color=SKY[daylight]
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color=SKY[daylight].lightened(.5)
	env.ambient_light_energy=.7
	game.camera.environment=env
	game.camera.look_at_from_position(global_position+Vector3(0,2.35,8.4),global_position+Vector3(0,.60,0),Vector3.UP)
	# Leave the lower part of the view free for the answer panel.
	game.camera.v_offset=-1.1
	game.box(self,Vector3(0,-.16,-1),Vector3(30,.3,23),Color("#756c53"))
	for i in 3:
		var troll=story.actor("troll",POS[i],1.22 if i==1 else 1.1)
		trolls.append(troll)
		for side in [-1,1]:
			game.orb(troll,Vector3(side*.53,.93,.22),.23,Color("#709eab"))
	if beat==Beat.CAUGHT:
		catching_arm=Node3D.new()
		trolls[0].add_child(catching_arm)
		catching_arm.position=Vector3(-.42,1,.23)
		game.orb(catching_arm,Vector3(-.30,0,0),.32,Color("#709eab")).scale=Vector3(1.6,.65,.7)
	# The orange lantern marks Gapa; Burczyk holds the wooden spoon.
	game.orb(trolls[0],Vector3(.66,.75,.32),.20,Color.GOLD,true)
	game.box(trolls[1],Vector3(-.6,1.15,.3),Vector3(.09,.75,.09),Color.SADDLE_BROWN)
	game.orb(trolls[1],Vector3(-.6,1.56,.3),.16,Color.SADDLE_BROWN)
	game.orb(self,Vector3(-3.6,.32,-1.8),.45,Color.ORANGE_RED,true)
	game.orb(self,Vector3(-3.6,.78,-1.8),.54,Color("#514858"))
	for i in 7:
		var angle:=i*PI/6
		game.orb(self,Vector3(4.4+cos(angle)*1.25,sin(angle)*1.55,-4),.64,Color("#736862"))
	game.orb(self,Vector3(4.4,.48,-4.2),1.14,Color("#352e39")).scale.z=.34
	game.leo.global_position=to_global(Vector3(-1.12,0,-.06))
	game.leo.rotation.y=.6
	if daylight==3:
		sun=game.orb(self,Vector3(-3.6,3.35,-8),.86,Color("#fff1ac"),true)
	if beat in [Beat.ROCKS,Beat.SKEWER,Beat.SAUSAGES,Beat.CONES]: build_objects()
	if answers.has(beat):
		for n in story.Data.number_choices(answers[beat]): story.button(str(n),answer.bind(n))
	if beat==Beat.END: story.button("Dalej",story.advance)
	narrate()
	if answers.has(beat) and story.marks>0:
		story.hint_errors=1
		if story.marks>=2: story.hint_miss(objects.size(),show_count)

func narrate() -> void:
	var clip:String="dawn_"+CLIPS[beat]
	if (beat in [Beat.ROCKS,Beat.ARGUE_ROCKS] and answers[Beat.ROCKS]!=4) or (beat in [Beat.SKEWER,Beat.ARGUE_FOOD] and answers[Beat.SAUSAGES]!=3) or (beat in [Beat.CONES,Beat.ARGUE_CONES] and answers[Beat.CONES]!=6):
		clip+="_alt"
	story.say(clip)
	var duration:float=game.narrator.stream.get_length() if game.sound and game.narrator.stream else 2.0
	deadline=story.age+duration+(.95 if beat==Beat.SKEWER else .35)

func build_objects() -> void:
	var total:int=answers.get(beat,answers[Beat.SAUSAGES]+1)
	var food:=beat in [Beat.SKEWER,Beat.SAUSAGES]
	if food: game.box(self,Vector3(0,1.0,1.2),Vector3(4.2,.08,.08),Color("#9c6d43"))
	for i in total:
		var x:float=(i-1.5)*.92 if food else (i-(total-1)*.5)*.75+(-.36 if i<total/2 else .36)
		var pos:=Vector3(x,1.0,1.25)
		var obj:MeshInstance3D
		if food:
			obj=game.orb(self,pos,.35,Color("#c76738"))
			obj.scale=Vector3(.85,1.27,.78)
			obj.rotation.z=-.35
			for stripe in [-1,1]:
				game.box(obj,Vector3(0,stripe*.12,.31),Vector3(.24,.03,.035),Color("#773821"))
		elif beat==Beat.CONES:
			obj=game.orb(self,pos,.32,Color("#96542f"))
			obj.scale.y=1.32
			for row in 3:
				for side in [-1,1]:
					game.orb(obj,Vector3(side*.13,(row-1)*.16,.20),.125,Color("#c0844c"))
		else:
			obj=game.orb(self,pos,.35,Color("#8aa7b7"))
			obj.scale=Vector3(1,.76,.9)
		objects.append(obj)
	if beat==Beat.SKEWER: eaten_from=objects.back().position
	if not food:
		for side in [-1,1]:
			# A palm below each separate group keeps the two addends visible.
			var x:float=side*(1.48 if total==6 else 1.12)
			game.orb(self,Vector3(x,.69,1.16),.65,Color("#709eab")).scale=Vector3(1.65,.40,.83)

func highlight(index:int) -> void:
	var mat:StandardMaterial3D=objects[index].material_override
	mat.emission_enabled=true
	mat.emission=Color("#ffcb5c")

func count_voice(n:int) -> void:
	if game.sound: game.play_clip(game.chime,"count_%d"%n)

func show_count(total:int) -> void:
	for i in objects.size():
		objects[i].material_override.emission_enabled=false
		if i<total: highlight(i)

func answer(n:int) -> void:
	if story.host.paused or story.part!=beat: return
	if n==answers[beat]:
		game.chime.stop()
		story.go_to("troll_dawn",beat+1)
		return
	story.marks+=1
	story.checkpoint()
	chuckle=.75
	if story.hint_lit>=story.hint_total: story.effect("story/dawn_laugh")
	story.hint_miss(objects.size(),show_count)

func _input(event:InputEvent) -> void:
	if not is_visible_in_tree() or game.paused or not answers.has(beat) or story.hint_total>0: return
	if not ((event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT)) and event.pressed): return
	if story.dock.get_global_rect().has_point(event.position) or game.pause_button.get_global_rect().has_point(event.position): return
	var nearest:=-1
	var radius:=30.0
	for i in objects.size():
		var distance:float=game.camera.unproject_position(objects[i].global_position).distance_to(event.position)
		if distance<radius:
			radius=distance
			nearest=i
	if nearest>=0 and nearest not in counted:
		counted.append(nearest)
		Count.mark(objects[nearest],counted.size())
		count_voice(counted.size())
		get_viewport().set_input_as_handled()

func tick(dt:float) -> void:
	var t:float=story.age
	if beat==Beat.CAUGHT:
		var reach:=smoothstep(0,.65,t)
		trolls[0].position=POS[0].lerp(Vector3(-.36,0,-.44),reach)
		catching_arm.rotation.z=lerpf(-.95,.15,reach)
		game.leo.position.y=global_position.y+.42*sin(PI*smoothstep(.45,1.5,t))
	if beat<=Beat.ACCEPT:
		var wake:=smoothstep(0,1,t) if beat==Beat.DISHES else float(beat>Beat.DISHES)
		trolls[2].rotation.z=(1-wake)*.98
		trolls[1].rotation.x=(1-wake)*.4
		if beat==Beat.CAUGHT: trolls[0].position=POS[0].lerp(Vector3(-.66,0,-.3),smoothstep(0,.75,t))
	if beat in [Beat.ARGUE_ROCKS,Beat.ARGUE_FOOD,Beat.ARGUE_CONES] or chuckle>0:
		chuckle=maxf(0,chuckle-dt)
		for i in 3: trolls[i].rotation.z=.17*sin(10*t+i*2)
	if beat==Beat.ARGUE_CONES: sun.position.y=lerpf(1.5,3.35,smoothstep(0,2,t))
	if beat==Beat.SKEWER:
		var bite:=smoothstep(deadline-1.15,deadline-.2,t)
		objects.back().position=eaten_from.lerp(POS[1]+Vector3(0,1.46,.50),bite)+Vector3.UP*sin(PI*bite)*.65
		objects.back().scale=Vector3(.85,1.27,.78)*(1-.99*smoothstep(.7,1,bite))
	if beat in [Beat.STONE,Beat.END]:
		for i in 3:
			trolls[i].rotation.z=[.42,-.36,.62][i]
			if (beat==Beat.END or t>.45*i) and not trolls[i].has_meta("stone"):
				var stone:=StandardMaterial3D.new()
				stone.albedo_color=Color("#9ca7b0")
				for mesh in trolls[i].find_children("*","MeshInstance3D",true,false): mesh.material_override=stone
				trolls[i].set_meta("stone",true)
	if beat!=Beat.END and not answers.has(beat) and t>=deadline:
		story.go_to("troll_dawn",beat+1)
