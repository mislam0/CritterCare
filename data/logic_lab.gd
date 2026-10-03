extends RefCounted
## Authored Logic Lab content and a bounded, deterministic instruction runner.
## Blocks are known IDs, never executable player-supplied GDScript.

const MAX_BLOCKS = 5
const BLOCKS = {
	"right":{"title":"Step right", "icon":"paw", "kind":"action"},
	"feed":{"title":"Offer one berry", "icon":"berry", "kind":"action"},
	"pet":{"title":"Pet Pip", "icon":"heart", "kind":"action"},
	"repeat2":{"title":"REPEAT 2 times: step right", "icon":"paw", "kind":"repeat"},
	"repeat3":{"title":"REPEAT 3 times: step right", "icon":"paw", "kind":"repeat"},
	"hungry":{"title":"IF hungry: offer berry\nELSE: pet Pip", "icon":"berry", "kind":"check"},
	"swapped":{"title":"IF hungry: pet Pip\nELSE: offer berry", "icon":"heart", "kind":"check"},
	"both":{"title":"IF hungry AND berry: feed\nELSE: pet Pip", "icon":"berry", "kind":"check"},
	"either":{"title":"IF hungry OR berry: feed\nELSE: pet Pip", "icon":"berry", "kind":"check"},
	"add1":{"title":"Add 1 seed to the jar", "icon":"seed", "kind":"action"},
	"add2":{"title":"Add 2 seeds to the jar", "icon":"seed", "kind":"action"},
	"add3":{"title":"Add 3 seeds to the jar", "icon":"seed", "kind":"action"},
	"repeat_add":{"title":"REPEAT 3 times: add 2", "icon":"seed", "kind":"repeat"},
	"define":{"title":"DEFINE cozy: berry, then pet", "icon":"book", "kind":"recipe"},
	"call":{"title":"CALL cozy", "icon":"book", "kind":"recipe"},
	"pack1":{"title":"CALL pack(1): add 1 seed", "icon":"seed", "kind":"recipe"},
	"pack2":{"title":"CALL pack(2): add 2 seeds", "icon":"seed", "kind":"recipe"},
	"pack3":{"title":"CALL pack(3): add 3 seeds", "icon":"seed", "kind":"recipe"},
	"each":{"title":"FOR EACH in [1, 3, 2]\nadd that many seeds", "icon":"seed", "kind":"repeat"},
	"nested22":{"title":"REPEAT 2 groups:\nREPEAT 2 times: add 1", "icon":"seed", "kind":"repeat"},
	"nested23":{"title":"REPEAT 2 groups:\nREPEAT 3 times: add 1", "icon":"seed", "kind":"repeat"},
	"nested33":{"title":"REPEAT 3 groups:\nREPEAT 3 times: add 1", "icon":"seed", "kind":"repeat"}
}

