extends Control
## Audio-clock rhythm game. The main coordinator owns permanent rewards.
signal finished(report: Dictionary)
signal preferences_changed(mode: String, offset_ms: int, sound_on: bool)

const Text = preload("res://data/game_text.gd")
var game_level: String = "kindergarten"
var lane_results: Array[Dictionary] = [{},{},{}]
var shown_misses: Dictionary = {}
const UI = preload("res://scripts/ui.gd")
const Rules = preload("res://data/snack_jam.gd")
const Hamster = preload("res://scripts/hamster.gd")
const SONG = preload("res://assets/audio/snack_jam.ogg")
const LANE_TEXTURES = [
	preload("res://assets/minigames/snack_jam/lane_0.png"),
	preload("res://assets/minigames/snack_jam/lane_1.png"),
	preload("res://assets/minigames/snack_jam/lane_2.png")
]
const NOTE_TEXTURES = [
	preload("res://assets/minigames/snack_jam/note_0.png"),
	preload("res://assets/minigames/snack_jam/note_1.png"),
	preload("res://assets/minigames/snack_jam/note_2.png")
]
const STAGE_BASE = preload("res://assets/minigames/snack_jam/stage_base.png")
const STAGE_GLOW = preload("res://assets/minigames/snack_jam/stage_glow.png")
const HIT_FEEDBACK_RING = preload("res://assets/minigames/snack_jam/hit_feedback_ring.png")
const BEAT_DOT = preload("res://assets/minigames/snack_jam/beat_dot.png")
const LANE_COLORS = [Color("b96684"),Color("aa8739"),Color("c77949")]
const LANE_X = [105.0,303.0,501.0]
const HIT_Y = 326.0
const TOP_Y = 68.0

var mode: String = "chill"
var timing_offset_ms: int = 0
var sound_on: bool = true
var gentle: bool = false
var cosmetics: Dictionary = {}
var best: Dictionary = {}
var round_state: Rules.Round
var music: AudioStreamPlayer
var started: bool = false
var paused: bool = false
var stopped: bool = false
var finished_once: bool = false
var resume_countdown: float = 0
var output_latency: float = 0
var manual_clock: bool = false # Accepted only with --test-mode.
var lane_flash: Array[float] = [0.0,0.0,0.0]
var dance_time: float = 0
var twirl_time: float = 0
var idle_clock: float = 0
var actor
var score_label: UI.LearningText
var combo_label: UI.LearningText
var time_label: UI.LearningText
var cue: UI.LearningText
var ready_panel: Panel
var mode_description: UI.LearningText
var personal_best: UI.LearningText
var offset_label: UI.LearningText
var helper_label: UI.LearningText
var pause_layer: Panel
var mode_buttons: Array[Button] = []
var pads: Array[Button] = []
var start_button: Button
var pause_button: Button
var music_button: Button
var progress_bar: ProgressBar
var lane_flash_overlays: Array[ColorRect] = []
var notes_layer: Control
var note_nodes: Array[TextureRect] = []
var feedback_panels: Array[Panel] = []
var feedback_labels: Array[UI.LearningText] = []
var feedback_rings: Array[TextureRect] = []
var stage_glow: TextureRect
var beat_dot: TextureRect

