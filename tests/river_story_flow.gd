extends SceneTree

var game
var story
var variant:=0

func _initialize() -> void:
	call_deferred("run")

func check(ok:bool,message:String) -> bool:
	if not ok:
		printerr(message)
		quit(1)
	return ok

func click(b:Button) -> void:
	await process_frame
	var pos:=b.get_global_transform_with_canvas()*(b.size*.5)
	for down in [true,false]:
		var event:=InputEventMouseButton.new()
		event.position=pos
		event.button_index=MOUSE_BUTTON_LEFT
		event.pressed=down
		root.push_input(event,true)
	await process_frame

func walk() -> void:
	var ticks:=0
	while game.state==game.State.WALK and ticks<800:
		var diff:Vector3=game.targets[0]-game.leo.position
		var v:=Vector2(diff.x,diff.z).normalized()
		Input.action_press("ui_left",maxf(0,-v.x))
		Input.action_press("ui_right",maxf(0,v.x))
		Input.action_press("ui_up",maxf(0,-v.y))
		Input.action_press("ui_down",maxf(0,v.y))
		ticks+=1
		await physics_frame
	for key in ["ui_left","ui_right","ui_down","ui_up"]: Input.action_release(key)
	check(ticks<800,"Destination unreachable")

func reopen() -> void:
	reload_current_scene()
	await scene_changed
	game=current_scene
	story=game.bystra
	await click(game.atlas.resume)

func touch(field:Control, point:Vector2, down:bool) -> void:
	var event:=InputEventScreenTouch.new()
	event.index=1
	event.position=field.get_global_transform_with_canvas()*point
	event.pressed=down
	root.push_input(event,true)

func drag(field:Control, point:Vector2) -> void:
	var event:=InputEventScreenDrag.new()
	event.index=1
	event.position=field.get_global_transform_with_canvas()*point
	root.push_input(event,true)

func riverbank() -> bool:
	var bank=story.bank
	var id:String=bank.id
	while bank.visible and bank.id==id:
		var mode:String=bank.mode()
		var before:int=bank.marks
		var start:Vector2
		var end:Vector2
		match mode:
			"nails":
				var i:=0
				while before & (1<<i): i+=1
				start=bank.screen(bank.farm.nail_at(i))
				end=bank.screen(bank.farm.BAG)
				if before==0:
					touch(game.ui,start,true)
					touch(game.ui,start,false)
					if not check(bank.marks==0,"Nail counted outside pack"): return false
			"hay":
				start=bank.screen(bank.farm.HAYSTACK)
				end=bank.screen(bank.farm.FEED[0 if before==0 else 1])
			"milk_cow":
				start=bank.screen(bank.farm.UDDER)
				end=start+Vector2(0,48)
			"scoop":
				var i:=0
				while before & (1<<i): i+=1
				start=bank.screen(bank.kitchen.flour_at(i))
			"pour":
				start=bank.screen(bank.kitchen.SOURCE)
				end=bank.screen(bank.kitchen.BOWL+Vector3.UP*.23)
			"crack":
				start=bank.screen(bank.kitchen.egg_at(1 if before==0 else 0))
			"stir":
				var hub:Vector2=bank.screen(bank.kitchen.BOWL+Vector3.UP*.4)
				start=hub+Vector2(44,0)
				touch(game.ui,start,true)
				for i in range(1,10):
					end=hub+Vector2(44,0).rotated(i*.2*(-1 if variant==1 else 1))
					drag(game.ui,end)
				touch(game.ui,end,false)
				await process_frame
				if not check(bank.mode()!=mode or bank.marks>before,"Stir stalled"): return false
				if before==0:
					await reopen()
					bank=story.bank
					if not check(bank.mode()==mode and bank.marks==1,"Lost stirring checkpoint"): return false
				continue
			"flip":
				start=bank.screen(bank.kitchen.pancake.position)
				end=start
				await create_timer(1.2).timeout
				if variant==1:
					bank.kitchen.sense_shake(Vector3(0,9,0))
					bank.kitchen.sense_shake(Vector3(0,18,0))
			"fit":
				var i:=0
				while before & (1<<i): i+=1
				start=bank.screen(bank.bridge.YARD[i])
				end=bank.screen(bank.bridge.slot(i+2))
				if before==0:
					var wrong:Vector2=bank.screen(bank.bridge.slot(1))
					touch(game.ui,start,true)
					drag(game.ui,wrong)
					touch(game.ui,wrong,false)
					if not check(bank.marks==0,"Wrong board fitted"): return false
			"pegs":
				var i:=0
				while before & (1<<i): i+=1
				start=bank.screen(bank.bridge.pegs[i].position)
			"stones":
				var i:=1 if before==0 else (2 if ((before>>4)&3)==0 else 0)
				var target:=0
				while bank.occupied(target): target+=1
				start=bank.screen(bank.STONE_FROM[i])
				end=bank.screen(bank.STONE_TO[target])
			"hops": start=bank.screen(bank.next_hop())
		if end==Vector2.ZERO: end=start
		touch(game.ui,start,true)
		drag(game.ui,end)
		touch(game.ui,end,false)
		if mode=="pour": await create_timer(.8).timeout
		if mode=="flip":
			await create_timer(1.4).timeout
		await create_timer(.58 if mode=="hops" else .08).timeout
		if not check(not bank.visible or bank.id!=id or bank.mode()!=mode or bank.marks!=before,"No progress at "+mode+" "+str(before)+" "+str(start)+" -> "+str(end)): return false
		if mode in ["nails","hay","milk_cow","stones","fit","pegs","scoop","crack"] and before==0:
			await reopen()
			bank=story.bank
			if not check(bank.visible and bank.marks==(4 if mode=="stones" else (2 if mode=="crack" else 1)),"Lost progress at "+mode): return false
	return true

