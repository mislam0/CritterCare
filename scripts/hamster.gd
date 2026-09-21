extends Node2D
## Pip is drawn from editable vector shapes. Body and paws use damped springs
## rather than sprite frames, so dragging works smoothly in every direction.

signal interacted(action: String)

const FLOOR_Y = 516.0
const GRAVITY = 1400.0
var is_held: bool = false
var is_falling: bool = false
var blocked: bool = false
var calm: bool = false
var velocity = Vector2.ZERO
var pointer_down: bool = false
var press_position = Vector2.ZERO
var grab_offset = Vector2.ZERO
var press_duration: float = 0.0
var angle: float = 0.0
var angular_velocity: float = 0.0
var paw_angle: float = 0.0
var paw_velocity: float = 0.0
var clock: float = 0.0
var idle_time: float = 0.0
var happy_time: float = 0.0
var groom_time: float = 0.0
var eating_time: float = 0.0
var food_kind: String = "berry"
var squish: float = 0.0
var moved_since_pickup: bool = false
var pickup_position = Vector2.ZERO
var direction: String = "resting"
var floaties: Array = []
var last_pointer = Vector2.ZERO

func _ready() -> void:
	last_pointer = get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if blocked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local = get_local_mouse_position()
		if hit_test(local):
			pointer_down = true
			press_duration = 0.0
			press_position = get_global_mouse_position()
			grab_offset = position - press_position
			get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	# Release is handled even if the mouse is now above a UI control.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and pointer_down:
		pointer_down = false
		if is_held:
			release()
		elif not blocked:
			var local = to_local(press_position)
			if head_test(local):
				pet()
			else:
				interacted.emit("body_click")
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and pointer_down:
		pointer_down = false
		if is_held:
			release()

func hit_test(point: Vector2) -> bool:
	# Transform back through the drawn body's rotation, then include ears,
	# paws and tail as well as the main silhouette. Grabbing any part works.
	point = point.rotated(-angle * (0.45 if calm else 1.0))
	if pow(point.x / 98.0, 2) + pow((point.y + 14) / 123.0, 2) <= 1.0:
		return true
	for center in [Vector2(-58, -96), Vector2(58, -96), Vector2(-43, 75), Vector2(43, 75), Vector2(77, 47)]:
		if point.distance_to(center) <= 28:
			return true
	return false

func head_test(point: Vector2) -> bool:
	return pow(point.x / 82.0, 2) + pow((point.y + 53) / 69.0, 2) <= 1.0

func pick_up() -> void:
	is_held = true
	is_falling = false
	eating_time = 0.0
	groom_time = 0.0
	idle_time = 0.0
	moved_since_pickup = false
	pickup_position = position
	interacted.emit("pickup")

func release() -> void:
	is_held = false
	is_falling = true
	velocity = velocity.limit_length(850.0)
	if position.y < FLOOR_Y - 30:
		interacted.emit("drop")
	else:
		interacted.emit("put_down")

func pet() -> void:
	happy_time = 1.8
	idle_time = 0.0
	groom_time = 0.0
	for i in range(5):
		floaties.append({"p": Vector2(randf_range(-70, 70), randf_range(-140, -95)), "life":1.5 + randf() * 0.4, "kind":"heart"})
	interacted.emit("pet")

func eat(kind: String) -> void:
	food_kind = kind
	eating_time = 1.8
	idle_time = 0.0
	happy_time = 0.0
	groom_time = 0.0
	interacted.emit("feed")

