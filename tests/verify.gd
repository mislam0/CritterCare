extends SceneTree
## Integration checks. Run from the project directory:
## godot --headless --path . --script res://tests/verify.gd -- --test-mode
## Add --capture=/absolute/folder under a graphical display for screenshots.

const SaveData = preload("res://scripts/save_data.gd")
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
	game._reset_progress()
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
	# Inspect all journal layouts with all real content, after gameplay checks.
	for key in Lessons.ORDER:
		game.progress.unlock(key)
		game.open_knowledge(key)
		await frames(2)
		var body = game.overlay.get_node("JournalBody")
		check(body.position.y + body.size.y < 541, "Knowledge body fits above code: " + key)
		if key in ["functions", "loops", "repeat"]:
			await snap("journal-" + key)
	game.close_modal()
	for key in Lessons.ORDER:
		game._show_lesson(key, false)
		await frames(2)
		check(game.speech_text.position.y + game.speech_text.size.y <= 145, "Learning bubble fits: " + key)
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
