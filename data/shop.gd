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

# Optional pieces in a single Room Decor Set. Coordinates are in the room's
# native 1280x800 space and sit in FRONT of existing room_furniture.png.
# Keep "room:decor" save keys; only the visual assembly is changing.
# The original room-furniture ideas (left shelf / little hanging / right accent)
# are still supported, and the set can now also theme the larger furniture beats
# shown in the room guides: window, plant, bowl, and a small floor item.
const DECOR_SET_LAYOUT = {
	"main_wall": {"rect":Rect2(435,164,410,396)},
	"left_shelf": {"rect":Rect2(98,315,200,155)},
	"side_hanging": {"rect":Rect2(850,302,95,150)},
	"right_surface": {"rect":Rect2(1014,384,190,205)},
	"window": {"rect":Rect2(930,174,242,222)},
	"right_plant": {"rect":Rect2(1036,378,154,224)},
	"food_bowl": {"rect":Rect2(883,510,114,64)},
	"floor_cushion": {"rect":Rect2(86,501,171,92)}
}

static func decor_set_piece_path(theme: String, piece: String) -> String:
	if not THEMES.has(theme) or piece == "main_wall" or not DECOR_SET_LAYOUT.has(piece):
		return ""
	return "res://assets/shop/room/decor_sets/%s/%s.png" % [theme, piece]

const THEME_ORDER = ["nature", "study", "smart_casual", "bear_spirit", "easter", "halloween", "thanksgiving", "christmas", "brainrot", "pixel_knight"]
const THEMES = {
	"nature":{"name":"Nature", "tagline":"Soft greens and little garden details."},
	"study":{"name":"Study", "tagline":"A tidy look for learning with {pet_name}."},
	"smart_casual":{"name":"Smart Casual", "tagline":"Clean, cool, and a little dressed up."},
	"halloween":{"name":"Halloween", "tagline":"Pumpkins, bats, and cozy spooky colors."},
	"christmas":{"name":"Christmas", "tagline":"Warm holiday colors and winter cheer."},
	"pixel_knight":{"name":"Pixel Knight", "tagline":"A tiny retro adventure set."},
	"easter":{"name":"Easter", "tagline":"Cracked eggs and springtime colors."},
	"brainrot":{"name":"Brainrot", "tagline":"Propellers, 67, and Tung Tung silliness."},
	"thanksgiving":{"name":"Thanksgiving", "tagline":"Autumn leaves, harvest treats, and warm colors."},
	"bear_spirit":{"name":"Bear Spirit", "tagline":"Little woodland comforts and friendly bear motifs."}
}

