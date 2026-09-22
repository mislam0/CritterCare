extends Node2D
## Main coordinator: care UI, lesson queue, inventory, mini games, and quizzes.
## Save data and learning content are separated so they are easy to extend.

const UI = preload("res://scripts/ui.gd")
const SaveData = preload("res://scripts/save_data.gd")
const Lessons = preload("res://data/lessons.gd")
const Curriculum = preload("res://data/curriculum.gd")
const Shop = preload("res://data/shop.gd")
const CosmeticArt = preload("res://scripts/cosmetic_art.gd")
const Picnic = preload("res://scripts/picnic.gd")
const Tutorial = preload("res://scripts/tutorial.gd")
var tutorial
var picnic
var picnic_count: Label
var picnic_streak: Label
var picnic_hint: Label
var picnic_pause: Button
var picnic_start: Button
var coin_label: Label
var shop_category: String = "pet"
var shop_notice: String = "Earn coins by completing games. Buy once, equip whenever you like."
var session_stage: int = 0
var loop_start: int = 0
var loop_stride: int = 1
var loop_inner: int = 0
var loop_value: int = 0
var loop_live_label: Label
var intro_keys: Array = []
var intro_index: int = 0
var intro_action: Callable
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
var speech_full_text: String = ""
var speech_pages: Array[String] = []
var speech_page_index: int = 0
var speech_next: Button
var speech_back: Button
var speech_book: Button
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
	_apply_cosmetics()
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
	tutorial = Tutorial.new()
	tutorial.game = self
	ui.add_child(tutorial)
	if not progress.tutorial_completed:
		start_tutorial()
	elif progress.discovered.size() > 0:
		_say("Welcome back!", "Your discoveries and purchases are saved. Visit Shop at the bottom to dress me up, or try Picnic Catch in Games / Quizzes!")
	else:
		_say("Hello, I'm Pip!", "Click my head to pet me, or hold and drag to pick me up. Play games for coins, then tap Shop for hats and room decorations!")

func _build_home() -> void:
	var logo = TextureRect.new()
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.texture = preload("res://assets/icon.svg")
	logo.position = Vector2(48, 37)
	logo.size = Vector2(66, 66)
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(logo)
	UI.label(ui, "CritterCare", Rect2(128, 25, 266, 62), 34, UI.INK)
	UI.label(ui, "Little moments. Big discoveries.", Rect2(130, 82, 268, 26), 15, UI.MUTED)
	var wallet = UI.panel(ui, Rect2(405, 38, 129, 70), Color("f3e4b9"), 20)
	wallet.name = "GoldBalance"
	_add_icon(wallet, "coin", Rect2(12, 10, 27, 27))
	UI.label(wallet, "GOLD", Rect2(46, 10, 73, 25), 13, UI.MUTED)
	coin_label = UI.label(wallet, "0", Rect2(9, 35, 111, 30), 21, UI.GREEN, true)
	fullness_bar = _meter("Fullness", 556, Color("d6ac68"))
	happiness_bar = _meter("Happiness", 740, Color("bf8290"))
	UI.panel(ui, Rect2(930, 38, 190, 70), Color("ececdd"), 20)
	_add_icon(ui, "berry", Rect2(944, 49, 42, 42))
	UI.label(ui, "TREAT POUCH", Rect2(992, 46, 115, 19), 12, UI.MUTED)
	pocket_label = UI.label(ui, "11 treats", Rect2(992, 66, 117, 31), 22)
	var settings_button = UI.button(ui, "···", Rect2(1140, 48, 66, 51), open_settings)
	settings_button.name = "SettingsButton"
	settings_button.add_theme_font_size_override("font_size", 30)
	UI.label(ui, "PIP'S LITTLE PLACE", Rect2(70, 154, 270, 27), 14, UI.GREEN)
	UI.panel(ui, Rect2(70, 201, 230, 138), Color(0.99, 0.98, 0.92, 0.79), 18)
	UI.label(ui, "Make yourself at home", Rect2(86, 213, 200, 29), 19)
	UI.label(ui, "01   Tap Pip's head\n02   Hold + drag to pick up\n03   Shop for a new look", Rect2(86, 247, 201, 76), 16, UI.MUTED)
	discoveries_label = UI.label(ui, "0 little discoveries", Rect2(85, 344, 230, 28), 16, UI.GREEN)
	UI.panel(ui, Rect2(561, 624, 158, 27), Color(0.99, 0.98, 0.91, 0.8), 13)
	status_label = UI.label(ui, "Pip · feeling cozy", Rect2(565, 624, 150, 27), 14, UI.GREEN, true)
	# Navigation buttons include custom vector icons and descriptive sublabels.
	_nav_button("Feed Critter", "A snack for Pip", "berry", 48, 271, open_feed, false).name = "FeedNav"
	_nav_button("Games / Quizzes", "Learn + earn coins", "game", 335, 338, open_games, true).name = "GamesNav"
	journal_button = _nav_button("Knowledge", "Your discoveries", "book", 689, 271, open_knowledge, false)
	var shop_nav = _nav_button("Shop", "Dress + decorate", "shop", 976, 256, open_shop, false)
	shop_nav.name = "ShopNav"
	_style_shop_button(shop_nav)
	UI.label(ui, "CLICK to pet  ·  HOLD + DRAG to carry  ·  ESC to return home", Rect2(70, 774, 845, 21), 12, UI.MUTED)
	UI.label(ui, "v%s · Guided first play" % ProjectSettings.get_setting("application/config/version"), Rect2(926, 774, 306, 21), 12, UI.MUTED)
	# Speech is created last so it floats above the room's labels.
	speech = UI.panel(ui, Rect2(410, 181, 460, 205), UI.CREAM, 22, true)
	speech.name = "PipSpeech"
	speech_tail = Polygon2D.new()
	speech_tail.color = UI.CREAM
	speech.add_child(speech_tail)
	speech_title = UI.label(speech, "", Rect2(20, 9, 420, 25), 14, UI.GREEN)
	speech_text = UI.label(speech, "", Rect2(20, 38, 420, 106), 18)
	speech_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	speech_hint = UI.label(speech, "", Rect2(20, 146, 420, 17), 11, UI.MUTED)
	speech_click = UI.button(speech, "", Rect2(0, 0, 460, 144), func():
		if not speech_key.is_empty():
			open_knowledge(speech_key)
		else:
			_advance_speech())
	for state in ["normal", "hover", "pressed", "focus"]:
		speech_click.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	speech_book = UI.button(speech, "Knowledge", Rect2(20, 168, 143, 29), func(): open_knowledge(speech_key))
	speech_book.name = "ReadInKnowledge"
	speech_back = UI.button(speech, "Back", Rect2(251, 168, 73, 29), func(): _show_speech_page(speech_page_index-1))
	speech_back.name = "SpeechBack"
	speech_next = UI.button(speech, "Done", Rect2(332, 168, 108, 29), _advance_speech, true)
	speech_next.name = "SpeechNext"
	for b in [speech_book, speech_back, speech_next]:
		b.add_theme_font_size_override("font_size", 14)
	toast_label = UI.label(ui, "", Rect2(319, 111, 724, 24), 14, UI.GREEN, true)

