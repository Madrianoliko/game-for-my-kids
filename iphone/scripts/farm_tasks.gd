extends Node3D

const WOOD := Color("#996a44")
const HAY := Color("#ecd168")
const BAG := Vector3(2.6,.45,.25)
const HAYSTACK := Vector3(-3.55,.5,.8)
const FEED := [Vector3(-.9,.46,.55),Vector3(2.85,.46,.55)]
const UDDER := Vector3(.5,1.03,.43)
var bank
var host
var nails:Array[Node3D]=[]
var bundle:Node3D
var stream:MeshInstance3D
var bucket_fill:MeshInstance3D
var selected:=-1

func setup(owner_bank) -> void:
	bank=owner_bank
	host=bank.host
	host.box(self,Vector3(0,-.2,0),Vector3(30,.38,18),Color("#ae865b"))
	if bank.mode()=="nails":
		host.box(self,Vector3(-2.35,.08,0),Vector3(4.5,.22,2.95),WOOD.darkened(.3))
		for i in 10:
			var nail:=Node3D.new()
			add_child(nail)
			nail.position=nail_at(i)
			host.box(nail,Vector3.ZERO,Vector3(.11,.13,.79),Color.SILVER)
			host.box(nail,Vector3(0,0,-.36),Vector3(.37,.18,.13),Color.LIGHT_STEEL_BLUE)
			nails.append(nail)
			if bank.marks & (1<<i): nail.position=packed(i)
		# Back flap, canvas sides and buckled front pocket surround the opening.
		host.box(self,BAG+Vector3(0,.42,-1.08),Vector3(2.15,.16,1.02),Color("#8ca27b")).rotation.x=-.45
		host.box(self,BAG,Vector3(2.22,.6,1.9),Color("#536f57"))
		host.box(self,BAG+Vector3.UP*.33,Vector3(2.03,.10,1.69),Color("#403932"))
		host.box(self,BAG+Vector3(0,-.06,1.02),Vector3(1.67,.42,.29),Color("#829877"))
		for side in [-1,1]:
			host.box(self,BAG+Vector3(side*.63,.18,1.14),Vector3(.16,.30,.12),WOOD)
			host.box(self,BAG+Vector3(side*.63,.22,1.21),Vector3(.19,.10,.06),Color.GOLD)
			host.box(self,BAG+Vector3(side*1.17,0,0),Vector3(.16,.15,1.5),WOOD)
		count_label()
		return
	for x in [-4,0,4]: host.box(self,Vector3(x,.94,-2.3),Vector3(.19,1.9,.17),WOOD)
	for y in [.55,1.35]: host.box(self,Vector3(0,y,-2.3),Vector3(10,.15,.17),WOOD)
	if bank.mode()=="hay":
		for i in 2:
			cow(FEED[i]+Vector3(-.35,-.43,-.9),.82)
			host.box(self,FEED[i],Vector3(1.35,.4,.65),WOOD)
			if bank.marks & (1<<i): hay(FEED[i]+Vector3.UP*.26)
		bundle=hay(HAYSTACK)
	else:
		cow(Vector3(-.4,.05,-.47),1.48)
		bank.rock(self,UDDER,.37,Color("#e5a494"),Vector3(1.3,.83,1))
		for side in [-1,1]:
			bank.rock(self,UDDER+Vector3(.22*side,-.24,.12),.12,Color("#e9ac9d"),Vector3(.78,1.9,.8))
		var bucket:=Vector3(.55,.15,1.45)
		var tin:=CylinderMesh.new()
		tin.top_radius=.65
		tin.bottom_radius=.48
		tin.height=.53
		host.mesh(self,tin,bucket,Color("#648795"))
		bank.torus(bucket+Vector3.UP*.27,.63,Color("#bac9c6"))
		bank.rock(self,bucket+Vector3.UP*.268,.59,Color("#344952"),Vector3(1,.035,1))
		bucket_fill=bank.rock(self,bucket+Vector3.UP*(.29+.04*bank.marks),.55,Color.FLORAL_WHITE,Vector3(1,.12,1))
		bucket_fill.visible=bank.marks>0
		stream=host.box(self,UDDER+Vector3(0,-.38,.47),Vector3(.068,.78,.075),Color.FLORAL_WHITE)
		stream.hide()

