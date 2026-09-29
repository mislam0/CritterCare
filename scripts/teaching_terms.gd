extends RefCounted
## One vocabulary for every teaching surface. Dialogue stays plain text.
## Whole-word matches protect names such as gift, floor, and is_held.
## Everyday and/or/not/for/in stay quiet in prose; capitals mark logic words.

const INK = "24475c"
const PAPER = "fff0aa"
const CONCEPTS = "if|then|else|elif|booleans?|bool|true|false|variables?|conditions?|conditionals?|loops?|nested loops?|repeats?|repeated|repeating|inputs?|outputs?|functions?|parameters?|arguments?|define|definitions?|calls?|accumulators?|running total|step sizes?|comparisons?|operators?|logical operators?|boolean logic|events?|signals?|timers?|vectors?|velocity|gravity|sequences?|sequencing|instructions?|programs?|programming|debug|debugging|bugs?|lists?|arrays?|indexes|indices|index|indexing|boundaries|boundary checks?|limits?|clamping|clamp|grouped checks|grouping|return values?"
const EXPLICIT = "AND|OR|NOT|FOR|EACH|WHILE|DEFINE|CALL|RETURN"
const CODE_WORDS = "and|or|not|for|in|while|func|var|const|return|range|clampf|clampi|Vector2"
static var prose_pattern: RegEx
static var code_pattern: RegEx

static func matches(value: String, code_mode: bool = false) -> Array[RegExMatch]:
	if prose_pattern == null:
		prose_pattern = RegEx.new()
		prose_pattern.compile("\\b(?:(?i:" + CONCEPTS + ")|" + EXPLICIT + ")\\b|<=|>=|==|!=|[<>]")
		code_pattern = RegEx.new()
		code_pattern.compile("\\b(?:(?i:" + CONCEPTS + ")|" + EXPLICIT + "|" + CODE_WORDS + ")\\b|<=|>=|==|!=|\\+=|-=|[<>=]")
	return (code_pattern if code_mode else prose_pattern).search_all(value)

static func escape(value: String) -> String:
	# Escape only the opening bracket, once. Even literal BBCode in a saved
	# quote or a list example must remain visible, never execute as formatting.
	return value.replace("[", "[lb]")

static func format_words(value: String, code_mode: bool = false) -> String:
	var result = ""
	var cursor = 0
	for found in matches(value, code_mode):
		result += escape(value.substr(cursor, found.get_start()-cursor))
		result += "[bgcolor=#%s][color=#%s][b]%s[/b][/color][/bgcolor]" % [PAPER, INK, escape(found.get_string())]
		cursor = found.get_end()
	return result + escape(value.substr(cursor))
