extends RefCounted
## Every quiz question belongs to one discoverable lesson. Snippets are
## simplified GDScript versions of the behavior in hamster.gd / save_data.gd.

const LEVELS = ["kindergarten", "middle", "college"]
const LEVEL_LABELS = {
	"kindergarten":"Kindergarten - Elementary level",
	"middle":"Middle - Highschool",
	"college":"College"
}
const LEVEL_SHORT = {
	"kindergarten":"Starter learner",
	"middle":"Growing coder",
	"college":"College detail"
}
const LEVEL_DESCRIPTIONS = {
	"kindergarten":"Pip explains slowly with IF ___ THEN ___ examples, plain words, and extra hints.",
	"middle":"Start easy. Unlock two more stages with OR, NOT, comparisons, and reusable recipes.",
	"college":"Start easy. Unlock all four stages, including lists, nested loops, and boundary checks."
}
const ORDER = ["idle", "events", "variables", "boolean", "vectors", "gravity", "condition", "functions", "loops", "timer", "and", "repeat", "or", "not", "comparison", "step_size", "elif", "parameters", "accumulator", "grouping", "lists", "nested", "limits", "picnic", "lab_sequence", "lab_repeat", "lab_branch", "lab_checks", "lab_counter", "lab_recipe", "lab_parameter", "lab_list", "lab_nested", "snack_jam"]
const DATA = {
	"snack_jam": {
		"tag":"INPUT & CONDITIONS", "title":"A little rhythm, a little logic", "trigger":"Finish a Snack Jam song",
		"bubble":"IF you tap the matching pad when a snack reaches its ring THEN it counts as a hit and the combo goes up. ELSE a missed snack resets the combo. Your tap is input; my dance and the changing score are output!",
		"body":"Input is something you tell the game to do, like pressing A, S, or D, or tapping a pad. Output is the response you can see or hear: Pip dances and the snack lights up.\n\nThe game checks two things: did you choose the matching lane, AND was your tap close enough to the note's time? That check is a condition. Its answer is a boolean: true means yes, false means no.\n\nA variable remembers a value. Combo remembers how many notes you have hit in a row. IF a hit succeeds THEN add 1 to combo. ELSE a missed note or an extra tap sets combo to 0. Previously caught snacks stay counted.\n\nPerfect hits earn full accuracy credit; Nice hits earn 70% credit. Missed notes earn none, and extra taps lower accuracy. Finish a song for 20 gold plus up to 20 accuracy bonus gold. At 70% accuracy, earn 2 berries; at 90%, also earn a seed. Chill, Standard, and Lively use separate best scores and the same reward thresholds. These rhythm choices do not change your learning stage.",
		"code":"if correct_lane and on_time:\n    combo += 1\n    dance()\nelse:\n    combo = 0",
		"question":"Pip's combo is 4. You hit the next matching snack on time. What happens?",
		"choices":["The combo becomes 5", "The combo stays 4", "The combo becomes 0"], "answer":0,
		"why":"A successful hit adds 1 to the stored combo: 4 + 1 = 5. The tap is input, and the updated combo and dance are output."
	},
	"lab_sequence":{"tag":"SEQUENCING","title":"My first program","trigger":"Open A snack for Pip in Logic Lab","bubble":"IF you press Run THEN I follow your blocks from top to bottom. A program is a list of instructions. Put Step right first, then Offer one berry. Order matters: I must reach my snack before I can eat it!","body":"An instruction tells Pip to do one thing. A sequence is the order of those instructions. Pip starts on tile 0; the next tile is 1.\n\nClick a block in the tray to add it to your program, or drag it into a space. Use the up and down arrows to reorder blocks, and the cross to remove one. There are five spaces. First, predict what Pip will do. Press Run to watch, or Step to follow one action at a time. Pause lets you read; Stop / edit lets you change the program.\n\nThis is a practice scene with its own berries and numbers. Trying does not spend your treats. IF an instruction is in the wrong place THEN move it and try again. Finding and fixing a mistake is called debugging.","code":"step_right()\noffer_berry()","question":"Pip is one step away from his berry. Which program works?","choices":["Step right, then offer the berry","Offer the berry, then step right","Offer the berry without moving"],"answer":0,"why":"Pip needs to be beside the berry before he can eat it. The order of instructions changes what happens."},
	"lab_repeat":{"tag":"REPEATS","title":"One block, several steps","trigger":"Open Three tiny steps in Logic Lab","bubble":"IF a block says REPEAT 3 times THEN I do its action three times. That repeated action is called a loop. Repeat my step three times, then offer the berry. Watch one block light up while I take each little step!","body":"REPEAT means do the same action again. A loop avoids writing the same instruction many times. REPEAT 3: step right means step, step, step.\n\nThe next block waits until all three steps finish. Then Offer one berry can run. You can also use three separate Step right blocks; both programs can work. Choose blocks from the tray, reorder them with the arrows or by dragging, and press Run. Step and Pause let you take your time.","code":"for step in range(3):\n    step_right()\noffer_berry()","question":"A block repeats Step right 3 times. How many steps does Pip take?","choices":["3 steps","1 step","4 steps"],"answer":0,"why":"The repeat count is three, so the same action happens three times before the next block runs."},
	"lab_branch":{"tag":"IF / ELSE","title":"One program, two visits","trigger":"Open Hungry or happy? in Logic Lab","bubble":"IF I am hungry THEN offer a berry. ELSE, which means otherwise, pet me. Hungry is a yes-or-no check: fullness below 60 means yes. Only one of these two actions runs. Try the same program with hungry Pip and already-fed Pip!","body":"A condition is a question with a yes or no answer. We call yes true and no false. Here hungry asks whether fullness is below 60. Fullness 30 gives yes; fullness 80 gives no.\n\nTHEN tells Pip what to do when the answer is yes. ELSE tells him what to do otherwise. The other action is skipped. The lab runs two separate visits with the same blocks, resetting its practice numbers before each visit. A program should work for both visits.\n\nChoose the rule block whose actions match the goal. Press Run, or Step through the check and its chosen action. There is no need to type code.","code":"if fullness < 60:\n    offer_berry()\nelse:\n    pet_pip()","question":"Fullness starts at 80. In IF hungry: feed; ELSE: pet, what happens?","choices":["The ELSE action pets Pip","The THEN action feeds Pip","Both actions happen"],"answer":0,"why":"80 is not below 60, so hungry is false. The ELSE action runs and the feeding action is skipped."},
	"lab_checks":{"tag":"AND / OR","title":"Check two things before feeding","trigger":"Open Two little checks in Logic Lab","bubble":"IF I am hungry AND a berry is available THEN feed me. ELSE pet me. AND needs both answers to be yes. OR needs at least one yes. When I am hungry but the berry is missing, AND says no, so we choose the pet instead!","body":"A boolean is a value that is either true (yes) or false (no). Hungry is true when fullness is below 60. Berry available is true when the practice tray has a berry.\n\nAND combines checks and needs both to be true. OR combines checks and needs at least one to be true. The goal requires AND because feeding needs hunger and an available berry.\n\nRun the same program for three visits: hungry with food, hungry without food, and not hungry with food. Watch each check, then its selected branch. Failed attempts cost nothing; edit a block or ask for a hint.","code":"if hungry and berry_available:\n    offer_berry()\nelse:\n    pet_pip()","question":"Hungry is true, but berry available is false. What is hungry AND berry available?","choices":["False: both checks must be true","True: one true check is enough","It has no answer"],"answer":0,"why":"AND needs two true values. The missing berry makes the combined check false, so the ELSE branch should run."},
	"lab_counter":{"tag":"VARIABLES","title":"A jar that remembers","trigger":"Open Fill the seed jar in Logic Lab","bubble":"IF we add seeds THEN the jar remembers a new total. A variable is a named place that stores a value. Our variable seeds starts at 0. Adding 2 three times changes it from 0 to 2, then 4, then 6.","body":"Seeds is a variable: its value can change. Each addition uses the old total and stores the new total. That is why the second Add 2 gives 4 instead of forgetting the first two seeds.\n\nBuild a program that reaches exactly 6. Repeated additions, two additions of 3, or REPEAT 3: add 2 can all work. Different programs can produce the same result. Watch the seed number change as each instruction lights up. These are practice seeds, so trying does not spend anything.","code":"seeds = 0\nfor turn in range(3):\n    seeds = seeds + 2","question":"Seeds is 4. An instruction adds 2. What value is stored next?","choices":["6","2","4"],"answer":0,"why":"The instruction uses the previous total: 4 + 2 = 6. It stores the result back in seeds."},
	"lab_recipe":{"tag":"FUNCTIONS","title":"Define it, then call it","trigger":"Open A reusable recipe in Logic Lab","bubble":"IF you DEFINE cozy THEN I remember a recipe: offer a berry, then pet me. Defining does not perform it yet. IF you CALL cozy THEN I follow that recipe. A named recipe like this is called a function.","body":"DEFINE gives a name to instructions. CALL runs the instructions stored under that name. You can call a function whenever you need the same recipe again.\n\nThe cozy recipe has two instructions in order: Offer one berry, then Pet Pip. Define it before calling it. Pip must also reach the berry on tile 2 before the call. A function still needs the right starting situation.\n\nTry DEFINE cozy, movement blocks, and CALL cozy. Watch the call light up while both instructions inside the recipe run. Calling an unknown recipe gives a helpful message instead of losing progress.","code":"func cozy():\n    offer_berry()\n    pet_pip()\n\nstep_right()\nstep_right()\ncozy()","question":"What happens when you DEFINE cozy?","choices":["Pip remembers the recipe for a later call","Pip immediately performs every action","The recipe is deleted"],"answer":0,"why":"A definition stores the recipe. Its instructions run when the function is called."},
	"lab_parameter":{"tag":"FUNCTION INPUTS","title":"Give a recipe a number","trigger":"Open A recipe with an input in Logic Lab","bubble":"IF you CALL pack(3) THEN the pack recipe adds 3 seeds. The number in the brackets is an input called a parameter. The recipe stays the same; changing its input changes how many seeds it adds.","body":"The lab already knows a recipe named pack(amount). It adds amount seeds to the jar. The parameter amount receives the number from your call. For pack(2), amount is 2; for pack(3), amount is 3.\n\nStart at 0 and build a program that reaches exactly 6. Calls run from top to bottom. Two calls of pack(3) work, and three calls of pack(2) work too. Watch each call pass its input to the same recipe.","code":"func pack(amount):\n    seeds = seeds + amount\n\npack(3)\npack(3)","question":"What number does amount receive in pack(2)?","choices":["2","The previous jar total","Always 3"],"answer":0,"why":"The call supplies 2 as the input. The recipe adds that amount to the existing total."},
	"lab_list":{"tag":"LISTS","title":"Visit each item in order","trigger":"Open Read the whole list in Logic Lab","bubble":"IF we use FOR EACH on [1, 3, 2] THEN we visit 1, then 3, then 2. A list keeps several values in order. We add each value to the jar, so the total changes from 0 to 1, then 4, then 6.","body":"A list stores an ordered collection of values. FOR EACH is a loop that visits every value. Our list has three values: [1, 3, 2].\n\nAn index is an item's position number. Index 0 is the first item, index 1 is the second, and index 2 is the third. An index is not the value itself: index 1 here holds value 3.\n\nUse the FOR EACH block to visit the whole list. The animation shows the index and value at each addition. The goal includes using the list, not just arriving at the number 6 by another route.","code":"seeds = 0\nfor amount in [1, 3, 2]:\n    seeds = seeds + amount","question":"Which value is at index 1 in [1, 3, 2]?","choices":["3","1","2"],"answer":0,"why":"Indexing starts at 0. Index 1 is the second position, whose value is 3."},
	"lab_nested":{"tag":"NESTED LOOPS","title":"A loop inside a loop","trigger":"Open Groups inside groups in Logic Lab","bubble":"IF we repeat 2 groups AND each group repeats 3 seed additions THEN we add 6 seeds altogether. A nested loop is a loop inside another loop. Finish all 3 inside steps before starting the next outside group.","body":"The outside loop counts groups. The inside loop counts seeds in one group. Each time the outside loop runs, the complete inside loop starts again.\n\nFor 2 groups with 3 seeds each, the sequence is group 1: seed 1, seed 2, seed 3; then group 2: seed 1, seed 2, seed 3. That makes 2 times 3, or 6 additions.\n\nChoose the matching nested block. The goal needs the stated groups as well as the total. Step through to see the outside loop start a group, then the inside loop finish its additions.","code":"for group in range(2):\n    for seed in range(3):\n        seeds = seeds + 1","question":"An outer loop runs 2 times. Its inner loop adds 1 seed 3 times. How many seeds are added?","choices":["6","5","3"],"answer":0,"why":"The three additions happen for each of two groups: 3 + 3 = 6."},
	"picnic": {
		"tag":"INPUT & OUTPUT", "title":"Catch a snack with Pip", "trigger":"Play Picnic Catch",
		"bubble":"IF you move the mouse or press a direction THEN my basket moves. IF it catches a snack THEN our snack count goes up by one. Your action is the input; my movement and our changing count are the output!",
		"body":"Input means an action you give the game, such as moving the mouse, dragging a finger, or pressing Right. Output means the response you see: Pip moves his basket.\n\nA condition is a yes-or-no check. IF a snack reaches the basket THEN add one to snacks. A variable is a named place that remembers a value; snacks remembers our count. A streak counts catches in a row. Missing a snack restarts the current streak, but keeps the snacks already collected.\n\nCatch 10 snacks to finish. There is no countdown or lost life. You earn 20 gold, plus 2 for each catch in your best streak. Later stages introduce golden seeds (+2 gold) and leaves to let fall. Your moves control the basket, so try a different position and watch what changes!",
		"code":"if snack_caught:\n    snacks += 1\n    streak += 1",
		"question":"Your basket catches a snack. What happens to the snack count?", "choices":["It increases by one", "It goes back to zero", "It never changes"], "answer":0,
		"why":"Catching a snack makes the check true, so the game adds one to the stored snack count."},
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
		"why":"Each repetition moves one stone, so four repetitions move four stones."},
	"or": {"tag": "OR LOGIC", "title": "At least one yes", "trigger": "More ways to decide", "bubble": "IF a find is a berry OR it is red THEN basket. OR needs at least one yes.", "body": "OR joins two yes-or-no checks. One true check is enough; two true checks also pass. A blue berry passes because it is a berry. A red button passes because it is red. A gray pebble fails both checks.", "code": "if is_berry or is_red:\n    basket()", "question": "The rule is berry OR red. Does a red button pass?", "choices": ["Yes: the red check is true", "No: both checks must be true", "Only if it becomes a berry"], "answer": 0, "why": "OR needs at least one true check. The red button passes the red check."},
	"not": {"tag": "NOT LOGIC", "title": "Turn a check around", "trigger": "More ways to decide", "bubble": "IF a berry is NOT red THEN basket. NOT turns true into false and false into true.", "body": "NOT reverses a yes-or-no answer. For a blue berry, is_red is false, so not is_red is true. For a red berry, not is_red is false. In this game, AND still requires the find to be a berry, too.", "code": "if is_berry and not is_red:\n    basket()", "question": "Which find passes berry AND NOT red?", "choices": ["A blue berry", "A red berry", "A gray pebble"], "answer": 0, "why": "The blue berry passes is_berry. Its red check is false, so NOT red is true."},
	"comparison": {"tag": "COMPARISONS", "title": "Compare two numbers", "trigger": "More ways to decide", "bubble": "IF fullness is less than 95 THEN there is room for a snack. The < sign means less than.", "body": "A comparison checks two values and gives true or false. < means less than, > means greater than, and == asks whether values are equal. At 94, fullness < 95 is true. At exactly 95 it is false. An equals sign by itself stores a value; two equals signs compare values.", "code": "can_snack = fullness < 95\nat_target = position == target", "question": "Fullness is exactly 95. Is fullness < 95 true?", "choices": ["No: 95 is not less than 95", "Yes: equal means less than", "Only on a sunny day"], "answer": 0, "why": "Less than does not include equal. At exactly 95 the check is false."},
	"step_size": {"tag": "VARIABLE UPDATES", "title": "A bigger step", "trigger": "More ways to decide", "bubble": "IF one repeat adds 2 THEN three repeats add 6. A variable remembers the new number each time.", "body": "A loop can change a stored number by more than one. Start at 1 and add 2 on each repeat: 3, 5, 7. Three repeats reach 7. Count the changes, not just the destination number. The garden labels show the value after each repeat.", "code": "position = 1\nfor step in range(3):\n    position += 2", "question": "Start at 1. Add 2 on each of 3 repeats. Where do you finish?", "choices": ["7", "3", "6"], "answer": 0, "why": "The stored value goes 1, 3, 5, 7. The starting value matters too."},
	"elif": {"tag": "ELIF CHOICES", "title": "Try the next question", "trigger": "Little recipes", "bubble": "IF it is a red berry THEN snack. ELSE IF it is another berry THEN save it. ELSE leave it.", "body": "ELIF is short for else if: otherwise, check another condition. The game checks in order and runs only the first matching choice. A red berry is also a berry, but the first choice already matched, so it does not run the next choice.", "code": "if is_red_berry: snack()\nelif is_berry: save_it()\nelse: leave_it()", "question": "A red berry matches the first AND second checks. What runs?", "choices": ["Only the first choice: snack", "Both snack and save", "Only the last choice: leave"], "answer": 0, "why": "An IF / ELIF / ELSE chain runs the first matching choice and skips the rest."},
	"parameters": {"tag": "FUNCTION INPUTS", "title": "Choose the recipe input", "trigger": "Little recipes", "bubble": "IF I call add_seeds(2) THEN the recipe adds 2 seeds. The number is an input to a reusable recipe.", "body": "A function is a named recipe. A parameter is a named input the recipe uses. add_seeds(amount) uses the value passed as amount. Calling add_seeds(2) adds two; calling add_seeds(3) adds three. You reuse the recipe with different inputs.", "code": "func add_seeds(amount):\n    total += amount\n# add_seeds(2) adds two", "question": "What changes when we call add_seeds(3) instead of add_seeds(2)?", "choices": ["The amount added by the same recipe", "The game forgets the recipe", "Nothing can change"], "answer": 0, "why": "The parameter amount receives 3, so the same recipe now adds 3 seeds."},
	"accumulator": {"tag": "RUNNING TOTALS", "title": "Keep adding to a total", "trigger": "Little recipes", "bubble": "IF a loop repeats THEN add this batch to total. An accumulator is a number that keeps a running total.", "body": "An accumulator remembers a running total. Start total at zero before the loop. Each repeat adds the next batch. With three seeds per batch and four repeats, the total becomes 3, 6, 9, 12. Resetting total inside the loop would lose earlier batches.", "code": "total = 0\nfor batch in range(4):\n    total += 3", "question": "Four repeats each add 3 seeds to a total that starts at 0. What is the total?", "choices": ["12", "3", "4"], "answer": 0, "why": "The total keeps earlier additions: 3 + 3 + 3 + 3 = 12."},
	"grouping": {"tag": "GROUPED LOGIC", "title": "Keep checks together", "trigger": "Code explorer", "bubble": "IF (berry OR seed) AND NOT spoiled THEN basket. Parentheses keep the food checks together.", "body": "Parentheses mark a group to check together. First ask whether the find is a berry or a seed. Then require that it is not spoiled. A fresh seed passes both parts. A spoiled berry fails the fresh check even though it is a berry.", "code": "if (is_berry or is_seed) \\\n        and not is_spoiled:\n    basket()", "question": "The rule is (berry OR seed) AND NOT spoiled. Does a spoiled berry pass?", "choices": ["No: NOT spoiled is false", "Yes: all berries pass", "Yes: parentheses ignore spoilage"], "answer": 0, "why": "The food group is true, but the freshness check is false. AND needs both parts."},
	"lists": {"tag": "LISTS", "title": "Keep values in order", "trigger": "Code explorer", "bubble": "IF I need the first list item THEN I use index 0. A list keeps several values in order.", "body": "A list, called an Array in GDScript, stores several values in order. An index names a position in the list. Counting indexes starts at zero. In [2, 3, 2], index 0 gives 2 and index 1 gives 3. Our three gardens use these entries to choose the inner repeat count.", "code": "steps = [2, 3, 2]\nfirst = steps[0] # 2\nsecond = steps[1] # 3", "question": "steps is [2, 3, 2]. What value is steps[1]?", "choices": ["3: the second item", "2: the first item", "1: the index itself"], "answer": 0, "why": "Index 0 is first; index 1 is second. The second value is 3."},
	"nested": {"tag": "NESTED LOOPS", "title": "A repeat inside a repeat", "trigger": "Code explorer", "bubble": "IF the outer loop repeats THEN run the whole inner loop again. Two groups of three steps make six steps.", "body": "A nested loop is a loop inside another loop. Every outer repeat starts the whole inner loop again. Two outer repeats with three inner repeats each give six steps: 3, then 3 more. The garden shows each inner step before starting the next group.", "code": "for group in range(2):\n    for step in range(3):\n        move_one_step()", "question": "An outer loop repeats 2 times. Its inner loop repeats 3 times each. How many steps?", "choices": ["6", "5", "3"], "answer": 0, "why": "Each outer repeat runs all three inner steps: 2 groups times 3 steps = 6."},
	"limits": {"tag": "BOUNDARY CHECKS", "title": "Check the edge", "trigger": "Code explorer", "bubble": "IF fullness reaches 95 THEN skip the snack. A boundary is the exact point where a rule changes.", "body": "A boundary is a limit where a decision changes. Test just below the limit, exactly at it, and just above it. For fullness < 95, 94 passes, 95 fails, and 96 fails. Testing these edge cases helps find mistakes before players encounter them.", "code": "# fullness < 95\n# 94: true; 95: false\n# 96: false", "question": "Which set best checks the edge of the rule fullness < 95?", "choices": ["94, 95, and 96", "10, 20, and 30", "Only 0"], "answer": 0, "why": "94, 95, and 96 test below, at, and above the boundary where the answer changes."}
}

