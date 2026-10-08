extends RefCounted
## Small, shared UI toolkit. All geometry uses the 1280 × 800 design canvas.

const INK = Color("35493e")
const MUTED = Color("778176")
const GREEN = Color("426d53")
const PALE = Color("e7edde")
const CREAM = Color("fffdf7")
const CORRECT = Color("00ff00")
const INCORRECT = Color("ff0000")
const FEEDBACK_BG = Color("101510")
const ORANGE = Color("c4764b")
const FONT = preload("res://assets/fonts/Nunito-SemiBold.ttf")
const HEADING_FONT = preload("res://assets/fonts/Nunito-ExtraBold.ttf")
const LearningText = preload("res://scripts/learning_text.gd")
const CODE_FONT = preload("res://assets/fonts/Code.ttf")

static func style(color: Color, radius: int = 18, border: Color = Color.TRANSPARENT, shadow: bool = false) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_border_width_all(1 if border.a > 0 else 0)
	s.border_color = border
	if shadow:
		s.shadow_color = Color(0.2, 0.24, 0.18, 0.09)
		s.shadow_size = 8
		s.shadow_offset = Vector2(0, 5)
	return s

static func theme() -> Theme:
	var t = Theme.new()
	t.default_font = FONT
	t.default_font_size = 19
	t.set_color("font_color", "Label", INK)
	t.set_color("default_color", "RichTextLabel", INK)
	t.set_font("normal_font", "RichTextLabel", FONT)
	t.set_font("bold_font", "RichTextLabel", HEADING_FONT)
	t.set_constant("line_separation", "RichTextLabel", 0)
	t.set_color("font_color", "Button", INK)
	t.set_color("font_hover_color", "Button", INK)
	t.set_color("font_pressed_color", "Button", INK)
	t.set_color("font_focus_color", "Button", INK)
	t.set_color("font_disabled_color", "Button", Color("9eaa9d"))
	t.set_stylebox("normal", "Button", style(CREAM, 15, Color("dce2d3")))
	t.set_stylebox("hover", "Button", style(Color("f0f4e7"), 15, Color("8aaa80")))
	t.set_stylebox("pressed", "Button", style(Color("dce8d4"), 15, Color("75916c")))
	t.set_stylebox("disabled", "Button", style(Color("eeeee6"), 15))
	t.set_stylebox("focus", "Button", style(Color.TRANSPARENT, 15, GREEN))
	return t

static func panel(parent: Node, rect: Rect2, color: Color = CREAM, radius: int = 20, shadow: bool = false) -> Panel:
	var p = Panel.new()
	p.position = rect.position
	p.size = rect.size
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", style(color, radius, Color.TRANSPARENT, shadow))
	parent.add_child(p)
	return p

