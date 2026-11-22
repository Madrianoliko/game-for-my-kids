extends Node3D

const ROPE_PATH := [Vector3(-3.5,.45,1.1),Vector3(-1.55,.45,-.65),Vector3(.95,.45,-.45)]
const HUB := Vector3(-2,.42,.1)
const RADIUS := 1.22
const TURN := 1.5*TAU
const WOOD := Color("#98683e")
const BRASS := Color("#ffc564")
const WATER := Color("#50b8ce")

var bank
var host
var rope:MeshInstance3D
var loose_end:MeshInstance3D
var handle:MeshInstance3D
var rotor:Node3D
var gate:MeshInstance3D
var stream:MeshInstance3D
var float_marker:MeshInstance3D
var bag:Node3D
var elapsed_angle:=0.0
var last_vector:=Vector2.ZERO
var winding:=0.0
var handle_angle:=0.0

func setup(owner_bank) -> void:
	bank=owner_bank
	host=bank.host
	match bank.mode():
		"thread":
			for i in range(1,3):
				bank.torus(ROPE_PATH[i],.5,BRASS)
				host.orb(self,ROPE_PATH[i],.18,WOOD)
			for i in bank.marks:
				line_between(new_rope(),ROPE_PATH[i],ROPE_PATH[i+1])
			rope=new_rope()
			loose_end=host.orb(self,ROPE_PATH[bank.marks],.26,BRASS)
			line_between(rope,ROPE_PATH[bank.marks],ROPE_PATH[bank.marks])
			bank.character("beaver",Vector3(-4.2,.05,-.8),.62)
			bank.character("troll",Vector3(3,.02,-.7),.75)
			host.box(self,Vector3(3,1.65,-.74),Vector3(2.2,.28,.38),WOOD)
			bank.ring=bank.torus(ROPE_PATH[bank.marks+1],.65,bank.LIGHT)
		"turn":
			rotor=Node3D.new()
			add_child(rotor)
			rotor.position=HUB
			bank.torus(HUB,RADIUS,WOOD)
			for i in 3:
				var spoke=host.box(rotor,Vector3.ZERO,Vector3(2*RADIUS,.14,.12),WOOD)
				spoke.rotation.y=i*PI/3
			handle=host.orb(rotor,Vector3(RADIUS,.13,0),.28,BRASS)
			host.box(self,Vector3(1.65,.08,0),Vector3(2.4,.15,3.25),Color("#b6a47d"))
			for x in [.42,2.88]:
				host.box(self,Vector3(x,.70,-.55),Vector3(.19,1.5,.3),WOOD)
			gate=host.box(self,Vector3(1.65,.45,-.55),Vector3(2.23,.88,.23),WOOD)
			stream=host.box(self,Vector3(1.65,.18,-.52),Vector3(2.16,.10,1),WATER)
			host.box(self,Vector3(3.4,.18,0),Vector3(.15,.15,2.25),WOOD)
			float_marker=host.orb(self,Vector3(3.4,.42,1),.24,BRASS)
			bank.rock(self,Vector3(3.99,.40,-1),.29,WATER,Vector3(1.45,.65,.7))
			host.box(self,Vector3(4.38,.40,-1),Vector3(.21,.12,.33),WATER).rotation.y=PI*.25
			elapsed_angle=TURN*bank.marks/12.0
			handle_angle=elapsed_angle
			update_gate()
		"sack":
			bank.character("beaver",Vector3(-2.7,.02,.75),.85)
			host.box(self,Vector3(1.5,.65,-1.55),Vector3(2.7,1.4,1.3),Color("#c9a47a"))
			host.box(self,Vector3(1.5,1.48,-1.55),Vector3(3.1,.22,1.65),WOOD)
			bank.character("beaver",Vector3(1.5,.8,-.92),.5)
			bag=bank.character("flour",bag_at(0),.95)
		"cart":
			bank.character("ram",Vector3(-1.8,.01,.32),.95)
			host.box(self,Vector3(.9,.48,.4),Vector3(2.65,.25,1.25),WOOD)
			for x in [.05,1.8]:
				for z in [-.25,1.05]:
					bank.rock(self,Vector3(x,.28,z),.34,WOOD.darkened(.4),Vector3(1,1,.42))
			for i in 5:
				host.box(self,Vector3(.9,.68+i*.09,.4),Vector3(2.55,.09,.8),WOOD.lightened(.12*(i%2)))
			bank.character("beaver",Vector3(3.15,0,.65),.74)
			bank.rock(self,Vector3(3.58,.13,.93),.36,Color.FLORAL_WHITE,Vector3(.76,.32,1.35))
			bank.ring=bank.torus(Vector3(.9,1.2,.4),.63,bank.LIGHT)

