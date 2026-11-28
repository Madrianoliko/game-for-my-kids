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
		if story.id()!="fork" or story.bank.visible: break
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

func walk_until_change(direction:Vector2, limit:=300) -> int:
	var route:String=story.id()
	var phase:int=story.part
	for frame in limit:
		game.stick.vector=direction
		await physics_frame
		if story.id()!=route or story.part!=phase:
			game.stick.vector=Vector2.ZERO
			return frame+1
	game.stick.vector=Vector2.ZERO
	return -1

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
	if not check(story.id()=="valley_intro" and story.square.visible and story.options.get_child_count()==1,"Pierwszy przelot nad doliną"): return
	var first_view:Vector3=game.camera.position
	await create_timer(2).timeout
	if not check(first_view.distance_to(game.camera.position)>1,"Ruch kamery we wstępie"): return
	while story.id()=="valley_intro": await physics_frame
	if not check(story.id()=="door" and story.voice=="route_door" and story.options.get_child_count()==1,"Prośba bobra bez wyboru odpowiedzi"): return
	while story.id()=="door": await physics_frame
	for i in story.pickups.size():
		var at:Vector2=game.camera.unproject_position(story.pickups[i].global_position)
		for j in i:
			var other:Vector2=game.camera.unproject_position(story.pickups[j].global_position)
			if not check(at.distance_to(other)>=game.ui.size.y*.12,"Odstęp narzędzi na ekranie"): return
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
	if not check(story.id()=="kids_arrive" and story.voice=="route_kids_arrive","Narrator zapowiada dzieci"): return
	while story.id()=="kids_arrive": await physics_frame
	if not check(story.id()=="range" and story.voice=="route_range","Dzieci proszą o pokaz łuku"): return
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
		var food:String=story.Square.FOOD[place]
		if not check(food not in story.items and story.food_models.size()>0,"Składnik czeka na podniesienie"): return
		if place=="dairy":
			await reopen()
			if not check(story.part==2 and food not in story.items,"Wiaderko czeka po wznowieniu"): return
		await move_to(story.origin+Vector3(.9,0,-.75))
		var pickup_position:Vector3=game.leo.position
		await tap_action(story.hand)
		if not check(story.food_models.all(func(model): return not model.visible) and game.leo.position.is_equal_approx(pickup_position),"Podniesiony składnik znika, Bilbo zostaje na miejscu"): return
		if not check(story.ingredient_ticks[story.Square.FOOD[place]].visible,"Missing ingredient tick"): return
		if not check(story.id()==place,"Unexpected teleport after collecting"): return
		await move_to(story.origin+Vector3(0,0,2.13))
		await tap_action(story.hand)
		if not check(story.id()=="village" and story.square.near_door(story.village_pos)==place,"Wrong exit after "+place): return
		await reopen()
		if not check(story.id()=="village" and story.square.near_door(story.village_pos)==place,"Village position lost"): return
		await tap_action(story.hand)
		if not check(story.id()=="village","Ponowne naciśnięcie przy drzwiach po wznowieniu"): return
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
	if not check(story.id()=="homecoming" and not story.visitor.visible,"Tygrysek czeka za drzwiami"): return
	while story.part==0: await physics_frame
	if not check(story.part==2 and story.visitor.visible,"Wejście Tygryska do ciemnej chatki"): return
	while story.part==2: await physics_frame
	if not check(story.voice=="route_birthday_surprise","Niespodzianka przed świeczkami"): return
	while story.part!=5: await physics_frame
	if not check(story.voice=="route_homecoming","Sto lat po zapaleniu świeczek"): return
	await click(story.options.get_child(0))
	while story.id()=="homecoming": await physics_frame
	if not check(story.id()=="stable" and story.chapters==1,"Ukończenie rozdziału 1"): return
	while story.part==0: await physics_frame
	var empty_count:=0
	for i in [2,1,4]:
		if story.stable.targets[i].visible:
			await click(story.stable.targets[i])
			empty_count+=1
			var badge:=story.stable.floors[i].get_node_or_null("CountBadge") as Label3D
			if not check(badge and badge.text==str(empty_count) and badge.modulate.r>badge.modulate.g,"Czerwony numer pustego boksu"): return
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
	await tap_action(story.hand)
	if not check(story.part==3 and story.items.count("Jabłko")==0,"Koszyk poza zasięgiem"): return
	await move_to(story.stable.global_position+story.PROVISIONS)
	await tap_action(story.hand)
	if not check(story.items.count("Jabłko")==story.travel_apples,"Prowiant od Toba"): return
	await click(story.options.get_child(0))
	await reopen()
	if not check(story.id()=="night_bridge" and game.stick.visible,"Wznowienie na moście"): return
	await walk()
	if not check(story.id()=="chief_sad","Spotkanie za mostem"): return
	while story.part!=1: await physics_frame
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
	var basket_total:int=story.travel_apples+story.chief_stock
	await reopen()
	if not check(story.part==4 and story.pickups.size()==basket_total,"Drugie pytanie i pełny kosz po wznowieniu"): return
	for apple in story.pickups:
		await tap_model(apple)
		if not check(apple.has_node("CountBadge"),"Można dotknąć każdego jabłka"): return
	await click(numeric_button(story.options,basket_total,true))
	var old_chief:=ConfigFile.new()
	old_chief.load(story.FILE)
	old_chief.erase_section_key("story","fork_path")
	old_chief.save(story.FILE)
	await reopen()
	if not check(story.fork_path=="" and story.part==3 and story.voice=="route_sad_reward","Wskazówka herszta po wznowieniu"): return
	await click(story.options.get_child(0))
	if not check(story.id()=="fork" and game.stick.visible,"Rozwidlenie po spotkaniu"): return
	var fork_save:=ConfigFile.new()
	fork_save.load(story.FILE)
	fork_save.set_value("story","fork_path","short")
	fork_save.save(story.FILE)
	await reopen()
	var path=story.fork_trail
	if not check(story.fork_path=="long" and story.voice=="route_fork_stream","Dawna krótka droga prowadzi nad strumień"): return
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
		for error in 2:
			await click(numeric_button(story.options,answer,false))
			while story.dawn.debating_mistake: await physics_frame
		if not check(story.part==stage and story.dawn.daylight==round_index and story.marks==2,"Śmiech bez zmiany pory dnia"): return
		if round_index==1: await reopen()
		while story.hint_lit<answer: await physics_frame
		if not check(story.hint_lit==answer,"Podpowiedź liczy wszystkie przedmioty"): return
		await click(numeric_button(story.options,answer,true))
		if not check(story.dawn.daylight==round_index+1,"Poprawna odpowiedź rozjaśnia niebo"): return
		for speaker in 3:
			while story.dawn.line<speaker: await physics_frame
			if round_index==0 and speaker==1:
				await reopen()
				if not check(story.dawn.line==1,"Wznowienie riposty Chrapka"): return
			if not check(story.voice.begins_with("route_quarrel_") and story.dawn.DISPUTES.has(story.part),"Trzy głosy po dobrej odpowiedzi"): return
	while story.part!=story.dawn.Beat.END: await physics_frame
	await physics_frame
	for troll in story.dawn.trolls:
		if not check(troll.has_meta("stone"),"Kamienne trolle po wschodzie słońca"): return
	await click(story.options.get_child(0))
	if not check(story.id()=="troll_cave" and story.part==0,"Wejście do jaskini za trollami"): return
	await click(story.options.get_child(0))
	if not check(story.part==3 and story.voice=="route_cave_find","Otwarta skrzynia z mapą i jabłkami"): return
	while story.part==3: await physics_frame
	await reopen()
	if not check(story.part==2 and story.map_sheet.visible and story.ReturnTrip.MAP not in story.items,"Rozwinięta mapa po wznowieniu"): return
	await create_timer(.3).timeout
	var map_center:Vector2=game.ui.size*.5
	touch(game.ui,map_center,true)
	touch(game.ui,map_center,false)
	await create_timer(.4).timeout
	if not check(story.part==1 and not story.map_sheet.visible and story.items.count(story.ReturnTrip.MAP)==1 and story.ReturnTrip.APPLES in story.items,"Złożona mapa w plecaku"): return
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
	var pen_order:=[3,1,4,0,2]
	for i in pen_order:
		await click(story.stable.targets[i])
		var badge=story.stable.floors[i].get_node("CountBadge")
		if not check(badge.text==str(pen_order.find(i)+1) and badge.modulate==story.Count.PRESENT,"Kolejność zielonych numerków"): return
	while story.id()=="stable_home": await physics_frame
	await reopen()
	if not check(story.id()=="map_sleep" and story.chapters==2,"Wieczór po powrocie kucyków"): return
	while story.id()=="map_sleep": await physics_frame
	if not check(story.id()=="dragon_map" and story.ReturnTrip.MAP in story.items,"Mapa w chatce"): return
	await click(story.options.get_child(0))
	var frames:=await walk_until_change(Vector2.RIGHT,800)
	if not check(frames>=600 and story.part==1,"Ponad dziesięć sekund śladami łapek"): return
	if not check(story.options.get_child_count()==0 and game.stick.visible,"Iskierka prowadzi bez ikon akcji"): return
	await move_to(story.origin+story.iskierka.LANTERN)
	await create_timer(9).timeout
	if not check(story.part==3 and story.options.get_child_count()==1 and story.voice=="route_dragon_fire","Pojedynczy płomyk po pokazie"): return
	await click(story.iskierka.fire_button)
	await create_timer(.5).timeout
	if not check(story.part==2 and story.iskierka.flame.visible,"Kichnięcie zapala latarnię"): return
	await walk_until_change(Vector2.RIGHT)
	if not check(story.id()=="dragon_berries","Dojście do krzaka z jagodami"): return
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
	old_end.save(story.FILE)
	await reopen()
	if not check(story.id()=="mountain_fork" and story.part==0,"Starszy zapis po nakarmieniu Iskierki"): return
	await tap_model(story.iskierka.bush)
	if not check(story.part==0,"Jeżyny czekają za strumieniem"): return
	for i in 3:
		await tap_model(story.iskierka.rocks[i])
		await create_timer(.55).timeout
	if not check(story.part==3 and game.stick.visible,"Po kamieniach Bilbo idzie dalej"): return
	await walk_until_change(Vector2.RIGHT)
	if not check(story.part==2,"Dojście do jeżyn"): return
	await click(story.options.get_child(0))
	await create_timer(1).timeout
	await walk_until_change(Vector2.RIGHT)
	if not check(story.id()=="mountain_steps","Marsz do schodów"): return
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
	await walk_until_change(Vector2.RIGHT)
	if not check(story.id()=="warm_cave","Wejście po stopniach gałką"): return
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
	var cave_end:=ConfigFile.new()
	cave_end.load(story.FILE)
	cave_end.set_value("story","ended",true)
	await click(story.options.get_child(0))
	if not check(story.id()=="mole_candles","Od ogniska do pustelnika"): return
	cave_end.save(story.FILE)
	await reopen()
	if not check(story.id()=="mole_candles" and story.part==0,"Wznowienie starszego zakończenia w jaskini"): return
	await click(story.options.get_child(0))
	for i in 5:
		await tap_model(story.iskierka.tokens[i])
		if i==1:
			await reopen()
			if not check(story.marks==3,"Wznowienie po dwóch świeczkach"): return
	if not check(story.part==2,"Policzone świeczki na torcie i na półce"): return
	var missing:int=story.iskierka.unlit.size()
	if not check(missing in [2,3,4],"Część świeczek już płonie"): return
	var initial:int=story.iskierka.initial_lights
	await reopen()
	if not check(story.iskierka.initial_lights==initial,"Zapalone świeczki po wznowieniu"): return
	await click(numeric_button(story.options,missing-1,true))
	await create_timer(3).timeout
	if not check(story.iskierka.lights.filter(func(light): return light.visible).size()==4,"Jedna świeczka nadal zgaszona"): return
	await click(numeric_button(story.options,missing+1,true))
	await create_timer(3.9).timeout
	if not check(story.hint_total==missing and story.iskierka.hat.rotation.z>.4,"Przypalona czapka i pomoc w liczeniu"): return
	await click(numeric_button(story.options,missing,true))
	await create_timer(3.2).timeout
	if not check(story.part==3 and story.iskierka.lights.all(func(light): return light.visible),"Pięć płomyków"): return
	await click(story.options.get_child(0))
	if not check(story.id()=="dragon_nest","Mama na szczycie"): return
	await click(story.options.get_child(0))
	var missing_kids:int=story.iskierka.empty_seats.size()
	for i in [2,0,3,1]:
		if i>=5-missing_kids: continue
		await tap_model(story.iskierka.tokens[i])
		if i==0:
			await reopen()
			if not check(story.iskierka.tokens[2].get_node("CountBadge").text=="1" and story.iskierka.tokens[0].get_node("CountBadge").text=="2","Kolejność smoczątek po wznowieniu"): return
	for i in 2: await click(numeric_button(story.options,missing_kids,false))
	if not check(story.part==2 and story.hint_total==missing_kids,"Mama pokazuje puste miejsca"): return
	await click(numeric_button(story.options,missing_kids,true))
	await create_timer(1).timeout
	if not check(story.part==3 and story.iskierka.mother.wings[0].rotation.x>1,"Mama obejmuje Iskierkę"): return
	await click(story.options.get_child(0))
	var takeoff:Vector3=game.camera.position
	await create_timer(4).timeout
	if not check(story.id()=="dragon_flight" and game.camera.position.distance_to(takeoff)>4 and story.square.is_visible_in_tree(),"Lot nad znajomą doliną"): return
	while story.id()=="dragon_flight": await physics_frame
	await reopen()
	if not check(story.id()=="cave_descent" and story.chapters==3,"Wznowienie zejścia do jaskini"): return
	while story.id()=="cave_descent": await physics_frame
	if not check(story.id()=="whisper_cave" and "Latarka" in story.items,"Bilbo wchodzi z latarką"): return
	await click(story.options.get_child(0))
	if not check("Latarka" not in story.items,"Szeptek zabiera latarkę"): return
	await click(story.options.get_child(0))
	await tap_model(story.whisper.entrances[2])
	if not check(story.id()=="fish_pool" and story.whisper.swimmers.size()==6,"Wybór rybek jako pierwszego tunelu"): return
	await click(story.options.get_child(0))
	await create_timer(1.6).timeout
	if not check(story.part==2 and not story.whisper.swimmers[4].visible and story.whisper.targets.size()==4,"Dwie rybki odpłynęły"): return
	await tap_model(story.whisper.targets[0])
	if not check(story.whisper.counted==1,"Liczenie rybek palcem"): return
	await click(numeric_button(story.options,4,true))
	await click(story.options.get_child(0))
	await tap_model(story.whisper.entrances[0])
	if not check(story.id()=="drip_tunnel" and story.whisper.answers[0].disabled,"Najpierw słuchanie"): return
	for attempt in 3:
		if not await verify_drops(3,attempt==2): return
		if attempt<2: await click(numeric_button(story.options,3,false))
	await tap_model(story.whisper.flashes[2])
	if not check(story.whisper.counted==4,"Liczenie dotykiem po dwóch pomyłkach"): return
	await click(numeric_button(story.options,3,true))
	await reopen()
	if not check(story.marks==1 and story.whisper.wall_gems[0].material_override.emission_enabled,"Pierwszy wielki kryształ po wznowieniu"): return
	await click(story.options.get_child(0))
	if not await verify_drops(5,false): return
	await click(story.options.get_child(-1))
	if not await verify_drops(5,false): return
	await click(numeric_button(story.options,5,true))
	await click(story.options.get_child(0))
	await reopen()
	if not check(story.whisper.reward_lit(4) and story.whisper.reward_lit(1),"Ryby i krople pamiętane niezależnie"): return
	var hall_save:=ConfigFile.new()
	hall_save.load(story.FILE)
	var legacy:=ConfigFile.new()
	legacy.load(story.FILE)
	var previous:Dictionary=legacy.get_value("story","numbers")
	previous.erase("drops_won")
	previous.erase("cave_rewards")
	legacy.set_value("story","numbers",previous)
	legacy.save(story.FILE)
	await reopen()
	if not check(story.whisper.reward_lit(1) and not story.whisper.reward_lit(4),"Zapis Z10 zachowuje dwa kryształy"): return
	hall_save.save(story.FILE)
	await reopen()
	await tap_model(story.whisper.entrances[1])
	for pattern in 2:
		if not check(story.id()=="pattern_door" and story.part==pattern,"Wzór drzwi"): return
		for i in 2: await insert_gem(1-story.whisper.solution)
		if not check(story.voice=="route_cave_pattern_hint","Podpowiedź do wzoru"): return
		await insert_gem(story.whisper.solution)
		if not check(story.part==pattern+2,"Drzwi przyjęły pasujący kryształ"): return
		await click(story.options.get_child(0))
	await click(story.options.get_child(0))
	if not check(story.id()=="whisper_hands" and not story.whisper.second_hand.visible,"Szeptek pokazuje jedną rękę"): return
	await click(story.options.get_child(0))
	for i in 2: await click(numeric_button(story.options,6,false))
	if not check(story.whisper.second_hand.visible and story.hint_total==6,"Liczenie sześciu palców"): return
	await click(numeric_button(story.options,6,true))
	await click(story.options.get_child(0))
	for total in [2,4,6]:
		if not check(story.whisper.targets.size()==total,"Nogi widoczne do policzenia"): return
		await click(numeric_button(story.options,total,true))
	await reopen()
	if not check(story.id()=="whisper_exit" and story.items.count("Latarka")==1 and story.whisper.wall_gems.all(func(g): return g.material_override.emission_enabled),"Latarka i siedem zapalonych kryształów po wznowieniu"): return
	while story.id()=="whisper_exit": await physics_frame
	await reopen()
	if not check(story.id()=="continued" and story.chapters==4 and "Latarka" in story.items,"Wznowienie po zakończeniu czwartego rozdziału"): return
	await click(story.options.get_child(0))
	if not check(game.atlas.visible and game.atlas.resume.visible and game.atlas.chapter_four.visible and game.atlas.chapter_three.visible,"Mapa rozdziałów po zakończeniu"): return
	await click(game.atlas.chapter_two)
	for dialog in game.ui.get_children():
		if dialog is ConfirmationDialog: dialog.confirmed.emit()
	if not check(story.id()=="stable","Wejście do rozdziału 2 z menu"): return
	# Accelerated tests advance game time faster than the audio mixer drains MP3 playback.
	game.narrator.stop()
	game.chime.stop()
	for i in 18:
		OS.delay_msec(12)
		await process_frame
	print("PASS cztery rozdziały, dowolny wybór tunelu i odzyskanie latarki. Wylosowane liczby ",rolled)
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

func verify_drops(total:int, persistent:bool) -> bool:
	var seen:=0
	for frame in 1200:
		await process_frame
		if story.whisper.heard>seen:
			seen+=1
			if not check(story.whisper.flashes[seen-1].material_override.emission_enabled,"Błysk przy każdym kapnięciu"): return false
		if not story.whisper.listening: break
	return check(seen==total and not story.whisper.answers[0].disabled and story.whisper.flashes.all(func(g): return g.material_override.emission_enabled==persistent),"Liczba kropli, pomoc i odblokowane odpowiedzi")

func insert_gem(i:int) -> void:
	var start:Vector2=story.whisper.screen_at(story.whisper.pieces[i])
	var end:Vector2=story.whisper.screen_at(story.whisper.socket)
	touch(game.ui,start,true)
	drag(game.ui,end)
	touch(game.ui,end,false)
	await process_frame
