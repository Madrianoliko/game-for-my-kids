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
	while game.bystra.id()!="pack": await physics_frame
	await click(game.pause_button)
	var menu=game.ui.get_node("PauseMenu")
	var volume:Button=menu.find_child("Głośnik",true,false)
	var before:bool=game.sound
	if not require(volume.icon!=null and volume.text=="" and volume.size.y>=game.bystra.hand.size.y,"Duże obrazki w pauzie"): return
	await click(volume)
	if not require(game.sound!=before and game.paused,"Dźwięk w pauzie"): return
	await click(volume)
	await click(menu.find_child("Wznów",true,false))
	if not require(not game.paused,"Wznowienie z ikony"): return
	await click(game.pause_button)
	menu=game.ui.get_node("PauseMenu")
	await click(menu.find_child("Menu",true,false))
	await process_frame
	if not require(game.atlas.visible and game.atlas.resume.visible,"Menu z zapisem"): return
	await click(game.atlas.resume)
	if not require(game.bystra.active and game.bystra.id()=="pack","Wznów przygodę Bilba"): return
	var legacy:=ConfigFile.new()
	legacy.set_value("story","version",3)
	legacy.set_value("story","route","door")
	legacy.set_value("story","declined",true)
	legacy.save(game.bystra.FILE)
	await click(game.pause_button)
	await click(game.ui.get_node("PauseMenu").find_child("Menu",true,false))
	await click(game.atlas.resume)
	if not require(game.bystra.id()=="pack" and game.bystra.items.is_empty(),"Wznowienie po dawnej odmowie"): return
	game.bystra.begin(false)
	if not require(game.bystra.id()=="valley_intro" and game.bystra.options.get_child_count()==2,"Strzałka przy powtórce"): return
	await click(game.bystra.options.get_child(0))
	if not require(game.bystra.id()=="door","Pominięcie przelotu"): return
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
