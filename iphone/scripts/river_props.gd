extends Node3D

var host
var prop := Node3D.new()
var scenery := Node3D.new()
var tracks: Array[Node3D] = []
var moving: Node3D
var tool: Node3D
var helmet: Node3D
var beam: Node3D
var net: Node3D
var hoof: Node3D
var wool: MeshInstance3D
const WOOD := Color("#ab784b")
const GOLD := Color("#f7c85f")
const WHITE := Color("#f5dfb4")
const GREEN := Color("#709d70")

func setup(game) -> void:
	host=game
	add_child(prop)
	add_child(scenery)

func ball(p: Vector3, radius: float, color: Color, stretch:=Vector3.ONE) -> MeshInstance3D:
	var obj: MeshInstance3D=host.orb(prop,p,radius,color)
	obj.scale=stretch
	return obj

func block(p: Vector3, dims: Vector3, color: Color) -> MeshInstance3D:
	return host.box(prop,p,dims,color)

func clear_props() -> void:
	tool=null
	helmet=null
	beam=null
	net=null
	hoof=null
	wool=null
	tracks.clear()
	for child in prop.get_children()+scenery.get_children():
		child.get_parent().remove_child(child)
		child.queue_free()
	prop.position=Vector3.ZERO
	prop.rotation=Vector3.ZERO
	prop.scale=Vector3.ONE
	moving=prop

func eyes(y:float,z:float,separation:float) -> void:
	for sign_x in [-1,1]:
		ball(Vector3(sign_x*separation,y,z),.065,Color("#30252c"))

func critter(kind: String) -> void:
	var fur := GREEN
	if kind=="badger": fur=Color("#696d79")
	if kind=="ram": fur=Color("#939887")
	if kind=="troll": fur=Color("#709eab")
	wool=ball(Vector3(0,.6,0),.57,fur,Vector3(1.1,1,.8))
	ball(Vector3(0,1.38,.05),.49,fur)
	eyes(1.44,.49,.19)
	for side in [-1,1]:
		ball(Vector3(side*.29,.13,.12),.2,fur)
		ball(Vector3(side*.51,1.48,.05),.16,fur)
	if kind=="ram":
		for side in [-1,1]:
			var horn:=TorusMesh.new()
			horn.inner_radius=.14
			horn.outer_radius=.29
			var obj=host.mesh(prop,horn,Vector3(side*.44,1.61,.16),WOOD)
			obj.rotation.x=PI/2
		tool=ball(Vector3(0,.87,.49),.15,GOLD)
		hoof=ball(Vector3(.4,.36,.3),.15,Color("#686753"),Vector3(1,1,1.4))
	elif kind=="badger":
		ball(Vector3(0,1.4,.46),.18,WHITE,Vector3(.55,1.7,.6))
	elif kind=="troll":
		ball(Vector3(0,1.27,.54),.19,Color("#a7c2ae"))
	else:
		helmet=ball(Vector3(0,1.75,.02),.46,GOLD if kind=="chief" else Color("#68758b"),Vector3(1,.5,1))
		if kind=="shield":
			ball(Vector3(.48,.87,.42),.44,WOOD,Vector3(1,1,.3))