func _style_shop_button(button: Button) -> void:
	button.tooltip_text = "Shop · pet accessories and room decorations (S)"
	button.add_theme_stylebox_override("normal", UI.style(Color("f3d896"), 18, Color("c29b49")))
	button.add_theme_stylebox_override("hover", UI.style(Color("ffe8ae"), 18, Color("a57c31")))
	button.add_theme_stylebox_override("pressed", UI.style(Color("dfc078"), 18))

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
	_add_icon(button, icon, Rect2(17, 20, 40, 40))
	UI.label(button, title, Rect2(72, 9, width-81, 34), 21, UI.CREAM if primary else UI.INK)
	UI.label(button, sub, Rect2(72, 45, width-81, 24), 13, Color("d7e4d0") if primary else UI.MUTED)
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
		if not _tutorial_active():
			start_time += delta
			progress.fullness = maxf(0, progress.fullness - delta * 0.06)
			progress.happiness = maxf(0, progress.happiness - delta * 0.025)
			if start_time > 2.0 and not progress.discovered.has("idle"):
				learn("idle")
		# Keep every page until the player chooses Next or Done. Reading has no timer.
		if not _tutorial_active() and not speech.visible and not speech_queue.is_empty():
			_show_lesson(speech_queue.pop_front())
		_position_speech(delta)
		_refresh_home()
	if loop_running and modal_name == "loop":
		loop_clock += delta
		if loop_clock >= 0.45:
			loop_clock = 0.0
			if session_stage == 3:
				loop_inner += 1
				loop_value += 1
				if loop_inner >= loop_stride:
					loop_step += 1
					loop_inner = 0
			else:
				loop_step += 1
				loop_value += loop_stride
			loop_marker.position.x = 258 + (loop_step + float(loop_inner) / loop_stride) * 116
			loop_live_label.text = "Value: %d · %d completed %s" % [loop_value, loop_step, "groups" if session_stage == 3 else "repeats"]
			_play_sound("step")
			if loop_step >= loop_count:
				_finish_loop_run()
	save_time += delta
	if save_time >= 30:
		save_time = 0
		_save()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if _tutorial_active():
			# Only the highlighted task's shortcut works during the guided tour.
			var allowed = {"pet":KEY_P,"feed":KEY_F,"knowledge":KEY_K,"shop":KEY_S,"games":KEY_M}
			if event.keycode == KEY_ESCAPE:
				tutorial.finish()
				return
			if event.keycode != allowed.get(tutorial.step_id(),0):
				return
		if event.keycode == KEY_ESCAPE:
			close_modal()
		elif modal_name.is_empty():
			match event.keycode:
				KEY_F: open_feed()
				KEY_M: open_games()
				KEY_K: open_knowledge()
				KEY_S: open_shop()
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
	coin_label.text = str(progress.coins)
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
	_tutorial_notice(action)

func learn(key: String) -> void:
	if not Lessons.DATA.has(key) or speech_queue.has(key):
		return
	if progress.discovered.has(key):
		if not _tutorial_active() and speech_queue.is_empty() and not speech.visible and modal_name.is_empty():
			_show_lesson(key, false)
		return
	speech_queue.append(key)
	# A new lesson waits until the player finishes the current bubble.

func _show_lesson(key: String, is_new: bool = true) -> void:
	var lesson = _lesson(key)
	var newly_unlocked = progress.unlock(key)
	progress.pip_quotes[key] = lesson.bubble
	_say(("NEW DISCOVERY · " if newly_unlocked else "LITTLE REMINDER · ") + lesson.tag, lesson.bubble, key)
	if newly_unlocked and is_new:
		_toast("New discovery: " + lesson.title)
		_play_sound("learn")
	_refresh_home()
	_save()

func _say(title: String, words: String, lesson_key: String = "") -> void:
	speech_title.text = title
	speech_full_text = words
	speech_key = lesson_key
	speech_pages = _paginate_speech(words)
	speech.visible = true
	_show_speech_page(0)
	_position_speech(1.0)

func _paginate_speech(words: String) -> Array[String]:
	# Measure the actual wrapped font lines. Keep exact substrings, so no word
	# or punctuation is dropped when a long sentence needs another page.
	var pages: Array[String] = []
	var remaining = words
	while not remaining.is_empty():
		var low = 1
		var high = remaining.length()
		var fits = 1
		while low <= high:
			var middle = (low + high) / 2
			speech_text.text = remaining.left(middle).strip_edges()
			# Visible-line count includes theme line spacing, which multiplying
			# font line height alone misses and can hide the final sentence.
			# Query total lines first to refresh Godot's shaped-text cache.
			if speech_text.get_line_count() <= speech_text.get_visible_line_count():
				fits = middle
				low = middle + 1
			else:
				high = middle - 1
		if fits < remaining.length():
			var prefix = remaining.left(fits)
			var sentence_end = maxi(prefix.rfind(". "), maxi(prefix.rfind("! "), prefix.rfind("? ")))
			var space = prefix.rfind(" ")
			if sentence_end >= fits / 2:
				fits = sentence_end + 2
			elif space > 0:
				fits = space + 1
		pages.append(remaining.left(fits))
		remaining = remaining.substr(fits)
	if pages.is_empty():
		pages.append("")
	return pages

func _show_speech_page(index: int) -> void:
	speech_page_index = clampi(index, 0, speech_pages.size()-1)
	speech_text.text = speech_pages[speech_page_index].strip_edges()
	speech_back.visible = speech_page_index > 0
	speech_next.text = "Next →" if speech_page_index < speech_pages.size()-1 else "Done"
	speech_book.visible = not speech_key.is_empty()
	speech_hint.text = "%d / %d · Take your time. Tap Next or Done when ready." % [speech_page_index+1, speech_pages.size()]

func _advance_speech() -> void:
	if speech_page_index < speech_pages.size()-1:
		_show_speech_page(speech_page_index+1)
		return
	speech.visible = false
	if _tutorial_active() and tutorial.step_id() == "speech":
		_tutorial_notice("speech_done")
		return
	speech_key = ""
	if not speech_queue.is_empty() and modal_name.is_empty():
		_show_lesson(speech_queue.pop_front())

func _position_speech(delta: float) -> void:
	var center = speech.size.x / 2
	var above = pip.position.y - speech.size.y - (155 if pip.cosmetic_items.has("head") else 130)
	var below = pip.position.y + 113
	var desired = Vector2(clampf(pip.position.x-center, 60, 1220-speech.size.x), above)
	if above >= 150:
		speech_tail.polygon = PackedVector2Array([Vector2(center-14,speech.size.y-2), Vector2(center+14,speech.size.y-2), Vector2(center,speech.size.y+11)])
	elif below + speech.size.y <= 651:
		desired.y = below
		speech_tail.polygon = PackedVector2Array([Vector2(center-14,2),Vector2(center+14,2),Vector2(center,-11)])
	else:
		# When Pip is halfway up the room, put the complete bubble beside him.
		desired.y = clampf(pip.position.y-125, 150, 651-speech.size.y)
		var on_right: bool = pip.position.x <= 640
		desired.x = pip.position.x+112 if on_right else pip.position.x-112-speech.size.x
		var edge = 2.0 if on_right else speech.size.x-2
		var tip = -11.0 if on_right else speech.size.x+11
		speech_tail.polygon = PackedVector2Array([Vector2(edge,111),Vector2(edge,139),Vector2(tip,125)])
	desired.x = clampf(desired.x, 60, 1220-speech.size.x)
	desired.y = clampf(desired.y, 150, 651-speech.size.y)
	speech.position = speech.position.lerp(desired, minf(1.0, delta*12))

