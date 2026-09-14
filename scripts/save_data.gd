extends RefCounted
## One local save, no accounts or networking. Never decreases needs while closed.

const SAVE_PATH = "user://crittercare_save.json"
var discovered: Array = []
var inventory: Dictionary = {"berry": 6, "seed": 3, "carrot": 2}
var fullness: float = 64.0
var happiness: float = 72.0
var pet_count: int = 0
var feed_count: int = 0
var games_won: int = 0
var sound: bool = true
var calm: bool = false
var scores: Array = []
var save_path: String = SAVE_PATH

func load_progress() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var parser = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(save_path)) != OK:
		return
	var parsed = parser.data
	if not parsed is Dictionary:
		return
	if parsed.get("discovered") is Array:
		for key in parsed.discovered:
			if key is String and not discovered.has(key):
				discovered.append(key)
	if parsed.get("inventory") is Dictionary:
		for key in inventory:
			inventory[key] = clampi(int(parsed.inventory.get(key, inventory[key])), 0, 9999)
	fullness = clampf(float(parsed.get("fullness", 64.0)), 0, 100)
	happiness = clampf(float(parsed.get("happiness", 72.0)), 0, 100)
	pet_count = maxi(0, int(parsed.get("pet_count", 0)))
	feed_count = maxi(0, int(parsed.get("feed_count", 0)))
	games_won = maxi(0, int(parsed.get("games_won", 0)))
	sound = bool(parsed.get("sound", true))
	calm = bool(parsed.get("calm", false))
	if parsed.get("scores") is Array:
		for entry in parsed.scores:
			if entry is Dictionary and entry.get("mode") is String and entry.get("score") is float:
				scores.append({"mode":entry.mode, "score":clampi(int(entry.score), 0, 100)})
		scores.sort_custom(func(a, b): return a.score > b.score)
		scores = scores.slice(0, 3)

func write() -> Error:
	var payload = {"version":1, "discovered":discovered, "inventory":inventory, "fullness":fullness, "happiness":happiness, "pet_count":pet_count, "feed_count":feed_count, "games_won":games_won, "sound":sound, "calm":calm, "scores":scores}
	var file = FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return DirAccess.rename_absolute(save_path + ".tmp", save_path)

func unlock(key: String) -> bool:
	if discovered.has(key):
		return false
	discovered.append(key)
	return true

func can_feed(kind: String) -> bool:
	return fullness < 95.0 and int(inventory.get(kind, 0)) > 0

func feed(kind: String) -> bool:
	if not can_feed(kind):
		return false
	inventory[kind] -= 1
	var amounts = {"berry":14.0, "seed":9.0, "carrot":20.0}
	fullness = minf(100.0, fullness + amounts.get(kind, 10.0))
	happiness = minf(100.0, happiness + 5.0)
	feed_count += 1
	return true

func reward(mode: String, points: int, berries: int, seeds: int, carrots: int = 0) -> void:
	inventory.berry = mini(9999, inventory.berry + berries)
	inventory.seed = mini(9999, inventory.seed + seeds)
	inventory.carrot = mini(9999, inventory.carrot + carrots)
	games_won += 1
	# A win builds appetite, keeping the earn-treats / feed-Pip loop playable.
	fullness = maxf(0, fullness - 12.0)
	scores.append({"mode":mode, "score":points})
	scores.sort_custom(func(a, b): return a.score > b.score)
	scores = scores.slice(0, 3)
	happiness = minf(100.0, happiness + 12.0)
