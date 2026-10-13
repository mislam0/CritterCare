extends Node2D
## Shared vector artwork for room shop thumbnails and decorations.
var kind: String = "rose_mat"
const UI = preload("res://scripts/ui.gd")

func _draw() -> void:
	var gold = Color("d8ae53")
	var green = Color("63855b")
	match kind:
		"rose_mat", "blue_mat":
			var color = Color("c78a9f") if kind == "rose_mat" else Color("83afc3")
			draw_set_transform(Vector2.ZERO,0,Vector2(1,0.5))
			draw_circle(Vector2.ZERO,30,color)
			draw_circle(Vector2.ZERO,25,color.lightened(0.35))
			draw_arc(Vector2.ZERO,20,0,TAU,48,color,2,true)
		"peach_wall", "night_wall":
			draw_style_box(UI.style(Color("edcdb7") if kind == "peach_wall" else Color("b9b6d1"),6),Rect2(-29,-24,58,48))
			for x in [-18,0,18]:
				for y in [-15,0,15]:
					draw_circle(Vector2(x,y),2,Color("fff1ce"))
		"lantern":
			draw_arc(Vector2(0,-21),7,PI,TAU,20,gold,3,true)
			draw_style_box(UI.style(Color("bd9256"),6),Rect2(-17,-20,34,44))
			draw_style_box(UI.style(Color("ffe7a1"),4),Rect2(-12,-15,24,33))
			draw_line(Vector2.ZERO+Vector2(0,-15),Vector2(0,18),gold,2,true)
		"bunting":
			draw_line(Vector2(-35,-15),Vector2(35,-15),green,2,true)
			for i in range(4):
				var x = -34+i*18
				draw_colored_polygon(PackedVector2Array([Vector2(x,-14),Vector2(x+15,-14),Vector2(x+7,11)]),[Color("bc7895"),gold,Color("83afc3"),green][i])
