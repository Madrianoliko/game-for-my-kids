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

func walk_to(target:Vector3) -> void:
	for tick in 400:
		var offset:=target-camp.ground
		if offset.length()<.08: break
		game.stick.vector=Vector2(offset.x,offset.z).normalized()
		await physics_frame
	game.stick.vector=Vector2.ZERO
	expect(camp.ground.distance_to(target)<.1,"Nie udało się dojść do "+str(target))

func next_window() -> void:
	await wait_phase(Camp.Phase.LOOK,Camp.GRACE+.1)
	var previous:=camp.catches
	if not expect(camp.inside>=0 and camp.flood.visible,"Brak osłony podczas spojrzenia"): return
	await wait_phase(Camp.Phase.BACK)
	expect(camp.catches==previous,"Gapa zauważył ruch wewnątrz stogu lub kucyka")

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
	if not expect(camp!=null and not game.atlas.visible,"Wejście z menu"): return
	# Próba ominięcia opowieści dotykiem i ruchem.
	await click(camp.back)
	game.stick.vector=Vector2.UP
	await click(camp.replay)
	for line in ["intro_stolen","intro_there","intro_run","intro_hide","intro_first"]:
		while camp.message!=line: await physics_frame
	game.stick.vector=Vector2.ZERO
	if not expect(camp.ground.distance_to(Camp.START)<.1,"Ruch podczas opowieści"): return
	await create_timer(7).timeout
	if not expect(camp.phase==Camp.Phase.FIRST and not camp.flood.visible,"Gapa zaczął liczyć przed nauką"): return
	game.stick.vector=Vector2.UP
	await wait_phase(Camp.Phase.DEMO_LOOK)
	game.stick.vector=Vector2.ZERO
	if not expect(camp.inside==0 and camp.message=="intro_safe" and camp.flood.visible,"Pokaz pierwszego schowania"): return
	await wait_phase(Camp.Phase.BACK)
	await walk_to(Camp.STACKS[0]+Vector3.RIGHT*2)
	await wait_phase(Camp.Phase.CAUGHT)
	if not expect(camp.catches==1 and game.stick.vector==Vector2.ZERO,"Stojący poza stogiem uniknął złapania"): return
	await wait_phase(Camp.Phase.BACK)
	if not expect(camp.ground.distance_to(Camp.STACKS[0])<.02,"Powrót do stogu"): return
	# Bieg przez środek polany najkrótszą drogą, bez postojów.
	while camp.phase!=Camp.Phase.CAUGHT:
		var heading:=camp.ground.direction_to(Camp.TETHER)
		game.stick.vector=Vector2(heading.x,heading.z)
		await physics_frame
	game.stick.vector=Vector2.ZERO
	if not expect(camp.catches==2 and not camp.following and camp.message=="caught_again","Bieg prosto do kucyka"): return
	await wait_phase(Camp.Phase.BACK)
	while camp.message!="hint": await physics_frame
	await wait_phase(Camp.Phase.LOOK,Camp.GRACE+.1)
	var before:=camp.ground
	game.stick.vector=Vector2.RIGHT
	for i in 6: await physics_frame
	game.stick.vector=Vector2.ZERO
	if not expect(camp.inside==0 and camp.ground.distance_to(before)>.1 and camp.catches==2,"Ruch wewnątrz stogu"): return
	await wait_phase(Camp.Phase.BACK)
	for i in range(1,Camp.STACKS.size()):
		await walk_to(Camp.STACKS[i])
		await next_window()
	await walk_to(Camp.TETHER)
	if not expect(not camp.hand.disabled and camp.ropes[2].visible,"Kucyk czeka przy ognisku"): return
	await click(camp.hand)
	if not expect(camp.following and not camp.ropes[2].visible,"Odwiązanie kucyka"): return
	for i in range(Camp.STACKS.size()-1,-1,-1):
		await walk_to(Camp.STACKS[i])
		await wait_phase(Camp.Phase.LOOK,Camp.GRACE+.3)
		if not expect(camp.cover(camp.pony.position)<0 and camp.inside==i,"Kucyk ma czekać poza stogiem"): return
		var parked:=camp.pony.position
		for tick in 8: await physics_frame
		if not expect(camp.pony.position.distance_to(parked)<.02,"Kucyk ruszył się podczas ukrycia"): return
		await next_window()
	while camp.rescued_mask==0:
		var heading:=camp.ground.direction_to(Camp.TOBO)
		game.stick.vector=Vector2(heading.x,heading.z)
		await physics_frame
	game.stick.vector=Vector2.ZERO
	if not expect(camp.rescued_mask==4 and camp.message=="one","Pierwszy kucyk przy Tobie"): return
	await click(camp.back)
	reload_current_scene()
	await scene_changed
	game=current_scene
	await click(game.atlas.resume)
	camp=game.bystra.camp
	if not expect(camp.rescued_mask==4 and camp.ponies[2].position.distance_to(Camp.TOBO)<2 and not camp.ropes[2].visible,"Wznowienie z uratowanym kucykiem"): return
	var driver=load(get_script().resource_path.get_base_dir()+"/support/camp_walk.gd").new(camp)
	for i in [1,0]:
		if not expect(await driver.rescue(i,click),"Powrót z kucykiem %s"%i): return
	while game.bystra.id()=="camp": await physics_frame
	if not expect(game.bystra.id()=="stable_home","Powrót do stajni"): return
	print("PASS światło Gapy, trzy kucyki, wznowienie po jednym i powrót do stajni")
	quit()