func _lesson(key: String) -> Dictionary:
	return Lessons.entry(key, "college" if progress.active_stage() >= 3 else ("middle" if progress.active_stage() > 0 else "kindergarten"))

func _level_prompt() -> String:
	return Lessons.LEVEL_SHORT[Lessons.normalize_level(progress.game_level)] + ": " + Lessons.level_description(progress.game_level)

func _by_level(kid: String, middle: String, college: String) -> String:
	match ("college" if progress.active_stage() >= 3 else ("middle" if progress.active_stage() > 0 else "kindergarten")):
		"middle":
			return middle
		"college":
			return college
		_:
			return kid

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
	if is_instance_valid(picnic):
		picnic.stop()
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
	if is_instance_valid(picnic):
		picnic.stop()
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
		btn.name = "Offer_" + kind
		btn.disabled = count <= 0 or progress.fullness >= 95 or pip.eating_time > 0
	var tip = "Choose a treat and Pip will eat it back in the room."
	if progress.fullness >= 95:
		tip = "Pip is full and cozy. A mini-game win builds his appetite for another snack."
	elif pip.eating_time > 0:
		tip = "Pip is still chewing. Return home and let him finish his little snack."
	UI.label(overlay, tip, Rect2(170, 587, 940, 46), 19, UI.GREEN, true)
	UI.button(overlay, "Earn more treats", Rect2(497, 659, 286, 51), open_games)
	_tutorial_notice("open_feed")

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
	_screen("knowledge", "The little book of discoveries", "%d / %d discovered · Pip’s full words, explanations, and code · Scroll inside each page." % [progress.discovered.size(), Lessons.ORDER.size()])
	if progress.discovered.is_empty():
		_add_icon(overlay, "book", Rect2(579, 276, 120, 120))
		UI.label(overlay, "Your story starts with a little curiosity", Rect2(200, 421, 880, 44), 27, UI.INK, true)
		UI.label(overlay, "Watch Pip idle, pet his head, or hold and drag him.\nA lesson joins this book when its bubble appears.", Rect2(240, 482, 800, 73), 21, UI.MUTED, true)
		UI.button(overlay, "Let's explore", Rect2(500, 606, 280, 52), close_modal, true)
		_tutorial_notice("open_knowledge")
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
		var b = UI.button(list, _lesson(key).title, Rect2(0, 0, 285, 50), func(): open_knowledge(key), key == selected)
		b.custom_minimum_size = Vector2(285, 52)
		b.add_theme_font_size_override("font_size", 17)
		if key == selected:
			_reveal_journal_entry(scroll, b)
	var lesson = _lesson(selected)
	UI.panel(overlay, Rect2(486, 224, 642, 478), Color("f5f3e9"), 20)
	UI.label(overlay, lesson.tag + "  /  " + lesson.trigger, Rect2(511, 235, 415, 35), 14, UI.GREEN)
	UI.label(overlay, lesson.title, Rect2(511, 276, 590, 48), 29)
	var quote = str(progress.pip_quotes.get(selected, lesson.bubble))
	UI.button(overlay, "Read with Pip", Rect2(941, 232, 166, 37), func():
		close_modal()
		_say("PIP SAYS · " + lesson.tag, quote, selected)).add_theme_font_size_override("font_size", 15)
	var body_scroll = ScrollContainer.new()
	body_scroll.name = "JournalBody"
	body_scroll.position = Vector2(510, 332)
	body_scroll.size = Vector2(595, 353)
	body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_scroll.focus_mode = Control.FOCUS_ALL
	overlay.add_child(body_scroll)
	var content = VBoxContainer.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	body_scroll.add_child(content)
	UI.paragraph(content, "PIP SAYS", 14, UI.GREEN)
	var quote_label = UI.paragraph(content, quote, 19, UI.GREEN)
	quote_label.name = "PipQuote"
	UI.paragraph(content, "WHAT THIS MEANS", 14, UI.MUTED)
	UI.paragraph(content, lesson.body, 18).name = "Explanation"
	UI.paragraph(content, "CODE EXAMPLE", 14, UI.MUTED)
	var code = UI.paragraph(content, lesson.code, 16, UI.GREEN)
	code.name = "Code"
	code.add_theme_font_override("font", preload("res://assets/fonts/Code.ttf"))
	UI.paragraph(content, "Simplified GDScript · the same idea used in Pip's behavior", 13, UI.MUTED)
	_tutorial_notice("open_knowledge")

func _reveal_journal_entry(scroll: ScrollContainer, entry: Button) -> void:
	await get_tree().process_frame
	if is_instance_valid(scroll) and is_instance_valid(entry):
		scroll.ensure_control_visible(entry)

