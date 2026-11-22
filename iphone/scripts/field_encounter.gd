extends Control

signal progressed(part_index:int)
signal completed
signal instruction(clip: String, caption: String)
signal performed(action: String)
const Icons := preload("res://scripts/river_icons.gd")
const SEQUENCES := {
	"pine":["aim_cone","aim_cone"],
}
const GUIDE := {
	"aim_cone":"Przytrzymaj łuk, naciągnij cięciwę w stronę dłoni i puść.",
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
var feedback := 0.0
var success := false
var flight := false
var arrow_end := Vector2.ZERO
var clip := ""
var locked := false

func begin(owner_story, id:String, saved_part:int) -> void:
	story=owner_story
	sequence=SEQUENCES[id]
	part=clampi(saved_part,0,sequence.size()-1)
	locked=false
	show()
	enter_part()

func enter_part() -> void:
	age=0
	finger=-1
	feedback=0
	flight=false
	clip="enc_"+mode()
	instruction.emit(clip,GUIDE[mode()])
	queue_redraw()

func mode() -> String: return sequence[part]

func source_point() -> Vector2:
	return Vector2(size.x*.25,size.y*.56)

func target_point() -> Vector2:
	var world:Vector3=story.actors[part].global_position+Vector3.UP*.57
	var at:Vector2=story.host.camera.unproject_position(world)
	at=get_global_transform_with_canvas().affine_inverse()*at
	return at.clamp(Vector2(size.x*.43,40),Vector2(size.x*.82,size.y-46))

func arrow_tip() -> Vector2:
	return source_point()+(source_point()-tip).limit_length(125)*3.5

func _process(dt:float) -> void:
	if not visible or not story: return
	if story.host.paused:
		finger=-1
		return
	if locked: return
	age+=dt*(.35 if finger!=-1 else 1.0)
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
	if at.distance_to(source_point())>55: resolve(false)

func drag(at:Vector2, id:int) -> void:
	if finger!=id: return
	tip=at

func release(at:Vector2,id:int) -> void:
	if finger!=id: return
	drag(at,id)
	var target:=target_point()
	arrow_end=arrow_tip()
	flight=true
	resolve(arrow_end.distance_to(target)<56 and down.distance_to(at)>20)

func _notification(what:int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT or what==NOTIFICATION_VISIBILITY_CHANGED:
		finger=-1

func _gui_input(event:InputEvent) -> void:
	if not visible or locked or story.host.paused: return
	if event is InputEventScreenTouch:
		if event.canceled:
			if finger==event.index: finger=-1
		elif event.pressed:
			press(event.position,event.index)
		else: release(event.position,event.index)
	elif event is InputEventScreenDrag: drag(event.position,event.index)
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.device!=InputEvent.DEVICE_ID_EMULATION:
		if event.pressed:
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

func _draw() -> void:
	if not is_visible_in_tree() or sequence.is_empty() or locked: return
	var src:=source_point()
	var target:=target_point()
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
	if feedback>0 and not success:
		draw_arc(tip,36+(1-feedback/.48)*18,0,TAU,36,Color("#ffae79"),4,true)
