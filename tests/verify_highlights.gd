extends "res://tests/verify.gd"
## Highlighting, exact-text preservation, and real teaching-surface checks.
const UI = preload("res://scripts/ui.gd")
const Terms = preload("res://scripts/teaching_terms.gd")
const Lab = preload("res://data/logic_lab.gd")

func highlighted_words(value: String, code_mode: bool = false) -> Array:
	return Terms.matches(value, code_mode).map(func(found): return found.get_string())

func check_surface(node, source: String, note: String) -> void:
	check(node is UI.LearningText and node.get_parsed_text() == source and node.text.contains("[bgcolor="), note)

func check_fixed_text(node: Node) -> Array:
	var clipped = []
	if node is UI.LearningText and node.is_visible_in_tree() and not node.fit_content and not node.content_fits():
		clipped.append(node.words)
	for child in node.get_children():
		clipped.append_array(check_fixed_text(child))
	return clipped

func run() -> void:
	graphical = DisplayServer.get_name() != "headless"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_dir = arg.trim_prefix("--capture=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
	check(highlighted_words("IF hungry THEN feed ELSE pet. Boolean true FALSE variables loops input output") == ["IF","THEN","ELSE","Boolean","true","FALSE","variables","loops","input","output"], "Core beginner terms stand out in all letter cases")
	check(highlighted_words("gift floor notebook sandy is_held input_name") == [], "Whole-word matching never highlights pieces of names")
	check(highlighted_words("Pet and feed, or wait for Pip; not now. AND OR NOT FOR EACH") == ["AND","OR","NOT","FOR","EACH"], "Ordinary prose conjunctions stay quiet; explicit logic words stand out")
	check(highlighted_words("if a and not b or c:\n    for i in range(3):\n        total += 1",true) == ["if","and","not","or","for","in","range","+="], "Lowercase code keywords and operators are highlighted")
	check(highlighted_words("Function parameter accumulator list index nested loops boundary check debug") == ["Function","parameter","accumulator","list","index","nested loops","boundary check","debug"], "Higher-stage concepts use the same emphasis")
	root.size = Vector2i(1280,800)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(5)
	game.progress.sound = false
	var tour = game.tutorial
	tour.step = 1
	tour._enter_step()
	check_surface(tour.words,preload("res://data/game_text.gd").TOUR_KIDS.pet,"Tutorial instructions highlight their IF / THEN explanation")
	await snap("highlight-tutorial")
	tour.finish()
	game.progress.save_path = "user://crittercare_highlight_acceptance.json"
	game.speech_queue.clear()
	game.close_modal()
	game._show_lesson("boolean")
	check_surface(game.speech_text,game.speech_pages[0].strip_edges(),"Pip's speech highlights terms without changing a sentence")
	await snap("highlight-speech")
	game.open_knowledge("boolean")
	var content = game.overlay.get_node("JournalBody/Content")
	check_surface(content.get_node("PipQuote"),game.progress.pip_quotes.boolean,"Knowledge highlights the complete saved Pip quote")
	check_surface(content.get_node("Explanation"),game._lesson("boolean").body,"Knowledge explanations share the term styling")
	check_surface(content.get_node("Code"),game._lesson("boolean").code,"Knowledge code retains indentation and exact source")
	await snap("highlight-knowledge")
	var sample = UI.paragraph(game.ui,"",18)
	var exact = "IF [b]literal[/b] THEN list [1, 3, 2]; steps[index] < 3.\n\t[unknown] — café ✓"
	sample.words = exact
	check(sample.get_parsed_text() == exact,"Brackets, literal markup, accents, tabs, newlines, and symbols survive formatting")
	var roundtrip = true
	for level in Lessons.LEVELS:
		for key in Lessons.ORDER:
			var lesson = Lessons.entry(key,level)
			for field in ["bubble","body","code","question","why"]:
				sample.code_mode = field == "code"
				sample.words = lesson[field]
				if sample.get_parsed_text() != lesson[field]: roundtrip = false
			for answer in lesson.choices:
				sample.words = answer
				if sample.get_parsed_text() != answer: roundtrip = false
	check(roundtrip,"Every lesson, code example, quiz choice, and explanation round-trips exactly at all Game levels")
	sample.queue_free()
	var quiz_clipping = []
	for level in Lessons.LEVELS:
		game.progress.game_level = level
		for key in Lessons.ORDER:
			game.quiz_keys = [key]
			game.quiz_index = 0
			game._quiz_question()
			await frames(1)
			quiz_clipping.append_array(check_fixed_text(game.overlay))
	check(quiz_clipping.is_empty(),"Every highlighted quiz question and answer fits at every Game level: " + str(quiz_clipping))
	game.progress.game_level = "kindergarten"
	game.quiz_keys = ["boolean"]
	game.quiz_index = 0
	game._quiz_question()
	var every_answer = true
	for answer in game.quiz_answer_buttons:
		var words = answer.get_node("TeachingWords")
		if words.get_parsed_text() != answer.accessibility_name or words.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			every_answer = false
	check(every_answer,"All quiz choices use passive rich text with their full accessible name")
	await snap("highlight-quiz")
	var answer = game.quiz_answer_buttons[0]
	await click(answer.get_global_rect().get_center())
	check(game.answer_locked and not game.next_button.disabled,"Highlighted quiz text still accepts an actual pointer click")
	check_surface(game.game_feedback,game.game_feedback.words,"Quiz feedback highlights the explanation after an answer")
	game.progress.game_level = "college"
	game.progress.stage_badges = {"0":Curriculum.MODES.duplicate(),"1":Curriculum.MODES.duplicate(),"2":Curriculum.MODES.duplicate()}
	game.progress.lab_completed = ["delivery","repeats"]
	game.start_lab(2)
	game._lab_setup()
	var lab = game.lab_screen
	lab.add_block("hungry")
	check_surface(lab.row_cards[0].get_node("Words"),Lab.BLOCKS.hungry.title,"Newly placed Lab blocks highlight IF, THEN, and ELSE")
	lab.step_run()
	lab.step_run()
	check_surface(lab.feedback,lab.feedback.words,"Live Lab trace feedback is highlighted after updates")
	await snap("highlight-lab")
	var layout_ok = true
	for window in [Vector2i(1280,800),Vector2i(960,600)]:
		root.size = window
		for screen in [game.open_games,game.open_settings,game.open_shop,game.start_sort,game.start_loop]:
			screen.call()
			await frames(3)
			var clipped = check_fixed_text(game.ui)
			if not clipped.is_empty():
				print("CLIPPED: ",clipped)
				layout_ok = false
	check(layout_ok,"Highlighted fixed text fits care, menus, settings, Shop, sorting, and loops at both window sizes")
	root.size = Vector2i(960,600)
	game.close_modal()
	game._show_lesson("condition")
	await snap("highlight-small-window")
	game._save()
	var reload = SaveData.new()
	reload.save_path = game.progress.save_path
	reload.load_progress()
	check(reload.pip_quotes == game.progress.pip_quotes and not JSON.stringify(reload.pip_quotes).contains("[bgcolor="),"Saving and loading preserves plain dialogue without presentation markup")
	game.queue_free()
	await frames()
	print("HIGHLIGHT RESULT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
