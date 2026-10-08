extends "res://tests/verify.gd"
## Outcome signals, zero-experience wording, and automatic teaching rate limits.
const UI = preload("res://scripts/ui.gd")
const Text = preload("res://data/game_text.gd")
const Jam = preload("res://data/snack_jam.gd")
const Cooldown = preload("res://scripts/teaching_cooldown.gd")

func clips(node: Node) -> Array:
	var found = []
	if node is UI.LearningText and node.is_visible_in_tree() and not node.fit_content and not node.content_fits(): found.append(node.words)
	for child in node.get_children(): found.append_array(clips(child))
	return found

func outcome(body, correct: bool) -> bool:
	var title = body.get_meta("feedback_heading")
	return body.get_meta("outcome") == (1 if correct else -1) and title.visible and title.get_theme_color("default_color") == (UI.CORRECT if correct else UI.INCORRECT) and title.get_theme_font_size("normal_font_size") >= 26

func run() -> void:
	graphical = DisplayServer.get_name() != "headless"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_dir = arg.trim_prefix("--capture=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
	var gate = Cooldown.new()
	check(gate.ready("pickup",0),"First lesson is immediately eligible")
	gate.mark("pickup",1000)
	check(not gate.ready("pickup",60999) and gate.ready("pickup",61000),"A repeated lesson waits exactly sixty seconds")
	check(gate.ready("feed",1001),"Cooldown is per lesson, so other discoveries still appear")
	gate.clear()
	check(gate.ready("pickup",1002),"Reset clears teaching cooldowns")
	for key in Lessons.ORDER:
		var kid = Lessons.entry(key,"kindergarten")
		check(kid.bubble.split(" ").size() <= 40 and kid.body.split(" ").size() <= 70 and kid.choices.size()==3,"Short complete beginner content: "+key)
	check(Lessons.entry("timer").question == "What does Pip's timer count?","The first timer quiz asks about the taught idea, not undefined code")
	check(Lessons.entry("lab_sequence").bubble.contains("Run means") and Lessons.entry("boolean").bubble.contains("true means yes"),"Controls and Boolean vocabulary are defined from zero")
	root.size = Vector2i(1280,800)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(5)
	game.tutorial.finish()
	game.progress.sound = false
	game.progress.save_path = "user://crittercare_feedback_acceptance.json"
	game.speech_queue.clear()
	game.speech.hide()
	for level in Lessons.LEVELS:
		game.progress.game_level = level
		game.progress.practice_stage = 0
		check(game._lesson("boolean").bubble == Lessons.entry("boolean",level).bubble,"Selected Game level controls wording even at First steps: "+level)
	game.progress.game_level = "kindergarten"
	game.learn("boolean")
	for i in range(20): game.learn("boolean")
	check(game.speech_queue.count("boolean")==1,"Rapid pickups queue only one copy of a new lesson")
	game._show_lesson(game.speech_queue.pop_front())
	var words: String = game.speech_full_text
	check(game.speech_pages.size() >= 2 and "".join(game.speech_pages)==words,"Bite-size speech pages preserve every word")
	await snap("short-pip-lesson")
	game.speech.hide()
	game.speech_key = ""
	for i in range(20): game.learn("boolean")
	check(not game.speech.visible and not game.speech_queue.has("boolean"),"Repeated pickup stays quiet during cooldown")
	game.learn("events")
	check(game.speech_queue.has("events"),"A different lesson remains eligible")
	game.speech_queue.clear()
	game.teaching_cooldowns.shown.boolean = Time.get_ticks_msec()-60001
	game.learn("boolean")
	check(game.speech.visible and game.speech_key=="boolean","The same interaction teaches again after a minute")
	game.speech.hide()
	game._say("Read again",words,"boolean")
	check(game.speech_full_text==words and game.speech.visible,"Explicit Read with Pip remains available")
	game.speech.hide()
	for i in range(12): game._say_auto("shop_equip","Dress Pip","Equip means put it on.")
	check(game.auto_speech.size()==1,"Equipment changes queue only one popup")
	game._process(0.01)
	game.speech.hide()
	game._say_auto("shop_equip","Dress Pip","Equip means put it on.")
	check(game.auto_speech.is_empty(),"Equipment teaching waits a minute after display")
	game.quiz_keys = ["boolean"]
	game.quiz_index = 0
	game._quiz_question()
	var wrong = game.quiz_answer_buttons.filter(func(button): return not button.get_meta("correct"))[0]
	await click(wrong.get_global_rect().get_center())
	check(outcome(game.game_feedback,false) and wrong.get_meta("outcome")==-1,"Wrong quiz click gets a large bold red banner and red answer")
	check(game.quiz_answer_buttons.filter(func(button): return button.get_meta("correct"))[0].get_meta("outcome")==1,"Correct quiz choice is shown in green after a mistake")
	await snap("quiz-red")
	game._quiz_question()
	var right = game.quiz_answer_buttons.filter(func(button): return button.get_meta("correct"))[0]
	await click(right.get_global_rect().get_center())
	check(outcome(game.game_feedback,true),"Correct quiz click gets immediate vivid green feedback")
	await snap("quiz-green")
	game.start_sort()
	game._answer_sort_choice(1-Curriculum.sort_answer(0,game.sort_index,game.sort_items[game.sort_index]))
	check(outcome(game.game_feedback,false),"Wrong sort is red")
	await snap("sort-red")
	game._next_sort()
	game._answer_sort_choice(Curriculum.sort_answer(0,game.sort_index,game.sort_items[game.sort_index]))
	check(outcome(game.game_feedback,true),"Correct sort is green without waiting for cooldown")
	game.start_loop()
	game.loop_count = 1
	game._update_loop_code()
	game._run_loop()
	while game.loop_running: game._process(0.5)
	check(outcome(game.game_feedback,false),"Wrong loop count is red")
	await snap("loop-red")
	game.loop_count = game.loop_targets[0]
	game._update_loop_code()
	game._run_loop()
	while game.loop_running: game._process(0.5)
	check(outcome(game.game_feedback,true),"Correct loop count is green")
	await snap("loop-green")
	game.start_lab(0)
	await finish_intro()
	var lab = game.lab_screen
	lab.add_block("feed")
	lab.step_run()
	while lab.active: lab.step_run()
	check(outcome(lab.feedback,false) and lab.feedback.words.contains("BEFORE"),"Wrong Lab plan is red and gives a concrete fix")
	await snap("lab-red")
	lab.clear_program()
	lab.add_block("right")
	lab.add_block("feed")
	lab.step_run()
	while lab.active: lab.step_run()
	check(outcome(lab.feedback,true),"A working Lab plan is green")
	await snap("lab-green")
	game.start_picnic()
	await finish_intro()
	var picnic = game.picnic
	picnic.start()
	picnic.resolve_catch("berry")
	check(picnic.last_outcome==1 and picnic.floaties.back().node.get_theme_color("default_color")==UI.CORRECT,"Caught snack gets a large vivid green popup")
	picnic.resolve_catch("leaf")
	check(picnic.last_outcome==-1 and picnic.floaties.back().node.get_theme_color("default_color")==UI.INCORRECT,"Caught leaf gets a red popup")
	for item in picnic.items: item.node.queue_free()
	picnic.items.clear()
	picnic.spawn_item("berry",picnic.size.x-60 if picnic.player_x < picnic.size.x/2+1 else 60)
	picnic.advance_items(20)
	check(picnic.last_outcome==-1 and picnic.misses>0,"Missed picnic snack also reports red")
	await snap("picnic-red")
	picnic.resolve_catch("berry")
	await snap("picnic-green")
	game.start_snack_jam()
	var jam = game.snack_jam
	jam.manual_clock = true
	jam.start()
	jam.advance_to(Jam.COUNT_IN)
	jam.tap(0)
	check(jam.cue.get_meta("outcome")==1 and jam.lane_results[0].correct,"Rhythm hit turns headline and lane green")
	await snap("jam-green")
	jam.tap(1)
	check(jam.cue.get_meta("outcome")==-1 and not jam.lane_results[1].correct,"Wrong or extra rhythm tap turns headline and lane red")
	jam.advance_to(jam.round_state.notes[1].time+0.3)
	check(jam.cue.words.contains("MISSED") and not jam.lane_results[jam.round_state.notes[1].lane].correct,"A missed rhythm note gets its own red outcome")
	await snap("jam-red")
	var clipped = []
	for window in [Vector2i(1280,800),Vector2i(960,600)]:
		root.size = window
		for level in Lessons.LEVELS:
			game.progress.game_level = level
			game.progress.practice_stage = 0
			for screen in [game.open_games,game.open_settings,game.open_shop,game.open_feed,game.start_loop,game.start_sort,game.start_snack_jam]:
				screen.call()
				await frames(2)
				clipped.append_array(clips(game.overlay))
	check(clipped.is_empty(),"Audience-specific labels fit at both sizes: "+str(clipped))
	game.progress.game_level = "kindergarten"
	game.open_knowledge("boolean")
	await snap("simple-knowledge-small")
	game._reset_progress()
	check(game.teaching_cooldowns.shown.is_empty() and game.auto_speech.is_empty() and game.tutorial.active,"Reset clears queued reminders and timers, then starts tutorial")
	check(game.tutorial.words.words==Text.TOUR_KIDS.welcome,"First-play/reset tour uses short beginner instructions")
	await snap("simple-tutorial-small")
	game.queue_free()
	await frames()
	print("FEEDBACK RESULT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
