extends RefCounted
## Display names are text, never node paths, save IDs, or code identifiers.
const DEFAULT = "Pip"
const MAX_LENGTH = 12
static var current: String = DEFAULT

static func clean(value: String) -> String:
	var allowed = RegEx.new()
	allowed.compile("[^\\p{L}\\p{M}\\p{N} '\\-]")
	var result = allowed.sub(value,"",true).strip_edges()
	while result.contains("  "): result = result.replace("  "," ")
	result = result.left(MAX_LENGTH).strip_edges()
	return DEFAULT if result.is_empty() else result

static func present(value: String) -> String:
	return value.replace("{pet_name}",current).replace("{PET_NAME}",current.to_upper())

static func resolve(value: Variant) -> Variant:
	if value is String: return present(value)
	if value is Array: return value.map(func(item): return resolve(item))
	if value is Dictionary:
		var result = value.duplicate()
		for key in result: result[key] = resolve(result[key])
		return result
	return value