func new_rope() -> MeshInstance3D:
	return host.box(self,Vector3.ZERO,Vector3(1,.13,.13),Color("#ffde92"))

func line_between(line:MeshInstance3D,a:Vector3,b:Vector3) -> void:
	line.position=(a+b)*.5
	line.scale.x=maxf(.16,a.distance_to(b))
	line.rotation.y=-atan2(b.z-a.z,b.x-a.x)

func knob() -> Vector3:
	return bank.to_local(handle.global_position)

func update_gate() -> void:
	var ratio:=elapsed_angle/TURN
	rotor.rotation.y=-handle_angle
	gate.position.y=.46+ratio*1.26
	stream.scale.z=.16+2.15*ratio
	stream.position.z=-.6+stream.scale.z*.5
	float_marker.position.z=1-2*ratio

func bag_at(clock:float) -> Vector3:
	var t:=minf(clock/2.8,1)
	return Vector3(lerpf(1.5,-2.35,t),lerpf(1.1,.52,t)+sin(t*PI)*.85,lerpf(-.8,.62,t))

func press(at:Vector2) -> bool:
	if bank.mode()=="thread": return bank.near(at,ROPE_PATH[bank.marks])
	if bank.mode()=="turn":
		last_vector=at-bank.screen(HUB)
		winding=0
		return bank.near(at,knob())
	return true

func drag(at:Vector2) -> void:
	match bank.mode():
		"thread":
			var pos:Vector3=bank.water(at)
			pos.y=.45
			loose_end.position=pos
			line_between(rope,ROPE_PATH[bank.marks],pos)
			if bank.near(at,ROPE_PATH[bank.marks+1]):
				bank.sound.emit("wood_tap")
				if bank.marks==1:
					bank.next_part()
				else:
					line_between(rope,ROPE_PATH[0],ROPE_PATH[1])
					bank.save_marks(1)
					loose_end.position=ROPE_PATH[1]
					rope=new_rope()
					line_between(rope,ROPE_PATH[1],ROPE_PATH[1])
					bank.ring.position=ROPE_PATH[2]
		"turn":
			var radial:Vector2=at-bank.screen(HUB)
			var radius:float=bank.screen(HUB).distance_to(bank.screen(HUB+Vector3.RIGHT*RADIUS))
			if radial.length()<radius*.38 or radial.length()>radius*1.65:
				last_vector=Vector2.ZERO
				return
			if last_vector!=Vector2.ZERO:
				var delta:=last_vector.angle_to(radial)
				if absf(delta)<PI/3:
					if winding==0 and absf(delta)>.008: winding=signf(delta)
					elapsed_angle=clampf(elapsed_angle+delta*winding,0,TURN)
					handle_angle+=delta
					update_gate()
					var tick:=floori(12*elapsed_angle/TURN)
					if tick!=bank.marks: bank.save_marks(tick)
			last_vector=radial

func release(at:Vector2) -> void:
	match bank.mode():
		"thread": reset_rope()
		"turn":
			if elapsed_angle>=TURN*.985: bank.next_part()
		"sack":
			if bank.near(at,bag.position+Vector3.UP*.32): bank.next_part()
		"cart":
			if bank.near(at,bank.ring.position): bank.next_part()

func reset_rope() -> void:
	loose_end.position=ROPE_PATH[bank.marks]
	line_between(rope,loose_end.position,loose_end.position)
