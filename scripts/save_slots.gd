extends RefCounted
## Manual snapshots live beside, and are independent from, the current autosave.
const SaveData = preload("res://scripts/save_data.gd")
const COUNT = 3
const LABEL_LENGTH = 24
var base_path: String = SaveData.SAVE_PATH

func slot_path(index: int) -> String:
	return "" if index < 0 or index >= COUNT else base_path + ".slot_%d.json" % (index + 1)

static func clean_label(value: String) -> String:
	if not SaveData.Names.Filter.accepts(value): return "My story"
	var allowed = RegEx.new()
	allowed.compile("[^\\p{L}\\p{M}\\p{N} '\\-]")
	var result = allowed.sub(value,"",true).strip_edges()
	while result.contains("  "): result = result.replace("  "," ")
	result = result.left(LABEL_LENGTH).strip_edges()
	if not SaveData.Names.Filter.accepts(result): return "My story"
	return "My story" if result.is_empty() else result

static func label_allowed(value: String) -> bool:
	return SaveData.Names.Filter.accepts(value) and SaveData.Names.Filter.accepts(value.left(LABEL_LENGTH))

func read_slot(index: int) -> Dictionary:
	var path = slot_path(index)
	if path.is_empty(): return {"state":"invalid"}
	if not FileAccess.file_exists(path): return {"state":"empty"}
	var parser = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return {"state":"damaged"}
	var data = parser.data
	if not data is Dictionary or data.get("slot_version") != 1 or not data.get("progress") is Dictionary:
		return {"state":"damaged"}
	var payload: Dictionary = data.progress
	# Refuse incompatible or malformed slots before touching the active game.
	if payload.get("version") != 9: return {"state":"damaged"}
	var defaults = SaveData.new().snapshot()
	for key in defaults:
		if not payload.has(key): return {"state":"damaged"}
		var value = payload[key]
		if defaults[key] is int or defaults[key] is float:
			if not (value is int or value is float): return {"state":"damaged"}
		elif typeof(value) != typeof(defaults[key]): return {"state":"damaged"}
	for kind in defaults.inventory:
		var amount = payload.inventory.get(kind)
		if not (amount is int or amount is float): return {"state":"damaged"}
	return {"state":"ready","label":clean_label(str(data.get("label","My story"))),"saved_at":str(data.get("saved_at","Unknown date")),"progress":payload}

func save_slot(index: int, label: String, progress) -> Error:
	var path = slot_path(index)
	if path.is_empty(): return ERR_INVALID_PARAMETER
	if not label_allowed(label): return ERR_INVALID_DATA
	return SaveData.write_json(path,{
		"slot_version":1,
		"label":clean_label(label),
		"saved_at":Time.get_datetime_string_from_system(false,true),
		"progress":progress.snapshot()
	})

func delete_slot(index: int) -> Error:
	var path = slot_path(index)
	if path.is_empty(): return ERR_INVALID_PARAMETER
	if not FileAccess.file_exists(path): return OK
	return DirAccess.remove_absolute(path)