func _ready() -> void:
	name = "SnackJam"
	size = Vector2(974,518)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	mode = Rules.normalize_mode(mode)
	timing_offset_ms = clampi(timing_offset_ms,-200,200)
	round_state = Rules.new_round(mode)
	lane_results = [{},{},{}]
	shown_misses.clear()
	music = AudioStreamPlayer.new()
	music.name = "JamMusic"
	music.stream = SONG
	# Stream playback provides the same measured playback clock on native and
	# Web. Sample playback cannot supply the accurate clock this game needs.
	music.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	add_child(music)
	music.finished.connect(_music_finished)
	_build_art()
	_rebuild_note_nodes()
	score_label = UI.label(self,"0 / %d snacks" % round_state.notes.size(),Rect2(0,0,250,31),21)
	combo_label = UI.label(self,"Combo 0 · Best 0",Rect2(269,0,440,31),20,UI.GREEN)
	time_label = UI.label(self,"53 seconds",Rect2(792,0,182,31),18,UI.GREEN,true)
	UI.label(self,Rules.SONG,Rect2(630,64,330,36),25,UI.INK,true)
	UI.label(self,"An original little tune · 100 BPM",Rect2(630,103,330,25),15,UI.MUTED,true)
	actor = Hamster.new()
	actor.blocked = true
	actor.stage_actor = true
	actor.calm = gentle
	actor.cosmetic_items = cosmetics
	actor.position = Vector2(794,259)
	actor.scale = Vector2.ONE*0.68
	add_child(actor)
	cue = UI.label(self,"Let's make music!",Rect2(631,351,330,46),28,UI.GREEN,true)
	for i in range(3):
		var lane = i
		var pad = UI.button(self,["A   Berry","S   Seed","D   Carrot"][i],Rect2(15+i*198,348,180,51),func(): pass)
		pad.name = "JamPad%d" % i
		pad.accessibility_name = ["Berry lane, A","Seed lane, S","Carrot lane, D"][i]
		pad.add_theme_stylebox_override("normal",UI.style(Color("fffaf0"),14,LANE_COLORS[i]))
		pad.add_theme_stylebox_override("pressed",UI.style(LANE_COLORS[i].lightened(0.63),14,LANE_COLORS[i]))
		pad.button_down.connect(func(): tap(lane))
		pads.append(pad)
	ready_panel = UI.panel(self,Rect2(14,62,578,274),Color("f8f5e8"),18)
	ready_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	UI.label(ready_panel,"Choose your groove",Rect2(16,10,548,34),25,UI.INK,true)
	for i in range(3):
		var selected: String = Rules.MODES[i]
		var b = UI.button(ready_panel,Rules.SETTINGS[selected].name,Rect2(17+i*185,55,176,42),func(): choose_mode(selected))
		b.name = "JamMode_" + selected
		mode_buttons.append(b)
	mode_description = UI.label(ready_panel,"",Rect2(16,105,546,30),17,UI.GREEN,true)
	personal_best = UI.label(ready_panel,"",Rect2(16,136,546,28),16,UI.MUTED,true)
	UI.label(ready_panel,Text.line("jam_controls",game_level),Rect2(20,166,539,58),18,UI.INK,true)
	UI.button(ready_panel,"−",Rect2(18,234,40,30),func(): adjust_timing(-20)).name = "JamTimingMinus"
	offset_label = UI.label(ready_panel,"",Rect2(62,232,194,34),15,UI.GREEN,true)
	UI.button(ready_panel,"+",Rect2(259,234,40,30),func(): adjust_timing(20)).name = "JamTimingPlus"
	UI.label(ready_panel,"Notes behind music? +\nNotes ahead? −",Rect2(320,225,240,44),13,UI.MUTED)
	helper_label = UI.label(self,Text.line("jam_ready",game_level),Rect2(3,416,968,45),17,UI.GREEN,true)
	pause_button = UI.button(self,"Pause",Rect2(0,474,120,42),func(): set_paused(not paused))
	pause_button.name = "JamPause"
	pause_button.disabled = true
	music_button = UI.button(self,"",Rect2(130,474,144,42),toggle_music)
	music_button.name = "JamSound"
	UI.button(self,"Restart",Rect2(284,474,126,42),restart).name = "JamRestart"
	UI.label(self,"A / S / D · Space pauses",Rect2(425,478,335,34),16,UI.MUTED,true)
	start_button = UI.button(self,"Start song  ▶",Rect2(779,472,195,45),start,true)
	start_button.name = "JamStart"
	pause_layer = UI.panel(self,Rect2(0,46,974,363),Color(0.96,0.95,0.91,0.95),20)
	pause_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	UI.label(pause_layer,"A little breather",Rect2(90,86,794,55),36,UI.INK,true)
	UI.label(pause_layer,Text.line("jam_pause",game_level),Rect2(120,153,734,98),23,UI.GREEN,true)
	pause_layer.hide()
	_refresh_preferences()
	_refresh_score()

func _refresh_preferences() -> void:
	for i in range(mode_buttons.size()):
		var selected = Rules.MODES[i] == mode
		mode_buttons[i].add_theme_stylebox_override("normal",UI.style(Color("d6e8cc") if selected else UI.CREAM,14,UI.GREEN if selected else Color("d8ded0")))
	mode_description.words = ({"chill":"40 snacks. Slow and roomy!","standard":"80 snacks. A steady beat!","lively":"120 snacks. Extra little beats!"}[mode]) if game_level == "kindergarten" else Rules.SETTINGS[mode].description
	var record: Dictionary = best.get(mode,{})
	personal_best.words = ("Your best: %d%% · best row %d" if game_level == "kindergarten" else "Personal best: %d%% · longest combo %d") % [int(record.get("accuracy",0)),int(record.get("combo",0))]
	offset_label.words = "Timing: %+d ms" % timing_offset_ms
	music_button.text = "Music: on" if sound_on else "Music: off"
	music.volume_db = -5.0 if sound_on else -80.0
	preferences_changed.emit(mode,timing_offset_ms,sound_on)

