extends Node3D

const Icons := preload("res://scripts/river_icons.gd")
const BOARD := Vector3(-2.45,.39,.52)
const PLATE := Vector3(1.65,.40,.4)
const RAIL := Vector3(0,.63,.1)
const WOOD := Color("#ac754d")
const FOOD := Color("#eab05f")
const PASS_LINES := ["Przenieś plasterki jabłka na placek Pestki.","Przenieś wiórki sera na placek Pestki.","Przenieś połowę ciastka do Toba. Druga zostaje dla Bilba."]
const SERVE_LINES := [
	"Jabłko z plecaka! Przesuń palcem przez jabłko, a potem przenieś plasterki na placek.",
	"Ser z plecaka! Przesuń palcem po serze, a potem posyp placek wiórkami.",
	"Zostało ostatnie ciastko! Przesuń palcem przez środek i podaj połowę Tobowi."
]

var bank
var host
var snack:=0
var ingredient:=Node3D.new()
var spoon:=Node3D.new()
var guest:Node3D
var destination:=PLATE
var served:=-1.0

static func sign_on(game,parent:Node3D,at:Vector3,mark:String) -> Node3D:
	var plaque:=Node3D.new()
	parent.add_child(plaque)
	plaque.position=at
	game.box(plaque,Vector3.ZERO,Vector3(.93,.86,.12),Color("#d9b783"))
	if Icons.MARKS.has(mark):
		var icon:=Sprite3D.new()
		plaque.add_child(icon)
		icon.texture=Icons.picture(mark)
		icon.pixel_size=.011
		icon.position.z=.07
	return plaque

func setup(owner_bank) -> void:
	bank=owner_bank
	host=bank.host
	snack=clampi(host.bystra.snack,0,2)
	if bank.mode()=="serve":
		supper_table()
		return
	for side in [-1,1]:
		bank.rock(self,Vector3(side*4.45,-.14,-.76),2.02,bank.GRASS,Vector3(1,.32,1.3))
		for i in 6:
			var reed=host.box(self,Vector3(side*(3.62+i*.14),.27,-.05+sin(i)),Vector3(.054,.65,.064),Color("#879652"))
			reed.rotation.z=.12*sin(i*2)
	var revealed:bool=bank.mode()=="supper"
	var height:=2.35 if revealed else .54
	for i in 5:
		host.box(self,Vector3((i-2)*1.22,height,-.83),Vector3(1.17,.2,2.1),WOOD.lightened(.055*(i%2)))
	for x in [-2.55,2.55]:
		host.box(self,Vector3(x,height*.5,-1.54),Vector3(.24,height+1.6,.25),WOOD)
	host.box(self,Vector3(0,height+.65,-1.54),Vector3(5.5,.22,.24),WOOD)
	sign_on(host,self,Vector3(-2.55,height+.57,-1.35),host.bystra.carving)
	if not revealed:
		bank.ring=bank.torus(RAIL,.6,bank.LIGHT)
		return
	# Keep the party on the near bank, visible beneath the deck's front edge.
	bank.rock(self,Vector3(0,-.12,1),3.8,bank.GRASS,Vector3(1.2,.12,.64))
	guest=bank.character("spider",Vector3(-.38,.12,1.08),1.08)
	guest.tool.hide()
	guest.rotation.y=.32
	for side in [-1,1]:
		for i in 4:
			var foot=host.box(guest,Vector3(side*(.78+.06*sin(i)),.27,i*.22-.34),Vector3(.11,.52,.1),Color("#57465e"))
			foot.rotation.z=side*.44
		bank.rock(guest,Vector3(side*.15-.015,.785,.49),.019,Color.FLORAL_WHITE,Vector3.ONE)
	bank.rock(self,Vector3(.65,.36,1.23),.49,FOOD,Vector3(1,.25,1))
	add_child(spoon)
	spoon.position=Vector3(.39,.57,1.44)
	host.box(spoon,Vector3(-.22,0,0),Vector3(.65,.08,.11),WOOD)
	bank.rock(spoon,Vector3(.16,0,0),.16,Color("#d3bd91"),Vector3(1,.42,1.24))
	bank.character("beaver",Vector3(2,.25,1.08),.56)

