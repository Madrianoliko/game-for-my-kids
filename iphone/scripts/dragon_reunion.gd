extends "res://scripts/iskierka.gd"

const Count := preload("res://scripts/touch_count.gd")

const Dragon := preload("res://scripts/iskierka.gd")
const FLIGHT_TIME := 9.0
const SNEEZE_INTERVAL := .55
var tokens:Array[MeshInstance3D]=[]
var lights:Array[MeshInstance3D]=[]
var hat:MeshInstance3D
var empty_seats:Array[MeshInstance3D]=[]
var unlit:Array[int]=[]
var initial_lights:=0
var mother
var trial:=0
var sneezes:=0
var timer:=0.0
var elapsed:=0.0
var flight_from:Vector3
var flight_to:Vector3

func setup(owner_story) -> void:
	story=owner_story
	game=story.host
	game.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	game.camera.size=8.8
	var focus:=global_position+Vector3(0,0,1.7)
	game.camera.look_at_from_position(focus+Vector3(0,8,6),focus,Vector3.UP)
	dragon=Node3D.new()
	add_child(dragon)
	build_dragon()
	if story.id()=="dragon_flight":
		build_flight()
		return
	game.box(self,Vector3(0,-.25,0),Vector3(18,.5,15),Color("#92836c"))
	game.leo.global_position=to_global(Vector3(-3.8,0,.65))
	dragon.position=Vector3(-2.5,0,.8)
	if story.id()=="mole_candles": build_candles()
	else: build_nest()
	prompt_phase()

func build_candles() -> void:
	game.hud.text="Urodziny kreta"
	if not story.numbers.has("lit_candles"):
		var order:=[0,1,2,3,4]
		order.shuffle()
		var mask:=0
		for n in randi_range(1,3): mask|=1<<int(order[n])
		story.numbers.lit_candles=mask
		story.checkpoint()
	initial_lights=story.numbers.lit_candles
	var cake=game.orb(self,Vector3(-1.75,.47,-1.25),1.3,Color("#edb58b"))
	cake.scale=Vector3(1,.42,.8)
	game.orb(self,Vector3(-1.75,.93,-1.25),1.22,Color.MISTY_ROSE).scale=Vector3(1,.12,.79)
	game.box(self,Vector3(1.75,.91,-1.45),Vector3(2.35,.2,.86),Color.SADDLE_BROWN)
	for x in [1,2.5]: game.box(self,Vector3(x,.4,-1.7),Vector3(.24,.8,.32),Color.SIENNA)
	for i in 5:
		var x:float=-2.57+.82*i if i<3 else 1.22+(i-3)*1.02
		var candle=game.box(self,Vector3(x,1.37,-1.35),Vector3(.27,.64,.29),Color.PALE_TURQUOISE)
		tokens.append(candle)
		var light=game.orb(candle,Vector3(0,.46,0),.145,Color.ORANGE,true)
		light.scale.y=1.6
		light.visible=story.part==3 or (initial_lights & (1<<i))!=0
		if (initial_lights & (1<<i))==0: unlit.append(i)
		lights.append(light)
	var mole=game.orb(self,Vector3(2.7,.55,.85),.56,Color("#594b45"))
	game.orb(mole,Vector3(0,.41,.06),.43,Color("#746157"))
	game.orb(mole,Vector3(0,.37,.44),.16,Color.LIGHT_PINK)
	for side in [-1,1]:
		game.orb(mole,Vector3(side*.19,.52,.40),.065,Color.BLACK)
		game.orb(mole,Vector3(side*.46,-.04,.28),.19,Color.BISQUE)
	hat=game.orb(mole,Vector3(0,.81,.04),.44,Color.DARK_CYAN)
	hat.scale=Vector3(1,.52,1)

func build_mother() -> void:
	mother=Dragon.new()
	add_child(mother)
	mother.game=game
	mother.story=story
	mother.set_process_input(false)
	mother.dragon=Node3D.new()
	mother.add_child(mother.dragon)
	mother.build_dragon()
	mother.scale=Vector3.ONE*2.05