func choose_mode(selected: String) -> void:
	if started or not selected in Rules.MODES: return
	mode = selected
	round_state = Rules.new_round(mode)
	lane_results = [{},{},{}]
	shown_misses.clear()
	_refresh_preferences()
	_refresh_score()
	_sync_art()

func adjust_timing(amount: int) -> void:
	if started: return
	timing_offset_ms = clampi(timing_offset_ms+amount,-200,200)
	_refresh_preferences()

func toggle_music() -> void:
	sound_on = not sound_on
	_refresh_preferences()

func start() -> void:
	if started or stopped: return
	round_state = Rules.new_round(mode)
	lane_results = [{},{},{}]
	shown_misses.clear()
	started = true
	paused = false
	finished_once = false
	resume_countdown = 0
	output_latency = AudioServer.get_output_latency()
	ready_panel.hide()
	start_button.disabled = true
	start_button.text = "Have fun, Pip!"
	pause_button.disabled = false
	pause_button.text = "Pause"
	helper_label.words = Text.line("jam_playing",game_level)
	music.stream_paused = false
	if not (manual_clock and "--test-mode" in OS.get_cmdline_user_args()):
		music.play()
	_refresh_score()

func restart() -> void:
	if stopped: return
	music.stop()
	music.stream_paused = false
	started = false
	paused = false
	finished_once = false
	resume_countdown = 0
	actor.dance_pose = 0
	dance_time = 0
	twirl_time = 0
	actor.scale = Vector2.ONE*0.68
	ready_panel.show()
	pause_layer.hide()
	start_button.disabled = false
	start_button.text = "Start song  ▶"
	pause_button.disabled = true
	pause_button.text = "Pause"
	round_state = Rules.new_round(mode)
	lane_results = [{},{},{}]
	shown_misses.clear()
	cue.words = "A fresh little groove"
	UI.clear_outcome(cue)
	helper_label.words = Text.line("jam_restart",game_level)
	_refresh_score()
	_sync_art()

func set_paused(value: bool) -> void:
	if not started or stopped or finished_once or paused == value: return
	paused = value
	UI.clear_outcome(cue)
	resume_countdown = 0 if value else Rules.BEAT*3
	# Resume the stream after the lead-in, with its original playback position.
	music.stream_paused = true
	pause_layer.visible = value
	pause_button.text = "Resume" if value else "Pause"
	if value: pause_button.grab_focus()
	_sync_art()

func stop() -> void:
	stopped = true
	started = false
	if is_instance_valid(music): music.stop()
	set_process(false)
	set_process_input(false)

func _exit_tree() -> void:
	stop()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and started:
		set_paused(true)

func _input(event: InputEvent) -> void:
	if stopped or not visible or not event is InputEventKey: return
	var key = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	if key == KEY_SPACE and started:
		if event.pressed and not event.echo: set_paused(not paused)
		# Consume the release too: the focused Resume button must not also
		# activate from this same Space press when keyboard focus moves to it.
		get_viewport().set_input_as_handled()
	elif key in [KEY_A,KEY_S,KEY_D]:
		if event.pressed and not event.echo: tap([KEY_A,KEY_S,KEY_D].find(key))
		get_viewport().set_input_as_handled()

func _song_time() -> float:
	# Audio time is authoritative: variable frame rates cannot drift the chart.
	return maxf(0,music.get_playback_position()+AudioServer.get_time_since_last_mix()-output_latency+timing_offset_ms/1000.0)

func tap(lane: int) -> void:
	if lane < 0 or lane > 2 or stopped or paused or resume_countdown > 0 or finished_once: return
	lane_flash[lane] = 0.24
	if not started:
		actor.dance_pose = lane+1
		dance_time = 0.8
		cue.words = ["Clap with me!","A little bounce!","A tiny twirl!"][lane]
		if lane == 2 and not gentle: twirl_time = 0.65
		return
	if not (manual_clock and "--test-mode" in OS.get_cmdline_user_args()):
		advance_to(_song_time())
		if finished_once: return
	var rating = round_state.hit(lane)
	if rating in ["perfect","good"]:
		cue.words = "✓ PERFECT!" if rating == "perfect" else "✓ NICE!"
		UI.outcome_label(cue,true)
		lane_results[lane] = {"correct":true,"words":"✓ HIT!","life":0.9}
		actor.dance_pose = 1+(round_state.combo/4)%3
		dance_time = 0.8
		actor.happy_time = 0.9
		if round_state.combo > 0 and round_state.combo%8 == 0 and not gentle:
			twirl_time = 0.65
			helper_label.words = "%d in a row! Pip loves your groove." % round_state.combo
	elif rating == "extra":
		cue.words = "✕ EXTRA TAP!"
		UI.outcome_label(cue,false)
		lane_results[lane] = {"correct":false,"words":"✕ EXTRA!","life":0.9}
		helper_label.words = Text.line("jam_extra",game_level)
	elif rating == "warmup":
		cue.words = "Feel the beat"
		UI.clear_outcome(cue)
	_refresh_score()
	_sync_art()

