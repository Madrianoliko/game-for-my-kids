extends Control

signal progressed(part_index:int)
signal completed
signal instruction(clip: String, caption: String)
signal performed(action: String)
const Icons := preload("res://scripts/river_icons.gd")
const SEQUENCES := {
	"pine":["aim_cone","aim_cone"], "orc1":["dodge"], "hit1":["sword"],
	"orc2":["circle"], "hit2":["sword"], "orc3":["block","block"], "hit3":["helmet"],
	"solve":["riddle"], "spool":["shadow_left","thread_left","shadow_right","thread_right","cover","aim_spool"],
	"ram":["flour","straw"], "bell":["loop","ring","hoof"]
}
const GUIDE := {
	"aim_cone":"Przytrzymaj łuk, naciągnij cięciwę w stronę dłoni i puść.",
	"aim_spool":"Wyceluj w szpulkę tak jak w szyszkę.",
	"dodge":"Gdy ork podniesie miecz, dotknij śladów z boku.",
	"sword":"Dotknij miecza, gdy zabłyśnie.",
	"circle":"Poprowadź Bilba po śladach pod tarczą na drugą stronę.",
	"block":"Gdy ork ruszy, przytrzymaj tarczę.",
	"helmet":"Hełm spada! Dotknij miecza, gdy zabłyśnie.",
	"riddle":"Pokaż hersztowi odpowiedź w lesie.",
	"shadow_left":"Popatrz na cień! Dotknij śladów po drugiej stronie pająka.",
	"shadow_right":"Drugi cień! Przeskocz na wolne miejsce.",
	"thread_left":"Mały pająk zjeżdża! Przesuń palcem w poprzek jego nitki.",
	"thread_right":"Drugi pająk! Przetnij także tę nitkę.",
	"cover":"Leci lepka kulka! Przytrzymaj deskę bobra.",
	"flour":"Baran tupie! Dotknij worka z mąką, żeby odskoczyć.",
	"straw":"Teraz zwab barana do słomy. Dotknij snopka.",
	"loop":"Przeciągnij pętlę od sznurka do dzwonka.",
	"ring":"Dotknij dzwonka albo lekko potrząśnij telefonem.",
	"hoof":"Baran już siedzi. Zadzwoń jeszcze raz albo wybierz strzałkę."
}
const GOLD := Color("#ffe18e")
const GREEN := Color("#a8f29c")
const INK := Color("#213b43")
var story
var sequence: Array
var part := 0
var age := 0.0
var finger := -1
var down := Vector2.ZERO
var tip := Vector2.ZERO
var passed_middle := false
var feedback := 0.0
var success := false
var flight := false
var arrow_end := Vector2.ZERO
var expected_answer := 0
var hoof_shown := false
var previous_accel := Vector3.ZERO
var clip := ""
var locked := false

func begin(owner_story, id:String, answer:int, saved_part:int) -> void:
	story=owner_story
	sequence=SEQUENCES[id]
	part=clampi(saved_part,0,sequence.size()-1)
	expected_answer=answer
	hoof_shown=false
	locked=false
	show()
	enter_part()

func enter_part() -> void:
	age=0
	finger=-1
	feedback=0
	flight=false
	passed_middle=false
	previous_accel=Input.get_accelerometer()
	clip="enc_"+mode()
	instruction.emit(clip,GUIDE[mode()])
	queue_redraw()

func mode() -> String: return sequence[part]

func source_point() -> Vector2:
	return Vector2(size.x*.25,size.y*.56)

func target_point() -> Vector2:
	# Screen position follows the actual actor or hanging prop.
	var offset:=Vector3(0,1.25,0)
	match mode():
		"aim_cone": offset=Vector3(.29,1.65,0)
		"aim_spool": offset=Vector3(.8,1.42,-.3)
		"ring","hoof","loop": offset=Vector3(0,.87,.49)
	var world:Vector3=story.props.global_position+offset
	if mode()=="aim_cone": world=story.actors[part].global_position+Vector3.UP*.57
	var at:Vector2=story.host.camera.unproject_position(world)
	at=get_global_transform_with_canvas().affine_inverse()*at
	return at.clamp(Vector2(size.x*.43,40),Vector2(size.x*.82,size.y-46))

func side_point(right:bool) -> Vector2:
	return Vector2(size.x*(.72 if right else .29),size.y*.72)

func thread_point() -> Vector2:
	return Vector2(size.x*(.35 if mode().ends_with("left") else .68),size.y*.45)

func ready_to_act() -> bool:
	return beat()>=.75 and beat()<=3.6

func beat() -> float:
	return fmod(age,4.4)