const CHALLENGES = [
	{"id":"delivery", "stage":0, "title":"A snack for Pip", "lesson":"lab_sequence",
	 "goal":"Move Pip to the berry on tile 1, then offer it to him.", "bowl":1,
	 "palette":["right","feed","pet"], "cases":[{"fullness":30}],
	 "hints":["Pip begins on tile 0. His berry is on the next tile.", "The instructions run from top to bottom. Move first, then offer the berry."]},
	{"id":"repeats", "stage":0, "title":"Three tiny steps", "lesson":"lab_repeat",
	 "goal":"Reach the berry on tile 3, then offer it. Try a REPEAT block!", "bowl":3,
	 "palette":["right","repeat2","repeat3","feed"], "cases":[{"fullness":30}],
	 "hints":["The berry is three little steps away.", "REPEAT 3 takes all three steps. Put Offer one berry after it."]},
	{"id":"choice", "stage":0, "title":"Hungry or happy?", "lesson":"lab_branch",
	 "goal":"Hungry Pip needs a berry. Otherwise, pet him. Make one program work for both visits.", "bowl":1,
	 "palette":["hungry","swapped","feed","pet"], "cases":[{"position":1,"fullness":30},{"position":1,"fullness":80}],
	 "hints":["Hungry means fullness is below 60. Our two visits begin at 30 and 80.", "IF hungry: offer berry. ELSE: pet Pip. One check can choose the right action for each visit."]},
	{"id":"both_checks", "stage":1, "title":"Two little checks", "lesson":"lab_checks",
	 "goal":"Feed only IF Pip is hungry AND a berry is available. Otherwise, pet him. Test all 3 visits.", "bowl":1,
	 "palette":["hungry","both","either","pet"], "cases":[{"position":1,"fullness":30},{"position":1,"fullness":30,"has_food":false},{"position":1,"fullness":80}],
	 "hints":["Hungry Pip cannot eat a berry that is not there. Check both things.", "AND needs two yes answers. OR accepts just one yes, which can choose feeding when the berry is missing."]},
	{"id":"seed_counter", "stage":1, "title":"Fill the seed jar", "lesson":"lab_counter",
	 "goal":"Start with 0 seeds. Make the jar remember a total of exactly 6.", "bowl":-1,
	 "palette":["add1","add2","add3","repeat_add"], "cases":[{}],
	 "hints":["The jar keeps the seeds from every addition. 2 + 2 + 2 makes 6.", "REPEAT 3 times: add 2 reaches 6. Two Add 3 blocks work too. Programs can have different correct solutions!"]},
	{"id":"cozy_recipe", "stage":2, "title":"A reusable recipe", "lesson":"lab_recipe",
	 "goal":"Define cozy, reach tile 2, then CALL cozy to offer one berry and pet Pip once.", "bowl":2,
	 "palette":["define","right","repeat2","call","feed"], "cases":[{"fullness":30}],
	 "hints":["DEFINE remembers the recipe; it does not perform it. CALL performs it later.", "Try DEFINE cozy, REPEAT 2 steps, then CALL cozy. Calling the recipe before reaching the berry is too soon."]},
	{"id":"recipe_input", "stage":2, "title":"A recipe with an input", "lesson":"lab_parameter",
	 "goal":"Use the pack recipe to put exactly 6 seeds into the jar.", "bowl":-1,
	 "palette":["pack1","pack2","pack3"], "cases":[{}],
	 "hints":["pack(amount) adds the number you give it. The number is an input called a parameter.", "CALL pack(3) twice makes 3 + 3 = 6. CALL pack(2) three times also works."]},
	{"id":"seed_list", "stage":3, "title":"Read the whole list", "lesson":"lab_list",
	 "goal":"Visit EACH number in [1, 3, 2] and add it to the jar. Finish with 6 seeds.", "bowl":-1,
	 "palette":["add1","add3","each"], "cases":[{}],
	 "hints":["A list keeps values in order. The values here are 1, then 3, then 2.", "FOR EACH visits every value. Watch the list index change from 0 to 1 to 2 as the jar fills."]},
	{"id":"seed_groups", "stage":3, "title":"Groups inside groups", "lesson":"lab_nested",
	 "goal":"Use a loop inside a loop to make 2 groups of 3 seeds: 6 altogether.", "bowl":-1,
	 "palette":["nested22","nested23","nested33","add1"], "cases":[{}],
	 "hints":["The outside loop counts groups. The inside loop adds seeds within each group.", "REPEAT 2 groups, with REPEAT 3 additions inside, makes 2 x 3 = 6. Watch all three additions finish before the next group starts."]}
]

static func index_of(id: String) -> int:
	for i in range(CHALLENGES.size()):
		if CHALLENGES[i].id == id:
			return i
	return -1

static func lesson_stage(key: String) -> int:
	for mission in CHALLENGES:
		if mission.lesson == key:
			return mission.stage
	return -1

static func is_unlocked(index: int, stage: int, completed: Array) -> bool:
	return index >= 0 and index < CHALLENGES.size() and CHALLENGES[index].stage <= stage and (index == 0 or completed.has(CHALLENGES[index-1].id))

static func initial_state(visit: Dictionary) -> Dictionary:
	var state = {"position":0, "fullness":30, "happiness":40, "seeds":0, "has_food":true, "fed":0, "petted":0, "calls":0, "defined":false, "used_list":false, "nested_groups":0, "nested_size":0, "error":""}
	state.merge(visit, true)
	return state

static func frame(trace: Array, row: int, words: String, state: Dictionary, action: String = "check") -> void:
	trace.append({"row":row, "words":words, "state":state.duplicate(true), "action":action})

static func perform(action: String, state: Dictionary, mission: Dictionary, trace: Array, row: int, prefix: String = "") -> void:
	if not state.error.is_empty():
		return
	var words = ""
	match action:
		"right":
			if state.position >= 3:
				state.error = "I reached the edge at tile 3. Remove an extra step or use a smaller repeat."
			else:
				state.position += 1
				words = "Step right: my tile number is now %d." % state.position
		"feed":
			if state.position != mission.bowl:
				state.error = "I cannot reach the berry yet. Move me to tile %d BEFORE Offer one berry." % mission.bowl
			elif not state.has_food:
				state.error = "There is no berry to offer. IF hungry AND a berry is available THEN feed; ELSE pet me."
			else:
				var old: int = state.fullness
				state.fullness = mini(100, old + 20)
				state.fed += 1
				state.has_food = false
				words = "IF you offer this berry THEN fullness changes: %d + 20 = %d." % [old,state.fullness]
		"pet":
			var old: int = state.happiness
			state.happiness = mini(100, old + 8)
			state.petted += 1
			words = "IF you pet me THEN happiness changes: %d + 8 = %d." % [old,state.happiness]
		_:
			var amount = int(action.trim_prefix("add"))
			var old: int = state.seeds
			state.seeds += amount
			words = "Seeds remembers our total: %d + %d = %d." % [old,amount,state.seeds]
	frame(trace,row,prefix + (state.error if not state.error.is_empty() else words),state,"error" if not state.error.is_empty() else action)

