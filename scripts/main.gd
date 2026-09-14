extends Node2D
## Main coordinator: care UI, lesson queue, inventory, mini games, and quizzes.
## Save data and learning content are separated so they are easy to extend.

const UI = preload("res://scripts/ui.gd")
const SaveData = preload("res://scripts/save_data.gd")
const Lessons = preload("res://data/lessons.gd")
const Icon = preload("res://scripts/icon.gd")
var progress = SaveData.new()
@onready var pip = $Pip
@onready var interface = $Interface
var ui: Control
var overlay: Control
var modal_name: String = ""
var fullness_bar: ProgressBar
var happiness_bar: ProgressBar
var fullness_label: Label
var happiness_label: Label
var pocket_label: Label
var discoveries_label: Label
var status_label: Label
var journal_button: Button
var speech: Panel
var speech_tail: Polygon2D
var speech_title: Label
var speech_text: Label
var speech_hint: Label
var speech_click: Button
var speech_life: float = 6.0
var speech_key: String = ""
var speech_queue: Array = []
var toast_label: Label
var toast_time: float = 0.0
var save_time: float = 0.0
var start_time: float = 0.0
var audio: AudioStreamPlayer
var quiz_keys: Array = []
var quiz_index: int = 0
var quiz_score: int = 0
var answer_locked: bool = false
var quiz_answer_buttons: Array = []
var game_feedback: Label
var next_button: Button
var sort_items: Array = []
var sort_index: int = 0
var sort_score: int = 0
var sort_rule_and: bool = false
var loop_round: int = 0
var loop_targets: Array = [3, 5, 4]
var loop_count: int = 3
var loop_step: int = 0
var loop_clock: float = 0.0
var loop_running: bool = false
var loop_marker: Panel
var loop_count_label: Label
var loop_code_label: Label
var loop_attempts: int = 0
var loop_buttons: Array = []
var session_rewarded: bool = false

func _ready() -> void:
	if "--test-mode" in OS.get_cmdline_user_args():
		progress.save_path = "user://crittercare_test_ui.json"
	else:
		progress.load_progress()
	# Ignore obsolete lesson IDs from a future or edited save.
	progress.discovered = progress.discovered.filter(func(key): return Lessons.DATA.has(key))
	pip.calm = progress.calm
	ui = Control.new()
	ui.name = "UI"
	ui.size = Vector2(1280, 800)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.theme = UI.theme()
	interface.add_child(ui)
	_build_home()
	pip.interacted.connect(_on_interaction)
	audio = AudioStreamPlayer.new()
	audio.volume_db = -19.0
	add_child(audio)
	_refresh_home()
	if progress.discovered.size() > 0:
		_say("Welcome back!", "Your treats and discoveries are right where you left them. Shall we learn something little today?", 6.0)
	else:
		_say("Hello, I'm Pip!", "A little pet. A little play. A little programming! Click my head to pet me, or hold and drag to pick me up.", 7.0)

