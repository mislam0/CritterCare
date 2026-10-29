extends "res://tests/verify.gd"
## Merge acceptance: pet creator + new toys alongside the team's ten-theme branch.
const Looks = preload("res://data/pet_looks.gd")
const Slots = preload("res://scripts/save_slots.gd")
const UI = preload("res://scripts/ui.gd")

func press_named(name: String) -> void:
	await frames(3)
	var button = game.ui.find_child(name, true, false)
	check(button != null, "Reachable control: " + name)
	if button != null:
		await click(button.get_global_rect().get_center() * (Vector2(root.size) / Vector2(1280,800)))

func clipped_labels(node: Node, result: Array) -> void:
	if node is UI.LearningText and node.is_visible_in_tree() and not node.fit_content and not node.content_fits(): result.append(node.words)
	for child in node.get_children(): clipped_labels(child, result)

func run() -> void:
	graphical = DisplayServer.get_name() != "headless"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_dir = arg.trim_prefix("--capture=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
	root.size = Vector2i(1280,800)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(5)
	game.progress.sound = false
	check(game.modal_name == "name_pet" and game.progress.pet_name == "Pip" and game.pip.appearance.species == "hamster", "Fresh story defaults to Pip the hamster")
	game.name_input.text = "Mochi"
	await press_named("ChoosePet")
	check(game.modal_name == "pet_creator" and game.creator.species_buttons.size() == 6, "First-play choice opens all six pets")
	for species in Looks.SPECIES:
		await press_named("Species_" + species)
		check(game.creator.actor.appearance.species == species, species + " has a live portrait")
		await snap("pet-" + species)
		for feature in Looks.FEATURES:
			var pick: OptionButton = game.creator.feature_controls[feature]
			var options: Array = Looks.CATALOG[species][feature]
			for index in range(options.size()):
				pick.select(index)
				pick.item_selected.emit(index)
				await frames()
				check(game.creator.actor.appearance[feature] == options[index], species + " preview changes " + feature + ": " + options[index])
		check(game.progress.pet_look.species == "hamster", "Preview does not apply " + species + " early")
	await press_named("Species_kitten")
	game.creator.color_controls.coat.color_changed.emit(Color("98c4b5"))
	check(game.creator.actor.appearance.coat == "98c4b5", "Color swatches update the live preview")
	await press_named("Species_bunny")
	await press_named("Species_kitten")
	check(game.creator.draft.coat == "98c4b5", "Switching species remembers the draft color")
	await press_named("CancelLook")
	check(game.modal_name == "name_pet" and game.name_input.text == "Mochi" and game.progress.pet_look.species == "hamster", "Cancel preserves the name draft and active hamster")
	await press_named("ChoosePet")
	await press_named("Species_bunny")
	game.creator.color_controls.coat.color_changed.emit(Color("e0b7d1"))
	await press_named("ApplyLook")
	check(game.modal_name == "name_pet" and game.pip.appearance.species == "bunny" and game.progress.pet_look.coat == "e0b7d1", "Applying a first-play pet updates the room and naming portrait")
	await press_named("UsePetName")
	check(game.progress.pet_name == "Mochi" and game.tutorial.active, "Chosen pet still leads into the guided tutorial")
	game.tutorial.finish()
	game.progress.coins = 500
	game.progress.owned = ["leaf_hat", "flower_clip", "vine_scarf", "hanging_plant", "sage_wallpaper", "leaf_rug"]
	game.progress.equipped = {"pet:head":"leaf_hat", "pet:face":"flower_clip", "pet:neck":"vine_scarf", "room:decor":"hanging_plant", "room:wall":"sage_wallpaper", "room:rug":"leaf_rug"}
	game._apply_cosmetics()
	await press_named("StylePet")
	await press_named("SavedLooksTab")
	await press_named("SaveLook0")
	check(game.creator.saved[0].outfit.size() == 3 and game.progress.saved_looks.all(func(entry): return entry.is_empty()), "Saved outfit remains a draft with all three PNG accessories")
	await press_named("ApplyLook")
	check(game.progress.saved_looks[0].appearance.species == "bunny" and game.progress.coins == 500, "Apply persists saved looks without charging coins")
	await press_named("StylePet")
	await press_named("Species_fox")
	await press_named("SavedLooksTab")
	await press_named("SaveLook0")
	check(game.creator.saved[0].appearance.species == "bunny", "Occupied preset needs a second Save click")
	await press_named("SaveLook0")
	check(game.creator.saved[0].appearance.species == "fox", "Confirmed preset replacement stays in the draft")
	await press_named("CancelLook")
	check(game.progress.saved_looks[0].appearance.species == "bunny", "Cancel also discards preset replacement")
	await press_named("StylePet")
	await press_named("Species_panda")
	await press_named("SavedLooksTab")
	await press_named("WearLook0")
	check(game.creator.draft.species == "bunny" and game.creator.outfit.size() == 3, "Wear restores a saved species and owned outfit")
	for dimensions in [Vector2i(1280,800), Vector2i(960,600)]:
		root.size = dimensions
		await frames(5)
		var clipped: Array = []
		clipped_labels(game.overlay, clipped)
		check(clipped.is_empty(), "Saved-look text fits " + str(dimensions) + ": " + str(clipped))
		await press_named("FaceTab")
		clipped.clear()
		clipped_labels(game.overlay, clipped)
		check(clipped.is_empty(), "Creator text fits " + str(dimensions) + ": " + str(clipped))
		await snap("creator-" + str(dimensions.x))
	root.size = Vector2i(1280,800)
	await press_named("ApplyLook")
	check(game.progress.equipped.get("room:decor") == "hanging_plant" and game.get_node("Room").decor_pieces.window.visible, "Wearing a look preserves the new furnished room set")
	game.open_shop()
	check(Shop.ITEMS.size() == 60 and Shop.THEMES.size() == 10, "Team's sixty Shop items and ten themes remain available")
	check(game.overlay.get_node("RoomCategory").text == "Room sets", "Team's room-set navigation is retained")
	await press_named("StylePetShop")
	await press_named("CancelLook")
	check(game.modal_name == "shop", "Creator returns to Shop without losing its category")
	game.open_settings()
	await press_named("StylePetSettings")
	await press_named("CancelLook")
	check(game.modal_name == "settings", "Creator returns to Settings")
	game.close_modal()
	game.session_stage = 0
	game._picnic_setup()
	await frames()
	check(game.picnic.actor.appearance == game.progress.pet_look, "Picnic Catch uses the customized pet")
	game.close_modal()
	game._lab_setup()
	await frames()
	check(game.lab_screen.actor.appearance == game.progress.pet_look, "Logic Lab uses the customized pet")
	game.close_modal()
	game.start_snack_jam()
	await frames()
	check(game.snack_jam.actor.appearance == game.progress.pet_look, "Snack Jam uses the customized pet")
	game.close_modal()
	game.set_process(false)
	game.progress.happiness = 50
	game.progress.coins = 500
	game.auto_speech.clear()
	game.speech_queue.clear()
	game.speech.hide()
	await press_named("BallPlay")
	check(game._ball_active() and game.ball_hint.visible, "Ball Play starts from the home button")
	game.ball_button.grab_focus()
	var key = InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	Input.parse_input_event(key)
	await frames()
	key = InputEventKey.new()
	key.keycode = KEY_SPACE
	Input.parse_input_event(key)
	check(game.ball_play.state == "flying", "Space throws while the Ball Play button has focus")
	check(not game.ball_play.throw_to(Vector2(900,550)), "An in-flight throw cannot be duplicated")
	game.ball_play._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var paused_position: Vector2 = game.pip.position
	await create_timer(0.15).timeout
	check(game.ball_play.paused and game.pip.position == paused_position, "Focus loss pauses the throw")
	game.ball_play.resume()
	var deadline = Time.get_ticks_msec() + 8000
	while game.progress.ball_returns == 0 and Time.get_ticks_msec() < deadline: await frames()
	check(game.progress.ball_returns == 1 and game.progress.happiness == 52 and game.progress.coins == 500, "One completed return grants exactly two happiness and no gold")
	await create_timer(1.1).timeout
	check(game.progress.ball_returns == 1, "A settled ball cannot repeat the return reward")
	await snap("ball-play")
	game._stop_ball()
	# The test disables normal processing to measure the exact happiness reward.
	# Advance the ordinary queued teaching path once after putting the toy away.
	game._process(0)
	check(game.progress.discovered.has("ball_play") and not str(game.progress.pip_quotes.get("ball_play", "")).is_empty(), "Putting the toy away records the complete lesson in Knowledge")
	for level in Lessons.LEVELS:
		game.progress.game_level = level
		var lesson: Dictionary = game._lesson("ball_play")
		check(not lesson.bubble.is_empty() and not lesson.question.is_empty(), "Ball lesson and quiz exist at " + level)
	game._toggle_ball()
	game.ball_play.throw_to(Vector2(900,550))
	game.open_settings()
	check(not game._ball_active() and game.progress.ball_returns == 1, "Opening a menu cancels an unfinished throw without reward")
	game.close_modal()
	var slots = Slots.new()
	slots.base_path = "user://pet_merge_slots.json"
	for i in range(3): slots.delete_slot(i)
	check(slots.save_slot(0, "My friend", game.progress) == OK and slots.read_slot(0).state == "ready", "Version-ten manual slot can be read after JSON round trip")
	var newer = SaveData.new()
	newer.apply_snapshot(slots.read_slot(0).progress)
	check(newer.pet_look == game.progress.pet_look and newer.saved_looks == game.progress.saved_looks and newer.ball_returns == 1, "Full-story slots retain custom design, presets, and play count")
	var legacy: Dictionary = game.progress.snapshot()
	legacy.version = 9
	for name in ["pet_look", "pet_designs", "saved_looks", "ball_returns"]: legacy.erase(name)
	legacy.owned = Shop.ITEMS.keys()
	SaveData.write_json(slots.slot_path(1), {"slot_version":1, "label":"Earlier story", "progress":legacy})
	check(slots.read_slot(1).state == "ready", "Version-nine slots from the uploaded branch remain loadable")
	var migrated = SaveData.new()
	migrated.apply_snapshot(slots.read_slot(1).progress)
	check(migrated.pet_look.species == "hamster" and migrated.owned.size() == 60 and migrated.coins == 500 and migrated.pet_name == "Mochi", "Old stories gain a hamster without losing any of the sixty purchases or progress")
	check(newer.clean_pet_outfit({"head":"santa_hat", "face":"leaf_hat", "neck":"vine_scarf"}) == {"neck":"vine_scarf"}, "Saved looks cannot equip unowned or wrong-slot items")
	var invalid = Looks.clean({"species":"unknown", "ears":"bad", "coat":"<bad>"})
	check(invalid == Looks.defaults(), "Invalid appearance values safely fall back to Pip")
	newer.happiness = 50
	check(newer.reward_petting(0) and not newer.reward_petting(1) and newer.happiness == 54 and newer.reward_petting(30000), "Team's four-point petting reward and thirty-second cooldown are preserved")
	game.progress.happiness = 50
	game.progress.fullness = 50
	game._drain_needs(60)
	check(game.progress.happiness == 45 and game.progress.fullness == 45, "Team's passive need balancing remains five points per minute")
	game._reset_progress()
	await frames()
	check(game.modal_name == "name_pet" and game.progress.pet_look.species == "hamster" and game.progress.saved_looks.is_empty() and game.progress.ball_returns == 0, "Reset clears the new pet data and offers first-play selection again")
	check(slots.read_slot(0).state == "ready", "Reset retains explicit story slots")
	for i in range(3): slots.delete_slot(i)
	print("PET MERGE CHECKS: %d; FAILURES: %d" % [checks,failures])
	quit(0 if failures == 0 else 1)