func advance_to(seconds: float) -> void:
	if not started or paused or resume_countdown > 0 or stopped or finished_once: return
	if round_state.advance(seconds)>0:
		cue.words = "✕ MISSED!"
		UI.outcome_label(cue,false)
		for i in range(round_state.notes.size()):
			var note: Dictionary = round_state.notes[i]
			if note.status == "missed" and not shown_misses.has(i):
				shown_misses[i] = true
				lane_results[note.lane] = {"correct":false,"words":"✕ MISSED!","life":0.9}
		helper_label.words = Text.line("jam_miss",game_level)
	_refresh_score()
	if round_state.completed:
		finished_once = true
		music.stop()
		finished.emit(round_state.report())

func _music_finished() -> void:
	if started and not paused and not stopped:
		advance_to(Rules.DURATION)

func _refresh_score() -> void:
	score_label.words = "%d / %d snacks" % [round_state.perfect+round_state.good,round_state.notes.size()]
	combo_label.words = ("In a row: %d · Best: %d" if game_level == "kindergarten" else "Combo %d · Best %d") % [round_state.combo,round_state.best_combo]
	time_label.words = "%ds left" % ceili(Rules.DURATION-round_state.clock) if started else "53 seconds"
	_sync_art()

func _process(delta: float) -> void:
	if paused or stopped: return
	idle_clock += delta
	if resume_countdown>0:
		resume_countdown = maxf(0,resume_countdown-delta)
		cue.words = "Ready… %d" % maxi(1,ceili(resume_countdown/Rules.BEAT))
		if resume_countdown == 0:
			music.stream_paused = false
			cue.words = "Back to the beat!"
	elif started and not (manual_clock and "--test-mode" in OS.get_cmdline_user_args()):
		advance_to(_song_time())
		if stopped or finished_once: return
	if started and round_state.clock < Rules.COUNT_IN and resume_countdown == 0:
		cue.words = "Get ready… %d" % maxi(1,ceili((Rules.COUNT_IN-round_state.clock)/Rules.BEAT))
	for i in range(3):
		lane_flash[i] = maxf(0,lane_flash[i]-delta)
		if not lane_results[i].is_empty():
			lane_results[i].life -= delta
			if lane_results[i].life <= 0: lane_results[i] = {}
	dance_time = maxf(0,dance_time-delta)
	twirl_time = maxf(0,twirl_time-delta)
	var beat_phase = (round_state.clock if started else idle_clock)/Rules.BEAT
	actor.clock += delta
	actor.dance_phase = beat_phase
	actor.happy_time = maxf(0,actor.happy_time-delta)
	actor.dance_pose = actor.dance_pose if dance_time>0 else 0
	actor.position.y = 259-(absf(sin(beat_phase*PI))*8 if started and not gentle else 0)
	actor.angle = sin(beat_phase*PI)*0.055 if started and not gentle else 0.0
	actor.scale.x = 0.68*(cos((1-twirl_time/0.65)*TAU) if twirl_time>0 and not gentle else 1.0)
	actor._update_costume_pose()
	actor.queue_redraw()
	_sync_art()

func _art_texture(node_name: String, image: Texture2D, rect: Rect2, _layer: int) -> TextureRect:
	var node = TextureRect.new()
	node.name = node_name
	node.texture = image
	node.position = rect.position
	node.size = rect.size
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_SCALE
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.z_index = 0
	add_child(node)
	return node