const IF_THEN = {
	"snack_jam":"IF you tap the matching snack on time THEN the combo goes up and I dance. ELSE a missed snack resets the combo.",
	"picnic":"IF you move the mouse or press a direction THEN my basket moves. IF it catches a snack THEN add one to our count.",
	"idle":"IF I am being held THEN I dangle. ELSE I rest and breathe.",
	"events":"IF your click lands on my head THEN the game runs pet().",
	"variables":"IF you pet me THEN happiness becomes the old number plus 8.",
	"boolean":"IF is_held is true THEN I follow your hand. IF it is false THEN I stand on my own.",
	"vectors":"IF the mouse moves right THEN my x number grows. IF it moves down THEN my y number grows.",
	"gravity":"IF you let go in the air THEN gravity pulls me down until the floor stops me.",
	"condition":"IF I am hungry enough AND you have a treat THEN I can eat.",
	"functions":"IF the game calls feed(kind) THEN it runs the snack recipe for that treat.",
	"loops":"IF the chew loop has more repeats left THEN I chew again.",
	"timer":"IF my quiet timer reaches its target THEN I clean my face.",
	"and":"IF is_berry is true AND is_red is true THEN the find goes in the basket.",
	"repeat":"IF repeat is 4 THEN the marker takes 4 steps.",
	"or": "IF a find is a berry OR it is red THEN basket. OR needs at least one yes.",
	"not": "IF a berry is NOT red THEN basket. NOT turns true into false and false into true.",
	"comparison": "IF fullness is less than 95 THEN there is room for a snack. The < sign means less than.",
	"step_size": "IF one repeat adds 2 THEN three repeats add 6. A variable remembers the new number each time.",
	"elif": "IF it is a red berry THEN snack. ELSE IF it is another berry THEN save it. ELSE leave it.",
	"parameters": "IF I call add_seeds(2) THEN the recipe adds 2 seeds. The number is an input to a reusable recipe.",
	"accumulator": "IF a loop repeats THEN add this batch to total. An accumulator is a number that keeps a running total.",
	"grouping": "IF (berry OR seed) AND NOT spoiled THEN basket. Parentheses keep the food checks together.",
	"lists": "IF I need the first list item THEN I use index 0. A list keeps several values in order.",
	"nested": "IF the outer loop repeats THEN run the whole inner loop again. Two groups of three steps make six steps.",
	"limits": "IF fullness reaches 95 THEN skip the snack. A boundary is the exact point where a rule changes."
}