func _build_home() -> void:
	var logo = TextureRect.new()
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.texture = preload("res://assets/icon.svg")
	logo.position = Vector2(48, 37)
	logo.size = Vector2(66, 66)
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(logo)
	UI.label(ui, "CritterCare", Rect2(128, 29, 310, 51), 39, UI.INK)
	UI.label(ui, "Little moments. Big discoveries.", Rect2(130, 80, 360, 26), 17, UI.MUTED)
	fullness_bar = _meter("Fullness", 556, Color("d6ac68"))
	happiness_bar = _meter("Happiness", 740, Color("bf8290"))
	UI.panel(ui, Rect2(930, 38, 190, 70), Color("ececdd"), 20)
	_add_icon(ui, "berry", Rect2(944, 49, 42, 42))
	UI.label(ui, "TREAT POUCH", Rect2(992, 46, 115, 19), 12, UI.MUTED)
	pocket_label = UI.label(ui, "11 treats", Rect2(992, 66, 117, 31), 22)
	UI.button(ui, "···", Rect2(1140, 48, 66, 51), open_settings).add_theme_font_size_override("font_size", 30)
	UI.label(ui, "PIP'S LITTLE PLACE", Rect2(70, 154, 270, 27), 14, UI.GREEN)
	UI.panel(ui, Rect2(70, 201, 230, 138), Color(0.99, 0.98, 0.92, 0.79), 18)
	UI.label(ui, "Make yourself at home", Rect2(86, 213, 200, 29), 19)
	UI.label(ui, "01   Tap Pip's head\n02   Hold + drag to pick up\n03   Play to earn treats", Rect2(86, 247, 201, 76), 16, UI.MUTED)
	discoveries_label = UI.label(ui, "0 little discoveries", Rect2(85, 344, 230, 28), 16, UI.GREEN)
	UI.panel(ui, Rect2(561, 624, 158, 27), Color(0.99, 0.98, 0.91, 0.8), 13)
	status_label = UI.label(ui, "Pip · feeling cozy", Rect2(565, 624, 150, 27), 14, UI.GREEN, true)
	# Navigation buttons include custom vector icons and descriptive sublabels.
	_nav_button("Feed Critter", "A tiny snack, a happy hamster", "berry", 48, 367, open_feed, false)
	_nav_button("Mini Games / Quizzes", "Play a little. Learn a lot.", "game", 431, 418, open_games, true)
	journal_button = _nav_button("Knowledge", "Your book of discoveries", "book", 865, 367, open_knowledge, false)
	UI.label(ui, "CLICK to pet  ·  HOLD + DRAG to carry  ·  ESC to return home", Rect2(70, 774, 845, 21), 12, UI.MUTED)
	UI.label(ui, "Made for curious little minds", Rect2(926, 774, 306, 21), 12, UI.MUTED)
	# Speech is created last so it floats above the room's labels.
	speech = UI.panel(ui, Rect2(427, 209, 426, 173), UI.CREAM, 22, true)
	speech_tail = Polygon2D.new()
	speech_tail.polygon = PackedVector2Array([Vector2(194, 170), Vector2(222, 170), Vector2(209, 185)])
	speech_tail.color = UI.CREAM
	speech.add_child(speech_tail)
	speech_title = UI.label(speech, "", Rect2(21, 12, 385, 24), 14, UI.GREEN)
	speech_text = UI.label(speech, "", Rect2(21, 40, 384, 102), 19)
	speech_hint = UI.label(speech, "", Rect2(21, 145, 384, 19), 12, UI.MUTED)
	speech_click = UI.button(speech, "", Rect2(0, 0, 426, 173), func():
		if not speech_key.is_empty():
			open_knowledge(speech_key)
		else:
			speech_life = 0)
	for state in ["normal", "hover", "pressed", "focus"]:
		speech_click.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	toast_label = UI.label(ui, "", Rect2(354, 148, 572, 38), 17, UI.GREEN, true)

func _meter(title: String, x: float, color: Color) -> ProgressBar:
	var l = UI.label(ui, title, Rect2(x, 42, 163, 28), 17)
	if title == "Fullness":
		fullness_label = l
	else:
		happiness_label = l
	var bar = ProgressBar.new()
	bar.position = Vector2(x, 79)
	bar.size = Vector2(160, 11)
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background", UI.style(Color("e7e4d7"), 6))
	bar.add_theme_stylebox_override("fill", UI.style(color, 6))
	ui.add_child(bar)
	bar.size = Vector2(160, 11)
	return bar

func _nav_button(title: String, sub: String, icon: String, x: float, width: float, action: Callable, primary: bool) -> Button:
	var button = UI.button(ui, "", Rect2(x, 686, width, 79), action, primary)
	_add_icon(button, icon, Rect2(21, 16, 45, 45))
	UI.label(button, title, Rect2(83, 9, width-96, 34), 23, UI.CREAM if primary else UI.INK)
	UI.label(button, sub, Rect2(83, 45, width-96, 24), 14, Color("d7e4d0") if primary else UI.MUTED)
	button.tooltip_text = title
	return button

func _add_icon(parent: Node, kind: String, rect: Rect2) -> Control:
	var icon = Icon.new()
	icon.kind = kind
	icon.position = rect.position
	icon.size = rect.size
	parent.add_child(icon)
	return icon