func arrow_tip() -> Vector2:
	return source_point()+(source_point()-tip).limit_length(125)*3.5

func _process(dt:float) -> void:
	if not visible or not story: return
	if story.host.paused:
		finger=-1
		return
	if locked: return
	if finger!=-1: hold_time+=dt
	age+=dt*(.35 if finger!=-1 and mode().begins_with("aim") else 1.0)
	if feedback>0:
		feedback-=dt
		if feedback<=0:
			flight=false
			if success:
				part+=1
				if part==sequence.size():
					locked=true
					hide()
					completed.emit()
					return
				progressed.emit(part)
				enter_part()
			else:
				age=0
				instruction.emit(clip,GUIDE[mode()])
	elif mode() in ["ring","hoof"] and OS.get_name()=="iOS":
		var accel:=Input.get_accelerometer()
		if age>.65 and previous_accel!=Vector3.ZERO and accel.distance_to(previous_accel)>8:
			if mode()=="ring": resolve(true)
			elif not hoof_shown:
				hoof_shown=true
				performed.emit("secret")
		previous_accel=accel
	queue_redraw()

func resolve(ok:bool) -> void:
	finger=-1
	success=ok
	feedback=.42 if ok else .48
	if ok: performed.emit(mode())
	else:
		instruction.emit("enc_retry","Spróbuj jeszcze raz. Popatrz na podpowiedź.")

func press(at:Vector2, id:int) -> void:
	if finger!=-1 or feedback>0 or locked: return
	finger=id
	down=at
	tip=at
	passed_middle=false
	if mode().begins_with("aim") or mode() in ["circle","loop"]:
		if at.distance_to(source_point())>55: resolve(false)

func drag(at:Vector2, id:int) -> void:
	if finger!=id: return
	tip=at
	if mode()=="circle" and at.distance_to(Vector2(size.x*.49,size.y*.84))<56: passed_middle=true

func release(at:Vector2,id:int) -> void:
	if finger!=id: return
	drag(at,id)
	var target:=target_point()
	match mode():
		"aim_cone","aim_spool":
			arrow_end=arrow_tip()
			flight=true
			resolve(arrow_end.distance_to(target)<56 and down.distance_to(at)>20)
		"thread_left","thread_right":
			var p:=thread_point()
			var crosses:=minf(down.x,at.x)<p.x and maxf(down.x,at.x)>p.x
			var near:=Geometry2D.get_closest_point_to_segment(p,down,at).distance_to(p)<48
			resolve(crosses and near and absf(down.x-at.x)>44)
		"circle": resolve(passed_middle and at.distance_to(side_point(true))<56)
		"loop": resolve(at.distance_to(target)<52)
		"shadow_left","shadow_right": resolve(at.distance_to(side_point(mode()=="shadow_left"))<54)
		"ring": resolve(at.distance_to(target)<52)
		"block","cover":
			resolve(ready_to_act() and down.distance_to(source_point())<55 and at.distance_to(source_point())<60 and hold_time>=.28)
		"riddle": resolve(at.distance_to(side_point(expected_answer==1))<55)
		"hoof":
			if at.distance_to(target)<52:
				hoof_shown=true
				performed.emit("secret")
				finger=-1
			else: resolve(at.distance_to(side_point(true))<54)
		"flour","straw","dodge": resolve(ready_to_act() and at.distance_to(side_point(mode()=="straw"))<54)
		_: resolve(ready_to_act() and at.distance_to(target)<54)

