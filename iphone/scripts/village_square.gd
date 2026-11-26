extends Node3D

const Stops := preload("res://scripts/village_stops.gd")
const DOORS := {"mill":Vector3(-6,0,-2.8),"coop":Vector3(3.7,0,-3.8),"dairy":Vector3(-6.4,0,3.1),"delivery":Vector3(5.6,0,3.0)}
const FOOD := {"mill":"Mąka","coop":"Jajka","dairy":"Mleko"}
const NAMES := {"mill":"Młyn","coop":"Kurnik","dairy":"Obora","delivery":"Chatka Wiewiórki"}
const ENTRY := Vector3(1.8,0,4.0)
const GREEN := Color("#92ae6e")
const PATH := Color("#d6b78d")
var game
var mill_wheel:Node3D
var lit_lanterns:=Node3D.new()
var unlit_lanterns:=Node3D.new()

func setup(host) -> void:
	game=host
	position=Vector3(310,0,0)
	host.box(self,Vector3(0,-.24,0),Vector3(56,.46,38),GREEN)
	path_between(Vector3(0,0,-4),Vector3(0,0,8),2.1)
	path_between(Vector3(0,0,.45),Vector3(14,0,.45),1.55)
	for key in DOORS:
		var door:Vector3=DOORS[key]
		path_between(Vector3(0,0,door.z+.55),door+Vector3.BACK*.55,1.55)
		var house:=Node3D.new()
		add_child(house)
		house.position=door
		Stops.building(host,house,key)
		match key:
			"mill":
				var wheel=house.get_child(-1)
				mill_wheel=Node3D.new()
				wheel.add_child(mill_wheel)
				mill_wheel.position=Vector3.UP
				wheel.prop.reparent(mill_wheel,true)
				for x in [-1.48,-1.05]:
					var sack=preload("res://scripts/river_props.gd").new()
					house.add_child(sack)
					sack.setup(host)
					sack.build("flour")
					sack.position=Vector3(x,0,.28)
					sack.scale=Vector3.ONE*.46
			"coop":
				for x in [-1.36,1.42]:
					host.orb(house,Vector3(x,.28,.18),.29,Color.IVORY)
					host.orb(house,Vector3(x+.16,.52,.27),.17,Color.IVORY)
					host.orb(house,Vector3(x+.16,.68,.27),.08,Color.INDIAN_RED)
			"dairy":
				for i in 3:
					host.box(house,Vector3(-1.56,.25+i*.24,.05),Vector3(.77,.25,.62),Stops.STRAW)
			"delivery":
				host.orb(house,Vector3(0,1.85,-.12),.45,Color("#c78b4c")).scale=Vector3(.81,1,.34)
				host.orb(house,Vector3(0,2.13,-.10),.48,Color("#785337")).scale=Vector3(1,.55,.4)
				host.orb(house,Vector3(1.19,1.56,-.17),.18,Color("#ffcc70"),true)
	for lamps in [unlit_lanterns,lit_lanterns]:
		add_child(lamps)
		Stops.lanterns(host,lamps,lamps==lit_lanterns)
	for i in 32:
		var x:float=sin(i*5.7)*.61
		var z:float=-4.1+i*.35
		host.orb(self,Vector3(x,.025,z),.18+fmod(i*.12,.19),Color("#bbac91")).scale=Vector3(1.3,.085,.83)
	for i in 28:
		var x:float=(-1 if i%2==0 else 1)*(9.45+sin(i*1.3)*.68)
		var z:float=-8.3+(i/2)*1.14
		if x>0 and absf(z-.45)<1.1: continue
		host.box(self,Vector3(x,.52,z),Vector3(.28,1.05,.24),Stops.WOOD)
		if i<26: host.box(self,Vector3(x,.68,z+.55),Vector3(.11,.13,1.26),Stops.WOOD)
	for i in 22:
		var x:float=fmod(i*2.91,19)-9.4
		var z:float=-7.6 if i%2==0 else 8.4
		tree(Vector3(x,0,z+sin(i*2.1)*.48),.77+.11*(i%4))
	for at in [Vector3(-3.65,0,2.5),Vector3(2.85,0,1.24),Vector3(6.2,0,-2.75),Vector3(-2.95,0,-1.7)]:
		for i in 8:
			var p:Vector3=at+Vector3(cos(i*2.4),0,sin(i*2.4))*(.2+.05*i)
			host.orb(self,p+Vector3.UP*.17,.105,Color("#f3c74c") if i%2 else Color("#d891ae"))
	hide()

func path_between(a:Vector3,b:Vector3,width:float) -> void:
	var length:=a.distance_to(b)
	var lane=game.box(self,(a+b)*.5,Vector3(width,.042,length+width*.58),PATH)
	lane.rotation.y=atan2(b.x-a.x,b.z-a.z)

func tree(at:Vector3,s:float) -> void:
	game.box(self,at+Vector3.UP*.64*s,Vector3(.3,1.28,.29)*s,Stops.WOOD)
	game.orb(self,at+Vector3.UP*1.7*s,1.05*s,Color("#608954")).scale.y=1.25

func camera_at(local:Vector3) -> void:
	var focus:=position+Vector3(local.x*.23,0,local.z*.22-.28)
	var camera:Camera3D=game.camera
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect=Camera3D.KEEP_HEIGHT
	camera.size=maxf(13.4,21.4/maxf(1.0,game.ui.size.aspect()))
	camera.look_at_from_position(focus+Vector3(0,15,9.4),focus,Vector3.UP)

func can_walk(at:Vector3) -> bool:
	if absf(at.x)>8.8 or at.z < -6.5 or at.z>5.95: return false
	for door:Vector3 in DOORS.values():
		var d:=at-door
		if absf(d.x)<1.7 and d.z<-.15 and d.z> -2.97: return false
	return true

func near_door(at:Vector3) -> String:
	for key in DOORS:
		if at.distance_to(DOORS[key]+Vector3.BACK*.42)<1.23: return key
	return ""

func _process(dt:float) -> void:
	if visible and not game.paused:
		# The axle is one unit above the mill wheel model's origin.
		if mill_wheel: mill_wheel.rotation.z+=dt*.28

func show_lamps(total:int) -> void:
	for i in lit_lanterns.get_child_count():
		lit_lanterns.get_child(i).visible=i<total
		unlit_lanterns.get_child(i).visible=i>=total
