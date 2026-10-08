extends RefCounted
## Theme-first Shop catalog. Each set contributes exactly three Pet cards and
## three Room cards so one set always fills one 3-column Shop row.

const PET_SLOT_LAYOUT = {
	"head":{"offset":Vector2(0,-115), "width":120.0},
	"face":{"offset":Vector2(0,-46), "width":183.0},
	"neck":{"offset":Vector2(0,26), "width":110.0}
}

const ROOM_SLOT_LAYOUT = {
	"wall":{"rect":Rect2(40,138,1200,525)},
	"decor":{"rect":Rect2(435,164,410,396)},
	"rug":{"rect":Rect2(320,500,640,130)}
}

const THEME_ORDER = ["nature", "study", "smart_casual", "halloween", "christmas", "pixel_knight"]
const THEMES = {
	"nature":{"name":"Nature", "tagline":"Soft greens and little garden details."},
	"study":{"name":"Study", "tagline":"A tidy look for learning with Pip."},
	"smart_casual":{"name":"Smart Casual", "tagline":"Clean, cool, and a little dressed up."},
	"halloween":{"name":"Halloween", "tagline":"Pumpkins, bats, and cozy spooky colors."},
	"christmas":{"name":"Christmas", "tagline":"Warm holiday colors and winter cheer."},
	"pixel_knight":{"name":"Pixel Knight", "tagline":"A tiny retro adventure set."}
}