func move_to(target:Vector3) -> void:
	for i in 200:
		var diff:Vector3=target-game.leo.position
		var v:=Vector2(diff.x,diff.z)
		if v.length()<.18: break
		game.stick.vector=v.normalized()
		await physics_frame
	game.stick.vector=Vector2.ZERO

func tap_action(b:Button) -> void:
	await process_frame
	var center:=b.get_global_rect().get_center()
	touch(game.ui,center,true)
	touch(game.ui,center,false)
	await process_frame

func shoot_pair() -> bool:
	if not check(not story.field.visible and story.bow.visible,"Bow already aiming"): return false
	await tap_action(story.bow)
	for shot in 2:
		var field=story.field
		var src:Vector2=field.source_point()
		var end:Vector2=src-(field.target_point()-src)/3.5
		touch(field,src,true)
		drag(field,end)
		touch(field,end,false)
		await create_timer(.55).timeout
	return true

func visit_door(key:String) -> void:
	# Follow the village lanes around the houses.
	await move_to(story.origin+Vector3(0,0,story.village_pos.z))
	var destination:Vector3=story.Square.DOORS[key]+Vector3.BACK*.6
	await move_to(story.origin+Vector3(0,0,destination.z))
	await move_to(story.origin+destination)
	await tap_action(story.hand)
	await process_frame

