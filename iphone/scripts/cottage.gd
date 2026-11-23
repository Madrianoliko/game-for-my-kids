extends Node3D

var game
var room := Node3D.new()
var sword := Node3D.new()

func build(host) -> void:
	game = host
	build_fox()
	build_room()
	game.leo.add_child(sword)
	sword.position = Vector3(.45,.92,.16)
	game.box(sword,Vector3(0,.36,0),Vector3(.11,.76,.07),Color("#c4ebff"))
	game.box(sword,Vector3.ZERO,Vector3(.34,.08,.10),Color("#ffa935"))
	game.box(sword,Vector3(0,-.11,0),Vector3(.08,.18,.08),Color("#714321"))
	reset()

var fox := Node3D.new()

func build_fox() -> void:
	add_child(fox)
	fox.position = game.point(-18,-1.45)
	var fur := Color("#d57935")
	game.orb(fox,Vector3(0,.46,0),.38,fur).scale.y=1.25
	game.orb(fox,Vector3(0,.96,.05),.31,fur)
	game.orb(fox,Vector3(0,.85,.29),.17,Color("#fff1d3"))
	game.orb(fox,Vector3(0,.89,.43),.06,Color("#3d3132"))
	for side in [-1,1]:
		var ear := CylinderMesh.new()
		ear.top_radius=0
		ear.bottom_radius=.14
		ear.height=.34
		game.mesh(fox,ear,Vector3(side*.2,1.25,.02),fur)
		game.orb(fox,Vector3(side*.13,1,.31),.04,Color("#362c25"))
	var tail = game.orb(fox,Vector3(.42,.36,-.13),.27,fur)
	tail.scale=Vector3(.75,1.8,.72)
	tail.rotation.z=-.72
	game.orb(fox,Vector3(.65,.65,-.13),.15,Color("#fff1d3"))

func build_room() -> void:
	add_child(room)
	room.position = Vector3(110,0,0)
	var timber := Color("#82512e")
	game.box(room,Vector3(0,-.15,0),Vector3(9,.3,10),timber)
	game.box(room,Vector3(0,2,-3),Vector3(9,4,.25),Color("#e4bd83"))
	for x in [-4,4]:
		game.box(room,Vector3(x,2,0),Vector3(.24,4,7),Color("#dbaf78"))
	for x in [-3.6,-1.25,1.25,3.6]:
		game.box(room,Vector3(x,1.95,-2.8),Vector3(.22,4,.28),timber)
	game.box(room,Vector3(0,3.5,-2.8),Vector3(8,.21,.3),timber)
	game.orb(room,Vector3(-2.4,2,-2.77),.82,timber).scale.z=.18
	game.orb(room,Vector3(-2.4,2,-2.64),.68,Color("#8dd3dd"),true).scale.z=.1
	game.box(room,Vector3(-2.4,2,-2.54),Vector3(.07,1.4,.08),timber)
	game.box(room,Vector3(-2.4,2,-2.54),Vector3(1.4,.07,.08),timber)
	game.box(room,Vector3(2.35,.8,-2.1),Vector3(1.9,1.6,1.15),Color("#987b69"))
	game.box(room,Vector3(2.35,.55,-1.51),Vector3(1.12,.9,.06),Color("#50352c"))
	game.orb(room,Vector3(2.35,.48,-1.40),.34,Color("#ffaf47"),true)
	game.box(room,Vector3(0,.8,0),Vector3(2.6,.2,1.4),timber)
	for x in [-1,1]:
		for z in [-.5,.5]:
			game.box(room,Vector3(x,.39,z),Vector3(.17,.78,.17),timber)
	var lamp := OmniLight3D.new()
	room.add_child(lamp)
	lamp.position=Vector3(1,2.8,1)
	lamp.light_color=Color("#ffcd86")
	lamp.omni_range=7
	lamp.light_energy=1.6

func reset() -> void:
	sword.hide()
	room.hide()
