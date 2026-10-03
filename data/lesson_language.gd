extends RefCounted
## Plain teaching text. Keep each beginner bubble in short, newline-separated thoughts.
const KIDS = {
	"idle": {
		"title": "Two little choices",
		"bubble": "IF means check. THEN means do!\nIF you hold me, THEN I dangle.\nELSE I rest. ELSE means otherwise!",
		"body": "A condition is a yes-or-no question.\nAm I being held?\nYes: dangle! No: rest.\nOnly one choice happens.",
		"code": "IF held: dangle\nELSE: rest",
		"question": "What does ELSE mean?",
		"choices": [
			"Otherwise",
			"Do both",
			"Stop forever"
		],
		"why": "ELSE is the other choice. Not held? I rest!"
	},
	"events": {
		"title": "A happy boop",
		"bubble": "Boop! Your tap is input.\nMy happy face is output.\nIF you pet me, THEN I feel happier!",
		"body": "Input is something you do. Output is what the game does back.\nYou tap. Pip smiles!\nAn event is something that happens, like your tap.",
		"code": "IF head tapped:\n    add happiness",
		"question": "Which one is input?",
		"choices": [
			"Your tap",
			"Pip smiling",
			"Pip breathing"
		],
		"why": "Your tap goes in. My happy reaction comes out!"
	},
	"variables": {
		"title": "My happy number",
		"bubble": "A variable remembers something.\nMine remembers my happy number!\nIF you pet me, THEN add 8.",
		"body": "Think of a named number box.\nThe happiness box starts at 40.\nAdd 8: now it holds 48!\nMy numbers stop at 100.",
		"code": "happiness: 40\npet Pip: add 8\nnew happiness: 48",
		"question": "What does a variable do?",
		"choices": [
			"Remembers a value",
			"Eats berries",
			"Always says no"
		],
		"why": "A variable is a named place to remember a value, like a number."
	},
	"boolean": {
		"title": "Yes or no?",
		"bubble": "Whee! A Boolean remembers yes or no.\ntrue means yes. false means no.\nIF you hold me, THEN held is true!",
		"body": "Am I being held? That question has two answers.\nHold me: true, or yes.\nLet go: false, or no.",
		"code": "IF held: true\nIF let go: false",
		"question": "A Boolean can remember...",
		"choices": [
			"true or false",
			"Only hats",
			"Three different answers"
		],
		"why": "true means yes. false means no. A Boolean has these two choices!"
	},
	"vectors": {
		"title": "Where am I?",
		"bubble": "Two numbers tell my place.\nx goes left and right. y goes up and down.\nIF you move right, THEN x grows!",
		"body": "A position tells where Pip is.\nA vector holds two numbers together: x and y.\nOn this screen, right makes x bigger. Down makes y bigger.",
		"code": "move right: bigger x\nmove down: bigger y",
		"question": "Which number changes when Pip moves right?",
		"choices": [
			"x",
			"Only y",
			"Neither"
		],
		"why": "x tells left and right. Moving right makes x bigger!"
	},
	"gravity": {
		"title": "A soft landing",
		"bubble": "IF you let go, THEN I fall.\nIF I reach the floor, THEN I stop.\nPlop! A soft landing.",
		"body": "Gravity pulls me down.\nThe game keeps checking: have I reached the floor?\nThat check helps me stop safely.",
		"code": "IF in the air: fall\nIF at the floor: stop",
		"question": "What tells Pip to stop falling?",
		"choices": [
			"Reaching the floor",
			"Getting a hat",
			"Opening the Shop"
		],
		"why": "The game checks for the floor. At the floor, Pip stops falling."
	},
	"condition": {
		"title": "Snack or wait?",
		"bubble": "A condition is a yes-or-no check.\nIF I have tummy room AND you have a treat, THEN I can eat!",
		"body": "AND means both things must be yes.\nTummy room? Treat ready?\nBoth yes: munch!\nOne no: wait.",
		"code": "IF room AND treat:\n    eat one treat",
		"question": "When can Pip eat?",
		"choices": [
			"Room AND a treat",
			"An empty pouch",
			"A full tummy only"
		],
		"why": "Both checks need yes: room in my tummy AND a treat for me!"
	},
	"functions": {
		"title": "My little recipe",
		"bubble": "A function is a named recipe.\nMy snack recipe does little steps.\nIF you offer food, THEN I use that recipe!",
		"body": "A recipe keeps steps together.\nThe feed recipe takes one treat, fills my tummy, and starts chewing.\nWe can use it again!",
		"code": "recipe feed:\n    take one treat\n    fill tummy\n    chew",
		"question": "What is a function like?",
		"choices": [
			"A recipe of steps",
			"A lost snack",
			"A random hat"
		],
		"why": "A function groups steps under one name. We can use the recipe again!"
	},
	"loops": {
		"title": "Munch again!",
		"bubble": "A loop does an action again.\nIF I am chewing, THEN chew again.\nMunch, munch, munch!",
		"body": "Repeat means do it again.\nMy chewing repeats for a little while.\nWhen snack time ends, the loop stops.",
		"code": "WHILE chewing:\n    chew again",
		"question": "What does a loop do?",
		"choices": [
			"Repeats an action",
			"Always buys a hat",
			"Forgets every step"
		],
		"why": "A loop repeats. Munch again, until snack time ends!"
	},
	"timer": {
		"title": "Tick, tick!",
		"bubble": "A timer counts time. Tick, tick!\nIF quiet time is up, THEN I wash my face.",
		"body": "The timer waits while I am quiet.\nWhen enough time passes, I groom.\nThen the timer starts over.",
		"code": "IF quiet timer is ready:\n    wash face",
		"question": "What does Pip's timer count?",
		"choices": [
			"Time",
			"Hats",
			"Berries"
		],
		"why": "A timer counts time. Time is up? Wash my face!"
	},
	"and": {
		"title": "Both must be yes",
		"bubble": "AND means both!\nIF a find is a berry AND red, THEN basket.\nA red button is not a berry!",
		"body": "Ask two little questions.\nIs it a berry? Is it red?\nBoth yes: into the basket.\nOne no: leave it.",
		"code": "IF berry AND red:\n    basket\nELSE: leave",
		"question": "A red button: basket or leave?",
		"choices": [
			"Leave it",
			"Basket",
			"Eat it"
		],
		"why": "Red? Yes. Berry? No. AND needs both, so leave it!"
	},
	"repeat": {
		"title": "Hop to the star",
		"bubble": "Count my hops!\nIF we repeat 3 times, THEN I hop 3 times.\nOne, two, three!",
		"body": "Pick how many hops to repeat.\nOne repeat makes one hop.\nTry your number. Did Pip reach the star?\nYou can change it and try again.",
		"code": "REPEAT 3 times:\n    hop right",
		"question": "How many hops does REPEAT 3 make?",
		"choices": [
			"3",
			"1",
			"0"
		],
		"why": "Three repeats make three hops!"
	},
	"or": {
		"title": "Either one works",
		"bubble": "OR means either one can be yes.\nIF berry OR seed, THEN basket!",
		"body": "A berry counts. A seed counts too.\nOne yes is enough for OR.\nA pebble is neither. Leave it!",
		"code": "IF berry OR seed: basket",
		"question": "Does a seed pass berry OR seed?",
		"choices": [
			"Yes",
			"No",
			"Only if red"
		],
		"why": "Yes! A seed passes one check. OR needs at least one yes."
	},
	"not": {
		"title": "Turn the answer around",
		"bubble": "NOT flips yes and no.\nIF NOT a button, THEN it is something else!",
		"body": "Button? Yes. NOT button? No!\nPebble? NOT button is yes.\nNOT reverses the answer.",
		"code": "button: yes\nNOT button: no",
		"question": "If button is true, NOT button is...",
		"choices": [
			"false",
			"true",
			"A berry"
		],
		"why": "NOT flips true to false, and false to true."
	},
	"comparison": {
		"title": "Compare two numbers",
		"bubble": "A comparison checks two numbers.\nIs 4 less than 5? Yes!\nThe < sign means less than.",
		"body": "Fullness below 95 leaves room for a snack.\n94 < 95: yes.\n95 < 95: no. Equal is not less!",
		"code": "94 < 95: yes\n95 < 95: no",
		"question": "Is 95 less than 95?",
		"choices": [
			"No",
			"Yes",
			"Always"
		],
		"why": "They are equal. Less than needs a smaller number."
	},
	"step_size": {
		"title": "Bigger hops",
		"bubble": "IF each repeat adds 2, THEN 3 repeats add 6.\nCount: 2, 4, 6!",
		"body": "Our starting number matters too.\nStart at 1. Add 2 three times.\n1, 3, 5, 7. We finish at 7!",
		"code": "start: 1\nadd 2, three times\nfinish: 7",
		"question": "Start at 1. Add 2 three times. Finish at...",
		"choices": [
			"7",
			"3",
			"6"
		],
		"why": "1 to 3, then 5, then 7. Three little changes!"
	},
	"elif": {
		"title": "Ask the next question",
		"bubble": "ELIF means else if.\nNo to the first check? Ask the next!",
		"body": "IF red berry: snack.\nELIF another berry: save it.\nELSE: leave it.\nUse the first yes. Skip the other choices.",
		"code": "IF red berry: snack\nELIF berry: save\nELSE: leave",
		"question": "A red berry passes the first check. What runs?",
		"choices": [
			"Snack only",
			"Snack and save",
			"Leave only"
		],
		"why": "The first yes wins. Snack, then skip the other choices!"
	},
	"parameters": {
		"title": "Choose the amount",
		"bubble": "A parameter is a recipe input.\nIt lets us choose an amount!",
		"body": "Our add-seeds recipe uses an amount.\nGive it 2: add 2 seeds.\nGive it 3: add 3 seeds.\nSame recipe, new number!",
		"code": "add seeds, amount 3:\n    add 3 seeds",
		"question": "What changes with a new amount?",
		"choices": [
			"How many seeds we add",
			"The recipe disappears",
			"Nothing"
		],
		"why": "The recipe uses the number we give it."
	},
	"accumulator": {
		"title": "Keep a total",
		"bubble": "An accumulator keeps a growing total.\nAdd more seeds. Keep the earlier ones!",
		"body": "Start with 0. Add 3 four times.\n3, 6, 9, 12!\nDo not empty the jar between turns.",
		"code": "total: 0\nREPEAT 4: add 3",
		"question": "Add 3 four times. What is the total?",
		"choices": [
			"12",
			"3",
			"4"
		],
		"why": "3 + 3 + 3 + 3 makes 12!"
	},
	"grouping": {
		"title": "Keep checks together",
		"bubble": "Brackets can group checks.\nIF (berry OR seed) AND NOT spoiled, THEN basket.",
		"body": "First: is it food?\nNext: is it fresh?\nA spoiled berry is food, but not fresh. Leave it!",
		"code": "IF (berry OR seed)\nAND NOT spoiled: basket",
		"question": "Should a spoiled berry go in?",
		"choices": [
			"No",
			"Yes",
			"Always"
		],
		"why": "It is food, but NOT spoiled is no. Both parts must be yes."
	},
	"lists": {
		"title": "A line of numbers",
		"bubble": "A list keeps things in order.\nAn index tells a place in the list.\nThe first index is 0!",
		"body": "Try the list [2, 3, 2].\nIndex 0 holds 2.\nIndex 1 holds 3.\nWe count places from zero.",
		"code": "list: [2, 3, 2]\nindex 1 holds: 3",
		"question": "What is at index 1 in [2, 3, 2]?",
		"choices": [
			"3",
			"2",
			"1"
		],
		"why": "Index 1 is the second place. It holds 3!"
	},
	"nested": {
		"title": "A loop in a loop",
		"bubble": "Nested loops are loops inside loops.\nTwo groups of three hops make six!",
		"body": "Each outside repeat runs all the inside repeats.\nThree hops. Then three more.\nThe inside count starts again each time.",
		"code": "REPEAT 2 groups:\n    REPEAT 3 hops",
		"question": "Two groups of three hops make...",
		"choices": [
			"6",
			"5",
			"3"
		],
		"why": "3 + 3 makes 6 hops!"
	},
	"limits": {
		"title": "Check the edge",
		"bubble": "A boundary is where a rule changes.\nTry just below it, on it, and above it!",
		"body": "For fullness < 95, test 94, 95, and 96.\n94: snack room!\n95 and 96: wait.",
		"code": "test 94, 95, 96",
		"question": "Which numbers test the edge at 95?",
		"choices": [
			"94, 95, 96",
			"10, 20, 30",
			"Only 0"
		],
		"why": "Those numbers test just below, at, and above 95."
	},
	"picnic": {
		"title": "Catch a snack!",
		"bubble": "Your move is input. My move is output!\nIF my basket catches a berry, THEN add one snack.",
		"body": "Input goes in: move the mouse or press a key.\nOutput comes out: Pip moves!\nCatch a snack to grow our number. Miss one? Try the next!",
		"code": "IF move: move basket\nIF catch: add 1 snack",
		"question": "What is input in Picnic Catch?",
		"choices": [
			"Your mouse move",
			"The snack count",
			"Pip's smile"
		],
		"why": "Your move is input. The game moves the basket back!"
	},
	"lab_sequence": {
		"title": "My first little plan",
		"bubble": "A program is a plan of steps.\nRun means try the plan. Step tries one part.\nMove first. THEN feed me!",
		"body": "Order matters!\nMy berry is one step away.\nStep right. Offer the berry.\nFeeding before moving will not work. Try changing the order!",
		"code": "step right\nTHEN offer berry",
		"question": "What should Pip do first?",
		"choices": [
			"Step to the berry",
			"Feed from far away",
			"Buy a hat"
		],
		"why": "Move to the berry BEFORE offering it."
	},
	"lab_repeat": {
		"title": "Three little steps",
		"bubble": "A loop repeats a step.\nREPEAT 3 means do it three times.\nTHEN offer my berry!",
		"body": "My berry is three tiles away.\nOne step is not enough.\nRepeat three steps. Then feed me.\nCount with Pip: one, two, three!",
		"code": "REPEAT 3: step right\nTHEN offer berry",
		"question": "How can Pip take three steps?",
		"choices": [
			"REPEAT 3",
			"REPEAT 1",
			"Do not move"
		],
		"why": "Three repeats make three steps. Then comes the berry!"
	},
	"lab_branch": {
		"title": "Hungry or happy?",
		"bubble": "A condition asks yes or no.\nIF hungry, THEN feed. ELSE pet!\nELSE means otherwise.",
		"body": "Below 60 means hungry here.\nFullness 30? Yes: feed.\nFullness 80? No: pet.\nTry the same plan with both visits.",
		"code": "IF hungry: feed\nELSE: pet",
		"question": "Fullness is 80. What should Pip do?",
		"choices": [
			"Get a pet",
			"Eat anyway",
			"Do both"
		],
		"why": "80 is not below 60. Hungry is no, so use ELSE: pet."
	},
	"lab_checks": {
		"title": "Check both things",
		"bubble": "AND means both checks must be yes.\nIF hungry AND berry ready, THEN feed.",
		"body": "Hungry but no berry? Pet instead!\nBerry ready but not hungry? Pet instead!\nBoth yes? Munch!",
		"code": "IF hungry AND berry:\n    feed\nELSE: pet",
		"question": "Hungry with no berry: what next?",
		"choices": [
			"Pet Pip",
			"Feed anyway",
			"Both"
		],
		"why": "Both checks must be yes to feed. No berry means use ELSE: pet."
	},
	"lab_counter": {
		"title": "Fill my seed jar",
		"bubble": "A variable remembers a number.\nIF we add seeds, THEN that number grows!",
		"body": "Start the jar at zero.\nAdd 2 three times: 2, 4, 6.\nKeep the earlier seeds. Our goal is 6!",
		"code": "seeds: 0\nREPEAT 3: add 2",
		"question": "Start at 0. Add 2 three times. Total?",
		"choices": [
			"6",
			"2",
			"3"
		],
		"why": "2 + 2 + 2 makes 6 seeds!"
	},
	"lab_recipe": {
		"title": "A cozy recipe",
		"bubble": "A function is a named recipe.\nDefine means name its steps. Call means use it!",
		"body": "First define cozy: feed, then pet.\nMove to the berry. Then call cozy.\nNaming a recipe does not run it. We must use it!",
		"code": "define cozy: feed, pet\nmove to berry\ncall cozy",
		"question": "What makes a named recipe run?",
		"choices": [
			"Calling it",
			"Only naming it",
			"Hiding it"
		],
		"why": "Define saves the recipe. Call runs its steps!"
	},
	"lab_parameter": {
		"title": "A recipe input",
		"bubble": "A parameter is a recipe input.\nChoose how many seeds the recipe adds!",
		"body": "The pack recipe uses an amount.\nCall it with 3, then 3 again.\nThe jar holds 6!\nOne recipe can use different numbers.",
		"code": "pack(3)\npack(3)",
		"question": "Pack 3, then 3. How many seeds?",
		"choices": [
			"6",
			"2",
			"4"
		],
		"why": "The recipe adds each amount: 3 + 3 = 6."
	},
	"lab_list": {
		"title": "Visit every number",
		"bubble": "A list keeps numbers in order.\nFOR EACH means visit every one.",
		"body": "Our list is [1, 2, 3].\nAdd 1, then 2, then 3.\nNow the jar has 6!\nVisit each number once.",
		"code": "FOR EACH in [1, 2, 3]:\n    add that number",
		"question": "What does FOR EACH visit?",
		"choices": [
			"Every list item",
			"Only the first",
			"No items"
		],
		"why": "FOR EACH visits every item, one at a time."
	},
	"lab_nested": {
		"title": "Little groups",
		"bubble": "A nested loop is a loop inside a loop.\nTwo groups of three seeds make six!",
		"body": "Each outside repeat starts all three inside repeats.\nFirst group: 3 seeds.\nNext group: 3 more.\nTotal: 6!",
		"code": "REPEAT 2 groups:\n    REPEAT 3: add 1",
		"question": "Two groups of three seeds make...",
		"choices": [
			"6",
			"5",
			"3"
		],
		"why": "Two complete groups: 3 + 3 = 6!"
	},
	"snack_jam": {
		"title": "Tap and dance!",
		"bubble": "Your tap is input. My dance is output!\nIF you tap the right snack on time, THEN it counts.\nMiss one? Try the next!",
		"body": "Input is what you do. Output is what the game does back.\nTap once when a snack reaches its ring.\nHits in a row make a combo. Let's dance!",
		"code": "IF right tap on time:\n    add hit and dance",
		"question": "What is input in Snack Jam?",
		"choices": [
			"Your tap",
			"Pip dancing",
			"The score"
		],
		"why": "Your tap is input. My dance and the score are output!"
	}
}
const COLLEGE = {
	"idle": "State means the information the game remembers now. A branch is one possible path through a condition. Only the matching path runs.",
	"events": "An event handler is a function that reacts to an event. The head-click handler updates happiness, then starts the visible reaction.",
	"variables": "Assignment stores a value. happiness += 8 means read its old value, add 8, and store the result. A limit keeps the value at or below 100.",
	"boolean": "A Boolean has exactly two values. Here is_held is state: the game stores whether carrying is active, then uses it to choose behavior.",
	"vectors": "A coordinate is one position number. A position vector groups x and y. Subtracting old position from new position gives movement in each direction.",
	"gravity": "Velocity means how quickly position changes. Gravity changes vertical velocity over time. A floor check stops downward movement at the floor.",
	"condition": "A guard is a check that must pass before an action. Feeding checks fullness, inventory, and whether chewing has finished before changing any values.",
	"functions": "A function call asks a named group of instructions to run. Keeping feeding steps together means each valid call applies the same checks and updates.",
	"loops": "An iteration is one repeat. A stopping condition is the check that ends repetition. Chewing ends when its remaining time reaches zero.",
	"timer": "delta is the elapsed time since the last frame, or screen update. Adding elapsed time keeps the timer based on seconds rather than how many frames ran.",
	"and": "A truth table lists each pair of true/false inputs. AND returns true only for the pair true, true.",
	"repeat": "A loop count controls how many iterations, or repeats, run. Compare the expected number of steps with the observed number to find a counting error.",
	"or": "Inclusive OR is true when one or both inputs are true. It is false only when both inputs are false.",
	"not": "Negation means reversing a Boolean. NOT true becomes false; NOT false becomes true. It reverses the answer, not the object being checked.",
	"comparison": "The operators < and > compare order; == compares equality. Assignment uses = to store a value instead of asking a question.",
	"step_size": "After n repeats, the result is start + n × step size. This describes repeated addition; both the starting value and each change affect the result.",
	"elif": "Conditions are checked in order. The first matching branch runs and the remaining branches are skipped, even if another condition would also be true.",
	"parameters": "A parameter is the input name in a function definition. An argument is the actual value supplied when calling it, such as 3 in add_seeds(3).",
	"accumulator": "Initialization sets a starting value. Initialize the total before the loop; resetting it inside the loop would discard previous additions.",
	"grouping": "Parentheses make the intended grouping explicit. Evaluate the food group, then require freshness with AND. Both parts must pass.",
	"lists": "An index identifies a position, not the value at that position. A three-item list has valid indexes 0, 1, and 2.",
	"nested": "For fixed counts, total inner executions equal outer count × inner count. Each new outer iteration runs the entire inner loop again.",
	"limits": "Boundary testing checks just below, at, and just above the point where a rule changes. It can reveal a mistaken < versus <= comparison.",
	"picnic": "The input changes basket position; a catch check updates stored counters. A missed snack resets consecutive catches, while the collected total stays.",
	"lab_sequence": "A precondition is something that must already be true for an action to work. Feeding requires standing at the berry. Changing instruction order changes that precondition.",
	"lab_repeat": "A repeat block runs its contained instruction the selected number of times. The feed instruction after it runs once, after all movement finishes.",
	"lab_branch": "A test case is a starting situation and its expected result. Both visits run the same instructions from separate starting states.",
	"lab_checks": "AND expresses that both preconditions are required. OR would allow feeding with a missing berry or without hunger, so the separate visits expose that mistake.",
	"lab_counter": "The counter is a variable storing a number. Updates keep previous additions; initialization happens once before executing the program.",
	"lab_recipe": "Definition stores the function steps; invocation, another word for a call, executes them. Calling before defining is rejected in this lab.",
	"lab_parameter": "The parameter names a replaceable input. Each call supplies an argument; both calls share the function instructions while using different amounts.",
	"lab_list": "Iteration means visiting each item in order. The program must process each value, rather than only arriving at the same final total another way.",
	"lab_nested": "Execution order matters: every outer repeat completes all inner repeats before the next outer repeat begins. Trace the individual additions to check the total.",
	"snack_jam": "A timing window is the allowed difference between note time and tap time. A hit requires both the matching lane and an available note within that window."
}