func build_nest() -> void:
	game.hud.text="Gniazdo na szczycie"
	build_mother()
	mother.position=Vector3(2.1,0,-2.35)
	if not story.numbers.has("nest_missing"):
		story.numbers.nest_missing=1 if story.part>0 else randi_range(1,2)
		story.checkpoint()
	for i in 5:
		var at:=Vector3((i-2)*1.11,.17,-.30)
		var seat=game.orb(self,at,.60,Color("#a67649"))
		seat.scale=Vector3(1,.38,1)
		game.orb(self,at+Vector3.UP*.17,.46,Color("#654a38")).scale.y=.22
		if i>=5-int(story.numbers.nest_missing):
			empty_seats.append(seat)
			if story.part!=3 or i!=3: continue
		var shell=game.orb(self,at+Vector3.UP*.38,.40,Color("#ffefc9"))
		tokens.append(shell)
		if story.part==3 and i==3 and empty_seats.has(seat):
			shell.create_tween().tween_property(shell,"position",shell.position,.9).from(shell.position+Vector3(-2,0,-2.4))
		var baby=game.orb(shell,Vector3(0,.33,0),.28,Color("#cc8964"))
		for side in [-1,1]:
			game.orb(baby,Vector3(side*.12,.08,.2),.045,Color.BLACK)
			game.orb(baby,Vector3(side*.17,.23,-.04),.07,Color.WHEAT)
	if story.part==3:
		dragon.position=Vector3(2.2,0,-.45)
		var hug=create_tween().set_parallel()
		hug.tween_property(dragon,"position",Vector3(1.65,0,-1.55),.85)
		for wing in mother.wings:
			hug.tween_property(wing,"rotation:x",1.22,.85)
			hug.tween_property(wing,"scale",Vector3(1.45,1.8,1),.85)
		hug.tween_property(mother.head,"rotation:x",.48,.85)

func prompt_phase() -> void:
	var mole:bool=story.id()=="mole_candles"
	match story.part:
		0:
			story.say("mole_intro" if mole else "nest_total")
			story.button("Dalej",story.go_to.bind(story.id(),1))
		1:
			restore_numbers(story.marks)
			story.say("mole_count" if mole else "nest_count")
		2:
			restore_numbers((1<<tokens.size())-1)
			story.say("mole_ask" if mole else "nest_ask")
			var missing:=unlit.size()
			var choices:=[missing-1,missing,missing+1] if mole else [1,2,3]
			choices.shuffle()
			for n in choices: story.button(str(n),answer.bind(n))
		3:
			if mole: story.say("mole_done")
			else: story.say("nest_hug_two" if empty_seats.size()==2 else "nest_hug")
			story.button("Dalej",story.advance)

func _input(event:InputEvent) -> void:
	if not is_visible_in_tree() or game.paused or story.part!=1 or tokens.is_empty(): return
	if not (event is InputEventScreenTouch and event.pressed): return
	if story.dock.get_global_rect().has_point(event.position): return
	var best:=-1
	var radius:=34.0
	for i in tokens.size():
		var d:float=game.camera.unproject_position(tokens[i].global_position).distance_to(event.position)
		if d<radius:
			best=i
			radius=d
	if best<0 or story.marks & (1<<best): return
	story.marks|=1<<best
	restore_numbers(story.marks)
	var count:=0
	for i in tokens.size():
		if story.marks & (1<<i): count+=1
	story.effect("count_%d"%count)
	if count==tokens.size(): story.go_to(story.id(),2)
	else: story.checkpoint()

func restore_numbers(mask:int) -> void:
	var order:Array=story.touch_order(mask,tokens.size())
	for i in order: Count.mark(tokens[i],order.find(i)+1,false,.65)

func reset_lights() -> void:
	for i in lights.size(): lights[i].visible=(initial_lights & (1<<i))!=0

func hint(count:int) -> void:
	if story.id()=="mole_candles":
		reset_lights()
		if count>0: Count.mark(tokens[unlit[count-1]],count,true,.65)
	elif count>0:
		Count.mark(empty_seats[count-1],count,true,.6)