func build(kind:String) -> void:
	clear_props()
	match kind:
		"gear_0":
			block(Vector3(0,.33,0),Vector3(.38,.55,.32),WOOD)
			ball(Vector3(0,.65,0),.23,GOLD)
		"gear_1","gear_5":
			var loop:=TorusMesh.new()
			loop.inner_radius=.35
			loop.outer_radius=.43
			var hoop=host.mesh(prop,loop,Vector3(0,.5,0),WOOD)
			hoop.rotation.x=PI/2
			if kind=="gear_5":
				hoop.scale.x=.6
				block(Vector3(0,.5,.04),Vector3(.025,.84,.035),WHITE)
		"gear_2": build("hammer")
		"gear_3":
			for x in [-.23,0,.23]:
				block(Vector3(x,.31,0),Vector3(.07,.53,.07),Color.SILVER)
				block(Vector3(x,.58,0),Vector3(.17,.07,.17),Color.SILVER)
		"gear_4":
			block(Vector3(0,.7,0),Vector3(.16,.9,.09),Color.SILVER)
			block(Vector3(0,.26,0),Vector3(.48,.11,.13),GOLD)
			block(Vector3(0,.13,0),Vector3(.12,.24,.12),WOOD)
		"gear_6": ball(Vector3(0,.52,0),.51,Color("#668cb0"),Vector3(.85,1,.32))
		"barrel":
			var cask:=CylinderMesh.new()
			cask.height=1.28
			cask.top_radius=.54
			cask.bottom_radius=.54
			moving=host.mesh(prop,cask,Vector3(0,.65,0),WOOD)
			for y in [.36,.95]:
				var band:=TorusMesh.new()
				band.inner_radius=.53
				band.outer_radius=.59
				host.mesh(prop,band,Vector3(0,y,0),Color("#59646a"))
		"dummy":
			block(Vector3(0,.6,0),Vector3(.19,1.2,.2),WOOD)
			ball(Vector3(0,1.08,0),.45,GOLD,Vector3(.82,1.36,.74))
			ball(Vector3(0,1.75,0),.29,GOLD)
			block(Vector3(0,1.31,0),Vector3(1.36,.16,.16),WOOD)
		"door":
			var frame:=TorusMesh.new()
			frame.inner_radius=.92
			frame.outer_radius=1.08
			var arch=host.mesh(prop,frame,Vector3(0,1.03,0),WOOD)
			arch.rotation.x=PI/2
			var visitor=host.beaver.duplicate()
			prop.add_child(visitor)
			visitor.position=Vector3(.18,0,-.42)
			visitor.rotation.y=0
			moving=Node3D.new()
			prop.add_child(moving)
			moving.position=Vector3(-.94,1.03,.13)
			var panel=host.orb(moving,Vector3(.94,0,0),.95,Color("#648850"))
			panel.scale.z=.13
			host.orb(moving,Vector3(1.52,-.03,.13),.105,GOLD)
		"beaver":
			prop.add_child(host.beaver.duplicate())
			prop.get_child(0).position=Vector3.ZERO
		"orc","chief","shield","badger","troll","ram": critter(kind)
		"spider":
			ball(Vector3(0,.65,0),.49,Color("#684d70"))
			eyes(.76,.43,.15)
			for side in [-1,1]:
				for i in 4:
					var leg:=block(Vector3(side*.56,.38,i*.21-.3),Vector3(.15,.8,.13),Color("#57465e"))
					leg.rotation.z=side*-.66
			tool=ball(Vector3(.8,1.42,-.3),.23,WOOD)
		"model":
			for side in [-1,1]:
				block(Vector3(side*.58,.30,0),Vector3(.55,.55,.8),Color("#a46555"))
			moving=block(Vector3(0,.62,0),Vector3(1.58,.1,.19),WOOD)
			ball(Vector3(.76,.64,0),.18,WOOD,Vector3(1,.45,1))
		"cone":
			block(Vector3(-.7,1,0),Vector3(.2,2,.2),WOOD)
			block(Vector3(-.22,2,0),Vector3(1.15,.16,.2),WOOD)
			moving=ball(Vector3(.29,1.65,0),.22,Color("#855032"),Vector3(.8,1.5,.8))
		"duck":
			ball(Vector3(0,.35,0),.44,GOLD,Vector3(1.28,.78,.76))
			ball(Vector3(.3,.72,.04),.28,GOLD)
			block(Vector3(.56,.69,.05),Vector3(.32,.1,.25),Color("#df853a"))
			ball(Vector3(.38,.77,.28),.042,Color.BLACK)
		"hammer":
			block(Vector3(0,.8,0),Vector3(.16,1.18,.17),WOOD)
			block(Vector3(0,1.38,0),Vector3(.79,.3,.38),Color("#8995a1"))
		"tracks":
			for i in 4:
				ball(Vector3((i%2-.5)*.52,.06,i*.33-.6),.19,WOOD,Vector3(.8,.3,1.3))
		"wheel":
			var ring:=TorusMesh.new()
			ring.inner_radius=.74
			ring.outer_radius=.93
			var wheel=host.mesh(prop,ring,Vector3(0,1,0),WOOD)
			wheel.rotation.x=PI/2
			for i in 4:
				block(Vector3(0,1,0),Vector3(.11,1.65,.16),WOOD).rotation.z=i*PI/4
			ball(Vector3(0,1,.15),.16,GOLD)
		"pack","flour":
			ball(Vector3(0,.58,0),.5,WOOD if kind=="pack" else WHITE,Vector3(1,1.25,.8))
			ball(Vector3(0,1.16,0),.2,WOOD)
		"blanket":
			for i in 5:
				block(Vector3(0,.27,i*.16-.32),Vector3(1.45,.17,.16),Color("#cc7872") if i%2 else WHITE)
		"water":
			for i in 5:
				ball(Vector3(i*.27-.55,.19,i*.16),.29,Color("#63b9c8"),Vector3(1,.3,1))
		"eggs":
			for side in [-1,1]: ball(Vector3(side*.3,.35,0),.26,WHITE,Vector3(.9,1.3,.9))
		"milk":
			block(Vector3(0,.55,0),Vector3(.52,.81,.52),Color("#a8d4de"))
			ball(Vector3(0,.96,0),.25,WHITE,Vector3(1,.12,1))
		"squirrel","tiger":
			var fur:=Color("#ce7843") if kind=="squirrel" else Color("#ffac46")
			ball(Vector3(0,.55,0),.49,fur,Vector3(.86,1.15,.83))
			ball(Vector3(0,1.19,.08),.39,fur)
			eyes(1.26,.432,.145)
			ball(Vector3(0,1.13,.45),.15,WHITE)
			ball(Vector3(0,1.18,.54),.075,WOOD.darkened(.6))
			for side in [-1,1]:
				ball(Vector3(side*.25,1.53,.04),.14,fur,Vector3(.88,1.47 if kind=="squirrel" else .88,.72))
				ball(Vector3(side*.29,.14,.16),.18,fur)
			if kind=="squirrel":
				ball(Vector3(-.42,.82,-.31),.48,fur,Vector3(.93,1.64,.83)).rotation.z=.42
				ball(Vector3(-.66,1.36,-.32),.31,fur)
			else:
				for x in [-.22,0,.22]: block(Vector3(x,1.49,.30),Vector3(.07,.13,.04),WOOD.darkened(.57))
				for y in [.42,.65]: block(Vector3(0,y,.37),Vector3(.58,.07,.04),WOOD.darkened(.62))
		"birthday_cake":
			for i in 3:
				var layer:=CylinderMesh.new()
				layer.top_radius=.62
				layer.bottom_radius=.62
				layer.height=.16
				host.mesh(prop,layer,Vector3(0,.12+i*.16,0),WHITE if i==1 else Color("#e7af77"))
			for i in 7: ball(Vector3(cos(i*TAU/7)*.44,.56,sin(i*TAU/7)*.44),.095,Color("#c85855"))
			block(Vector3(0,.69,0),Vector3(.075,.33,.075),Color("#73a9c3"))
			ball(Vector3(0,.90,0),.085,GOLD,Vector3(.72,1.48,.72))
		"cake":
			for i in 4: ball(Vector3(0,.18+i*.12,0),.56,GOLD,Vector3(1,.19,1))

