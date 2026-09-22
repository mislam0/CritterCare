extends Control
## Optional arcade play: collect ten snacks at your own pace. No lives or countdown.
## The coordinator owns permanent rewards; this node owns only the current round.

signal changed
signal caught(kind: String)
signal finished(report: Dictionary)
signal pause_changed(value: bool)

const UI = preload("res://scripts/ui.gd")
const Icon = preload("res://scripts/icon.gd")
const Hamster = preload("res://scripts/hamster.gd")
const GOAL = 10
var stage: int = 0
var gentle: bool = false
var cosmetics: Dictionary = {}
var running: bool = false
var paused: bool = false
var completed: bool = false
var collected: int = 0
var streak: int = 0
var best_streak: int = 0
var seed_gold: int = 0
var misses: int = 0
var spawned: int = 0
var spawn_clock: float = 0.0
var player_x: float = 323.0
var target_x: float = 323.0
var button_direction: float = 0.0
var items: Array = []
var floaties: Array = []
var feedback: String = "Ready when you are! Press Start picnic."
var actor
var basket: Node2D
var pause_shade: Panel
var rng = RandomNumberGenerator.new()

class Basket extends Node2D:
	func _draw() -> void:
		draw_colored_polygon(PackedVector2Array([Vector2(-55,0),Vector2(55,0),Vector2(43,38),Vector2(-43,38)]), Color("c99a5e"))
		for x in range(-36, 45, 18):
			draw_line(Vector2(x,4), Vector2(x*0.77,34), Color("e8c28a"), 4, true)
		for y in [13,25]:
			draw_line(Vector2(-48,y),Vector2(48,y),Color("ac7f4b"),2,true)
		draw_line(Vector2(-55,0),Vector2(55,0),Color("f0d5a1"),8,true)

func _ready() -> void:
	name = "PicnicField"
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	rng.randomize()
	player_x = size.x / 2
	target_x = player_x
	actor = Hamster.new()
	actor.blocked = true
	actor.calm = gentle
	actor.cosmetic_items = cosmetics
	actor.scale = Vector2.ONE * 0.42
	add_child(actor)
	basket = Basket.new()
	add_child(basket)
	pause_shade = UI.panel(self, Rect2(Vector2.ZERO, size), Color(0.98,0.98,0.92,0.91), 18)
	UI.label(pause_shade, "Picnic paused", Rect2(45,125,size.x-90,54), 32, UI.GREEN, true)
	UI.label(pause_shade, "Your snacks will wait. Tap Resume when you are ready.", Rect2(65,190,size.x-130,75), 20, UI.INK, true)
	pause_shade.hide()
	_update_player()

func start() -> void:
	if running or completed:
		return
	running = true
	feedback = "Move under a berry. IF the basket catches it THEN add one snack!"
	spawn_item("berry", player_x)
	grab_focus()
	changed.emit()

func stop() -> void:
	running = false
	button_direction = 0
	set_process(false)

func set_paused(value: bool) -> void:
	if not running or completed or paused == value:
		return
	paused = value
	button_direction = 0
	pause_shade.visible = paused
	pause_shade.move_to_front()
	pause_changed.emit(paused)
	if not paused:
		grab_focus()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		set_paused(true)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and running:
		if event.pressed and not event.echo and event.keycode == KEY_SPACE:
			set_paused(not paused)
			accept_event()
		elif event.keycode in [KEY_LEFT, KEY_RIGHT, KEY_A, KEY_D]:
			accept_event()
		return
	if not running or paused:
		return
	if event is InputEventMouseMotion:
		move_to_pointer(event.position.x)
	elif event is InputEventMouseButton and event.pressed:
		move_to_pointer(event.position.x)
		grab_focus()
	elif event is InputEventScreenTouch and event.pressed:
		move_to_pointer(event.position.x)
	elif event is InputEventScreenDrag:
		move_to_pointer(event.position.x)

func move_to_pointer(x: float) -> void:
	target_x = clampf(x, 60, size.x - 60)

func _process(delta: float) -> void:
	if not running or paused or completed:
		return
	# Pause on focus loss; cap a stray long frame so objects cannot teleport.
	delta = minf(delta, 0.05)
	var direction = button_direction
	if Input.is_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A):
		direction -= 1
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D):
		direction += 1
	if direction != 0:
		target_x = clampf(player_x + signf(direction) * 620 * delta, 60, size.x-60)
	player_x = move_toward(player_x, target_x, 620 * delta)
	actor.clock += delta
	actor.happy_time = maxf(0, actor.happy_time-delta)
	actor._update_costume_pose()
	actor.queue_redraw()
	_update_player()
	spawn_clock += delta
	var interval = 1.75 if gentle or stage == 0 else 1.45
	if spawn_clock >= interval:
		spawn_clock = 0
		spawn_item(next_kind(), rng.randf_range(65, size.x-65))
	advance_items(delta)
	for f in floaties:
		f.life -= delta
		f.node.position.y -= delta * 23
		f.node.modulate.a = clampf(f.life, 0, 1)
	for i in range(floaties.size()-1, -1, -1):
		if floaties[i].life <= 0:
			floaties[i].node.queue_free()
			floaties.remove_at(i)

