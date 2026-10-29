extends Node2D
## Room fetch toy: one throw, one return reward; focus loss pauses the toy.

signal changed
signal returned
const BALL = preload("res://assets/toys/ball.png")
var pet
var active: bool = false
var paused: bool = false
var state: String = "off"
var home_x: float = 640
var target_x: float = 850
var elapsed: float = 0
var duration: float = 1
var launch: Vector2
var destination: Vector2
var round_returns: int = 0
var ball: Sprite2D

func _ready() -> void:
	ball = Sprite2D.new()
	ball.texture = BALL
	ball.scale = Vector2.ONE * 0.37
	add_child(ball)
	hide()

func start(actor) -> void:
	pet = actor
	if pet.is_held: pet.release()
	pet.is_falling = false
	pet.pointer_down = false
	pet.position.y = pet.FLOOR_Y
	pet.velocity = Vector2.ZERO
	pet.angle = 0
	pet.angular_velocity = 0
	pet.fetching = true
	pet.eating_time = 0
	pet.groom_time = 0
	home_x = pet.position.x
	active = true
	paused = false
	state = "aim"
	round_returns = 0
	ball.position = Vector2(home_x + 44, 589)
	show()
	changed.emit()

func stop() -> void:
	if is_instance_valid(pet):
		pet.fetching = false
		pet.blocked = false
		pet.position.y = pet.FLOOR_Y
		pet.velocity = Vector2.ZERO
		pet.angle = 0
		pet.direction = "resting"
	active = false
	paused = false
	state = "off"
	hide()
	changed.emit()

func resume() -> void:
	if not active: return
	paused = false
	pet.blocked = false
	changed.emit()

func throw_to(point: Vector2) -> bool:
	if not active or paused or state != "aim": return false
	target_x = clampf(point.x, 340, 970)
	if absf(target_x - home_x) < 110:
		target_x = clampf(home_x + (-180 if home_x > 650 else 180), 340, 970)
	launch = ball.position
	destination = Vector2(target_x, 589)
	duration = 0.65 + absf(target_x - home_x) / 1400
	elapsed = 0
	state = "flying"
	pet.direction = "chasing the ball"
	changed.emit()
	return true

func _unhandled_input(event: InputEvent) -> void:
	if not active: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var point = get_global_mouse_position()
		if Rect2(320, 390, 685, 228).has_point(point):
			if paused: resume()
			else: throw_to(point)
			get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if not active or paused: return
	delta = minf(delta, 0.05)
	if state == "aim":
		pet.direction = "ready for a throw"
		return
	elapsed += delta
	if state == "flying":
		var t = minf(1, elapsed / duration)
		ball.position = launch.lerp(destination, t) + Vector2(0, - sin(t * PI) * (45 if pet.calm else 110))
		ball.rotation += delta * 3
		pet.position.x = move_toward(pet.position.x, target_x, 230 * delta)
		if t >= 1:
			state = "chasing"
			elapsed = 0
	elif state == "chasing":
		pet.position.x = move_toward(pet.position.x, target_x, 230 * delta)
		ball.position.y = 589 - (absf(sin(elapsed * 8)) * maxf(0, 12 - elapsed * 8) if not pet.calm else 0)
		if absf(pet.position.x - target_x) < 5:
			state = "returning"
			pet.direction = "bringing the ball back"
			changed.emit()
	elif state == "returning":
		pet.position.x = move_toward(pet.position.x, home_x, 250 * delta)
		ball.position = pet.position + Vector2(0, 30)
		if absf(pet.position.x - home_x) < 2:
			pet.position.x = home_x
			ball.position = Vector2(home_x + 44, 589)
			pet.happy_time = 1.5
			state = "celebrate"
			elapsed = 0
			round_returns += 1
			returned.emit()
			changed.emit()
	elif state == "celebrate" and elapsed >= 0.9:
		state = "aim"
		changed.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and active:
		paused = true
		pet.blocked = true
		changed.emit()