func _process(delta: float) -> void:
	if not is_instance_valid(ui):
		return
	toast_time = maxf(0, toast_time-delta)
	toast_label.visible = toast_time > 0
	if modal_name.is_empty():
		start_time += delta
		progress.fullness = maxf(0, progress.fullness - delta * 0.06)
		progress.happiness = maxf(0, progress.happiness - delta * 0.025)
		if start_time > 2.0 and not progress.discovered.has("idle"):
			learn("idle")
		if speech.visible and not speech.get_global_rect().has_point(ui.get_global_mouse_position()):
			speech_life -= delta
		if speech_life <= 0:
			if not speech_queue.is_empty():
				_show_lesson(speech_queue.pop_front())
			else:
				speech.visible = false
		# The bubble tracks Pip's head but stays entirely inside the room.
		var bubble_y = pip.position.y - 312
		if bubble_y < 183:
			bubble_y = minf(443, pip.position.y + 113)
			speech_tail.polygon = PackedVector2Array([Vector2(194, 2), Vector2(222, 2), Vector2(209, -13)])
		else:
			speech_tail.polygon = PackedVector2Array([Vector2(194, 170), Vector2(222, 170), Vector2(209, 185)])
		var desired = Vector2(clampf(pip.position.x - 213, 70, 788), bubble_y)
		speech.position = speech.position.lerp(desired, minf(1.0, delta * 12))
		_refresh_home()
	if loop_running and modal_name == "loop":
		loop_clock += delta
		if loop_clock >= 0.45:
			loop_clock = 0.0
			loop_step += 1
			loop_marker.position.x = 258 + loop_step * 116
			_play_sound("step")
			if loop_step >= loop_count:
				_finish_loop_run()
	save_time += delta
	if save_time >= 30:
		save_time = 0
		_save()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			close_modal()
		elif modal_name.is_empty():
			match event.keycode:
				KEY_F: open_feed()
				KEY_M: open_games()
				KEY_K: open_knowledge()
				KEY_P: pip.pet()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if is_instance_valid(ui):
			_save()

func _refresh_home() -> void:
	fullness_bar.value = progress.fullness
	happiness_bar.value = progress.happiness
	fullness_label.text = "Fullness  %d" % roundi(progress.fullness)
	happiness_label.text = "Happiness  %d" % roundi(progress.happiness)
	pocket_label.text = "%d treats" % (progress.inventory.berry + progress.inventory.seed + progress.inventory.carrot)
	discoveries_label.text = "%d / %d little discoveries" % [progress.discovered.size(), Lessons.ORDER.size()]
	status_label.text = "Pip · " + (pip.direction if pip.is_held or pip.is_falling else ("snack time" if pip.eating_time > 0 else "feeling cozy"))

func _on_interaction(action: String) -> void:
	match action:
		"pet":
			progress.pet_count += 1
			progress.happiness = minf(100, progress.happiness + 8)
			learn("events" if progress.pet_count == 1 else "variables")
			_play_sound("pet")
		"pickup":
			learn("boolean")
			_play_sound("pickup")
		"move": learn("vectors")
		"drop": learn("gravity")
		"put_down": learn("boolean")
		"land": _play_sound("land")
		"groom": learn("timer")
		"chew_done": learn("loops")
		"feed":
			learn("condition" if progress.feed_count == 1 else "functions")
			_play_sound("eat")
		"body_click":
			_toast("Tap my head for a pet. Hold anywhere on me to pick me up!")
	_refresh_home()
	_save()

func learn(key: String) -> void:
	if not Lessons.DATA.has(key) or speech_queue.has(key):
		return
	if progress.discovered.has(key):
		if speech_queue.is_empty() and (not speech.visible or speech_life < 1.0) and modal_name.is_empty():
			_show_lesson(key, false)
		return
	speech_queue.append(key)
	# Finish the current bubble before presenting the next lesson.
	if not speech.visible:
		speech_life = 0

func _show_lesson(key: String, is_new: bool = true) -> void:
	var lesson = Lessons.DATA[key]
	var newly_unlocked = progress.unlock(key)
	_say(("NEW DISCOVERY · " if newly_unlocked else "LITTLE REMINDER · ") + lesson.tag, lesson.bubble, 13.0)
	speech_key = key
	speech_hint.text = "Saved to Knowledge · click to explore · hover to keep reading"
	if newly_unlocked and is_new:
		_toast("New discovery: " + lesson.title)
		_play_sound("learn")
	_refresh_home()
	_save()

func _say(title: String, words: String, duration: float = 8.0) -> void:
	speech_title.text = title
	speech_text.text = words
	speech_hint.text = "Hover to keep reading"
	speech_key = ""
	speech_life = duration
	speech.visible = true

func _toast(message: String) -> void:
	toast_label.text = message
	toast_time = 4.0

func _save() -> void:
	if progress.write() != OK and is_instance_valid(toast_label):
		_toast("Progress could not be saved. Check that your user folder is writable.")

func _play_sound(kind: String) -> void:
	if not progress.sound or not is_instance_valid(audio):
		return
	var path = "res://assets/audio/" + kind + ".wav"
	if ResourceLoader.exists(path):
		audio.stream = load(path)
		audio.play()

