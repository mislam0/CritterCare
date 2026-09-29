extends RichTextLabel
## Plain words are the source of truth; BBCode exists only in the renderer.
const Terms = preload("res://scripts/teaching_terms.gd")

var words: String = "":
	set(value):
		if value == words:
			return
		words = value
		text = Terms.format_words(words, code_mode)
var code_mode: bool = false:
	set(value):
		if value == code_mode:
			return
		code_mode = value
		text = Terms.format_words(words, code_mode)

func _init() -> void:
	bbcode_enabled = true
	threaded = false
	scroll_active = false
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func content_fits() -> bool:
	# Unlike visible-line counts, shaping height can be measured immediately,
	# before a frame is drawn. This includes the emphasized font's real width.
	return get_content_height() <= size.y + 0.5
