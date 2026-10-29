extends RefCounted
## One catalog drives the creator, save validation, previews and every pet actor.
const SPECIES = ["hamster", "kitten", "bunny", "puppy", "fox", "panda"]
const COLORS = ["coat", "patch", "belly", "inner", "iris", "nose_color"]
const COLOR_LABELS = {"coat":"Main fur", "patch":"Markings", "belly":"Belly + muzzle", "inner":"Inner ears + paws", "iris":"Eyes", "nose_color":"Nose"}
const FEATURES = ["eyes", "nose", "mouth", "ears", "pattern"]
const TITLES = {"eyes":"Eyes", "nose":"Nose", "mouth":"Mouth", "ears":"Ears", "pattern":"Fur pattern"}
const LABELS = {
	"button":"Button", "sparkle":"Sparkly", "gentle":"Gentle", "cat_eye":"Cat eyes", "oval":"Soft oval",
	"triangle":"Triangle", "heart":"Heart", "snout":"Wide nose", "tiny":"Tiny", "smile":"Little smile",
	"grin":"Big smile", "tongue":"Tongue out", "buck":"Bunny teeth", "round":"Round", "small":"Little",
	"fluffy":"Fluffy", "pointed":"Pointy", "folded":"One folded", "tufted":"Tufted", "upright":"Tall",
	"lop":"Floppy", "one_lop":"One floppy", "floppy":"Floppy", "perky":"Perky", "one_up":"One up",
	"wide":"Wide", "cheeks":"Cheek puffs", "stripe":"Back stripe", "blaze":"Face blaze", "solid":"Plain fur",
	"tabby":"Tabby stripes", "tuxedo":"Tuxedo", "spots":"Spots", "dipped":"Dipped ears", "patches":"Eye patch",
	"socks":"Little socks", "mask":"Eye patches", "boots":"Dark boots", "moon":"Moon belly"
}
const CATALOG = {
	"hamster":{"title":"Hamster", "hint":"Pip's classic cozy look", "ears":["round","small","fluffy"], "eyes":["button","sparkle","gentle"], "nose":["button","heart","tiny"], "mouth":["smile","grin","tiny"], "pattern":["cheeks","stripe","blaze"], "colors":["cda477","9d7357","fff0d4","eab6a2","423930","ab7768"]},
	"kitten":{"title":"Kitten", "hint":"Pointy ears and a curling tail", "ears":["pointed","folded","tufted"], "eyes":["cat_eye","sparkle","gentle"], "nose":["triangle","heart","tiny"], "mouth":["smile","tongue","tiny"], "pattern":["tabby","tuxedo","solid"], "colors":["9aabb9","627386","f4efe6","e8b4ba","406c63","be8392"]},
	"bunny":{"title":"Bunny", "hint":"Long ears and a cotton tail", "ears":["upright","lop","one_lop"], "eyes":["oval","sparkle","gentle"], "nose":["heart","button","tiny"], "mouth":["buck","smile","tiny"], "pattern":["blaze","dipped","spots"], "colors":["e4d2c3","b69c8b","fff7ec","efb9c3","675056","c68d9d"]},
	"puppy":{"title":"Puppy", "hint":"Soft ears and a wagging tail", "ears":["floppy","perky","one_up"], "eyes":["oval","button","sparkle"], "nose":["snout","button","heart"], "mouth":["tongue","smile","grin"], "pattern":["patches","socks","solid"], "colors":["d7b180","936c4d","fff0d4","d59c8f","473b32","62483c"]},
	"fox":{"title":"Fox", "hint":"A fluffy tail with a bright tip", "ears":["pointed","wide","tufted"], "eyes":["cat_eye","gentle","sparkle"], "nose":["triangle","snout","tiny"], "mouth":["smile","grin","tongue"], "pattern":["mask","boots","blaze"], "colors":["d78a55","754d3c","fff0d6","e5b5a2","513d33","554137"]},
	"panda":{"title":"Panda", "hint":"Round ears and cuddly paws", "ears":["round","small","fluffy"], "eyes":["button","oval","sparkle"], "nose":["snout","button","heart"], "mouth":["smile","grin","tiny"], "pattern":["mask","socks","moon"], "colors":["ede9dc","58616a","fffaf0","d3a7ae","2e3840","45484b"]}
}
const PALETTES = {
	"Classic":[],
	"Peach":["e8b59b","c58170","fff0dc","e99eac","654742","b77283"],
	"Moon":["aaaaca","666b8c","f3edff","d0a6d4","4c486d","8e74a1"],
	"Mint":["a9c7b2","628877","eff7dc","e6b9b3","395951","9c7774"],
	"Cocoa":["a97e68","654a43","f3dcca","d9a28f","392d2b","714f4b"],
	"Snow":["e8e9ee","9dabb9","fffaf2","edbdcb","58647e","b77d96"]
}

static func defaults(species: String = "hamster") -> Dictionary:
	if not CATALOG.has(species): species = "hamster"
	var result = {"species":species}
	for key in FEATURES: result[key] = CATALOG[species][key][0]
	for i in range(COLORS.size()): result[COLORS[i]] = CATALOG[species].colors[i]
	return result

static func clean(value: Variant) -> Dictionary:
	if not value is Dictionary: return defaults()
	var result = defaults(str(value.get("species","hamster")))
	for key in FEATURES:
		if value.get(key) in CATALOG[result.species][key]: result[key] = value[key]
	for key in COLORS:
		var color = value.get(key)
		if color is String and color.length() == 6 and color.is_valid_hex_number(false):
			result[key] = color.to_lower()
	return result

static func designs(value: Variant) -> Dictionary:
	var result = {}
	if value is Dictionary:
		for species in SPECIES:
			if value.get(species) is Dictionary:
				var candidate: Dictionary = value[species].duplicate(true)
				candidate.species = species
				result[species] = clean(candidate)
	return result

static func palette(value: Dictionary, palette_name: String) -> Dictionary:
	var result = clean(value)
	var colors: Array = PALETTES.get(palette_name,[])
	if colors.is_empty(): colors = CATALOG[result.species].colors
	for i in range(COLORS.size()): result[COLORS[i]] = colors[i]
	return result

static func surprise(species: String) -> Dictionary:
	var result = defaults(species)
	for key in FEATURES: result[key] = CATALOG[result.species][key].pick_random()
	return palette(result, PALETTES.keys().pick_random())

static func title(value: Dictionary) -> String:
	return CATALOG[clean(value).species].title