func supper_table() -> void:
	host.box(self,Vector3(0,-.18,0),Vector3(30,.38,18),WOOD)
	for i in range(-3,4):
		host.box(self,Vector3(0,.014,i*1.36),Vector3(18,.014,.023),Color("#996a47"))
	host.box(self,PLATE-Vector3.UP*.34,Vector3(3,.08,2.5),Color("#8fa69a"))
	host.box(self,BOARD-Vector3.UP*.23,Vector3(2.55,.15,1.72),Color("#e0bb87"))
	bank.rock(self,PLATE,.99,Color("#617f89"),Vector3(1,.18,1))
	bank.rock(self,PLATE+Vector3.UP*.13,.78,FOOD,Vector3(1,.13,1))
	var seat:=Vector3(.35,.46,-1.80)
	bank.Bridge.bench_legs(host,self,seat)
	bank.Bridge.bench_seat(host,self,seat)
	bank.character("beaver",seat+Vector3.UP*.07,.59)
	if snack==2:
		destination=Vector3(2.8,.72,-.85)
		bank.character("troll",destination-Vector3.UP*.72,.77)
	add_child(ingredient)
	ingredient.position=BOARD
	var cut:bool=bank.marks>0
	match snack:
		0:
			for i in (3 if cut else 1):
				var piece:=Vector3((i-1)*.30 if cut else 0,0,0)
				bank.rock(ingredient,piece,.53,Color("#db6249"),Vector3(.28 if cut else 1,.93,.86))
			if not cut: host.box(ingredient,Vector3(0,.49,0),Vector3(.08,.26,.09),WOOD)
		1:
			if cut:
				for i in 6:
					host.box(ingredient,Vector3((i%3-1)*.28,.09,(floori(i/3.0)-.5)*.29),Vector3(.13,.13,.35),Color("#ffce5d"))
			else:
				host.box(ingredient,Vector3.ZERO,Vector3(1.05,.54,.76),Color("#ffce5d"))
				for i in 3: bank.rock(ingredient,Vector3((i-1)*.29,.27,0),.095,FOOD,Vector3(1,.22,1))
		2:
			var size:=Vector3(.64,.22,.93) if cut else Vector3(1,.22,1)
			bank.rock(ingredient,Vector3.ZERO,.55,FOOD,size)
			if cut: bank.rock(self,BOARD+Vector3.LEFT*.74,.55,FOOD,size)
			for i in 4:
				bank.rock(ingredient,Vector3(cos(i*2.4)*.21,.12,sin(i*2.4)*.27),.07,WOOD,Vector3.ONE)
	if cut: bank.ring=bank.torus(destination,.62,bank.LIGHT)

func press(at:Vector2) -> bool:
	if bank.mode()=="serve": return served<0 and bank.near(at,BOARD)
	return bank.mode()=="peek" and bank.near(at,RAIL)

func drag(at:Vector2) -> void:
	if bank.mode()=="serve" and bank.marks==1:
		ingredient.position=bank.water(at)+Vector3.UP*.37

func cancel() -> void:
	if bank.mode()=="serve" and served<0: ingredient.position=BOARD

func release(at:Vector2) -> void:
	if bank.mode()=="peek":
		if bank.near(at,RAIL):
			bank.sound.emit("wood_tap")
			bank.next_part()
		return
	if bank.mode()!="serve": return
	if bank.marks==0:
		if at.distance_to(bank.start)<34: return
		bank.save_marks(1)
		bank.build()
	elif bank.near(at,destination):
		ingredient.position=destination+Vector3.UP*.24
		bank.ring.hide()
		served=0
		bank.sound.emit("chime")
	else: cancel()

func animate(dt:float) -> void:
	if served>=0:
		served+=dt
		if served>=.85: bank.next_part()
	elif bank.mode()=="supper":
		var lift:float=(1-cos(bank.clock*3.4))*.5
		spoon.position=Vector3(.39-.56*lift,.57+.42*lift,1.44)
		spoon.rotation.z=.33*lift
