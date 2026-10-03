extends Control
## Block editor and visual trace player. The coordinator owns permanent rewards.

signal solved(challenge_id: String)
signal back_requested
signal next_requested

const Text = preload("res://data/game_text.gd")
var game_level: String = "kindergarten"
const UI = preload("res://scripts/ui.gd")
const Lab = preload("res://data/logic_lab.gd")
const Hamster = preload("res://scripts/hamster.gd")
const Icon = preload("res://scripts/icon.gd")
var mission: Dictionary
var program: Array = []
var gentle: bool = false
var cosmetics: Dictionary = {}
var already_completed: bool = false
var active: bool = false
var autoplay: bool = false
var solved_once: bool = false
var report: Dictionary = {}
var trace_index: int = 0
var clock: float = 0
var attempts: int = 0
var hint_index: int = 0
var state: Dictionary = {}
var palette_cards: Array = []
var slots: Array = []
var row_cards: Array = []
var row_controls: Array = []
var row_labels: Array = []
var actor
var actor_target = Vector2.ZERO
var food_icon: Control
var world: Panel
var feedback: UI.LearningText
var stats: UI.LearningText
var visit_label: UI.LearningText
var progress_label: UI.LearningText
var run_button: Button
var step_button: Button
var stop_button: Button
var clear_button: Button
var hint_button: Button
var next_button: Button
var highlighted: int = -1
var seed_jar

class SeedJar extends Control:
	var count: int = 0
	func _draw() -> void:
		draw_style_box(preload("res://scripts/ui.gd").style(Color("f8fcf2"),13,Color("96ac94")),Rect2(8,11,91,94))
		draw_style_box(preload("res://scripts/ui.gd").style(Color("cbae79"),6),Rect2(5,3,97,17))
		for i in range(mini(count,20)):
			var point = Vector2(25+(i%4)*19,91-floori(float(i)/4)*15)
			draw_circle(point,6,Color("d9b04e"))
			draw_line(point+Vector2(0,-3),point+Vector2(0,3),Color("b28631"),1.5,true)

class BlockCard extends Button:
	var lab
	var block_id: String = ""
	var row: int = -1
	func _get_drag_data(_point: Vector2):
		if lab.active or block_id.is_empty():
			return null
		var preview = Panel.new()
		preview.size = Vector2(260,64)
		preview.theme = lab.theme
		preview.add_theme_stylebox_override("panel",lab.UI.style(lab.UI.CREAM,12))
		lab.UI.label(preview,lab.Lab.BLOCKS[block_id].title,Rect2(10,4,240,56),16)
		set_drag_preview(preview)
		return {"lab":lab.get_instance_id(),"block":block_id,"row":row}
	func _can_drop_data(_point: Vector2, data: Variant) -> bool:
		return row >= 0 and lab.can_drop(data)
	func _drop_data(_point: Vector2, data: Variant) -> void:
		lab.drop_block(row,data)

class DropSlot extends Panel:
	var lab
	var row: int = 0
	func _can_drop_data(_point: Vector2, data: Variant) -> bool:
		return lab.can_drop(data)
	func _drop_data(_point: Vector2, data: Variant) -> void:
		lab.drop_block(row,data)