func open_games() -> void:
	var stage = progress.active_stage()
	var cap = Curriculum.max_stage(progress.game_level)
	_screen("games", "Play, learn, and grow", Lessons.level_label(progress.game_level) + " · Everyone starts with the basics. No timers.")
	var picker = OptionButton.new()
	picker.name = "StagePicker"
	picker.position = Vector2(154, 224)
	picker.size = Vector2(345, 44)
	for i in range(cap + 1):
		picker.add_item("%d. %s%s" % [i+1, Curriculum.STAGES[i].name, " · locked" if i > progress.unlocked_stage() else ""])
		picker.set_item_disabled(i, i > progress.unlocked_stage())
	picker.select(stage)
	picker.item_selected.connect(func(index):
		progress.practice_stage = index
		_save()
		open_games())
	overlay.add_child(picker)
	UI.label(overlay, Curriculum.STAGES[stage].summary, Rect2(520, 222, 594, 48), 17, UI.GREEN)
	var wins: Array = progress.stage_badges.get(str(stage), [])
	var path_text = "Finish all three activities to collect this stage's badges. A quiz needs at least 3 questions."
	if Curriculum.completed(progress.stage_badges, stage):
		path_text = "Stage complete! Replay any activity for coins or choose another unlocked stage."
	if cap == 0:
		path_text = "Keep practicing these gentle games. This level always stays at First steps."
	UI.label(overlay, path_text, Rect2(154, 278, 974, 43), 16, UI.MUTED)
	var cards = [
		["berry", "Berry Detective", "Follow a rule and sort 10 finds.\nA win needs 7 correct.", start_sort],
		["paw", "Loop Garden", "Choose repeats for 3 gardens.\nTry again whenever you need.", start_loop],
		["book", "Pip's Pop Quiz", "Up to 5 lessons you have seen.\nA win needs 60% correct.", start_quiz]]
	for i in range(3):
		var x = 151 + i*330
		UI.panel(overlay, Rect2(x, 333, 317, 273), [Color("f5e7e5"),Color("e8eddc"),Color("f2eada")][i], 20)
		_add_icon(overlay, cards[i][0], Rect2(x+18, 350, 49, 49))
		UI.label(overlay, "Badge earned" if wins.has(Curriculum.MODES[i]) else "Badge to earn", Rect2(x+84, 358, 210, 30), 15, UI.GREEN)
		UI.label(overlay, cards[i][1], Rect2(x+18, 410, 281, 38), 24)
		UI.label(overlay, cards[i][2], Rect2(x+18, 452, 281, 68), 18)
		UI.label(overlay, "Finish: coins · Win: treats too", Rect2(x+18, 518, 281, 23), 15, UI.GREEN)
		var b = UI.button(overlay, "Let's play" if i < 2 else "Start quiz", Rect2(x+18, 547, 281, 44), cards[i][3], true)
		if i == 2 and _stage_quiz_pool(stage).is_empty():
			b.text = "Play the other games first"
			b.disabled = true
	var note = "Next stage unlocks after all three badges. Earlier stages stay available for practice."
	if stage == cap:
		note = "You are at this level's final stage. Replay for practice, treats, and coins."
	if stage > 0 and _stage_quiz_pool(stage).size() < 3:
		note = "Play both games to meet this stage's ideas before taking its quiz."
	UI.panel(overlay, Rect2(151, 618, 977, 78), Color("f5e5b7"), 18)
	_add_icon(overlay, "basket", Rect2(167, 632, 48, 48))
	UI.label(overlay, "NEW · Picnic Catch", Rect2(233, 623, 585, 31), 23)
	UI.label(overlay, "A play break with Pip · catch snacks, build streaks, earn gold", Rect2(234, 657, 588, 25), 15, UI.GREEN)
	var picnic_button = UI.button(overlay, "Play Picnic Catch", Rect2(850, 634, 259, 45), start_picnic, true)
	picnic_button.name = "PlayPicnic"
	picnic_button.tooltip_text = "Bonus activity · optional for stage badges"
	var best: Array[String] = []
	for record in progress.scores:
		best.append("%s %d%%" % [record.mode, record.score])
	var best_label = UI.label(overlay, "Best scores: " + (" · ".join(best) if not best.is_empty() else "Your first win will appear here."), Rect2(158, 701, 966, 28), 14, UI.MUTED)
	best_label.tooltip_text = note
	_tutorial_notice("open_games")

func _stage_quiz_pool(stage: int) -> Array:
	var keys = progress.discovered.filter(func(key):
		return Lessons.DATA.has(key) and (key in Curriculum.STAGES[stage].keys if stage > 0 else (Lessons.ORDER.find(key) < 12 or key == "picnic")))
	keys.shuffle()
	return keys.slice(0, 5)

func start_picnic() -> void:
	_tutorial_notice("start_activity")
	session_stage = progress.active_stage()
	session_rewarded = false
	var keys: Array = ["picnic"]
	if session_stage >= 1:
		keys.append("or")
	if session_stage >= 2:
		keys.append("elif")
	if session_stage >= 3:
		keys.append("limits")
	_begin_intro(keys, _picnic_setup)

func _picnic_setup() -> void:
	_screen("picnic", "Pip's Picnic Catch", "Catch 10 snacks · No countdown, no lost lives · A bonus game, separate from stage badges.")
	picnic_count = UI.label(overlay, "Snacks  0 / 10", Rect2(166, 220, 230, 35), 22, UI.GREEN)
	picnic_streak = UI.label(overlay, "Streak  0   ·   Best  0", Rect2(428, 220, 370, 35), 18, UI.GREEN)
	picnic = Picnic.new()
	picnic.position = Vector2(154,263)
	picnic.size = Vector2(646,367)
	picnic.stage = session_stage
	picnic.gentle = progress.calm
	picnic.cosmetics = progress.cosmetics("pet")
	overlay.add_child(picnic)
	picnic.changed.connect(_refresh_picnic)
	picnic.caught.connect(func(_kind): _play_sound("correct"))
	picnic.finished.connect(_finish_picnic)
	picnic.pause_changed.connect(func(value):
		picnic_pause.text = "Resume" if value else "Pause")
	UI.panel(overlay, Rect2(820,221,308,409), Color("f4edda"), 18)
	UI.label(overlay, "A picnic with Pip", Rect2(839,233,270,37), 24)
	var controls = UI.label(overlay, "Move: mouse, touch, or A / D.\nArrow keys also work.\nOr hold the buttons below.", Rect2(841,278,262,100), 17)
	controls.name = "PicnicControls"
	var rule = "Catch berries. Missing one only restarts your current streak. Your collected snacks stay!"
	if session_stage == 1:
		rule = "Catch berries OR golden seeds.\nEach seed also gives +2 gold.\nOR means either snack counts."
	elif session_stage >= 2:
		rule = "Berries: +1 snack.\nGolden seeds: +1 snack, +2 gold.\nLet leaves fall to keep your streak."
	UI.scroll_text(overlay, rule, Rect2(841,383,264,111), 17, UI.GREEN)
	UI.scroll_text(overlay, "Finish: 20 gold + 2 per best-streak catch, plus seed bonuses. Also 3 berries + 1 seed for Pip.", Rect2(841,502,264,105), 17)
	picnic_hint = UI.label(overlay, "Ready when you are! Press Start picnic.", Rect2(157,637,963,44), 17, UI.GREEN, true)
	var left = UI.button(overlay, "← Left", Rect2(157,691,141,40), func(): pass)
	var right = UI.button(overlay, "Right →", Rect2(309,691,141,40), func(): pass)
	left.name = "PicnicLeft"
	right.name = "PicnicRight"
	left.button_down.connect(func(): picnic.button_direction = -1)
	right.button_down.connect(func(): picnic.button_direction = 1)
	left.button_up.connect(func(): picnic.button_direction = 0)
	right.button_up.connect(func(): picnic.button_direction = 0)
	picnic_pause = UI.button(overlay, "Pause", Rect2(466,691,137,40), func(): picnic.set_paused(not picnic.paused))
	picnic_pause.name = "PicnicPause"
	picnic_pause.disabled = true
	UI.label(overlay, "Your best streak: %d" % progress.picnic_best, Rect2(615,691,260,40), 16, UI.MUTED, true)
	picnic_start = UI.button(overlay, "Start picnic", Rect2(886,686,239,46), func():
		picnic.start()
		picnic_start.disabled = true
		picnic_start.text = "Have fun, Pip!"
		picnic_pause.disabled = false, true)
	picnic_start.name = "PicnicStart"

func _refresh_picnic() -> void:
	if modal_name != "picnic":
		return
	picnic_count.text = "Snacks  %d / %d" % [picnic.collected, Picnic.GOAL]
	picnic_streak.text = "Streak  %d   ·   Best  %d" % [picnic.streak, picnic.best_streak]
	picnic_hint.text = picnic.feedback

