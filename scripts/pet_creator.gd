extends Control
## Live pet creator. All changes, including saved looks, stay drafts until Apply.

signal applied(appearance: Dictionary, designs: Dictionary, looks: Array, outfit: Dictionary)
signal cancel_requested
const UI = preload("res://scripts/ui.gd")
const Looks = preload("res://data/pet_looks.gd")
const Pet = preload("res://scripts/hamster.gd")
var progress
var draft: Dictionary
var drafts: Dictionary
var saved: Array
var outfit: Dictionary
var actor
var content: Control
var species_buttons: Dictionary = {}
var feature_controls: Dictionary = {}
var color_controls: Dictionary = {}
var tab: String = "face"
var notice: String = "Save a pet design and its outfit here."
var replace_pending: int = -1
var show_outfit: bool = true

func _ready() -> void:
	size = Vector2(980, 510)
	draft = Looks.clean(progress.pet_look)
	drafts = Looks.designs(progress.pet_designs)
	saved = progress.clean_looks(progress.saved_looks)
	outfit = progress.cosmetics("pet").duplicate()
	build()

func build() -> void:
	if is_instance_valid(content):
		remove_child(content)
		content.queue_free()
	content = Control.new()
	content.size = size
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)
	species_buttons.clear()
	feature_controls.clear()
	color_controls.clear()
	for i in range(Looks.SPECIES.size()):
		var species: String = Looks.SPECIES[i]
		var b = UI.button(content, "", Rect2(i * 164, 0, 154, 92), func(): select_species(species))
		b.name = "Species_" + species
		b.accessibility_name = Looks.CATALOG[species].title
		if species == draft.species: b.add_theme_stylebox_override("normal", UI.style(Color("e0eddb"), 16, UI.GREEN))
		var mini = Pet.new()
		mini.blocked = true
		mini.stage_actor = true
		mini.appearance = draft if species == draft.species else drafts.get(species, Looks.defaults(species))
		mini.position = Vector2(77, 48)
		mini.scale = Vector2.ONE * 0.22
		b.add_child(mini)
		UI.label(b, Looks.CATALOG[species].title, Rect2(4, 66, 146, 22), 15, UI.GREEN, true)
		species_buttons[species] = b
	UI.panel(content, Rect2(0, 105, 300, 343), Color("eef1e6"), 22)
	UI.label(content, Looks.CATALOG[draft.species].title, Rect2(15, 111, 270, 33), 26, UI.INK, true)
	actor = Pet.new()
	actor.blocked = true
	actor.stage_actor = true
	actor.calm = progress.calm
	actor.appearance = draft.duplicate()
	actor.cosmetic_items = outfit if show_outfit else {}
	actor.position = Vector2(150, 327)
	actor.scale = Vector2.ONE * 0.9
	content.add_child(actor)
	UI.button(content, "Outfit preview: " + ("on" if show_outfit else "off"), Rect2(25, 405, 250, 31), func():
		show_outfit = not show_outfit
		build()).add_theme_font_size_override("font_size", 14)
	UI.button(content, "Face + fur", Rect2(326, 105, 310, 36), func():
		tab = "face"
		build(), tab == "face").name = "FaceTab"
	UI.button(content, "Saved looks", Rect2(648, 105, 326, 36), func():
		tab = "saved"
		build(), tab == "saved").name = "SavedLooksTab"
	if tab == "face": build_features()
	else: build_saved()
	UI.button(content, "Cancel", Rect2(0, 467, 160, 44), func(): cancel_requested.emit()).name = "CancelLook"
	UI.button(content, "Surprise me", Rect2(176, 467, 170, 44), func():
		draft = Looks.surprise(draft.species)
		build()).name = "SurpriseLook"
	UI.button(content, "Reset this look", Rect2(362, 467, 198, 44), func():
		draft = Looks.defaults(draft.species)
		build()).name = "ResetLook"
	UI.label(content, "Free to change!", Rect2(570, 473, 177, 32), 15, UI.GREEN, true)
	UI.button(content, "Use this look", Rect2(759, 467, 215, 44), commit, true).name = "ApplyLook"

