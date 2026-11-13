extends SceneTree

const Shop = preload("res://data/shop.gd")
const SaveData = preload("res://scripts/save_data.gd")
var failures := 0
var game

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
	else:
		print("PASS: " + message)

func send_key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	game._input(event)

func _initialize() -> void:
	if not "--test-mode" in OS.get_cmdline_user_args():
		quit(2)
		return
	call_deferred("run")

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in range(5):
		await process_frame
	if game.modal_name == "name_pet":
		game._complete_pet_name("Pip")
	game.tutorial.finish()
	game.close_modal()
	game.progress.coins = 0
	var sequence = [KEY_UP, KEY_UP, KEY_DOWN, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_LEFT, KEY_RIGHT, KEY_B, KEY_A]
	for key in sequence:
		send_key(key)
	check(game.progress.coins == 10000, "Konami sequence awards 10,000 gold")
	check(not game._ball_active(), "Code does not start Ball Play")
	var reloaded = SaveData.new()
	reloaded.save_path = game.progress.save_path
	reloaded.load_progress()
	check(reloaded.coins == 10000, "Gold survives reloading the save")
	for key in sequence:
		send_key(key)
	check(game.progress.coins == 20000, "Code can be entered again")
	send_key(KEY_UP)
	send_key(KEY_DOWN)
	check(game.secret_sequence_index == 0, "A wrong key resets the sequence")
	game.modal_name = "name_pet"
	for key in sequence:
		send_key(key)
	check(game.progress.coins == 20000, "Code is disabled while naming a pet")
	game.modal_name = ""
	for theme in ["sweetheart", "lucky_clover", "midnight_celebration", "spring_celebration"]:
		for category in ["pet", "room"]:
			for id in Shop.theme_items(theme, category):
				check(game.progress.buy(id), "Can buy " + id)
				check(game.progress.toggle_equip(id), "Can equip " + id)
				game.progress.write()
				reloaded.load_progress()
				check(reloaded.owned.has(id) and reloaded.equipped.get(Shop.slot_key(id), "") == id, "Purchase and equipment persist: " + id)
	print("HOLIDAYS: %d failures" % failures)
	quit(1 if failures else 0)