func _screen(id: String, title: String, subtitle: String) -> Control:
	if is_instance_valid(overlay):
		overlay.hide()
		overlay.queue_free()
	loop_running = false
	if pip.is_held:
		pip.release()
	pip.pointer_down = false
	pip.blocked = true
	modal_name = id
	overlay = Control.new()
	overlay.name = "Screen_" + id
	overlay.size = Vector2(1280, 800)
	ui.add_child(overlay)
	var dim = ColorRect.new()
	dim.color = Color(0.19, 0.25, 0.19, 0.33)
	dim.size = Vector2(1280, 800)
	overlay.add_child(dim)
	UI.panel(overlay, Rect2(112, 94, 1056, 655), UI.CREAM, 28, true)
	UI.label(overlay, title, Rect2(151, 119, 840, 50), 34)
	UI.label(overlay, subtitle, Rect2(154, 174, 900, 30), 17, UI.MUTED)
	UI.button(overlay, "Close  ×", Rect2(1020, 120, 113, 43), close_modal)
	return overlay

func close_modal() -> void:
	if is_instance_valid(overlay):
		overlay.hide()
		overlay.queue_free()
	modal_name = ""
	pip.blocked = false
	loop_running = false
	_refresh_home()
	_save()

func open_feed() -> void:
	_screen("feed", "A little something delicious", "Your treat pouch · earn refills by playing mini games and quizzes.")
	var kinds = ["berry", "seed", "carrot"]
	var titles = ["Garden berries", "Sunflower seed", "Carrot nibble"]
	var descriptions = ["A sweet little reward.\n+14 fullness · +5 happiness", "A pocket-sized favorite.\n+9 fullness · +5 happiness", "Crunch, crunch, happy.\n+20 fullness · +5 happiness"]
	for i in range(3):
		var x = 152 + i*330
		var kind: String = kinds[i]
		UI.panel(overlay, Rect2(x, 232, 316, 334), [Color("f5e7e5"),Color("efedda"),Color("f5e9d6")][i], 20)
		_add_icon(overlay, kind, Rect2(x+114, 252, 88, 88))
		UI.label(overlay, titles[i], Rect2(x+10, 355, 296, 33), 25, UI.INK, true)
		UI.label(overlay, descriptions[i], Rect2(x+16, 400, 284, 60), 17, UI.MUTED, true)
		var count: int = progress.inventory[kind]
		var btn = UI.button(overlay, "Offer one · %d left" % count, Rect2(x+26, 491, 264, 51), func(): _feed(kind), true)
		btn.disabled = count <= 0 or progress.fullness >= 95 or pip.eating_time > 0
	var tip = "Choose a treat and Pip will eat it back in the room."
	if progress.fullness >= 95:
		tip = "Pip is full and cozy. A mini-game win builds his appetite for another snack."
	elif pip.eating_time > 0:
		tip = "Pip is still chewing. Return home and let him finish his little snack."
	UI.label(overlay, tip, Rect2(170, 587, 940, 46), 19, UI.GREEN, true)
	UI.button(overlay, "Earn more treats", Rect2(497, 659, 286, 51), open_games)

func _feed(kind: String) -> void:
	if pip.eating_time > 0:
		return
	if progress.feed(kind):
		close_modal()
		pip.eat(kind)
		_toast("One %s for Pip. Happy snacking!" % kind)
		_save()
	else:
		learn("condition")
		open_feed()

func open_knowledge(selected: String = "") -> void:
	_screen("knowledge", "The little book of discoveries", "%d / %d lessons discovered · learn by doing, then revisit it here." % [progress.discovered.size(), Lessons.ORDER.size()])
	if progress.discovered.is_empty():
		_add_icon(overlay, "book", Rect2(579, 276, 120, 120))
		UI.label(overlay, "Your story starts with a little curiosity", Rect2(200, 421, 880, 44), 27, UI.INK, true)
		UI.label(overlay, "Watch Pip idle, pet his head, or hold and drag him.\nA lesson joins this book when its bubble appears.", Rect2(240, 482, 800, 73), 21, UI.MUTED, true)
		UI.button(overlay, "Let's explore", Rect2(500, 606, 280, 52), close_modal, true)
		return
	if not progress.discovered.has(selected):
		selected = progress.discovered.back()
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(148, 225)
	scroll.size = Vector2(310, 470)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	overlay.add_child(scroll)
	var list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)
	for key in Lessons.ORDER:
		if not progress.discovered.has(key):
			continue
		var b = UI.button(list, Lessons.DATA[key].title, Rect2(0, 0, 285, 50), func(): open_knowledge(key), key == selected)
		b.custom_minimum_size = Vector2(285, 52)
		b.add_theme_font_size_override("font_size", 17)
		if key == selected:
			_reveal_journal_entry(scroll, b)
	var lesson = Lessons.DATA[selected]
	UI.panel(overlay, Rect2(486, 224, 642, 478), Color("f5f3e9"), 20)
	UI.label(overlay, lesson.tag + "  /  " + lesson.trigger, Rect2(511, 239, 590, 28), 14, UI.GREEN)
	UI.label(overlay, lesson.title, Rect2(511, 276, 590, 48), 29)
	var body = UI.label(overlay, lesson.body, Rect2(513, 334, 583, 195), 18)
	body.name = "JournalBody"
	body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	body.add_theme_constant_override("line_spacing", -2)
	UI.code(overlay, lesson.code, Rect2(511, 541, 592, 118), 17)
	UI.label(overlay, "Simplified GDScript · the same idea used in Pip's behavior", Rect2(513, 669, 582, 23), 13, UI.MUTED)