var hold_time := 0.0
func _notification(what:int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT or what==NOTIFICATION_VISIBILITY_CHANGED:
		finger=-1

func _gui_input(event:InputEvent) -> void:
	if not visible or locked or story.host.paused: return
	if event is InputEventScreenTouch:
		if event.canceled:
			if finger==event.index: finger=-1
		elif event.pressed:
			if finger==-1: hold_time=0
			press(event.position,event.index)
		else: release(event.position,event.index)
	elif event is InputEventScreenDrag: drag(event.position,event.index)
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.device!=InputEvent.DEVICE_ID_EMULATION:
		if event.pressed:
			hold_time=0
			press(event.position,-2)
		else: release(event.position,-2)
	elif event is InputEventMouseMotion: drag(event.position,-2)
	accept_event()

func tile(p:Vector2,key:String,lit:=true) -> void:
	draw_circle(p+Vector2(0,3),39,Color("#102533c9"),true,-1,true)
	draw_circle(p,37,INK,true,-1,true)
	draw_arc(p,36,0,TAU,52,GREEN if lit else GOLD,3,true)
	draw_texture_rect(Icons.picture(key),Rect2(p-Vector2(26,26),Vector2(52,52)),false)

func guide(a:Vector2,b:Vector2) -> void:
	draw_dashed_line(a,b,GOLD,3,9,true,true)
	var pos:=a.lerp(b,fmod(age*.75,1.0))
	draw_circle(pos,7,GREEN,true,-1,true)
	if finger==-1: draw_texture_rect(Icons.picture("Ręka"),Rect2(pos+Vector2(-7,3),Vector2(35,35)),false,Color(1,1,1,.8))

func strand_spider(p:Vector2) -> void:
	var body:=p+Vector2(0,20+minf(beat(),1.4)*19)
	draw_line(Vector2(p.x,0),body,Color.WHITE,4,true)
	draw_set_transform(Vector2(body.x,size.y-12),0,Vector2(1,.24))
	draw_circle(Vector2.ZERO,28,Color("#172f3899"))
	draw_set_transform(Vector2.ZERO)
	for side in [-1,1]:
		for i in 3:
			var start:=body+Vector2(side*8,i*4-6)
			draw_line(start,start+Vector2(side*17,-9+i*5),Color("#efc3db"),3,true)
	draw_circle(body,15,Color("#62465e"),true,-1,true)
	for side in [-1,1]: draw_circle(body+Vector2(side*5,-3),2.5,Color.WHITE)

func _draw() -> void:
	if not is_visible_in_tree() or sequence.is_empty() or locked: return
	var m:=mode()
	var src:=source_point()
	var target:=target_point()
	if m in ["dodge","sword","helmet","flour","straw","block"] and beat()<.75:
		var cue:=target+Vector2(0,-30)
		for i in 3:
			var angle:float=-PI*.5+(i-1)*.58
			draw_line(cue+Vector2.from_angle(angle)*8,cue+Vector2.from_angle(angle)*(14+8*beat()/.75),GOLD,4,true)
	match m:
		"aim_cone","aim_spool":
			tile(src,"Łuk")
			draw_arc(target,33,0,TAU,44,GOLD,3,true)
			var end:=target if finger==-1 else arrow_tip()
			for i in range(1,14):
				var t:=i/14.0
				draw_circle(src.lerp(end,t)-Vector2(0,44*sin(PI*t)),3,GOLD)
			if finger==-1: guide(src,src-(target-src)/3.5)
			if finger!=-1: draw_line(src,tip,Color.WHITE,4,true)
			if flight:
				var t:=clampf(1-feedback/(.42 if success else .48),0,1)
				var arrow:=src.lerp(arrow_end,t)-Vector2(0,44*sin(PI*t))
				draw_line(arrow-Vector2(26,-4),arrow,GOLD,5,true)
		"shadow_left","shadow_right":
			strand_spider(thread_point())
			tile(side_point(m=="shadow_left"),"Łapka")
		"thread_left","thread_right":
			var p:=thread_point()
			strand_spider(p)
			guide(p-Vector2(48,0),p+Vector2(48,0))
		"circle","loop":
			tile(src,"Ręka")
			if m=="circle":
				var mid:=Vector2(size.x*.49,size.y*.84)
				guide(src,mid)
				guide(mid,side_point(true))
				tile(side_point(true),"Łapka")
			else:
				guide(src,target)
				tile(target,"Dzwonek")
			if finger!=-1:
				draw_line(src,tip,Color.WHITE,4,true)
				if m=="loop": draw_arc(tip,23,0,TAU,32,GOLD,4,true)
		"block","cover":
			tile(src,"Deska" if m=="cover" else "Tarcza",ready_to_act())
			var t:=clampf((beat()-.45)/1.2,0,1)
			draw_circle(target.lerp(src,t),10,Color("#e0d7ea") if m=="cover" else GOLD)
			if finger!=-1: draw_arc(src,43,-PI/2,-PI/2+TAU*minf(hold_time/.28,1),40,GREEN,5,true)
		"riddle":
			tile(side_point(false),"Kałuża")
			tile(side_point(true),"Pień")
		"flour","straw","dodge":
			var right:=m=="straw"
			tile(side_point(right),"Słoma" if right else ("Mąka" if m=="flour" else "Łapka"),ready_to_act())
			guide(target,side_point(right))
		"ring","hoof":
			tile(target,"Dzwonek",ready_to_act())
			if m=="hoof": tile(side_point(true),"Dalej")
		_: tile(target,"Machnij mieczem",ready_to_act())
	if feedback>0 and not success:
		draw_arc(tip,36+(1-feedback/.48)*18,0,TAU,36,Color("#ffae79"),4,true)
