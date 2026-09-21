extends Node2D
## Original vector room art. Change these colors to redecorate Pip's room.
const UI = preload("res://scripts/ui.gd")

func ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points = PackedVector2Array()
	for i in range(80):
		var a = TAU * i / 80.0
		points.append(center + Vector2(cos(a), sin(a)) * radii)
	draw_colored_polygon(points, color)

func leaf(p: Vector2, angle: float, color: Color, length: float = 22.0) -> void:
	var points = PackedVector2Array()
	for i in range(32):
		var a = TAU * i / 32.0
		points.append(p + Vector2(cos(a) * length, sin(a) * length * 0.37).rotated(angle))
	draw_colored_polygon(points, color)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 800), Color("f7f3e9"))
	draw_style_box(UI.style(Color("dce5d0"), 28), Rect2(40, 138, 1200, 525))
	# A very light wallpaper pattern.
	for x in range(75, 1230, 43):
		for y in range(172, 495, 44):
			draw_circle(Vector2(x + (12 if y % 2 == 0 else 0), y), 1.4, Color(0.47, 0.58, 0.40, 0.15))
	var floor_style = UI.style(Color("e8d9be"), 0)
	floor_style.corner_radius_bottom_left = 28
	floor_style.corner_radius_bottom_right = 28
	draw_style_box(floor_style, Rect2(40, 503, 1200, 160))
	draw_rect(Rect2(40, 494, 1200, 9), Color("f1e9d5"))
	draw_line(Vector2(40, 503), Vector2(1240, 503), Color("c8c0a5"), 1.5)
	for y in [552, 607]:
		draw_line(Vector2(42, y), Vector2(1238, y), Color("ddcbb0"), 1.5)
	for x in [184, 470, 770, 1080]:
		draw_line(Vector2(x, 506), Vector2(x-20, 551), Color("ddcbb0"), 1.5)
		draw_line(Vector2(x-30, 608), Vector2(x-55, 661), Color("ddcbb0"), 1.5)
	# Woven play mat.
	ellipse(Vector2(644, 591), Vector2(310, 49), Color(0.35, 0.35, 0.23, 0.08))
	ellipse(Vector2(640, 585), Vector2(303, 46), Color("b6c29a"))
	ellipse(Vector2(640, 582), Vector2(290, 40), Color("edf0d8"))
	ellipse(Vector2(640, 582), Vector2(266, 32), Color("dee6c6"))
	for x in range(397, 900, 19):
		draw_line(Vector2(x, 571), Vector2(x+4, 591), Color(0.51, 0.61, 0.39, 0.12), 1.1, true)
	# Right window: a quiet miniature landscape.
	draw_style_box(UI.style(Color("b6b89c"), 57), Rect2(956, 216, 210, 207))
	draw_style_box(UI.style(Color("faf2dd"), 52), Rect2(949, 208, 210, 207))
	draw_style_box(UI.style(Color("c9e3db"), 41), Rect2(961, 220, 186, 181))
	draw_circle(Vector2(1104, 258), 23, Color("f8dc9c"))
	ellipse(Vector2(1000, 274), Vector2(24, 10), Color("edf5e7"))
	ellipse(Vector2(1021, 279), Vector2(25, 8), Color("edf5e7"))
	draw_colored_polygon(PackedVector2Array([Vector2(962, 348),Vector2(1000, 312),Vector2(1049, 345),Vector2(1086, 322),Vector2(1147, 350),Vector2(1147, 390),Vector2(962, 390)]), Color("a0bd91"))
	draw_colored_polygon(PackedVector2Array([Vector2(962, 370),Vector2(1018, 352),Vector2(1070, 373),Vector2(1110, 357),Vector2(1147, 372),Vector2(1147, 390),Vector2(962, 390)]), Color("83a077"))
	draw_rect(Rect2(1050, 220, 8, 177), Color("faf2dd"))
	draw_rect(Rect2(961, 311, 186, 7), Color("faf2dd"))
	draw_style_box(UI.style(Color("f5ebd3"), 7), Rect2(938, 390, 233, 17))
	# A shelf with books and a tiny house plant.
	draw_style_box(UI.style(Color("b79f7b"), 5), Rect2(100, 428, 189, 12))
	draw_line(Vector2(121, 440), Vector2(121, 461), Color("af9978"), 5)
	draw_line(Vector2(269, 440), Vector2(269, 461), Color("af9978"), 5)
	for i in range(3):
		var col = [Color("a9b491"),Color("d0a38d"),Color("e7cf96")][i]
		draw_style_box(UI.style(col, 3), Rect2(110+i*21, 370+i*7, 17, 58-i*7))
		draw_line(Vector2(114+i*21, 416), Vector2(122+i*21, 416), Color("f6eedb"), 2)
	draw_style_box(UI.style(Color("cfaa83"), 5), Rect2(218, 395, 44, 33))
	draw_line(Vector2(240, 397), Vector2(239, 346), Color("718568"), 3, true)
	leaf(Vector2(228, 367), 0.5, Color("91a579"), 21)
	leaf(Vector2(252, 354), -0.5, Color("758f67"), 20)
	leaf(Vector2(252, 380), -0.6, Color("91a579"), 16)
	# Floor plant.
	ellipse(Vector2(1100, 578), Vector2(52, 11), Color(0.3, 0.3, 0.2, 0.1))
	draw_style_box(UI.style(Color("be8f70"), 15), Rect2(1060, 504, 78, 67))
	draw_style_box(UI.style(Color("d3ab86"), 6), Rect2(1053, 499, 92, 15))
	for i in range(5):
		var target = Vector2(1060 + i*20, 442 - sin(i*0.8)*48)
		draw_line(Vector2(1098, 504), target, Color("6d8762"), 3, true)
		leaf(target, (i-2)*0.38, [Color("87a175"), Color("6f8960")][i%2], 27)
	# A cushion and Pip's bowl.
	ellipse(Vector2(203, 571), Vector2(69, 15), Color("c7b49d"))
	ellipse(Vector2(198, 559), Vector2(70, 21), Color("dbc0ae"))
	ellipse(Vector2(198, 552), Vector2(53, 15), Color("efdbcb"))
	draw_style_box(UI.style(Color("b9bc9e"), 16), Rect2(891, 560, 67, 29))
	ellipse(Vector2(924, 562), Vector2(34, 10), Color("e7e4cc"))
	ellipse(Vector2(924, 562), Vector2(26, 6), Color("a39d7d"))