func _reveal_journal_entry(scroll: ScrollContainer, entry: Button) -> void:
	await get_tree().process_frame
	if is_instance_valid(scroll) and is_instance_valid(entry):
		scroll.ensure_control_visible(entry)

func open_games() -> void:
	_screen("games", "Play a little. Learn a lot.", "Three little adventures · no time pressure · every win brings treats home.")
	var cards = [
		["berry", "Berry Detective", "Sort a basket using if / else\nand AND rules.", "10 finds · win with 7 correct", "+5 berries  +2 seeds"],
		["paw", "Loop Garden", "Help a little marker cross the\nstepping stones with a loop.", "3 gardens · retry as you learn", "+4 berries  +3 seeds  +1 carrot"],
		["book", "Pip's Pop Quiz", "A quiz about discoveries\nyou've already encountered.", "Up to 5 questions · win with 60%", "+2 berries per correct answer"]]
	for i in range(3):
		var x = 151 + i*330
		UI.panel(overlay, Rect2(x, 234, 317, 361), [Color("f5e7e5"),Color("e8eddc"),Color("f2eada")][i], 20)
		_add_icon(overlay, cards[i][0], Rect2(x+20, 255, 59, 59))
		UI.label(overlay, cards[i][1], Rect2(x+20, 326, 280, 43), 25)
		UI.label(overlay, cards[i][2], Rect2(x+20, 380, 280, 61), 18)
		UI.label(overlay, cards[i][3], Rect2(x+20, 451, 280, 35), 14, UI.MUTED)
		UI.label(overlay, cards[i][4], Rect2(x+20, 489, 280, 27), 14, UI.GREEN)
		var action = [start_sort, start_loop, start_quiz][i]
		var b = UI.button(overlay, "Let's play" if i < 2 else "Start quiz", Rect2(x+20, 533, 276, 44), action, true)
		if i == 2 and progress.discovered.is_empty():
			b.text = "Discover a lesson first"
			b.disabled = true
	var score_text = "Your best moments will appear here. Try your first adventure!"
	if not progress.scores.is_empty():
		var entries: Array[String] = []
		for i in range(progress.scores.size()):
			entries.append("%d. %s %d%%" % [i+1, progress.scores[i].mode, progress.scores[i].score])
		score_text = "    ·    ".join(entries)
	UI.label(overlay, "YOUR LOCAL TOP 3", Rect2(166, 619, 955, 27), 13, UI.GREEN, true)
	UI.label(overlay, score_text, Rect2(166, 652, 955, 42), 17, UI.MUTED, true)

func start_quiz() -> void:
	quiz_keys = Lessons.quiz_pool(progress.discovered)
	if quiz_keys.is_empty():
		open_games()
		return
	quiz_index = 0
	quiz_score = 0
	session_rewarded = false
	_quiz_question()

func _quiz_question() -> void:
	_screen("quiz", "Pip's Pop Quiz", "Only your discovered lessons · question %d of %d" % [quiz_index+1, quiz_keys.size()])
	answer_locked = false
	quiz_answer_buttons.clear()
	var lesson = Lessons.DATA[quiz_keys[quiz_index]]
	UI.label(overlay, lesson.tag, Rect2(173, 222, 925, 27), 14, UI.GREEN)
	UI.label(overlay, lesson.question, Rect2(173, 262, 924, 86), 28)
	var options: Array = []
	for i in range(lesson.choices.size()):
		options.append({"text":lesson.choices[i], "correct":i == lesson.answer})
	options.shuffle()
	for i in range(options.size()):
		var option: Dictionary = options[i]
		var b = UI.button(overlay, "%s    %s" % [char(65+i), option.text], Rect2(174, 371+i*65, 932, 54), func(): _answer_quiz(option.correct, lesson.why))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 20)
		b.set_meta("correct", option.correct)
		quiz_answer_buttons.append(b)
	game_feedback = UI.label(overlay, "Take your time. Think about what you and Pip tried together.", Rect2(174, 573, 932, 66), 19, UI.MUTED)
	next_button = UI.button(overlay, "Next question  →" if quiz_index < quiz_keys.size()-1 else "See how you did  →", Rect2(794, 656, 312, 51), _next_quiz, true)
	next_button.disabled = true
	UI.label(overlay, "%d correct so far" % quiz_score, Rect2(174, 660, 580, 40), 17, UI.MUTED)

