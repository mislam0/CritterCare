extends SceneTree
## Real-renderer gallery + regression checks for every coordinated shop set.
## godot --path . --script res://tests/verify_shop_art.gd -- --test-mode --capture=...
const Shop = preload("res://data/shop.gd")
var checks := 0
var failures := 0
var capture_dir := ""
var game

func _initialize() -> void:
	if not "--test-mode" in OS.get_cmdline_user_args():
		quit(2)
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_dir = arg.trim_prefix("--capture=")
	call_deferred("run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func frames(count: int = 3) -> void:
	for i in range(count):
		await process_frame

func snap(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless":
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await frames()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(name + ".png"))

func run() -> void:
	root.size = Vector2i(1280, 800)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(5)
	if game.modal_name == "name_pet":
		game._complete_pet_name("Pip")
	game.tutorial.finish()
	game.close_modal()
	game.progress.sound = false
	game.progress.coins = 100000
	game.speech.visible = false
	game.speech_queue.clear()
	game.set_process(false)
	game.pip.set_physics_process(false)
	var room = game.get_node("Room")
	check(room.get_node("WallpaperMask").clip_children == CanvasItem.CLIP_CHILDREN_ONLY, "Wallpaper stays inside rounded room mask")
	var help_card: Control = game.ui.get_node("HomeHelp")
	check(help_card.get_global_rect().end.y <= Shop.DECOR_SET_LAYOUT["left_shelf"].rect.position.y, "Home help clears the shelf artwork")
	for theme in Shop.THEME_ORDER:
		game.progress.equipped.clear()
		for id in Shop.ITEMS:
			if Shop.ITEMS[id].theme != theme:
				continue
			if not game.progress.owned.has(id):
				check(game.progress.buy(id), "Can buy " + id)
			check(game.progress.toggle_equip(id), "Can equip " + id)
		game._apply_cosmetics()
		await frames()
		check(game.pip.costumes.get_child_count() == 3, theme + ": three pet pieces")
		check(not room.furniture.visible, theme + ": complete set replaces base silhouettes")
		for sprite in game.pip.costumes.get_children():
			check(sprite.texture.get_size() == Vector2(640, 640), theme + ": pet canvas")
			if theme == "pixel_knight":
				check(sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Pixel pet filtering")
		for piece in ["main_wall", "left_shelf", "side_hanging", "window", "right_plant", "food_bowl", "floor_cushion"]:
			var layer: TextureRect = room.decor_pieces[piece]
			check(layer.visible and layer.texture != null, theme + ": visible " + piece)
			check(layer.position == Shop.DECOR_SET_LAYOUT[piece].rect.position, theme + ": anchor " + piece)
			if theme == "pixel_knight":
				check(layer.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Pixel room filtering")
		game.pip.clock = 0
		game.pip.angle = 0
		game.pip.squish = 0
		game.pip._update_costume_pose()
		game.pip.queue_redraw()
		game._refresh_home()
		await snap(theme)
		game.pip.angle = 0.2
		game.pip.squish = 0.05
		game.pip.clock = 0.5
		game.pip._update_costume_pose()
		check(absf(game.pip.costumes.rotation) > 0.01, theme + ": costumes follow motion")
		check(game.pip.costumes.scale != Vector2.ONE, theme + ": costumes follow squash/breathing")
		if theme == "bear_spirit":
			await snap("bear_spirit-motion")
	game.pip.angle = 0
	game.pip.squish = 0
	game.pip._update_costume_pose()
	game.shop_category = "pet"
	game.open_shop()
	await snap("shop-pet")
	game._set_shop_category("room")
	await snap("shop-room")
	game.close_modal()
	game.progress.equipped.clear()
	game._apply_cosmetics()
	for piece in room.decor_pieces.values():
		check(not piece.visible, "Unequipping hides themed overlays")
	check(room.furniture.visible, "Unequipping restores original furniture")
	await snap("default-room")
	print("SHOP ART: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