func _finish_picnic(report: Dictionary) -> void:
	if session_rewarded or modal_name != "picnic" or not is_instance_valid(picnic) or not picnic.completed:
		return
	session_rewarded = true
	var gold: int = 20 + 2 * report.best_streak + report.seed_gold
	progress.award_coins(gold)
	progress.reward("Picnic Catch", report.best_streak * 10, 3, 1)
	progress.picnic_rounds += 1
	progress.picnic_best = maxi(progress.picnic_best, report.best_streak)
	var words: String = _lesson("picnic").bubble + " We caught 10 snacks! Our longest streak was %d, so it added %d bonus gold." % [report.best_streak, report.best_streak*2]
	_discover_in_game("picnic", words)
	_say("Thanks for playing with me!", words, "picnic")
	_save()
	_refresh_home()
	_screen("picnic_result", "A perfect little picnic!", "All 10 snacks collected · Your reward is saved · Play again whenever you like.")
	_add_icon(overlay, "basket", Rect2(582,222,112,112))
	UI.label(overlay, "+%d gold" % gold, Rect2(278,341,724,53), 38, UI.GREEN, true)
	UI.label(overlay, "20 for finishing + %d streak bonus + %d seed bonus" % [report.best_streak*2,report.seed_gold], Rect2(230,404,820,40), 22, UI.INK, true)
	UI.panel(overlay, Rect2(219,462,842,67), Color("e7efdc"),18)
	UI.label(overlay, "+3 berries · +1 seed · Pip feels happier!", Rect2(240,471,800,48), 24, UI.GREEN, true)
	UI.label(overlay, "Best streak this picnic: %d   ·   Personal best: %d\nPicnics completed: %d" % [report.best_streak,progress.picnic_best,progress.picnic_rounds], Rect2(250,546,780,74), 21, UI.MUTED, true)
	UI.button(overlay, "Play again", Rect2(184,654,289,53), start_picnic, true)
	UI.button(overlay, "Shop · %d gold" % progress.coins, Rect2(494,654,290,53), open_shop)
	UI.button(overlay, "Back to Pip", Rect2(805,654,289,53), close_modal)
	_play_sound("win")

func _begin_intro(keys: Array, action: Callable) -> void:
	intro_keys = keys
	intro_index = 0
	intro_action = action
	_intro_page()

func _intro_page() -> void:
	var key: String = intro_keys[intro_index]
	var lesson = Lessons.entry(key)
	_screen("intro", "Pip explains: " + lesson.title, "Stage %d · Little lesson %d of %d · No coding experience needed." % [session_stage+1, intro_index+1, intro_keys.size()])
	UI.panel(overlay, Rect2(154, 224, 972, 264), Color("e8edde"), 20)
	UI.scroll_text(overlay, lesson.bubble, Rect2(181, 242, 918, 85), 25, UI.GREEN)
	UI.scroll_text(overlay, lesson.body, Rect2(181, 330, 918, 140), 20)
	UI.code(overlay, lesson.code, Rect2(181, 511, 918, 111), 19)
	UI.label(overlay, "Read the words first; the code shows the same idea. Saved to Knowledge.", Rect2(184, 632, 910, 33), 17, UI.MUTED)
	UI.button(overlay, "Next little lesson →" if intro_index < intro_keys.size()-1 else "Try it together →", Rect2(767, 680, 331, 46), func():
		intro_index += 1
		if intro_index < intro_keys.size():
			_intro_page()
		else:
			intro_action.call(), true)
	_discover_in_game(key, lesson.bubble)

func start_quiz() -> void:
	_tutorial_notice("start_activity")
	session_stage = progress.active_stage()
	quiz_keys = _stage_quiz_pool(session_stage)
	if quiz_keys.is_empty():
		open_games()
		return
	quiz_index = 0
	quiz_score = 0
	session_rewarded = false
	_quiz_question()

func _quiz_question() -> void:
	_screen("quiz", "Pip's Pop Quiz", "Stage %d · Only lessons you have seen · question %d of %d" % [session_stage+1, quiz_index+1, quiz_keys.size()])
	answer_locked = false
	quiz_answer_buttons.clear()
	var lesson = _lesson(quiz_keys[quiz_index])
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
	game_feedback = UI.scroll_text(overlay, _by_level(
		"Take your time. Read the answer like a story: IF something happens THEN the game reacts.",
		"Take your time. Pick the answer that matches the condition and result you saw in the game.",
		"Take your time. Match the observed game behavior to the programming concept and state change."), Rect2(174, 573, 932, 74), 17, UI.MUTED)
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
	game_feedback.text = _by_level(
		("Yes! " if correct else "Not yet, but this is how we learn. ") + explanation,
		("Correct. " if correct else "Debug moment. ") + explanation,
		("Correct. " if correct else "Incorrect, but useful feedback. ") + explanation)
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
	_tutorial_notice("start_activity")
	session_stage = progress.active_stage()
	sort_items = ["berry", "stone", "blueberry", "button", "berry", "blueberry", "berry", "button", "stone", "berry"]
	if session_stage == 3:
		sort_items = ["berry", "seed", "spoiled_berry", "button", "stone", "blueberry", "spoiled_berry", "berry", "stone", "berry"]
	var first = sort_items.slice(0, 5)
	var second = sort_items.slice(5, 10)
	first.shuffle()
	second.shuffle()
	sort_items = first + second
	sort_index = 0
	sort_score = 0
	session_rewarded = false
	if session_stage == 0:
		_sort_question()
	else:
		_begin_intro({1:["or", "not", "comparison"], 2:["elif"], 3:["grouping", "limits"]}[session_stage], _sort_question)

func _sort_question() -> void:
	_screen("sort", "Berry Detective", "Stage %d · Look at the rule each round. Take as long as you need." % [session_stage+1])
	answer_locked = false
	sort_rule_and = sort_index >= 5
	var rule = Curriculum.sort_rule(session_stage, sort_index)
	UI.panel(overlay, Rect2(154, 224, 423, 365), Color("e9efdf"), 20)
	UI.label(overlay, "PIP'S RULE · " + rule.id.to_upper(), Rect2(178, 242, 378, 28), 14, UI.GREEN)
	var snippet = rule.code if session_stage == 2 else "if %s:\n    basket()\nelse:\n    leave_it()" % rule.code
	if session_stage == 3:
		snippet = "if (" + rule.code + "):\n    basket()\nelse:\n    leave_it()"
	UI.code(overlay, snippet, Rect2(176, 281, 380, 140), 16)
	UI.label(overlay, rule.words, Rect2(179, 437, 374, 132), 19)
	UI.panel(overlay, Rect2(593, 224, 533, 365), Color("f5eddf"), 20)
	var kind: String = sort_items[sort_index]
	_add_icon(overlay, kind, Rect2(807, 253, 100, 100))
	var names = {"berry":"A red berry", "blueberry":"A blue berry", "stone":"A gray pebble", "button":"A red button", "seed":"A fresh seed", "spoiled_berry":"A spoiled berry"}
	UI.label(overlay, names[kind], Rect2(609, 367, 500, 45), 28, UI.INK, true)
	var state = "Find %d of 10 · %d correct" % [sort_index+1, sort_score]
	if session_stage == 3 and sort_index >= 5:
		state += " · Fullness: %d" % Curriculum.fullness_for(sort_index)
	UI.label(overlay, state, Rect2(609, 421, 500, 35), 16, UI.MUTED, true)
	quiz_answer_buttons.clear()
	var choices = ["Snack now", "Save for later", "Leave it"] if session_stage == 2 else ["Into the basket", "Leave it"]
	var width = 155 if session_stage == 2 else 238
	for i in range(choices.size()):
		var choice: int = i
		quiz_answer_buttons.append(UI.button(overlay, choices[i], Rect2(612+i*(width+10), 508, width, 52), func(): _answer_sort_choice(choice), i == 0))
	game_feedback = UI.scroll_text(overlay, "Pip: Try saying the rule out loud. IF the check says yes THEN choose its action; ELSE choose the other action.", Rect2(174, 598, 932, 57), 18, UI.MUTED)
	next_button = UI.button(overlay, "Next find →" if sort_index < 9 else "Open your basket →", Rect2(799, 675, 307, 47), _next_sort, true)
	next_button.disabled = true
	UI.label(overlay, "7 correct wins treats. Finish for coins.", Rect2(174, 675, 600, 39), 17, UI.MUTED)

