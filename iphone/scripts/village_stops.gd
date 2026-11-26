extends RefCounted

const WOOD := Color("#9c724b")
const STRAW := Color("#e5bb65")
const TARGETS := [Vector3(.62,.77,-.52),Vector3(2.18,1.17,-.88)]

static func shelf(host,parent:Node3D,at:Vector3) -> void:
	host.box(parent,at+Vector3.UP*.62,Vector3(1.04,.13,.69),WOOD)
	host.box(parent,at+Vector3.UP*.21,Vector3(1.04,.09,.69),WOOD)
	for x in [-.43,.43]:
		for z in [-.25,.25]: host.box(parent,at+Vector3(x,.35,z),Vector3(.09,.7,.1),WOOD.darkened(.14))

static func building(host,parent:Node3D,kind:String) -> void:
	var at:=Vector3(0,0,-1.5)
	host.box(parent,at+Vector3.UP*1.14,Vector3(3,2.28,2.4),Color("#d8ab77"))
	var roof:Color={"mill":Color("#8d7566"),"coop":Color("#be794c"),"dairy":Color("#868f97"),"delivery":Color("#68915c")}.get(kind,WOOD)
	for side in [-1,1]:
		host.box(parent,at+Vector3(side*.82,2.59,0),Vector3(1.99,.24,2.85),roof).rotation.z=-side*.39
	var gable:=PrismMesh.new()
	gable.size=Vector3(3.25,.72,2.45)
	host.mesh(parent,gable,at+Vector3.UP*2.55,Color("#d8ab77"))
	for x in [-1.16,1.16]:
		host.box(parent,at+Vector3(x,1.21,1.23),Vector3(.53,.64,.08),WOOD)
		host.box(parent,at+Vector3(x,1.21,1.29),Vector3(.40,.49,.04),Color("#efd799"))
		host.box(parent,at+Vector3(x,1.21,1.33),Vector3(.055,.52,.035),WOOD)
	if kind in ["delivery","mill"]:
		host.box(parent,at+Vector3(1.02,2.7,-.57),Vector3(.43,1.05,.43),Color("#a47965"))
	host.box(parent,at+Vector3(0,.85,1.22),Vector3(1.08,1.7,.08),Color("#514335"))
	if kind=="mill":
		var wheel=preload("res://scripts/river_props.gd").new()
		parent.add_child(wheel)
		wheel.setup(host)
		wheel.build("wheel")
		wheel.position=Vector3(1.52,.03,-.11)
	elif kind=="coop":
		for i in 3: host.box(parent,Vector3(0,.12+i*.12,.97-i*.33),Vector3(.85,.12,.28),WOOD)
	elif kind=="dairy":
		for x in [-1,1]: host.box(parent,Vector3(x*.33,.92,-.20),Vector3(.12,1.81,.08),STRAW).rotation.z=x*.37

static func interior(story,kind:String) -> void:
	var host=story.host
	var room:Node3D=story.scene
	host.box(room,Vector3(0,-.15,0),Vector3(11,.3,9),Color("#ab8454"))
	host.box(room,Vector3(0,1.42,-2.83),Vector3(10,2.84,.25),Color("#d5ac7b"))
	for x in [-3.8,-.5,3.8]: host.box(room,Vector3(x,1.5,-2.63),Vector3(.22,3,.25),WOOD)
	for x in range(-5,6):
		host.box(room,Vector3(x,.006,0),Vector3(.025,.012,8),WOOD.darkened(.1))
	if kind=="mill":
		for x in [-3.45,-2.73]: story.actor("flour",Vector3(x,.02,-1.26),.82)
		story.actor("wheel",Vector3(-2.2,.2,-2.32),1.26)
		for point in TARGETS:
			host.box(room,Vector3(point.x,(point.y+2.9)*.5,point.z),Vector3(.035,2.9-point.y,.035),Color.IVORY)
	elif kind=="coop":
		for x in [-1.8,.1,1.85]:
			host.orb(room,Vector3(x,.3,-1.45),.64,STRAW).scale=Vector3(1.2,.47,.9)
			host.orb(room,Vector3(x,.75,-1.65),.36,Color.IVORY)
			host.orb(room,Vector3(x+.22,1.05,-1.49),.21,Color.IVORY)
			host.orb(room,Vector3(x+.30,1.25,-1.49),.09,Color.INDIAN_RED)
			host.box(room,Vector3(x+.32,1.03,-1.30),Vector3(.12,.09,.19),STRAW)

static func lanterns(host,parent:Node3D,lit:bool) -> void:
	for x in [-2.65,-1.55,-.55,.55,1.65,2.75]:
		var lamp:=Node3D.new()
		parent.add_child(lamp)
		host.box(lamp,Vector3(x,.5,-.1),Vector3(.12,1,.12),WOOD)
		host.box(lamp,Vector3(x,1.35,-.1),Vector3(.42,.09,.42),WOOD)
		host.orb(lamp,Vector3(x,1.14,-.1),.27,Color("#ffda75") if lit else Color("#d4b897"),lit)
		host.box(lamp,Vector3(x,.94,-.1),Vector3(.42,.08,.42),WOOD)
		for edge in [-1,1]:
			host.box(lamp,Vector3(x+edge*.19,1.15,.05),Vector3(.04,.43,.045),WOOD)
		if lit:
			var light:=OmniLight3D.new()
			lamp.add_child(light)
			light.position=Vector3(x,1.22,-.1)
			light.light_color=Color("#ffe2a0")
			light.omni_range=2.6
