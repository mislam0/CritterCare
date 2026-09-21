extends Control
## Vector UI illustrations, deliberately independent of external image assets.
var kind: String = "berry"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var sc = minf(size.x, size.y) / 48.0
	draw_set_transform(size / 2, 0, Vector2.ONE * sc)
	var green = Color("65845b")
	var ink = Color("426d53")
	match kind:
		"berry":
			for p in [Vector2(-8, 2), Vector2(8, 2), Vector2(0, 13)]:
				draw_circle(p, 10, Color("bc637a"))
				draw_circle(p+Vector2(-3, -3), 2, Color("efabb6"))
			draw_line(Vector2(0, -3), Vector2(3, -17), green, 3, true)
			draw_colored_polygon(PackedVector2Array([Vector2(1,-9), Vector2(15,-17),Vector2(17,-7),Vector2(3,-3)]), green)
		"seed":
			draw_colored_polygon(PackedVector2Array([Vector2(0,-22),Vector2(14,-3),Vector2(13,12),Vector2(0,21),Vector2(-13,12),Vector2(-14,-3)]), Color("a28b5e"))
			draw_line(Vector2(0,-16),Vector2(0,16),Color("ede0bc"),3,true)
		"carrot":
			draw_colored_polygon(PackedVector2Array([Vector2(-14,-9),Vector2(14,-9),Vector2(0,23)]),Color("db975c"))
			for i in [-1,0,1]:
				draw_line(Vector2(0,-8), Vector2(i*10,-22),green,5,true)
			draw_line(Vector2(-7,0),Vector2(3,0),Color("b87946"),2,true)
		"book", "code":
			draw_style_box(preload("res://scripts/ui.gd").style(Color("d9b887"),5),Rect2(-18,-19,36,40))
			draw_line(Vector2(-11,-18),Vector2(-11,20),Color("f7e6c6"),3,true)
			draw_polyline(PackedVector2Array([Vector2(0,-5),Vector2(-4,0),Vector2(0,5)]),ink,2,true)
			draw_polyline(PackedVector2Array([Vector2(7,-5),Vector2(11,0),Vector2(7,5)]),ink,2,true)
		"game":
			draw_style_box(preload("res://scripts/ui.gd").style(Color("c3d2b4"),10),Rect2(-23,-12,46,30))
			draw_line(Vector2(-16,2),Vector2(-4,2),ink,4,true)
			draw_line(Vector2(-10,-4),Vector2(-10,8),ink,4,true)
			draw_circle(Vector2(9,6),3,Color("bc637a"))
			draw_circle(Vector2(15,-1),3,Color("d6aa68"))
		"heart":
			var col = Color("c47d87")
			draw_circle(Vector2(-8,-4),11,col)
			draw_circle(Vector2(8,-4),11,col)
			draw_colored_polygon(PackedVector2Array([Vector2(-19,0),Vector2(19,0),Vector2(0,22)]),col)
		"star":
			var points = PackedVector2Array()
			for i in range(10):
				points.append(Vector2(0,-22 if i%2==0 else -10).rotated(i*PI/5))
			draw_colored_polygon(points,Color("dbb563"))
		"paw":
			draw_circle(Vector2(0,9),12,ink)
			for p in [Vector2(-16,-4),Vector2(-6,-14),Vector2(7,-14),Vector2(17,-3)]:
				draw_circle(p,6,ink)
		"stone":
			draw_style_box(preload("res://scripts/ui.gd").style(Color("a9aaa0"),13),Rect2(-22,-12,44,32))
			draw_line(Vector2(-7,-6),Vector2(5,-7),Color("cfd0c6"),4,true)
		"button":
			draw_circle(Vector2.ZERO,19,Color("bd6a7e"))
			draw_arc(Vector2.ZERO,15,0,TAU,40,Color("e4a0ac"),2,true)
			for x in [-4,4]:
				for y in [-4,4]:
					draw_circle(Vector2(x,y),2,Color("743d53"))
		"blueberry":
			draw_circle(Vector2.ZERO,19,Color("7b8dac"))
			draw_circle(Vector2(-6,-6),5,Color("a5b3cd"))
			draw_line(Vector2(0,-17),Vector2(4,-23),green,3,true)
		_:
			draw_circle(Vector2.ZERO,17,green)
