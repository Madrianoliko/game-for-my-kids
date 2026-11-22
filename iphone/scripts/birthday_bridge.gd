extends Node3D

const WOOD := Color("#ce985b")
const GOLD := Color("#ffdd89")
const LOOSE := 3
const YARD := [Vector3(2.65,.32,1.75), Vector3(-2.65,.32,1.75), Vector3(0,.32,1.75)]
const BENCH := Vector3(3.8,.4,1.05)
const OFFCUT := Vector3(-3.8,.42,1.05)

var bank
var host
var boards:Array[Node3D]=[]
var pegs:Array[MeshInstance3D]=[]
var short_board:MeshInstance3D
var tool:Node3D
var child:Node3D
var duck:Node3D
var selected:=-1
var rolling:=-1.0

func slot(i:int) -> Vector3:
	return Vector3((i-2)*1.22,.49,-.73)

func dimensions(i:int) -> Vector3:
	return Vector3([1.04,.84,1.13][i%3],.17,[1.70,2.12,1.37][i%3])

static func bench_legs(game,parent:Node3D,seat:Vector3) -> void:
	for dx in [-.44,.44]:
		game.box(parent,seat+Vector3(dx,-.18,0),Vector3(.17,.48,.5),WOOD.darkened(.3))

static func bench_seat(game,parent:Node3D,at:Vector3) -> MeshInstance3D:
	return game.box(parent,at,Vector3(1.34,.16,.52),WOOD)

func setup(owner_bank) -> void:
	bank=owner_bank
	host=bank.host
	for z in [-1.18,-.22]:
		host.box(self,Vector3(0,.25,z),Vector3(8.6,.22,.18),WOOD.darkened(.32))
	for x in [-4.15,4.15]:
		bank.rock(self,Vector3(x,-.12,-.65),1.8,bank.GRASS,Vector3(1.18,.32,1.48))
	for i in 5:
		var at:=slot(i)
		var dims:=dimensions(i)
		var board:=Node3D.new()
		add_child(board)
		boards.append(board)
		board.position=at
		host.box(board,Vector3.ZERO,dims,WOOD)
		host.box(board,Vector3(-dims.x*.22,.091,0),Vector3(.028,.01,dims.z*.82),WOOD.darkened(.18))
		if i==LOOSE:
			bank.rock(board,Vector3(.23,.087,.38),.14,WOOD.darkened(.27),Vector3(1,.12,1.34))
		if bank.mode()=="fit" and i>=2 and not (bank.marks & (1<<(i-2))):
			board.position=YARD[i-2]
			host.box(self,at-Vector3.UP*.13,dims,Color("#425852"))
			var outline:MeshInstance3D=bank.torus(at,.22,GOLD)
			outline.scale=Vector3(dims.x,1,dims.z)
		if bank.mode()=="pegs":
			var peg=host.orb(self,at+Vector3.UP*.19,.16,WOOD.darkened(.38))
			pegs.append(peg)
			if bank.marks & (1<<i): peg.scale.y=.32
			else: peg.material_override.albedo_color=GOLD
	if bank.mode()=="pegs":
		tool=bank.character("hammer",Vector3(-3.8,.31,.84),.74)
	if bank.mode() in ["bench","launch"]:
		bench_legs(host,self,BENCH)
		short_board=bench_seat(host,self,OFFCUT if bank.mode()=="bench" else BENCH)
		if bank.mode()=="bench": bank.ring=bank.torus(BENCH,.57,GOLD)
	if bank.mode()=="launch":
		child=bank.character("beaver",Vector3(-3.55,.36,-.77),.52)
		bank.character("beaver",Vector3(3.6,.34,-.50),.90)
		bank.character("troll",Vector3(3.65,.32,-1.72),.70)
		host.box(self,Vector3(-2.56,.73,-1.13),Vector3(2.2,.14,.68),WOOD.lightened(.16)).rotation.z=-.17
		duck=bank.character("duck",Vector3(-3.28,1,-1.13),.58)
		bank.ring=bank.torus(duck.position,.50,GOLD)

func press(at:Vector2) -> bool:
	selected=-1
	if bank.mode()=="fit":
		for i in range(2,5):
			if not (bank.marks & (1<<(i-2))) and bank.near(at,boards[i].position):
				selected=i
				return true
		return false
	if bank.mode()=="bench": return bank.near(at,OFFCUT)
	return rolling<0

func drag(at:Vector2) -> void:
	var pos:Vector3=bank.water(at)+Vector3.UP*.15
	if selected>=0: boards[selected].position=pos
	if bank.mode()=="bench": short_board.position=pos

func cancel() -> void:
	if selected>=0:
		boards[selected].position=YARD[selected-2]
		selected=-1
	if bank.mode()=="bench": short_board.position=OFFCUT

func release(at:Vector2) -> void:
	match bank.mode():
		"fit":
			if selected<0: return
			var i:=selected
			if not bank.near(at,slot(i)):
				cancel()
				return
			selected=-1
			boards[i].position=slot(i)
			bank.sound.emit("wood_tap")
			var mask:int=bank.marks | (1<<(i-2))
			if mask==7: bank.next_part()
			else: bank.save_marks(mask)
		"wobble":
			if bank.near(at,slot(LOOSE)): bank.next_part()
		"pegs":
			for i in 5:
				if not (bank.marks & (1<<i)) and bank.near(at,pegs[i].position):
					tool.position=slot(i)+Vector3(.17,.3,.26)
					pegs[i].scale.y=.32
					pegs[i].material_override.albedo_color=WOOD.darkened(.38)
					bank.sound.emit("wood_tap")
					var mask:int=bank.marks | (1<<i)
					if mask==31: bank.next_part()
					else: bank.save_marks(mask)
					return
		"bench":
			if bank.near(at,BENCH): bank.next_part()
			else: cancel()
		"launch":
			if rolling<0 and bank.near(at,duck.position):
				bank.ring.hide()
				rolling=0

func animate(dt:float) -> void:
	if bank.mode()=="pegs":
		for i in boards.size():
			boards[i].rotation.x=0 if bank.marks & (1<<i) else .17*sin(bank.clock*4+i)
	if rolling<0: return
	rolling+=dt
	var slide:=clampf(rolling/1.6,0,1)
	duck.position=Vector3(lerpf(-3.28,3.42,slide),lerpf(1,.76,slide)-.34*sin(slide*PI),-1.13)
	var run:=clampf((rolling-1.65)/1.75,0,1)
	child.position.x=lerpf(-3.55,3.13,run)
	child.position.y=.36+.13*absf(sin(run*PI*7))
	if rolling>=3.9: bank.next_part()
