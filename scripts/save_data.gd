extends RefCounted
## One local save, no accounts or networking. Never decreases needs while closed.

const SAVE_PATH = "user://crittercare_save.json"
const Shop = preload("res://data/shop.gd")
const Curriculum = preload("res://data/curriculum.gd")
var coins: int = 0
var owned: Array = []
var equipped: Dictionary = {}
var stage_badges: Dictionary = {}
var practice_stage: int = 0
var discovered: Array = []
var pip_quotes: Dictionary = {}
var inventory: Dictionary = {"berry": 6, "seed": 3, "carrot": 2}
var fullness: float = 64.0
var happiness: float = 72.0
var pet_count: int = 0
var feed_count: int = 0
var games_won: int = 0
var picnic_best: int = 0
var picnic_rounds: int = 0
var tutorial_completed: bool = false
var sound: bool = true
var calm: bool = false
var game_level: String = "kindergarten"
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
	discovered.clear()
	pip_quotes.clear()
	scores.clear()
	if parsed.get("discovered") is Array:
		for key in parsed.discovered:
			if key is String and not discovered.has(key):
				discovered.append(key)
	if parsed.get("pip_quotes") is Dictionary:
		for key in parsed.pip_quotes:
			if key is String and discovered.has(key) and parsed.pip_quotes[key] is String:
				pip_quotes[key] = parsed.pip_quotes[key]
	if parsed.get("inventory") is Dictionary:
		for key in inventory:
			inventory[key] = clampi(int(parsed.inventory.get(key, inventory[key])), 0, 9999)
	fullness = clampf(float(parsed.get("fullness", 64.0)), 0, 100)
	happiness = clampf(float(parsed.get("happiness", 72.0)), 0, 100)
	pet_count = maxi(0, int(parsed.get("pet_count", 0)))
	feed_count = maxi(0, int(parsed.get("feed_count", 0)))
	games_won = maxi(0, int(parsed.get("games_won", 0)))
	picnic_best = clampi(int(parsed.get("picnic_best", 0)), 0, 10)
	picnic_rounds = maxi(0, int(parsed.get("picnic_rounds", 0)))
	# Existing pre-tutorial saves belong to returning players. Replay is in Settings.
	tutorial_completed = bool(parsed.get("tutorial_completed", true))
	sound = bool(parsed.get("sound", true))
	calm = bool(parsed.get("calm", false))
	var parsed_level = str(parsed.get("game_level", "kindergarten"))
	game_level = parsed_level if parsed_level in ["kindergarten", "middle", "college"] else "kindergarten"
	coins = clampi(int(parsed.get("coins", 0)), 0, 999999)
	owned.clear()
	equipped.clear()
	stage_badges.clear()
	if parsed.get("owned") is Array:
		for id in parsed.owned:
			if id is String and Shop.ITEMS.has(id) and not owned.has(id):
				owned.append(id)
	if parsed.get("equipped") is Dictionary:
		for slot in parsed.equipped:
			var id = str(parsed.equipped[slot])
			if owned.has(id) and Shop.slot_key(id) == slot:
				equipped[slot] = id
	if parsed.get("stage_badges") is Dictionary:
		for stage in range(Curriculum.STAGES.size()):
			var wins = parsed.stage_badges.get(str(stage), [])
			if wins is Array:
				stage_badges[str(stage)] = []
				for mode in Curriculum.MODES:
					if wins.has(mode):
						stage_badges[str(stage)].append(mode)
	practice_stage = clampi(int(parsed.get("practice_stage", 0)), 0, unlocked_stage())
	if parsed.get("scores") is Array:
		for entry in parsed.scores:
			if entry is Dictionary and entry.get("mode") is String and entry.get("score") is float:
				scores.append({"mode":entry.mode, "score":clampi(int(entry.score), 0, 100)})
		scores.sort_custom(func(a, b): return a.score > b.score)
		scores = scores.slice(0, 3)

func write() -> Error:
	var payload = {"version":6, "discovered":discovered, "pip_quotes":pip_quotes, "inventory":inventory, "fullness":fullness, "happiness":happiness, "pet_count":pet_count, "feed_count":feed_count, "games_won":games_won, "picnic_best":picnic_best, "picnic_rounds":picnic_rounds, "tutorial_completed":tutorial_completed, "sound":sound, "calm":calm, "game_level":game_level, "scores":scores, "coins":coins, "owned":owned, "equipped":equipped, "stage_badges":stage_badges, "practice_stage":practice_stage}
	var file = FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return DirAccess.rename_absolute(save_path + ".tmp", save_path)

func reset_progress(keep_preferences: bool = true) -> void:
	var old_sound = sound
	var old_calm = calm
	var old_level = game_level
	discovered = []
	pip_quotes = {}
	inventory = {"berry": 6, "seed": 3, "carrot": 2}
	fullness = 64.0
	happiness = 72.0
	pet_count = 0
	feed_count = 0
	games_won = 0
	picnic_best = 0
	picnic_rounds = 0
	tutorial_completed = false
	scores = []
	coins = 0
	owned = []
	equipped = {}
	stage_badges = {}
	practice_stage = 0
	if keep_preferences:
		sound = old_sound
		calm = old_calm
		game_level = old_level
	else:
		sound = true
		calm = false
		game_level = "kindergarten"

func unlock(key: String) -> bool:
	if discovered.has(key):
		return false
	discovered.append(key)
	return true

func unlocked_stage() -> int:
	return Curriculum.unlocked(stage_badges, game_level)

func active_stage() -> int:
	return clampi(practice_stage, 0, unlocked_stage())

func mark_stage_win(stage: int, mode: String) -> void:
	if stage < 0 or stage > unlocked_stage() or not mode in Curriculum.MODES:
		return
	var previous = unlocked_stage()
	var key = str(stage)
	if not stage_badges.has(key):
		stage_badges[key] = []
	if not stage_badges[key].has(mode):
		stage_badges[key].append(mode)
	if unlocked_stage() > previous:
		practice_stage = unlocked_stage()

func buy(id: String) -> bool:
	if not Shop.ITEMS.has(id) or owned.has(id):
		return false
	var price: int = Shop.ITEMS[id].price
	if coins < price:
		return false
	coins -= price
	owned.append(id)
	return true

func toggle_equip(id: String) -> bool:
	if not Shop.ITEMS.has(id) or not owned.has(id):
		return false
	var slot = Shop.slot_key(id)
	if equipped.get(slot, "") == id:
		equipped.erase(slot)
	else:
		equipped[slot] = id
	return true

func cosmetics(category: String) -> Dictionary:
	var result = {}
	for slot in equipped:
		if slot.begins_with(category + ":"):
			result[slot.get_slice(":", 1)] = equipped[slot]
	return result

func award_coins(amount: int) -> void:
	coins = clampi(coins + maxi(0, amount), 0, 999999)

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
