extends TextureRect
## PNG-backed UI illustration. Callers keep setting `kind` exactly as before.

const ICONS = {
	"music": preload("res://assets/ui/icons/music.png"),
	"basket": preload("res://assets/ui/icons/basket.png"),
	"leaf": preload("res://assets/ui/icons/leaf.png"),
	"golden_seed": preload("res://assets/ui/icons/golden_seed.png"),
	"berry": preload("res://assets/ui/icons/berry.png"),
	"coin": preload("res://assets/ui/icons/coin.png"),
	"shop": preload("res://assets/ui/icons/shop.png"),
	"spoiled_berry": preload("res://assets/ui/icons/spoiled_berry.png"),
	"seed": preload("res://assets/ui/icons/seed.png"),
	"carrot": preload("res://assets/ui/icons/carrot.png"),
	"book": preload("res://assets/ui/icons/book.png"),
	"code": preload("res://assets/ui/icons/code.png"),
	"game": preload("res://assets/ui/icons/game.png"),
	"heart": preload("res://assets/ui/icons/heart.png"),
	"star": preload("res://assets/ui/icons/star.png"),
	"paw": preload("res://assets/ui/icons/paw.png"),
	"stone": preload("res://assets/ui/icons/stone.png"),
	"button": preload("res://assets/ui/icons/button.png"),
	"blueberry": preload("res://assets/ui/icons/blueberry.png"),
	"default": preload("res://assets/ui/icons/default.png")
}

var kind: String = "berry":
	set(value):
		kind = value
		_apply_texture()

func _init() -> void:
	# Set these before callers assign position/size. Otherwise TextureRect can
	# briefly enforce the PNG's 96x96 native minimum and enlarge small HUD icons.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func _ready() -> void:
	_apply_texture()

func _apply_texture() -> void:
	texture = ICONS.get(kind, ICONS["default"])