func _ready() -> void:
	name = "LogicLabEditor"
	size = Vector2(974,518)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.scroll_text(self,"YOUR GOAL · " + mission.goal,Rect2(0,0,974,56),20,UI.GREEN).name = "LabGoal"
	progress_label = UI.label(self,Text.line("lab_order",game_level),Rect2(0,60,974,29),16,UI.MUTED)
	UI.label(self,"1. CHOOSE BLOCKS",Rect2(0,91,226,24),14,UI.GREEN)
	UI.label(self,"2. YOUR PROGRAM · TOP TO BOTTOM",Rect2(238,91,354,24),14,UI.GREEN)
	UI.label(self,"3. WATCH WHAT HAPPENS",Rect2(604,91,370,24),14,UI.GREEN)
	for i in range(mission.palette.size()):
		var id: String = mission.palette[i]
		var card = _card(self,id,Rect2(0,120+i*53,226,52))
		card.name = "Add_" + id
		card.pressed.connect(func(): add_block(id))
		palette_cards.append(card)
	for i in range(Lab.MAX_BLOCKS):
		var slot = DropSlot.new()
		slot.lab = self
		slot.row = i
		slot.position = Vector2(238,120+i*53)
		slot.size = Vector2(354,52)
		add_child(slot)
		slots.append(slot)
		UI.label(slot,str(i+1),Rect2(3,2,24,44),16,UI.MUTED,true)
		var empty = UI.label(slot,"Drop a block here",Rect2(33,4,280,40),16,UI.MUTED)
		row_labels.append(empty)
		var card = _card(slot,"",Rect2(29,1,211,50))
		card.row = i
		card.name = "ProgramBlock%d" % i
		card.tooltip_text = "Drag to reorder, or use the up and down buttons."
		row_cards.append(card)
		var up = UI.button(slot,"↑",Rect2(244,4,33,40),func(): move_block(i,-1))
		var down = UI.button(slot,"↓",Rect2(280,4,33,40),func(): move_block(i,1))
		var remove = UI.button(slot,"×",Rect2(316,4,33,40),func(): remove_block(i))
		up.tooltip_text = "Move instruction %d up" % (i+1)
		down.tooltip_text = "Move instruction %d down" % (i+1)
		remove.tooltip_text = "Remove instruction %d" % (i+1)
		row_controls.append([up,down,remove])
	world = UI.panel(self,Rect2(604,120,370,260),Color("eef0df"),18)
	world.clip_contents = true
	visit_label = UI.label(world,"",Rect2(14,8,342,25),15,UI.GREEN)
	stats = UI.label(world,"",Rect2(14,37,342,60),18,UI.INK)
	for i in range(4):
		var tile = UI.panel(world,Rect2(14+i*87,188,80,34),Color("dfcfaa"),9)
		UI.label(tile,str(i),Rect2(0,0,80,33),15,UI.INK,true)
		tile.visible = mission.bowl >= 0
	seed_jar = SeedJar.new()
	seed_jar.position = Vector2(235,104)
	seed_jar.size = Vector2(108,110)
	seed_jar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	seed_jar.visible = mission.bowl < 0
	world.add_child(seed_jar)
	food_icon = Icon.new()
	food_icon.kind = "berry"
	food_icon.size = Vector2(31,31)
	food_icon.position = Vector2(37+maxi(0,mission.bowl)*87,150)
	food_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world.add_child(food_icon)
	actor = Hamster.new()
	actor.blocked = true
	actor.calm = gentle
	actor.cosmetic_items = cosmetics
	actor.scale = Vector2.ONE * 0.34
	world.add_child(actor)
	UI.label(world,Text.line("lab_safe",game_level),Rect2(12,228,346,25),14,UI.MUTED,true)
	feedback = UI.feedback_text(self,Text.line("lab_edit",game_level),Rect2(0,387,974,83),18)
	feedback.name = "LabFeedback"
	UI.button(self,"Lab menu",Rect2(0,477,114,39),func(): back_requested.emit()).name = "LabBack"
	hint_button = UI.button(self,"Hint",Rect2(123,477,76,39),show_hint)
	hint_button.name = "LabHint"
	clear_button = UI.button(self,"Clear",Rect2(208,477,80,39),clear_program)
	clear_button.name = "LabClear"
	step_button = UI.button(self,"Step",Rect2(303,477,103,39),step_run)
	step_button.name = "LabStep"
	run_button = UI.button(self,"Run  ▶",Rect2(415,477,142,39),toggle_run,true)
	run_button.name = "LabRun"
	stop_button = UI.button(self,"Stop / edit",Rect2(566,477,144,39),stop_run)
	stop_button.name = "LabStop"
	next_button = UI.button(self,"Next challenge →",Rect2(754,477,220,39),func(): next_requested.emit(),true)
	next_button.name = "LabNext"
	next_button.hide()
	_reset_world()
	refresh_blocks()