func _answer_sort(chose_basket: bool) -> void:
	_answer_sort_choice(0 if chose_basket else 1)

func _answer_sort_choice(choice: int) -> void:
	if answer_locked:
		return
	answer_locked = true
	var kind: String = sort_items[sort_index]
	var expected = Curriculum.sort_answer(session_stage, sort_index, kind)
	var correct = choice == expected
	if correct:
		sort_score += 1
	for b in quiz_answer_buttons:
		b.disabled = true
	var names = ["snack now", "save for later", "leave it"] if session_stage == 2 else ["into the basket", "leave it"]
	var fact = "Berry? %s. Red? %s." % ["yes" if kind in ["berry", "blueberry", "spoiled_berry"] else "no", "yes" if kind in ["berry", "button"] else "no"]
	if session_stage == 3:
		fact = "Food? %s. Spoiled? %s." % ["yes" if kind in ["berry", "blueberry", "spoiled_berry", "seed"] else "no", "yes" if kind == "spoiled_berry" else "no"]
		if sort_index >= 5:
			fact += " Fullness %d < 95? %s." % [Curriculum.fullness_for(sort_index), "yes" if Curriculum.fullness_for(sort_index)<95 else "no"]
	game_feedback.text = ("Pip: You found it! " if correct else "Pip: Let's check together. ") + fact + " So choose: " + names[expected] + ". " + ("Follow the rule above one check at a time." if not correct else "")
	game_feedback.add_theme_color_override("font_color", UI.GREEN if correct else UI.ORANGE)
	next_button.disabled = false
	_discover_in_game(Curriculum.sort_rule(session_stage, sort_index).id, Curriculum.sort_rule(session_stage, sort_index).words + "\n\n" + game_feedback.text)
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
	_tutorial_notice("start_activity")
	session_stage = progress.active_stage()
	loop_round = 0
	loop_attempts = 0
	session_rewarded = false
	loop_targets = [3, 4, 5]
	loop_targets.shuffle()
	if session_stage == 0:
		_loop_garden()
	else:
		_begin_intro({1:["step_size"], 2:["parameters", "accumulator"], 3:["lists", "nested"]}[session_stage], _loop_garden)

func _loop_garden() -> void:
	_screen("loop", "Loop Garden", "Garden %d of 3 · choose a repeat count to reach the golden star." % [loop_round+1])
	loop_count = 1
	loop_start = [1, 2, 0][loop_round] if session_stage == 1 else 0
	loop_stride = [2, 3, 2][loop_round] if session_stage > 0 else 1
	loop_value = loop_start
	loop_inner = 0
	loop_step = 0
	loop_clock = 0
	loop_buttons.clear()
	UI.panel(overlay, Rect2(154, 224, 972, 225), Color("e7efde"), 20)
	UI.label(overlay, ("ONE REPEAT = ONE STEP TO THE RIGHT" if session_stage == 0 else "START %d · EACH %s ADDS %d · TARGET %d" % [loop_start, "GROUP" if session_stage == 3 else "REPEAT", loop_stride, _loop_target_value()]), Rect2(180, 244, 920, 30), 14, UI.GREEN, true)
	loop_live_label = UI.label(overlay, "Value: %d · Ready to try" % loop_start, Rect2(180, 274, 920, 25), 14, UI.MUTED, true)
	for i in range(7):
		var x = 247 + i*116
		UI.panel(overlay, Rect2(x, 352, 91, 43), Color("c5cbb6"), 22)
		UI.label(overlay, ("START" if session_stage == 0 else str(loop_start)) if i == 0 else str(loop_start + i * loop_stride), Rect2(x, 399, 91, 25), 14, UI.MUTED, true)
		if i == loop_targets[loop_round]:
			_add_icon(overlay, "star", Rect2(x+20, 299, 51, 51))
	loop_marker = UI.panel(overlay, Rect2(258, 305, 65, 65), Color("fff7df"), 32, true)
	_add_icon(loop_marker, "paw", Rect2(14, 11, 38, 38))
	UI.label(overlay, "Repeat", Rect2(178, 478, 120, 37), 22)
	loop_buttons.append(UI.button(overlay, "−", Rect2(301, 473, 54, 48), func(): _change_loop(-1)))
	loop_count_label = UI.label(overlay, "1", Rect2(365, 473, 61, 48), 29, UI.INK, true)
	loop_buttons.append(UI.button(overlay, "+", Rect2(436, 473, 54, 48), func(): _change_loop(1)))
	loop_code_label = UI.code(overlay, "", Rect2(549, 467, 552, 130), 17)
	_update_loop_code()
	loop_buttons.append(UI.button(overlay, "Run my loop  →", Rect2(178, 536, 312, 52), _run_loop, true))
	game_feedback = UI.scroll_text(overlay, _by_level(
		"Count from START to the star. IF the number is right THEN the marker lands on the star.",
		"Choose the repeat count, run it, then debug by comparing where it stopped.",
		"Set the loop parameter, execute it, then compare expected position with actual position."), Rect2(178, 606, 920, 61), 19, UI.MUTED)
	next_button = UI.button(overlay, "Next garden  →" if loop_round < 2 else "Collect rewards →", Rect2(788, 675, 312, 47), _next_loop, true)
	if session_stage > 0:
		game_feedback.text = "Pip: Each stone label shows the new total. Count %s to the star, then run your loop." % ("groups of inner steps" if session_stage == 3 else "repeats")
	next_button.visible = false

func _change_loop(amount: int) -> void:
	if loop_running:
		return
	loop_count = clampi(loop_count + amount, 1, 6)
	_update_loop_code()

