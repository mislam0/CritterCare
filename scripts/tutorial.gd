extends Control
## A guided tour of the real care UI. Clicks go through only at the green target.
## Progression follows actual game events; no purchases or rewards are simulated.

const UI = preload("res://scripts/ui.gd")
const GREEN = Color("29924c")
const STEPS = [
	{"id":"welcome", "title":"Welcome to CritterCare!", "words":"I'm Pip, your little hamster friend. Click Let's begin to learn how to care for me and explore my home. Then follow the green arrows at your own pace!"},
	{"id":"pet", "title":"Say hello to Pip", "words":"Click or tap my head once. IF you pet me THEN I feel happier! A short tap pets me; holding your click picks me up."},
	{"id":"carry", "title":"Pick me up gently", "words":"Hold your click or finger on me, move me to a new spot, then let go. IF you hold me THEN I follow you. Release me for a soft landing."},
	{"id":"needs", "title":"How is Pip feeling?", "words":"Fullness shows how fed I am. Happiness shows how cheerful I feel. Petting and snacks help! GOLD is your money for the Shop. You earn it by playing games."},
	{"id":"feed", "title":"Let's find a snack", "words":"Click Feed Critter at the bottom. This opens your treat pouch. You begin with berries, seeds, and carrots to share with me."},
	{"id":"snack", "title":"Offer Pip one treat", "words":"Click the highlighted Offer one button. It spends one treat and raises my fullness. IF I have room AND you have that treat THEN I can eat it."},
	{"id":"speech", "title":"Pip explains the why", "words":"My speech teaches the logic behind your actions. Click Next to read another page, then Done. Nothing disappears while you are reading. The full words are saved in Knowledge."},
	{"id":"knowledge", "title":"Your learning book", "words":"Click Knowledge at the bottom. It keeps the lessons you have already met, so you can look them up whenever you want."},
	{"id":"book", "title":"Read it again anytime", "words":"Each discovery includes Pip says, a plain explanation, and a code example. Scroll down to read it all. Read with Pip replays the complete explanation."},
	{"id":"shop", "title":"Make this home yours", "words":"Click Shop at the bottom right. You can browse now, even with zero gold. Game rewards help you buy your favorite looks later."},
	{"id":"catalog", "title":"Dress Pip and the room", "words":"Use these tabs for pet accessories or room decorations. Buy once, then Equip or Unequip for free. Your purchases stay yours until Reset progress. No purchase is needed for this tour."},
	{"id":"settings", "title":"Make yourself comfy", "words":"Click the three dots at the top right. Settings lets you choose your Game level, sound, gentler movement, and more."},
	{"id":"level", "title":"Choose your Game level", "words":"Everyone starts with easy lessons. Higher Game levels unlock more concepts as you progress. Keep this level or choose another. You can replay this tour in Settings anytime."},
	{"id":"games", "title":"Time to play and learn", "words":"Click Games / Quizzes. Complete activities to earn gold and treats. Pip explains each activity before you begin, with hints when you need help."},
	{"id":"activities", "title":"You're ready to explore!", "words":"Sort finds in Berry Detective, repeat steps in Loop Garden, or try a quiz. Picnic Catch is a playful snack hunt. Finish this tour, or click the highlighted Picnic Catch to start!"}
]

var game
var active: bool = false
var step: int = 0
var carry_moved: bool = false
var clock: float = 0.0
var target_rect = Rect2()
var arrow_tip = Vector2.ZERO
var blockers: Array[ColorRect] = []
var card: Panel
var heading: Label
var words: Label
var counter: Label
var next_button: Button
var skip_button: Button
var skip_step: Button
var old_focus: Dictionary = {}
var focusable: Array[Control] = []
var focus_index: int = 0

func _ready() -> void:
	name = "FirstPlayTutorial"
	size = Vector2(1280,800)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(4):
		var shade = ColorRect.new()
		shade.color = Color(0.1,0.25,0.14,0.12)
		shade.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(shade)
		blockers.append(shade)
	card = UI.panel(self, Rect2(64,174,430,294), UI.CREAM, 22, true)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.add_theme_stylebox_override("panel", UI.style(UI.CREAM,22,GREEN,true))
	counter = UI.label(card,"",Rect2(20,12,390,25),14,GREEN)
	heading = UI.label(card,"",Rect2(20,43,390,39),24)
	words = UI.scroll_text(card,"",Rect2(20,90,390,141),18)
	next_button = UI.button(card,"Next →",Rect2(279,248,131,33),next_step,true)
	next_button.add_theme_font_size_override("font_size",16)
	next_button.name = "TutorialNext"
	skip_button = UI.button(card,"Skip tutorial",Rect2(20,248,116,33),finish)
	skip_button.add_theme_font_size_override("font_size",14)
	skip_button.name = "TutorialSkip"
	skip_step = UI.button(card,"Skip step",Rect2(146,248,119,33),next_step)
	skip_step.add_theme_font_size_override("font_size",14)
	skip_step.name = "TutorialSkipStep"
	hide()