const ITEMS = {
	# Nature
	"leaf_hat":{"name":"Little Leaf Hat", "theme":"nature", "category":"pet", "slot":"head", "price":25, "description":"The original little leaf, perfect for a nature-loving Pip.", "texture":preload("res://assets/shop/pet/leaf_hat.png")},
	"flower_clip":{"name":"Flower Clip", "theme":"nature", "category":"pet", "slot":"face", "price":35, "description":"A soft flower tucked beside Pip's cheek.", "texture":preload("res://assets/shop/pet/flower_clip.png")},
	"vine_scarf":{"name":"Vine Collar", "theme":"nature", "category":"pet", "slot":"neck", "price":45, "description":"A soft leafy collar that keeps the nature look without a scarf.", "texture":preload("res://assets/shop/pet/vine_scarf.png")},
	"sage_wallpaper":{"name":"Sage Wallpaper", "theme":"nature", "category":"room", "slot":"wall", "price":45, "description":"Calm sage walls with a light leaf pattern.", "texture":preload("res://assets/shop/room/sage_wallpaper.png")},
	"hanging_plant":{"name":"Hanging Plant", "theme":"nature", "category":"room", "slot":"decor", "price":60, "description":"A trailing plant that brings the room to life.", "texture":preload("res://assets/shop/room/hanging_plant.png")},
	"leaf_rug":{"name":"Leaf Rug", "theme":"nature", "category":"room", "slot":"rug", "price":55, "description":"A soft green rug shaped with simple leaf details.", "texture":preload("res://assets/shop/room/leaf_rug.png")},

	# Study
	"scholar_cap":{"name":"Scholar Cap", "theme":"study", "category":"pet", "slot":"head", "price":50, "description":"A little graduation cap for Pip's study sessions.", "texture":preload("res://assets/shop/pet/scholar_cap.png")},
	"glasses":{"name":"Study Glasses", "theme":"study", "category":"pet", "slot":"face", "price":60, "description":"The classic round spectacles, ready for reading.", "texture":preload("res://assets/shop/pet/glasses.png")},
	"bow":{"name":"Study Bow Tie", "theme":"study", "category":"pet", "slot":"neck", "price":65, "description":"A neat berry-colored bow tie for a polished learner.", "texture":preload("res://assets/shop/pet/bow.png")},
	"warm_cream_wallpaper":{"name":"Warm Cream Wallpaper", "theme":"study", "category":"room", "slot":"wall", "price":70, "description":"Simple warm walls that make a quiet study corner.", "texture":preload("res://assets/shop/room/warm_cream_wallpaper.png")},
	"study_bookshelf":{"name":"Study Bookshelf", "theme":"study", "category":"room", "slot":"decor", "price":85, "description":"A small shelf packed with books and study supplies.", "texture":preload("res://assets/shop/room/study_bookshelf.png")},
	"plaid_study_rug":{"name":"Plaid Study Rug", "theme":"study", "category":"room", "slot":"rug", "price":75, "description":"A warm plaid rug for reading time.", "texture":preload("res://assets/shop/room/plaid_study_rug.png")},

	# Smart Casual
	"flat_cap":{"name":"Flat Cap", "theme":"smart_casual", "category":"pet", "slot":"head", "price":75, "description":"A simple red cap in Pip's favorite clean-lined style.", "texture":preload("res://assets/shop/pet/flat_cap.png")},
	"sunglasses":{"name":"Sunglasses", "theme":"smart_casual", "category":"pet", "slot":"face", "price":90, "description":"Cool shades that pair perfectly with a tie.", "texture":preload("res://assets/shop/pet/sunglasses.png")},
	"necktie":{"name":"Necktie", "theme":"smart_casual", "category":"pet", "slot":"neck", "price":85, "description":"A simple blue tie for Pip's dressed-up days.", "texture":preload("res://assets/shop/pet/necktie.png")},
	"blue_gray_stripes":{"name":"Blue-Gray Stripes", "theme":"smart_casual", "category":"room", "slot":"wall", "price":95, "description":"Clean blue-gray stripes with a modern feel.", "texture":preload("res://assets/shop/room/blue_gray_stripes.png")},
	"wall_clock":{"name":"Wall Clock", "theme":"smart_casual", "category":"room", "slot":"decor", "price":110, "description":"A simple round clock for a neat, finished room.", "texture":preload("res://assets/shop/room/wall_clock.png")},
	"navy_rectangle_rug":{"name":"Navy Rectangle Rug", "theme":"smart_casual", "category":"room", "slot":"rug", "price":100, "description":"A tidy navy rug with a crisp border.", "texture":preload("res://assets/shop/room/navy_rectangle_rug.png")},

	# Halloween
	"pumpkin_hat":{"name":"Pumpkin Hat", "theme":"halloween", "category":"pet", "slot":"head", "price":100, "description":"A cheerful pumpkin cap for spooky season.", "texture":preload("res://assets/shop/pet/pumpkin_hat.png")},
	"bat_mask":{"name":"Pumpkin Mask", "theme":"halloween", "category":"pet", "slot":"face", "price":110, "description":"A cheerful pumpkin mask for Pip's Halloween costume.", "texture":preload("res://assets/shop/pet/bat_mask.png")},
	"halloween_scarf":{"name":"Pumpkin Bow", "theme":"halloween", "category":"pet", "slot":"neck", "price":120, "description":"A pumpkin bow with purple ribbon tails for a playful spooky look.", "texture":preload("res://assets/shop/pet/halloween_scarf.png")},
	"halloween_wallpaper":{"name":"Halloween Wallpaper", "theme":"halloween", "category":"room", "slot":"wall", "price":125, "description":"Dark purple walls dotted with pumpkins and bats.", "texture":preload("res://assets/shop/room/halloween_wallpaper.png")},
	"jack_o_lantern":{"name":"Jack-o'-Lantern", "theme":"halloween", "category":"room", "slot":"decor", "price":140, "description":"A friendly glowing pumpkin for Pip's room.", "texture":preload("res://assets/shop/room/jack_o_lantern.png")},
	"pumpkin_rug":{"name":"Pumpkin Rug", "theme":"halloween", "category":"room", "slot":"rug", "price":130, "description":"A round orange rug shaped like a pumpkin.", "texture":preload("res://assets/shop/room/pumpkin_rug.png")},

	# Christmas
	"santa_hat":{"name":"Santa Hat", "theme":"christmas", "category":"pet", "slot":"head", "price":110, "description":"A soft red Santa hat with fluffy trim.", "texture":preload("res://assets/shop/pet/santa_hat.png")},
	"red_nose":{"name":"Red Nose", "theme":"christmas", "category":"pet", "slot":"face", "price":120, "description":"A bright little red nose for holiday Pip.", "texture":preload("res://assets/shop/pet/red_nose.png")},
	"holiday_scarf":{"name":"Holiday Scarf", "theme":"christmas", "category":"pet", "slot":"neck", "price":130, "description":"A cozy red, green, and cream winter scarf.", "texture":preload("res://assets/shop/pet/holiday_scarf.png")},
	"christmas_wallpaper":{"name":"Christmas Wallpaper", "theme":"christmas", "category":"room", "slot":"wall", "price":135, "description":"Soft winter-green walls with small festive details.", "texture":preload("res://assets/shop/room/christmas_wallpaper.png")},
	"wreath":{"name":"Holiday Wreath", "theme":"christmas", "category":"room", "slot":"decor", "price":150, "description":"A green wreath with berries and a red ribbon.", "texture":preload("res://assets/shop/room/wreath.png")},
	"holiday_rug":{"name":"Holiday Rug", "theme":"christmas", "category":"room", "slot":"rug", "price":140, "description":"A warm green rug with red and gold accents.", "texture":preload("res://assets/shop/room/holiday_rug.png")},

	# Pixel Knight
	"pixel_knight_helmet":{"name":"Pixel Knight Helmet", "theme":"pixel_knight", "category":"pet", "slot":"face", "price":140, "description":"A blocky silver helmet that covers Pip's whole face.", "texture":preload("res://assets/shop/pet/pixel_knight_helmet.png")},
	"pixel_visor":{"name":"Red Feather Plume", "theme":"pixel_knight", "category":"pet", "slot":"head", "price":150, "description":"A bright red plume that tops Pip's little knight helmet.", "texture":preload("res://assets/shop/pet/pixel_visor.png")},
	"pixel_chestplate":{"name":"Pixel Chestplate", "theme":"pixel_knight", "category":"pet", "slot":"neck", "price":160, "description":"A chunky pixel chestplate with a tiny gold crest.", "texture":preload("res://assets/shop/pet/pixel_chestplate.png")},
	"pixel_brick_wallpaper":{"name":"Pixel Brick Wallpaper", "theme":"pixel_knight", "category":"room", "slot":"wall", "price":165, "description":"Retro stone blocks for a tiny castle room.", "texture":preload("res://assets/shop/room/pixel_brick_wallpaper.png")},
	"pixel_castle_banner":{"name":"Pixel Castle Banner", "theme":"pixel_knight", "category":"room", "slot":"decor", "price":180, "description":"A retro castle banner for Pip's pixel room.", "texture":preload("res://assets/shop/room/pixel_castle_banner.png")},
	"pixel_tile_rug":{"name":"Pixel Tile Rug", "theme":"pixel_knight", "category":"room", "slot":"rug", "price":170, "description":"A stone-tile rug drawn in chunky pixels.", "texture":preload("res://assets/shop/room/pixel_tile_rug.png")}
}

