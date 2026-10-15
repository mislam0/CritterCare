extends RefCounted
## Offline name-only moderation. Never filters programming lessons or ordinary UI.
## Bounded normalization + dictionary/trie matching; no remote calls or logging.
const Data = preload("res://data/moderation/lexicon.gd")
const LIMIT = 256
const LEET = {"0":"o","1":"il","2":"z","3":"e","4":"a","5":"s","6":"g","7":"t","8":"b","9":"g"}
static var _ready: bool = false
static var _words: Dictionary = {}
static var _word_repeats: Dictionary = {}
static var _friendly: Dictionary = {}
static var _inner: Dictionary = {}
static var _all_terms: Dictionary = {}
static var _repeated: Dictionary = {}
static var _format: RegEx
static var _tokens: RegEx

static func _init_data() -> void:
	if _ready: return
	_format = RegEx.new()
	_format.compile("[^\\p{L}\\p{M}\\p{N} '\\-]")
	_tokens = RegEx.new()
	_tokens.compile("[\\p{L}\\p{N}]+")
	for term in Data.WORDS:
		_words[term] = true
		_insert(_all_terms,term)
	for term in Data.WORD_REPEATS: _word_repeats[term] = true
	for term in Data.FRIENDLY: _friendly[term] = true
	for term in Data.INNER: _insert(_inner,term)
	for term in Data.REPEATED: _insert(_repeated,term)
	_ready = true

static func _insert(tree: Dictionary, word: String) -> void:
	var branch = tree
	for letter in word:
		if not branch.has(letter): branch[letter] = {}
		branch = branch[letter]
	branch["!"] = true

static func fold(value: String) -> String:
	var result = ""
	for letter in value:
		result += str(Data.FOLD.get(str(letter.unicode_at(0)),letter))
	return result

static func _joined(value: String) -> String:
	var result = ""
	for token in _tokens.search_all(value): result += token.get_string()
	return result

static func _collapse(value: String) -> String:
	var result = ""
	var previous = ""
	for letter in value:
		if letter != previous: result += letter
		previous = letter
	return result

static func _options(letter: String) -> String:
	return letter + str(LEET.get(letter,""))

static func _contains(tree: Dictionary, value: String) -> bool:
	# Alternatives branch through existing trie edges instead of generating an
	# exponential number of leetspeak strings (1 can be i OR l).
	for start in range(value.length()):
		var states = [tree]
		for position in range(start,value.length()):
			var next_states = []
			for state in states:
				for letter in _options(value[position]):
					if not state.has(letter): continue
					var branch: Dictionary = state[letter]
					if branch.has("!"): return true
					next_states.append(branch)
			states = next_states
			if states.is_empty(): break
	return false

static func _exact(value: String, repeated: bool = false) -> bool:
	var dictionary = _word_repeats if repeated else _words
	if dictionary.has(value): return true
	# Exact tokens use a small candidate set. Longer/combined evasions are
	# independently matched by the bounded trie above.
	var variants = [""]
	for original in value:
		var next = []
		for prefix in variants:
			for letter in _options(original):
				next.append(prefix+letter)
				if next.size() >= 128: break
			if next.size() >= 128: break
		variants = next
	for variant in variants:
		if dictionary.has(variant): return true
	return false

static func _bad_sequence(value: String) -> bool:
	# Reject any complete combination of listed terms, including short words
	# that cannot safely be treated as substrings of every ordinary name.
	if value.is_empty(): return false
	var reachable: Dictionary = {0:true}
	for start in range(value.length()):
		if not reachable.has(start): continue
		var states = [_all_terms]
		for position in range(start,value.length()):
			var next_states = []
			for state in states:
				for letter in _options(value[position]):
					if not state.has(letter): continue
					var branch: Dictionary = state[letter]
					if branch.has("!"):
						if position+1 == value.length(): return true
						reachable[position+1] = true
					next_states.append(branch)
			states = next_states
			if states.is_empty(): break
	return false

static func _unpad(value: String) -> String:
	var first = 0
	var last = value.length()
	while first < last and "x0123456789".contains(value[first]): first += 1
	while last > first and "x0123456789".contains(value[last-1]): last -= 1
	return value.substr(first,last-first)

static func _one_edit(a: String, b: String) -> bool:
	# For selected severe roots only. First letters must agree to avoid e.g.
	# treating every ordinary rhyme as profanity. Whitelisted names are whole names.
	if a.is_empty() or b.is_empty() or a[0] != b[0] or absi(a.length()-b.length()) > 1: return false
	var i = 0
	var j = 0
	var edits = 0
	while i < a.length() and j < b.length():
		if _options(a[i]).contains(b[j]):
			i += 1
			j += 1
			continue
		edits += 1
		if edits > 1: return false
		if a.length() > b.length(): i += 1
		elif a.length() < b.length(): j += 1
		elif i+1 < a.length() and j+1 < b.length() and a[i] == b[j+1] and a[i+1] == b[j]:
			i += 2
			j += 2
		else:
			i += 1
			j += 1
	return edits + (a.length()-i) + (b.length()-j) <= 1

static func accepts(value: String) -> bool:
	_init_data()
	if value.length() > LIMIT or _format.search(value) != null: return false
	for letter in value:
		var cp = letter.unicode_at(0)
		# Invisible variation selectors and the combining grapheme joiner are
		# marks, but have no place in a short pet name.
		if cp == 0x34f or (cp >= 0xfe00 and cp <= 0xfe0f) or (cp >= 0xe0100 and cp <= 0xe01ef): return false
	var normalized = fold(value)
	var joined = _joined(normalized)
	if _friendly.has(joined): return true
	if _bad_sequence(joined) or _bad_sequence(_unpad(joined)) or _contains(_inner,joined): return false
	var reversed = ""
	for letter in joined: reversed = letter + reversed
	if _bad_sequence(reversed) or _bad_sequence(_unpad(reversed)) or _contains(_inner,reversed): return false
	for token in _tokens.search_all(normalized):
		if _exact(token.get_string()): return false
	var collapsed = _collapse(joined)
	if collapsed != joined and (_exact(collapsed,true) or _contains(_repeated,collapsed)): return false
	for root in Data.FUZZY:
		for start in range(joined.length()):
			if joined[start] != root[0]: continue
			for length in range(maxi(3,root.length()-1),root.length()+2):
				if start+length <= joined.length() and _one_edit(joined.substr(start,length),root): return false
	return true