static func label(parent: Node, value: String, rect: Rect2, size: int = 20, color: Color = INK, center: bool = false) -> LearningText:
	var l = LearningText.new()
	# Establish wrapping width while the label is empty. Setting long text at
	# width zero first creates an oversized minimum height in Godot's layout.
	l.position = rect.position
	l.size = rect.size
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# A clipped label needs room for at least one complete font line.
	var font = HEADING_FONT if size >= 23 else FONT
	while size > 10 and font.get_height(size) > rect.size.y - 1:
		size -= 1
	l.add_theme_font_size_override("normal_font_size", size)
	l.add_theme_font_size_override("bold_font_size", size)
	if size >= 23:
		l.add_theme_font_override("normal_font", HEADING_FONT)
	l.add_theme_color_override("default_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(l)
	l.words = value
	return l

static func button(parent: Node, value: String, rect: Rect2, action: Callable, primary: bool = false) -> Button:
	var b = Button.new()
	b.text = value
	b.position = rect.position
	b.size = rect.size
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if primary:
		b.add_theme_stylebox_override("normal", style(GREEN, 15))
		b.add_theme_stylebox_override("hover", style(Color("527e61"), 15))
		b.add_theme_stylebox_override("pressed", style(Color("325b43"), 15))
		for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(key, CREAM)
	b.pressed.connect(action)
	parent.add_child(b)
	return b

static func paragraph(parent: Node, value: String, font_size: int = 18, color: Color = INK) -> LearningText:
	# Container-managed text grows vertically and is never clipped to a fixed height.
	var l = LearningText.new()
	l.fit_content = true
	l.size = Vector2(560, 40)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("normal_font_size", font_size)
	l.add_theme_font_size_override("bold_font_size", font_size)
	l.add_theme_color_override("default_color", color)
	parent.add_child(l)
	l.words = value
	return l

static func scroll_text(parent: Node, value: String, rect: Rect2, font_size: int = 18, color: Color = INK) -> LearningText:
	var scroll = ScrollContainer.new()
	scroll.position = rect.position
	scroll.size = rect.size
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.focus_mode = Control.FOCUS_ALL
	parent.add_child(scroll)
	return paragraph(scroll, value, font_size, color)

static func code(parent: Node, text: String, rect: Rect2, font_size: int = 19) -> LearningText:
	panel(parent, rect, Color("edf0e6"), 14)
	# A long example can grow inside its scroll area instead of losing lines.
	var l = scroll_text(parent, text, Rect2(rect.position + Vector2(20, 12), rect.size - Vector2(40, 24)), font_size, GREEN)
	use_code_font(l)
	return l

static func use_code_font(l: LearningText) -> void:
	l.add_theme_font_override("normal_font", CODE_FONT)
	l.add_theme_font_override("bold_font", CODE_FONT)
	l.code_mode = true

static func teaching_button(parent: Node, value: String, rect: Rect2, action: Callable, primary: bool = false, font_size: int = 17, left: bool = false) -> Button:
	# The native button keeps focus, mouse/touch and keyboard activation.
	# Its passive rich-text child never intercepts a click or drag.
	var b = button(parent, "", rect, action, primary)
	b.accessibility_name = value
	var l = label(b, value, Rect2(14, 3, rect.size.x-28, rect.size.y-6), font_size, CREAM if primary else INK, not left)
	l.name = "TeachingWords"
	l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	l.offset_left = 14
	l.offset_right = -14
	l.offset_top = 3
	l.offset_bottom = -3
	return b

static func feedback_text(parent: Node, value: String, rect: Rect2, font_size: int = 18) -> LearningText:
	var shell = panel(parent,rect,Color("eef0e5"),12)
	var heading = label(shell,"",Rect2(12,0,rect.size.x-24,42),28,INK,true)
	heading.name = "OutcomeHeading"
	var body = scroll_text(shell,value,Rect2(12,4,rect.size.x-24,rect.size.y-8),font_size)
	body.set_meta("feedback_shell",shell)
	body.set_meta("feedback_heading",heading)
	body.set_meta("outcome",0)
	heading.hide()
	return body

static func show_feedback(body: LearningText, correct: bool, heading: String = "") -> void:
	var shell: Panel = body.get_meta("feedback_shell")
	var title: LearningText = body.get_meta("feedback_heading")
	var color = CORRECT if correct else INCORRECT
	body.set_meta("outcome",1 if correct else -1)
	shell.add_theme_stylebox_override("panel",style(FEEDBACK_BG,12,color))
	title.words = heading if not heading.is_empty() else ("✓ CORRECT!" if correct else "✕ TRY AGAIN!")
	title.add_theme_color_override("default_color",color)
	title.add_theme_font_override("normal_font",HEADING_FONT)
	title.show()
	var scroll: ScrollContainer = body.get_parent()
	scroll.position.y = 42
	scroll.size.y = shell.size.y-46
	scroll.scroll_vertical = 0
	body.add_theme_color_override("default_color",CREAM)

static func neutral_feedback(body: LearningText) -> void:
	var shell: Panel = body.get_meta("feedback_shell")
	body.set_meta("outcome",0)
	body.get_meta("feedback_heading").hide()
	shell.add_theme_stylebox_override("panel",style(Color("eef0e5"),12))
	var scroll: ScrollContainer = body.get_parent()
	scroll.position.y = 4
	scroll.size.y = shell.size.y-8
	scroll.scroll_vertical = 0
	body.add_theme_color_override("default_color",INK)

static func outcome_label(l: LearningText, correct: bool) -> void:
	var color = CORRECT if correct else INCORRECT
	l.add_theme_color_override("default_color",color)
	l.add_theme_font_override("normal_font",HEADING_FONT)
	l.add_theme_stylebox_override("normal",style(FEEDBACK_BG,9,color))
	l.set_meta("outcome",1 if correct else -1)

static func clear_outcome(l: LearningText) -> void:
	l.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
	l.add_theme_color_override("default_color",GREEN)
	l.set_meta("outcome",0)

static func mark_answer(b: Button, correct: bool) -> void:
	var color = CORRECT if correct else INCORRECT
	b.add_theme_stylebox_override("disabled",style(FEEDBACK_BG,15,color))
	b.add_theme_color_override("font_disabled_color",color)
	b.add_theme_font_override("font",HEADING_FONT)
	b.set_meta("outcome",1 if correct else -1)
	if b.has_node("TeachingWords"):
		b.get_node("TeachingWords").add_theme_color_override("default_color",color)
		b.get_node("TeachingWords").add_theme_font_override("normal_font",HEADING_FONT)