func _card(parent: Node, id: String, rect: Rect2) -> BlockCard:
	var card = BlockCard.new()
	card.lab = self
	card.block_id = id
	card.position = rect.position
	card.size = rect.size
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if not id.is_empty():
		var color: Color = {"action":UI.CREAM,"check":Color("e6edf4"),"repeat":Color("f5ead0"),"recipe":Color("f1e7ed")}[Lab.BLOCKS[id].kind]
		card.add_theme_stylebox_override("normal",UI.style(color,15,Color("d6dfce")))
	parent.add_child(card)
	var words = UI.label(card,Lab.BLOCKS[id].title if not id.is_empty() else "",Rect2(8,1,rect.size.x-16,rect.size.y-2),15)
	words.add_theme_constant_override("line_separation",0)
	words.name = "Words"
	card.tooltip_text = "Add: " + (Lab.BLOCKS[id].title if not id.is_empty() else "instruction")
	return card

func refresh_blocks() -> void:
	for i in range(Lab.MAX_BLOCKS):
		var filled = i < program.size()
		slots[i].add_theme_stylebox_override("panel",UI.style(Color("d4ebc2") if i == highlighted else Color("eef0e7"),10,UI.GREEN if i == highlighted else Color("d7dece")))
		row_cards[i].visible = filled
		row_labels[i].visible = not filled
		if filled:
			row_cards[i].block_id = program[i]
			row_cards[i].get_node("Words").words = Lab.BLOCKS[program[i]].title
			row_cards[i].disabled = active
		for j in range(3):
			row_controls[i][j].visible = filled
			row_controls[i][j].disabled = active or (j == 0 and i == 0) or (j == 1 and i == program.size()-1)
	for card in palette_cards:
		card.disabled = active or program.size() >= Lab.MAX_BLOCKS
	clear_button.disabled = active or program.is_empty()
	step_button.disabled = autoplay or program.is_empty()
	run_button.disabled = program.is_empty()
	run_button.text = "Pause" if autoplay else ("Resume" if active else "Run  ▶")
	stop_button.disabled = not active
	hint_button.disabled = active

func can_drop(data: Variant) -> bool:
	return not active and data is Dictionary and data.get("lab") == get_instance_id() and mission.palette.has(data.get("block")) and (int(data.get("row",-1)) >= 0 or program.size() < Lab.MAX_BLOCKS)

func drop_block(target: int, data: Dictionary) -> void:
	if not can_drop(data):
		return
	var source = int(data.row)
	var id: String = data.block
	if source >= 0:
		if source >= program.size(): return
		program.remove_at(source)
	program.insert(clampi(target,0,program.size()),id)
	_program_changed()

func add_block(id: String) -> void:
	if active or program.size() >= Lab.MAX_BLOCKS or not mission.palette.has(id):
		return
	program.append(id)
	_program_changed()

func move_block(index: int, offset: int) -> void:
	var target = index+offset
	if active or index < 0 or index >= program.size() or target < 0 or target >= program.size():
		return
	var id = program[index]
	program.remove_at(index)
	program.insert(target,id)
	_program_changed()

func remove_block(index: int) -> void:
	if active or index < 0 or index >= program.size(): return
	program.remove_at(index)
	_program_changed()

func clear_program() -> void:
	if active: return
	program.clear()
	_program_changed()

func _program_changed() -> void:
	highlighted = -1
	_reset_world()
	UI.neutral_feedback(feedback)
	feedback.words = "%d / %d blocks. " % [program.size(),Lab.MAX_BLOCKS] + Text.line("lab_edit",game_level)
	refresh_blocks()

func show_hint() -> void:
	UI.neutral_feedback(feedback)
	feedback.words = "Pip's hint: " + mission.hints[mini(hint_index,mission.hints.size()-1)]
	hint_index += 1

func begin_run() -> bool:
	report = Lab.present_report(Lab.execute(mission,program),mission,game_level)
	if not report.valid:
		feedback.words = report.message
		UI.show_feedback(feedback,false)
		return false
	active = true
	trace_index = 0
	clock = 0
	attempts += 1
	UI.neutral_feedback(feedback)
	progress_label.words = "Try %d · " % attempts + Text.line("lab_test",game_level)
	_reset_world()
	return true

