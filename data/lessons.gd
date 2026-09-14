extends RefCounted
## Every quiz question belongs to one discoverable lesson. Snippets are
## simplified GDScript versions of the behavior in hamster.gd / save_data.gd.

const ORDER = ["idle", "events", "variables", "boolean", "vectors", "gravity", "condition", "functions", "loops", "timer", "and", "repeat"]
const DATA = {
	"idle": {
		"tag":"IF / ELSE", "title":"A tiny decision", "trigger":"Watch Pip idle",
		"bubble":"If I'm being held, I dangle. Else, I can relax! An if / else chooses which behavior runs.",
		"body":"The game checks my state before choosing an animation. An if block runs when its condition is true. The else block runs when that condition is false.\n\nTry holding me, then letting go. The same check can choose a different action when my state changes.",
		"code":"if is_held:\n    animate_dangle()\nelse:\n    animate_idle()",
		"question":"Pip is NOT being held. Which branch runs?", "choices":["The else branch: idle", "The if branch: dangle", "Both branches at once"], "answer":0,
		"why":"is_held is false, so the if block is skipped and the else block runs."},
	"events": {
		"tag":"EVENTS", "title":"A click starts something", "trigger":"Click Pip's head",
		"bubble":"You clicked my head! That mouse event called pet(), and pet() started my happy animation.",
		"body":"An event tells the game that something happened: a click, a key press, or a released mouse button. The game checks where the click happened, then responds.\n\nA short click on my head pets me. Holding the click starts a different action: picking me up.",
		"code":"if head_clicked:\n    pet()",
		"question":"What starts Pip's petting reaction?", "choices":["A mouse click event on the head", "Closing the game", "A number hidden in a berry"], "answer":0,
		"why":"The head click is an input event. Its handler calls pet()."},
	"variables": {
		"tag":"VARIABLES", "title":"Happiness has a value", "trigger":"Pet Pip again",
		"bubble":"My happiness went up! A variable stores a value that can change. Petting adds 8, up to 100.",
		"body":"A variable is a named place to keep a value. happiness stores a number. Petting adds 8 to the old value and stores the result.\n\nThe game caps happiness at 100. If it was 97, petting makes it 100, rather than 105.",
		"code":"happiness = min(100, happiness + 8)",
		"question":"Happiness is 40. Petting adds 8. What is it now?", "choices":["48", "8", "40"], "answer":0,
		"why":"The new value is the old value plus 8: 40 + 8 = 48."},
	"boolean": {
		"tag":"BOOLEANS", "title":"Held: true or false?", "trigger":"Hold Pip to pick up",
		"bubble":"Wheee! is_held is now true. A boolean has only two values: true and false. Let go to make it false.",
		"body":"A boolean stores one of two values: true or false. My is_held variable answers the question: am I being held?\n\nPicking me up sets it to true. Releasing me sets it to false. The game uses this value to choose movement and animation.",
		"code":"# Pick up\nis_held = true\n# Release\nis_held = false",
		"question":"Which pair contains the two boolean values?", "choices":["true and false", "left and berry", "1, 2, and 3"], "answer":0,
		"why":"A boolean has exactly two possible values: true and false."},
	"vectors": {
		"tag":"POSITION", "title":"A world of x and y", "trigger":"Move Pip while holding",
		"bubble":"Moving right increases x. Moving down increases y. My position is a Vector2: two numbers for one spot!",
		"body":"A 2D position has an x coordinate and a y coordinate. In Godot's 2D screen, x increases to the right and y increases downward.\n\nWhile you hold me, a spring pulls my position toward the mouse. My direction changes how my body leans and my paws swing.",
		"code":"position = Vector2(x, y)\n# Right: x increases\n# Down:  y increases",
		"question":"In Godot's 2D screen, what increases when Pip moves down?", "choices":["The y coordinate", "The number of berries", "The x coordinate"], "answer":0,
		"why":"Screen y increases downward. Screen x increases to the right."},
	"gravity": {
		"tag":"CAUSE & EFFECT", "title":"A soft landing", "trigger":"Release Pip in the air",
		"bubble":"You let go, so gravity pulled me down. When I reached the floor, the game made me bounce gently!",
		"body":"When I am falling, gravity increases my downward velocity over time. The game moves me using that velocity.\n\nOn the floor, it reverses and reduces that velocity for a gentle bounce. Once the bounce is small enough, I settle. This connects an action to its consequences.",
		"code":"velocity.y += gravity * delta\nposition += velocity * delta",
		"question":"Why does Pip move down after you release him in the air?", "choices":["Gravity increases downward velocity", "The mouse is still holding him", "A quiz changes his x coordinate"], "answer":0,
		"why":"Once released, gravity adds to downward velocity each physics step."},
	"condition": {
		"tag":"CONDITIONS", "title":"Is it snack time?", "trigger":"Offer Pip a treat",
		"bubble":"Before a snack, the game checks: am I below 95 fullness AND do you have this treat? Only then can I eat!",
		"body":"A condition is a check with a true or false result. Feeding checks my fullness and your inventory. Both checks must be true.\n\nIf I am too full or you have no treats of that kind, nothing is spent. You can earn more treats by playing.",
		"code":"if fullness < 95 and treats > 0:\n    feed()\nelse:\n    show_reason()",
		"question":"Pip's fullness is 60, but you have 0 berries. Can he eat a berry?", "choices":["No: the inventory check is false", "Yes: fullness is below 95", "Yes: the game invents a berry"], "answer":0,
		"why":"Both conditions must be true. With no berries, the inventory check fails."},
	"functions": {
		"tag":"FUNCTIONS", "title":"A little recipe of actions", "trigger":"Feed Pip a second time",
		"bubble":"feed() is a function: a named recipe of actions. It spends one treat, updates my needs, and counts the snack.",
		"body":"A function groups useful steps under a name so the game can call those steps again. feed(kind) takes a treat kind as its input.\n\nThe same function works for berries, seeds, and carrots. It checks availability, subtracts one treat, and updates my needs.",
		"code":"func feed(kind):\n    inventory[kind] -= 1\n    fullness += nutrition[kind]",
		"question":"Why put feeding steps into a function?", "choices":["So the game can reuse the steps", "To delete every treat", "To stop the game responding to clicks"], "answer":0,
		"why":"A function gives a reusable name to a group of actions."},
	"loops": {
		"tag":"LOOPS", "title":"Three little chews", "trigger":"Let Pip finish a snack",
		"bubble":"Munch, munch, munch! My snack animation repeats the same chew three times. Loops are for repeating actions.",
		"body":"A loop repeats an action. Pip's eating animation counts three chew cycles and then returns to idle.\n\nA for loop can express the same idea: repeat the chew action three times. range(3) supplies 0, 1, and 2: three values, so three repetitions.",
		"code":"for chew in range(3):\n    animate_one_chew()",
		"question":"How many times does a for loop over range(3) repeat?", "choices":["3 times", "2 times", "Forever"], "answer":0,
		"why":"range(3) supplies three values: 0, 1, and 2. The body runs once for each."},
	"timer": {
		"tag":"TIMERS", "title":"Time for a little groom", "trigger":"Leave Pip resting for a while",
		"bubble":"My idle timer reached its target, so I washed my face! Timers let a game do something after time has passed.",
		"body":"The game adds delta, the time since the previous update, to my idle timer. When enough time has passed, it starts a grooming animation and resets the timer.\n\nUsing elapsed time lets a timer measure seconds even if the number of frames per second changes.",
		"code":"idle_time += delta\nif idle_time >= 12.0:\n    groom()\n    idle_time = 0.0",
		"question":"What does delta represent in the timer?", "choices":["Time since the previous update", "The number of carrots", "Always exactly one second"], "answer":0,
		"why":"delta is elapsed time since the last update, measured in seconds."},
	"and": {
		"tag":"AND LOGIC", "title":"Two checks, one choice", "trigger":"Play Berry Detective",
		"bubble":"You tested two checks with AND! For 'is a berry AND is red', a blue berry fails the red check.",
		"body":"The and operator combines two conditions. The combined result is true only when both conditions are true.\n\nIn Berry Detective, check the rule on every round. A berry can pass is_berry but fail is_red. A red button can pass is_red but fail is_berry.",
		"code":"if is_berry and is_red:\n    put_in_basket()\nelse:\n    leave_it()",
		"question":"The rule is is_berry AND is_red. Does a BLUE berry pass?", "choices":["No: is_red is false", "Yes: it is a berry", "Yes: only one check must pass"], "answer":0,
		"why":"AND needs both checks to be true. This berry fails the red check."},
	"repeat": {
		"tag":"LOOP COUNTS", "title":"Just enough steps", "trigger":"Play Loop Garden",
		"bubble":"You chose how many times to repeat a step! Too many or too few repeats end in a different place.",
		"body":"A repeat count controls how often a loop runs. In Loop Garden, one repetition moves the marker one stepping stone to the right.\n\nCount the steps from the start to the target, choose that repeat count, then run it. If the result is wrong, change the count and try again. That's debugging!",
		"code":"for step in range(repeats):\n    move_one_stone_right()",
		"question":"The target is 4 steps away. How many times should move_one_stone_right() run?", "choices":["4 times", "1 time", "5 times"], "answer":0,
		"why":"Each repetition moves one stone, so four repetitions move four stones."}
}

static func quiz_pool(discovered: Array) -> Array:
	var pool: Array = []
	for key in discovered:
		if DATA.has(key):
			pool.append(key)
	pool.shuffle()
	return pool.slice(0, 5)