func _answer_quiz(correct: bool, explanation: String) -> void:
	if answer_locked:
		return
	answer_locked = true
	if correct:
		quiz_score += 1
	for b in quiz_answer_buttons:
		b.disabled = true
		if b.get_meta("correct"):
			b.add_theme_stylebox_override("disabled", UI.style(Color("dcebd2"), 15, Color("8ba67a")))
			b.add_theme_color_override("font_disabled_color", UI.GREEN)
	game_feedback.text = ("You got it! " if correct else "A little learning moment. ") + explanation
	game_feedback.add_theme_color_override("font_color", UI.GREEN if correct else UI.ORANGE)
	next_button.disabled = false
	_play_sound("correct" if correct else "try")

func _next_quiz() -> void:
	if not answer_locked:
		return
	quiz_index += 1
	if quiz_index >= quiz_keys.size():
		var percent = roundi(float(quiz_score)/quiz_keys.size()*100)
		var won = percent >= 60
		_result("Pop Quiz", percent, won, quiz_score*2 if won else 0, 1 if won else 0, 0,
			"%d of %d correct. %s" % [quiz_score, quiz_keys.size(), "Pip is proud of your discoveries!" if won else "Revisit your Knowledge book, then try again."])
	else:
		_quiz_question()

func start_sort() -> void:
	sort_items = ["berry", "stone", "blueberry", "button", "berry", "blueberry", "berry", "button", "stone", "berry"]
	# Shuffle the first and second halves separately: the AND half always
	# contains a berry, a blue berry, and a red non-berry.
	var first = sort_items.slice(0, 5)
	var second = sort_items.slice(5, 10)
	first.shuffle()
	second.shuffle()
	sort_items = first + second
	sort_index = 0
	sort_score = 0
	session_rewarded = false
	_sort_question()

func _sort_question() -> void:
	_screen("sort", "Berry Detective", "Look at the rule. Decide whether this find belongs in the basket. No timer!")
	answer_locked = false
	sort_rule_and = sort_index >= 5
	var rule = "is_berry and is_red" if sort_rule_and else "is_berry"
	UI.panel(overlay, Rect2(154, 234, 401, 339), Color("e9efdf"), 20)
	UI.label(overlay, "THE BASKET RULE", Rect2(178, 256, 350, 29), 14, UI.GREEN)
	UI.code(overlay, "if %s:\n    basket()\nelse:\n    leave_it()" % rule, Rect2(176, 305, 356, 136), 18)
	UI.label(overlay, "Both checks must be true." if sort_rule_and else "A berry passes. Other finds do not.", Rect2(179, 461, 351, 77), 20)
	UI.panel(overlay, Rect2(580, 234, 545, 339), Color("f5eddf"), 20)
	var kind: String = sort_items[sort_index]
	_add_icon(overlay, kind, Rect2(797, 264, 112, 112))
	var names = {"berry":"A red berry", "blueberry":"A blue berry", "stone":"A gray pebble", "button":"A red button"}
	UI.label(overlay, names[kind], Rect2(606, 388, 493, 45), 28, UI.INK, true)
	UI.label(overlay, "Find %d of 10  ·  %d correct" % [sort_index+1, sort_score], Rect2(606, 443, 493, 32), 16, UI.MUTED, true)
	quiz_answer_buttons.clear()
	quiz_answer_buttons.append(UI.button(overlay, "Into the basket", Rect2(604, 498, 244, 51), func(): _answer_sort(true), true))
	quiz_answer_buttons.append(UI.button(overlay, "Leave it", Rect2(862, 498, 239, 51), func(): _answer_sort(false)))
	game_feedback = UI.label(overlay, "Read the rule on every round. The rule changes halfway through!", Rect2(174, 587, 932, 61), 19, UI.MUTED)
	next_button = UI.button(overlay, "Next find  →" if sort_index < 9 else "Open your basket  →", Rect2(799, 660, 307, 51), _next_sort, true)
	next_button.disabled = true
	UI.label(overlay, "7 / 10 correct earns the reward", Rect2(174, 664, 600, 39), 17, UI.MUTED)

