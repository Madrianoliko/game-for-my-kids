extends Node3D

const Count := preload("res://scripts/touch_count.gd")

signal counted(index:int)
const PLACE := Vector3(14,0,-1.2)
var empty_mask := (1<<1) | (1<<2) | (1<<4)
const FULL_MASK := (1<<5)-1
const WIDTH := 1.55
var host
var floors:Array[MeshInstance3D]=[]
var horses:Array[Node3D]=[]
var targets:Array[Button]=[]
var smoke:=Node3D.new()
var clock:=0.0

func setup(game) -> void:
	host=game
	position=PLACE
	var wood:=Color("#ac7448")
	host.box(self,Vector3(0,1,-1.4),Vector3(8.5,2,.18),wood)
	host.box(self,Vector3(0,2.15,-1.52),Vector3(8.8,.23,1.7),Color("#466e87")).rotation.x=-.15
	# Podkowa nad szerokimi, otwartymi drzwiami stajni.
	for i in 12:
		var angle:=lerpf(-2.1,2.1,i/11.0)
		host.box(self,Vector3(sin(angle)*.38,2.12-cos(angle)*.38,-.67),Vector3(.14,.14,.12),Color.GOLD)
	for i in 6:
		var x:float=(i-2.5)*WIDTH
		host.box(self,Vector3(x,.65,.1),Vector3(.12,1.3,2.7),wood)
	for i in 5:
		var x:float=(i-2)*WIDTH
		floors.append(host.box(self,Vector3(x,.06,.28),Vector3(WIDTH-.16,.12,2.1),Color.WHEAT))
		host.box(self,Vector3(x,.38,1.4),Vector3(WIDTH,.12,.12),wood)
		var horse:=preload("res://scripts/pony.gd").make(host,self,Vector3(x,.12,.23),[Color.PERU,Color.IVORY,Color.TAN][i%3])
		horses.append(horse)
		var target:=Button.new()
		host.ui.add_child(target)
		target.flat=true
		target.accessibility_name="Boks %d"%(i+1)
		target.pressed.connect(func(): counted.emit(i))
		targets.append(target)
	add_child(smoke)
	host.orb(self,Vector3(5.5,-.9,-2.8),2.4,Color.DARK_OLIVE_GREEN).scale=Vector3(1.6,.75,1.1)
	smoke.position=Vector3(5.5,1.05,-2.8)
	for i in 5:
		host.orb(smoke,Vector3(i*.13,i*.46,0),.25+i*.065,Color.SLATE_GRAY)
	set_pens(false,0,false)

func set_pens(all_home:bool,mask:int,interactive:bool,sequence:Array=[]) -> void:
	smoke.visible=not all_home and interactive
	for i in 5:
		horses[i].visible=all_home or not (empty_mask & (1<<i))
		var b:=targets[i]
		b.visible=interactive and (all_home or not horses[i].visible)
		b.disabled=bool(mask & (1<<i))
		var order:=sequence.find(i)
		if interactive and order>=0:
			Count.mark(floors[i],order+1,not all_home,1.65)
		else: Count.clear(floors[i])
		if b.visible:
			var center:=global_position+Vector3((i-2)*WIDTH,.4,.34)
			var tl:Vector2=host.camera.unproject_position(center+Vector3(-.72,.8,-.6))
			var br:Vector2=host.camera.unproject_position(center+Vector3(.72,-.32,1.2))
			b.position=tl
			b.size=br-tl

func _process(dt:float) -> void:
	if is_visible_in_tree() and smoke.visible and not host.paused:
		clock+=dt
		for i in smoke.get_child_count():
			var puff:=smoke.get_child(i) as Node3D
			puff.position.x=i*.13+.12*sin(clock+i)

func highlight_empty(total:int) -> void:
	var index:=0
	for i in floors.size():
		if empty_mask & (1<<i):
			index+=1
			floors[i].material_override.emission_enabled=index<=total
			floors[i].material_override.emission=Count.EMPTY
