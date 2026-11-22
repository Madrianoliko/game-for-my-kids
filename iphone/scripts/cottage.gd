extends Node3D

var game
var raiders: Array[Node3D] = []
var room := Node3D.new()
var basket := Node3D.new()
var sword := Node3D.new()
var swing: Tween
var slit := Node3D.new()
var remaining := 0

func build(host) -> void:
	game = host
	build_fox()
	build_door()
	build_room()
	for side in [-1,1]:
		var orc := Node3D.new()
		add_child(orc)
		raiders.append(orc)
		game.orb(orc,Vector3(0,.7,0),.52,Color("#654966")).scale = Vector3(.86,1.1,.65)
		game.orb(orc,Vector3(0,1.38,0),.38,Color("#83ab73"))
		for hand in [-1,1]:
			game.orb(orc,Vector3(hand*.36,1.46,0),.14,Color("#83ab73")).scale = Vector3(1.5,.65,.55)
			game.orb(orc,Vector3(hand*.15,1.43,.31),.045,Color("#322e38"))
			game.box(orc,Vector3(hand*.2,.21,0),Vector3(.25,.42,.32),Color("#473943"))
			game.orb(orc,Vector3(hand*.46,.78,.08),.17,Color("#83ab73"))
			game.box(orc,Vector3(hand*.13,1.24,.33),Vector3(.06,.09,.05),Color("#ffedcc"))
		game.orb(orc,Vector3(0,1.63,0),.34,Color("#626781")).scale.y=.52
	game.leo.add_child(sword)
	sword.position = Vector3(.45,.92,.16)
	game.box(sword,Vector3(0,.36,0),Vector3(.11,.76,.07),Color("#c4ebff"))
	game.box(sword,Vector3.ZERO,Vector3(.34,.08,.10),Color("#ffa935"))
	game.box(sword,Vector3(0,-.11,0),Vector3(.08,.18,.08),Color("#714321"))
	game.leo.add_child(slit)
	for i in 9:
		var angle := -.95+i*.24
		var spark = game.orb(slit,Vector3(sin(angle)*1.15,1.02,cos(angle)*1.15),.08,Color("#ffed91"),true)
		spark.scale = Vector3(1.75,.5,1)
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

func build_door() -> void:
	var hut := Node3D.new()
	add_child(hut)
	hut.position=game.point(-53)
	game.orb(hut,Vector3(0,.55,0),2.5,Color("#719448")).scale=Vector3(1.4,.89,.8)
	game.orb(hut,Vector3(0,1.1,1.61),1.22,Color("#bc9869")).scale.z=.28
	game.orb(hut,Vector3(0,1.08,1.84),1.03,Color("#536d40")).scale.z=.22
	game.orb(hut,Vector3(.58,1.05,2.05),.11,Color("#ffce68"),true)
	game.box(hut,Vector3(1.45,2.4,-.2),Vector3(.6,1.5,.6),Color("#985d47"))
	for side in [-1,1]:
		game.orb(hut,Vector3(side*1.85,1.13,1.44),.44,Color("#ffcf77"),true).scale.z=.35

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
	room.add_child(basket)
	basket.position.y=.92
	game.orb(basket,Vector3(0,.08,0),.55,Color("#ca9d55")).scale=Vector3(1,.36,.8)
	for x in [-.27,0,.27]:
		game.orb(basket,Vector3(x,.28,x*.45),.19,Color("#dc4b36"))
	var lamp := OmniLight3D.new()
	room.add_child(lamp)
	lamp.position=Vector3(1,2.8,1)
	lamp.light_color=Color("#ffcd86")
	lamp.omni_range=7
	lamp.light_energy=1.6

func reset() -> void:
	if swing: swing.kill()
	for orc in raiders: orc.hide()
	sword.hide()
	slit.hide()
	room.hide()
	basket.hide()
	remaining=0

func ambush() -> void:
	remaining=raiders.size()
	game.leo.rotation.y=PI
	for i in raiders.size():
		var side := -1 if i==0 else 1
		var orc := raiders[i]
		orc.position=game.leo.position+Vector3(side*2.9,0,-3)
		orc.show()
		var tween := orc.create_tween()
		tween.tween_property(orc,"position",game.leo.position+Vector3(side*.88,0,-1.3),.45)
	sword.show()

func strike() -> void:
	var orc := raiders[raiders.size()-remaining]
	remaining-=1
	slit.show()
	sword.rotation.z=-1.15
	swing=create_tween()
	swing.tween_property(sword,"rotation:z",1.2,.19)
	swing.parallel().tween_property(orc,"position",orc.position+Vector3(-3 if remaining==1 else 3,.35,-2),.34)
	swing.tween_callback(orc.hide)
	swing.tween_callback(slit.hide)
	swing.tween_property(sword,"rotation:z",0,.12)

func enter() -> void:
	room.show()
	game.leo.position=room.position+Vector3(-1.75,0,.22)
	game.leo.rotation.y=1.1
	game.camera.position=room.position+Vector3(0,2.4,4.8)
	game.camera.look_at(room.position+Vector3(0,1.24,-.25))
