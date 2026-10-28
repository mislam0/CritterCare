extends Node2D
## PNG-backed base room. Shop equipment stays simple for players:
## one wallpaper, one coordinated decor bundle, and one rug at a time.

const Shop = preload("res://data/shop.gd")
const ROOM_BACKDROP = preload("res://assets/room/base/room_backdrop.png")
const DEFAULT_WALLPAPER = preload("res://assets/room/base/default_wallpaper.png")
const ROOM_FLOOR = preload("res://assets/room/base/room_floor.png")
const DEFAULT_RUG = preload("res://assets/room/base/default_rug.png")
const ROOM_FURNITURE = preload("res://assets/room/base/room_furniture.png")

var cosmetic_items: Dictionary = {}
var wallpaper: TextureRect
var rug: TextureRect
var decor: TextureRect
var decor_pieces: Dictionary = {}
var furniture: TextureRect

func _ready() -> void:
	_texture("RoomBackdrop", ROOM_BACKDROP, Rect2(0, 0, 1280, 800))
	# Clip the opaque wallpaper to the same rounded footprint as the room.
	# The intermediate origin keeps every existing room-space anchor unchanged.
	var mask := Panel.new()
	mask.name = "WallpaperMask"
	mask.position = Vector2(40, 138)
	mask.size = Vector2(1200, 525)
	mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.set_corner_radius_all(32)
	mask.add_theme_stylebox_override("panel", style)
	add_child(mask)
	var origin := Node2D.new()
	origin.position = Vector2(-40, -138)
	mask.add_child(origin)
	wallpaper = _texture("Wallpaper", DEFAULT_WALLPAPER, Rect2(40, 138, 1200, 525), origin)
	_texture("RoomFloor", ROOM_FLOOR, Rect2(0, 0, 1280, 800))
	rug = _texture("Rug", DEFAULT_RUG, Rect2(320, 500, 640, 130))
	furniture = _texture("RoomFurniture", ROOM_FURNITURE, Rect2(0, 0, 1280, 800))
	# One historic wall-decoration item is now a Decor Set: a main wall piece
	# plus themed room accents. Retain the original furniture as the fallback
	# and use the existing room:decor save key.
	for piece_name in Shop.DECOR_SET_LAYOUT:
		var rect: Rect2 = Shop.ROOM_SLOT_LAYOUT["decor"].rect if piece_name == "main_wall" else Shop.DECOR_SET_LAYOUT[piece_name].rect
		var layer: TextureRect = _texture("DecorSet_" + piece_name, null, rect)
		decor_pieces[piece_name] = layer
	decor = decor_pieces["main_wall"]
	_apply_cosmetics()

func _texture(node_name: String, image: Texture2D, rect: Rect2, target: Node = null) -> TextureRect:
	var node = TextureRect.new()
	node.name = node_name
	node.texture = image
	node.position = rect.position
	node.size = rect.size
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_SCALE
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.visible = image != null
	if target == null:
		add_child(node)
	else:
		target.add_child(node)
	return node

func set_cosmetics(items: Dictionary) -> void:
	cosmetic_items = items.duplicate()
	if is_node_ready():
		_apply_cosmetics()

func _room_item(slot: String) -> Dictionary:
	if not cosmetic_items.has(slot):
		return {}
	var id: String = str(cosmetic_items[slot])
	if not Shop.ITEMS.has(id) or Shop.ITEMS[id].category != "room" or Shop.ITEMS[id].slot != slot:
		return {}
	var item: Dictionary = Shop.ITEMS[id].duplicate()
	item["id"] = id
	return item

func _apply_cosmetics() -> void:
	var wall_item := _room_item("wall")
	wallpaper.texture = DEFAULT_WALLPAPER if wall_item.is_empty() else wall_item.texture
	wallpaper.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if not wall_item.is_empty() and wall_item.get("theme", "") == "pixel_knight" else CanvasItem.TEXTURE_FILTER_LINEAR
	wallpaper.position = Vector2(40, 138)
	wallpaper.size = Vector2(1200, 525)
	wallpaper.visible = true

	var rug_item := _room_item("rug")
	if rug_item.is_empty():
		rug.texture = DEFAULT_RUG
		rug.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		rug.position = Vector2(320, 500)
		rug.size = Vector2(640, 130)
		rug.visible = true
	else:
		_apply_item(rug, "rug", rug_item)

	_apply_decor_set(_room_item("decor"))

func _apply_decor_set(item: Dictionary) -> void:
	# The old PNG remains the shop thumbnail AND the bundle's primary wall art.
	# Partial custom bundles still fall back to the original furniture. Complete
	# bundles replace all five base pieces so old silhouettes cannot show through.
	for piece_name in decor_pieces:
		var layer: TextureRect = decor_pieces[piece_name]
		if item.is_empty():
			layer.texture = null
			layer.visible = false
			continue
		if piece_name == "main_wall":
			_apply_item(layer, "decor", item)
			continue
		var path: String = Shop.decor_set_piece_path(str(item.get("theme", "")), str(piece_name))
		if path.is_empty() or not ResourceLoader.exists(path):
			layer.texture = null
			layer.visible = false
			continue
		var image: Texture2D = load(path) as Texture2D
		layer.texture = image
		layer.visible = image != null
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if item.get("theme", "") == "pixel_knight" else CanvasItem.TEXTURE_FILTER_LINEAR
		var rect: Rect2 = Shop.DECOR_SET_LAYOUT[piece_name].rect
		layer.position = rect.position
		layer.size = rect.size
	var replaces_furniture := true
	for piece_name in ["left_shelf", "window", "right_plant", "food_bowl", "floor_cushion"]:
		if not decor_pieces[piece_name].visible:
			replaces_furniture = false
			break
	furniture.visible = not replaces_furniture

func _apply_item(node: TextureRect, slot: String, item: Dictionary) -> void:
	var layout: Dictionary = Shop.room_layout(slot, str(item.get("id", "")))
	if layout.is_empty():
		node.texture = null
		node.visible = false
		return
	node.texture = item.texture
	# Pixel art must not be blurred by bilinear filtering at different UI scales.
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if item.get("theme", "") == "pixel_knight" else CanvasItem.TEXTURE_FILTER_LINEAR
	node.position = layout.rect.position
	node.size = layout.rect.size
	node.visible = true
