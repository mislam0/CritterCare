extends Node2D
## Shared vector artwork for shop thumbnails and Pip's equipped accessories.
var kind: String = "leaf_hat"
const UI = preload("res://scripts/ui.gd")

func _draw() -> void:
	var gold = Color("d8ae53")
	var green = Color("63855b")
	match kind:
		"leaf_hat":
			draw_colored_polygon(PackedVector2Array([Vector2(-25,9),Vector2(-16,-9),Vector2(6,-18),Vector2(25,-13),Vector2(14,7)]), green)
			draw_line(Vector2(-24,9),Vector2(19,-12),Color("a6c785"),2,true)
			draw_line(Vector2(-5,-1),Vector2(-8,-11),Color("a6c785"),1.5,true)
		"bow":
			for side in [-1,1]:
				draw_colored_polygon(PackedVector2Array([Vector2(0,0),Vector2(side*22,-13),Vector2(side*22,13)]),Color("b95173"))
			draw_circle(Vector2.ZERO,7,Color("e494ac"))
		"glasses":
			for side in [-1,1]:
				draw_arc(Vector2(side*14,0),11,0,TAU,40,gold,2.4,true)
				draw_line(Vector2(side*25,-1),Vector2(side*30,-5),gold,2.4,true)
			draw_arc(Vector2(0,2),5,PI,TAU,16,gold,2.3,true)
		"scarf":
			draw_style_box(UI.style(Color("719ab4"),6),Rect2(-25,-7,50,16))
			draw_style_box(UI.style(Color("86b0c5"),4),Rect2(9,4,13,28))
			for i in range(3):
				draw_line(Vector2(12+i*4,30),Vector2(12+i*4,36),Color("719ab4"),2,true)
		"flower_hat":
			draw_style_box(UI.style(Color("dfb971"),8),Rect2(-18,-23,36,26))
			draw_style_box(UI.style(Color("eed291"),5),Rect2(-32,-2,64,9))
			draw_line(Vector2(-18,-4),Vector2(18,-4),Color("bc7895"),4,true)
			for i in range(6):
				draw_circle(Vector2(12,-10)+Vector2(0,-5).rotated(i*TAU/6),3.5,Color("fff9eb"))
			draw_circle(Vector2(12,-10),3,gold)
		"crown":
			draw_colored_polygon(PackedVector2Array([Vector2(-26,8),Vector2(-29,-19),Vector2(-12,-9),Vector2(0,-28),Vector2(12,-9),Vector2(29,-19),Vector2(26,8)]),gold)
			draw_line(Vector2(-24,3),Vector2(24,3),Color("f6d994"),4,true)
			for x in [-17,0,17]:
				draw_circle(Vector2(x,-4),3.5,Color("b9738b"))
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