func begin() -> void:
	_restore_focus()
	active = true
	step = 0
	carry_moved = false
	game.progress.tutorial_completed = false
	game._save()
	show()
	_enter_step()

func step_id() -> String:
	return STEPS[step].id

func _enter_step() -> void:
	var id = step_id()
	if id in ["welcome","pet","carry","needs","feed","knowledge","shop","settings","games"]:
		game.close_modal()
	if id == "snack" and game.modal_name != "feed":
		game.open_feed()
	elif id == "book" and game.modal_name != "knowledge":
		game.open_knowledge("events")
	elif id == "catalog" and game.modal_name != "shop":
		game.open_shop()
	elif id == "level" and game.modal_name != "settings":
		game.open_settings()
	elif id == "activities" and game.modal_name != "games":
		game.open_games()
	game.speech.hide()
	if id == "speech":
		game.close_modal()
		game.speech_queue.erase("events")
		game._show_lesson("events")
	game.pip.blocked = id not in ["pet","carry","speech"] or not game.modal_name.is_empty()
	counter.text = "PIP'S FIRST-PLAY TOUR  ·  %d / %d" % [step+1,STEPS.size()]
	heading.text = STEPS[step].title
	words.text = STEPS[step].words
	var action_step = id in ["pet","carry","feed","snack","speech","knowledge","shop","settings","games"]
	next_button.disabled = action_step
	next_button.text = "Follow arrow" if action_step else ("Let's begin →" if id == "welcome" else ("Finish tour" if id == "activities" else "Next →"))
	skip_step.visible = action_step
	if id == "snack" and _snack_button().disabled:
		words.text = "Pip is full, still chewing, or this pouch is empty. Feeding waits until he has room and you have a treat. Games earn more treats. Click Next to continue the tour."
		next_button.disabled = false
		next_button.text = "Next →"
		skip_step.hide()
	_resize_card(350 if id == "speech" else 430)
	_refresh_layout(true)
	_update_focus()
	next_button.grab_focus() if not next_button.disabled else skip_step.grab_focus()

func _resize_card(width: float) -> void:
	card.size = Vector2(width,358 if width < 400 else 318)
	counter.size.x = width-40
	heading.size.x = width-40
	heading.add_theme_font_size_override("font_size",21 if width < 400 else 24)
	words.get_parent().size = Vector2(width-40,card.size.y-153)
	words.get_parent().scroll_vertical = 0
	var y = card.size.y-46
	skip_button.position = Vector2(18,y)
	skip_button.size.x = 104 if width < 400 else 116
	skip_step.position = Vector2(128 if width < 400 else 146,y)
	skip_step.size.x = 87 if width < 400 else 119
	next_button.position = Vector2(width-125 if width < 400 else width-151,y)
	next_button.size.x = 107 if width < 400 else 131
	next_button.add_theme_font_size_override("font_size",14 if width < 400 else 16)

func next_step() -> void:
	if not active:
		return
	if step == STEPS.size()-1:
		finish()
		return
	step += 1
	_enter_step()

func notice(event: String) -> void:
	if not active:
		return
	var id = step_id()
	if id == "carry":
		if event == "move":
			carry_moved = true
		elif event == "land" and carry_moved:
			next_step()
	elif id == "activities" and event == "start_activity":
		finish()
	elif event == {"pet":"pet","feed":"open_feed","snack":"feed","speech":"speech_done","knowledge":"open_knowledge","shop":"open_shop","settings":"open_settings","games":"open_games"}.get(id, ""):
		next_step()

func finish() -> void:
	if not active:
		return
	active = false
	hide()
	_restore_focus()
	game.progress.tutorial_completed = true
	game.pip.blocked = not game.modal_name.is_empty()
	game._save()
	game._say("Have fun exploring!", "You can replay our tour from Settings anytime. Care for me, try a game, or visit the Shop. I'll keep explaining the programming ideas as we play!")

func _restore_focus() -> void:
	# Menus are rebuilt and freed during the tour. Keep stable IDs and weak refs,
	# never freed Node instances as dictionary keys.
	for entry in old_focus.values():
		var control = entry.node.get_ref()
		if is_instance_valid(control):
			control.focus_mode = entry.mode
	old_focus.clear()

func _snack_button() -> Button:
	for kind in ["berry","seed","carrot"]:
		var b = game.overlay.get_node_or_null("Offer_"+kind)
		if is_instance_valid(b) and not b.disabled:
			return b
	return game.overlay.get_node("Offer_berry")

func target_control() -> Control:
	match step_id():
		"feed": return game.ui.get_node("FeedNav")
		"snack": return _snack_button()
		"speech": return game.speech_next
		"knowledge": return game.journal_button
		"book": return game.overlay.get_node_or_null("JournalBody")
		"shop": return game.ui.get_node("ShopNav")
		"settings": return game.ui.get_node("SettingsButton")
		"level": return game.overlay.get_node_or_null("GameLevel")
		"games": return game.ui.get_node("GamesNav")
		"activities": return game.overlay.get_node_or_null("PlayPicnic")
	return null

