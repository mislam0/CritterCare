extends Node2D
## Shared animated pet rig. Shop PNG anchors stay compatible across all species.


signal interacted(action: String)

const Looks = preload("res://data/pet_looks.gd")
var appearance: Dictionary = Looks.defaults()
var fetching: bool = false
const Shop = preload("res://data/shop.gd")
var costumes: Node2D
var cosmetic_items: Dictionary = {}

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

var stage_actor: bool = false
var dance_pose: int = 0
var dance_phase: float = 0.0

func set_appearance(value: Dictionary) -> void:
	appearance = Looks.clean(value)
	queue_redraw()

func _ready() -> void:
	appearance = Looks.clean(appearance)
	last_pointer = get_global_mouse_position()
	set_cosmetics(cosmetic_items)

func set_cosmetics(items: Dictionary) -> void:
	cosmetic_items = items.duplicate()
	if is_instance_valid(costumes):
		remove_child(costumes)
		costumes.queue_free()
	costumes = Node2D.new()
	costumes.name = "Cosmetics"
	add_child(costumes)
	for slot in items:
		var id: String = str(items[slot])
		if not Shop.ITEMS.has(id) or Shop.ITEMS[id].category != "pet":
			continue
		var item: Dictionary = Shop.ITEMS[id]
		var layout: Dictionary = Shop.pet_layout(str(slot), id)
		var sprite = Sprite2D.new()
		sprite.name = "Cosmetic_" + id
		sprite.texture = item.texture
		sprite.position = layout.offset
		# Shop pet art is intentionally high-resolution. Always fit it down to
		# the catalog display width so curves stay crisp during Pip's motion.
		var source_width := maxf(1.0, float(sprite.texture.get_width()))
		sprite.scale = Vector2.ONE * (float(layout.width) / source_width)
		# Preserve hard-edged user-authored pixel art on the Pixel Knight set.
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if item.theme == "pixel_knight" else CanvasItem.TEXTURE_FILTER_LINEAR
		costumes.add_child(sprite)
	_update_costume_pose()

func _update_costume_pose() -> void:
	if not is_instance_valid(costumes):
		return
	var breath = sin(clock * 2.3) * (0.012 if not calm else 0.005)
	costumes.position = Vector2(0, -breath * 30)
	costumes.rotation = angle * (0.45 if calm else 1.0)
	costumes.scale = Vector2(1 + squish + breath, 1 - squish - breath)

func _unhandled_input(event: InputEvent) -> void:
	if blocked or fetching:
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


	point = point.rotated(-angle * (0.45 if calm else 1.0))
	if cosmetic_items.has("head") and Rect2(-56, -161, 112, 67).has_point(point):
		return true
	var species = str(appearance.get("species", "hamster"))
	if species == "bunny" and Rect2(-99, -199, 198, 135).has_point(point): return true
	if species in ["kitten", "fox", "puppy"] and Rect2(-96, -152, 192, 89).has_point(point): return true
	if species in ["fox", "kitten", "puppy"] and Rect2(60, -5, 85, 90).has_point(point): return true
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
	elif fetching:
		angular_velocity += ( - angle * 35.0 - angular_velocity * 8.0) * delta
		idle_time = 0.0
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
	_update_costume_pose()
	queue_redraw()

func ellipse(center: Vector2, radii: Vector2, color: Color, outline: Color = Color.TRANSPARENT, width: float = 2.4) -> void:
	var points = PackedVector2Array()
	for i in range(65):
		var a = TAU * i / 64.0
		points.append(center + Vector2(cos(a), sin(a)) * radii)
	draw_colored_polygon(points, color)
	if outline.a > 0:
		draw_polyline(points, outline, width, true)

func _poly(points: Array, color: Color, outline: Color) -> void:
	var vertices = PackedVector2Array(points)
	draw_colored_polygon(vertices, color)
	vertices.append(vertices[0])
	draw_polyline(vertices, outline, 2.4, true)

