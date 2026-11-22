# Run outside the exported game with --main-pack and --script.
# Use override.cfg to set a unique custom user directory starting with ValleyQA-.
extends SceneTree

var game
var failed := false

func _initialize() -> void:
	call_deferred("check_flow")

func require(ok: bool, message: String) -> bool:
	if not ok:
		failed = true
		printerr(message)
		quit(1)
	return ok

func numeric_button(row:Container, answer:int, correct:bool) -> Button:
	for button:Button in row.get_children():
		if button.text.is_valid_int() and (button.text == str(answer)) == correct:
			return button
	return null

func click(control: Button) -> void:
	await process_frame
	var position := control.get_global_transform_with_canvas() * (control.size * .5)
	for down in [true,false]:
		var event := InputEventMouseButton.new()
		event.position = position
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event,true)
	await process_frame

func answer_button(n: int) -> Button:
	for b in game.panel.find_children("*","Button",true,false):
		if b.text == str(n): return b
	return null

func idle_start() -> bool:
	await click(game.atlas.classic)
	if not require(game.state==game.State.WALK and game.stage==0,"Start button"): return false
	var pos: Vector3 = game.leo.position
	await create_timer(15).timeout
	return require(game.state==game.State.WALK and game.stage==0 and game.stars==0 and is_equal_approx(game.leo.position.x,pos.x) and is_equal_approx(game.leo.position.z,pos.z),"Start advanced without input (stage %d, position %s -> %s)" % [game.stage,pos,game.leo.position])

func walk_until_stop() -> void:
	var ticks := 0
	while game.state==game.State.WALK and ticks<3200:
		var pos: Vector3 = game.leo.position
		var target: Vector3 = game.targets[0]
		var direction := Vector2(target.x-pos.x,target.z-pos.z).normalized()
		Input.action_press("ui_right",maxf(direction.x,0))
		Input.action_press("ui_left",maxf(-direction.x,0))
		Input.action_press("ui_down",maxf(direction.y,0))
		Input.action_press("ui_up",maxf(-direction.y,0))
		await physics_frame
		ticks+=1
	for key in ["ui_left","ui_right","ui_down","ui_up"]: Input.action_release(key)
	require(ticks<3200,"Walking timed out")

func check_flow() -> void:
	create_timer(160).timeout.connect(func(): require(false,"Test timed out"))
	if not require(not ResourceLoader.exists("res://scripts/smoke.gd"),"Package contains the automatic walkthrough"): return
	if not require(OS.get_user_data_dir().get_file().begins_with("ValleyQA-"),"Use an isolated QA user directory"): return
	if not require(not FileAccess.file_exists("user://valley.cfg"),"Use a new QA directory"): return
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	await scene_changed
	game=current_scene
	if not require(game.best==0 and game.state==game.State.HOME,"Fresh menu"): return
	if not await idle_start(): return
	print("Fresh start idle for 15 seconds: OK")
	await walk_until_stop()
	if not require(game.state==game.State.MATH and game.stage==0,"Beaver"): return
	await create_timer(2).timeout
	var repair = game.panel.get_child(-1)
	await click(repair.slots[3])
	await click(repair.slots[3])
	if not require(repair.counted.size()==1,"Counted one gap twice"): return
	for i in [0,4,2,1]: await click(repair.slots[i])
	if not require(repair.choices.visible,"Five gaps counted"): return
	await click(numeric_button(repair.choices, 3, false))
	if not require(repair.choices.visible and game.stars==0,"Incorrect board count advanced"): return
	await click(numeric_button(repair.choices, 3, true))
	for i in [2,2,0,4,1]: await click(repair.slots[i])
	if not require(repair.fixed.size()==4 and not repair.cross.visible,"Duplicate peg"): return
	await click(repair.slots[3])
	if not require(repair.cross.visible and game.stage==0,"Manual crossing prompt"): return
	await click(repair.cross)
	if not require(game.stage==1 and game.stars==1 and game.boards.size()==5,"Repair reward"): return
	for board in game.boards:
		if not require(board.visible,"Missing plank on repaired bridge"): return
	var crossing_start: Vector3 = game.leo.position
	await create_timer(.5).timeout
	if not require(game.leo.position.is_equal_approx(crossing_start),"Crossed without input"): return
	await walk_until_stop()
	if not require(game.state==game.State.STORY,"Fox"): return
	await click(game.panel.find_children("*","Button",true,false)[0])
	await click(answer_button(game.answer))
	await walk_until_stop()
	if not require(game.state==game.State.FIGHT and game.cottage.remaining==2,"Ambush"): return
	await create_timer(2).timeout
	if not require(game.cottage.remaining==2,"Automatic sword"): return
	await click(game.action_button)
	await create_timer(.8).timeout
	if not require(game.state==game.State.FIGHT and game.cottage.remaining==1,"First sword"): return
	await click(game.action_button)
	await create_timer(1).timeout
	if not require(game.state==game.State.WALK and game.stage==6,"Door walk"): return
	await walk_until_stop()
	if not require(game.state==game.State.INSIDE and not game.cottage.basket.visible,"Door entry"): return
	await click(game.action_button)
	if not require(game.state==game.State.END and game.cottage.basket.visible,"Delivery"): return
	await click(game.action_button)
	if not require(game.state==game.State.HOME and game.best==4,"Return to map"): return
	if not await idle_start(): return
	print("Player-controlled route and restart from menu: OK")
	reload_current_scene()
	await scene_changed
	game=current_scene
	if not require(game.best==4 and game.state==game.State.HOME,"Load previous 4/4"): return
	if not await idle_start(): return
	print("Loaded 4/4 and idle for 15 seconds: OK")
	quit(int(failed))
