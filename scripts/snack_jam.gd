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
	queue_redraw()

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
	queue_redraw()

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
	queue_redraw()

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
	queue_redraw()

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
	queue_redraw()

func _star(center: Vector2, radius: float, color: Color) -> void:
	var points = PackedVector2Array()
	for i in range(10):
		points.append(center+Vector2.from_angle(-PI/2+i*PI/5)*radius*(1 if i%2==0 else 0.46))
	draw_colored_polygon(points,color)

func _note(lane: int, y: float) -> void:
	var x: float = LANE_X[lane]
	draw_style_box(UI.style(UI.CREAM,12,LANE_COLORS[lane]),Rect2(x-37,y-21,74,42))
	var c: Color = LANE_COLORS[lane]
	if lane == 0:
		draw_circle(Vector2(x-18,y+3),9,c)
		draw_circle(Vector2(x-22,y-3),6,c)
		draw_circle(Vector2(x-13,y-3),6,c)
		draw_line(Vector2(x-18,y-7),Vector2(x-12,y-13),UI.GREEN,3,true)
	elif lane == 1:
		draw_colored_polygon(PackedVector2Array([Vector2(x-19,y-13),Vector2(x-10,y),Vector2(x-18,y+13),Vector2(x-27,y)]),c)
		draw_line(Vector2(x-18,y-8),Vector2(x-18,y+8),UI.CREAM,2,true)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(x-27,y-7),Vector2(x-9,y-7),Vector2(x-22,y+14)]),c)
		draw_line(Vector2(x-18,y-8),Vector2(x-16,y-15),UI.GREEN,3,true)
	draw_string(UI.HEADING_FONT,Vector2(x+4,y+7),["A","S","D"][lane],HORIZONTAL_ALIGNMENT_LEFT,-1,20,UI.INK)

func _draw() -> void:
	if round_state == null: return
	draw_style_box(UI.style(Color("e7e4d9"),3),Rect2(0,38,974,5))
	if round_state.clock>0:
		draw_style_box(UI.style(UI.GREEN,3),Rect2(0,38,974*round_state.clock/Rules.DURATION,5))
	draw_style_box(UI.style(Color("ede9dc"),20),Rect2(0,49,606,357))
	for i in range(3):
		draw_style_box(UI.style(Color("f7f4e9").lerp(LANE_COLORS[i],lane_flash[i]*0.75),16),Rect2(11+i*198,59,188,340))
		draw_line(Vector2(LANE_X[i],71),Vector2(LANE_X[i],337),Color("e0dbc9"),2,true)
		draw_circle(Vector2(LANE_X[i],HIT_Y),28,LANE_COLORS[i].lightened(0.77))
		draw_arc(Vector2(LANE_X[i],HIT_Y),28,0,TAU,40,LANE_COLORS[i],3,true)
	if started:
		var approach: float = Rules.SETTINGS[mode].approach
		for note in round_state.notes:
			if note.status != "waiting": continue
			var ahead: float = note.time-round_state.clock
			if ahead <= approach and ahead >= -Rules.SETTINGS[mode].window:
				_note(note.lane,HIT_Y-(HIT_Y-TOP_Y)*ahead/approach)
	for i in range(3):
		if not lane_results[i].is_empty():
			var color = UI.CORRECT if lane_results[i].correct else UI.INCORRECT
			draw_style_box(UI.style(UI.FEEDBACK_BG,9,color),Rect2(22+i*198,65,166,37))
			draw_string(UI.HEADING_FONT,Vector2(28+i*198,92),lane_results[i].words,HORIZONTAL_ALIGNMENT_CENTER,154,24,color)
			draw_arc(Vector2(LANE_X[i],HIT_Y),30,0,TAU,40,color,4,true)
	var glow = minf(round_state.combo/24.0,1.0)
	draw_style_box(UI.style(Color("eae4ef").lerp(Color("f6e7bc"),glow*0.65),20),Rect2(621,49,353,357))
	# Soft stage decorations, with no full-screen flashes or camera shaking.
	for x in [659,936]:
		draw_colored_polygon(PackedVector2Array([Vector2(x,135),Vector2(x-28,313),Vector2(x+28,313)]),Color(1,0.95,0.76,0.25+glow*0.15))
	for i in range(5):
		_star(Vector2(675+i*60,153+(i%2)*10),7+glow*2,Color("c5b69e").lerp(Color("bc9443"),glow))
	draw_style_box(UI.style(Color("c5b59b"),8),Rect2(638,323,319,15))
	draw_ellipse_shadow()
	for x in [640,923]:
		draw_style_box(UI.style(Color("777d78"),7),Rect2(x,268,33,54))
		draw_circle(Vector2(x+16,283),8,Color("515e55"))
		draw_circle(Vector2(x+16,305),11,Color("515e55"))
	var pulse_time = Rules.BEAT*3-resume_countdown if resume_countdown>0 else (round_state.clock if started else idle_clock)
	var pulse = (cos(pulse_time/Rules.BEAT*TAU)+1)/2 if not gentle else 0.5
	draw_circle(Vector2(795,339),4+pulse*2,UI.GREEN)

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(794,318),0,Vector2(1,0.13))
	draw_circle(Vector2.ZERO,57,Color(0.28,0.28,0.22,0.13))
	draw_set_transform(Vector2.ZERO)
