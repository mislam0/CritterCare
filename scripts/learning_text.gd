extends RichTextLabel
## Plain words are the source of truth; BBCode exists only in the renderer.
const Terms = preload("res://scripts/teaching_terms.gd")
const Names = preload("res://scripts/pet_name.gd")
var source_words: String = ""

var words: String = "":
	set(value):
		if source_words == value and words == Names.present(value): return
		source_words = value
		words = Names.present(value)
		refresh_format()
		fit_name()
var teaching: bool = false:
	set(value):
		teaching = value
		refresh_format()
var code_mode: bool = false:
	set(value):
		if value == code_mode:
			return
		code_mode = value
		refresh_format()

func refresh_format() -> void:
	text = Terms.format_words(words, code_mode) if teaching else Terms.escape(words)

func refresh_name() -> void:
	words = source_words
	fit_name()

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

func fit_name() -> void:
	if fit_content or not has_meta("name_font_size") or not (source_words.contains("{pet_name}") or source_words.contains("{PET_NAME}")): return
	var base: int = get_meta("name_font_size")
	add_theme_font_size_override("normal_font_size",base)
	add_theme_font_size_override("bold_font_size",base)
	while base > 12 and not content_fits():
		base -= 1
		add_theme_font_size_override("normal_font_size",base)
		add_theme_font_size_override("bold_font_size",base)
