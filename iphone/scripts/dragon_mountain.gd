extends "res://scripts/iskierka.gd"

const MISSING := [5,2,7]
const ROCK := Color("#899395")
const GOLD := Color("#ffbc40")
const HOPS := [Vector3(-2.8,.15,.9),Vector3(-2.2,.16,-.15),Vector3(-2.8,.18,-1.25)]
var rocks:Array[MeshInstance3D]=[]
var sockets:Array[MeshInstance3D]=[]
var piles:Array[Node3D]=[]
var bush:Node3D
var busy:=false
var large_side:int
var trembling:Tween
var fire:MeshInstance3D

func setup(owner_story) -> void:
	story=owner_story
	game=story.host
	var focus:=global_position+Vector3(0,0,1.45)
	game.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	game.camera.size=8.6
	game.camera.look_at_from_position(focus+Vector3(0,10,6),focus,Vector3.UP)
	var cave:bool=story.id()=="warm_cave"
	game.box(self,Vector3(0,-.23,0),Vector3(18,.45,14),Color("#786652") if cave else Color("#97a073"))
	for i in 7:
		var crag=game.orb(self,Vector3(i*1.9-5.7,0,-3.9),1.55,Color("#685e5a") if cave else ROCK)
		crag.scale.y=2.0 if cave else 1.4
	dragon=Node3D.new()
	add_child(dragon)
	build_dragon()
	dragon.position=Vector3(-.8,0,1.0)
	game.leo.global_position=to_global(Vector3(.25,0,1.1))
	match story.id():
		"mountain_fork": build_trails()
		"mountain_steps": build_steps()
		"warm_cave": build_cave()

func build_trails() -> void:
	game.hud.text="U stóp góry"
	game.box(self,Vector3(-2.6,.02,-.5),Vector3(2.35,.06,5),Color("#599eaf"))
	for at in HOPS:
		var rock=game.orb(self,at,.58,ROCK)
		rock.scale.y=.36
		rocks.append(rock)
	bush=Node3D.new()
	add_child(bush)
	bush.position=Vector3(2.55,0,-.45)
	for i in 3:
		var twig=game.orb(bush,Vector3((i-1)*.5,.55,(i%2)*.32),.7,Color("#506b43"))
		for j in 3: game.orb(twig,Vector3((j-1)*.27,.43,.4),.115,Color("#47304e"))
	match story.part:
		0: story.say("mountain_choose")
		1:
			story.say("mountain_jump")
			if story.marks>0: place_pair(HOPS[story.marks-1])
			tint(rocks[story.marks],GOLD)
		2:
			place_pair(bush.position+Vector3.BACK*1.15)
			story.say("mountain_burn")
			story.button("Płomień",burn)

func place_pair(at:Vector3) -> void:
	game.leo.global_position=to_global(at)
	dragon.position=at+Vector3.LEFT*.72

func tint(node:MeshInstance3D,color:Color) -> void:
	node.material_override.albedo_color=color

func burn() -> void:
	if busy or game.paused: return
	busy=true
	breathe(bush.position+Vector3.UP*.55)
	var charred=create_tween()
	charred.tween_interval(.3)
	charred.tween_property(bush,"scale",Vector3(.9,.08,.9),.5)
	charred.tween_callback(story.advance)

func breathe(at:Vector3) -> void:
	dragon.look_at(to_global(Vector3(at.x,dragon.position.y,at.z)),Vector3.UP,true)
	var puff=game.orb(self,to_local(spark.global_position),.26,Color.ORANGE_RED,true)
	var flight=create_tween()
	flight.tween_property(puff,"position",at,.27)
	flight.tween_callback(puff.queue_free)

func hop() -> void:
	busy=true
	var at:Vector3=HOPS[story.marks]
	var start:Vector3=game.leo.global_position
	var jump=create_tween()
	jump.tween_method(func(t:float):
		game.leo.global_position=start.lerp(to_global(at),t)+Vector3.UP*sin(t*PI)*.65
		dragon.position=to_local(game.leo.global_position)+Vector3.LEFT*.72
	,.0,1.0,.43)
	jump.tween_callback(func():
		if story.marks+1==HOPS.size(): story.advance()
		else: story.go_to("mountain_fork",1,story.marks+1)
	)

func slot_at(n:int) -> Vector3:
	return Vector3((n-4.5)*1.04,.13+n*.085,-1.25)

func tray_at(i:int) -> Vector3:
	return Vector3((i-1)*1.7,.23,.8)

func build_steps() -> void:
	game.hud.text="Kamienne stopnie"
	place_pair(Vector3(-4.4,0,.85))
	for n in range(1,9):
		var at:=slot_at(n)
		var base=game.box(self,Vector3(at.x,at.y*.5,at.z),Vector3(1,at.y,1.15),Color("#524b43"))
		sockets.append(base)
		var i:=MISSING.find(n)
		var fitted:bool=i>=0 and (story.marks & (1<<i))!=0
		var pos:=at if i<0 or fitted else tray_at(i)
		var slab=game.box(self,pos,Vector3(.96,.22,1.06),ROCK)
		if fitted: light_step(slab)
		rocks.append(slab)
		for j in n:
			var dot=game.orb(slab,Vector3((j%2-.5)*.37,.125,(floori(j/2.0)-(ceili(n/2.0)-1)*.5)*.23),.083,Color("#212730"))
			dot.scale.y=.36
	if story.marks==7:
		story.say("mountain_ready")
		story.button("Dalej",story.advance)
	else: story.say("mountain_steps")