func _target() -> Rect2:
	var control = target_control()
	if is_instance_valid(control):
		return control.get_global_rect().grow(7)
	match step_id():
		"welcome","pet": return Rect2(game.pip.position+Vector2(-86,-122),Vector2(172,142))
		"carry": return Rect2(game.pip.position+Vector2(-108,-163),Vector2(216,269))
		"needs": return Rect2(400,31,508,84)
		"catalog": return Rect2(149,213,538,56)
	return Rect2(510,332,595,353)

func _process(delta: float) -> void:
	if not active:
		return
	clock += delta
	move_to_front()
	_refresh_layout()
	# Menus may rebuild their controls after a tab or Game level changes.
	_update_focus()
	if step_id() != "speech":
		game.speech.hide()

func _refresh_layout(force: bool = false) -> void:
	target_rect = _target().intersection(Rect2(5,5,1270,790))
	var avoid = game.speech.get_global_rect().grow(12) if step_id() == "speech" else target_rect.grow(22)
	if force or card.get_global_rect().intersects(avoid):
		var candidates = [Vector2(55,170),Vector2(1225-card.size.x,170),Vector2(55,662-card.size.y),Vector2(1225-card.size.x,662-card.size.y)]
		for position_choice in candidates:
			if not Rect2(position_choice,card.size).intersects(avoid):
				card.position = position_choice
				break
	var x = target_rect.position.x
	var y = target_rect.position.y
	var right = target_rect.end.x
	var bottom = target_rect.end.y
	var areas = [Rect2(0,0,1280,y),Rect2(0,y,x,bottom-y),Rect2(right,y,1280-right,bottom-y),Rect2(0,bottom,1280,800-bottom)]
	for i in range(4):
		blockers[i].position = areas[i].position
		blockers[i].size = areas[i].size
	queue_redraw()

func _update_focus() -> void:
	focusable.clear()
	var target = target_control()
	for node in game.ui.find_children("*","Control",true,false):
		if node == self or is_ancestor_of(node):
			continue
		var id: int = node.get_instance_id()
		if node.focus_mode == Control.FOCUS_NONE and not old_focus.has(id):
			continue
		if not old_focus.has(id):
			old_focus[id] = {"node":weakref(node),"mode":node.focus_mode}
		var allowed = node == target or (is_instance_valid(target) and target.is_ancestor_of(node))
		if step_id() == "catalog" and node is Button and node.name in ["PetCategory","RoomCategory"]:
			allowed = true
		if allowed and old_focus[id].mode != Control.FOCUS_NONE and node.is_visible_in_tree():
			if node.focus_mode != old_focus[id].mode:
				node.focus_mode = old_focus[id].mode
			if not node is BaseButton or not node.disabled:
				focusable.append(node)
		elif node.focus_mode != Control.FOCUS_NONE:
			node.focus_mode = Control.FOCUS_NONE
	for b in [next_button,skip_step,skip_button]:
		if b.visible and not b.disabled:
			focusable.append(b)

func _input(event: InputEvent) -> void:
	if not active or not event is InputEventKey or not event.pressed or event.echo:
		return
	# Focus stays in the tour and the highlighted control, not hidden buttons.
	if event.keycode == KEY_TAB and not focusable.is_empty():
		focus_index = focusable.find(get_viewport().gui_get_focus_owner())
		focus_index = posmod(focus_index + (-1 if event.shift_pressed else 1), focusable.size())
		focusable[focus_index].grab_focus()
		get_viewport().set_input_as_handled()

func _draw() -> void:
	if not active or not target_rect.has_area():
		return
	var border = UI.style(Color(0.2,0.8,0.4,0.05),15,GREEN)
	border.set_border_width_all(4)
	draw_style_box(border,target_rect)
	var direction = (target_rect.get_center()-card.get_rect().get_center()).normalized()
	var half_card = card.size/2
	var half_target = target_rect.size/2
	var from_distance = minf(half_card.x/maxf(absf(direction.x),0.001),half_card.y/maxf(absf(direction.y),0.001))
	var to_distance = minf(half_target.x/maxf(absf(direction.x),0.001),half_target.y/maxf(absf(direction.y),0.001))
	var tip = target_rect.get_center()-direction*(to_distance+10)
	var start = card.get_rect().get_center()+direction*(from_distance+9)
	if start.distance_to(tip) < 42:
		start = tip-direction*62
	if not game.progress.calm:
		tip -= direction*(3+sin(clock*3)*3)
	arrow_tip = tip
	draw_line(start,tip,UI.CREAM,12,true)
	draw_line(start,tip,GREEN,7,true)
	var side = direction.orthogonal()
	draw_colored_polygon(PackedVector2Array([tip,tip-direction*24+side*15,tip-direction*24-side*15]),UI.CREAM)
	draw_colored_polygon(PackedVector2Array([tip,tip-direction*21+side*11,tip-direction*21-side*11]),GREEN)
