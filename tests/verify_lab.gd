extends "res://tests/verify.gd"
## Logic Lab acceptance checks. Uses only isolated test saves.
const Lab = preload("res://data/logic_lab.gd")
const SOLUTIONS = [
	["right","feed"], ["repeat3","feed"], ["hungry"], ["both"],
	["repeat_add"], ["define","repeat2","call"], ["pack3","pack3"],
	["each"], ["nested23"]
]

func finish_lab(lab) -> void:
	lab.step_run()
	var budget = 128
	while lab.active and budget > 0:
		lab.step_run()
		budget -= 1
	check(budget > 0 and not lab.active,"A bounded program finishes without an infinite loop")
	await frames()

func fit_labels(node: Node) -> Array[String]:
	var problems: Array[String] = []
	if node is Label and node.is_visible_in_tree() and node.clip_text and node.get_line_count() > node.get_visible_line_count():
		problems.append(str(node.text))
	for child in node.get_children():
		problems.append_array(fit_labels(child))
	return problems

func run() -> void:
	graphical = DisplayServer.get_name() != "headless"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_dir = arg.trim_prefix("--capture=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
	# Expectations specify the task outcomes independently of the runner's goal checker.
	for i in range(SOLUTIONS.size()):
		var mission: Dictionary = Lab.CHALLENGES[i]
		var original = mission.duplicate(true)
		var report = Lab.execute(mission,SOLUTIONS[i])
		check(report.valid and report.success,"Working program solves " + mission.id)
		check(report.trace.size() <= 32 and report.results.size() == mission.cases.size(),"Each authored visit has a finite execution trace: " + mission.id)
		check(mission == original,"Running does not mutate the authored starting situation: " + mission.id)
		if i in [4,6,7,8]:
			check(report.results[0].state.seeds == 6,"The seed jar reaches exactly six: " + mission.id)
		if i in [0,1,5]:
			check(report.results[0].state.position == [1,3,0,0,0,2][i] and report.results[0].state.fed == 1,"Pip reaches the correct tile and eats exactly one berry: " + mission.id)
		if i in [2,3]:
			check(report.results[0].state.fed == 1 and report.results[0].state.petted == 0,"The hungry visit takes only the feeding branch")
			check(report.results[-1].state.fed == 0 and report.results[-1].state.petted == 1,"The not-hungry visit takes only the petting branch")
	check(not Lab.execute(Lab.CHALLENGES[0],["feed","right"]).success,"Feeding before moving fails")
	check(not Lab.execute(Lab.CHALLENGES[0],["right"]).success,"Reaching the tile alone does not count as feeding")
	check(not Lab.execute(Lab.CHALLENGES[1],["repeat2","feed"]).success,"An incorrect repeat count fails with retryable feedback")
	check(Lab.execute(Lab.CHALLENGES[1],["right","right","right","feed"]).success,"Separate steps are accepted as an alternative working program")
	check(not Lab.execute(Lab.CHALLENGES[2],["feed"]).success,"A program must work for both hungry and not-hungry visits")
	check(not Lab.execute(Lab.CHALLENGES[2],["swapped"]).success,"Swapping THEN and ELSE changes the outcome")
	check(not Lab.execute(Lab.CHALLENGES[3],["either"]).success,"OR is rejected when the task requires both hunger and food")
	check(Lab.execute(Lab.CHALLENGES[3],["both"]).results[1].state.petted == 1,"Hungry Pip without food takes the safe ELSE branch")
	check(Lab.execute(Lab.CHALLENGES[4],["add3","add3"]).success,"Different additions can reach the same target")
	check(not Lab.execute(Lab.CHALLENGES[5],["repeat2","call","define"]).success,"A function cannot run before its definition")
	check(not Lab.execute(Lab.CHALLENGES[5],["define","repeat2"]).success,"Defining a function does not execute it")
	check(Lab.execute(Lab.CHALLENGES[6],["pack2","pack2","pack2"]).success,"Parameter calls accept another correct solution")
	check(not Lab.execute(Lab.CHALLENGES[7],["add3","add3"]).success,"The list task requires reading the list as well as reaching six")
	check(not Lab.execute(Lab.CHALLENGES[8],["nested22"]).success,"Two groups of two do not satisfy two groups of three")
	check(not Lab.execute(Lab.CHALLENGES[0],[]).valid,"An empty program cannot run or award a reward")
	check(not Lab.execute(Lab.CHALLENGES[0],["delete_save"]).valid,"Unknown instructions are rejected")
	check(not Lab.execute(Lab.CHALLENGES[0],["each"]).valid,"Blocks from a different challenge are rejected")
	check(not Lab.execute(Lab.CHALLENGES[0],["right","right","right","right","right","right"]).valid,"The editor and runner enforce the same five-block limit")

	root.size = Vector2i(1280,800)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(5)
	game.tutorial.finish()
	game.progress.save_path = "user://crittercare_lab_acceptance.json"
	game.progress.sound = false
	game.open_games()
	check(game.overlay.has_node("PlayLogicLab"),"Logic Lab is visible in Games / Quizzes")
	await snap("lab-games-menu")
	game.overlay.get_node("PlayLogicLab").pressed.emit()
	check(game.modal_name == "lab_menu","The Games button opens the lab challenge menu")
	check(not game.overlay.get_node("LabChallenge0").disabled and game.overlay.get_node("LabChallenge1").disabled,"A new learner begins with the first simple challenge")
	await snap("lab-challenge-menu")
	game.overlay.get_node("LabChallenge0").pressed.emit()
	check(game.modal_name == "intro" and game.progress.discovered.has("lab_sequence"),"A plain-language lesson is shown and saved before the first challenge")
	await finish_intro()
	var lab = game.lab_screen
	await frames(3)
	check(lab.run_button.disabled and lab.step_button.disabled,"Empty programs cannot start from the UI")
	if graphical:
		await click(lab.get_node("Add_feed").get_global_rect().get_center())
		await click(lab.get_node("Add_right").get_global_rect().get_center())
	else:
		lab.get_node("Add_feed").pressed.emit()
		lab.get_node("Add_right").pressed.emit()
	check(lab.program == ["feed","right"],"Clicking blocks builds a program in order")
	var coins: int = game.progress.coins
	var berries: int = game.progress.inventory.berry
	await finish_lab(lab)
	check(not lab.report.success and game.progress.coins == coins and game.progress.inventory.berry == berries,"An unsuccessful attempt spends and awards no inventory or coins")
	check(lab.feedback.text.contains("BEFORE"),"Pip explains the actual ordering mistake")
	lab.hint_button.pressed.emit()
	check(lab.feedback.text.contains("next tile"),"Hint gives a relevant clue without requiring a purchase")
	lab.row_controls[1][0].pressed.emit()
	check(lab.program == ["right","feed"],"The up button reorders instructions")
	lab.toggle_run()
	check(lab.active and lab.autoplay and lab.row_controls[0][2].disabled,"Running highlights execution and locks edits")
	var trace_before: int = lab.trace_index
	lab.toggle_run()
	lab._process(3.0)
	check(lab.active and not lab.autoplay and lab.trace_index == trace_before,"Pause freezes instruction execution")
	lab.stop_run()
	check(not lab.active and lab.program == ["right","feed"],"Stop preserves the editable program")
	await snap("lab-program-ready")
	await finish_lab(lab)
	check(lab.report.success and game.progress.coins == coins+25 and game.progress.inventory.berry == berries+2,"First working solution awards exactly 25 coins and two berries")
	check(game.progress.lab_completed == ["delivery"] and game.progress.stage_badges.is_empty(),"Lab completion persists separately from curriculum badges")
	check(game.progress.pip_quotes.lab_sequence.contains("fullness changes: 30 + 20 = 50"),"Knowledge records Pip's actual complete walkthrough")
	await snap("lab-first-success")
	await finish_lab(lab)
	game._finish_lab("delivery")
	check(game.progress.coins == coins+25 and game.progress.inventory.berry == berries+2,"Replay and duplicate completion cannot award the first-solution reward twice")
	# Exercise Godot's drag protocol and a real pointer drag when a display exists.
	lab.clear_program()
	var foreign = {"lab":-1,"block":"right","row":-1}
	check(not lab.can_drop(foreign),"A different lab's drag data is rejected")
	if graphical:
		var from: Vector2 = lab.get_node("Add_right").get_global_rect().get_center()
		var to: Vector2 = lab.slots[0].get_global_rect().get_center()
		await mouse_move(from)
		await mouse_button(from,true)
		var previous = from
		for tick in range(1,11):
			var point = from.lerp(to,float(tick)/10)
			Input.warp_mouse(point)
			var motion = InputEventMouseMotion.new()
			motion.position = point
			motion.global_position = point
			motion.relative = point-previous
			motion.button_mask = MOUSE_BUTTON_MASK_LEFT
			Input.parse_input_event(motion)
			previous = point
			await frames(2)
		await mouse_button(to,false)
		check(lab.program == ["right"],"Dragging a tray block into the program works with actual pointer events")
	else:
		lab.drop_block(0,{"lab":lab.get_instance_id(),"block":"right","row":-1})
	lab.add_block("feed")
	lab.drop_block(0,{"lab":lab.get_instance_id(),"block":"feed","row":1})
	check(lab.program == ["feed","right"],"Dragging an existing row reorders instead of duplicating it")
	lab.remove_block(0)
	check(lab.program == ["right"],"Removing a row closes the gap")
	# Complete every stage through the same editor, trace, and reward signals players use.
	game.progress.game_level = "college"
	for stage in range(3): game.progress.stage_badges[str(stage)] = Curriculum.MODES.duplicate()
	for i in range(1,Lab.CHALLENGES.size()):
		game.start_lab(i)
		await finish_intro()
		lab = game.lab_screen
		for id in SOLUTIONS[i]: lab.add_block(id)
		await frames(3)
		var errors = fit_labels(lab)
		check(errors.is_empty(),"Challenge text and instruction labels fit: " + Lab.CHALLENGES[i].id + " " + str(errors))
		await finish_lab(lab)
		check(game.progress.lab_completed.has(Lab.CHALLENGES[i].id),"Editor and runner complete " + Lab.CHALLENGES[i].id)
		if i in [2,4,5,7,8]: await snap("lab-solved-" + Lab.CHALLENGES[i].id)
	check(game.progress.coins == coins+225,"Nine first completions pay nine rewards")
	game._save()
	var restored = SaveData.new()
	restored.save_path = game.progress.save_path
	restored.load_progress()
	check(restored.lab_completed == game.progress.lab_completed and restored.coins == game.progress.coins,"Lab records and rewards survive save/reload")
	check(restored.pip_quotes.lab_nested == game.progress.pip_quotes.lab_nested,"Full lab explanations survive save/reload")
	game.progress.game_level = "kindergarten"
	game.open_logic_lab()
	check(game.overlay.get_node("LabChallenge3").disabled and not game.overlay.get_node("LabChallenge2").disabled,"Kindergarten keeps only the three gentle lab challenges even with advanced records")
	game.progress.game_level = "middle"
	check(not Lab.is_unlocked(7,game.progress.unlocked_stage(),game.progress.lab_completed),"Middle level does not expose the college list puzzles")
	game.progress.game_level = "college"
	game.open_logic_lab()
	check(fit_labels(game.overlay).is_empty(),"All challenge menu labels fit")
	await snap("lab-all-complete")
	game.start_lab(8)
	await finish_intro()
	lab = game.lab_screen
	lab.add_block("nested23")
	lab.step_run()
	lab.step_run()
	lab.step_run()
	if graphical:
		root.size = Vector2i(960,600)
		await frames(4)
		check(fit_labels(lab).is_empty(),"Logic Lab remains readable in a 960 by 600 window")
		await snap("lab-small-window")
	game.close_modal()
	check(not lab.active and not lab.is_processing(),"Closing an unfinished run stops all lab playback")
	var old = FileAccess.open("user://crittercare_lab_legacy.json",FileAccess.WRITE)
	old.store_string(JSON.stringify({"version":6,"coins":73,"owned":["leaf_hat"],"tutorial_completed":true}))
	old.close()
	var legacy = SaveData.new()
	legacy.save_path = "user://crittercare_lab_legacy.json"
	legacy.load_progress()
	check(legacy.lab_completed.is_empty() and legacy.coins == 73 and legacy.owned.has("leaf_hat"),"Old saves gain an empty lab record without losing coins or purchases")
	game._reset_progress()
	check(game.progress.lab_completed.is_empty() and game.progress.coins == 0 and game.tutorial.active,"Reset clears lab rewards and completion and restarts the tutorial")
	check(game.progress.game_level == "college","Reset keeps the selected Game level")
	game.tutorial.finish()
	game.close_modal()
	for path in ["user://crittercare_lab_acceptance.json","user://crittercare_lab_legacy.json"]:
		DirAccess.remove_absolute(path)
	print("LAB RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
