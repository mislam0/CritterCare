extends RefCounted
## Small, shared UI toolkit. All geometry uses the 1280 × 800 design canvas.

const INK = Color("35493e")
const MUTED = Color("778176")
const GREEN = Color("426d53")
const PALE = Color("e7edde")
const CREAM = Color("fffdf7")
const ORANGE = Color("c4764b")
const FONT = preload("res://assets/fonts/Nunito-SemiBold.ttf")
const HEADING_FONT = preload("res://assets/fonts/Nunito-ExtraBold.ttf")

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

static func label(parent: Node, value: String, rect: Rect2, size: int = 20, color: Color = INK, center: bool = false) -> Label:
	var l = Label.new()
	# Establish wrapping width while the label is empty. Setting long text at
	# width zero first creates an oversized minimum height in Godot's layout.
	l.position = rect.position
	l.size = rect.size
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.clip_text = true
	l.add_theme_font_size_override("font_size", size)
	if size >= 23:
		l.add_theme_font_override("font", HEADING_FONT)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(l)
	l.text = value
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

static func code(parent: Node, text: String, rect: Rect2, font_size: int = 19) -> Label:
	panel(parent, rect, Color("edf0e6"), 14)
	var l = label(parent, text, Rect2(rect.position + Vector2(20, 12), rect.size - Vector2(40, 24)), font_size, GREEN)
	l.add_theme_font_override("font", preload("res://assets/fonts/Code.ttf"))
	return l