func answer(n:int) -> void:
	if game.paused or trial!=0 or story.part!=2: return
	if story.id()=="dragon_nest":
		if n==empty_seats.size(): story.go_to("dragon_nest",3)
		else:
			for seat in empty_seats: seat.create_tween().tween_property(seat,"scale:y",.64,.24).from(.38)
			story.say("nest_retry")
			story.hint_miss(empty_seats.size(),hint)
		return
	trial=n
	sneezes=0
	timer=0
	if story.hint_total>0: story.clear_hint()
	reset_lights()
	hat.rotation.z=0
	hat.material_override.albedo_color=Color.DARK_CYAN
	for b in story.options.get_children():
		if b.text.is_valid_int(): b.disabled=true

func _process(dt:float) -> void:
	if not is_visible_in_tree() or game.paused: return
	if story.id()=="dragon_flight":
		elapsed=minf(elapsed+dt,FLIGHT_TIME)
		fly(elapsed)
		if elapsed>=FLIGHT_TIME and story.age>=story.speech_end: end_chapter()
		return
	if trial==0: return
	timer-=dt
	if timer>0: return
	if sneezes<trial:
		var target:Node3D=lights[unlit[sneezes]] if sneezes<unlit.size() else hat
		dragon.look_at(Vector3(target.global_position.x,dragon.global_position.y,target.global_position.z),Vector3.UP,true)
		var puff=game.orb(self,to_local(spark.global_position),.20,Color.ORANGE_RED,true)
		var flight=puff.create_tween()
		flight.tween_property(puff,"global_position",target.global_position,.23)
		if target==hat:
			flight.tween_callback(func(): hat.material_override.albedo_color=Color("#403533"))
			flight.tween_property(hat,"rotation:z",.48,.12)
		else:
			flight.tween_callback(target.show)
			flight.tween_callback(story.effect.bind("count_%d"%(sneezes+1)))
		flight.tween_callback(puff.queue_free)
		sneezes+=1
		timer=SNEEZE_INTERVAL
	else:
		var result:=trial
		trial=0
		if result==unlit.size(): story.go_to("mole_candles",3)
		else:
			story.say("mole_low" if result<unlit.size() else "mole_high")
			story.hint_miss(unlit.size(),hint)
			for b in story.options.get_children(): b.disabled=false

func build_flight() -> void:
	game.hud.text="Lot nad doliną"
	story.square.show()
	var village:Vector3=story.square.global_position
	var crossing:=village+Vector3(2,.07,5.8)
	game.box(self,to_local(crossing),Vector3(2.5,.09,16),Color("#6ba9b5"))
	for i in game.boards.size():
		var plank=game.boards[i].duplicate()
		add_child(plank)
		plank.global_position=crossing+Vector3((i-2)*.57,.18,0)
		plank.rotation.y=PI/2
		plank.show()
	build_mother()
	flight_from=village+Vector3(-7,3.6,-2.4)
	flight_to=story.stone_hill.global_position+Vector3(0,3.6,0)
	mother.rotation.y=PI*.5
	game.camera.size=13
	if story.part==1: elapsed=FLIGHT_TIME
	fly(elapsed)
	story.say("dragon_flight")

func fly(t:float) -> void:
	var fraction:=t/FLIGHT_TIME
	var crossing:Vector3=story.square.global_position+Vector3(2,4.5,6)
	var at:=flight_from.lerp(crossing,fraction*2) if fraction<.5 else crossing.lerp(flight_to,(fraction-.5)*2)
	mother.global_position=at+Vector3.UP*sin(t*2.3)*.14
	for wing in mother.wings: wing.rotation.x=.7*sin(t*4.5)
	game.leo.global_position=mother.to_global(Vector3(0,.88,-.24))
	dragon.global_position=mother.to_global(Vector3(0,.87,.12))
	var focus:=at-Vector3.UP*1.55
	game.camera.look_at_from_position(focus+Vector3(2,11,9),focus,Vector3.UP)

func end_chapter() -> void:
	story.chapters=maxi(story.chapters,3)
	if "Latarka" not in story.items: story.items.append("Latarka")
	story.advance()
