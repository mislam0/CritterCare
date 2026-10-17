extends "res://tests/verify.gd"
const UI = preload("res://scripts/ui.gd")
const Names = preload("res://scripts/pet_name.gd")

func labels(node: Node) -> Array:
	var result = []
	if node is UI.LearningText and node.is_visible_in_tree(): result.append(node)
	for child in node.get_children(): result.append_array(labels(child))
	return result

func press_key(code: int) -> void:
	var event = InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event.pressed = false
	Input.parse_input_event(event)
	await frames(2)

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
	check(game.modal_name == "name_pet" and not game.tutorial.active and not game.progress.name_chosen,"The first launch asks for a name before the tutorial")
	check(game.name_input.text == "Pip" and game.name_input.has_focus(),"Pip is prefilled and the name field receives keyboard focus")
	var needs = Vector2(game.progress.fullness,game.progress.happiness)
	game._process(5)
	check(needs == Vector2(game.progress.fullness,game.progress.happiness) and game.pip.blocked,"Care and teaching wait while the name is being chosen")
	await snap("name-first-play")
	game.name_input.text = "Mochi"
	game.name_input.text_changed.emit("Mochi")
	await click(game.overlay.get_node("UsePetName").get_global_rect().get_center())
	check(game.progress.pet_name == "Mochi" and game.progress.name_chosen and game.tutorial.active,"An actual Use this name click saves the choice and begins the tour")
	check(game.tutorial.words.words.contains("Mochi") and not game.tutorial.words.words.contains("{pet_name}"),"The tutorial introduces the chosen name")
	await snap("name-tutorial")
	game.tutorial.finish()
	game._show_lesson("timer")
	check(game.speech_full_text == "".join(game.speech_pages) and game._lesson("timer").question.contains("Mochi"),"New lessons and quiz wording use the chosen name without losing speech text")
	game._discover_in_game("events","IF Mochi is petted THEN happiness grows.")
	var quote = game.progress.pip_quotes.events
	game.open_settings()
	await frames(3)
	await click(game.overlay.get_node("RenamePet").get_global_rect().get_center())
	check(game.modal_name == "name_pet" and game.name_input.text == "Mochi","Settings offers a rename without resetting progress")
	game.name_input.text = "Pip Junior"
	await press_key(KEY_ENTER)
	check(game.progress.pet_name == "Pip Junior" and game.modal_name == "settings","Enter confirms a new name and returns to Settings")
	game.open_games()
	await frames(4)
	check(game.game_menu_button("PlaySnackJam").get_meta("game_card").find_child("GameTitle",true,false).words == "Pip Junior's Snack Jam","Names containing Pip are expanded only once")
	game.open_knowledge("events")
	check(game.overlay.get_node("JournalBody/Content/PipQuote").words == quote and game.progress.pip_quotes.events == quote,"Renaming preserves the exact earlier recorded quote")
	game._save()
	var loaded = SaveData.new()
	loaded.save_path = game.progress.save_path
	loaded.load_progress()
	check(loaded.pet_name == "Pip Junior" and loaded.name_chosen and loaded.tutorial_completed,"Name and first-play completion survive save/reload")
	game.queue_free()
	await frames(3)
	game = load("res://scenes/main.tscn").instantiate()
	game.progress = loaded
	root.add_child(game)
	current_scene = game
	await frames(5)
	check(game.modal_name != "name_pet" and not game.tutorial.active and game.status_label.words.contains("Pip Junior"),"A returning saved player is not asked to name the pet again")
	check(Names.clean("   ") == "Pip" and Names.clean(" Étoile ") == "Étoile" and Names.clean("WWWWWWWWWWWWextra").length() == 12,"Blank input falls back to Pip; Unicode names and the length limit are supported")
	check(not Names.clean("[b]\nMochi\t{PET_NAME}").contains("[") and not Names.clean("\n\t").contains("\n"),"Control characters and markup delimiters cannot become name formatting")
	# A deliberately wide valid name must not crop headings or block navigation.
	game.open_name_prompt(false)
	game._complete_pet_name("WWWWWWWWWWWW")
	for window in [Vector2i(1280,800),Vector2i(960,600)]:
		root.size = window
		var clipped = []
		for screen in [game.open_settings,game.open_feed,game.open_games,game.open_shop,game.start_quiz,game.start_snack_jam]:
			screen.call()
			await frames(4)
			for label in labels(game.ui):
				if not label.fit_content and not label.content_fits(): clipped.append(label.words)
		game.start_tutorial()
		for step in range(game.tutorial.STEPS.size()):
			game.tutorial.step = step
			game.tutorial._enter_step()
			await frames(3)
			if not game.tutorial.heading.content_fits(): clipped.append(game.tutorial.heading.words)
		game.tutorial.finish()
		check(clipped.is_empty(),"Long names fit menus and tutorial at %s: %s" % [window,clipped])
		game.open_name_prompt(false)
		await snap("name-small" if window.x == 960 else "name-wide")
		game.close_modal()
	root.size = Vector2i(1280,800)
	# Normal interface prose never opts into teaching highlights.
	var highlighted = []
	for screen in [game.open_games,game.open_settings,game.open_shop,game.open_feed,game.start_quiz,game.start_sort,game.start_loop,game.start_snack_jam]:
		screen.call()
		await frames(3)
		for label in labels(game.overlay):
			if label.teaching or label.text.contains("[bgcolor="): highlighted.append(label.words)
	check(highlighted.is_empty(),"Menus, quiz questions/answers, game rules, controls, and scores stay unhighlighted: %s" % [highlighted])
	game.close_modal()
	game._say("Hi!","IF you like hats, THEN visit the Shop.")
	check(not game.speech_text.teaching and not game.speech_text.text.contains("[bgcolor="),"An ordinary greeting stays plain even when it contains coding words")
	game._show_lesson("boolean")
	check(game.speech_text.teaching and game.speech_text.text.contains("[bgcolor="),"An actual Pip lesson opts into term highlighting")
	game.open_knowledge("boolean")
	check(game.overlay.get_node("JournalBody/Content/PipQuote").teaching and game.overlay.get_node("JournalBody/Content/Code").teaching,"Knowledge retains highlighting inside saved teaching and examples")
	game.progress.game_level = "college"
	game._reset_progress()
	check(game.modal_name == "name_pet" and game.progress.pet_name == "Pip" and not game.progress.name_chosen and not game.tutorial.active,"Reset restarts naming with Pip as the default")
	await frames(3)
	await click(game.overlay.get_node("KeepPip").get_global_rect().get_center())
	check(game.progress.pet_name == "Pip" and game.tutorial.active and game.progress.game_level == "college","Keep Pip starts the new tutorial while retaining Game level")
	game.tutorial.finish()
	var old_file = FileAccess.open("user://name_legacy.json",FileAccess.WRITE)
	old_file.store_string(JSON.stringify({"version":8,"coins":321,"owned":["leaf_hat"],"equipped":{"pet:head":"leaf_hat"},"tutorial_completed":true}))
	old_file.close()
	var old = SaveData.new()
	old.save_path = "user://name_legacy.json"
	old.load_progress()
	check(not old.name_chosen and old.pet_name == "Pip" and old.coins == 321 and old.owned == ["leaf_hat"] and old.equipped == {"pet:head":"leaf_hat"},"Existing saves receive a one-time name choice without losing coins or PNG cosmetics")
	game.queue_free()
	await frames()
	print("IDENTITY RESULT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