func react(id:String) -> Tween:
	var tween:=create_tween()
	if id=="door":
		tween.tween_property(moving,"rotation:y",-1.75,.37)
	elif id=="model" or id=="crank" or id=="rope":
		tween.tween_property(moving,"rotation:z",moving.rotation.z+PI*.55,.36)
	elif id.begins_with("hit") or id=="pine" or id=="spool":
		tween.tween_property(moving,"position:y",moving.position.y+.3,.13)
		tween.tween_property(moving,"scale",Vector3.ONE*.22,.22)
	else:
		tween.tween_property(moving,"scale",moving.scale*1.12,.14)
		tween.tween_property(moving,"scale",moving.scale,.15)
	return tween

func fixed_block(at:Vector3, dimensions:Vector3, color:Color) -> MeshInstance3D:
	return host.box(scenery,at,dimensions,color)

func stage_encounter(id:String) -> void:
	if id in ["orc1","orc2","orc3","hit1","hit2","hit3","riddle","solve"]:
		for x in [-1.6,1.6]: fixed_block(Vector3(x,.68,-.66),Vector3(.16,1.36,.17),WOOD)
		beam=fixed_block(Vector3(0,1.06,-.62),Vector3(3.45,.21,.22),Color("#bf9157"))
		if id=="solve":
			ball(Vector3(-1.7,.055,.8),.62,Color("#64adc0"),Vector3(1,.12,.66))
			var stump:=CylinderMesh.new()
			stump.top_radius=.36
			stump.bottom_radius=.43
			stump.height=.62
			host.mesh(prop,stump,Vector3(1.7,.31,.8),WOOD)
		if id not in ["riddle","solve"]:
			tool=block(Vector3(-.59,1.01,.29),Vector3(.13,.85,.1),Color("#abbac8"))
	elif id in ["spool","free"]:
		net=Node3D.new()
		prop.add_child(net)
		for i in 6:
			host.box(net,Vector3(i*.28-.7,0,0),Vector3(.025,1.44,.025),WHITE)
			host.box(net,Vector3(0,i*.28-.7,0),Vector3(1.44,.025,.025),WHITE)
		net.position=Vector3(0,.76 if id=="free" else 2.65,.54)
	elif id in ["ram","bell"]:
		host.orb(scenery,Vector3(-1.25,.36,.15),.39,WHITE).scale=Vector3(1,1.3,.82)
		fixed_block(Vector3(-1.25,.77,.15),Vector3(.29,.14,.25),WOOD)
		for j in 5:
			fixed_block(Vector3(1.23+j*.09,.31,.15),Vector3(.10,.62,.48),GOLD).rotation.z=(j-2)*.09
		for i in 6:
			var track:Node3D=host.orb(scenery,Vector3(-1.2+i*.45,.04,.5+.14*(i%2)),.1,WHITE)
			track.scale=Vector3(.8,.18,1.2)
			tracks.append(track)
			track.visible=id=="bell"
		if id=="bell": wool.material_override.albedo_color=WHITE