func _answer_sort(chose_basket: bool) -> void:
	if answer_locked:
		return
	answer_locked = true
	var kind: String = sort_items[sort_index]
	var is_berry = kind in ["berry", "blueberry"]
	var is_red = kind in ["berry", "button"]
	var passes = (is_berry and is_red) if sort_rule_and else is_berry
	var correct = chose_basket == passes
	if correct:
		sort_score += 1
	for b in quiz_answer_buttons:
		b.disabled = true
	var explanation = "is_berry = %s" % ("true" if is_berry else "false")
	if sort_rule_and:
		explanation += ", is_red = %s" % ("true" if is_red else "false")
	game_feedback.text = ("Good detective work! " if correct else "Let's check it together. ") + explanation + (". The rule passes: basket!" if passes else ". The rule fails: leave it.")
	game_feedback.add_theme_color_override("font_color", UI.GREEN if correct else UI.ORANGE)
	next_button.disabled = false
	# Discovery occurs when the explanatory feedback is actually visible.
	if sort_rule_and:
		_discover_in_game("and")
	_play_sound("correct" if correct else "try")

func _next_sort() -> void:
	if not answer_locked:
		return
	sort_index += 1
	if sort_index >= 10:
		var won = sort_score >= 7
		_result("Berry Detective", sort_score*10, won, 5 if won else 0, 2 if won else 0, 0, "%d / 10 finds sorted correctly. %s" % [sort_score, "That's a very clever basket!" if won else "Try again and check both parts of each rule."])
	else:
		_sort_question()

func start_loop() -> void:
	loop_round = 0
	loop_attempts = 0
	session_rewarded = false
	loop_targets = [3, 4, 5]
	loop_targets.shuffle()
	_loop_garden()

func _loop_garden() -> void:
	_screen("loop", "Loop Garden", "Garden %d of 3 · choose a repeat count to reach the golden star." % [loop_round+1])
	loop_count = 1
	loop_step = 0
	loop_clock = 0
	loop_buttons.clear()
	UI.panel(overlay, Rect2(154, 224, 972, 225), Color("e7efde"), 20)
	UI.label(overlay, "ONE REPEAT = ONE STEP TO THE RIGHT", Rect2(180, 244, 920, 30), 14, UI.GREEN, true)
	for i in range(7):
		var x = 247 + i*116
		UI.panel(overlay, Rect2(x, 352, 91, 43), Color("c5cbb6"), 22)
		UI.label(overlay, "START" if i == 0 else str(i), Rect2(x, 399, 91, 25), 14, UI.MUTED, true)
		if i == loop_targets[loop_round]:
			_add_icon(overlay, "star", Rect2(x+20, 299, 51, 51))
	loop_marker = UI.panel(overlay, Rect2(258, 305, 65, 65), Color("fff7df"), 32, true)
	_add_icon(loop_marker, "paw", Rect2(14, 11, 38, 38))
	UI.label(overlay, "Repeat", Rect2(178, 478, 120, 37), 22)
	loop_buttons.append(UI.button(overlay, "−", Rect2(301, 473, 54, 48), func(): _change_loop(-1)))
	loop_count_label = UI.label(overlay, "1", Rect2(365, 473, 61, 48), 29, UI.INK, true)
	loop_buttons.append(UI.button(overlay, "+", Rect2(436, 473, 54, 48), func(): _change_loop(1)))
	loop_code_label = UI.code(overlay, "", Rect2(549, 467, 552, 104), 19)
	_update_loop_code()
	loop_buttons.append(UI.button(overlay, "Run my loop  →", Rect2(178, 536, 312, 52), _run_loop, true))
	game_feedback = UI.label(overlay, "Count from START to the star. Try any count, watch what happens, then adjust it.", Rect2(178, 606, 920, 61), 19, UI.MUTED)
	next_button = UI.button(overlay, "Next garden  →" if loop_round < 2 else "Collect your treats  →", Rect2(788, 675, 312, 47), _next_loop, true)
	next_button.visible = false

func _change_loop(amount: int) -> void:
	if loop_running:
		return
	loop_count = clampi(loop_count + amount, 1, 6)
	_update_loop_code()

func _update_loop_code() -> void:
	loop_count_label.text = str(loop_count)
	loop_code_label.text = "for step in range(%d):\n    move_one_stone_right()" % loop_count

