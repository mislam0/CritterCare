extends RefCounted
## Monotonic session time; menus do not pause the one-minute cooldown.
const DELAY_MS = 60000
var shown: Dictionary = {}
func ready(key: String, now_ms: int = -1) -> bool:
	if now_ms < 0: now_ms = Time.get_ticks_msec()
	return not shown.has(key) or now_ms-int(shown[key]) >= DELAY_MS
func mark(key: String, now_ms: int = -1) -> void:
	if now_ms < 0: now_ms = Time.get_ticks_msec()
	shown[key] = now_ms
func clear() -> void:
	shown.clear()
