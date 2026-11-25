extends Node3D

const START := Vector3(0,0,4.6)
const EDGE := Vector3(0,0,-4.8)
const SLEEPER := Vector3(-3.4,0,-.6)
const STREAM := Vector3(4.4,0,.15)
const FAR_BANK := Vector3(4.4,0,-2.4)
const SHORT := [START, Vector3(-3.25,0,2.2), Vector3(-5.45,0,-.6), Vector3(-3.3,0,-3.1), EDGE]
const LONG := [START, Vector3(3.2,0,2.65), STREAM, FAR_BANK, Vector3(3.5,0,-3.6), EDGE]
const WIDTH := 1.15
const WAKE_RADIUS := 1.4
const SPEED := 3.6
const SNORE_PERIOD := 3.3

var story
var sleeper:Node3D
var roll:=0.0
var caught_at:=Vector3.ZERO
var noises:=0
var snore_time:=0.0

func setup(owner_story) -> void:
	story=owner_story
	var game=story.host
	game.box(self,Vector3(0,-.17,0),Vector3(24,.32,18),Color("#496443"))
	for path in [SHORT,LONG]:
		for i in range(1,path.size()):
			var a:Vector3=path[i-1]
			var b:Vector3=path[i]
			var strip=game.box(self,(a+b)*.5,Vector3(WIDTH*2,.04,a.distance_to(b)),Color("#b5966c"))
			strip.rotation.y=atan2(b.x-a.x,b.z-a.z)
			game.orb(self,b,.99,Color("#b5966c")).scale=Vector3(WIDTH,.025,WIDTH)
	game.box(self,STREAM+Vector3(0,.028,-1.1),Vector3(3.9,.045,1.9),Color("#68afb9"))
	for i in 3:
		game.orb(self,STREAM+Vector3(.28*cos(i*PI),.10,-.5-i*.52),.36,Color("#aaa993")).scale.y=.38
	for x in [-1.25,1.25]:
		game.orb(self,EDGE+Vector3(x,.48,0),.8,Color("#507348"))
	var ring:=TorusMesh.new()
	ring.inner_radius=WAKE_RADIUS-.065
	ring.outer_radius=WAKE_RADIUS+.065
	game.mesh(self,ring,SLEEPER+Vector3.UP*.09,Color("#ffc876"),true)
	sleeper=story.actor("troll",SLEEPER+Vector3(.55,.53,0),.92)
	sleeper.rotation.z=PI*.5
	var start:=START
	if story.fork_path=="short": start=SHORT[1]
	if story.fork_path=="long": start=FAR_BANK if story.part==1 else LONG[1]
	game.leo.global_position=to_global(start)
	game.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	game.camera.size=maxf(13.8,14.0/game.ui.size.aspect())
	game.camera.look_at_from_position(global_position+Vector3(0,15,8),global_position,Vector3.UP)
	story.say("fork_choose" if story.fork_path=="" else ("fork_quiet" if story.fork_path=="short" else "fork_walk"))

func on_trail(pos:Vector3,path:Array) -> bool:
	for i in range(1,path.size()):
		if pos.distance_to(Geometry3D.get_closest_point_to_segment(pos,path[i-1],path[i]))<=WIDTH: return true
	return false

func tick(dt:float) -> void:
	var game=story.host
	var leo=game.leo
	var pos:=to_local(leo.global_position)
	snore_time-=dt
	if snore_time<=0:
		if story.fork_path!="long" and roll<=0: story.effect("story/fork_snore")
		snore_time=SNORE_PERIOD
	if roll>0:
		roll=maxf(0,roll-dt)
		var turn:=smoothstep(0,1,1-roll)
		sleeper.rotation.x=lerpf(0,.85,turn if noises%2==1 else 1-turn)
		leo.global_position=to_global(caught_at.lerp(SHORT[1],smoothstep(0,1,1-roll)))
		return
	var input:Vector2=game.stick.vector
	if input.is_zero_approx(): input=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if input.is_zero_approx(): return
	var step:=Vector3(input.x,0,input.y).limit_length(1)*SPEED*dt
	var next:=pos+step
	if not ((story.fork_path!="long" and on_trail(next,SHORT)) or (story.fork_path!="short" and on_trail(next,LONG))): return
	leo.global_position=to_global(next)
	leo.rotation.y=atan2(-step.x,-step.z)
	if story.fork_path=="" and absf(next.x)>1.55:
		story.fork_path="short" if next.x<0 else "long"
		story.checkpoint()
		story.say("fork_quiet" if next.x<0 else "fork_walk")
	if story.fork_path=="short" and next.distance_to(SLEEPER)<WAKE_RADIUS:
		caught_at=next
		roll=1
		noises+=1
		story.effect("story/fork_murmur")
		if noises>=2: story.say("fork_hint")
	elif story.fork_path=="long" and story.part==0 and next.z<=STREAM.z+.35:
		story.go_to("fork",2)
	elif next.distance_to(EDGE)<.8 and (story.fork_path=="short" or story.part==1):
		story.advance()
