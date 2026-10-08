extends RefCounted
## Berry Bounce: one authored song, three charts. No gameplay randomness.
const SONG = "Berry Bounce"
const BPM = 100.0
const BEAT = 60.0 / BPM
const COUNT_IN = 4.0 * BEAT
const BEATS = 80
const DURATION = 88.0 * BEAT # Four count-in beats, 80 playing beats, four outro beats.
const MODES = ["chill", "standard", "lively"]
const SETTINGS = {
	"chill":{"name":"Chill", "perfect":0.12, "window":0.24, "approach":3.0, "description":"40 snacks · spacious patterns · generous timing"},
	"standard":{"name":"Standard", "perfect":0.08, "window":0.16, "approach":2.4, "description":"80 snacks · one on each beat · a steady groove"},
	"lively":{"name":"Lively", "perfect":0.055, "window":0.11, "approach":1.9, "description":"120 snacks · extra offbeats · a quicker challenge"}
}
const LANES = [0,1,2,1,0,2,1,2,0,1,0,2,1,2,0,1]

static func normalize_mode(value: String) -> String:
	return value if value in MODES else "chill"

static func chart(mode: String) -> Array:
	mode = normalize_mode(mode)
	var notes: Array = []
	for beat in range(BEATS):
		var lane: int = LANES[beat % LANES.size()]
		if mode != "chill" or beat % 2 == 0:
			notes.append({"time":COUNT_IN+beat*BEAT, "lane":lane, "status":"waiting"})
		if mode == "lively" and beat % 2 == 1:
			notes.append({"time":COUNT_IN+(beat+0.5)*BEAT, "lane":(lane+1)%3, "status":"waiting"})
	return notes

static func prizes(accuracy: int) -> Dictionary:
	accuracy = clampi(accuracy,0,100)
	return {"gold":20+2*floori(accuracy/10.0), "berries":2 if accuracy>=70 else 0, "seeds":1 if accuracy>=90 else 0}

static func new_round(selected: String = "chill") -> Round:
	var result = Round.new()
	result.mode = normalize_mode(selected)
	result.notes = chart(result.mode)
	return result

class Round extends RefCounted:
	var mode: String
	var notes: Array
	var clock: float = 0
	var perfect: int = 0
	var good: int = 0
	var missed: int = 0
	var extra_taps: int = 0
	var combo: int = 0
	var best_combo: int = 0
	var completed: bool = false

	func advance(to_time: float) -> int:
		if completed: return 0
		clock = maxf(clock,clampf(to_time,0,DURATION))
		var new_misses = 0
		for note in notes:
			if note.status == "waiting" and clock > note.time + SETTINGS[mode].window + 0.000001:
				note.status = "missed"
				missed += 1
				new_misses += 1
				combo = 0
		if clock >= DURATION:
			completed = true
		return new_misses

	func hit(lane: int) -> String:
		if completed or lane < 0 or lane > 2: return "ignored"
		var nearest: Dictionary = {}
		var error = INF
		for note in notes:
			if note.status == "waiting" and note.lane == lane and absf(note.time-clock) < error:
				nearest = note
				error = absf(note.time-clock)
		if not nearest.is_empty() and error <= SETTINGS[mode].window + 0.000001:
			var rating = "perfect" if error <= SETTINGS[mode].perfect + 0.000001 else "good"
			nearest.status = rating
			perfect += 1 if rating == "perfect" else 0
			good += 1 if rating == "good" else 0
			combo += 1
			best_combo = maxi(best_combo,combo)
			return rating
		# Count-in/outro are safe to practice in. During the chart, extra taps
		# reset the combo and cost accuracy so holding/mashing cannot win.
		if clock < notes[0].time-SETTINGS[mode].window or clock > notes.back().time+SETTINGS[mode].window:
			return "warmup"
		extra_taps += 1
		combo = 0
		return "extra"

	func accuracy() -> int:
		return clampi(roundi(float(perfect*100 + good*70 - extra_taps*25)/notes.size()),0,100)

	func report() -> Dictionary:
		return {"mode":mode, "accuracy":accuracy(), "perfect":perfect, "good":good, "missed":missed, "extra_taps":extra_taps, "best_combo":best_combo, "notes":notes.size(), "completed":completed}