func _physics_process(delta: float) -> void:
	if blocked:
		return
	clock += delta
	if pointer_down and not is_held:
		press_duration += delta
		if press_duration >= 0.22 or get_global_mouse_position().distance_to(press_position) > 9:
			pick_up()
	if is_held:
		# A spring pulls the grabbed point toward the mouse. The body trails it.
		var target = get_global_mouse_position() + grab_offset
		target.x = clampf(target.x, 142, 1138)
		target.y = clampf(target.y, 268, FLOOR_Y)
		var spring = 105.0 if not calm else 140.0
		velocity += ((target - position) * spring - velocity * 16.0) * delta
		position += velocity * delta
		position.x = clampf(position.x, 140, 1140)
		position.y = clampf(position.y, 248, FLOOR_Y + 6)
		var lean = clampf(velocity.x / 850.0 + grab_offset.x / 190.0, -0.75, 0.75)
		angular_velocity += ((lean - angle) * 38.0 - angular_velocity * 6.0) * delta
		if velocity.length() > 45:
			if absf(velocity.x) > absf(velocity.y):
				direction = "moving right" if velocity.x > 0 else "moving left"
			else:
				direction = "moving down" if velocity.y > 0 else "moving up"
		else:
			direction = "being held"
		if not moved_since_pickup and position.distance_to(pickup_position) > 50:
			moved_since_pickup = true
			interacted.emit("move")
	elif is_falling:
		velocity.y += GRAVITY * delta
		position += velocity * delta
		direction = "soft landing"
		if position.x < 140 or position.x > 1140:
			position.x = clampf(position.x, 140, 1140)
			velocity.x *= -0.35
		if position.y >= FLOOR_Y:
			position.y = FLOOR_Y
			squish = minf(0.22, absf(velocity.y) / 4500.0)
			if absf(velocity.y) > 155.0 and not calm:
				velocity.y *= -0.24
				velocity.x *= 0.6
				angular_velocity += velocity.x / 120.0
			else:
				is_falling = false
				velocity = Vector2.ZERO
				interacted.emit("land")
		angular_velocity += (-angle * 18.0 - angular_velocity * 2.5) * delta
	else:
		direction = "resting"
		angular_velocity += (-angle * 45.0 - angular_velocity * 9.0) * delta
		idle_time += delta
		if idle_time >= 12.0 and eating_time <= 0 and happy_time <= 0:
			groom_time = 2.5
			idle_time = 0.0
			interacted.emit("groom")
	angle += angular_velocity * delta
	angle = clampf(angle, -1.0, 1.0)
	# A separate spring makes paws/ears lag behind the swinging body.
	var paw_target = -angular_velocity * 0.35 + (sin(clock * 4.0) * 0.18 if is_held else 0.0)
	paw_velocity += ((paw_target - paw_angle) * 28.0 - paw_velocity * 5.0) * delta
	paw_angle = clampf(paw_angle + paw_velocity * delta, -0.8, 0.8)
	squish = move_toward(squish, 0, delta * 1.2)
	happy_time = maxf(0, happy_time - delta)
	groom_time = maxf(0, groom_time - delta)
	if eating_time > 0:
		eating_time = maxf(0, eating_time - delta)
		if eating_time == 0:
			happy_time = 1.0
			interacted.emit("chew_done")
	for f in floaties:
		f.p.y -= delta * 40
		f.life -= delta
	floaties = floaties.filter(func(f): return f.life > 0)
	queue_redraw()

func ellipse(center: Vector2, radii: Vector2, color: Color, outline: Color = Color.TRANSPARENT, width: float = 2.4) -> void:
	var points = PackedVector2Array()
	for i in range(65):
		var a = TAU * i / 64.0
		points.append(center + Vector2(cos(a), sin(a)) * radii)
	draw_colored_polygon(points, color)
	if outline.a > 0:
		draw_polyline(points, outline, width, true)

