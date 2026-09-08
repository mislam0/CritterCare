extends ColorRect

var _base_position := Vector2.ZERO
var _busy := false
var _default_color := Color(0.290196, 0.564706, 0.886275, 1)
var _happy_color := Color(0.976471, 0.686275, 0.27451, 1)

func _ready() -> void:
	_base_position = position
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		play_bounce()

func play_bounce() -> void:
	if _busy:
		return

	_busy = true
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", _base_position.y - 35.0, 0.12)
	tween.parallel().tween_property(self, "color", _happy_color, 0.12)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", _base_position.y, 0.16)
	tween.parallel().tween_property(self, "color", _default_color, 0.16)
	await tween.finished
	_busy = false