const SIMPLE_WORDS = {
	"snack_jam":"Your tap is input: an action you give the game. My dance is output: its response. Combo is a variable that remembers a number.",
	"picnic":"Input means your action. Output means what the game does because of it. A variable remembers a value, like our snack count!",
	"idle":"A condition is just a yes-or-no question the game asks.",
	"events":"An event means something happened, like a click.",
	"variables":"A variable is a labeled box that stores a number or word.",
	"boolean":"A boolean is a tiny switch with only true or false.",
	"vectors":"A Vector2 is two position numbers: x and y.",
	"gravity":"Velocity means speed and direction. Gravity changes the downward speed.",
	"condition":"A condition is a check. The answer is true or false.",
	"functions":"A function is a named recipe the game can reuse.",
	"loops":"A loop repeats the same step instead of writing it many times.",
	"timer":"A timer counts time until something should happen.",
	"and":"AND means both checks must be true.",
	"repeat":"A repeat count tells a loop how many times to run.",
	"or": "",
	"not": "",
	"comparison": "",
	"step_size": "",
	"elif": "",
	"parameters": "",
	"accumulator": "",
	"grouping": "",
	"lists": "",
	"nested": "",
	"limits": ""
}

const COLLEGE_NOTES = {
	"snack_jam":"The lane check AND the timing check must both be true. The game compares the tap time with the note time, then updates the combo variable.",
	"picnic":"The game checks whether a snack crosses the basket's height within its width. Each snack counts once; reaching 10 ends the round. The changing snack count is stored in a variable.",
	"idle":"This is state-based animation selection: is_held controls which branch mutates the current animation state.",
	"events":"This uses input handling: a mouse event is filtered by hit area, then dispatches the pet interaction.",
	"variables":"This is bounded state mutation: happiness is incremented and clamped so the invariant 0 <= happiness <= 100 holds.",
	"boolean":"is_held is a boolean state flag used by movement, animation, and input flow.",
	"vectors":"Position is represented by a 2D vector. The held critter interpolates toward the pointer to create soft motion.",
	"gravity":"The falling behavior integrates velocity over time, then resolves contact with the floor using a damped bounce.",
	"condition":"Feeding is gated by compound conditions, so inventory and fullness must both allow the action.",
	"functions":"feed(kind) abstracts repeated snack behavior behind one callable routine with a treat-type parameter.",
	"loops":"The chew animation is a finite repeated sequence. A loop expresses repeated work without duplicating code.",
	"timer":"The timer accumulates delta time, making the behavior frame-rate independent.",
	"and":"Logical AND shortens a decision that needs multiple true predicates before accepting an item.",
	"repeat":"The loop count is an input-controlled parameter; debugging means comparing expected and observed state.",
	"or": "OR needs at least one true check. The red button passes the red check.",
	"not": "The blue berry passes is_berry. Its red check is false, so NOT red is true.",
	"comparison": "Less than does not include equal. At exactly 95 the check is false.",
	"step_size": "The stored value goes 1, 3, 5, 7. The starting value matters too.",
	"elif": "An IF / ELIF / ELSE chain runs the first matching choice and skips the rest.",
	"parameters": "The parameter amount receives 3, so the same recipe now adds 3 seeds.",
	"accumulator": "The total keeps earlier additions: 3 + 3 + 3 + 3 = 12.",
	"grouping": "The food group is true, but the freshness check is false. AND needs both parts.",
	"lists": "Index 0 is first; index 1 is second. The second value is 3.",
	"nested": "Each outer repeat runs all three inner steps: 2 groups times 3 steps = 6.",
	"limits": "94, 95, and 96 test below, at, and above the boundary where the answer changes."
}