func _update_player() -> void:
	actor.position = Vector2(player_x, catch_y()-14)
	basket.position = Vector2(player_x, catch_y())

func catch_y() -> float:
	return size.y-67

func next_kind() -> String:
	if stage >= 2 and (spawned+1) % 4 == 0:
		return "leaf"
	if stage >= 1 and (spawned+1) % 3 == 0:
		return "seed"
	return "berry"

func spawn_item(kind: String, x: float) -> void:
	var icon = Icon.new()
	icon.kind = "golden_seed" if kind == "seed" else kind
	icon.size = Vector2(37,37)
	icon.position = Vector2(clampf(x,60,size.x-60)-18.5,-38)
	add_child(icon)
	items.append({"kind":kind, "x":icon.position.x+18.5, "y":-19.5, "speed":100.0 if gentle or stage == 0 else 128.0, "node":icon})
	spawned += 1
	pause_shade.move_to_front()

func advance_items(delta: float) -> void:
	if not running or paused or completed:
		return
	# Sweep across the catch line so a low frame rate cannot skip a collision.
	for i in range(items.size()-1, -1, -1):
		var item: Dictionary = items[i]
		var old_y: float = item.y
		item.y += item.speed * delta
		item.node.position.y = item.y - 18.5
		if old_y <= catch_y() and item.y >= catch_y() and absf(item.x-player_x) <= 57:
			var kind: String = item.kind
			item.node.queue_free()
			items.remove_at(i)
			resolve_catch(kind)
			if completed:
				return
		elif item.y > size.y+24:
			if item.kind != "leaf":
				misses += 1
				streak = 0
				feedback = "Missed one? That's okay! Keep your snacks and try the next berry."
				changed.emit()
			item.node.queue_free()
			items.remove_at(i)

func resolve_catch(kind: String) -> void:
	if not running or paused or completed:
		return
	if kind == "leaf":
		streak = 0
		feedback = "A leaf! ELSE means otherwise: leave it. Your snacks and earned gold are safe."
		_pop("Oops, a leaf!", UI.MUTED)
	else:
		collected += 1
		streak += 1
		best_streak = maxi(best_streak, streak)
		if kind == "seed":
			seed_gold += 2
			feedback = "Golden seed! IF it is a seed THEN add one snack AND two bonus gold."
		else:
			feedback = "Caught it! Snacks: %d + 1 = %d. That number is a variable: it remembers our count." % [collected-1, collected]
		_pop("+1 snack" + (" · +2 gold" if kind == "seed" else ""), UI.GREEN)
		actor.happy_time = 0.8
		caught.emit(kind)
	changed.emit()
	if collected >= GOAL:
		completed = true
		running = false
		finished.emit({"snacks":collected, "best_streak":best_streak, "seed_gold":seed_gold, "misses":misses})

func _pop(words: String, color: Color) -> void:
	for f in floaties:
		f.node.position.y -= 32
	var label = UI.label(self, words, Rect2(clampf(player_x-110, 0, size.x-220), catch_y()-110, 220, 31), 17, color, true)
	floaties.append({"node":label,"life":1.4})

func _draw() -> void:
	draw_style_box(UI.style(Color("e6efe1"),18), Rect2(Vector2.ZERO,size))
	draw_circle(Vector2(size.x-63,57),29,Color("f4d785"))
	for cloud in [Vector2(102,54),Vector2(389,79)]:
		draw_style_box(UI.style(Color("fafaf0"),16),Rect2(cloud,Vector2(87,24)))
	# Leaves frame the upper edge, outside the catching area.
	for x in range(0, int(size.x)+30, 46):
		draw_circle(Vector2(x,-14),38,Color("b8cfaa"))
	draw_rect(Rect2(0,size.y-42,size.x,42),Color("c9d9b9"))
	for x in range(22, int(size.x), 53):
		draw_line(Vector2(x,size.y-17),Vector2(x+5,size.y-25),Color("a8bd97"),2,true)
	draw_line(Vector2(17,catch_y()),Vector2(size.x-17,catch_y()),Color(0.4,0.57,0.36,0.22),1,true)
