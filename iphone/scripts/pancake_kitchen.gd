extends Node3D

const FOOD_COLOR := Color("#e8ae61")
const BOWL := Vector3(1.15,.48,.25)
const SOURCE := Vector3(-2.7,.57,.45)
const CREAM := Color("#ffe2a0")
const BLUE := Color("#467c91")
const WOOD := Color("#ad744c")
const SHELL := Color("#f5d8b5")
const RECIPE := {"scoop":3,"crack":2,"pour":1}

var bank
var host
var utensil:Node3D
var batter:MeshInstance3D
var pancake:MeshInstance3D
var ram:Node3D
var milk_stream:MeshInstance3D
var yolks:Array[MeshInstance3D]=[]
var bubbles:Array[MeshInstance3D]=[]
var sacks:Array[Node3D]=[]
var portions:Array[MeshInstance3D]=[]
var spoon_angle:=0.0
var last_vector:=Vector2.ZERO
var winding:=0.0
var stroke:=0.0
var pouring:=-1.0
var flight:=-1.0
var previous_accel:=Vector3.ZERO

func setup(owner_bank) -> void:
	bank=owner_bank
	host=bank.host
	host.box(self,Vector3(0,-.24,0),Vector3(30,.46,18),Color("#b78357"))
	for x in range(-8,9,2):
		host.box(self,Vector3(x,0,0),Vector3(.03,.012,18),WOOD)
	host.box(self,Vector3(.7,.035,.26),Vector3(6.3,.06,3.55),Color("#97b3a1"))
	var mode:String=bank.mode()
	var frying:=mode=="flip"
	bank.rock(self,BOWL,1.34,Color("#38424a") if frying else BLUE,Vector3(1,.33,1))
	bank.torus(BOWL+Vector3.UP*.23,1.17,Color("#c4b78d"))
	batter=bank.rock(self,BOWL+Vector3.UP*.22,1.1,CREAM,Vector3(1,.12,1))
	utensil=Node3D.new()
	add_child(utensil)
	utensil.position=SOURCE
	draw_recipe(mode)
	draw_pantry(mode)
	match mode:
		"scoop":
			for i in 3:
				var sack:Node3D=bank.character("flour",flour_at(i)-Vector3.UP*.4,.73)
				sack.visible=(bank.marks & (1<<i))==0
				sacks.append(sack)
		"crack":
			for i in 2:
				var egg:MeshInstance3D=bank.rock(utensil,egg_at(i)-SOURCE,.45,SHELL,Vector3(.84,1.22,.86))
				egg.visible=(bank.marks & (1<<i))==0
				if not egg.visible: yolk(i)
		"pour":
			for i in 2: yolk(i)
			milk_stream=host.box(self,BOWL+Vector3.UP*.6,Vector3(.10,.7,.10),Color.FLORAL_WHITE)
			milk_stream.hide()
			bank.rock(utensil,Vector3.ZERO,.62,BLUE,Vector3(.87,1.16,.87))
			bank.rock(utensil,Vector3.UP*.56,.43,Color.FLORAL_WHITE,Vector3(1,.19,1))
			host.box(utensil,Vector3(.47,.41,0),Vector3(.38,.21,.37),BLUE).rotation.z=.28
			host.box(utensil,Vector3(-.63,.13,0),Vector3(.22,.58,.21),BLUE)
		"stir":
			host.box(utensil,Vector3(.48,.28,0),Vector3(1.3,.14,.17),WOOD).rotation.z=.28
			bank.rock(utensil,Vector3.ZERO,.28,WOOD,Vector3(1.22,.45,.72))
			utensil.position=BOWL+Vector3(.72,.40,0)
			for i in 2: yolk(i)
			blend()
		"flip":
			for x in [-1.3,1.3]: host.box(self,BOWL+Vector3(x,0,0),Vector3(.38,.18,.36),BLUE)
			batter.hide()
			bank.rock(self,Vector3(-1.36,.17,.63),1.1,BLUE,Vector3(1,.11,1))
			for i in 2: bank.rock(self,Vector3(-1.36,.30+i*.15,.63),.97,CREAM if i==1 else FOOD_COLOR,Vector3(1,.17,1))
			pancake=bank.rock(self,BOWL+Vector3.UP*.33,.96,Color("#e8ae61"),Vector3(1,.12,1))
			for i in 6:
				var offset:=Vector3(cos(i*2.39),0,sin(i*2.39))*(.28+i*.07)
				bubbles.append(bank.rock(self,pancake.position+offset+Vector3.UP*.1,.092,CREAM,Vector3.ONE))
			previous_accel=Input.get_accelerometer()
	update_fill()