const ITEMS = {
	# Nature
	"leaf_hat":{"name":"Leaf Hat", "theme":"nature", "category":"pet", "slot":"head", "price":25, "description":"Overlapping green leaves make a little woodland hat.", "texture":preload("res://assets/shop/pet/head/leaf_hat.png")},
	"flower_clip":{"name":"Leaf Glasses", "theme":"nature", "category":"pet", "slot":"face", "price":35, "description":"Green leaf spectacles for a nature-loving {pet_name}.", "texture":preload("res://assets/shop/pet/face/leaf_glasses.png")},
	"vine_scarf":{"name":"Vine Collar", "theme":"nature", "category":"pet", "slot":"neck", "price":45, "description":"A light leafy collar with a white flower.", "texture":preload("res://assets/shop/pet/neck/vine_collar.png")},
	"sage_wallpaper":{"name":"Leafy Pattern", "theme":"nature", "category":"room", "slot":"wall", "price":45, "description":"A gentle repeat of leafy branches in warm green tones.", "texture":preload("res://assets/shop/room/wall/sage_wallpaper.png")},
	"hanging_plant":{"name":"Nature Decor Set", "theme":"nature", "category":"room", "slot":"decor", "price":60, "description":"A hanging planter, garden window, leafy shelf, botanical hanging, plant, bowl, and cushion.", "texture":preload("res://assets/shop/room/decor/hanging_plant.png")},
	"leaf_rug":{"name":"Leaf Rug", "theme":"nature", "category":"room", "slot":"rug", "price":55, "description":"A soft green rug shaped with simple leaf details.", "texture":preload("res://assets/shop/room/rug/leaf_rug.png")},

	# Study
	"scholar_cap":{"name":"Beret", "theme":"study", "category":"pet", "slot":"head", "price":65, "description":"A little red beret for creative study sessions.", "texture":preload("res://assets/shop/pet/head/study_beret.png")},
	"glasses":{"name":"Round Glasses", "theme":"study", "category":"pet", "slot":"face", "price":75, "description":"Classic simple round glasses for reading.", "texture":preload("res://assets/shop/pet/face/glasses.png")},
	"bow":{"name":"Study Scarf", "theme":"study", "category":"pet", "slot":"neck", "price":85, "description":"A cozy red and gold plaid scarf for reading afternoons.", "texture":preload("res://assets/shop/pet/neck/study_scarf.png")},
	"warm_cream_wallpaper":{"name":"Notebook Paper", "theme":"study", "category":"room", "slot":"wall", "price":85, "description":"Notebook lines with tiny pencils and open books.", "texture":preload("res://assets/shop/room/wall/notebook_wallpaper.png")},
	"study_bookshelf":{"name":"Study Decor Set", "theme":"study", "category":"room", "slot":"decor", "price":100, "description":"Framed book art, a library window, book shelf, pencil hanging, plant, bowl, and reading cushion.", "texture":preload("res://assets/shop/room/decor/framed_book.png")},
	"plaid_study_rug":{"name":"Book Rug", "theme":"study", "category":"room", "slot":"rug", "price":95, "description":"An oval reading rug with an open book.", "texture":preload("res://assets/shop/room/rug/book_rug.png")},

	# Smart Casual
	"flat_cap":{"name":"Flat Cap", "theme":"smart_casual", "category":"pet", "slot":"head", "price":105, "description":"A brown checked cap with a simple curved brim.", "texture":preload("res://assets/shop/pet/head/brown_flat_cap.png")},
	"sunglasses":{"name":"Sunglasses", "theme":"smart_casual", "category":"pet", "slot":"face", "price":115, "description":"Cool shades that pair perfectly with a tie.", "texture":preload("res://assets/shop/pet/face/sunglasses.png")},
	"necktie":{"name":"Necktie", "theme":"smart_casual", "category":"pet", "slot":"neck", "price":125, "description":"A simple blue tie for {pet_name}'s dressed-up days.", "texture":preload("res://assets/shop/pet/neck/necktie.png")},
	"blue_gray_stripes":{"name":"Stripe Pattern", "theme":"smart_casual", "category":"room", "slot":"wall", "price":125, "description":"Neat blue and cream stripes for an easygoing room.", "texture":preload("res://assets/shop/room/wall/blue_gray_stripes.png")},
	"wall_clock":{"name":"Smart Casual Decor Set", "theme":"smart_casual", "category":"room", "slot":"decor", "price":140, "description":"A wall clock, blue-sky window, tidy shelf, geometric hanging, striped plant pot, bowl, and plaid cushion.", "texture":preload("res://assets/shop/room/decor/wall_clock.png")},
	"navy_rectangle_rug":{"name":"Casual Rug", "theme":"smart_casual", "category":"room", "slot":"rug", "price":135, "description":"An oval navy rug with a quiet plaid pattern.", "texture":preload("res://assets/shop/room/rug/casual_rug.png")},

	# Halloween
	"pumpkin_hat":{"name":"Witch Hat", "theme":"halloween", "category":"pet", "slot":"head", "price":225, "description":"A simple purple witch hat for Halloween.", "texture":preload("res://assets/shop/pet/head/witch_hat.png")},
	"bat_mask":{"name":"Pumpkin Mask", "theme":"halloween", "category":"pet", "slot":"face", "price":235, "description":"Pumpkin-shaped eye openings for {pet_name}'s Halloween costume.", "texture":preload("res://assets/shop/pet/face/pumpkin_mask.png")},
	"halloween_scarf":{"name":"Candy Corn Bow Tie", "theme":"halloween", "category":"pet", "slot":"neck", "price":245, "description":"An orange, yellow and cream Halloween bow.", "texture":preload("res://assets/shop/pet/neck/candy_corn_bowtie.png")},
	"halloween_wallpaper":{"name":"Pumpkin Night", "theme":"halloween", "category":"room", "slot":"wall", "price":245, "description":"Little pumpkins, stars and crescent moons against deep purple.", "texture":preload("res://assets/shop/room/wall/halloween_wallpaper.png")},
	"jack_o_lantern":{"name":"Halloween Decor Set", "theme":"halloween", "category":"room", "slot":"decor", "price":260, "description":"A friendly ghost, moonlit window, pumpkin shelf, moon hanging, pumpkin plant pot, bowl, and cushion.", "texture":preload("res://assets/shop/room/decor/ghost_wall_hanging.png")},
	"pumpkin_rug":{"name":"Jack-o'-Lantern Rug", "theme":"halloween", "category":"room", "slot":"rug", "price":255, "description":"An orange oval pumpkin rug with a friendly carved face.", "texture":preload("res://assets/shop/room/rug/pumpkin_rug.png")},

	# Christmas
	"santa_hat":{"name":"Santa Hat", "theme":"christmas", "category":"pet", "slot":"head", "price":305, "description":"A soft red Santa hat with fluffy trim.", "texture":preload("res://assets/shop/pet/head/santa_hat.png")},
	"red_nose":{"name":"Holly Glasses", "theme":"christmas", "category":"pet", "slot":"face", "price":315, "description":"Round green glasses decorated with holly leaves.", "texture":preload("res://assets/shop/pet/face/holly_glasses.png")},
	"holiday_scarf":{"name":"Holiday Scarf", "theme":"christmas", "category":"pet", "slot":"neck", "price":325, "description":"A cozy red and green winter scarf.", "texture":preload("res://assets/shop/pet/neck/holiday_scarf.png")},
	"christmas_wallpaper":{"name":"Holly Snow", "theme":"christmas", "category":"room", "slot":"wall", "price":325, "description":"Winter-green wallpaper with holly sprigs and snowflakes.", "texture":preload("res://assets/shop/room/wall/christmas_wallpaper.png")},
	"wreath":{"name":"Christmas Decor Set", "theme":"christmas", "category":"room", "slot":"decor", "price":340, "description":"A holiday wreath, snowy window, gift shelf, star hanging, Christmas tree, festive bowl, and cushion.", "texture":preload("res://assets/shop/room/decor/wreath.png")},
	"holiday_rug":{"name":"Ornament Rug", "theme":"christmas", "category":"room", "slot":"rug", "price":335, "description":"A festive red and green oval rug with simple winter motifs.", "texture":preload("res://assets/shop/room/rug/holiday_rug.png")},

	# Pixel Knight
	"pixel_knight_helmet":{"name":"Pixel Knight Helmet", "theme":"pixel_knight", "category":"pet", "slot":"face", "price":395, "description":"A crisp silver pixel helmet with a dark visor and gold rivets.", "texture":preload("res://assets/shop/pet/face/pixel_knight_helmet.png")},
	"pixel_visor":{"name":"Pixel Knight Plume", "theme":"pixel_knight", "category":"pet", "slot":"head", "price":385, "description":"A bright red pixel plume for the little knight helmet.", "texture":preload("res://assets/shop/pet/head/pixel_knight_plume.png")},
	"pixel_chestplate":{"name":"Pixel Knight Chest", "theme":"pixel_knight", "category":"pet", "slot":"neck", "price":405, "description":"Silver pixel armor with a gold edge and little crest.", "texture":preload("res://assets/shop/pet/neck/pixel_knight_chest.png")},
	"pixel_brick_wallpaper":{"name":"Pixel Brick Wallpaper", "theme":"pixel_knight", "category":"room", "slot":"wall", "price":405, "description":"Gray castle stones with little blue and gold banners.", "texture":preload("res://assets/shop/room/wall/pixel_brick_wallpaper.png")},
	"pixel_castle_banner":{"name":"Pixel Knight Decor Set", "theme":"pixel_knight", "category":"room", "slot":"decor", "price":420, "description":"A heraldic banner, castle window, shield shelf, star shield plaque, pixel plant, crest bowl, and cushion.", "texture":preload("res://assets/shop/room/decor/pixel_castle_banner.png")},
	"pixel_tile_rug":{"name":"Pixel Tile Rug", "theme":"pixel_knight", "category":"room", "slot":"rug", "price":415, "description":"A blue and cream pixel rug with a gold shield crest.", "texture":preload("res://assets/shop/room/rug/pixel_tile_rug.png")},
	# Easter
	"bunny_ears":{"name":"Cracked Egg Headpiece", "theme":"easter", "category":"pet", "slot":"head", "price":185, "description":"A pastel eggshell headpiece decorated with a little flower.", "texture":preload("res://assets/shop/pet/head/cracked_egg_head.png")},
	"egg_cheek_sticker":{"name":"Carrot Glasses", "theme":"easter", "category":"pet", "slot":"face", "price":195, "description":"Bright orange spring glasses with leafy accents.", "texture":preload("res://assets/shop/pet/face/carrot_glasses.png")},
	"spring_bow_tie":{"name":"Ribbon Collar", "theme":"easter", "category":"pet", "slot":"neck", "price":205, "description":"A large flat pink bow and daisy on a straight green ribbon.", "texture":preload("res://assets/shop/pet/neck/spring_bow_tie.png")},
	"easter_wallpaper":{"name":"Easter Pattern", "theme":"easter", "category":"room", "slot":"wall", "price":205, "description":"A bright springtime pattern of colored eggs and flowers.", "texture":preload("res://assets/shop/room/wall/easter_wallpaper.png")},
	"easter_egg_garland":{"name":"Easter Decor Set", "theme":"easter", "category":"room", "slot":"decor", "price":220, "description":"An Easter basket, spring window, egg shelf, flower hanging, daisies, bowl, and pink cushion.", "texture":preload("res://assets/shop/room/decor/easter_basket.png")},
	"easter_egg_rug":{"name":"Egg Rug", "theme":"easter", "category":"room", "slot":"rug", "price":215, "description":"A soft pastel oval rug with spring eggs and flower accents.", "texture":preload("res://assets/shop/room/rug/easter_egg_rug.png")},

	# Brainrot
	"brainrot_shark_cap":{"name":"Propeller Hat", "theme":"brainrot", "category":"pet", "slot":"head", "price":345, "description":"A bright propeller beanie for a very silly look.", "texture":preload("res://assets/shop/pet/head/brainrot_propeller_hat.png")},
	"brainrot_coffee_glasses":{"name":"67 Glasses", "theme":"brainrot", "category":"pet", "slot":"face", "price":355, "description":"Golden novelty frames shaped like the numbers 6 and 7.", "texture":preload("res://assets/shop/pet/face/brainrot_67_glasses.png")},
	"brainrot_banana_bow":{"name":"Tung Tung Tie", "theme":"brainrot", "category":"pet", "slot":"neck", "price":365, "description":"A wooden-looking tie with a goofy Tung Tung face.", "texture":preload("res://assets/shop/pet/neck/brainrot_tung_tung_tie.png")},
	"brainrot_wallpaper":{"name":"Brainrot Doodle", "theme":"brainrot", "category":"room", "slot":"wall", "price":365, "description":"A cheerful chaos of doodles, squiggles, stars and spirals.", "texture":preload("res://assets/shop/room/wall/brainrot_wallpaper.png")},
	"brainrot_meme_poster":{"name":"Brainrot Decor Set", "theme":"brainrot", "category":"room", "slot":"decor", "price":380, "description":"A Tung Tung sign, playful window, toy shelf, star hanging, curly plant, spiral bowl, and star cushion.", "texture":preload("res://assets/shop/room/decor/brainrot_tung_tung_poster.png")},
	"brainrot_swirl_rug":{"name":"Spiral Rug", "theme":"brainrot", "category":"room", "slot":"rug", "price":375, "description":"A wide blue rug with one big white curling spiral.", "texture":preload("res://assets/shop/room/rug/brainrot_spiral_rug.png")},

	# Thanksgiving & Bear Spirit — two complete 3+3 rows
	"thanksgiving_turkey_hat":{"name":"Turkey Hat", "theme":"thanksgiving", "category":"pet", "slot":"head", "price":265, "description":"A little autumn turkey hat for {pet_name}.", "texture":preload("res://assets/shop/pet/head/thanksgiving_turkey_hat.png")},
	"thanksgiving_leaf_glasses":{"name":"Autumn Leaf Glasses", "theme":"thanksgiving", "category":"pet", "slot":"face", "price":275, "description":"Fall-colored leaf frames for cozy days.", "texture":preload("res://assets/shop/pet/face/thanksgiving_leaf_glasses.png")},
	"thanksgiving_harvest_bow":{"name":"Harvest Bow Tie", "theme":"thanksgiving", "category":"pet", "slot":"neck", "price":285, "description":"A warm orange bow tie for harvest season.", "texture":preload("res://assets/shop/pet/neck/thanksgiving_harvest_bow.png")},
	"thanksgiving_wallpaper":{"name":"Harvest Pattern", "theme":"thanksgiving", "category":"room", "slot":"wall", "price":285, "description":"A harvest pattern of orange pumpkins and fall leaves.", "texture":preload("res://assets/shop/room/wall/thanksgiving_wallpaper.png")},
	"thanksgiving_cornucopia":{"name":"Thanksgiving Decor Set", "theme":"thanksgiving", "category":"room", "slot":"decor", "price":300, "description":"A cornucopia, autumn window, harvest shelf, leaf hanging, autumn plant, bowl, and plaid cushion.", "texture":preload("res://assets/shop/room/decor/thanksgiving_cornucopia.png")},
	"thanksgiving_pie_rug":{"name":"Pie Rug", "theme":"thanksgiving", "category":"room", "slot":"rug", "price":295, "description":"A golden pumpkin pie rug with a simple lattice crust.", "texture":preload("res://assets/shop/room/rug/thanksgiving_pie_rug.png")},
	"bear_spirit_hood":{"name":"Bear Spirit Hood", "theme":"bear_spirit", "category":"pet", "slot":"head", "price":145, "description":"A friendly bear cap with round ears and a little green leaf.", "texture":preload("res://assets/shop/pet/head/bear_spirit_hood.png")},
	"bear_spirit_glasses":{"name":"Woodland Glasses", "theme":"bear_spirit", "category":"pet", "slot":"face", "price":155, "description":"Simple warm-gold glasses for an explorer.", "texture":preload("res://assets/shop/pet/face/bear_spirit_glasses.png")},
	"bear_spirit_scarf":{"name":"Bear Spirit Scarf", "theme":"bear_spirit", "category":"pet", "slot":"neck", "price":165, "description":"A green scarf with a tiny bear charm.", "texture":preload("res://assets/shop/pet/neck/bear_spirit_scarf.png")},
	"bear_spirit_wallpaper":{"name":"Woodland Wallpaper", "theme":"bear_spirit", "category":"room", "slot":"wall", "price":165, "description":"Little leaves, trees, and friendly bear faces.", "texture":preload("res://assets/shop/room/wall/bear_spirit_wallpaper.png")},
	"bear_spirit_banner":{"name":"Bear Spirit Decor Set", "theme":"bear_spirit", "category":"room", "slot":"decor", "price":180, "description":"A bear banner, woodland window, bear shelf, lantern, trailing plant, bear bowl, and bear cushion.", "texture":preload("res://assets/shop/room/decor/bear_spirit_banner.png")},
	"bear_spirit_rug":{"name":"Bear Spirit Rug", "theme":"bear_spirit", "category":"room", "slot":"rug", "price":175, "description":"A soft green oval rug with a bear design.", "texture":preload("res://assets/shop/room/rug/bear_spirit_rug.png")}

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