func nail_at(i:int) -> Vector3:
	return Vector3(-3.95+.81*(i%5),.29,-.60+1.26*floori(i/5.0))

func packed(i:int) -> Vector3:
	return BAG+Vector3((i%5-2)*.34,.48,(floori(i/5.0)-.5)*.59)

func count_label() -> void:
	var n:=0
	for i in 10:
		if bank.marks & (1<<i): n+=1
	bank.host.hud.text="Gwoździe   %d / 8"%n

func hay(at:Vector3) -> Node3D:
	var sheaf:=Node3D.new()
	add_child(sheaf)
	sheaf.position=at
	for i in 5:
		host.box(sheaf,Vector3((i-2)*.14,0,0),Vector3(.16,.29,.85),HAY).rotation.y=(i-2)*.09
	host.box(sheaf,Vector3(0,.04,0),Vector3(.84,.33,.12),WOOD)
	return sheaf

func cow(at:Vector3,amount:float) -> void:
	var body:=Node3D.new()
	add_child(body)
	body.position=at
	body.scale=Vector3.ONE*amount
	bank.rock(body,Vector3(0,.93,0),.66,Color.IVORY,Vector3(1.72,.86,.84))
	for x in [-.58,.57]:
		for z in [-.31,.32]: host.box(body,Vector3(x,.39,z),Vector3(.20,.77,.21),Color("#564c44"))
	bank.rock(body,Vector3(-.31,1.13,.33),.32,Color("#524c48"),Vector3(1.22,.84,.55))
	bank.rock(body,Vector3(.86,1.36,.03),.45,Color.IVORY,Vector3(.96,1.12,.91))
	bank.rock(body,Vector3(1.09,1.17,.28),.26,Color("#e7b1a1"),Vector3(1.1,.73,1))
	for z in [-.30,.35]:
		bank.rock(body,Vector3(.77,1.62,z),.19,Color("#574e47"),Vector3(.76,.51,1.42))
		host.orb(body,Vector3(1.06,1.45,z),.061,Color.BLACK)

func press(at:Vector2) -> bool:
	selected=-1
	match bank.mode():
		"nails":
			var best:=37.0
			for i in 10:
				var distance:float=at.distance_to(bank.screen(nail_at(i)))
				if not (bank.marks & (1<<i)) and distance<best:
					best=distance
					selected=i
			return selected>=0
		"hay": return bank.near(at,HAYSTACK)
		_: return bank.near(at,UDDER)

func drag(at:Vector2) -> void:
	match bank.mode():
		"nails":
			if selected>=0: nails[selected].position=bank.water(at)+Vector3.UP*.34
		"hay": bundle.position=bank.water(at)+Vector3.UP*.34
		"milk_cow": stream.visible=at.y-bank.start.y>14

func cancel() -> void:
	if selected>=0: nails[selected].position=nail_at(selected)
	selected=-1
	if bundle: bundle.position=HAYSTACK
	if stream: stream.hide()

func release(at:Vector2) -> void:
	match bank.mode():
		"nails":
			var i:=selected
			cancel()
			if i<0 or at.distance_to(bank.screen(BAG))>72: return
			nails[i].position=packed(i)
			bank.save_marks(bank.marks | (1<<i))
			count_label()
			var total:=0
			for nail in 10:
				if bank.marks & (1<<nail): total+=1
			bank.sound.emit("count_%d"%total if total<=4 else "story/nail_"+str(total))
			if total==8: bank.next_part()
		"hay":
			cancel()
			for i in 2:
				if not (bank.marks & (1<<i)) and bank.near(at,FEED[i]):
					hay(FEED[i]+Vector3.UP*.26)
					if bank.marks!=0: bank.next_part()
					else: bank.save_marks(1<<i)
					return
		"milk_cow":
			stream.hide()
			if at.y-bank.start.y<37: return
			bucket_fill.show()
			bucket_fill.position.y+=.055
			if bank.marks==2: bank.next_part()
			else: bank.save_marks(bank.marks+1)