func draw_pantry(mode:String) -> void:
	if mode!="scoop": bank.character("flour",Vector3(-4.45,.05,-.05),.68)
	if mode!="crack":
		for i in 2: bank.rock(self,Vector3(-3.95+i*.64,.27,1.45),.33,SHELL,Vector3(.85,1.12,.88))
	if mode!="pour":
		bank.rock(self,Vector3(-4.65,.54,.93),.42,BLUE,Vector3(.83,1.25,.83))
		bank.rock(self,Vector3(-4.65,.99,.93),.29,Color.FLORAL_WHITE,Vector3(1,.17,1))

func draw_recipe(mode:String) -> void:
	var card:=Vector3(-2.85,.13,-1.52)
	host.box(self,card,Vector3(4.65,.13,1.2),Color("#f4deb0"))
	var x:=card.x-1.84
	for ingredient:String in RECIPE:
		for i in RECIPE[ingredient]:
			var spot:=Vector3(x,.26,card.z)
			if ingredient==mode:
				var tick:MeshInstance3D=bank.torus(spot,.29,Color("#fff486"))
				portions.append(tick)
				tick.visible=i<bank.marks
			match ingredient:
				"scoop":
					host.box(self,spot+Vector3(-.15,.02,0),Vector3(.32,.09,.085),WOOD)
					bank.rock(self,spot+Vector3(.04,.04,0),.17,SHELL,Vector3(1,.55,1))
				"crack":
					bank.rock(self,spot,.18,Color("#e4ac7c"),Vector3(.86,.84,1.23))
				"pour":
					host.box(self,spot,Vector3(.32,.22,.31),BLUE)
					host.box(self,spot+Vector3(0,.12,0),Vector3(.25,.025,.25),Color.FLORAL_WHITE)
			x+=.62
		x+=.19

func flour_at(i:int) -> Vector3:
	return SOURCE+Vector3((i-1)*1.19,0,0)

func egg_at(i:int) -> Vector3:
	return SOURCE+Vector3((i-.5)*1.65,0,0)

func yolk(i:int) -> void:
	yolks.append(bank.rock(self,BOWL+Vector3((i-.5)*.82,.38,.12),.28,Color("#eda633"),Vector3(1,.38,1)))

func blend() -> void:
	for egg_yolk in yolks: egg_yolk.scale=Vector3(1,.38,1)*(1-bank.marks/7.0)

func update_fill() -> void:
	if bank.mode()=="scoop":
		var count:=0
		for sack in sacks:
			if not sack.visible: count+=1
		for i in portions.size(): portions[i].visible=i<count
		batter.visible=count>0
		batter.position.y=.72+.13*count
		batter.scale=Vector3(.38+.24*count,.18+.13*count,.38+.24*count)
	if bank.mode()=="crack":
		var count:=int((bank.marks & 1)!=0)+int((bank.marks & 2)!=0)
		for i in portions.size(): portions[i].visible=i<count

func press(at:Vector2) -> bool:
	if pouring>=0: return false
	match bank.mode():
		"scoop": return true
		"pour": return bank.near(at,SOURCE)
		"stir":
			last_vector=at-bank.screen(BOWL+Vector3.UP*.4)
			winding=0
			stroke=0
			return last_vector.length()<102
		"flip": return flight<0 and bank.clock>=1.05 and bank.near(at,pancake.position)
	return true