static func normalize_level(level: String) -> String:
	return level if level in LEVELS else "kindergarten"

static func level_label(level: String) -> String:
	return LEVEL_LABELS[normalize_level(level)]

static func level_description(level: String) -> String:
	return LEVEL_DESCRIPTIONS[normalize_level(level)]

static func entry(key: String, level: String = "kindergarten") -> Dictionary:
	var lesson = DATA[key].duplicate(true)
	if key.begins_with("lab_"):
		return lesson
	if key in ["or", "not", "comparison", "step_size", "elif", "parameters", "accumulator", "grouping", "lists", "nested", "limits"]:
		return lesson
	var normalized = normalize_level(level)
	if normalized == "kindergarten":
		lesson.bubble = IF_THEN[key] + " " + SIMPLE_WORDS[key]
		lesson.body = IF_THEN[key] + "\n\n" + SIMPLE_WORDS[key] + " You can read it like a normal sentence before you read it like code.\n\n" + lesson.body
		lesson.why = SIMPLE_WORDS[key] + " " + lesson.why
	elif normalized == "middle":
		lesson.bubble = IF_THEN[key] + " In code, this is " + lesson.tag.to_lower() + " controlling what happens next."
		lesson.body = IF_THEN[key] + "\n\nRead the plain words first, then follow the code one line at a time. Each line describes a check, a stored value, or an action.\n\n" + lesson.body
		lesson.why = "Think about which check is true. " + lesson.why
	else:
		lesson.bubble = IF_THEN[key] + " " + COLLEGE_NOTES[key]
		lesson.body = lesson.body + "\n\nCollege note: " + COLLEGE_NOTES[key]
		lesson.why = COLLEGE_NOTES[key] + " " + lesson.why
	return lesson

static func quiz_pool(discovered: Array) -> Array:
	var pool: Array = []
	for key in discovered:
		if DATA.has(key):
			pool.append(key)
	pool.shuffle()
	return pool.slice(0, 5)