func pose_encounter(mode:String, age:float, reacting:bool, feedback:float, secret:bool) -> void:
	var impact:=clampf(1-feedback/.42,0,1) if reacting else 0.0
	if mode in ["dodge","sword","circle","block","helmet"]:
		if tool:
			tool.rotation.z=-.3-1.25*minf(age/.75,1)
			if mode=="block": tool.rotation.z+=.46*sin(age*7)
			if age>3.6: tool.rotation.z=lerpf(-1.55,.65,minf((age-3.6)*4,1))
		if mode=="helmet" and helmet:
			helmet.position.y=1.75-.26*minf(age/.75,1)
			helmet.rotation.z=.27*sin(age*5)
		if mode=="circle": prop.rotation.y=-.65*impact
		if mode=="dodge":
			prop.rotation.x=-.1*minf(age/.75,1)+impact*.35
			prop.position.z=.55*impact
		if reacting and mode in ["sword","helmet"]:
			prop.rotation.z=.36*impact
			prop.position.y=-.22*impact
	elif mode=="riddle" and beam:
		beam.position.y=1.06-impact*.9
		beam.rotation.z=impact*.15
	elif mode=="aim_spool" and net:
		net.position.y=lerpf(2.65,.76,impact)
	elif mode=="aim_cone":
		moving.position.x=.29+.12*sin(age*2)-impact*1.75
		moving.position.y=1.65+.42*sin(PI*impact)-.38*impact
	elif mode in ["flour","straw"]:
		prop.rotation.x=.1*sin(minf(age,.75)*15)
		prop.position.x=impact*(.85 if mode=="straw" else -.85)
		prop.position.z=impact*.55
		for i in tracks.size():
			tracks[i].visible=mode=="straw" or impact>(i+1)*.14
		if mode=="straw" or impact>.7: wool.material_override.albedo_color=WHITE
	elif mode in ["ring","hoof"]:
		tool.rotation.z=.52*sin(age*12) if reacting else 0.0
		if mode=="hoof":
			prop.scale.y=.76
			hoof.position.y=.83 if secret else .36
