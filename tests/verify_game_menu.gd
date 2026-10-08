extends "res://tests/verify.gd"
## Catalog layout and actual navigation; this does not duplicate game scoring tests.
const Menu = preload("res://data/game_menu.gd")

func screen_point(point: Vector2) -> Vector2:
	return point * (Vector2(root.size) / Vector2(1280,800))

func visible_button(button: Button) -> bool:
	return game.games_scroll.get_global_rect().encloses(button.get_global_rect())

func wheel(point: Vector2) -> void:
	await mouse_move(screen_point(point))
	for i in range(4):
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_WHEEL_DOWN
		event.position = screen_point(point)
		event.global_position = event.position
		event.pressed = true
		Input.parse_input_event(event)
		await frames(2)
		event.pressed = false
		Input.parse_input_event(event)
		await frames(2)

func tab() -> void:
	var event = InputEventKey.new()
	event.keycode = KEY_TAB
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event.pressed = false
	Input.parse_input_event(event)
	await frames(2)

func run() -> void:
	graphical = DisplayServer.get_name() != "headless"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_dir = arg.trim_prefix("--capture=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
	root.size = Vector2i(1280,800)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(5)
	game.tutorial.finish()
	game.progress.sound = false
	game.open_games()
	await frames(5)
	check(game.game_menu_button("PlayQuiz").disabled,"Quiz remains locked until a lesson is discovered")
	game._show_lesson("boolean")
	for window in [Vector2i(1280,800),Vector2i(960,600)]:
		root.size = window
		for level in Lessons.LEVELS:
			game.progress.game_level = level
			game.games_scroll_offset = 0
			game.open_games()
			await frames(6)
			var scroll: ScrollContainer = game.games_scroll
			check(scroll.get_v_scroll_bar().visible and scroll.get_v_scroll_bar().max_value > scroll.size.y,"Catalog overflows vertically with a visible scrollbar: %s %s" % [window,level])
			var problems = []
			for id in Menu.ORDER:
				var button = game.game_menu_button(Menu.CARDS[id].button)
				var card: Control = button.get_meta("game_card")
				var description = card.find_child("GameDescription",true,false)
				var title = card.find_child("GameTitle",true,false)
				var reward = card.find_child("GameRewards",true,false)
				if title.words.is_empty() or description.words.is_empty() or reward.words.is_empty(): problems.append(id+" missing text")
				if not card.get_global_rect().encloses(button.get_global_rect()): problems.append(id+" button outside card")
				for words in [title,description,reward]:
					if not words.content_fits(): problems.append(id+" clipped text")
					if not card.get_global_rect().encloses(words.get_global_rect()): problems.append(id+" text outside card")
				if card.get_global_rect().end.x > scroll.get_global_rect().end.x-12: problems.append(id+" horizontal overflow")
				game.reveal_game(Menu.CARDS[id].button)
				await frames(2)
				if not visible_button(button): problems.append(id+" unreachable")
			check(problems.is_empty(),"All six cards have complete text and reachable buttons: %s %s %s" % [window,level,problems])
			game.games_scroll.scroll_vertical = 0
			await frames(2)
			check(visible_button(game.game_menu_button("PlaySort")) and visible_button(game.game_menu_button("PlayLoop")) and visible_button(game.game_menu_button("PlayQuiz")),"All first-row Play buttons fit before scrolling: %s %s" % [window,level])
			await snap("menu-%s-%d-top" % [level,window.x])
			game.reveal_game("PlayLogicLab")
			await snap("menu-%s-%d-bottom" % [level,window.x])
		# Real input rather than assigning the scrollbar for these checks.
		game.games_scroll.scroll_vertical = 0
		await frames(3)
		await wheel(Vector2(550,480))
		check(game.games_scroll.scroll_vertical > 0,"Mouse wheel scrolls over card text: %s" % window)
		game.games_scroll.scroll_vertical = 0
		await frames(3)
		var bar = game.games_scroll.get_v_scroll_bar()
		await click(screen_point(bar.get_global_rect().position+Vector2(7,340)))
		check(game.games_scroll.scroll_vertical > 0,"Scrollbar track clicks reveal lower games: %s" % window)
		game.games_scroll.scroll_vertical = 0
		await frames(2)
		var start = screen_point(bar.get_global_rect().position+Vector2(7,80))
		await mouse_move(start)
		await mouse_button(start,true)
		await mouse_move(screen_point(bar.get_global_rect().position+Vector2(7,270)))
		await mouse_button(screen_point(bar.get_global_rect().position+Vector2(7,270)),false)
		check(game.games_scroll.scroll_vertical > 0,"Dragging the green scrollbar reveals lower games: %s" % window)
		game.games_scroll.scroll_vertical = 0
		game.game_menu_button("PlayQuiz").grab_focus()
		await frames(2)
		await tab()
		check(game.game_menu_button("PlayPicnic").has_focus() and visible_button(game.game_menu_button("PlayPicnic")),"Tab follows the grid order and reveals Picnic Catch: %s" % window)
		game.game_menu_button("PlayPicnic").release_focus()
		game.games_scroll.scroll_vertical = 0
		await frames(2)
		# Visit all six destinations by clicking their visible buttons.
		for id in Menu.ORDER:
			game.open_games()
			await frames(5)
			game.reveal_game(Menu.CARDS[id].button)
			await frames(3)
			await click(screen_point(game.game_menu_button(Menu.CARDS[id].button).get_global_rect().get_center()))
			var expected = {"sort":["sort"],"loop":["loop"],"quiz":["quiz"],"picnic":["intro","picnic"],"lab":["lab_menu"],"jam":["snack_jam"]}[id]
			check(game.modal_name in expected,"Visible card launches %s at %s (actual %s)" % [id,window,game.modal_name])
		game.open_games()
		await frames(5)
		game.reveal_game("PlaySnackJam")
		await frames(2)
		var offset: int = game.games_scroll.scroll_vertical
		game.close_modal()
		game.open_games()
		await frames(5)
		check(offset > 0 and game.games_scroll.scroll_vertical == offset,"Returning to Games remembers the browsing position: %s" % window)
		game.start_tutorial()
		game.tutorial.step = game.tutorial.STEPS.size()-1
		game.tutorial._enter_step()
		await frames(6)
		check(visible_button(game.game_menu_button("PlayPicnic")) and game.tutorial.target_rect.has_point(game.game_menu_button("PlayPicnic").get_global_rect().get_center()),"Tutorial automatically reveals its actual Picnic Catch target: %s" % window)
		await snap("menu-tutorial-%d" % window.x)
		await click(screen_point(game.game_menu_button("PlayPicnic").get_global_rect().get_center()))
		check(not game.tutorial.active and game.modal_name in ["intro","picnic"],"Tutorial target accepts the real click after scrolling: %s" % window)
	game.games_scroll_offset = 300
	game._reset_progress()
	check(game.games_scroll_offset == 0,"Reset starts the catalog at the beginning")
	game.tutorial.finish()
	game.queue_free()
	await frames(2)
	print("GAME MENU RESULT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