static func run_block(id: String, state: Dictionary, mission: Dictionary, trace: Array, row: int) -> void:
	match id:
		"right", "feed", "pet", "add1", "add2", "add3":
			perform(id,state,mission,trace,row)
		"repeat2", "repeat3", "repeat_add":
			var count = 2 if id == "repeat2" else 3
			for i in range(count):
				perform("add2" if id == "repeat_add" else "right",state,mission,trace,row,"Repeat %d of %d. " % [i+1,count])
		"hungry", "swapped", "both", "either":
			var hungry: bool = state.fullness < 60
			var passes: bool = hungry
			var check_words = "Hungry? %s, because fullness %d is %s60." % ["yes" if hungry else "no",state.fullness,"below " if hungry else "not below "]
			if id == "both" or id == "either":
				passes = (hungry and state.has_food) if id == "both" else (hungry or state.has_food)
				check_words = "Hungry: %s. Berry available: %s. %s gives %s." % [str(hungry),str(state.has_food),"AND" if id == "both" else "OR",str(passes)]
			var action = ("pet" if passes else "feed") if id == "swapped" else ("feed" if passes else "pet")
			frame(trace,row,check_words + " %s will run; the other action is skipped." % ("THEN" if passes else "ELSE"),state)
			perform(action,state,mission,trace,row,("THEN: " if passes else "ELSE: "))
		"define":
			state.defined = true
			frame(trace,row,"DEFINE stores my cozy recipe: offer a berry, then pet me. Nothing in the recipe runs yet!",state,"define")
		"call":
			if not state.defined:
				state.error = "I do not know cozy yet! Put DEFINE cozy before CALL cozy."
				frame(trace,row,state.error,state,"error")
			else:
				state.calls += 1
				frame(trace,row,"CALL cozy starts the recipe we defined. Now its two instructions run in order.",state,"call")
				perform("feed",state,mission,trace,row,"Inside cozy, step 1: ")
				perform("pet",state,mission,trace,row,"Inside cozy, step 2: ")
		"pack1", "pack2", "pack3":
			var amount = int(id.trim_prefix("pack"))
			state.calls += 1
			frame(trace,row,"CALL pack(%d): the input amount receives %d. The recipe adds that many seeds." % [amount,amount],state,"call")
			perform("add%d" % amount,state,mission,trace,row)
		"each":
			state.used_list = true
			var values = [1,3,2]
			for i in range(values.size()):
				perform("add%d" % values[i],state,mission,trace,row,"List index %d holds %d. " % [i,values[i]])
		"nested22", "nested23", "nested33":
			var groups = 3 if id == "nested33" else 2
			var count = 2 if id == "nested22" else 3
			state.nested_groups = groups
			state.nested_size = count
			for outer in range(groups):
				frame(trace,row,"Outside loop: group %d of %d. Now run the inside loop %d times." % [outer+1,groups,count],state)
				for inner in range(count):
					perform("add1",state,mission,trace,row,"Group %d, seed %d of %d. " % [outer+1,inner+1,count])

static func goal_error(mission: Dictionary, initial: Dictionary, state: Dictionary) -> String:
	if not state.error.is_empty():
		return state.error
	match mission.id:
		"delivery", "repeats":
			if state.position != mission.bowl or state.fed != 1:
				return "I need to reach tile %d AND eat its berry. Moving alone does not offer the snack." % mission.bowl
		"choice", "both_checks":
			var needs_food: bool = initial.fullness < 60 and (initial.has_food or mission.id == "choice")
			if state.fed != (1 if needs_food else 0) or state.petted != (0 if needs_food else 1):
				return "This visit needs %s. Choose one branch for each visit; do not run both actions." % ("one berry and no pet" if needs_food else "one pet and no berry")
		"cozy_recipe":
			if state.calls < 1 or state.fed != 1 or state.petted != 1 or state.position != 2:
				return "Use DEFINE and CALL so cozy gives one berry and one pet at tile 2. A definition alone does not run the recipe."
		"seed_counter", "recipe_input", "seed_list", "seed_groups":
			if state.seeds != 6:
				return "The jar has %d seeds; our goal is exactly 6. Change the additions or repeats, then run again." % state.seeds
			if mission.id == "recipe_input" and state.calls < 1:
				return "Use the pack recipe so its input controls the number of seeds."
			if mission.id == "seed_list" and not state.used_list:
				return "We reached 6, but this challenge asks us to read EACH value from the list. Try FOR EACH."
			if mission.id == "seed_groups" and (state.nested_groups != 2 or state.nested_size != 3):
				return "This challenge needs two groups with three seeds in each. Choose the matching nested repeat."
	return ""

