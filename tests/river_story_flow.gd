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

func numeric_button(row:Container, answer:int, correct:bool) -> Button:
	for button:Button in row.get_children():
		if button.text.is_valid_int() and (button.text == str(answer)) == correct:
			return button
	return null

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

func walk_fork(target:Vector3) -> void:
	for tick in 180:
		if story.id()!="fork" or story.bank.visible or story.fork_trail.roll>0: break
		var delta:Vector3=target-story.fork_trail.to_local(game.leo.global_position)
		if delta.length()<.08: break
		game.stick.vector=Vector2(delta.x,delta.z).normalized()
		await physics_frame
	game.stick.vector=Vector2.ZERO

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
				end=bank.screen(bank.bridge.slot(i+bank.bridge.on_hand))
				if before==0:
					var wrong:Vector2=bank.screen(bank.bridge.slot(0))
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
	if story.id()=="range" and not check(story.voice=="route_drawstring","Missing bow instruction"): return false
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
	create_timer(540).timeout.connect(func(): check(false,"Timeout at "+story.id()))
	if not check(OS.get_user_data_dir().get_file().begins_with("ValleyQA-") and not FileAccess.file_exists("user://bystra-v1.cfg"),"Use isolated directory"): return
	variant=int(OS.get_environment("QA_SNACK"))
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	await scene_changed
	game=current_scene
	story=game.bystra
	if not check(not game.atlas.chapter_three.visible,"Smoczek zablokowany przed rozdziałem 2"): return
	seed(179)
	var positions := {}
	for i in 30:
		var choices:Array[int] = story.Data.number_choices(3)
		if not check(choices.size()==3 and choices[0]>=1 and choices[1]==choices[0]+1 and choices[2]==choices[1]+1 and 3 in choices,"Invalid number choices"): return
		positions[choices.find(3)] = true
		for small in [1,2]:
			var low:Array[int] = story.Data.number_choices(small)
			if not check(low.min()>=1 and small in low,"Invalid small answer"): return
	if not check(positions.size()==3,"Missing answer position"): return
	seed(23)
	var first:Dictionary=story.Data.draw_numbers()
	seed(42)
	if not check(first!=story.Data.draw_numbers(),"Różne ziarna losują różne liczby"): return
	seed([23,10,1][variant])
	await click(game.atlas.play)
	var rolled:Dictionary=story.numbers.duplicate()
	await reopen()
	if not check(story.numbers==rolled,"Zapis zachowuje wylosowane liczby"): return
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
		if not check(story.voice=="route_guard_side","Missing flanking instruction"): return
		touch(game.ui,shield_pos,false)
		await create_timer(2.25).timeout
		game.leo.position=story.foe.global_position+Vector3(0,0,1.1)
	var before:Vector3=game.leo.position
	await create_timer(2.2).timeout
	if not check(game.leo.position.distance_to(before)>.6,"No knockback"): return
	await move_to(story.foe.global_position+Vector3(.8,0,.1))
	if variant==1 and not check(story.voice=="route_guard_sword","Missing sword instruction"): return
	await tap_action(story.sword)
	await create_timer(.45).timeout
	if not check(story.id()=="chief","Cannot hit exposed orc"): return
	await click(numeric_button(story.options, story.numbers.chief, false))
	if not check(story.hint_total==0,"Za wczesna pomoc"): return
	await click(numeric_button(story.options, story.numbers.chief, false))
	await create_timer(5).timeout
	if not check(story.hint_lit==story.numbers.chief,"Liczenie po drugiej pomyłce"): return
	if not check(story.id()=="chief","Incorrect addition accepted"): return
	await click(numeric_button(story.options, story.numbers.chief, true))
	await walk()
	await click(story.options.get_child(0))
	if not await riverbank(): return
	var repair=game.panel.get_child(-1)
	if not check(not repair.choices.visible,"Answers before count"): return
	for slot in repair.slots: await click(slot)
	await click(numeric_button(repair.choices, story.numbers.boards, false))
	if not check(story.hint_total==0,"Za wczesna pomoc"): return
	await click(numeric_button(repair.choices, story.numbers.boards, false))
	await create_timer(5).timeout
	if not check(story.hint_lit==story.numbers.boards,"Liczenie po drugiej pomyłce"): return
	if not check(not story.bank.visible and repair.highlighted==story.numbers.boards and repair.preview==0,"Trzy podświetlone luki mostu"): return
	await click(numeric_button(repair.choices, story.numbers.boards, true))
	if not await riverbank(): return
	await walk()
	if not check(story.id()=="lanterns","Missing dark village"): return
	var wrong_lamps:=numeric_button(story.options,story.numbers.lamps,false)
	await click(wrong_lamps)
	for i in story.square.lamp_order.size():
		if not check(story.square.lit_lanterns.get_child(story.square.lamp_order[i]).visible==(i<int(wrong_lamps.text)),"Liczba zapalonych latarenek"): return
	if not check(story.hint_total==0,"Za wczesna pomoc"): return
	await click(numeric_button(story.options, story.numbers.lamps, false))
	await create_timer(5).timeout
	if not check(story.hint_lit==story.numbers.lamps,"Liczenie po drugiej pomyłce"): return
	for index in story.square.lamp_order:
		var lamp=story.square.lit_lanterns.get_child(index)
		if not check(lamp.is_visible_in_tree(),"Latarenka nadal ciemna po podpowiedzi"): return
	if not check(story.part==0,"Wrong lantern sum accepted"): return
	await click(numeric_button(story.options, story.numbers.lamps, true))
	if not check(story.part==1 and story.hint_total==0,"Lamps did not light"): return
	await click(story.options.get_child(0))
	if not check(story.id()=="invitation","No birthday invitation"): return
	await click(story.options.get_child(0))
	if not check(story.ingredient_list.visible,"Missing ingredient list"): return
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
		if not check(story.ingredient_ticks[story.Square.FOOD[place]].visible,"Missing ingredient tick"): return
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
	if not check(not story.ingredient_list.visible,"List visible after delivery"): return
	await click(story.options.get_child(0))
	for stage in ["recipe","eggs","milk"]:
		if not check(story.id()==stage,"Missing kitchen "+stage): return
		if not await riverbank(): return
	if not check(story.id()=="homecoming","No reunion"): return
	await click(story.options.get_child(0))
	while story.id()=="homecoming": await physics_frame
	if not check(story.id()=="stable" and story.chapters==1,"Ukończenie rozdziału 1"): return
	while story.part==0: await physics_frame
	for i in [2,1,4]:
		if story.stable.targets[i].visible: await click(story.stable.targets[i])
	while story.options.get_child_count()<3: await physics_frame
	await click(numeric_button(story.options,story.pony_count(),false))
	if not check(story.hint_total==0,"Za wczesna pomoc"): return
	await click(numeric_button(story.options,story.pony_count(),false))
	await create_timer(5).timeout
	if not check(story.hint_lit==story.pony_count(),"Liczenie po drugiej pomyłce"): return
	if not check(story.part==1,"Błędna odpowiedź w stajni"): return
	await click(numeric_button(story.options,story.pony_count(),true))
	while story.part==2: await physics_frame
	# Zapis stajni sprzed dodania jabłek zawierał część 3 i pustą kieszeń.
	await reopen()
	if not check(story.id()=="stable" and story.part==3 and not "Jabłko" in story.items,"Stary zapis stajni"): return
	await click(story.options.get_child(0))
	if not check(story.items.count("Jabłko")==story.travel_apples,"Prowiant od Toba"): return
	await click(story.options.get_child(0))
	await reopen()
	if not check(story.id()=="night_bridge" and game.stick.visible,"Wznowienie na moście"): return
	await walk()
	if not check(story.id()=="chief_sad","Spotkanie za mostem"): return
	while story.part==0: await physics_frame
	for total in range(1,story.travel_apples+1):
		while story.options.get_child(0).disabled: await physics_frame
		await click(story.options.get_child(0))
		if total==1: await reopen()
		if not check(story.marks==total and story.items.count("Jabłko")==story.travel_apples-total,"Przekazanie jabłka"): return
	while story.part==1: await physics_frame
	for attempt in 2: await click(numeric_button(story.options,story.travel_apples,false))
	if not check(story.part==2 and story.hint_total==story.travel_apples,"Pomoc w liczeniu"): return
	await create_timer(1).timeout
	if not check(story.hint_lit==1 and story.pickups[0].material_override.emission_enabled and not story.pickups[1].material_override.emission_enabled,"Jabłka zapalają się po kolei"): return
	await click(numeric_button(story.options,story.travel_apples,true))
	var old_chief:=ConfigFile.new()
	old_chief.load(story.FILE)
	old_chief.erase_section_key("story","fork_path")
	old_chief.save(story.FILE)
	await reopen()
	if not check(story.fork_path=="" and story.part==3 and story.voice.begins_with("route_sad_thanks"),"Wskazówka herszta po wznowieniu"): return
	await click(story.options.get_child(0))
	if not check(story.id()=="fork" and game.stick.visible,"Rozwidlenie po spotkaniu"): return
	var fork_save:=ConfigFile.new()
	fork_save.load(story.FILE)
	var path=story.fork_trail
	await walk_fork(path.SHORT[1])
	await reopen()
	path=story.fork_trail
	if not check(story.fork_path=="short","Zapis krótkiej drogi"): return
	await walk_fork(path.SLEEPER)
	if not check(path.roll>0,"Brak reakcji śpiącego trolla"): return
	while path.roll>0: await physics_frame
	if not check(path.to_local(game.leo.global_position).distance_to(path.SHORT[1])<.1,"Powrót przed krąg"): return
	for point in path.SHORT.slice(2): await walk_fork(point)
	if not check(story.id()=="camp" and story.fork_path=="short","Obejście Chrapka"): return
	fork_save.save(story.FILE)
	await reopen()
	path=story.fork_trail
	await walk_fork(path.LONG[1])
	await walk_fork(path.STREAM)
	if not check(story.bank.visible and story.bank.mode()=="hops","Wejście do strumienia"): return
	var stone:Vector2=story.bank.screen(story.bank.next_hop())
	touch(game.ui,stone,true)
	touch(game.ui,stone,false)
	await create_timer(.65).timeout
	await reopen()
	if not check(story.bank.visible and story.marks==1 and story.fork_path=="long","Wznowienie na kamieniu"): return
	if not await riverbank(): return
	path=story.fork_trail
	await walk_fork(path.LONG[-2])
	await walk_fork(path.EDGE)
	if not check(story.id()=="camp" and story.fork_path=="long","Obóz za strumieniem"): return
	var driver=load(get_script().resource_path.get_base_dir()+"/support/camp_walk.gd").new(story.camp)
	var order_ponies:Array=[0,2,1] if variant==0 else [1,0,2]
	for i in order_ponies:
		if not (story.numbers.camp & (1<<i)): continue
		if not check(await driver.rescue(i,click),"Nie udało się odprowadzić kucyka %s"%i): return
	while story.id()=="camp": await physics_frame
	if not check(story.id()=="troll_dawn","Gapa zatrzymuje Bilba po trzecim ratunku"): return
	for round_index in 3:
		var answer:int=[story.numbers.rocks,story.numbers.sausages,story.numbers.cones][round_index]
		if round_index==1:
			while story.part!=story.dawn.Beat.SKEWER: await physics_frame
			if not check(story.dawn.objects.size()==answer+1,"Cztery kiełbaski przed zjedzeniem"): return
			while story.age<story.dawn.deadline-.25: await physics_frame
			if not check(story.dawn.objects.back().scale.x<.3,"Burczyk zjada kiełbaskę"): return
		while not story.dawn.answers.has(story.part): await physics_frame
		var stage:int=story.part
		if not check(story.dawn.objects.size()==answer and story.dawn.daylight==round_index,"Przedmioty i światło"): return
		for item in story.dawn.objects:
			var xy:Vector2=game.camera.unproject_position(item.global_position)
			if not check(root.get_visible_rect().has_point(xy) and not story.dock.get_global_rect().has_point(xy),"Przedmiot poza obszarem dotyku"): return
			touch(game.ui,xy,true)
			touch(game.ui,xy,false)
		if not check(story.dawn.counted.size()==answer,"Liczenie przedmiotów dotykiem"): return
		for error in 2: await click(numeric_button(story.options,answer,false))
		if not check(story.part==stage and story.dawn.daylight==round_index and story.marks==2,"Śmiech bez zmiany pory dnia"): return
		if round_index==1: await reopen()
		while story.hint_lit<answer: await physics_frame
		if not check(story.hint_lit==answer,"Podpowiedź liczy wszystkie przedmioty"): return
		await click(numeric_button(story.options,answer,true))
		if not check(story.dawn.daylight==round_index+1,"Poprawna odpowiedź rozjaśnia niebo"): return
	while story.part!=story.dawn.Beat.END: await physics_frame
	await physics_frame
	for troll in story.dawn.trolls:
		if not check(troll.has_meta("stone"),"Kamienne trolle po wschodzie słońca"): return
	await click(story.options.get_child(0))
	if not check(story.id()=="troll_cave" and story.part==0,"Wejście do jaskini za trollami"): return
	await click(story.options.get_child(0))
	await reopen()
	if not check(story.part==1 and story.items.count(story.ReturnTrip.MAP)==1 and story.ReturnTrip.APPLES in story.items,"Zawartość skrzyni po wznowieniu"): return
	await click(story.options.get_child(0))
	if not check(story.id()=="chief_happy" and story.part==0,"Herszt czeka na trakcie"): return
	await click(story.options.get_child(0))
	await reopen()
	if not check(story.part==1 and story.ReturnTrip.APPLES not in story.items and story.ReturnTrip.MAP in story.items,"Oddano jabłka, zachowano mapę"): return
	await click(story.options.get_child(0))
	for actor in story.return_trip.ponies+[game.leo,game.marker]:
		if not check(root.get_visible_rect().has_point(game.camera.unproject_position(actor.global_position)),"Kucyki i cel widoczne na początku przeprawy"): return
	for expected in range(1,story.pony_count()+1):
		game.stick.vector=Vector2.DOWN
		for tick in 180:
			await physics_frame
			if story.marks>=expected: break
		game.stick.vector=Vector2.ZERO
		if not check(story.marks==expected and story.return_trip.ponies[expected-1].global_position.z>=story.ReturnTrip.BRIDGE_START,"Kucyk wchodzi na deski"): return
		if expected==1:
			await reopen()
			if not check(story.part==2 and story.marks==1 and game.stick.visible,"Wznowienie z pierwszym kucykiem na moście"): return
	game.stick.vector=Vector2.DOWN
	while story.id()=="chief_happy": await physics_frame
	if not check(story.id()=="stable_home" and story.stone_hill.is_visible_in_tree(),"Stajnia i wzgórze trolli"): return
	var legacy_stable:=ConfigFile.new()
	legacy_stable.load(story.FILE)
	legacy_stable.erase_section_key("story","stone_hill")
	legacy_stable.set_value("story","items",PackedStringArray())
	legacy_stable.save(story.FILE)
	await reopen()
	if not check(story.id()=="stable_home" and story.part==0 and story.stone_hill.visible and story.ReturnTrip.MAP in story.items,"Istniejący zapis stajni za nowym krokiem"): return
	for i in [3,1,4,0,2]: await click(story.stable.targets[i])
	while not game.atlas.visible: await physics_frame
	var cfg:=ConfigFile.new()
	cfg.load(story.FILE)
	if not check(cfg.get_value("story","chapters_completed")==2 and game.atlas.chapter_two.visible and game.atlas.stone_marker.visible and not game.atlas.resume.visible,"Ukończenie rozdziału 2"): return
	if not check(game.atlas.chapter_three.visible,"Odblokowanie smoczka"): return
	await click(game.atlas.chapter_three)
	if not check(story.id()=="dragon_map" and story.ReturnTrip.MAP in story.items,"Mapa w chatce"): return
	await click(story.options.get_child(0))
	await move_to(story.origin+story.iskierka.SHRUB)
	if not check(story.part==1,"Spotkanie w krzakach"): return
	await click(story.options.get_child(0))
	if not check(story.part==1 and not story.iskierka.flame.visible,"Zasięg ognia"): return
	await move_to(story.origin+story.iskierka.LANTERN)
	if not check(story.iskierka.dragon.position.distance_to(story.iskierka.LANTERN)<1.85,"Smoczyca idzie za Bilbem"): return
	await click(story.options.get_child(0))
	await create_timer(.5).timeout
	if not check(story.part==2 and story.iskierka.flame.visible,"Kichnięcie zapala latarnię"): return
	await click(story.options.get_child(0))
	if not check(story.id()=="dragon_berries","Sześć jagód"): return
	for i in 6:
		await move_berry(i,0 if i<4 else 1)
		if i==2:
			await reopen()
			if not check(story.iskierka.slots.count(1)==3,"Zapis ułożonych jagód"): return
	if not check(story.part==0 and story.iskierka.pointing==1,"Iskierka pokazuje mniejszą porcję"): return
	await move_berry(0,1)
	if not check(story.part==1 and story.iskierka.spark.scale.x>2,"Równe porcje rozjaśniają płomyk"): return
	var old_end:=ConfigFile.new()
	old_end.load(story.FILE)
	old_end.set_value("story","ended",true)
	await click(story.options.get_child(0))
	if not check(story.id()=="mountain_fork","Droga za sadem"): return
	await tap_model(story.iskierka.rocks[0])
	for i in 3:
		await tap_model(story.iskierka.rocks[i])
		await create_timer(.55).timeout
	if not check(story.id()=="mountain_steps","Przeprawa przez strumień"): return
	old_end.save(story.FILE)
	await reopen()
	if not check(story.id()=="mountain_fork" and story.part==0,"Starszy zapis po nakarmieniu Iskierki"): return
	await tap_model(story.iskierka.bush)
	if not check(story.part==2,"Ścieżka przez jeżyny"): return
	await click(story.options.get_child(0))
	await create_timer(1).timeout
	if not check(story.id()=="mountain_steps","Wypalenie przejścia"): return
	for i in 2:
		await place_step(5,2)
		await create_timer(.55).timeout
	if not check(story.marks==0 and story.voice=="route_mountain_help","Podpowiedź po dwóch pomyłkach"): return
	await place_step(2,2)
	await reopen()
	if not check(story.marks==2,"Zapis naprawionego stopnia"): return
	await place_step(7,7)
	await place_step(5,5)
	if not check(story.marks==7,"Trzy złote stopnie"): return
	await click(story.options.get_child(0))
	var side:int=story.iskierka.large_side
	await reopen()
	if not check(story.id()=="warm_cave" and story.iskierka.large_side==side,"Wznowienie z tymi samymi kupkami"): return
	for i in 2:
		await tap_model(story.iskierka.piles[1-side])
		await create_timer(.4).timeout
	if not check(story.part==0 and story.voice=="route_mountain_point" and story.iskierka.fire.scale.y<1,"Mały ogień i wskazanie kupki"): return
	await tap_model(story.iskierka.piles[side])
	await create_timer(.4).timeout
	if not check(story.part==1 and story.iskierka.fire.scale.y>1,"Duże ognisko ogrzewa Iskierkę"): return
	await click(story.options.get_child(0))
	if not check(game.atlas.visible and game.atlas.chapter_three.visible,"Powrót z ciepłej jaskini"): return
	await click(game.atlas.chapter_two)
	if not check(story.id()=="stable","Wejście do rozdziału 2 z menu"): return
	# Accelerated tests advance game time faster than the audio mixer drains MP3 playback.
	game.narrator.stop()
	game.chime.stop()
	for i in 18:
		OS.delay_msec(12)
		await process_frame
	print("PASS oba rozdziały, ratunki i odblokowanie rozdziału. Wylosowane liczby ",rolled)
	quit()

func move_berry(i:int,side:int) -> void:
	var start:Vector2=game.camera.unproject_position(story.iskierka.berries[i].global_position)
	var end:Vector2=game.camera.unproject_position(story.iskierka.leaves[side].global_position)
	touch(game.ui,start,true)
	drag(game.ui,end)
	touch(game.ui,end,false)
	await process_frame

func tap_model(node:Node3D) -> void:
	var p:Vector2=game.camera.unproject_position(node.global_position)
	touch(game.ui,p,true)
	touch(game.ui,p,false)
	await process_frame

func place_step(piece:int,socket:int) -> void:
	var at:Vector2=game.camera.unproject_position(story.iskierka.rocks[piece-1].global_position)
	var end:Vector2=game.camera.unproject_position(story.iskierka.sockets[socket-1].global_position)
	touch(game.ui,at,true)
	drag(game.ui,end)
	touch(game.ui,end,false)
	await process_frame
