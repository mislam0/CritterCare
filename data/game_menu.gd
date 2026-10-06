extends RefCounted
## Menu copy only. The existing game controllers still own rules and rewards.
const ORDER = ["sort", "loop", "quiz", "picnic", "lab", "jam"]
const CARDS = {
	"sort": {
		"title":"Berry Detective", "icon":"berry", "color":"f5e7e5", "button":"PlaySort", "action":"Let's play",
		"descriptions":[
			"Basket or leave? Follow Pip's rule for 10 finds. Look at each berry or object and choose. Get 7 right to win treats. No hurry!",
			"Read Pip's rule, then choose where each find belongs. Practice IF / ELSE choices as you sort 10 finds. Get at least 7 right to win.",
			"Check each find against a condition, a yes-or-no question, then choose its matching action. Later stages combine checks and add choices. Get 7 of 10 right."
		],
		"reward":"Finish: gold · Win: treats too"
	},
	"loop": {
		"title":"Loop Garden", "icon":"paw", "color":"e8eddc", "button":"PlayLoop", "action":"Let's play",
		"descriptions":[
			"Help Pip hop to the star! Pick how many hops to repeat, then press Run. Try three little gardens. Miss the star? Change your number and try again!",
			"A loop repeats an action. Choose a repeat count and watch Pip move toward the star. Solve three gardens; you can change your number and retry for free.",
			"Predict a repeat count, run the loop, and compare its finish with the target. Three gardens practice repetition; later stages add starting values, bigger steps, and grouped repeats."
		],
		"reward":"Finish 3 gardens: gold + treats"
	},
	"quiz": {
		"title":"Pip's Pop Quiz", "icon":"book", "color":"f2eada", "button":"PlayQuiz", "action":"Start quiz",
		"descriptions":[
			"Try little questions about things Pip showed you! Tap one answer, then read his helpful explanation. There are up to 5 questions. Take your time!",
			"Answer up to 5 questions about lessons you have discovered. Choose one answer and read why it fits. A score of 60% or more earns a win.",
			"Recall up to 5 discovered ideas from your current stage. Choose an answer, then use the explanation to check your reasoning. Reach 60% correct to earn a win."
		],
		"reward":"Finish: gold · Win: treats too"
	},
	"picnic": {
		"title":"Picnic Catch", "icon":"basket", "color":"f5e5b7", "button":"PlayPicnic", "action":"Play Picnic Catch",
		"descriptions":[
			"Move Pip's basket with your mouse, arrows, or finger. Catch 10 falling snacks! Miss one? Try the next. Catch a few in a row for extra gold.",
			"Move the basket with mouse, touch, or arrow keys to catch 10 snacks. Keep catching in a row for bonus gold. Later stages add seeds and leaves to avoid.",
			"Steer the basket to collect 10 falling snacks. Consecutive catches earn a streak bonus; a miss keeps your collected snacks. Later stages add golden seeds and leaves to avoid."
		],
		"reward":"Finish: gold + bonuses + treats"
	},
	"lab": {
		"title":"Pip's Logic Lab", "icon":"code", "color":"e0eadb", "button":"PlayLogicLab", "action":"Open Logic Lab",
		"descriptions":[
			"Make a plan with blocks! Help Pip move and get a snack. Run plays your plan. Step shows one part. Fix it and try again to solve each puzzle!",
			"Arrange instruction blocks into a program, a plan for Pip. Run it or step through one action at a time. Solve puzzles using movement, choices, and repeats.",
			"Build a block program and test it on different starting visits. Watch Pip follow each instruction to find and fix mistakes. Later cards add reusable recipes and lists."
		],
		"reward":"Each first solution: 25 gold + 2 berries"
	},
	"jam": {
		"title":"Pip's Snack Jam", "icon":"music", "color":"eae1ee", "button":"PlaySnackJam", "action":"Play Snack Jam",
		"descriptions":[
			"Tap A, S, or D when snacks reach their rings. Or tap the pads! Pip dances to the song. Pick slow, steady, or lively beats. Finish for gold!",
			"Tap the matching A / S / D key or pad in time with the song. Hits in a row build a combo. Choose Chill, Standard, or Lively; finish for gold.",
			"Match each snack's lane and timing with A / S / D or the pads. Build consecutive hits for a combo. Rhythm modes are separate from Game level; timing earns bonus rewards."
		],
		"reward":"Finish: 20–40 gold · Timing: treats"
	}
}

static func description(id: String, level: String) -> String:
	return CARDS[id].descriptions[2 if level == "college" else (1 if level == "middle" else 0)]