func _update_loop_code() -> void:
	loop_count_label.text = str(loop_count)
	match session_stage:
		1: loop_code_label.text = "position = %d\nfor step in range(%d):\n    position += %d" % [loop_start, loop_count, loop_stride]
		2: loop_code_label.text = "total = 0\nfor batch in range(%d):\n    add_seeds(%d) # total += %d" % [loop_count, loop_stride, loop_stride]
		3: loop_code_label.text = "steps = [2, 3, 2]\nfor group in range(%d):\n    for step in range(steps[%d]):\n        move_one_step()" % [loop_count, loop_round]
		_: loop_code_label.text = "for step in range(%d):\n    move_one_stone_right()" % loop_count

func _loop_target_value() -> int:
	return loop_start + loop_targets[loop_round] * loop_stride

func _run_loop() -> void:
	if loop_running:
		return
	loop_attempts += 1
	loop_running = true
	loop_step = 0
	loop_clock = 0.0
	loop_marker.position.x = 258
	loop_value = loop_start
	loop_inner = 0
	for b in loop_buttons:
		b.disabled = true
	game_feedback.text = _by_level(
		"Running your loop... IF there is another repeat left THEN take one step.",
		"Running your loop... each repeat runs move_one_stone_right() once.",
		"Executing loop body... each iteration advances the marker by one state.")
	if session_stage > 0:
		game_feedback.text = "Pip: Start at %d. Each repeat adds %d to our stored number. Watch it change!" % [loop_start, loop_stride]
	if session_stage == 3:
		game_feedback.text = "Pip: Every outer repeat runs all %d inner steps. Then the inner count starts again." % loop_stride

func _finish_loop_run() -> void:
	loop_running = false
	var reached = loop_value == _loop_target_value()
	if reached:
		game_feedback.text = _by_level(
			"IF repeat is %d THEN I take %d steps. You reached the star!" % [loop_count, loop_step],
			"%d repeats = %d steps. You reached the star!" % [loop_count, loop_step],
			"%d iterations produced %d position updates. Target reached." % [loop_count, loop_step])
		next_button.visible = true
		_play_sound("correct")
	else:
		game_feedback.text = _by_level(
			"You moved %d steps, but the star is %d steps away. IF the number is wrong THEN try a new number!" % [loop_step, loop_targets[loop_round]],
			"You moved %d steps. The star is %d steps away. Change the repeat count and try again!" % [loop_step, loop_targets[loop_round]],
			"Observed %d iterations, expected %d. Adjust the loop count and rerun." % [loop_step, loop_targets[loop_round]])
		for b in loop_buttons:
			b.disabled = false
		_play_sound("try")
	if session_stage > 0:
		game_feedback.text = "Pip: Start %d + (%d repeats × %d each) = %d. " % [loop_start, loop_count, loop_stride, loop_value] + ("You reached the target!" if reached else "Our target is %d. Try changing the repeat count." % _loop_target_value())
	game_feedback.add_theme_color_override("font_color", UI.GREEN if reached else UI.ORANGE)
	_discover_in_game("repeat", game_feedback.text)

func _next_loop() -> void:
	if loop_running or loop_value != _loop_target_value() or not next_button.visible:
		return
	loop_round += 1
	if loop_round >= 3:
		var score = maxi(60, 100-(loop_attempts-3)*5)
		_result("Loop Garden", score, true, 4, 3, 1, "Three gardens, three working loops. You tested your code and helped it grow!")
	else:
		_loop_garden()

func _discover_in_game(key: String, spoken: String = "") -> void:
	# Store the whole encountered explanation, independently of its layout.
	var newly_unlocked = progress.unlock(key)
	var quote = spoken if not spoken.is_empty() else str(_lesson(key).bubble)
	var changed = progress.pip_quotes.get(key, "") != quote
	progress.pip_quotes[key] = quote
	if newly_unlocked:
		speech_queue.erase(key)
		_refresh_home()
	if newly_unlocked or changed:
		_save()

func _result(mode: String, points: int, won: bool, berries: int, seeds: int, carrots: int, message: String) -> void:
	if session_rewarded:
		return
	session_rewarded = true
	var previous_stage = progress.unlocked_stage()
	var earned = 12 + clampi(points, 0, 100) / 10 + (8 if won else 0) + session_stage * 5
	progress.award_coins(earned)
	if won:
		progress.reward(mode, points, berries, seeds, carrots)
		if mode != "Pop Quiz" or quiz_keys.size() >= 3:
			progress.mark_stage_win(session_stage, mode)
	_save()
	_refresh_home()
	_screen("result", "A little win for a big thinker!" if won else "Every try teaches you something", mode + " · Stage %d · %d%%" % [session_stage+1, points])
	_add_icon(overlay, "coin", Rect2(590, 223, 100, 100))
	UI.label(overlay, "+%d coins" % earned, Rect2(300, 330, 680, 47), 34, UI.GREEN, true)
	UI.label(overlay, message, Rect2(208, 385, 864, 87), 24, UI.INK, true)
	var reward = "+%d berries · +%d seeds · +%d carrots" % [berries, seeds, carrots] if won else "You earned practice coins. Read Pip's hints and try again for treats."
	UI.panel(overlay, Rect2(219, 486, 842, 66), Color("e7efdc"), 18)
	UI.label(overlay, reward, Rect2(239, 492, 802, 54), 20, UI.GREEN, true)
	var next_text = "Your coins are saved. Visit the Shop to make Pip's place your own."
	if progress.unlocked_stage() > previous_stage:
		next_text = "New stage unlocked: " + Curriculum.STAGES[progress.unlocked_stage()].name + "! Pip will explain every new idea."
	elif won and mode == "Pop Quiz" and quiz_keys.size() < 3:
		next_text = "Rewards earned! Discover at least 3 lessons, then win a quiz to earn its stage badge."
	elif Curriculum.completed(progress.stage_badges, session_stage):
		next_text = "All three stage badges earned! Keep playing or explore another unlocked stage."
	UI.label(overlay, next_text, Rect2(208, 563, 864, 64), 19, UI.GREEN, true)
	UI.button(overlay, "Play something else", Rect2(184, 654, 289, 53), open_games)
	UI.button(overlay, "Shop · %d coins" % progress.coins, Rect2(494, 654, 290, 53), open_shop, true)
	UI.button(overlay, "Back to Pip", Rect2(805, 654, 289, 53), close_modal)
	_play_sound("win" if won else "try")