func _draw() -> void:
	var ink = Color("795944")
	var fur = Color("cda477")
	var light_fur = Color("e4bd8c")
	var cream = Color("fff0d4")
	var pink = Color("eab6a2")
	var breath = sin(clock * 2.3) * (0.012 if not calm else 0.005)
	var chew = sin((1.8 - eating_time) * TAU / 0.6) if eating_time > 0 else 0.0
	var lean = angle * (0.45 if calm else 1.0)
	# The ground shadow stays on the floor when the hamster is lifted.
	var height = FLOOR_Y - position.y
	var shadow_width = 78.0 - minf(height * 0.12, 30.0)
	ellipse(Vector2(0, FLOOR_Y - position.y + 85), Vector2(shadow_width, 12), Color(0.25, 0.28, 0.18, 0.15))
	draw_set_transform(Vector2(0, -breath * 30), lean, Vector2(1 + squish + breath, 1 - squish - breath))
	# Tail, body and dangling feet.
	ellipse(Vector2(77, 47), Vector2(17, 15), pink, ink)
	var dangle = 11.0 if is_held or is_falling else 0.0
	for side in [-1, 1]:
		var foot = Vector2(side * 43 + paw_angle * 22, 75 + dangle)
		if is_held:
			draw_line(Vector2(side * 40, 53), foot, fur.darkened(0.08), 17, true)
		ellipse(foot, Vector2(24, 13 if not is_held else 19), pink, ink)
		for j in range(2):
			draw_line(foot + Vector2(-5 + j * 8, 3), foot + Vector2(-5 + j * 8, 9), Color("c68c7e"), 1.7, true)
	ellipse(Vector2(0, 11), Vector2(84, 77), fur, ink)
	ellipse(Vector2(0, 30), Vector2(58, 57), cream)
	# Ears lag with the paw spring.
	for side in [-1, 1]:
		var ear = Vector2(side * 58 + paw_angle * 5, -96 + side * paw_angle * 5)
		ellipse(ear, Vector2(26, 28), fur, ink)
		ellipse(ear + Vector2(0, 2), Vector2(16, 17), pink)
	# Round head with cheeks and a cream muzzle.
	ellipse(Vector2(0, -40), Vector2(80 + chew * 2, 67), light_fur, ink)
	ellipse(Vector2(-46, -9), Vector2(34, 29), cream)
	ellipse(Vector2(46, -9), Vector2(34, 29), cream)
	ellipse(Vector2(0, 0), Vector2(46, 31), cream)
	# Forehead markings.
	for i in [-1, 0, 1]:
		draw_line(Vector2(i * 9, -104 + abs(i) * 3), Vector2(i * 7, -85 + abs(i) * 2), fur.darkened(0.05), 5, true)
	var look = (get_global_mouse_position() - position) / 120.0 if is_inside_tree() else Vector2.ZERO
	look = look.limit_length(4.0)
	var blink = fmod(clock, 4.7) > 4.51
	var happy = happy_time > 0 or groom_time > 0
	for side in [-1, 1]:
		var eye = Vector2(side * 32, -46) + look
		if happy or blink:
			draw_arc(eye + Vector2(0, 5), 9, PI + 0.2, TAU - 0.2, 18, Color("473b32"), 3.5, true)
		else:
			ellipse(eye, Vector2(7, 10 if is_held else 9), Color("423930"))
			ellipse(eye + Vector2(2, -3), Vector2(2.3, 3), Color("fffdf6"))
		ellipse(Vector2(side * 52, -22), Vector2(15, 7), Color(0.9, 0.56, 0.49, 0.48))
	# Nose and tiny smile.
	ellipse(Vector2(0, -17), Vector2(8, 5.5), Color("ab7768"))
	draw_line(Vector2(0, -13), Vector2(0, -6), ink, 2.1, true)
	if is_held:
		ellipse(Vector2(0, 2), Vector2(6, 7), Color("956652"))
	else:
		draw_arc(Vector2(-6, -7), 6, 0.0, PI, 18, ink, 2.2, true)
		draw_arc(Vector2(6, -7), 6, 0.0, PI, 18, ink, 2.2, true)
	for side in [-1, 1]:
		for j in range(2):
			draw_line(Vector2(side * 62, -7 + j * 9), Vector2(side * 89, -12 + j * 16), Color("a68663"), 1.5, true)
	# Paws: dangling, tucked, washing, or holding the current snack.
	for side in [-1, 1]:
		var hand = Vector2(side * 70, 33)
		if is_held or is_falling:
			hand += Vector2(paw_angle * 28, 15 + side * paw_angle * 8)
		elif eating_time > 0:
			hand = Vector2(side * 17, 9 + chew * 3)
		elif groom_time > 0:
			hand = Vector2(side * 35, -38 + sin(clock * 12) * 12)
		elif happy:
			hand = Vector2(side * 74, 15 + sin(clock * 10) * 3)
		draw_line(Vector2(side * 70, 16), hand, fur, 22, true)
		ellipse(hand, Vector2(14, 18), light_fur, ink, 2.0)
		ellipse(hand + Vector2(0, 5), Vector2(8, 6), pink)
	if eating_time > 0:
		var food_color = {"berry":Color("bc5871"), "seed":Color("b69658"), "carrot":Color("ec975a")}.get(food_kind, pink)
		ellipse(Vector2(0, 12 + chew * 3), Vector2(11, 14), food_color)
		draw_line(Vector2(0, 0), Vector2(5, -6), Color("68835c"), 3, true)
	draw_set_transform(Vector2.ZERO)
	for f in floaties:
		var p: Vector2 = f.p
		var col = Color("ce8090")
		col.a = minf(1.0, f.life)
		draw_circle(p + Vector2(-4, -2), 5, col)
		draw_circle(p + Vector2(4, -2), 5, col)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-9, 0), p+Vector2(9, 0), p+Vector2(0, 10)]), col)
