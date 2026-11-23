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

func position_in_camp() -> Vector3:
	return camp.to_local(game.leo.global_position)

func wait_phase(phase:Camp.Phase, after:=0.0) -> void:
	while camp.phase!=phase or camp.elapsed<after: await physics_frame

func walk_to(target:Vector3, sneak:=true) -> void:
	for tick in 1800:
		var offset:=target-position_in_camp()
		if offset.length()<.09: break
		var moving:=not sneak or camp.phase==Camp.Phase.BACK
		game.stick.vector=Vector2(offset.x,offset.z).normalized() if moving else Vector2.ZERO
		await physics_frame
	game.stick.vector=Vector2.ZERO
	expect(position_in_camp().distance_to(target)<.12,"Nie udało się dojść do "+str(target))

func run() -> void:
	create_timer(150).timeout.connect(func(): expect(false,"Przekroczony czas w obozie"))
	if not expect(OS.get_user_data_dir().get_file().begins_with("ValleyQA-"),"Wymagany izolowany zapis"): return
	var save_path:="user://bystra-v1.cfg"
	# Opaque existing save must survive even if chapter one cannot load its format.
	var sentinel:="[test]\nvalue=77\n"
	var file:=FileAccess.open(save_path,FileAccess.WRITE)
	file.store_string(sentinel)
	file.close()
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	await scene_changed
	game=current_scene
	await click(game.atlas.camp_trial)
	for child in game.get_children():
		if child is Camp: camp=child
	if not expect(camp!=null and not game.atlas.visible,"Wejście z menu"): return
	await wait_phase(Camp.Phase.BACK)
	await walk_to(Camp.BUSHES[0])
	await wait_phase(Camp.Phase.LOOK,Camp.GRACE+.05)
	var hides_at:=position_in_camp()
	game.stick.vector=Vector2.RIGHT
	for i in 8: await physics_frame
	game.stick.vector=Vector2.ZERO
	if not expect(camp.in_light(hides_at) and position_in_camp().distance_to(hides_at)>.1 and camp.catches==0,"Ruch w krzaku"): return
	var exposed:Vector3=Camp.BUSHES[0]+Vector3.RIGHT*(Camp.HIDE_RADIUS+.35)
	await walk_to(exposed)
	await wait_phase(Camp.Phase.LOOK,Camp.GRACE+.05)
	for i in 16: await physics_frame
	if not expect(camp.in_light(exposed) and camp.cover(exposed)<0 and camp.catches==0,"Stanie w świetle"): return
	game.stick.vector=Vector2.RIGHT
	await wait_phase(Camp.Phase.CAUGHT)
	game.stick.vector=Vector2.ZERO
	await wait_phase(Camp.Phase.BACK)
	if not expect(camp.catches==1 and position_in_camp().distance_to(Camp.BUSHES[0])<.02,"Powrót do pierwszego krzaka"): return
	await walk_to(Camp.BUSHES[1])
	await walk_to(Camp.TETHER)
	if not expect(not camp.hand.disabled and camp.rope.visible,"Kucyk czeka przy drzewie"): return
	await click(camp.hand)
	if not expect(camp.following and not camp.rope.visible and camp.hay.visible,"Uwolnienie kucyka dłonią"): return
	var near_edge:Vector3=Camp.BUSHES[1]+Camp.BUSHES[1].direction_to(Camp.TETHER)*.85
	await walk_to(near_edge)
	await wait_phase(Camp.Phase.LOOK,Camp.GRACE+.05)
	var pony_pos:=camp.pony.position
	if not expect(camp.in_light(pony_pos) and camp.cover(pony_pos)<0,"Kucyk powinien wystawać zza krzaka"): return
	for i in 12: await physics_frame
	if not expect(camp.pony.position.is_equal_approx(pony_pos),"Kucyk rusza się przy stojącym Bilbie"): return
	game.stick.vector=Vector2.LEFT
	for i in 8: await physics_frame
	game.stick.vector=Vector2.ZERO
	if not expect(camp.catches==1,"Odkryty kucyk zdradził schowanego Bilba"): return
	await walk_to(Camp.BUSHES[1]+Vector3.LEFT*(Camp.HIDE_RADIUS+.4))
	await wait_phase(Camp.Phase.LOOK,Camp.GRACE+.05)
	game.stick.vector=Vector2.LEFT
	await wait_phase(Camp.Phase.CAUGHT)
	await wait_phase(Camp.Phase.BACK)
	if not expect(camp.catches==2 and camp.following and camp.pony.position.distance_to(Camp.BUSHES[1])<=Camp.FOLLOW_DISTANCE+.02,"Powrót razem z kucykiem"): return
	while camp.message!="hint": await physics_frame
	await walk_to(Camp.BUSHES[0])
	# Enter the return zone, then let the thank-you and the star finish.
	while camp.phase!=Camp.Phase.DONE:
		var offset:=Camp.TOBO-position_in_camp()
		game.stick.vector=Vector2(offset.x,offset.z).normalized() if camp.phase==Camp.Phase.BACK else Vector2.ZERO
		await physics_frame
	while not camp.star.visible: await physics_frame
	while not game.atlas.visible: await physics_frame
	if not expect(FileAccess.get_file_as_string(save_path)==sentinel and not FileAccess.file_exists("user://valley.cfg"),"Próba zmieniła zapis gry"): return
	if not expect(game.camera.current and not game.stick.visible,"Przywrócenie menu"): return
	if failures==0:
		print("PASS obóz: stożek, bezruch, krzaki, dwa powroty, kucyk, podpowiedź, gwiazdka i zapis")
		quit()