static func execute(mission: Dictionary, program: Array) -> Dictionary:
	var report = {"valid":false, "success":false, "trace":[], "results":[], "message":""}
	if program.is_empty() or program.size() > MAX_BLOCKS:
		report.message = "Add between 1 and %d blocks, then try Run." % MAX_BLOCKS
		return report
	for id in program:
		if not id is String or not mission.palette.has(id):
			report.message = "This challenge uses only the blocks in its tray."
			return report
	report.valid = true
	report.success = true
	for visit in range(mission.cases.size()):
		var state = initial_state(mission.cases[visit])
		var initial = state.duplicate(true)
		var first_frame: int = report.trace.size()
		var starting_words = "Start fresh: the jar has 0 seeds. Our goal is exactly 6." if mission.bowl < 0 else "Start fresh: fullness %d, berry %s." % [state.fullness,"available" if state.has_food else "not available"]
		frame(report.trace,-1,"Visit %d of %d. " % [visit+1,mission.cases.size()] + starting_words + (" The same program runs again." if visit > 0 else " Read your blocks from top to bottom."),state,"setup")
		for row in range(program.size()):
			run_block(program[row],state,mission,report.trace,row)
			if not state.error.is_empty():
				break
		var error = goal_error(mission,initial,state)
		var passed = error.is_empty()
		report.results.append({"passed":passed,"state":state.duplicate(true),"message":error})
		report.success = report.success and passed
		if not passed and report.message.is_empty():
			report.message = "Visit %d: " % (visit+1) + error
		frame(report.trace,-1,"Visit %d works!" % (visit+1) if passed else error,state,"pass" if passed else "error")
		for i in range(first_frame,report.trace.size()):
			report.trace[i]["visit"] = visit+1
	if report.success:
		report.message = "Your program works for %s! You gave instructions, tested them, and watched what changed." % ("this visit" if mission.cases.size() == 1 else "all %d visits" % mission.cases.size())
	return report

static func present_mission(source: Dictionary, level: String) -> Dictionary:
	var result = source.duplicate(true)
	if level == "kindergarten":
		match result.id:
			"delivery":
				result.goal = "Step to my berry. THEN offer it!"
				result.hints = ["My berry is on the next tile.","Step right first. THEN offer the berry."]
			"repeats":
				result.goal = "Take 3 steps. THEN offer my berry!"
				result.hints = ["My berry is 3 little steps away.","Use REPEAT 3. THEN offer a berry."]
			"choice":
				result.goal = "IF hungry: feed. ELSE: pet. Try both visits!"
				result.hints = ["Below 60 means hungry. 30: yes. 80: no.","IF hungry: berry. ELSE: pet. Pick that block!"]
	return result

static func short_error(words: String, mission: Dictionary) -> String:
	if words.contains("BEFORE"): return "Move to tile %d BEFORE offering the berry." % mission.bowl
	if words.contains("edge"): return "Too far! Try fewer steps."
	if words.contains("no berry"): return "No berry here. Try petting Pip!"
	if words.contains("between 1"): return "Add 1 to 5 blocks. THEN press Run!"
	if words.contains("tray"): return "Use the blocks on this card."
	if mission.id == "choice": return "Hungry Pip needs food. Full Pip needs a pet. Try IF / ELSE!"
	if mission.id in ["delivery","repeats"]: return "Reach tile %d. THEN offer one berry. Try again!" % mission.bowl
	return words

static func present_report(source: Dictionary, mission: Dictionary, level: String) -> Dictionary:
	var result = source.duplicate(true)
	if level != "kindergarten": return result
	result.message = "Your plan works for every visit. Hooray!" if result.success else short_error(result.message,mission)
	for item in result.trace:
		var state: Dictionary = item.state
		match item.action:
			"setup": item.words = "Visit %d. %s Let's try our plan!" % [item.visit,"Hungry Pip." if state.fullness < 60 else "Pip has a full tummy."]
			"right": item.words = "One step right! Now I am on tile %d." % state.position
			"feed": item.words = "Munch! IF fed, THEN fullness grows to %d." % state.fullness
			"pet": item.words = "IF you pet me, THEN happiness grows to %d!" % state.happiness
			"check":
				if mission.id == "choice": item.words = "Hungry? %s. %s goes next." % ["Yes" if state.fullness < 60 else "No","THEN" if item.words.contains("THEN") else "ELSE"]
			"pass": item.words = "Visit %d works!" % item.visit
			"error": item.words = short_error(item.words,mission)
	return result
