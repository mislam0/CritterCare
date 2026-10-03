extends RefCounted
## Audience wording; game rules and rhythm modes are separate.
const COPY = {
	"jam_controls": [
		"Tap A, S, or D.\nTap when a snack reaches its ring!",
		"Tap the matching A / S / D key or pad when the snack reaches its ring.",
		"Tap the matching lane as its snack reaches the ring. Each note accepts one hit."
	],
	"jam_ready": [
		"Try a pad. Then press Start song!",
		"Try a pad, choose a rhythm mode, then start the song.",
		"Preview pads, select a rhythm mode, then start. Timing tolerance means how close each tap must be."
	],
	"jam_playing": [
		"One tap per snack. Keep dancing!",
		"Tap once per snack. A combo counts hits in a row.",
		"Each valid hit adds to the combo, the number of consecutive hits. A miss resets it."
	],
	"jam_miss": [
		"Oops! Try the next snack.",
		"Missed one. Try the next; earlier hits stay.",
		"That note passed its timing window. The combo restarts; earlier hits stay."
	],
	"jam_extra": [
		"Wait for a snack. Tap just once!",
		"Tap once when a snack reaches its ring. Extra taps reset the combo.",
		"That tap matched no available note. Extra taps reset the combo and lower final accuracy."
	],
	"jam_restart": [
		"Let's try again! Finish the song for gold.",
		"A fresh try. Finish for gold; 70% accuracy earns treats.",
		"This round starts at zero. Finish for gold; 70% accuracy earns treats."
	],
	"jam_pause": [
		"Music is waiting!\nPress Resume or Space to play again.",
		"Music and snacks are paused. Resume gives a three-beat lead-in.",
		"Music and note timing are paused together. Resume continues after a three-beat lead-in."
	],
	"picnic_ready": [
		"Press Start picnic. Let's catch snacks!",
		"Press Start picnic, then move under falling snacks.",
		"Start the round, then position the basket under falling snacks."
	],
	"picnic_start": [
		"Move under a berry. Catch it!",
		"IF the basket catches a snack THEN the count goes up.",
		"Input moves the basket. A catch check increases the stored snack count."
	],
	"picnic_miss": [
		"Missed it! Try the next berry.",
		"Missed one. The streak restarts, but your snacks stay.",
		"Missed snack: streak resets to 0. Collected snacks stay."
	],
	"picnic_leaf": [
		"Oops, a leaf! Let leaves fall.",
		"That is a leaf. Let it pass to keep your streak.",
		"Leaf caught: streak resets. Snacks and gold stay."
	],
	"picnic_dodge": [
		"Good! Let the leaf fall.",
		"Good choice: leave the leaf and keep the streak.",
		"Leaf left: your streak and collected snacks stay."
	],
	"lab_order": [
		"Tap blocks. Use ↑ and ↓ to move them.",
		"Click blocks to add them. Drag or use arrows to reorder.",
		"Arrange instructions from top to bottom. The program follows that order."
	],
	"lab_edit": [
		"Tap blocks. Make a plan from top to bottom!",
		"Add blocks, then predict what the program will do.",
		"A program is a list of instructions. Build it, predict the result, then test it."
	],
	"lab_stopped": [
		"Stopped! Change a block and try again.",
		"Change any blocks, then run from the start. Trying costs nothing.",
		"Execution has stopped. Revise the instructions and test from the starting state."
	],
	"lab_retry": [
		"Let's fix the plan! Try Hint.",
		"Debug means find and fix a mistake. Edit a block or ask for a hint.",
		"Compare your prediction with the result. The trace, a step-by-step record, helps find a mistake."
	],
	"lab_test": [
		"Watch Pip follow your plan!",
		"Watch the highlighted block. Pause, Step, or Stop to edit.",
		"The highlighted block is executing now. Pause or Step to inspect each action."
	],
	"lab_safe": [
		"Practice Pip. Your treats stay safe!",
		"Practice treats; your pouch stays the same.",
		"Practice state; real inventory stays unchanged."
	]
}
const TOUR_KIDS = {
	"welcome": "Hi! I'm Pip. Let's play!\nClick Let's begin. Follow the green arrow.",
	"pet": "Boop my head!\nIF you tap me, THEN I feel happy.",
	"carry": "Hold me. Move me. Let go!\nWhee! I'll land softly.",
	"needs": "Fullness is my tummy number.\nHappiness is my happy number.\nGOLD buys fun things!",
	"feed": "Click Feed Critter.\nLet's open your snack pouch!",
	"snack": "Click Offer one.\nOne treat for Pip. Munch!",
	"speech": "Read my little idea.\nBright words are coding words.\nClick Next, then Done. Take your time!",
	"knowledge": "Click Knowledge.\nIt's our book of things we learned!",
	"book": "Pip says keeps my words.\nScroll to see more.\nRead with Pip lets us read again!",
	"shop": "Click Shop.\nLet's look at hats and room things!",
	"catalog": "Pet things or room things? Pick a tab!\nBuy means keep it. Equip means put it on.\nJust looking is free!",
	"settings": "Click the three dots.\nWe can change sound and Game level here.",
	"level": "Pick your Game level.\nWe all start small. Bigger levels add more later.\nYou can change it anytime!",
	"games": "Click Games / Quizzes.\nLet's play for gold and treats!",
	"activities": "Try a game!\nSort snacks, hop, build, or dance.\nClick Picnic Catch, or Finish tour."
}
static func line(key: String, level: String) -> String:
	return COPY[key][2 if level == "college" else (1 if level == "middle" else 0)]
