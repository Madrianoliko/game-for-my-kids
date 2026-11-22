extends Node3D

const WOOD := Color("#ce985b")
const GOLD := Color("#ffdd89")
const LOOSE := 3
const YARD := [Vector3(2.65,.32,1.75), Vector3(-2.65,.32,1.75), Vector3(0,.32,1.75)]
var bank
var host
var boards:Array[Node3D]=[]
var pegs:Array[MeshInstance3D]=[]
var tool:Node3D
var selected:=-1

func slot(i:int) -> Vector3:
	return Vector3((i-2)*1.22,.49,-.73)

func dimensions(i:int) -> Vector3:
	return Vector3([1.04,.84,1.13][i%3],.17,[1.70,2.12,1.37][i%3])

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
func press(at:Vector2) -> bool:
	selected=-1
	if bank.mode()=="fit":
		for i in range(2,5):
			if not (bank.marks & (1<<(i-2))) and bank.near(at,boards[i].position):
				selected=i
				return true
		return false
	return true

func drag(at:Vector2) -> void:
	var pos:Vector3=bank.water(at)+Vector3.UP*.15
	if selected>=0: boards[selected].position=pos

func cancel() -> void:
	if selected>=0:
		boards[selected].position=YARD[selected-2]
		selected=-1

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
func animate(_dt:float) -> void:
	if bank.mode()=="pegs":
		for i in boards.size():
			boards[i].rotation.x=0 if bank.marks & (1<<i) else .17*sin(bank.clock*4+i)
