extends RefCounted
## All learners begin at stage 0. Stage badges are shared across level changes.
const MODES = ["Berry Detective", "Loop Garden", "Pop Quiz"]
const STAGES = [
	{"name":"First steps", "summary":"IF / ELSE, true or false, AND, and simple repeats.", "keys":[]},
	{"name":"More ways to decide", "summary":"OR, NOT, number comparisons, and changing a step size.", "keys":["or", "not", "comparison", "step_size"]},
	{"name":"Little recipes", "summary":"ELIF choices, function inputs, and a running total.", "keys":["elif", "parameters", "accumulator"]},
	{"name":"Code explorer", "summary":"Grouped checks, lists, nested loops, and safe limits.", "keys":["grouping", "lists", "nested", "limits"]}
]

static func max_stage(level: String) -> int:
	return 3 if level == "college" else (2 if level == "middle" else 0)

static func completed(badges: Dictionary, stage: int) -> bool:
	var wins: Array = badges.get(str(stage), [])
	return MODES.all(func(mode): return wins.has(mode))

static func unlocked(badges: Dictionary, level: String) -> int:
	var stage = 0
	while stage < max_stage(level) and completed(badges, stage):
		stage += 1
	return stage

static func sort_rule(stage: int, index: int) -> Dictionary:
	match stage:
		1:
			return {"id":"or", "code":"is_berry or is_red", "words":"OR needs at least one yes. IF it is a berry OR it is red THEN basket; ELSE leave it."} if index < 5 else {"id":"not", "code":"is_berry and not is_red", "words":"NOT flips yes and no. IF it is a berry AND it is NOT red THEN basket; ELSE leave it."}
		2:
			return {"id":"elif", "code":"if is_red_berry: snack()\nelif is_berry: save_it()\nelse: leave_it()", "words":"ELIF means otherwise, check this. Red berry: snack. Other berry: save. Anything else: leave. Only the first matching choice runs."}
		3:
			return {"id":"grouping", "code":"(is_berry or is_seed)\n        and not is_spoiled", "words":"Check the group first: berry OR seed. Then check NOT spoiled. Both parts need a yes to go in the basket."} if index < 5 else {"id":"limits", "code":"is_berry and not is_spoiled\n        and fullness < 95", "words":"IF it is a fresh berry AND fullness is less than 95 THEN basket; ELSE leave. The < sign means less than."}
		_:
			return {"id":"and", "code":"is_berry and is_red", "words":"AND needs both yes answers. IF it is a berry AND it is red THEN basket; ELSE leave it."} if index >= 5 else {"id":"idle", "code":"is_berry", "words":"IF it is a berry THEN basket. ELSE means otherwise: leave it. True means yes; false means no."}

static func sort_answer(stage: int, index: int, kind: String) -> int:
	var berry = kind in ["berry", "blueberry", "spoiled_berry"]
	var red = kind in ["berry", "button"]
	var spoiled = kind == "spoiled_berry"
	var passes = false
	match stage:
		1: passes = (berry or red) if index < 5 else (berry and not red)
		2: return 0 if kind == "berry" else (1 if berry else 2)
		3: passes = ((berry or kind == "seed") and not spoiled) if index < 5 else (berry and not spoiled and fullness_for(index) < 95)
		_: passes = berry if index < 5 else (berry and red)
	return 0 if passes else 1

static func fullness_for(index: int) -> int:
	return 60 if index % 2 == 0 else 95
