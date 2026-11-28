extends SceneTree

const Camp := preload("res://scripts/troll_camp.gd")
var game
var camp:Camp
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func expect(ok:bool, why:String) -> bool:
	if not ok:
		failures+=1
		printerr(why)
		quit(1)
	return ok

func click(button:Button) -> void:
	await process_frame
	var point:=button.get_global_rect().get_center()
	for down in [true,false]:
		var event:=InputEventMouseButton.new()
		event.button_index=MOUSE_BUTTON_LEFT
		event.pressed=down
		event.position=point
		root.push_input(event,true)
	await process_frame

func wait_phase(phase:Camp.Phase, after:=0.0) -> void:
	while camp.phase!=phase or camp.elapsed<after: await physics_frame

func run() -> void:
	create_timer(420).timeout.connect(func(): expect(false,"Przekroczony czas w obozie"))
	if not expect(OS.get_user_data_dir().get_file().begins_with("ValleyQA-"),"Wymagany izolowany zapis"): return
	var save_path:="user://bystra-v1.cfg"
	var cfg:=ConfigFile.new()
	cfg.set_value("story","route","camp")
	cfg.set_value("story","version",3)
	cfg.set_value("story","chapters_completed",1)
	cfg.save(save_path)
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	await scene_changed
	game=current_scene
	await click(game.atlas.resume)
	camp=game.bystra.camp
	if not expect(game.bystra.id()=="camp" and camp!=null and not game.atlas.visible,"Stary zapis obozu sprzed dodania nocnego mostu"): return
	# Próba ominięcia opowieści dotykiem i ruchem.
	await click(camp.back)
	game.stick.vector=Vector2.UP
	await click(camp.replay)
	for line in ["intro_stolen","intro_there","intro_run","intro_first"]:
		while camp.message!=line: await physics_frame
	game.stick.vector=Vector2.ZERO
	if not expect(camp.ground.distance_to(Camp.START)<.1,"Ruch podczas opowieści"): return
	await create_timer(7).timeout
	if not expect(camp.phase==Camp.Phase.FIRST,"Patrol czeka na pierwszą kryjówkę"): return
	game.stick.vector=Vector2.UP
	await wait_phase(Camp.Phase.DEMO)
	game.stick.vector=Vector2.ZERO
	if not expect(camp.inside==0 and camp.cone.visible and camp.in_light(camp.ground),"Światło na pierwszym stogu"): return
	await wait_phase(Camp.Phase.PATROL)
	camp.patrol_angle=0
	camp.update_patrol(0)
	var before:=camp.gapa.position
	# Bieg za plecami Gapy w zasięgu latarni.
	camp.ground=before-camp.cone.basis.z*1.2
	game.stick.vector=Vector2.DOWN
	for tick in 8: await physics_frame
	game.stick.vector=Vector2.ZERO
	if not expect(camp.catches==0 and camp.gapa.position.distance_to(before)>.05,"Bezpieczny ruch za patrolem"): return
	# Nawet stojący Bilbo zostaje zauważony w świetle poza sianem.
	camp.ground=camp.gapa.position+camp.cone.basis.z*1.7
	await wait_phase(Camp.Phase.CAUGHT)
	await wait_phase(Camp.Phase.PATROL)
	if not expect(camp.catches==1 and camp.ground.distance_to(Camp.STACKS[0])<.1,"Powrót do stogu po złapaniu"): return
	var lit_frames:=0
	for tick in 1250:
		await physics_frame
		if camp.in_light(camp.ground): lit_frames+=1
	if not expect(lit_frames>10 and camp.catches==1,"Stóg chroni, gdy przechodzi światło"): return
	var driver=load(get_script().resource_path.get_base_dir()+"/support/camp_walk.gd").new(camp)
	if not expect(await driver.rescue(2,click),"Pierwszy kucyk przy Tobie"): return
	await click(camp.back)
	reload_current_scene()
	await scene_changed
	game=current_scene
	await click(game.atlas.resume)
	camp=game.bystra.camp
	if not expect(camp.rescued_mask==4 and camp.ponies[2].position.distance_to(Camp.TOBO)<2 and not camp.ropes[2].visible,"Wznowienie z uratowanym kucykiem"): return
	driver=load(get_script().resource_path.get_base_dir()+"/support/camp_walk.gd").new(camp)
	for i in [1,0]:
		if not expect(await driver.rescue(i,click),"Powrót z kucykiem %s"%i): return
	while game.bystra.id()=="camp": await physics_frame
	if not expect(game.bystra.id()=="troll_dawn" and game.bystra.part==0,"Zapis starego obozu prowadzi do kłótni bez utraty ratunków"): return
	print("PASS światło Gapy, trzy kucyki, wznowienie po jednym i spotkanie z Gapą")
	quit()