func light_step(rock:MeshInstance3D) -> void:
	tint(rock,GOLD)
	rock.material_override.emission_enabled=true
	rock.material_override.emission=GOLD

func fit(i:int,n:int) -> void:
	var expected:int=MISSING[i]
	var rock:=rocks[expected-1]
	if expected==n:
		rock.position=slot_at(n)
		light_step(rock)
		story.marks|=1<<i
		story.checkpoint()
		if story.marks==7: story.render()
	else:
		mistakes+=1
		rock.position=slot_at(n)
		busy=true
		var wobble=create_tween()
		for angle in [.18,-.18,.0]: wobble.tween_property(rock,"rotation:z",angle,.09)
		wobble.tween_property(rock,"position",tray_at(i),.19)
		wobble.tween_callback(func(): busy=false)
		if mistakes>=2: tint(sockets[expected-1],GOLD)
		story.say("mountain_help" if mistakes>=2 else "mountain_wobble")

func build_cave() -> void:
	game.hud.text="Ciepła jaskinia"
	if not story.numbers.has("coal_side"):
		story.numbers["coal_side"]=randi_range(0,1)
		story.checkpoint()
	large_side=story.numbers.coal_side
	for side in 2:
		var pile:=Node3D.new()
		add_child(pile)
		pile.position=Vector3(-2.1 if side==0 else 2.1,.18,-.8)
		piles.append(pile)
		var count:=5 if side==large_side else 2
		for j in count:
			var dx:float=(j%3-(mini(count,3)-1)*.5)*.53
			game.orb(pile,Vector3(dx,.04,floori(j/3.0)*.56),.27,Color("#332d39"))
	fire=game.orb(self,Vector3.ZERO,.54,Color.ORANGE,true)
	game.orb(fire,Vector3(0,.48,0),.33,Color.GOLD,true)
	fire.visible=story.part==1
	if story.part==1:
		show_fire(large_side)
		story.say("mountain_warm")
		story.button("Dalej",finish)
	else:
		shiver()
		story.say("mountain_coal")

func shiver() -> void:
	if trembling: trembling.kill()
	trembling=head.create_tween().set_loops()
	trembling.tween_property(head,"rotation:z",.095,.08)
	trembling.tween_property(head,"rotation:z",-.095,.08)

func show_fire(side:int) -> void:
	fire.position=piles[side].position+Vector3.UP*.42
	fire.scale=Vector3(1.15,1.8,1.15) if side==large_side else Vector3(.35,.54,.35)
	fire.show()

func choose_coal(side:int) -> void:
	busy=true
	breathe(piles[side].position)
	var flight=create_tween()
	flight.tween_interval(.27)
	flight.tween_callback(func():
		if side==large_side: story.go_to("warm_cave",1)
		else:
			show_fire(side)
			shiver()
			mistakes+=1
			if mistakes>=2:
				for coal in piles[large_side].get_children(): tint(coal,Color.PERU)
			story.say("mountain_point" if mistakes>=2 else "mountain_cold")
			busy=false
	)

func nearest(nodes:Array,xy:Vector2,radius:float) -> int:
	var best:=-1
	for i in nodes.size():
		var dist:float=game.camera.unproject_position(nodes[i].global_position).distance_to(xy)
		if dist<radius:
			radius=dist
			best=i
	return best

func _input(event:InputEvent) -> void:
	if not is_visible_in_tree() or game.paused or busy: return
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag): return
	if event is InputEventScreenTouch and event.pressed:
		if finger!=-1 or story.dock.get_global_rect().has_point(event.position): return
		match story.id():
			"mountain_fork":
				var stone:=nearest(rocks,event.position,45)
				if story.part==0:
					if stone>=0: story.go_to("mountain_fork",1)
					elif nearest([bush],event.position,65)==0: story.go_to("mountain_fork",2)
				elif story.part==1 and stone==story.marks: hop()
			"mountain_steps":
				var i:=MISSING.find(nearest(rocks,event.position,32)+1)
				if i>=0 and (story.marks & (1<<i))==0:
					held=i
					finger=event.index
			"warm_cave":
				var side:=nearest(piles,event.position,65)
				if story.part==0 and side>=0: choose_coal(side)
	elif finger==event.index and held>=0:
		var rock:=rocks[MISSING[held]-1]
		if event is InputEventScreenDrag:
			var hit=Plane(Vector3.UP,.9).intersects_ray(game.camera.project_ray_origin(event.position),game.camera.project_ray_normal(event.position))
			if hit!=null: rock.global_position=hit
		else:
			var n:=nearest(sockets,event.position,36)+1
			var i:=held
			held=-1
			finger=-1
			if n>0 and not event.canceled: fit(i,n)
			else: rock.position=tray_at(i)
