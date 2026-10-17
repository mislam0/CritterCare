extends "res://tests/verify.gd"
const Slots = preload("res://scripts/save_slots.gd")
const UI = preload("res://scripts/ui.gd")

func ui_click(node_name: String) -> void:
	await frames(3)
	await click(game.overlay.get_node(node_name).get_global_rect().get_center() * (Vector2(root.size) / Vector2(1280,800)))

func check_labels(node: Node, clipped: Array) -> void:
	if node is UI.LearningText and node.is_visible_in_tree() and not node.fit_content and not node.content_fits(): clipped.append(node.words)
	for child in node.get_children(): check_labels(child,clipped)

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
	game._complete_pet_name("Mochi")
	game.tutorial.finish()
	game.progress.sound = false
	game.progress.save_path = "user://crittercare_slots_test.json"
	game.save_slots.base_path = game.progress.save_path
	for i in range(Slots.COUNT): game.save_slots.delete_slot(i)
	game.open_settings()
	await ui_click("SaveLoad")
	check(game.modal_name == "save_slots","Settings opens Save / Load through a real click")
	check(game.overlay.get_node("LoadSlot0").disabled and game.overlay.get_node("DeleteSlot0").disabled,"Empty slots disable Load and Delete")
	check(game.save_slots.slot_path(-1).is_empty() and game.save_slots.save_slot(3,"bad",game.progress) == ERR_INVALID_PARAMETER and game.save_slots.delete_slot(-1) == ERR_INVALID_PARAMETER,"Out-of-range slot IDs cannot access arbitrary files")
	game.progress.coins = 123
	game.progress.owned = ["leaf_hat"]
	game.progress.equipped = {"pet:head":"leaf_hat"}
	game.progress.game_level = "middle"
	game.progress.stage_badges = {"0":["Berry Detective","Loop Garden","Pop Quiz"]}
	game.progress.practice_stage = 1
	game.progress.discovered = ["events"]
	game.progress.pip_quotes = {"events":"IF Mochi is petted THEN happiness grows."}
	game.progress.scores = [{"mode":"Quiz","score":80}]
	# Use a known valid lab ID, independent of the display title.
	game.progress.lab_completed = [game.Lab.CHALLENGES[0].id]
	game.progress.jam_best = {"chill":{"accuracy":90,"combo":20}}
	game.progress.jam_rounds = 2
	game.progress.picnic_best = 8
	game.progress.picnic_rounds = 3
	game.progress.calm = true
	game.progress.jam_offset_ms = 40
	game.progress.inventory = {"berry":9,"seed":4,"carrot":1}
	await ui_click("SaveSlot0")
	check(game.modal_name == "save_slot" and game.slot_name_input.has_focus(),"Saving asks for a slot name with keyboard focus")
	game.slot_name_input.text = "Before the garden"
	await ui_click("ConfirmSlot")
	var saved: Dictionary = game.save_slots.read_slot(0)
	check(saved.state == "ready" and saved.label == "Before the garden" and saved.progress.pet_name == "Mochi" and not saved.saved_at.is_empty(),"A named slot persists the pet name and save time")
	check(saved.progress.coins == 123 and saved.progress.inventory.berry == 9 and saved.progress.equipped.get("pet:head") == "leaf_hat","A slot stores coins, treats, and PNG equipment")
	var first_bytes = FileAccess.get_file_as_string(game.save_slots.slot_path(0))
	game.progress.coins = 987
	game.progress.pet_name = "Pip Junior"
	game.progress.inventory.berry = 77
	game.progress.equipped = {}
	game.progress.stage_badges = {}
	game.progress.jam_best = {}
	game.progress.lab_completed = []
	game.progress.sound = true
	game.progress.calm = false
	game._save()
	check(FileAccess.get_file_as_string(game.save_slots.slot_path(0)) == first_bytes,"Autosaving later play never changes a manual slot")
	game.open_save_slots()
	await ui_click("SaveSlot1")
	game.slot_name_input.text = "Later story"
	await ui_click("ConfirmSlot")
	check(game.save_slots.read_slot(1).progress.coins == 987 and game.save_slots.read_slot(0).progress.coins == 123,"Slots hold independent points in progress")
	await ui_click("SaveSlot0")
	await ui_click("CancelSlot")
	check(FileAccess.get_file_as_string(game.save_slots.slot_path(0)) == first_bytes,"Cancelling an overwrite preserves the previous slot byte for byte")
	await ui_click("LoadSlot0")
	await ui_click("CancelSlot")
	check(game.progress.coins == 987 and game.progress.pet_name == "Pip Junior","Cancelling Load keeps the active game")
	await ui_click("LoadSlot0")
	await ui_click("ConfirmSlot")
	check(game.progress.coins == 123 and game.progress.pet_name == "Mochi" and UI.Names.current == "Mochi","Confirmed Load restores coins and the chosen display name")
	check(game.progress.inventory.berry == 9 and game.progress.cosmetics("pet").get("head") == "leaf_hat" and game.pip.cosmetic_items.get("head") == "leaf_hat","Loaded treats and equipped art appear in the active game")
	check(game.progress.practice_stage == 1 and game.progress.stage_badges.get("0",[]).size() == 3 and game.progress.game_level == "middle","Load restores learning level and stage badges")
	check(game.progress.pip_quotes.get("events") == saved.progress.pip_quotes.events and game.progress.scores[0].score == 80,"Exact teaching quotes and integer scores survive slot loading")
	check(game.progress.lab_completed.size() == 1 and game.progress.jam_best.chill.accuracy == 90 and game.progress.picnic_best == 8,"Lab, rhythm, and picnic records survive slot loading")
	check(game.progress.calm and not game.progress.sound and game.progress.jam_offset_ms == 40 and not game.tutorial.active,"Preferences and completed tutorial restore without starting a new tour")
	var reload = SaveData.new()
	reload.save_path = game.progress.save_path
	reload.load_progress()
	check(reload.pet_name == "Mochi" and reload.coins == 123 and reload.jam_rounds == 2,"The loaded slot becomes the autosave used on the next launch")
	check(game.save_slots.read_slot(1).progress.coins == 987,"Loading one slot leaves the other saved story intact")
	game.open_save_slots()
	await ui_click("DeleteSlot1")
	await snap("save-delete")
	await ui_click("CancelSlot")
	check(game.save_slots.read_slot(1).state == "ready","Cancelling Delete keeps the slot")
	await ui_click("DeleteSlot1")
	await ui_click("ConfirmSlot")
	check(game.save_slots.read_slot(1).state == "empty" and game.progress.coins == 123 and game.save_slots.read_slot(0).state == "ready","Deleting a slot leaves current progress and other slots untouched")
	await ui_click("SaveSlot1")
	game.slot_name_input.text = " "
	await ui_click("ConfirmSlot")
	check(game.save_slots.read_slot(1).label == "My story","A deleted slot can be reused and blank names get a readable default")
	await ui_click("SaveSlot1")
	game.progress.coins = 234
	game.slot_name_input.text = "Replaced story"
	await ui_click("ConfirmSlot")
	check(game.save_slots.read_slot(1).label == "Replaced story" and game.save_slots.read_slot(1).progress.coins == 234,"Confirmed overwrite updates only the selected slot")
	var damaged = FileAccess.open(game.save_slots.slot_path(2),FileAccess.WRITE)
	damaged.store_string("{broken json")
	damaged.close()
	game.open_save_slots()
	check(game.save_slots.read_slot(2).state == "damaged" and game.overlay.get_node("LoadSlot2").disabled and not game.overlay.get_node("DeleteSlot2").disabled,"An unreadable save is visible and deletable but cannot load")
	await ui_click("SaveSlot2")
	game.slot_name_input.text = "WWWWWWWWWWWWWWWWWWWWWWWW"
	await ui_click("ConfirmSlot")
	check(game.save_slots.read_slot(2).state == "ready","Replacing an unreadable slot repairs it without changing other slots")
	for dimensions in [Vector2i(1280,800),Vector2i(960,600)]:
		root.size = dimensions
		game.open_save_slots()
		await frames(4)
		var clipped = []
		check_labels(game.overlay,clipped)
		check(clipped.is_empty(),"All slot summaries fit at %s: %s" % [dimensions,clipped])
		await snap("save-slots-small" if dimensions.x == 960 else "save-slots")
		await ui_click("SaveSlot2")
		await frames(3)
		check(game.modal_name == "save_slot","Save controls respond to pointer input at %s" % dimensions)
		clipped.clear()
		check_labels(game.overlay,clipped)
		check(clipped.is_empty(),"Save confirmation fits at %s: %s" % [dimensions,clipped])
		await ui_click("CancelSlot")
	root.size = Vector2i(1280,800)
	# A failed write must not replace the active in-memory game.
	var working_path = game.progress.save_path
	game.progress.save_path = "user://missing_slot_test_directory/progress.json"
	game._confirm_slot_action(0,"load")
	await ui_click("ConfirmSlot")
	check(game.progress.coins == 234 and game.modal_name == "save_slots" and game.overlay.get_node("SaveNotice").words.contains("Couldn't load"),"Unavailable storage leaves active progress intact and reports the failed load")
	game.progress.save_path = working_path
	var invalid_slots = Slots.new()
	invalid_slots.base_path = "user://missing_slot_test_directory/progress.json"
	check(invalid_slots.save_slot(0,"failed",game.progress) != OK and FileAccess.get_file_as_string(game.save_slots.slot_path(0)) == first_bytes,"A failed save write does not damage existing slots")
	game._reset_progress()
	check(game.modal_name == "name_pet" and game.save_slots.read_slot(0).progress.coins == 123,"Reset clears the current game and retains explicit manual save slots")
	game._complete_pet_name("Pip")
	game.tutorial.finish()
	game._confirm_slot_action(0,"load")
	await ui_click("ConfirmSlot")
	check(game.progress.pet_name == "Mochi" and game.progress.coins == 123,"A retained manual save can restore a story after Reset")
	var reopened = Slots.new()
	reopened.base_path = working_path
	check(reopened.read_slot(0).label == "Before the garden" and reopened.read_slot(1).label == "Replaced story","Slot metadata is read from disk after creating a fresh manager")
	check(Slots.clean_label("[b]\n\t").find("[") == -1 and Slots.clean_label("WWWWWWWWWWWWWWWWWWWWWWWWextra").length() == 24,"Slot titles strip control/markup delimiters and respect their length limit")
	for i in range(Slots.COUNT): reopened.delete_slot(i)
	game.queue_free()
	await frames(3)
	print("SAVE SLOTS RESULT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
