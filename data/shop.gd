extends RefCounted
## A single catalog drives prices, ownership validation, previews, and slots.
const ITEMS = {
	"leaf_hat":{"name":"Little leaf hat", "category":"pet", "slot":"head", "price":20, "description":"A garden leaf for a curious head."},
	"bow":{"name":"Berry bow tie", "category":"pet", "slot":"neck", "price":35, "description":"A rosy bow for Pip's next adventure."},
	"glasses":{"name":"Round spectacles", "category":"pet", "slot":"face", "price":60, "description":"Golden frames for a little thinker."},
	"scarf":{"name":"Cozy blue scarf", "category":"pet", "slot":"neck", "price":75, "description":"A soft scarf with a tiny fringe."},
	"flower_hat":{"name":"Daisy sunhat", "category":"pet", "slot":"head", "price":110, "description":"A sunny brim and a little flower."},
	"crown":{"name":"Starlight crown", "category":"pet", "slot":"head", "price":180, "description":"A golden crown for your tiny friend."},
	"rose_mat":{"name":"Berry blush rug", "category":"room", "slot":"rug", "price":25, "description":"A woven rug in warm berry colors."},
	"blue_mat":{"name":"Cloud blue rug", "category":"room", "slot":"rug", "price":50, "description":"A peaceful blue place to play."},
	"peach_wall":{"name":"Peach wallpaper", "category":"room", "slot":"wall", "price":60, "description":"Warm peach walls for a cozy room."},
	"lantern":{"name":"Firefly lantern", "category":"room", "slot":"light", "price":90, "description":"A golden glow beside the window."},
	"night_wall":{"name":"Twilight wallpaper", "category":"room", "slot":"wall", "price":120, "description":"Soft lavender with little stars."},
	"bunting":{"name":"Party bunting", "category":"room", "slot":"garland", "price":150, "description":"Colorful flags above Pip's place."}
}
const ORDER = ["leaf_hat", "bow", "glasses", "scarf", "flower_hat", "crown", "rose_mat", "blue_mat", "peach_wall", "lantern", "night_wall", "bunting"]

static func slot_key(id: String) -> String:
	if not ITEMS.has(id):
		return ""
	return ITEMS[id].category + ":" + ITEMS[id].slot
