extends VBoxContainer

signal ordered
signal counted_slot
var story_order := false
signal repaired
signal voice(clip: String)
signal hammer_hit

const Icons := preload("res://scripts/river_icons.gd")
const SPANS := 5
const ON_HAND := 2
enum Step { COUNT, CHOOSE, FASTEN, DONE }

var step := Step.COUNT
var counted: Array[int] = []
var fixed: Array[int] = []
var instruction := Label.new()
var river := Control.new()
var cross := Button.new()
var choices := HBoxContainer.new()
var slots: Array[Button] = []
var current_clip := "beaver_help"

func _ready() -> void:
	custom_minimum_size.x = 700
	add_theme_constant_override("separation",10)
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction.add_theme_font_size_override("font_size",24)
	add_child(instruction)
	river.custom_minimum_size = Vector2(700,160)
	add_child(river)
	river.draw.connect(draw_bridge)
	for i in SPANS:
		var slot := Button.new()
		slot.flat = true
		for kind in ["normal","hover","pressed","disabled"]:
			slot.add_theme_stylebox_override(kind,StyleBoxEmpty.new())
		river.add_child(slot)
		slots.append(slot)
		slot.pressed.connect(touch_slot.bind(i))
	river.resized.connect(layout_slots)
	layout_slots()
	choices.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(choices)
	for n in [2,3,4]:
		var pick := Button.new()
		Icons.apply(pick,str(n))
		choices.add_child(pick)
		pick.pressed.connect(choose_boards.bind(n))
	choices.hide()
	var controls:=HBoxContainer.new()
	controls.alignment=BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation",16)
	add_child(controls)
	var repeat:=Button.new()
	Icons.apply(repeat,"Posłuchaj bobra")
	controls.add_child(repeat)
	Icons.apply(cross,"Na drugi brzeg!")
	controls.add_child(cross)
	cross.hide()
	cross.pressed.connect(func(): repaired.emit())
	repeat.pressed.connect(func(): voice.emit(current_clip))
	if story_order and counted.size()==SPANS:
		choices.show()
		step=Step.CHOOSE
		prompt("Mam dwie deski. Ile jeszcze przynieść?","beaver_more")
		return
	prompt("Dotknij każdego pustego miejsca na moście.","beaver_help")

func prompt(words: String, clip: String) -> void:
	instruction.text = words
	current_clip = clip
	voice.emit(clip)

func layout_slots() -> void:
	var pitch := (river.size.x-96)/SPANS
	for i in slots.size():
		slots[i].position=Vector2(48+i*pitch+3,17)
		slots[i].size=Vector2(pitch-6,river.size.y-34)

func touch_slot(i: int) -> void:
	if step==Step.COUNT and not counted.has(i):
		counted.append(i)
		counted_slot.emit()
		if counted.size()==SPANS:
			step=Step.CHOOSE
			choices.show()
			prompt("Mam dwie deski. Ile jeszcze przynieść?","beaver_more")
		else:
			voice.emit("count_%d" % counted.size())
	elif step==Step.FASTEN and not fixed.has(i):
		fixed.append(i)
		hammer_hit.emit()
		if fixed.size()==SPANS:
			step=Step.DONE
			cross.show()
			prompt("Most gotowy!","beaver_ready")
		var slot := slots[i]
		var tap := create_tween()
		tap.tween_property(slot,"position:y",slot.position.y+7,.07)
		tap.tween_property(slot,"position:y",17.0,.12)
		tap.parallel().tween_method(func(_t: float): river.queue_redraw(),0.0,1.0,.12)
	river.queue_redraw()

func choose_boards(n: int) -> void:
	if step!=Step.CHOOSE: return
	if n!=SPANS-ON_HAND:
		prompt("Policz puste miejsca obok dwóch desek.","beaver_retry")
		return
	if story_order:
		ordered.emit()
		return
	step=Step.FASTEN
	choices.hide()
	prompt("Stuknij w każdy kołek, żeby przybić deski.","beaver_pegs")
	river.queue_redraw()

func draw_bridge() -> void:
	var bounds := Rect2(Vector2.ZERO,river.size)
	river.draw_rect(bounds,Color("#397b83"))
	for j in 4:
		for i in 12:
			var x := i*64.0 + (18 if j%2 else 0)
			var y := 8+j*46.0
			river.draw_line(Vector2(x,y),Vector2(x+18,y-2),Color("#81bab1"),2,true)
	for y in [37.0,river.size.y-37]:
		river.draw_line(Vector2(0,y+3),Vector2(river.size.x,y+3),Color("#473f34"),12)
		river.draw_line(Vector2(0,y),Vector2(river.size.x,y),Color("#b88c59"),6)
	for i in slots.size():
		var rect := slots[i].get_rect().grow(-5)
		var wooden := step>=Step.FASTEN or (step==Step.CHOOSE and i<ON_HAND)
		if wooden:
			river.draw_rect(rect,Color("#d29b5d"))
			river.draw_rect(rect,Color("#613f2c"),false,3)
			for k in range(1,4):
				var x := rect.position.x+rect.size.x*k*.23
				river.draw_line(Vector2(x,rect.position.y+10),Vector2(x+3,rect.end.y-12),Color("#b37a47"),2,true)
			if step>=Step.FASTEN:
				var p := rect.get_center()
				if fixed.has(i):
					river.draw_circle(p,11,Color("#6a462f"))
					river.draw_line(p-Vector2(5,0),p+Vector2(5,0),Color("#c29b73"),2)
				else:
					river.draw_circle(p,22,Color("#ffde82"),false,3,true)
					river.draw_line(p+Vector2(0,10),p-Vector2(0,9),Color("#684831"),11)
					river.draw_circle(p-Vector2(0,9),9,Color("#ffe4ac"))
		else:
			river.draw_rect(rect,Color("#245866c0"))
			river.draw_rect(rect,Color("#cce6d9"),false,3)
			if step==Step.COUNT and counted.has(i):
				var number := str(counted.find(i)+1)
				river.draw_string(ThemeDB.fallback_font,Vector2(rect.position.x,rect.get_center().y+13),number,HORIZONTAL_ALIGNMENT_CENTER,rect.size.x,38,Color("#ffe79a"))