func _ear(side: int, fur: Color, inner: Color, ink: Color) -> void:
	var kind = str(appearance.ears)
	var sway = Vector2(paw_angle * 5, side * paw_angle * 5)
	if kind in ["round", "small", "fluffy"]:
		var radius = 19.0 if kind == "small" else 26.0
		var ear = Vector2(side * 58, -96) + sway
		ellipse(ear, Vector2(radius, radius + 2), fur, ink)
		if kind == "fluffy":
			for j in [-1, 0, 1]: ellipse(ear + Vector2(j * 13, -18), Vector2(10, 11), fur)
		ellipse(ear + Vector2(0, 2), Vector2(radius * 0.61, radius * 0.65), inner)
	elif kind in ["upright", "lop", "one_lop"]:
		var droop = kind == "lop" or (kind == "one_lop" and side == 1)
		var ear = Vector2(side * (77 if droop else 39), -76 if droop else -138) + sway
		ellipse(ear, Vector2(21, 58), fur, ink)
		ellipse(ear + Vector2(0, 2), Vector2(11, 43), inner)
		if appearance.pattern == "dipped": ellipse(ear + Vector2(0, -37), Vector2(18, 18), Color(appearance.patch))
	elif kind == "floppy" or (kind == "one_up" and side == -1):
		var ear = Vector2(side * 74, -65) + sway
		ellipse(ear, Vector2(24, 54), fur, ink)
		ellipse(ear + Vector2(side * 3, 10), Vector2(13, 32), inner)
	else:
		var tip = Vector2(side * (82 if kind == "wide" else 65), -149) + sway
		if kind == "folded" and side == 1: tip = Vector2(82, -110) + sway
		_poly([Vector2(side * 30, -91) + sway, tip, Vector2(side * 80, -69) + sway], fur, ink)
		_poly([Vector2(side * 44, -94) + sway, tip + Vector2( - side * 4, 19), Vector2(side * 68, -86) + sway], inner, inner)
		if kind == "tufted":
			for j in range(3): draw_line(tip + Vector2(side * (j - 1) * 3, 3), tip + Vector2(side * (j - 1) * 5, -8 + j * 3), fur, 3, true)