func drag(at:Vector2) -> void:
	match bank.mode():
		"pour":
			utensil.position=bank.water(at)+Vector3.UP*.36
			if bank.mode()=="pour":
				milk_stream.visible=bank.near(at,BOWL+Vector3.UP*.23)
				utensil.rotation.z=-1.2*clampf((utensil.position.x-SOURCE.x)/(BOWL.x-SOURCE.x),0,1)
		"stir":
			var center:Vector2=bank.screen(BOWL+Vector3.UP*.4)
			var v:=at-center
			if v.length()<14 or v.length()>110:
				last_vector=Vector2.ZERO
				return
			if last_vector.length()>12:
				var delta:=last_vector.angle_to(v)
				if absf(delta)<PI/2:
					if winding==0 and absf(delta)>.01: winding=signf(delta)
					stroke=maxf(0,stroke+delta*winding)
					spoon_angle+=delta
					utensil.position=BOWL+Vector3(.75*cos(spoon_angle),.4,.75*sin(spoon_angle))
					if stroke>=PI*.49:
						stroke=0
						if bank.marks>=5: bank.next_part()
						else:
							bank.save_marks(bank.marks+1)
							blend()
			last_vector=v

func cancel() -> void:
	if bank.mode() in ["scoop","pour"]:
		utensil.position=SOURCE
		utensil.rotation.z=0
		if milk_stream: milk_stream.hide()

func release(at:Vector2) -> void:
	match bank.mode():
		"scoop":
			for i in 3:
				if sacks[i].visible and bank.near(at,flour_at(i)) and bank.near(bank.start,flour_at(i)):
					sacks[i].hide()
					var mask:int=bank.marks | (1<<i)
					if mask==7: bank.next_part()
					else:
						bank.save_marks(mask)
						update_fill()
						bank.sound.emit("wood_tap")
					return
		"pour":
			cancel()
			if not bank.near(at,BOWL+Vector3.UP*.23): return
			pouring=0
			utensil.position=BOWL+Vector3(-.65,1,0)
			utensil.rotation.z=-1.12
			milk_stream.show()
			portions[0].show()
		"crack":
			for i in 2:
				if bank.marks & (1<<i): continue
				if bank.near(at,egg_at(i)) and bank.near(bank.start,egg_at(i)):
					bank.sound.emit("wood_tap")
					if bank.marks!=0: bank.next_part()
					else:
						bank.save_marks(1<<i)
						utensil.get_child(i).hide()
						yolk(i)
						update_fill()
					return
		"flip":
			if bank.near(at,pancake.position): flip()

func flip() -> void:
	flight=0
	for bubble in bubbles: bubble.hide()

func sense_shake(sample:Vector3) -> void:
	if flight<0 and bank.clock>=1.05 and previous_accel!=Vector3.ZERO and previous_accel.distance_to(sample)>6.5: flip()
	previous_accel=sample

func animate(dt:float) -> void:
	if pouring>=0:
		pouring+=dt
		batter.material_override.albedo_color=CREAM.lerp(Color.FLORAL_WHITE,minf(pouring,.65))
		if pouring>=.75: bank.next_part()
		return
	if bank.mode()!="flip": return
	if flight<0:
		if OS.get_name()=="iOS": sense_shake(Input.get_accelerometer())
		for i in bubbles.size(): bubbles[i].visible=bank.clock>=1.05+i*.09
		return
	flight+=dt
	var t:=minf(1,flight/.85)
	var origin:=BOWL+Vector3.UP*.33
	var plate:=Vector3(-1.36,.62,.63)
	pancake.position=origin.lerp(plate,t)+Vector3.UP*1.72*sin(PI*t)
	pancake.rotation.x=TAU*t
	if flight>1.23: bank.next_part()
