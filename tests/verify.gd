extends SceneTree
## Integration checks. Run from the project directory:
## godot --headless --path . --script res://tests/verify.gd -- --test-mode
## Add --capture=/absolute/folder under a graphical display for screenshots.

const SaveData = preload("res://scripts/save_data.gd")
const Curriculum = preload("res://data/curriculum.gd")
const Shop = preload("res://data/shop.gd")
const Lessons = preload("res://data/lessons.gd")
var game
var failures: int = 0
var checks: int = 0
var capture_dir: String = ""
var graphical: bool = false

func _initialize() -> void:
	if not "--test-mode" in OS.get_cmdline_user_args():
		push_error("Pass --test-mode to use isolated test saves.")
		quit(2)
		return
	call_deferred("run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("FAIL: " + message)
	else:
		print("PASS: " + message)

func frames(count: int = 2) -> void:
	for i in range(count):
		await process_frame

func snap(name: String) -> void:
	if capture_dir.is_empty() or not graphical:
		return
	await frames(3)
	await RenderingServer.frame_post_draw
	var path = capture_dir.path_join(name + ".png")
	root.get_texture().get_image().save_png(path)
	print("SCREENSHOT: " + name)

func mouse_move(point: Vector2) -> void:
	if graphical:
		Input.warp_mouse(point)
	var event = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	Input.parse_input_event(event)
	await frames(2)

func mouse_button(point: Vector2, pressed: bool) -> void:
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = point
	event.global_position = point
	Input.parse_input_event(event)
	await frames(2)

func click(point: Vector2) -> void:
	await mouse_move(point)
	await mouse_button(point, true)
	await mouse_button(point, false)

func run() -> void:
	graphical = DisplayServer.get_name() != "headless"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_dir = arg.trim_prefix("--capture=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
	root.size = Vector2i(1280, 800)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(5)
	game.progress.sound = false
	check(game.progress.inventory.berry == 6, "Fresh start has starter treats")
	check(game.progress.discovered.is_empty(), "Unseen lessons are locked")
	check(not game.pip.is_held, "Pip starts at rest")
	check(game.pip.hit_test(Vector2(-77, -110)), "Ear tips can be grabbed")
	check(game.pip.hit_test(Vector2(88, 49)), "Tail can be grabbed")
	check(game.tutorial.active and not game.progress.tutorial_completed, "A first launch automatically starts the guided tutorial")
	await snap("tutorial-first-launch")
	game.tutorial.skip_button.pressed.emit()
	await snap("01-home")
	game.open_knowledge()
	await snap("02-empty-knowledge")
	check(game.pip.blocked, "Menu pauses hamster interaction")
	game.close_modal()
	await frames()
	# Pointer-level test runs on a real display; state tests also run headless.
	if graphical:
		await click(Vector2(640, 461))
		check(game.progress.pet_count == 1, "A short head click pets Pip")
		await click(Vector2(640, 559))
		check(game.progress.pet_count == 1, "A short body click does not pet the head")
		await mouse_move(Vector2(655, 528))
		await mouse_button(Vector2(655, 528), true)
		await create_timer(0.3).timeout
		check(game.pip.is_held, "Holding a body click picks Pip up")
		await mouse_move(Vector2(850, 315))
		await create_timer(0.35).timeout
		check(game.pip.position.y < 450, "Mouse spring moves Pip upward")
		check(game.pip.moved_since_pickup, "Directional movement emits the position lesson")
		await snap("03-picked-up")
		await mouse_button(Vector2(850, 315), false)
		check(not game.pip.is_held and game.pip.is_falling, "Release starts a fall")
		await create_timer(1.6).timeout
		check(not game.pip.is_falling and absf(game.pip.position.y-516) < 1, "Fall bounces and settles safely on the floor")
	else:
		game.pip.pet()
	game.pip.pet()
	check(game.progress.pet_count >= 2, "Petting increments care count")
	check(game.progress.happiness > 72, "Petting raises happiness")
	game.pip.position = Vector2(640, 516)
	game.pip.velocity = Vector2.ZERO
	game.pip.angle = 0
	game.open_feed()
	await snap("04-treat-pouch")
	var berries_before: int = game.progress.inventory.berry
	game._feed("berry")
	check(game.progress.inventory.berry == berries_before-1, "Feeding consumes exactly one treat")
	check(game.pip.eating_time > 0, "Feeding starts the eating animation")
	game._feed("berry")
	check(game.progress.inventory.berry == berries_before-1, "Eating cannot double-spend a treat")
	game.pip._physics_process(1.8)
	check(game.speech_queue.has("loops"), "Completing a snack queues the chew loop lesson")
	game.progress.fullness = 100
	check(not game.progress.feed("berry"), "Full pet refuses a snack without spending it")
	game.progress.fullness = 40
	game.progress.inventory.carrot = 0
	check(not game.progress.feed("carrot"), "Empty inventory cannot become negative")
	game.progress.inventory.carrot = 2
	game._feed("seed")
	game.pip._physics_process(1.8)
	check(game.speech_queue.has("functions"), "Second feeding introduces functions")
	game.pip.idle_time = 12
	game.pip.happy_time = 0
	game.pip._physics_process(0.016)
	check(game.speech_queue.has("timer"), "Idle grooming introduces timers")
	# Only displayed learning bubbles unlock journal entries.
	game.speech_queue.clear()
	game.learn("boolean")
	check(not game.progress.discovered.has("boolean"), "Queued but unseen lesson remains locked")
	game._show_lesson("boolean")
	check(game.progress.discovered.has("boolean"), "Displayed lesson unlocks Knowledge")
	game._show_lesson("boolean")
	check(game.progress.discovered.count("boolean") == 1, "Lessons cannot be duplicated")
	game._show_lesson("condition")
	game._show_lesson("events")
	game.open_knowledge("condition")
	await snap("05-knowledge")
	game.open_games()
	await snap("06-games")
	var appetite_before: float = game.progress.fullness
	game.start_quiz()
	check(game.quiz_keys.size() == 3, "Quiz uses the number of discovered lessons up to five")
	for key in game.quiz_keys:
		check(game.progress.discovered.has(key), "Quiz never includes undiscovered concept " + key)
	await snap("07-quiz")
	berries_before = game.progress.inventory.berry
	var question_total: int = game.quiz_keys.size()
	for i in range(question_total):
		game._answer_quiz(true, "Correct explanation.")
		var score: int = game.quiz_score
		game._answer_quiz(true, "Double click")
		check(game.quiz_score == score, "Quiz locks each answer after the first choice")
		game._next_quiz()
	check(game.modal_name == "result", "Quiz reaches a result screen")
	check(game.progress.inventory.berry == berries_before + question_total*2, "Quiz win pays earned berries exactly once")
	check(game.progress.fullness < appetite_before, "A mini-game win builds appetite for new treats")
	game._result("Pop Quiz", 100, true, 99, 99, 99, "Duplicate reward")
	check(game.progress.inventory.berry == berries_before + question_total*2, "Result reward cannot be claimed twice")
	await snap("08-reward")
	game.start_quiz()
	berries_before = game.progress.inventory.berry
	for i in range(game.quiz_keys.size()):
		game._answer_quiz(false, "Try again.")
		game._next_quiz()
	check(game.progress.inventory.berry == berries_before, "Losing a quiz does not grant win rewards")
	game.start_sort()
	await snap("09-berry-detective")
	berries_before = game.progress.inventory.berry
	for i in range(10):
		var kind: String = game.sort_items[game.sort_index]
		var passes = kind == "berry" if game.sort_rule_and else kind in ["berry", "blueberry"]
		game._answer_sort(passes)
		game._next_sort()
	check(game.sort_score == 10, "All ten berry sorting rules evaluate correctly")
	check(game.progress.discovered.has("and"), "AND feedback unlocks its lesson")
	check(game.progress.inventory.berry == berries_before+5, "Berry Detective rewards a successful basket")
	game.start_loop()
	await snap("10-loop-garden")
	game.loop_count = 1
	game._run_loop()
	game._process(0.5)
	check(not game.loop_running and not game.next_button.visible, "Wrong loop count lets player debug and retry")
	check(game.progress.discovered.has("repeat"), "Running a loop unlocks the repeat-count lesson")
	berries_before = game.progress.inventory.berry
	for garden in range(3):
		game.loop_count = game.loop_targets[game.loop_round]
		game._run_loop()
		for step in range(game.loop_count):
			game._process(0.5)
		check(game.next_button.visible, "Correct loop reaches the target in garden " + str(garden+1))
		game._next_loop()
	check(game.modal_name == "result", "Loop Garden completes all three rounds")
	check(game.progress.inventory.berry == berries_before+4, "Loop Garden grants one completion reward")
	game.start_loop()
	game._run_loop()
	game.close_modal()
	check(not game.loop_running, "Closing a mini game cancels its active animation")
	check(Lessons.entry("timer", "kindergarten").bubble.begins_with("IF my quiet timer reaches its target THEN"), "Starter level uses IF THEN teaching language")
	check(Lessons.entry("timer", "college").body.contains("College note:"), "College level adds advanced lesson notes")
	game.open_settings()
	await snap("11-settings")
	game.progress.game_level = "middle"
	game.progress.discovered = ["idle", "boolean"]
	game.progress.inventory.berry = 42
	game.progress.games_won = 5
	game.progress.scores = [{"mode":"Test", "score":100}]
	reset_for_checks()
	check(game.progress.discovered.is_empty(), "Reset progress clears discovered lessons")
	check(game.progress.inventory.berry == 6 and game.progress.games_won == 0, "Reset progress restores starter inventory and counters")
	check(game.progress.game_level == "middle", "Reset progress keeps selected game level")
	# Persistence round trip, limits, and corrupt-file fallback.
	var record = SaveData.new()
	record.save_path = "user://crittercare_verify_data.json"
	record.discovered = ["idle", "boolean"]
	record.game_level = "college"
	record.inventory.berry = 17
	record.reward("Test", 90, 1, 2)
	record.reward("Test2", 100, 1, 2)
	record.reward("Test3", 80, 1, 2)
	record.reward("Test4", 85, 1, 2)
	check(record.write() == OK, "Save writes successfully")
	var loaded = SaveData.new()
	loaded.save_path = record.save_path
	loaded.load_progress()
	check(loaded.inventory.berry == 21 and loaded.discovered == record.discovered, "Treats and Knowledge survive a save/reload")
	check(loaded.game_level == "college", "Game level survives a save/reload")
	check(loaded.scores.size() == 3 and loaded.scores[0].score == 100, "Local top three scores persist in ranked order")
	var bad = FileAccess.open(record.save_path, FileAccess.WRITE)
	bad.store_string("{broken save")
	bad.close()
	var recovered = SaveData.new()
	recovered.save_path = record.save_path
	recovered.load_progress()
	check(recovered.inventory.berry == 6, "Corrupt save safely falls back to defaults")
	DirAccess.remove_absolute(record.save_path)
	await verify_additions()
	await verify_readability()
	await verify_picnic()
	await verify_tutorial()
	# Inspect all journal layouts with all real content, after gameplay checks.
	for key in Lessons.ORDER:
		game.progress.unlock(key)
		game.open_knowledge(key)
		await frames(2)
		var body = game.overlay.get_node("JournalBody")
		check(body.get_node("Content/PipQuote").text == str(game.progress.pip_quotes.get(key, game._lesson(key).bubble)) and not body.get_node("Content/PipQuote").clip_text, "Knowledge includes Pip’s complete words: " + key)
		if key in ["functions", "loops", "repeat"]:
			await snap("journal-" + key)
	game.close_modal()
	for key in Lessons.ORDER:
		game._show_lesson(key, false)
		await frames(2)
		check(game.speech_text.get_line_count() <= game.speech_text.get_visible_line_count(), "Every learning-bubble line is visible: " + key)
		check(game.speech_title.size.y < 33, "Learning bubble heading fits: " + key)
	game.speech_queue.clear()
	game._show_lesson("idle", false)
	game.pip.position = Vector2(640, 516)
	game.pip.angle = 0
	game.pip.angular_velocity = 0
	game.pip.paw_angle = 0
	game.pip.paw_velocity = 0
	game.pip.happy_time = 0
	game.pip.groom_time = 0
	await snap("12-home-discovery")
	if graphical:
		root.size = Vector2i(960, 600)
		await frames(4)
		await snap("13-small-window")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	game.queue_free()
	await frames(3)
	DirAccess.remove_absolute("user://crittercare_test_ui.json")
	quit(1 if failures else 0)

func finish_intro() -> void:
	var pages = 0
	while game.modal_name == "intro" and pages < 8:
		for node in game.overlay.get_children():
			if node is Button and (node.text.begins_with("Next little") or node.text.begins_with("Try it")):
				node.pressed.emit()
				break
		pages += 1
		await frames()

func verify_additions() -> void:
	game.close_modal()
	reset_for_checks()
	game.progress.sound = false
	check(game.progress.coins == 0 and game.progress.owned.is_empty(), "New game has no coins or purchases")
	for level in ["kindergarten", "middle", "college"]:
		game.progress.game_level = level
		check(game.progress.unlocked_stage() == 0, "Fresh " + level + " starts with the same easy stage")
	check(not game.progress.buy("leaf_hat") and game.progress.coins == 0, "Insufficient coins cannot buy an item or create debt")
	check(not game.progress.toggle_equip("crown"), "Unowned items cannot be equipped")
	# The OR, NOT, ELIF, freshness, and boundary cases have independently specified outcomes.
	check(Curriculum.sort_answer(1, 0, "button") == 0, "OR accepts a red non-berry")
	check(Curriculum.sort_answer(1, 0, "blueberry") == 0, "OR accepts a non-red berry")
	check(Curriculum.sort_answer(1, 0, "stone") == 1, "OR rejects an item failing both checks")
	check(Curriculum.sort_answer(1, 5, "berry") == 1 and Curriculum.sort_answer(1, 5, "blueberry") == 0, "NOT reverses the color check")
	check(Curriculum.sort_answer(2, 0, "berry") == 0 and Curriculum.sort_answer(2, 0, "blueberry") == 1 and Curriculum.sort_answer(2, 0, "button") == 2, "ELIF gives three exclusive outcomes")
	check(Curriculum.sort_answer(3, 0, "seed") == 0 and Curriculum.sort_answer(3, 0, "spoiled_berry") == 1, "Grouped food rule rejects spoilage")
	check(Curriculum.sort_answer(3, 6, "berry") == 0 and Curriculum.sort_answer(3, 5, "berry") == 1, "Boundary rule blocks food at exactly 95 fullness")
	# A short quiz pays rewards but cannot count as a full curriculum badge.
	game.progress.discovered = ["idle"]
	game.start_quiz()
	game._answer_quiz(true, "An IF chooses an action.")
	game._next_quiz()
	check(game.progress.coins > 0, "Finishing a quiz awards coins")
	check(not game.progress.stage_badges.get("0", []).has("Pop Quiz"), "One-question quiz does not bypass the three-question badge requirement")
	var paid: int = game.progress.coins
	game._result("Pop Quiz", 100, true, 0, 0, 0, "Repeat event")
	check(game.progress.coins == paid, "Result events cannot duplicate coin rewards")
	game.start_sort()
	game.close_modal()
	check(game.progress.coins == paid, "Abandoning an activity awards no coins")
	game.start_quiz()
	game._answer_quiz(false, "Read the hint and try again.")
	game._next_quiz()
	check(game.progress.coins > paid, "Completed attempts earn practice coins even below the win threshold")
	# Check the real shop actions, permanent ownership, and mutually exclusive slots.
	game.progress.coins = 400
	game.open_shop()
	await snap("20-shop-new")
	game._shop_action("leaf_hat")
	check(game.progress.coins == 380 and game.progress.owned.has("leaf_hat"), "Shop purchase charges its catalog price once")
	check(not game.progress.equipped.has("pet:head"), "Buying unlocks an item before equipping")
	check(not game.progress.buy("leaf_hat") and game.progress.coins == 380, "Owned items cannot be purchased twice")
	game._shop_action("leaf_hat")
	check(game.pip.cosmetic_items.get("head") == "leaf_hat", "Equip updates Pip's actual accessory art")
	game._shop_action("leaf_hat")
	check(game.progress.owned.has("leaf_hat") and not game.pip.cosmetic_items.has("head"), "Unequip removes art and preserves ownership")
	game._shop_action("leaf_hat")
	game._shop_action("crown")
	game._shop_action("crown")
	check(game.progress.equipped.get("pet:head") == "crown" and game.progress.owned.has("leaf_hat"), "Another hat replaces only the equipped hat")
	game._shop_action("bow")
	game._shop_action("bow")
	check(game.pip.cosmetic_items.size() == 2, "Different accessory slots can be equipped together")
	game.shop_category = "room"
	game._shop_action("rose_mat")
	game._shop_action("rose_mat")
	game._shop_action("peach_wall")
	game._shop_action("peach_wall")
	check(game.get_node("Room").cosmetic_items.get("rug") == "rose_mat" and game.get_node("Room").cosmetic_items.get("wall") == "peach_wall", "Room purchases change the real rug and walls together")
	await snap("21-shop-room")
	game.close_modal()
	game.pip.position = Vector2(640,516)
	game.pip.angle = 0
	game.pip.angular_velocity = 0
	game.pip.velocity = Vector2.ZERO
	game.pip.is_falling = false
	game.pip.groom_time = 0
	game.pip.happy_time = 0
	game.pip._update_costume_pose()
	check(game.pip.hit_test(Vector2(0,-150)), "Pip can be picked up by an equipped hat")
	game._say("A place of our own", "IF you equip an owned item THEN I wear it. Unequipping keeps it in your collection!")
	await snap("22-customized-home")
	# Save/reload restores the wallet and both equipped categories.
	game.progress.write()
	var restored = SaveData.new()
	restored.save_path = game.progress.save_path
	restored.load_progress()
	check(restored.coins == game.progress.coins and restored.owned == game.progress.owned, "Coins and permanent purchases survive save/reload")
	check(restored.equipped == game.progress.equipped, "Equipped pet and room items survive save/reload")
	# All three badges required; replaying one activity cannot skip a stage.
	game.progress.stage_badges = {}
	game.progress.mark_stage_win(0,"Berry Detective")
	game.progress.mark_stage_win(0,"Berry Detective")
	game.progress.mark_stage_win(0,"Loop Garden")
	check(game.progress.unlocked_stage() == 0, "Repeating one game cannot replace the missing quiz badge")
	game.progress.mark_stage_win(0,"Pop Quiz")
	check(game.progress.unlocked_stage() == 1 and game.progress.active_stage() == 1, "Three different badges unlock and select the next stage")
	game.open_games()
	await snap("23-learning-path")
	# Play every added stage using its tutorial, challenge controls, and result flow.
	for stage in range(1, 4):
		check(game.progress.active_stage() == stage, "Progression reaches stage " + str(stage+1))
		game.start_sort()
		check(game.modal_name == "intro", "New stage first explains its sorting concepts")
		await snap("stage-%d-intro" % stage)
		await finish_intro()
		check(game.modal_name == "sort", "Guided lessons continue into the challenge")
		game.sort_items = ["berry", "stone", "blueberry", "button", "berry", "blueberry", "berry", "button", "stone", "berry"] if stage < 3 else ["berry", "seed", "spoiled_berry", "button", "stone", "blueberry", "spoiled_berry", "berry", "stone", "berry"]
		var expected = {1:[0,1,0,0,0,0,1,1,1,1], 2:[0,2,1,2,0,1,0,2,2,0], 3:[0,0,1,1,1,1,1,1,1,1]}[stage]
		for i in range(10):
			game._sort_question()
			if i == 5:
				await snap("stage-%d-sort" % stage)
			game._answer_sort_choice(expected[i])
			game._next_sort()
		check(game.sort_score == 10 and game.modal_name == "result", "New sorting stage finishes and rewards all correct choices: " + str(stage))
		game.start_loop()
		await finish_intro()
		game.loop_targets = [3,4,5]
		game._loop_garden()
		await snap("stage-%d-loop" % stage)
		# Incorrect value remains retryable and reveals the computed total.
		game.loop_count = 1
		game._run_loop()
		for tick in range(3 if stage == 3 else 1):
			game._process(0.5)
		check(not game.next_button.visible, "Extended loop exposes a mistake without advancing")
		for garden in range(3):
			game.loop_count = [3,4,5][garden]
			game._run_loop()
			var ticks: int = game.loop_count * (game.loop_stride if stage == 3 else 1)
			for tick in range(ticks):
				game._process(0.5)
			check(game.next_button.visible and game.loop_value == ([7,14,10][garden] if stage == 1 else [6,12,10][garden]), "Extended loop computes the expected value: stage %d garden %d" % [stage, garden])
			game._next_loop()
		check(game.modal_name == "result", "Extended loops finish all three gardens")
		game.start_quiz()
		check(game.quiz_keys.size() >= 3, "Both guided games teach enough concepts for this stage's quiz")
		check(game.quiz_keys.all(func(key): return key in Curriculum.STAGES[stage].keys and game.progress.discovered.has(key)), "Stage quiz only uses its taught concepts")
		for i in range(game.quiz_keys.size()):
			for b in game.quiz_answer_buttons:
				if b.get_meta("correct"):
					b.pressed.emit()
					break
			game._next_quiz()
		check(Curriculum.completed(game.progress.stage_badges, stage), "Finishing the quiz completes the stage badges")
	# Level changes cap available complexity without deleting achievements or items.
	game.progress.game_level = "middle"
	check(game.progress.unlocked_stage() == 2 and game.progress.active_stage() == 2, "Middle level stops at Little recipes")
	game.progress.game_level = "kindergarten"
	check(game.progress.active_stage() == 0, "Lowest level stays at original difficulty despite advanced progress")
	game.progress.game_level = "college"
	game.progress.practice_stage = 0
	game.start_loop()
	check(game.session_stage == 0 and game.loop_stride == 1, "Earlier unlocked stages remain playable at their original difficulty")
	game.close_modal()
	game.progress.write()
	restored.load_progress()
	check(restored.stage_badges == game.progress.stage_badges and restored.practice_stage == 0, "Stage badges and selected practice stage persist")
	reset_for_checks()
	check(game.progress.coins == 0 and game.progress.owned.is_empty() and game.progress.equipped.is_empty(), "Reset clears wallet and permanent customization unlocks")
	check(game.progress.stage_badges.is_empty() and game.progress.unlocked_stage() == 0, "Reset returns the curriculum to First steps")
	check(game.pip.cosmetic_items.is_empty() and game.get_node("Room").cosmetic_items.is_empty(), "Reset removes equipped art immediately")
	restored.load_progress()
	check(restored.owned.is_empty() and restored.coins == 0, "Reset is persisted and purchases do not return on reload")
	# Previous-version saves migrate without losing inventory or inventing progression.
	var old_path = "user://crittercare_legacy_test.json"
	var file = FileAccess.open(old_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version":2,"inventory":{"berry":17},"discovered":["idle"],"game_level":"college","games_won":50}))
	file.close()
	var legacy = SaveData.new()
	legacy.save_path = old_path
	legacy.load_progress()
	check(legacy.inventory.berry == 17 and legacy.discovered == ["idle"], "Version 2 saves keep care progress during migration")
	check(legacy.coins == 0 and legacy.owned.is_empty() and legacy.unlocked_stage() == 0, "Older win totals do not bypass the new beginner stages")
	file = FileAccess.open(old_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"coins":-50,"owned":["bow","bow","unknown"],"equipped":{"pet:head":"bow","pet:neck":"crown","room:wall":"peach_wall"},"practice_stage":99}))
	file.close()
	legacy = SaveData.new()
	legacy.save_path = old_path
	legacy.load_progress()
	check(legacy.coins == 0 and legacy.owned == ["bow"] and legacy.equipped.is_empty(), "Invalid wallet, duplicate ownership, wrong slots, and unowned gear are sanitized")
	check(legacy.active_stage() == 0, "Edited practice index cannot unlock advanced stages")
	DirAccess.remove_absolute(old_path)

func verify_readability() -> void:
	game.close_modal()
	game.speech_queue.clear()
	game.progress.sound = false
	# The header is a balance, and the bottom Shop works at both window sizes.
	for window in [Vector2i(1280,800), Vector2i(960,600)]:
		root.size = window
		await frames(3)
		var wallet = game.ui.get_node("GoldBalance")
		check(wallet is Panel and not game.ui.has_node("ShopTop") and game.coin_label.text == str(game.progress.coins), "Header shows the current gold balance without another Shop button")
		if graphical:
			await click(wallet.get_global_rect().get_center() * (Vector2(window)/Vector2(1280,800)))
			check(game.modal_name.is_empty(), "Clicking the gold balance does not open Shop")
		for name in ["ShopNav"]:
			var button: Button = game.ui.get_node(name)
			check(button.visible and not button.disabled and Rect2(0,0,1280,800).encloses(button.get_global_rect()), "Visible Shop entrance: %s at %s" % [name, window])
			if graphical:
				await click(button.get_global_rect().get_center() * (Vector2(window)/Vector2(1280,800)))
			else:
				button.pressed.emit()
			check(game.modal_name == "shop", "Shop entrance opens the real catalog: %s at %s" % [name, window])
			game.close_modal()
			await frames()
		game.speech.visible = false
		await snap("readability-home-%d" % window.x)
	root.size = Vector2i(1280,800)
	await frames(3)
	# All real lesson variants, plus a much longer future lesson, retain every character.
	for level in Lessons.LEVELS:
		var errors: Array[String] = []
		for key in Lessons.ORDER:
			var original: String = Lessons.entry(key, level).bubble
			game._say("PIP SAYS · " + level, original)
			if "".join(game.speech_pages) != original:
				errors.append(key + " lost text")
			for page in range(game.speech_pages.size()):
				game._show_speech_page(page)
				if game.speech_text.get_line_count() > game.speech_text.get_visible_line_count():
					errors.append(key + " clipped")
				if game.speech_text.get_theme_font_size("font_size") < 18:
					errors.append(key + " shrank")
		check(errors.is_empty(), "Every " + level + " dialogue variant fits at readable size with no lost text: " + ", ".join(errors))
	var long_quote = ("IF you pet me THEN happiness goes up. A variable remembers the new number. ").repeat(9) + "This is the final sentence."
	game._say("A longer explanation", long_quote)
	check(game.speech_pages.size() > 1 and "".join(game.speech_pages) == long_quote, "Long explanations paginate without dropping their ending")
	var first: String = game.speech_text.text
	game.speech_next.pressed.emit()
	check(game.speech_page_index == 1 and game.speech_text.text != first, "Next advances to the next readable page")
	game.speech_back.pressed.emit()
	check(game.speech_page_index == 0 and game.speech_text.text == first, "Back restores the previous page")
	game._process(120)
	check(game.speech.visible and game.speech_page_index == 0 and game.speech_text.text == first, "Waiting cannot erase or interrupt unfinished speech")
	game.speech_queue.clear()
	game.learn("parameters")
	while game.speech_page_index < game.speech_pages.size()-1:
		game.speech_next.pressed.emit()
	check(game.speech_text.text.ends_with("This is the final sentence.") and game.speech_next.text == "Done", "Final speech page includes the full ending and a Done button")
	game.speech_next.pressed.emit()
	check(game.speech_key == "parameters", "Done presents the next queued lesson")
	# Bubbles and their controls remain inside the room when Pip moves.
	var positions = [Vector2(140,248), Vector2(1140,248), Vector2(140,516), Vector2(1140,516), Vector2(640,420)]
	for point in positions:
		game.pip.position = point
		game._position_speech(1)
		check(Rect2(40,138,1200,525).encloses(game.speech.get_global_rect()), "Complete bubble stays visible beside Pip at " + str(point))
	game.pip.position = Vector2(640,516)
	game._position_speech(1)
	# Keep the exact encountered wording even when the current teaching level changes.
	game.progress.game_level = "college"
	for stage in range(3):
		game.progress.stage_badges[str(stage)] = Curriculum.MODES.duplicate()
	game.progress.practice_stage = 3
	game._show_lesson("functions")
	var heard: String = game.speech_full_text
	check(heard == Lessons.entry("functions", "college").bubble, "The captured quote is the exact displayed lesson variant")
	await snap("readability-long-bubble")
	if game.speech_pages.size() > 1:
		game.speech_next.pressed.emit()
		await snap("readability-bubble-last-page")
	game.progress.game_level = "kindergarten"
	game.open_knowledge("functions")
	await frames(3)
	check(game.overlay.get_node("JournalBody/Content/PipQuote").text == heard, "Knowledge keeps what Pip actually said after a level change")
	await snap("readability-knowledge-quote")
	var body = game.overlay.get_node("JournalBody")
	body.scroll_vertical = 100000
	await frames(3)
	var code = body.get_node("Content/Code")
	check(body.get_global_rect().intersects(code.get_global_rect()), "Scrolling reaches the complete code example below the full explanation")
	await snap("readability-knowledge-end")
	for node in game.overlay.get_children():
		if node is Button and node.text == "Read with Pip":
			node.pressed.emit()
			break
	check(game.modal_name.is_empty() and game.speech_full_text == heard, "Read with Pip replays exactly the saved words")
	game.progress.write()
	var reloaded = SaveData.new()
	reloaded.save_path = game.progress.save_path
	reloaded.load_progress()
	check(reloaded.pip_quotes.get("functions") == heard, "Full dialogue survives save and reload")
	reset_for_checks()
	check(game.progress.pip_quotes.is_empty(), "Reset clears saved dialogue along with discoveries")
	# Existing saves without quotes still get a complete Pip says section.
	game.progress.unlock("timer")
	game.open_knowledge("timer")
	check(game.overlay.get_node("JournalBody/Content/PipQuote").text == game._lesson("timer").bubble, "Older discoveries receive a full fallback quote without resetting progress")
	game.close_modal()

func picnic_drop(field, kind: String, caught: bool = true) -> void:
	field.spawn_item(kind, field.player_x if caught else (60 if field.player_x > 320 else 586))
	field.advance_items(5.0)

func verify_picnic() -> void:
	game.close_modal()
	reset_for_checks()
	game.progress.sound = false
	game.progress.game_level = "college"
	game.open_games()
	check(game.overlay.has_node("PlayPicnic"), "Picnic Catch has a visible entry in Games / Quizzes")
	await snap("picnic-games-menu")
	game.overlay.get_node("PlayPicnic").pressed.emit()
	check(game.modal_name == "intro" and game.progress.discovered.has("picnic"), "Picnic teaches input/output before the first round and saves it in Knowledge")
	await finish_intro()
	var field = game.picnic
	field.set_process(false)
	check(field.stage == 0 and not field.running and field.items.is_empty(), "New College players also start with gentle berries, and nothing falls before Start")
	var controls: Label = game.overlay.get_node("PicnicControls")
	check(controls.get_line_count() <= controls.get_visible_line_count(), "Picnic control instructions are completely visible")
	await snap("picnic-ready")
	game.picnic_start.pressed.emit()
	check(field.running and field.items.size() == 1 and game.picnic_start.disabled, "Start begins one round and cannot be pressed twice")
	field.items[0].node.queue_free()
	field.items.clear()
	# Input routing through the real field, including viewport scaling.
	for window in [Vector2i(1280,800),Vector2i(960,600)]:
		root.size = window
		await frames(3)
		if graphical:
			var point = (field.global_position+Vector2(490,165)) * (Vector2(window)/Vector2(1280,800))
			await mouse_move(point)
			check(absf(field.target_x-490) < 3, "Mouse moves the basket target in the game field at " + str(window))
		var touch = InputEventScreenTouch.new()
		touch.index = 0
		touch.pressed = true
		touch.position = (field.global_position+Vector2(190,160)) * (Vector2(window)/Vector2(1280,800))
		Input.parse_input_event(touch)
		await frames()
		check(absf(field.target_x-190) < 3, "Touch input reaches the correct basket position at " + str(window))
		touch.pressed = false
		Input.parse_input_event(touch)
		await snap("picnic-window-%d" % window.x)
	root.size = Vector2i(1280,800)
	await frames(3)
	field.player_x = 323
	field.target_x = 323
	var key = InputEventKey.new()
	key.keycode = KEY_RIGHT
	key.physical_keycode = KEY_RIGHT
	key.pressed = true
	Input.parse_input_event(key)
	await frames()
	field._process(0.05)
	key.pressed = false
	Input.parse_input_event(key)
	await frames()
	check(field.player_x > 323, "Right arrow moves Pip toward the right")
	var left_before: float = field.player_x
	game.overlay.get_node("PicnicLeft").button_down.emit()
	field._process(0.05)
	game.overlay.get_node("PicnicLeft").button_up.emit()
	check(field.player_x < left_before and field.button_direction == 0, "On-screen direction buttons move only while held")
	field.move_to_pointer(-500)
	for i in range(20): field._process(0.05)
	check(field.player_x == 60, "Basket stays within the left edge")
	field.move_to_pointer(2000)
	for i in range(20): field._process(0.05)
	check(field.player_x == field.size.x-60, "Basket stays within the right edge")
	for item in field.items: item.node.queue_free()
	field.items.clear()
	field.spawn_item("berry",field.player_x)
	game.picnic_pause.pressed.emit()
	var before: float = field.items[0].y
	var time_before: float = field.spawn_clock
	field._process(20)
	field.advance_items(20)
	check(field.paused and field.items[0].y == before and field.spawn_clock == time_before and game.picnic_pause.text == "Resume", "Pause freezes falling snacks and spawning without advancing the round")
	await snap("picnic-paused")
	game.picnic_pause.pressed.emit()
	check(not field.paused, "Resume continues the same round")
	var space = InputEventKey.new()
	space.keycode = KEY_SPACE
	space.pressed = true
	field._gui_input(space)
	check(field.paused, "Space pauses when the garden has keyboard focus")
	field._gui_input(space)
	check(not field.paused, "Space resumes the paused garden")
	field.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(field.paused, "Switching away from the application pauses the picnic")
	field.set_paused(false)
	field.advance_items(5)
	check(field.collected == 1 and field.streak == 1, "A snack crossing the basket counts exactly once, even across a large frame step")
	field.advance_items(5)
	check(field.collected == 1, "An already caught snack cannot count again")
	field.spawn_item("berry", field.player_x-100)
	field.advance_items(5)
	check(field.collected == 1 and field.streak == 0 and field.best_streak == 1, "A missed snack resets only the current streak and preserves collected snacks and best streak")
	# Exit unfinished: no gold, snacks, records, or rewards are paid.
	game.close_modal()
	check(not field.running and game.progress.coins == 0 and game.progress.picnic_rounds == 0, "Closing an unfinished picnic stops play and pays nothing")
	# An advanced round exercises seeds, leaves, costumes, and precise reward arithmetic.
	for stage in range(3): game.progress.stage_badges[str(stage)] = Curriculum.MODES.duplicate()
	game.progress.practice_stage = 3
	game.progress.owned = ["leaf_hat"]
	game.progress.equipped = {"pet:head":"leaf_hat"}
	game.start_picnic()
	await finish_intro()
	field = game.picnic
	field.set_process(false)
	check(field.stage == 3 and field.actor.cosmetic_items.get("head") == "leaf_hat", "Unlocked stages add the advanced picnic rules and Pip wears the equipped hat")
	game.picnic_start.pressed.emit()
	for item in field.items: item.node.queue_free()
	field.items.clear()
	field.player_x = 323
	field.target_x = 323
	field._update_player()
	field.spawned = 2
	check(field.next_kind() == "seed", "Later stages introduce golden seeds")
	field.spawned = 3
	check(field.next_kind() == "leaf", "Third and fourth stages also introduce leaves")
	field.stage = 0
	check(field.next_kind() == "berry", "First steps always stays berry-only")
	field.stage = 3
	picnic_drop(field,"leaf")
	check(field.collected == 0 and field.streak == 0 and field.seed_gold == 0, "A leaf adds no snack or gold")
	picnic_drop(field,"seed")
	check(field.collected == 1 and field.seed_gold == 2 and field.streak == 1, "Golden seed adds one snack and exactly two bonus gold")
	field.spawn_item("berry",173)
	field.spawn_item("seed",433)
	field.spawn_item("leaf",570)
	for item in field.items:
		item.y = 90 + item.x/7
		item.node.position.y = item.y-18.5
	await snap("picnic-playing")
	for item in field.items: item.node.queue_free()
	field.items.clear()
	for i in range(8): picnic_drop(field,"berry")
	var inventory_before: int = game.progress.inventory.berry
	var badges_before = game.progress.stage_badges.duplicate(true)
	var money_before: int = game.progress.coins
	picnic_drop(field,"berry")
	check(game.modal_name == "picnic_result" and game.progress.coins == money_before+42, "Finishing pays exactly 20 gold + 20 for a ten-catch streak + 2 seed gold")
	check(game.progress.inventory.berry == inventory_before+3 and game.progress.picnic_rounds == 1 and game.progress.picnic_best == 10, "Finished picnics grant treats and save the best streak and completed-round count")
	check(game.progress.stage_badges == badges_before, "A bonus picnic never replaces a curriculum badge")
	game._finish_picnic({"best_streak":10,"seed_gold":2})
	check(game.progress.coins == money_before+42 and game.progress.picnic_rounds == 1, "Duplicate finish events cannot pay twice")
	await snap("picnic-rewards")
	var saved = SaveData.new()
	saved.save_path = game.progress.save_path
	saved.load_progress()
	check(saved.picnic_best == 10 and saved.picnic_rounds == 1 and saved.coins == game.progress.coins, "Picnic gold and records survive save and reload")
	game.open_knowledge("picnic")
	check(game.overlay.get_node("JournalBody/Content/PipQuote").text == game.progress.pip_quotes.picnic and game.progress.pip_quotes.picnic.contains("longest streak was 10"), "Knowledge includes Pip's complete picnic explanation and the last round's streak")
	await snap("picnic-knowledge")
	reset_for_checks()
	check(game.progress.picnic_best == 0 and game.progress.picnic_rounds == 0 and game.progress.coins == 0, "Reset clears picnic records along with gold")
	game.progress.sound = false

func reset_for_checks() -> void:
	game._reset_progress()
	game.tutorial.finish()

func activate_tour_button(button: Button) -> void:
	await frames(2)
	if graphical:
		await click(button.get_global_rect().get_center() * (Vector2(root.size)/Vector2(1280,800)))
	else:
		button.pressed.emit()
	await frames(2)

func verify_tutorial() -> void:
	game.close_modal()
	game._reset_progress()
	game.progress.sound = false
	var tour = game.tutorial
	check(tour.active and tour.step_id() == "welcome" and not game.progress.tutorial_completed, "Reset progress restarts the tutorial from its welcome")
	var needs_before = Vector2(game.progress.fullness,game.progress.happiness)
	game._process(120)
	check(Vector2(game.progress.fullness,game.progress.happiness) == needs_before and not game.speech.visible, "Needs and ordinary lesson bubbles wait while the tutorial is being read")
	if graphical:
		await click(game.ui.get_node("ShopNav").get_global_rect().get_center())
		check(game.modal_name.is_empty() and tour.step_id() == "welcome", "Clicks outside the tutorial target cannot open unrelated controls")
	await activate_tour_button(tour.next_button)
	check(tour.step_id() == "pet" and tour.next_button.disabled, "The petting step waits for a real pet instead of advancing automatically")
	await snap("tutorial-pet")
	if graphical:
		await click(game.pip.position+Vector2(0,-54))
	else:
		game.pip.pet()
	check(tour.step_id() == "carry" and game.progress.pet_count == 1, "Petting Pip advances the tutorial and records real care")
	if graphical:
		await mouse_move(game.pip.position)
		await mouse_button(game.pip.position,true)
		await create_timer(0.3).timeout
		await mouse_move(Vector2(820,390))
		await create_timer(0.4).timeout
		check(game.pip.is_held and tour.carry_moved, "The green target permits holding and dragging Pip")
		await snap("tutorial-dragging")
		await mouse_button(Vector2(820,390),false)
		await create_timer(1.8).timeout
	else:
		game.pip.pick_up()
		game.pip.position = Vector2(820,390)
		game.pip.interacted.emit("move")
		game.pip.release()
		for i in range(180): game.pip._physics_process(1.0/60)
	check(tour.step_id() == "needs" and not game.pip.is_falling, "The carrying step advances after movement and a settled landing")
	await snap("tutorial-gold-and-needs")
	await activate_tour_button(tour.next_button)
	check(tour.step_id() == "feed", "The next green arrow points to Feed Critter")
	await activate_tour_button(game.ui.get_node("FeedNav"))
	check(tour.step_id() == "snack" and game.modal_name == "feed", "Opening Feed points to a real available treat")
	await snap("tutorial-feed")
	var berries: int = game.progress.inventory.berry
	await activate_tour_button(tour.target_control())
	check(tour.step_id() == "speech" and game.progress.inventory.berry == berries-1 and game.progress.feed_count == 1, "Offering the highlighted treat spends exactly one and opens the speech lesson")
	await snap("tutorial-dialogue")
	var read_pages = 0
	while tour.step_id() == "speech" and read_pages < 8:
		await activate_tour_button(game.speech_next)
		read_pages += 1
	check(tour.step_id() == "knowledge", "Reading every speech page reaches the Knowledge step")
	await activate_tour_button(game.journal_button)
	check(tour.step_id() == "book" and game.overlay.has_node("JournalBody"), "The real Knowledge book opens with Pip's complete explanation")
	await snap("tutorial-knowledge")
	await activate_tour_button(tour.next_button)
	await activate_tour_button(game.ui.get_node("ShopNav"))
	check(tour.step_id() == "catalog" and game.progress.coins == 0 and game.progress.owned.is_empty(), "The Shop introduction requires no gold or purchases")
	await activate_tour_button(game.overlay.get_node("RoomCategory"))
	check(tour.step_id() == "catalog" and game.shop_category == "room", "The highlighted Shop tabs remain usable without losing the tutorial")
	await snap("tutorial-shop")
	await activate_tour_button(tour.next_button)
	await activate_tour_button(game.ui.get_node("SettingsButton"))
	check(tour.step_id() == "level" and game.modal_name == "settings", "Settings introduces the actual Game level dropdown")
	await snap("tutorial-settings")
	game.overlay.get_node("GameLevel").item_selected.emit(1)
	await frames()
	check(tour.step_id() == "level" and game.progress.game_level == "middle", "Game level changes rebuild settings without stranding the arrow")
	await activate_tour_button(tour.next_button)
	await activate_tour_button(game.ui.get_node("GamesNav"))
	check(tour.step_id() == "activities" and game.modal_name == "games", "The final step introduces activities and points to Picnic Catch")
	await snap("tutorial-games")
	await activate_tour_button(game.overlay.get_node("PlayPicnic"))
	check(not tour.active and game.progress.tutorial_completed and game.modal_name == "intro", "Starting the highlighted game finishes the tour and enters the activity normally")
	var restored = SaveData.new()
	restored.save_path = game.progress.save_path
	restored.load_progress()
	check(restored.tutorial_completed, "Tutorial completion survives save and reload")
	game.close_modal()
	game.open_settings()
	await activate_tour_button(game.overlay.get_node("ReplayTutorial"))
	check(tour.active and tour.step_id() == "welcome" and game.progress.feed_count == 1 and game.progress.inventory.berry == berries-1, "Replay tutorial starts the tour without resetting care or inventory")
	# Every step stays readable and its target remains inside either supported window.
	for window in [Vector2i(1280,800),Vector2i(960,600)]:
		root.size = window
		await frames(3)
		var problems: Array[String] = []
		for step in range(tour.STEPS.size()):
			tour.step = step
			tour._enter_step()
			await frames(3)
			if not Rect2(0,0,1280,800).encloses(tour.target_rect) or not Rect2(0,0,1280,800).encloses(tour.card.get_global_rect()):
				problems.append(tour.step_id()+" outside viewport")
			if tour.card.get_global_rect().intersects(tour.target_rect):
				problems.append(tour.step_id()+" card covers target")
			if tour.heading.get_line_count() > tour.heading.get_visible_line_count():
				problems.append(tour.step_id()+" clipped heading")
			if tour.words.size.y > tour.words.get_parent().size.y+1:
				problems.append(tour.step_id()+" needs text scrolling")
			if graphical and tour.arrow_tip == Vector2.ZERO:
				problems.append(tour.step_id()+" missing arrow")
			if window.x == 960 and tour.step_id() in ["pet","snack","speech","activities"]:
				await snap("tutorial-small-"+tour.step_id())
		check(problems.is_empty(), "All tutorial text, arrows, targets, and cards fit at %s: %s" % [window,", ".join(problems)])
	root.size = Vector2i(1280,800)
	await frames()
	# Replays need a way forward if the pet is full or the player has no treats.
	game.progress.fullness = 100
	tour.step = 5
	tour._enter_step()
	check(not tour.next_button.disabled and tour.words.text.contains("Pip is full"), "Replaying with a full Pip offers a clear way past the feeding step")
	await activate_tour_button(tour.skip_button)
	check(not tour.active and game.progress.tutorial_completed, "Skip tutorial dismisses and saves completion")
	check(game.ui.get_node("ShopNav").focus_mode == Control.FOCUS_ALL, "Finishing restores normal keyboard focus for home controls")
	game.close_modal()
	# A saved but unfinished tour starts again next launch; old saves are respected.
	game.start_tutorial()
	restored.load_progress()
	check(not restored.tutorial_completed, "An unfinished tour stays pending in the save")
	game.tutorial.finish()
	var legacy = SaveData.new()
	legacy.save_path = "user://tutorial_legacy_test.json"
	var file = FileAccess.open(legacy.save_path,FileAccess.WRITE)
	file.store_string(JSON.stringify({"coins":75,"pet_count":9}))
	file.close()
	legacy.load_progress()
	check(legacy.tutorial_completed and legacy.coins == 75, "Pre-tutorial saves keep their progress and can use Replay without a forced tour")
	DirAccess.remove_absolute(legacy.save_path)
	game._reset_progress()
	check(tour.active and tour.step_id() == "welcome" and not game.progress.tutorial_completed and game.progress.game_level == "middle", "Reset starts the tour again while retaining the selected Game level")
	game.tutorial.finish()
	game.progress.sound = false