func _draw() -> void:
	var species = str(appearance.species)
	var fur = Color(appearance.coat)
	var patches = Color(appearance.patch)
	var cream = Color(appearance.belly)
	var pink = Color(appearance.inner)
	var ink = fur.darkened(0.46).lerp(Color("594b44"), 0.38)
	var light_fur = fur.lerp(cream, 0.22)
	var breath = sin(clock * 2.3) * (0.012 if not calm else 0.005)
	var chew = sin((1.8 - eating_time) * TAU / 0.6) if eating_time > 0 else 0.0
	var lean = angle * (0.45 if calm else 1.0)
	var height = FLOOR_Y - position.y
	if not stage_actor:
		ellipse(Vector2(0, height + 85), Vector2(78 - minf(height * 0.12, 30), 12), Color(0.25, 0.28, 0.18, 0.15))
	draw_set_transform(Vector2(0, -breath * 30), lean, Vector2(1 + squish + breath, 1 - squish - breath))

	if species == "kitten":
		var points = PackedVector2Array()
		for i in range(25):
			var t = i / 24.0
			points.append(Vector2(64, 52).bezier_interpolate(Vector2(132, 68), Vector2(127, 11), Vector2(114, -3), t))
		draw_polyline(points, ink, 23, true)
		draw_polyline(points, fur, 18, true)
		ellipse(Vector2(114, -3), Vector2(10, 12), patches)
	elif species == "fox":
		_poly([Vector2(56, 66), Vector2(92, 63), Vector2(138, 24), Vector2(125, -14), Vector2(91, 4), Vector2(70, 37)], fur, ink)
		_poly([Vector2(116, 43), Vector2(138, 24), Vector2(125, -14), Vector2(110, -5), Vector2(113, 17), Vector2(102, 21)], cream, cream)
	elif species == "puppy":
		var wag = sin(clock * 7) * 9 if happy_time > 0 or fetching else sin(clock * 2) * 3
		draw_line(Vector2(64, 48), Vector2(111, 17 + wag), ink, 22, true)
		draw_line(Vector2(64, 48), Vector2(111, 17 + wag), fur, 17, true)
		ellipse(Vector2(111, 17 + wag), Vector2(9, 10), patches)
	else: ellipse(Vector2(77, 47), Vector2(21 if species == "bunny" else 17, 19 if species == "bunny" else 15), cream if species == "bunny" else (patches if species == "panda" else pink), ink)
	var dangle = 11.0 if is_held or is_falling else 0.0
	for side in [-1, 1]:
		var foot = Vector2(side * 43 + paw_angle * 22, 75 + dangle)
		if (dance_pose > 0 or fetching) and not calm: foot.y -= maxf(0, sin((dance_phase if dance_pose > 0 else clock * 3) * TAU + side * PI / 2)) * 13
		if is_held: draw_line(Vector2(side * 40, 53), foot, fur.darkened(0.08), 17, true)
		var feet_color = patches if species == "panda" or appearance.pattern in ["boots", "socks"] else (pink if species == "hamster" else light_fur)
		ellipse(foot, Vector2(24, 13 if not is_held else 19), feet_color, ink)
		for j in range(2): draw_line(foot + Vector2(-5 + j * 8, 3), foot + Vector2(-5 + j * 8, 9), ink.lightened(0.3), 1.7, true)
	var body_width = 88.0 if species == "panda" else (84.0 if species == "hamster" else 77.0)
	ellipse(Vector2(0, 11), Vector2(body_width, 77), fur, ink)
	if appearance.pattern == "stripe": ellipse(Vector2(0, 21), Vector2(23, 64), patches)
	if appearance.pattern == "spots":
		for spot in [Vector2(-57, 18), Vector2(48, 46), Vector2(24, -17)]: ellipse(spot, Vector2(16, 20), patches)
	if species == "panda" and appearance.pattern != "moon": ellipse(Vector2(0, 5), Vector2(82, 37), patches)
	if appearance.pattern != "solid": ellipse(Vector2(0, 30), Vector2(53 if species != "hamster" else 58, 57), cream)
	if appearance.pattern == "moon": ellipse(Vector2(0, 7), Vector2(38, 19), patches)
	for side in [-1, 1]: _ear(side, patches if species == "panda" or species == "puppy" else fur, pink, ink)
	var head_width = 73.0 if species == "bunny" else (76.0 if species in ["kitten", "fox"] else 80.0)
	ellipse(Vector2(0, -40), Vector2(head_width + chew * 2, 67), light_fur, ink)
	if species == "fox":
		_poly([Vector2(-73, -22), Vector2(-86, -4), Vector2(-32, 12), Vector2(0, -8)], cream, cream)
		_poly([Vector2(73, -22), Vector2(86, -4), Vector2(32, 12), Vector2(0, -8)], cream, cream)
	if appearance.pattern == "mask":
		for side in [-1, 1]: ellipse(Vector2(side * 32, -46), Vector2(22, 26), patches)
	elif appearance.pattern == "patches": ellipse(Vector2(-34, -48), Vector2(33, 37), patches)
	elif appearance.pattern == "tuxedo":
		_poly([Vector2(-26, -26), Vector2(0, -86), Vector2(26, -26)], cream, cream)
	elif appearance.pattern == "blaze": ellipse(Vector2(0, -65), Vector2(14, 37), cream)
	if species == "hamster":
		ellipse(Vector2(-46, -9), Vector2(34, 29), cream)
		ellipse(Vector2(46, -9), Vector2(34, 29), cream)
	ellipse(Vector2(0, 0), Vector2(55 if species == "hamster" else 36, 31 if species == "hamster" else 24), cream)
	if appearance.pattern in ["cheeks", "tabby", "stripe"]:
		for i in [-1, 0, 1]: draw_line(Vector2(i * 10, -102 + abs(i) * 3), Vector2(i * 8, -83 + abs(i) * 2), patches, 5, true)
		if appearance.pattern == "tabby":
			for side in [-1, 1]:
				for j in range(2): draw_line(Vector2(side * 72, -44 + j * 14), Vector2(side * 54, -40 + j * 12), patches, 5, true)
	var look = ((get_global_mouse_position() - global_position) / 120).limit_length(4) if is_inside_tree() and not stage_actor else Vector2.ZERO
	var blink = fmod(clock, 4.7) > 4.51
	var happy = happy_time > 0 or groom_time > 0
	var eye_color = Color(appearance.iris)
	for side in [-1, 1]:
		var eye = Vector2(side * 32, -46) + look
		if happy or blink:
			draw_arc(eye + Vector2(0, 5), 9, PI + 0.2, TAU - 0.2, 18, eye_color, 3.5, true)
		else:
			var radii = Vector2(7, 9)
			if appearance.eyes == "sparkle": radii = Vector2(11, 13)
			if appearance.eyes == "oval": radii = Vector2(8, 12)
			if appearance.eyes == "gentle": radii = Vector2(10, 6)
			if appearance.eyes == "cat_eye":
				ellipse(eye, Vector2(12, 11), eye_color.lightened(0.48))
				ellipse(eye, Vector2(4, 9), eye_color.darkened(0.35))
			else: ellipse(eye, radii, eye_color)
			ellipse(eye + Vector2(2, -3), Vector2(2.3, 3), Color("fffdf6"))
			if appearance.eyes == "sparkle": ellipse(eye + Vector2(-4, 4), Vector2(2, 2), Color("fffdf6"))
		ellipse(Vector2(side * 52, -22), Vector2(15, 7), Color(pink, 0.48))
	var nose = Color(appearance.nose_color)
	match appearance.nose:
		"heart":
			draw_circle(Vector2(-4, -19), 5, nose)
			draw_circle(Vector2(4, -19), 5, nose)
			draw_colored_polygon(PackedVector2Array([Vector2(-9, -18), Vector2(9, -18), Vector2(0, -10)]), nose)
		"triangle": _poly([Vector2(-9, -21), Vector2(9, -21), Vector2(0, -12)], nose, nose)
		"snout":
			ellipse(Vector2(0, -18), Vector2(13, 8), nose)
			ellipse(Vector2(-3, -21), Vector2(4, 2), nose.lightened(0.25))
		"tiny": ellipse(Vector2(0, -17), Vector2(4, 3), nose)
		_: ellipse(Vector2(0, -17), Vector2(8, 5.5), nose)
	draw_line(Vector2(0, -12), Vector2(0, -6), ink, 2.1, true)
	if is_held: ellipse(Vector2(0, 2), Vector2(6, 7), ink)
	elif appearance.mouth in ["grin", "tongue"]:
		ellipse(Vector2(0, 2), Vector2(12, 9), ink)
		if appearance.mouth == "tongue": ellipse(Vector2(2, 9), Vector2(7, 9), pink)
		else: draw_line(Vector2(-7, -2), Vector2(7, -2), cream, 4, true)
	elif appearance.mouth == "tiny": draw_line(Vector2(-4, 0), Vector2(4, 0), ink, 2, true)
	else:
		draw_arc(Vector2(-6, -7), 6, 0, PI, 18, ink, 2.2, true)
		draw_arc(Vector2(6, -7), 6, 0, PI, 18, ink, 2.2, true)
		if appearance.mouth == "buck":
			draw_rect(Rect2(-7, 1, 14, 10), Color("fffdf6"))
			draw_line(Vector2(0, 2), Vector2(0, 11), ink, 1.4, true)
	if species in ["hamster", "kitten", "bunny"]:
		for side in [-1, 1]:
			for j in range(2): draw_line(Vector2(side * 62, -7 + j * 9), Vector2(side * 89, -12 + j * 16), ink.lightened(0.25), 1.5, true)
	for side in [-1, 1]:
		var hand = Vector2(side * 70, 33)
		if dance_pose == 1: hand = Vector2(side * lerpf(16, 58, (sin(dance_phase * TAU) + 1) / 2), 9)
		elif dance_pose == 2: hand = Vector2(side * 75, -22 + (0 if calm else sin(dance_phase * TAU + side) * 18))
		elif dance_pose == 3: hand = Vector2(side * 86, -9)
		elif is_held or is_falling: hand += Vector2(paw_angle * 28, 15 + side * paw_angle * 8)
		elif eating_time > 0: hand = Vector2(side * 17, 9 + chew * 3)
		elif groom_time > 0: hand = Vector2(side * 35, -38 + sin(clock * 12) * 12)
		elif happy: hand = Vector2(side * 74, 15 + sin(clock * 10) * 3)
		elif fetching: hand += Vector2(0, sin(clock * 14 + side * PI / 2) * 9)
		var paw_color = patches if species == "panda" or appearance.pattern == "boots" else light_fur
		draw_line(Vector2(side * 70, 16), hand, paw_color, 22, true)
		ellipse(hand, Vector2(14, 18), paw_color, ink, 2)
		ellipse(hand + Vector2(0, 5), Vector2(8, 6), pink)
	if eating_time > 0:
		var food_color = {"berry":Color("bc5871"), "seed":Color("b69658"), "carrot":Color("ec975a")}.get(food_kind, pink)
		ellipse(Vector2(0, 12 + chew * 3), Vector2(11, 14), food_color)
		draw_line(Vector2(0, 0), Vector2(5, -6), Color("68835c"), 3, true)
	draw_set_transform(Vector2.ZERO)
	for f in floaties:
		var at: Vector2 = f.p
		var col = Color("ce8090")
		col.a = minf(1, f.life)
		draw_circle(at + Vector2(-4, -2), 5, col)
		draw_circle(at + Vector2(4, -2), 5, col)
		draw_colored_polygon(PackedVector2Array([at + Vector2(-9, 0), at + Vector2(9, 0), at + Vector2(0, 10)]), col)