func _build_art() -> void:
	progress_bar = ProgressBar.new()
	progress_bar.name = "JamProgress"
	progress_bar.position = Vector2(0,38)
	progress_bar.size = Vector2(974,5)
	progress_bar.min_value = 0
	progress_bar.max_value = Rules.DURATION
	progress_bar.show_percentage = false
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.add_theme_stylebox_override("background",UI.style(Color("e7e4d9"),3))
	progress_bar.add_theme_stylebox_override("fill",UI.style(UI.GREEN,3))
	add_child(progress_bar)

	var lane_shell = UI.panel(self,Rect2(0,49,606,357),Color("ede9dc"),20)
	lane_shell.name = "JamLaneShell"
	for i in range(3):
		_art_texture("JamLane%d" % i,LANE_TEXTURES[i],Rect2(11+i*198,59,188,340),-19)
		var flash = ColorRect.new()
		flash.name = "JamLaneFlash%d" % i
		flash.position = Vector2(11+i*198,59)
		flash.size = Vector2(188,340)
		flash.color = Color.TRANSPARENT
		flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(flash)
		lane_flash_overlays.append(flash)

	notes_layer = Control.new()
	notes_layer.name = "JamNotes"
	notes_layer.position = Vector2.ZERO
	notes_layer.size = size
	notes_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(notes_layer)

	for i in range(3):
		var feedback_panel = UI.panel(self,Rect2(22+i*198,65,166,37),UI.FEEDBACK_BG,9)
		feedback_panel.name = "JamLaneFeedback%d" % i
		feedback_panel.hide()
		var feedback_label = UI.label(feedback_panel,"",Rect2(6,0,154,37),24,UI.CORRECT,true)
		feedback_labels.append(feedback_label)
		feedback_panels.append(feedback_panel)
		var ring = _art_texture("JamHitFeedback%d" % i,HIT_FEEDBACK_RING,Rect2(LANE_X[i]-32,HIT_Y-32,64,64),-16)
		ring.hide()
		feedback_rings.append(ring)

	_art_texture("JamStage",STAGE_BASE,Rect2(621,49,353,357),-20)
	stage_glow = _art_texture("JamStageGlow",STAGE_GLOW,Rect2(621,49,353,357),-19)
	stage_glow.modulate.a = 0.0
	beat_dot = _art_texture("JamBeatDot",BEAT_DOT,Rect2(785,329,20,20),-18)
	beat_dot.pivot_offset = Vector2(10,10)

func _rebuild_note_nodes() -> void:
	if not is_instance_valid(notes_layer) or round_state == null:
		return
	for node in note_nodes:
		if is_instance_valid(node):
			node.hide()
			node.queue_free()
	note_nodes.clear()
	for i in range(round_state.notes.size()):
		var note: Dictionary = round_state.notes[i]
		var lane: int = int(note.lane)
		var node = TextureRect.new()
		node.name = "JamNote%03d" % i
		node.texture = NOTE_TEXTURES[lane]
		node.size = Vector2(74,42)
		node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		node.stretch_mode = TextureRect.STRETCH_SCALE
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.hide()
		notes_layer.add_child(node)
		note_nodes.append(node)

func _sync_art() -> void:
	if round_state == null or not is_instance_valid(progress_bar):
		return
	progress_bar.value = clampf(round_state.clock,0.0,Rules.DURATION)
	if note_nodes.size() != round_state.notes.size():
		_rebuild_note_nodes()
	for i in range(3):
		var flash_color: Color = LANE_COLORS[i]
		flash_color.a = clampf(lane_flash[i]/0.24*0.18,0.0,0.18)
		lane_flash_overlays[i].color = flash_color
		if lane_results[i].is_empty():
			feedback_panels[i].hide()
			feedback_rings[i].hide()
		else:
			var result_color: Color = UI.CORRECT if lane_results[i].correct else UI.INCORRECT
			feedback_panels[i].add_theme_stylebox_override("panel",UI.style(UI.FEEDBACK_BG,9,result_color))
			feedback_labels[i].words = lane_results[i].words
			feedback_labels[i].add_theme_color_override("default_color",result_color)
			feedback_labels[i].add_theme_font_override("normal_font",UI.HEADING_FONT)
			feedback_panels[i].show()
			feedback_rings[i].modulate = result_color
			feedback_rings[i].show()

	var approach: float = Rules.SETTINGS[mode].approach
	for i in range(note_nodes.size()):
		var node = note_nodes[i]
		var note: Dictionary = round_state.notes[i]
		node.hide()
		if not started or note.status != "waiting":
			continue
		var ahead: float = note.time-round_state.clock
		if ahead <= approach and ahead >= -Rules.SETTINGS[mode].window:
			var y: float = HIT_Y-(HIT_Y-TOP_Y)*ahead/approach
			node.position = Vector2(LANE_X[int(note.lane)]-37,y-21)
			node.show()

	var glow := minf(round_state.combo/24.0,1.0)
	stage_glow.modulate.a = glow*0.65
	var pulse_time: float = Rules.BEAT*3-resume_countdown if resume_countdown>0 else (round_state.clock if started else idle_clock)
	var pulse: float = (cos(pulse_time/Rules.BEAT*TAU)+1)/2 if not gentle else 0.5
	beat_dot.scale = Vector2.ONE*(0.65+pulse*0.35)