func toggle_run() -> void:
	if not active and not begin_run(): return
	autoplay = not autoplay
	clock = 0
	if autoplay and trace_index == 0:
		advance_trace()
	refresh_blocks()

func step_run() -> void:
	if autoplay: return
	if not active and not begin_run(): return
	advance_trace()
	refresh_blocks()

func stop_run() -> void:
	active = false
	autoplay = false
	highlighted = -1
	UI.neutral_feedback(feedback)
	feedback.words = Text.line("lab_stopped",game_level)
	refresh_blocks()

func stop() -> void:
	active = false
	autoplay = false
	set_process(false)

func advance_trace() -> void:
	if not active: return
	if trace_index >= report.trace.size():
		finish_run()
		return
	var current: Dictionary = report.trace[trace_index]
	state = current.state.duplicate(true)
	highlighted = current.row
	feedback.words = "Pip: " + current.words
	if current.action in ["pass","error"]: UI.show_feedback(feedback,current.action == "pass")
	else: UI.neutral_feedback(feedback)
	visit_label.words = "Visit %d of %d · %s" % [current.visit,mission.cases.size(),"testing" if current.action != "pass" else "works!"]
	if current.action == "setup":
		actor.eating_time = 0
		actor.happy_time = 0
		actor.floaties.clear()
	elif current.action == "feed":
		actor.eat("berry")
	elif current.action == "pet":
		actor.pet()
	elif str(current.action).begins_with("add"):
		actor.happy_time = 0.7
	_update_world(current.action == "setup")
	trace_index += 1
	refresh_blocks()
	if trace_index >= report.trace.size():
		finish_run()

func finish_run() -> void:
	if not active: return
	active = false
	autoplay = false
	highlighted = -1
	feedback.words = "Pip: " + report.message
	UI.show_feedback(feedback,report.success,"✓ PLAN WORKS!" if report.success else "✕ TRY AGAIN!")
	if report.success:
		progress_label.words = "Program complete! " + ("Already collected: practice as often as you like." if already_completed else "First solution: +25 gold and +2 berries.")
		next_button.show()
		actor.happy_time = 2.0
		solved_once = true
		solved.emit(mission.id)
		already_completed = true
	else:
		progress_label.words = Text.line("lab_retry",game_level)
	refresh_blocks()

func _reset_world() -> void:
	state = Lab.initial_state(mission.cases[0])
	visit_label.words = "Visit 1 of %d · ready" % mission.cases.size()
	actor.eating_time = 0
	actor.happy_time = 0
	actor.floaties.clear()
	_update_world(true)

func _update_world(snap: bool = false) -> void:
	stats.words = "Seeds in jar: %d\nGoal: exactly 6" % state.seeds if mission.bowl < 0 else "Fullness %d   ·   Happiness %d\nHungry: %s   ·   Berry: %s" % [state.fullness,state.happiness,"yes" if state.fullness < 60 else "no","yes" if state.has_food else "no"]
	food_icon.visible = mission.bowl >= 0 and state.has_food
	seed_jar.count = state.seeds
	seed_jar.queue_redraw()
	actor_target = Vector2(54+state.position*87 if mission.bowl >= 0 else 105,163)
	if snap or gentle:
		actor.position = actor_target

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and active and autoplay:
		autoplay = false
		refresh_blocks()

func _process(delta: float) -> void:
	delta = minf(delta,0.05)
	actor.position = actor.position.lerp(actor_target,minf(1.0,delta*8))
	actor.clock += delta
	actor.happy_time = maxf(0,actor.happy_time-delta)
	actor.eating_time = maxf(0,actor.eating_time-delta)
	for f in actor.floaties:
		f.p.y -= delta*40
		f.life -= delta
	actor.floaties = actor.floaties.filter(func(f): return f.life > 0)
	actor._update_costume_pose()
	actor.queue_redraw()
	if active and autoplay:
		clock += delta
		var words = str(report.trace[maxi(0,trace_index-1)].words).split(" ").size()
		var reading_time = clampf(float(words)*0.25,2.4,7.0)
		if clock >= reading_time:
			clock = 0
			advance_trace()