func run() -> void:
	create_timer(300).timeout.connect(func(): check(false,"Timeout at "+story.id()))
	if not check(OS.get_user_data_dir().get_file().begins_with("ValleyQA-") and not FileAccess.file_exists("user://bystra-v1.cfg"),"Use isolated directory"): return
	variant=int(OS.get_environment("QA_SNACK"))
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	await scene_changed
	game=current_scene
	story=game.bystra
	await click(game.atlas.play)
	await click(story.options.get_child(1))
	await move_to(story.origin+Vector3(-2.1,0,1.3))
	await move_to(story.origin+Vector3(-2.1,0,-1.8))
	await move_to(story.visitor.global_position)
	await tap_action(story.hand)
	if not check(story.dock.visible and story.id()=="door","Talk again after declining"): return
	await click(story.options.get_child(0))
	await tap_action(story.hand)
	if not check(story.id()=="pack" and story.items.is_empty(),"Empty bag left cottage"): return
	for i in [5,0,1,2,3,4,6]:
		if i==4: await move_to(story.origin+Vector3(2.7,0,1.5))
		if i==2: await move_to(story.origin+Vector3(1.2,0,-1.8))
		if i==0: await move_to(story.origin+Vector3(-2.8,0,1.3))
		await move_to(story.pickups[i].global_position)
		await tap_action(story.hand)
		await create_timer(.32).timeout
		if i==3:
			if not check(story.bank.visible and "Gwoździe" not in story.items,"Box collected automatically"): return
			if not await riverbank(): return
		if not check(story.Data.GEAR[i] in story.items,"Cannot collect "+str(i)): return
		if i==5:
			await reopen()
			if not check(story.items.size()==1,"Pickup not saved"): return
	await move_to(story.origin+Vector3(2.6,0,1.8))
	await move_to(story.origin+Vector3(2.6,0,-1.8))
	await move_to(story.visitor.global_position)
	await tap_action(story.hand)
	if not check(story.id()=="range","Cannot exit packed"): return
	if not await shoot_pair(): return
	if not check(story.id()=="dummy","Bow tutorial"): return
	for i in 2:
		await move_to(story.actors[i].global_position)
		await tap_action(story.sword)
		await create_timer(.5).timeout
	await walk()
	if not check(story.id()=="guard","Sword tutorial"): return
	game.leo.position=story.foe.global_position+Vector3(0,0,1.1)
	await tap_action(story.sword)
	if not check(not story.busy,"Orc shield did not block"): return
	if variant==1:
		var shield_pos:Vector2=story.shield.get_global_rect().get_center()
		touch(game.ui,shield_pos,true)
		var stick_pos:Vector2=game.stick.get_global_rect().get_center()
		var second:=InputEventScreenTouch.new()
		second.index=2
		second.pressed=true
		second.position=stick_pos+Vector2(36,0)
		root.push_input(second,true)
		var first_x:float=game.leo.position.x
		await create_timer(.18).timeout
		if not check(story.blocking and game.leo.position.x>first_x,"Shield and joystick conflict"): return
		second.pressed=false
		root.push_input(second,true)
		var protected_position:Vector3=game.leo.position
		await create_timer(2.1).timeout
		if not check(story.blocking and game.leo.position.distance_to(protected_position)<.12,"Blocked attack moved Bilbo"): return
		touch(game.ui,shield_pos,false)
		await create_timer(2.25).timeout
		game.leo.position=story.foe.global_position+Vector3(0,0,1.1)
	var before:Vector3=game.leo.position
	await create_timer(2.2).timeout
	if not check(game.leo.position.distance_to(before)>.6,"No knockback"): return
	await move_to(story.foe.global_position+Vector3(.8,0,.1))
	await tap_action(story.sword)
	await create_timer(.45).timeout
	if not check(story.id()=="chief","Cannot hit exposed orc"): return
	await click(story.options.get_child(0))
	if not check(story.id()=="chief","Incorrect addition accepted"): return
	await click(story.options.get_child(1))
	await walk()
	await click(story.options.get_child(0))
	if not await riverbank(): return
	var repair=game.panel.get_child(-1)
	if not check(not repair.choices.visible,"Answers before count"): return
	for slot in repair.slots: await click(slot)
	await click(repair.choices.get_child(0))
	if not check(not story.bank.visible,"Wrong board count accepted"): return
	await click(repair.choices.get_child(1))
	if not await riverbank(): return
	await walk()
	if not check(story.id()=="lanterns","Missing dark village"): return
	await click(story.options.get_child(0))
	if not check(story.part==0,"Wrong lantern sum accepted"): return
	await click(story.options.get_child(1))
	if not check(story.part==1,"Lamps did not light"): return
	await click(story.options.get_child(0))
	if not check(story.id()=="invitation","No birthday invitation"): return
	await click(story.options.get_child(0))
	await visit_door("delivery")
	if not check(story.id()=="delivery" and story.voice=="route_need_mill","Started baking with empty bag"): return
	await click(story.outside)
	var order:Array=[["mill","dairy","coop"],["coop","mill","dairy"],["dairy","coop","mill"]][variant]
	for place in order:
		await visit_door(place)
		if not check(story.id()==place,"Could not enter "+place): return
		if place=="dairy":
			await click(story.outside)
			if not check(story.id()=="village","Cannot exit barn"): return
			await visit_door(place)
			if not await riverbank(): return
		else:
			if place=="mill":
				if not await shoot_pair(): return
				if not check(story.part==2,"Mill spiders did not retreat"): return
			else:
				await move_to(story.foe.global_position)
				await tap_action(story.sword)
				await create_timer(.6).timeout
			await move_to(story.origin+Vector3(.9,0,-.75))
			await tap_action(story.hand)
		if not check(story.id()==place,"Unexpected teleport after collecting"): return
		await move_to(story.origin+Vector3(0,0,2.13))
		await tap_action(story.hand)
		if not check(story.id()=="village" and story.square.near_door(story.village_pos)==place,"Wrong exit after "+place): return
		await reopen()
		if not check(story.id()=="village" and story.square.near_door(story.village_pos)==place,"Village position lost"): return
	if not check(story.ingredients_ready(),"Missing ingredients"): return
	await visit_door("delivery")
	await move_to(story.origin+Vector3(1.95,0,1.26))
	await move_to(story.visitor.global_position)
	await tap_action(story.hand)
	if not check(story.id()=="delivery" and story.part==1,"Food not delivered"): return
	await reopen()
	await click(story.options.get_child(0))
	for stage in ["recipe","eggs","milk"]:
		if not check(story.id()==stage,"Missing kitchen "+stage): return
		if not await riverbank(): return
	if not check(story.id()=="homecoming","No reunion"): return
	await click(story.options.get_child(0))
	if not check(game.state==game.State.HOME and not story.saved,"Save not closed"): return
	# Accelerated tests advance game time faster than the audio mixer drains MP3 playback.
	game.narrator.stop()
	game.chime.stop()
	for i in 18:
		OS.delay_msec(12)
		await process_frame
	print("PASS repair trip, controls, combat, resume, stones, boards and cooking")
	quit()