func open_settings() -> void:
	_screen("settings", "Make yourself comfortable", "A calm place to play, learn, and care for a tiny friend.")
	UI.panel(overlay, Rect2(151, 221, 978, 109), Color("eef0e5"), 20)
	UI.label(overlay, "Little sound effects", Rect2(181, 232, 625, 35), 24)
	UI.label(overlay, "Soft clicks, happy chimes, and tiny footsteps.", Rect2(182, 276, 649, 30), 18, UI.MUTED)
	UI.button(overlay, "Sound: " + ("on" if progress.sound else "off"), Rect2(878, 251, 215, 50), func():
		progress.sound = not progress.sound
		_save()
		open_settings())
	UI.panel(overlay, Rect2(151, 344, 978, 109), Color("f3eddf"), 20)
	UI.label(overlay, "Gentler movement", Rect2(181, 355, 625, 35), 24)
	UI.label(overlay, "Less swinging and breathing motion, with no landing bounce.", Rect2(182, 399, 658, 30), 18, UI.MUTED)
	UI.button(overlay, "Gentle: " + ("on" if progress.calm else "off"), Rect2(878, 374, 215, 50), func():
		progress.calm = not progress.calm
		pip.calm = progress.calm
		_save()
		open_settings())
	UI.panel(overlay, Rect2(151, 467, 978, 118), Color("e8edde"), 20)
	UI.label(overlay, "Game level", Rect2(181, 478, 510, 35), 24)
	UI.label(overlay, Lessons.level_description(progress.game_level), Rect2(182, 518, 514, 56), 17, UI.MUTED)
	var picker = OptionButton.new()
	picker.name = "GameLevel"
	picker.position = Vector2(730, 501)
	picker.size = Vector2(363, 50)
	picker.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	picker.add_theme_font_override("font", UI.FONT)
	picker.add_theme_font_size_override("font_size", 18)
	for level in Lessons.LEVELS:
		picker.add_item(Lessons.LEVEL_LABELS[level])
	picker.selected = maxi(0, Lessons.LEVELS.find(progress.game_level))
	picker.item_selected.connect(func(index: int):
		progress.game_level = Lessons.LEVELS[index]
		progress.practice_stage = progress.unlocked_stage()
		_save()
		_toast("Game level: " + Lessons.level_label(progress.game_level))
		open_settings())
	overlay.add_child(picker)
	UI.panel(overlay, Rect2(151, 599, 978, 70), Color("f5e7e5"), 20)
	UI.label(overlay, "Reset progress", Rect2(181, 607, 320, 30), 22)
	UI.label(overlay, "Clears lessons, badges, coins, purchases, and care progress.", Rect2(182, 638, 661, 24), 16, UI.MUTED)
	UI.button(overlay, "Reset progress", Rect2(878, 609, 215, 47), _confirm_reset)
	UI.label(overlay, "Saves automatically. P pet · F feed · M games · K knowledge · S shop", Rect2(181, 686, 669, 42), 15, UI.GREEN)
	UI.button(overlay, "Replay tutorial", Rect2(878,682,215,45), start_tutorial).name = "ReplayTutorial"
	_tutorial_notice("open_settings")

func _reset_progress() -> void:
	progress.reset_progress(true)
	_apply_cosmetics()
	start_time = 0
	pip.idle_time = 0
	pip.eating_time = 0
	shop_notice = "A fresh start. Play games to earn your first coins."
	pip.calm = progress.calm
	_save()
	close_modal()
	speech_queue.clear()
	_refresh_home()
	start_tutorial()

func _tutorial_active() -> bool:
	return is_instance_valid(tutorial) and tutorial.active

func _tutorial_notice(event: String) -> void:
	if _tutorial_active():
		tutorial.notice(event)

func start_tutorial() -> void:
	if not is_instance_valid(tutorial):
		return
	close_modal()
	speech.hide()
	tutorial.begin()

func _confirm_reset() -> void:
	_screen("reset", "Start a fresh story?", "This clears this device's saved progress, including every Shop purchase.")
	UI.label(overlay, "Coins, owned items, equipped items, stage badges, lessons, scores, and care counts will reset. You will receive the starter treats again. Your game level, sound, and movement settings stay.", Rect2(205, 275, 870, 167), 26, UI.INK, true)
	UI.button(overlay, "Keep my progress", Rect2(284, 521, 336, 58), open_settings, true)
	UI.button(overlay, "Reset everything", Rect2(655, 521, 336, 58), _reset_progress)

func _apply_cosmetics() -> void:
	pip.set_cosmetics(progress.cosmetics("pet"))
	$Room.set_cosmetics(progress.cosmetics("room"))

func open_shop() -> void:
	_screen("shop", "The little Shop", "Buy once, keep forever in this save. Equip and unequip here for free.")
	UI.button(overlay, "Pet accessories", Rect2(155, 219, 250, 44), func():
		shop_category = "pet"
		open_shop(), shop_category == "pet").name = "PetCategory"
	UI.button(overlay, "Room decorations", Rect2(416, 219, 264, 44), func():
		shop_category = "room"
		open_shop(), shop_category == "room").name = "RoomCategory"
	_add_icon(overlay, "coin", Rect2(899, 222, 35, 35))
	UI.label(overlay, "%d coins" % progress.coins, Rect2(944, 219, 184, 44), 24, UI.GREEN)
	var ids = Shop.ORDER.filter(func(id): return Shop.ITEMS[id].category == shop_category)
	for i in range(ids.size()):
		var id: String = ids[i]
		var item: Dictionary = Shop.ITEMS[id]
		var owned: bool = progress.owned.has(id)
		var equipped: bool = progress.equipped.get(Shop.slot_key(id), "") == id
		var x = 153 + (i % 3) * 330
		var y = 282 + (i / 3) * 197
		UI.panel(overlay, Rect2(x, y, 315, 181), Color("e6efdf") if equipped else Color("f3eedf"), 18)
		var art = CosmeticArt.new()
		art.kind = id
		art.position = Vector2(x+54, y+61)
		art.scale = Vector2.ONE * 1.08
		overlay.add_child(art)
		UI.label(overlay, item.name, Rect2(x+104, y+10, 199, 44), 19)
		UI.label(overlay, item.description, Rect2(x+104, y+57, 195, 53), 15, UI.MUTED)
		UI.label(overlay, "Equipped" if equipped else ("Owned" if owned else "%d coins" % item.price), Rect2(x+10, y+105, 295, 22), 15, UI.GREEN, true)
		var text = ("Unequip" if equipped else "Equip") if owned else "Buy · %d coins" % item.price
		var b = UI.button(overlay, text, Rect2(x+14, y+133, 287, 37), func(): _shop_action(id), owned)
		b.name = "Shop_" + id
		if not owned and progress.coins < item.price:
			b.text = "Need %d more coins" % (item.price - progress.coins)
			b.disabled = true
	UI.label(overlay, shop_notice, Rect2(156, 682, 972, 46), 16, UI.GREEN, true)
	_tutorial_notice("open_shop")

func _shop_action(id: String) -> void:
	if not Shop.ITEMS.has(id):
		return
	if not progress.owned.has(id):
		var before: int = progress.coins
		if not progress.buy(id):
			return
		shop_notice = "%s is yours! Coins: %d - %d = %d. Choose Equip to use it." % [Shop.ITEMS[id].name, before, Shop.ITEMS[id].price, progress.coins]
		_say("Coins remember a number", "IF you have enough coins THEN buying subtracts the price. Your item stays owned, even after you unequip it!")
		_play_sound("win")
	else:
		progress.toggle_equip(id)
		var wearing: bool = progress.equipped.get(Shop.slot_key(id), "") == id
		shop_notice = Shop.ITEMS[id].name + (" equipped. Items for the same spot replace each other; both stay owned." if wearing else " unequipped. It stays yours to equip again.")
		_say("A choice changes what you see", "IF an owned item is equipped THEN the game shows it. ELSE it stays in your collection. Try another look whenever you like!")
		_apply_cosmetics()
	_save()
	_refresh_home()
	open_shop()
