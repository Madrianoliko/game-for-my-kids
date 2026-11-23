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

func check_flow() -> void:
	if not require(OS.get_user_data_dir().get_file().begins_with("ValleyQA-"),"Izolowany zapis"): return
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	await scene_changed
	game=current_scene
	if not require(game.atlas.visible and not game.atlas.resume.visible and not game.atlas.chapter_two.visible,"Menu bez zapisu"): return
	await click(game.atlas.play)
	await click(game.bystra.options.get_child(0))
	await click(game.pause_button)
	var menu:AcceptDialog=game.ui.get_child(-1)
	if not require(menu.dialog_text=="Bilbo poczeka tutaj.","Pauza Bilba"): return
	menu.custom_action.emit("map")
	await process_frame
	if not require(game.atlas.visible and game.atlas.resume.visible,"Menu z zapisem"): return
	await click(game.atlas.resume)
	if not require(game.bystra.active and game.bystra.id()=="pack","Wznów przygodę Bilba"): return
	var legacy:=ConfigFile.new()
	legacy.set_value("story","version",3)
	legacy.set_value("story","route","mill")
	legacy.set_value("story","part",2)
	legacy.set_value("story","items",PackedStringArray(game.bystra.Data.GEAR))
	legacy.save(game.bystra.FILE)
	reload_current_scene()
	await scene_changed
	game=current_scene
	await click(game.atlas.resume)
	if not require(game.bystra.id()=="mill" and game.bystra.part==2 and game.bystra.chapters==0,"Stary zapis w młynie"): return
	print("PASS menu, wznowienie i wcześniejszy zapis z młyna")
	quit()