static func slot_key(id: String) -> String:
	if not ITEMS.has(id):
		return ""
	return ITEMS[id].category + ":" + ITEMS[id].slot

static func pet_layout(slot: String, id: String = "") -> Dictionary:
	# Pet cosmetics are standardized to the shared 640x640 templates for each
	# slot, so new items can be authored directly against the template without
	# per-item render offsets or widths.
	return PET_SLOT_LAYOUT.get(slot, {"offset":Vector2.ZERO, "width":96.0}).duplicate()

static func room_layout(slot: String, id: String = "") -> Dictionary:
	# Room cosmetics are standardized to shared templates for each room slot.
	# Items should be authored directly onto those template canvases rather than
	# relying on per-item placement rectangles.
	return ROOM_SLOT_LAYOUT.get(slot, {}).duplicate()

static func theme_items(theme: String, category: String) -> Array[String]:
	var result: Array[String] = []
	for id in ITEMS:
		var item: Dictionary = ITEMS[id]
		if item.theme == theme and item.category == category:
			result.append(str(id))
	# Keep every row predictable: pet = head/face/neck; room = wall/decor/rug.
	var slot_order = ["head", "face", "neck"] if category == "pet" else ["wall", "decor", "rug"]
	result.sort_custom(func(a, b): return slot_order.find(ITEMS[a].slot) < slot_order.find(ITEMS[b].slot))
	return result