func _run_loop() -> void:
	if loop_running:
		return
	loop_attempts += 1
	loop_running = true
	loop_step = 0
	loop_clock = 0.0
	loop_marker.position.x = 258
	for b in loop_buttons:
		b.disabled = true
	game_feedback.text = "Running your loop... one repeat, one step."

func _finish_loop_run() -> void:
	loop_running = false
	var reached = loop_step == loop_targets[loop_round]
	if reached:
		game_feedback.text = "%d repeats = %d steps. You reached the star!" % [loop_count, loop_step]
		next_button.visible = true
		_play_sound("correct")
	else:
		game_feedback.text = "You moved %d steps. The star is %d steps away. Change the repeat count and try again!" % [loop_step, loop_targets[loop_round]]
		for b in loop_buttons:
			b.disabled = false
		_play_sound("try")
	game_feedback.add_theme_color_override("font_color", UI.GREEN if reached else UI.ORANGE)
	_discover_in_game("repeat")

func _next_loop() -> void:
	if loop_running or loop_step != loop_targets[loop_round]:
		return
	loop_round += 1
	if loop_round >= 3:
		var score = maxi(60, 100-(loop_attempts-3)*5)
		_result("Loop Garden", score, true, 4, 3, 1, "Three gardens, three working loops. You tested your code and helped it grow!")
	else:
		_loop_garden()

func _discover_in_game(key: String) -> void:
	# Mini-game feedback already shows the concept, so it is now encountered.
	if progress.unlock(key):
		speech_queue.erase(key)
		_save()
		_refresh_home()

func _result(mode: String, points: int, won: bool, berries: int, seeds: int, carrots: int, message: String) -> void:
	if session_rewarded:
		return
	session_rewarded = true
	if won:
		progress.reward(mode, points, berries, seeds, carrots)
		_save()
	_screen("result", "A little win for a big thinker!" if won else "Every try teaches you something", mode + " · " + str(points) + "%")
	_add_icon(overlay, "star" if won else "book", Rect2(581, 238, 118, 118))
	UI.label(overlay, message, Rect2(215, 388, 850, 86), 27, UI.INK, true)
	if won:
		var reward = "+%d berries   +%d seeds" % [berries, seeds]
		if carrots > 0:
			reward += "   +%d carrot" % carrots
		UI.panel(overlay, Rect2(322, 503, 636, 74), Color("e7efdc"), 20)
		UI.label(overlay, reward + "\nAlready tucked into your treat pouch", Rect2(338, 510, 604, 59), 20, UI.GREEN, true)
	else:
		UI.label(overlay, "Win the next round to earn treats. Pip is cheering you on!", Rect2(225, 507, 830, 61), 20, UI.MUTED, true)
	UI.button(overlay, "Play something else", Rect2(271, 640, 350, 54), open_games)
	UI.button(overlay, "Back to Pip", Rect2(655, 640, 350, 54), close_modal, true)
	_play_sound("win" if won else "try")

func open_settings() -> void:
	_screen("settings", "Make yourself comfortable", "A calm place to play, learn, and care for a tiny friend.")
	UI.panel(overlay, Rect2(151, 231, 978, 131), Color("eef0e5"), 20)
	UI.label(overlay, "Little sound effects", Rect2(181, 247, 625, 38), 25)
	UI.label(overlay, "Soft clicks, happy chimes, and tiny footsteps.", Rect2(182, 294, 649, 36), 19, UI.MUTED)
	UI.button(overlay, "Sound: " + ("on" if progress.sound else "off"), Rect2(878, 269, 215, 50), func():
		progress.sound = not progress.sound
		_save()
		open_settings())
	UI.panel(overlay, Rect2(151, 380, 978, 131), Color("f3eddf"), 20)
	UI.label(overlay, "Gentler movement", Rect2(181, 396, 625, 38), 25)
	UI.label(overlay, "Less swinging and breathing motion, with no landing bounce.", Rect2(182, 443, 658, 36), 19, UI.MUTED)
	UI.button(overlay, "Gentle: " + ("on" if progress.calm else "off"), Rect2(878, 418, 215, 50), func():
		progress.calm = not progress.calm
		pip.calm = progress.calm
		_save()
		open_settings())
	UI.label(overlay, "Progress saves automatically on this device.\nPip's needs pause while you're away or in a menu. There is no game over.", Rect2(180, 541, 920, 75), 20, UI.MUTED, true)
	UI.label(overlay, "Keyboard helpers: P pet · F feed · M mini games · K knowledge · Esc close\nUse Tab and Enter to move through and activate buttons.", Rect2(180, 637, 920, 58), 16, UI.GREEN, true)