func build_features() -> void:
	for i in range(Looks.FEATURES.size()):
		var feature: String = Looks.FEATURES[i]
		var x = 326 + (i % 2) * 330
		var y = 151 + floori(i / 2.0) * 63
		UI.label(content, Looks.TITLES[feature], Rect2(x, y, 310, 20), 15, UI.MUTED)
		var options: Array = Looks.CATALOG[draft.species][feature]
		var pick = picker(Rect2(x, y + 22, 314, 33))
		pick.name = "Feature_" + feature
		for id in options: pick.add_item(Looks.LABELS[id])
		pick.selected = options.find(draft[feature])
		pick.item_selected.connect(func(index): set_feature(feature, options[index]))
		feature_controls[feature] = pick
	UI.label(content, "Color palette", Rect2(656, 277, 310, 20), 15, UI.MUTED)
	var palettes = picker(Rect2(656, 299, 314, 33))
	palettes.name = "ColorPalette"
	palettes.add_item("Choose colors…")
	for title in Looks.PALETTES: palettes.add_item(title)
	palettes.item_selected.connect(func(index):
		if index > 0:
			draft = Looks.palette(draft, Looks.PALETTES.keys()[index - 1])
			build())
	for i in range(Looks.COLORS.size()):
		var part: String = Looks.COLORS[i]
		var x = 326 + (i % 3) * 220
		var y = 347 + floori(i / 3.0) * 52
		UI.label(content, Looks.COLOR_LABELS[part], Rect2(x, y, 205, 19), 14, UI.MUTED)
		var color = ColorPickerButton.new()
		color.name = "Color_" + part
		color.position = Vector2(x, y + 20)
		color.size = Vector2(204, 27)
		color.color = Color(draft[part])
		color.edit_alpha = false
		color.accessibility_name = Looks.COLOR_LABELS[part]
		color.tooltip_text = "Choose " + Looks.COLOR_LABELS[part].to_lower()
		content.add_child(color)
		color.color_changed.connect(func(value): set_color(part, value))
		color_controls[part] = color

func picker(rect: Rect2) -> OptionButton:
	var pick = OptionButton.new()
	pick.position = rect.position
	pick.size = rect.size
	pick.add_theme_font_size_override("font_size", 17)
	content.add_child(pick)
	return pick

func build_saved() -> void:
	for i in range(3):
		var entry: Dictionary = saved[i]
		var y = 153 + i * 83
		UI.panel(content, Rect2(326, y, 648, 74), Color("eef1e6"), 15)
		var title = "Look %d · " % (i + 1)
		title += "Empty" if entry.is_empty() else Looks.title(entry.appearance)
		UI.label(content, title, Rect2(342, y + 6, 296, 28), 20)
		UI.label(content, "Save this pet + outfit" if entry.is_empty() else "%d accessories · ready to wear" % entry.outfit.size(), Rect2(342, y + 36, 296, 25), 14, UI.MUTED)
		var wear = UI.button(content, "Wear", Rect2(662, y + 17, 88, 39), func(): restore_look(i))
		wear.name = "WearLook%d" % i
		wear.disabled = entry.is_empty()
		UI.button(content, "Save", Rect2(758, y + 17, 88, 39), func(): store_look(i)).name = "SaveLook%d" % i
		var clear = UI.button(content, "Clear", Rect2(854, y + 17, 101, 39), func():
			saved[i] = {}
			replace_pending = -1
			notice = "Look %d cleared. Use this look keeps your changes." % (i + 1)
			build())
		clear.name = "ClearLook%d" % i
		clear.disabled = entry.is_empty()
	UI.label(content, notice, Rect2(330, 405, 640, 43), 16, UI.GREEN).name = "LookNotice"

func select_species(species: String) -> void:
	if not Looks.CATALOG.has(species): return
	drafts[draft.species] = draft.duplicate(true)
	draft = Looks.clean(drafts.get(species, Looks.defaults(species)))
	replace_pending = -1
	build()

func set_feature(feature: String, value: String) -> void:
	if feature in Looks.FEATURES and value in Looks.CATALOG[draft.species][feature]:
		draft[feature] = value
		actor.set_appearance(draft)

func set_color(part: String, value: Color) -> void:
	if part in Looks.COLORS:
		draft[part] = value.to_html(false)
		actor.set_appearance(draft)

func store_look(index: int) -> void:
	if index < 0 or index >= 3: return
	if not saved[index].is_empty() and replace_pending != index:
		replace_pending = index
		notice = "Replace Look %d? Tap its Save button again." % (index + 1)
		build()
		return
	saved[index] = {"appearance": draft.duplicate(true), "outfit": outfit.duplicate()}
	replace_pending = -1
	notice = "Look %d ready! Use this look saves all your changes." % (index + 1)
	build()

func restore_look(index: int) -> void:
	if index < 0 or index >= 3 or saved[index].is_empty(): return
	drafts[draft.species] = draft.duplicate(true)
	draft = Looks.clean(saved[index].appearance)
	outfit = progress.clean_pet_outfit(saved[index].outfit)
	replace_pending = -1
	notice = "Look %d is in the preview. Use this look to keep it." % (index + 1)
	build()

func commit() -> void:
	drafts[draft.species] = draft.duplicate(true)
	applied.emit(draft.duplicate(true), drafts.duplicate(true), saved.duplicate(true), outfit.duplicate())

func _process(delta: float) -> void:
	if is_instance_valid(actor):
		actor.clock += delta
		actor.queue_redraw()
		actor._update_costume_pose()
