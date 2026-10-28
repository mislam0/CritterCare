extends RefCounted
## Shared lesson vocabulary and a lexical GDScript colorizer.
## Authored words and saved dialogue stay plain; only this renderer emits BBCode.
## Palette uses dark colors against the game's cream/light teaching panels.

const COLORS = {
	"control":"7040a0", "logic":"2459a6", "data":"176b63",
	"functions":"963c78", "structure":"92501c", "events":"806115", "movement":"4d5797",
	"boundaries":"52652e", "debug":"5e5968", "operators":"53616b",
	"keywords":"7040a0", "variables":"2459a6", "calls":"92501c",
	"types":"176b63", "strings":"326b38", "numbers":"2459a6",
	"literals":"2459a6", "comments":"657065"
}
const CATEGORY_NAMES = {
	"control":"Control flow and repetition", "logic":"Logic and comparisons",
	"data":"Variables and collections", "functions":"Functions",
	"structure":"Program structure", "events":"Events and timing",
	"movement":"Movement and quantities", "boundaries":"Limits and boundaries",
	"debug":"Debugging", "operators":"Operators and punctuation"
}
## Internal word bank only. Category names and patterns are never shown as UI.
## Red is reserved for incorrect outcome feedback, not teaching vocabulary.
const VOCABULARY = {
	"control":"if|then|else|elif|nested loops?|loops?|repeats?|repeated|repeating",
	"logic":"boolean logic|logical operators?|grouped checks|grouping|booleans?|bool|true|false|conditionals?|conditions?|comparisons?|operators?",
	"data":"running total|variables?|accumulators?|lists?|arrays?|indexes|indices|indexing|index",
	"functions":"return values?|functions?|parameters?|arguments?|definitions?|define|calls?",
	"structure":"sequencing|sequences?|instructions?|programming|programs?",
	"events":"inputs?|outputs?|events?|signals?|timers?",
	"movement":"step sizes?|vectors?|velocity|gravity",
	"boundaries":"boundary checks?|boundaries|boundary|limits?|clamping|clamp",
	"debug":"debugging|debug|bugs?"
}
const EXPLICIT_WORDS = {
	"control":"FOR|EACH|WHILE", "logic":"AND|OR|NOT",
	"functions":"DEFINE|CALL|RETURN"
}
const CODE_PATTERN = "(?<strings>\"\"\"[\\s\\S]*?(?:\"\"\"|\\z)|'''[\\s\\S]*?(?:'''|\\z)|\"(?:\\\\[^\\n]|[^\"\\\\\\n])*(?:\"|$)|'(?:\\\\[^\\n]|[^'\\\\\\n])*(?:'|$))|(?<comments>#[^\\n]*)|(?<numbers>(?<![\\w.])(?:0[xX][0-9a-fA-F_]+|0[bB][01_]+|(?:[0-9][0-9_]*(?:\\.[0-9_]*)?|\\.[0-9][0-9_]*)(?:[eE][+-]?[0-9_]+)?)(?!\\w))|(?<identifier>\\b[A-Za-z_][A-Za-z_0-9]*\\b)|(?<operators>==|!=|<=|>=|\\+=|-=|\\*=|/=|:=|->|\\*\\*|<<|>>|//|&&|\\|\\||[+*/%<>=!&|^~:.,;(){}\\[\\]\\\\-])"
const KEYWORDS = ["if", "elif", "else", "for", "in", "while", "and", "or", "not", "func", "var", "const", "return", "break", "continue", "pass", "match", "when", "class", "class_name", "extends", "signal", "static", "await", "self", "super", "assert", "breakpoint", "is", "as", "enum"]
const TYPES = ["bool", "int", "float", "String", "StringName", "Vector2", "Vector2i", "Vector3", "Vector3i", "Vector4", "Vector4i", "Color", "Array", "Dictionary", "Callable", "Signal", "Node", "Node2D", "Control", "Object", "Variant", "Rect2", "PackedStringArray", "void"]
const RULE_KEYWORDS = ["IF", "THEN", "ELSE", "ELIF", "AND", "OR", "NOT", "FOR", "EACH", "WHILE", "REPEAT", "DEFINE", "CALL", "RETURN"]
static var prose_pattern: RegEx
static var code_pattern: RegEx

static func matches(value: String, code_mode: bool = false) -> Array[RegExMatch]:
	if prose_pattern == null:
		prose_pattern = RegEx.new()
		var patterns: PackedStringArray = []
		for category in VOCABULARY:
			var words = "(?i:" + VOCABULARY[category] + ")"
			if EXPLICIT_WORDS.has(category): words += "|" + EXPLICIT_WORDS[category]
			patterns.append("(?<%s>\\b(?:%s)\\b)" % [category,words])
		patterns.append("(?<operators><=|>=|==|!=|[<>])")
		prose_pattern.compile("|".join(patterns))
		code_pattern = RegEx.new()
		code_pattern.compile(CODE_PATTERN)
	return (code_pattern if code_mode else prose_pattern).search_all(value)

static func token_category(found: RegExMatch, value: String, code_mode: bool = false) -> String:
	if not code_mode:
		for category in CATEGORY_NAMES:
			if found.get_start(category) >= 0:
				return category
		return "operators"
	for category in ["strings", "comments", "numbers", "operators"]:
		if found.get_start(category) >= 0:
			return category
	var word = found.get_string()
	if word in ["true", "false", "null", "PI", "TAU", "INF", "NAN"]:
		return "literals"
	# Members named like types/keywords are still member identifiers.
	var before = value.substr(0, found.get_start()).strip_edges()
	if not before.ends_with("."):
		# Starter lessons use uppercase plain-word rules rather than GDScript.
		if word in KEYWORDS or word in RULE_KEYWORDS:
			return "keywords"
		if word in TYPES:
			return "types"
	var after = value.substr(found.get_end()).strip_edges()
	return "calls" if after.begins_with("(") else "variables"

static func escape(value: String) -> String:
	# Literal brackets, including saved BBCode, must never become formatting.
	return value.replace("[", "[lb]")

static func format_words(value: String, code_mode: bool = false) -> String:
	var result = ""
	var cursor = 0
	for found in matches(value, code_mode):
		result += escape(value.substr(cursor, found.get_start()-cursor))
		var category = token_category(found, value, code_mode)
		result += "[color=#%s]%s[/color]" % [COLORS[category], escape(found.get_string())]
		cursor = found.get_end()
	return result + escape(value.substr(cursor))
