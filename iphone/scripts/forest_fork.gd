extends Node3D

const START := Vector3(0,0,4.6)
const EDGE := Vector3(0,0,-4.8)
const STREAM := Vector3(4.4,0,.15)
const FAR_BANK := Vector3(4.4,0,-2.4)
const LONG := [START, Vector3(3.2,0,2.65), STREAM, FAR_BANK, Vector3(3.5,0,-3.6), EDGE]
const WIDTH := 1.15
const SPEED := 3.6

var story

func setup(owner_story) -> void:
	story=owner_story
	var game=story.host
	game.box(self,Vector3(0,-.17,0),Vector3(24,.32,18),Color("#496443"))
	for i in range(1,LONG.size()):
		var a:Vector3=LONG[i-1]
		var b:Vector3=LONG[i]
		var strip=game.box(self,(a+b)*.5,Vector3(WIDTH*2,.04,a.distance_to(b)),Color("#b5966c"))
		strip.rotation.y=atan2(b.x-a.x,b.z-a.z)
		game.orb(self,b,.99,Color("#b5966c")).scale=Vector3(WIDTH,.025,WIDTH)
	game.box(self,STREAM+Vector3(0,.028,-1.1),Vector3(3.9,.045,1.9),Color("#68afb9"))
	for i in 3:
		game.orb(self,STREAM+Vector3(.28*cos(i*PI),.10,-.5-i*.52),.36,Color("#aaa993")).scale.y=.38
	for x in [-1.25,1.25]:
		game.orb(self,EDGE+Vector3(x,.48,0),.8,Color("#507348"))
	var start:=START
	if story.fork_path=="long": start=FAR_BANK if story.part==1 else LONG[1]
	game.mark_goal(to_global(EDGE if story.part==1 else STREAM)+Vector3.UP*.24)
	game.leo.global_position=to_global(start)
	game.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	game.camera.size=maxf(13.8,14.0/game.ui.size.aspect())
	game.camera.look_at_from_position(global_position+Vector3(0,15,8),global_position,Vector3.UP)
	story.say("fork_walk" if story.part==1 else "fork_stream")

func on_trail(pos:Vector3,path:Array) -> bool:
	for i in range(1,path.size()):
		if pos.distance_to(Geometry3D.get_closest_point_to_segment(pos,path[i-1],path[i]))<=WIDTH: return true
	return false

func tick(dt:float) -> void:
	var game=story.host
	var leo=game.leo
	var pos:=to_local(leo.global_position)
	var input:Vector2=game.stick.vector
	if input.is_zero_approx(): input=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if input.is_zero_approx(): return
	var step:=Vector3(input.x,0,input.y).limit_length(1)*SPEED*dt
	var next:=pos+step
	if not on_trail(next,LONG): return
	leo.global_position=to_global(next)
	leo.rotation.y=atan2(-step.x,-step.z)
	if story.fork_path=="" and absf(next.x)>1.55:
		story.fork_path="long"
		story.checkpoint()
	if story.part==0 and next.z<=STREAM.z+.35:
		story.go_to("fork",2)
	elif next.distance_to(EDGE)<.8 and story.part==1:
		story.advance()
