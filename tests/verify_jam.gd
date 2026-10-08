extends "res://tests/verify.gd"
## Rhythm judgement, real controls/audio playback, persistence and rewards.
const Jam = preload("res://data/snack_jam.gd")
const UI = preload("res://scripts/ui.gd")

func key_press(code: int, echo: bool = false) -> void:
	var event = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	event.echo = echo
	Input.parse_input_event(event)
	await frames(2)
	event = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = false
	Input.parse_input_event(event)
	await frames(2)

func touch_pad(point: Vector2) -> void:
	var event = InputEventScreenTouch.new()
	event.index = 0
	event.position = point
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = InputEventScreenTouch.new()
	event.index = 0
	event.position = point
	event.pressed = false
	Input.parse_input_event(event)
	await frames(2)

func clipped_text(node: Node) -> Array:
	var result = []
	if node is UI.LearningText and node.is_visible_in_tree() and not node.fit_content and not node.content_fits():
		result.append(node.words)
	for child in node.get_children(): result.append_array(clipped_text(child))
	return result

func finish_perfect(field) -> void:
	for note in field.round_state.notes:
		if note.status != "waiting": continue
		field.advance_to(note.time)
		field.tap(note.lane)
	field.advance_to(Jam.DURATION)
	await frames()

func run() -> void:
	graphical = DisplayServer.get_name() != "headless"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_dir = arg.trim_prefix("--capture=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
	check(absf(preload("res://assets/audio/snack_jam.ogg").get_length()-Jam.DURATION)<0.01,"The bundled original song has the chart's exact 52.8-second duration")
	for mode in Jam.MODES:
		var round_state = Jam.new_round(mode)
		var expected = {"chill":40,"standard":80,"lively":120}[mode]
		check(round_state.notes.size()==expected,"Authored note count: " + mode)
		var previous = -1.0
		var valid = true
		for note in round_state.notes:
			valid = valid and note.time>previous and note.lane in [0,1,2] and note.time>=Jam.COUNT_IN and note.time<Jam.DURATION-1
			previous = note.time
			round_state.advance(note.time)
			valid = valid and round_state.hit(note.lane)=="perfect"
		check(valid,"Ordered beat-aligned notes can all be hit without chords: " + mode)
		round_state.advance(Jam.DURATION)
		check(round_state.completed and round_state.accuracy()==100 and round_state.best_combo==expected and round_state.missed==0,"A complete perfect performance scores correctly: " + mode)
		var snapshot = round_state.report()
		round_state.advance(Jam.DURATION+10)
		round_state.hit(0)
		check(round_state.report()==snapshot,"A completed round cannot be changed by extra callbacks: " + mode)
		var empty = Jam.new_round(mode)
		empty.advance(Jam.DURATION)
		check(empty.missed==expected and empty.accuracy()==0 and empty.completed,"An untouched chart ends gently with every note counted once: " + mode)
		var near = Jam.new_round(mode)
		near.advance(near.notes[0].time+Jam.SETTINGS[mode].window)
		check(near.hit(near.notes[0].lane)=="good","A tap at the outer timing boundary is accepted: " + mode)
		near.advance(near.notes[1].time+Jam.SETTINGS[mode].window+0.002)
		check(near.missed==1 and near.combo==0,"A late note misses once and resets the combo: " + mode)
	check(Jam.SETTINGS.chill.window>Jam.SETTINGS.standard.window and Jam.SETTINGS.standard.window>Jam.SETTINGS.lively.window,"Rhythm modes have progressively tighter timing")
	var spaced = Jam.new_round("chill")
	check(spaced.hit(0)=="warmup" and spaced.extra_taps==0,"Count-in practice taps do not punish the player")
	spaced.advance(Jam.COUNT_IN)
	check(spaced.hit(1)=="extra" and spaced.perfect==0,"The correct time with the wrong lane cannot catch a note")
	check(spaced.hit(0)=="perfect" and spaced.hit(0)=="extra" and spaced.perfect==1,"Each snack can be hit once; repeated taps reset the combo")
	check(spaced.accuracy()==1,"Extra taps reduce accuracy instead of improving a score")
	var at = spaced.clock
	spaced.advance(at-1)
	check(spaced.clock==at,"Audio clock jitter cannot rewind judged notes")
	check(Jam.prizes(0)=={"gold":20,"berries":0,"seeds":0} and Jam.prizes(69).berries==0 and Jam.prizes(70).berries==2 and Jam.prizes(89).seeds==0 and Jam.prizes(90).seeds==1 and Jam.prizes(100).gold==40,"Finish coins and 70%/90% treat thresholds are exact")
	root.size = Vector2i(1280,800)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(5)
	game.tutorial.finish()
	game.progress.save_path = "user://crittercare_jam_acceptance.json"
	game.progress.sound = false
	game.speech_queue.clear()
	game.speech.hide()
	game.open_games()
	check(is_instance_valid(game.game_menu_button("PlaySnackJam")) and is_instance_valid(game.game_menu_button("PlayPicnic")) and is_instance_valid(game.game_menu_button("PlayLogicLab")),"Snack Jam has a visible menu entrance beside both existing bonus activities")
	await snap("jam-games-menu")
	await frames(3)
	game.reveal_game("PlaySnackJam")
	await frames(3)
	await click(game.game_menu_button("PlaySnackJam").get_global_rect().get_center())
	check(game.modal_name=="snack_jam" and not game.progress.discovered.has("snack_jam"),"The button opens the rhythm game directly and saves teaching for after the song")
	var field = game.snack_jam
	field.manual_clock = true
	check(field.music.playback_type==AudioServer.PLAYBACK_TYPE_STREAM,"Music uses measured stream playback on native and Web")
	await frames()
	check(clipped_text(game.overlay).is_empty(),"The rhythm setup instructions and controls fit")
	await snap("jam-ready")
	for level in Lessons.LEVELS:
		game.progress.game_level = level
		field.choose_mode("lively")
		check(field.mode=="lively" and field.round_state.notes.size()==120,"Rhythm settings are independent of Game level: "+level)
	field.choose_mode("chill")
	field.adjust_timing(500)
	check(field.timing_offset_ms==200 and game.progress.jam_offset_ms==200,"Timing preference clamps and saves")
	field.adjust_timing(-200)
	await click(field.pads[0].get_global_rect().get_center())
	check(field.actor.dance_pose==1 and field.round_state.perfect==0,"Pads preview a dance before the song without earning points")
	await click(field.start_button.get_global_rect().get_center())
	check(field.started and field.ready_panel.visible==false and field.start_button.disabled,"Start begins the round once and removes its setup overlay")
	field.choose_mode("lively")
	check(field.mode=="chill","The chart cannot be changed during a song")
	field.advance_to(Jam.COUNT_IN)
	await key_press(KEY_A,true)
	check(field.round_state.perfect==0,"Holding a keyboard key does not automatically hit notes")
	await key_press(KEY_A)
	check(field.round_state.perfect==1 and field.round_state.combo==1,"A real A-key press catches the matching first snack")
	field.advance_to(field.round_state.notes[1].time)
	await click(field.pads[field.round_state.notes[1].lane].get_global_rect().get_center())
	check(field.round_state.perfect==2,"A real pointer press on a pad catches the next snack")
	field.advance_to(field.round_state.notes[2].time)
	await touch_pad(field.pads[field.round_state.notes[2].lane].get_global_rect().get_center())
	check(field.round_state.perfect==3,"A touch on a pad catches one snack without duplicate mouse input")
	await snap("jam-playing")
	# Manual chart timing does not start an audio stream. Start the real,
	# muted stream here so pause/resume also checks an active playback.
	field.music.play()
	await frames(2)
	await key_press(KEY_SPACE)
	var freeze = field.round_state.report()
	field.advance_to(Jam.DURATION)
	field.tap(1)
	field._process(5)
	check(field.paused and field.music.stream_paused and field.round_state.report()==freeze,"Pause freezes audio, chart, scoring, and miss judgement")
	await snap("jam-paused")
	await key_press(KEY_SPACE)
	check(not field.paused and field.resume_countdown>0 and field.music.stream_paused,"Resume waits for a three-beat lead-in before releasing the music")
	field._process(Jam.BEAT*3+0.01)
	check(field.resume_countdown==0 and not field.music.stream_paused and field.round_state.report()==freeze,"Resume preserves the exact note position without generating misses")
	field._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(field.paused,"Losing window focus automatically pauses the song")
	field.set_paused(false)
	field._process(Jam.BEAT*3+0.01)
	var money = game.progress.coins
	var berries = game.progress.inventory.berry
	var seeds = game.progress.inventory.seed
	var badges = game.progress.stage_badges.duplicate(true)
	var fake_report = field.round_state.report()
	game._finish_snack_jam(fake_report,field)
	check(game.progress.coins==money and game.modal_name=="snack_jam","An unfinished callback cannot pay rewards")
	await finish_perfect(field)
	check(game.modal_name=="jam_result" and game.progress.coins==money+40 and game.progress.inventory.berry==berries+2 and game.progress.inventory.seed==seeds+1,"Finishing a perfect song pays exactly 40 gold, two berries and one seed")
	check(game.progress.jam_rounds==1 and game.progress.jam_best.chill.accuracy==100 and game.progress.jam_best.chill.combo==40 and game.progress.stage_badges==badges,"Separate personal bests save without awarding curriculum badges")
	game._finish_snack_jam(fake_report,field)
	check(game.progress.coins==money+40 and game.progress.jam_rounds==1,"Duplicate completion cannot pay twice")
	check(game.progress.discovered.has("snack_jam") and game.progress.pip_quotes.snack_jam.contains("40 of 40") and game.overlay.find_child("JamPipQuote",true,false).words==game.progress.pip_quotes.snack_jam,"The complete post-song explanation and actual result are saved to Knowledge")
	check(clipped_text(game.overlay).is_empty(),"All result figures and reward text fit")
	await snap("jam-result")
	var reload = SaveData.new()
	reload.save_path = game.progress.save_path
	reload.load_progress()
	check(reload.jam_best==game.progress.jam_best and reload.jam_rounds==1 and reload.pip_quotes.snack_jam==game.progress.pip_quotes.snack_jam,"Song records and full dialogue survive save/reload")
	game.open_knowledge("snack_jam")
	check(game.overlay.get_node("JournalBody/Content/PipQuote").words==game.progress.pip_quotes.snack_jam,"Knowledge replays exactly what Pip said about the round")
	await snap("jam-knowledge")
	for selected in ["standard","lively"]:
		game.start_snack_jam()
		field = game.snack_jam
		field.manual_clock = true
		field.choose_mode(selected)
		field.start()
		for i in range(12):
			var note = field.round_state.notes[i]
			field.advance_to(note.time)
			field.tap(note.lane)
		await snap("jam-"+selected)
		await finish_perfect(field)
		check(game.progress.jam_best[selected].accuracy==100,"Full UI round completes and stores its own best: "+selected)
	game.start_snack_jam()
	field = game.snack_jam
	field.manual_clock = true
	field.choose_mode("chill")
	field.start()
	field.advance_to(Jam.COUNT_IN)
	field.tap(0)
	var before_restart = game.progress.coins
	field.restart()
	check(not field.started and field.round_state.perfect==0 and game.progress.coins==before_restart,"Restart discards an unfinished score and pays nothing")
	field.start()
	game.close_modal()
	check(not field.music.playing and field.stopped and game.progress.coins==before_restart,"Leaving a song stops all music and pays no unfinished reward")
	await frames()
	game.start_snack_jam()
	field = game.snack_jam
	field.manual_clock = true
	field.start()
	field.advance_to(Jam.DURATION)
	check(game.modal_name=="jam_result" and game.progress.coins==before_restart+20,"Missing every note still ends the song and gives only its finish reward")
	check(game.progress.jam_best.chill.accuracy==100,"A lower later score never overwrites a personal best")
	game.progress.calm = true
	game.progress.owned = ["leaf_hat","bow"]
	game.progress.equipped = {"pet:head":"leaf_hat","pet:neck":"bow"}
	game.start_snack_jam()
	field = game.snack_jam
	field.tap(2)
	check(field.gentle and field.twirl_time==0 and field.actor.calm,"Gentler movement suppresses twirls and large bouncing")
	check(field.actor.cosmetic_items=={"head":"leaf_hat","neck":"bow"} and field.actor.costumes.get_child_count()==2,"The dancing Pip wears the player's equipped accessories")
	root.size = Vector2i(960,600)
	await frames(3)
	check(clipped_text(game.overlay).is_empty(),"Rhythm text still fits in the minimum 960 by 600 window")
	await snap("jam-small-window")
	root.size = Vector2i(1280,800)
	await frames()
	# Exercise the actual audio clock for a whole song, with real key events.
	game.close_modal()
	game.progress.calm = false
	game.start_snack_jam()
	field = game.snack_jam
	field.choose_mode("chill")
	field.adjust_timing(-field.timing_offset_ms)
	field.start()
	var started_at = Time.get_ticks_msec()
	while is_instance_valid(field) and game.modal_name=="snack_jam" and Time.get_ticks_msec()-started_at<65000:
		for note in field.round_state.notes:
			if note.status=="waiting" and field.round_state.clock>=note.time:
				await key_press([KEY_A,KEY_S,KEY_D][note.lane])
		await process_frame
	check(game.modal_name=="jam_result","The actual music stream reaches results without a manual clock or forced completion")
	check(game.progress.jam_rounds==5,"A real audio-driven playthrough awards exactly one further completion")
	# Migration is additive; reset clears records but keeps rhythm preferences.
	var old_save = SaveData.new()
	old_save.save_path = "user://crittercare_jam_migration.json"
	var old_file = FileAccess.open(old_save.save_path,FileAccess.WRITE)
	old_file.store_string(JSON.stringify({"version":7,"coins":74,"lab_completed":["delivery"],"tutorial_completed":true}))
	old_file.close()
	old_save.load_progress()
	check(old_save.coins==74 and old_save.lab_completed==["delivery"] and old_save.jam_best.is_empty() and old_save.jam_mode=="chill","Version-7 saves gain default rhythm preferences without losing progress")
	game.progress.jam_mode = "lively"
	game.progress.jam_offset_ms = 40
	game._reset_progress()
	check(game.progress.jam_best.is_empty() and game.progress.jam_rounds==0 and game.progress.coins==0 and game.tutorial.active,"Reset clears rhythm records/rewards and restarts the tutorial")
	check(game.progress.jam_mode=="lively" and game.progress.jam_offset_ms==40,"Reset preserves selected rhythm and timing comfort settings")
	game.queue_free()
	await frames()
	print("JAM RESULT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
