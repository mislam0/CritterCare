extends Node2D
## PNG-backed base room. Shop equipment is intentionally simple:
## one wallpaper, one room decoration, and one rug at a time.

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

func _ready() -> void:
	_texture("RoomBackdrop", ROOM_BACKDROP, Rect2(0, 0, 1280, 800))
	wallpaper = _texture("Wallpaper", DEFAULT_WALLPAPER, Rect2(40, 138, 1200, 525))
	_texture("RoomFloor", ROOM_FLOOR, Rect2(0, 0, 1280, 800))
	rug = _texture("Rug", DEFAULT_RUG, Rect2(320, 500, 640, 130))
	_texture("RoomFurniture", ROOM_FURNITURE, Rect2(0, 0, 1280, 800))
	decor = _texture("RoomDecoration", null, Shop.ROOM_SLOT_LAYOUT["decor"].rect)
	_apply_cosmetics()

func _texture(node_name: String, image: Texture2D, rect: Rect2) -> TextureRect:
	var node = TextureRect.new()
	node.name = node_name
	node.texture = image
	node.position = rect.position
	node.size = rect.size
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_SCALE
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.visible = image != null
	add_child(node)
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

	var decor_item := _room_item("decor")
	if decor_item.is_empty():
		decor.texture = null
		decor.visible = false
	else:
		_apply_item(decor, "decor", decor_item)

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
