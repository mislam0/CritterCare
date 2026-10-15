extends "res://tests/verify.gd"
const Names = preload("res://scripts/pet_name.gd")
const Filter = preload("res://scripts/name_filter.gd")
const UI = preload("res://scripts/ui.gd")

func tap_button(id: String) -> void:
	await frames(3)
	await click(game.overlay.get_node(id).get_global_rect().get_center() * Vector2(root.size) / Vector2(1280,800))

func set_name(value: String) -> void:
	game.name_input.text = value
	game.name_input.text_changed.emit(value)

func run() -> void:
	graphical = DisplayServer.get_name() != "headless"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_dir = arg.trim_prefix("--capture=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
	var unexpected = []
	for index in range(Filter.Data.WORDS.size()):
		var term: String = Filter.Data.WORDS[index]
		if Filter.Data.FRIENDLY.has(term): continue
		if Filter.accepts(term): unexpected.append(index)
	check(unexpected.is_empty(),"Every compiled dictionary entry is rejected except explicit friendly-name exceptions; failure indexes: %s" % [unexpected])
	var cases = []
	for term in ["fuck","shit","bitch","cunt","nigger","faggot","porn","whore","asshole","dildo"]:
		cases.append_array([term,term.to_upper(),"x"+term+"x",term+"shit",term.replace("i","1").replace("o","0").replace("a","4").replace("s","5")," ".join(term.split("")),"-".join(term.split("")),"'".join(term.split("")),term.repeat(2)])
		var doubled = ""
		for letter in term: doubled += letter.repeat(2)
		cases.append(doubled)
	cases.append_array(["f.u.c.k","f_u_c_k","f*ck","f@ck","fu\u200bck","fu\u202eck","fúçk","ｆｕｃｋ","𝐟𝐮𝐜𝐤","fuсk","shіt","sh1t","b1tch","b!tch","a55","asscum","sexass","fuuck","fuxck","fcuk","fukc","shyt","phuck","n1gg3r","niggashit","fuuucckk","a55555","f\ufe0fuck","f\u034fuck","FUCKPip","Mochifuck","putain","mierda","scheisse","сука","씨발","操你妈","madarchod","banchod"])
	for i in range(cases.size()):
		check(not Filter.accepts(cases[i]),"Obfuscation/combination fixture %d is rejected" % i)
	check(not Filter.accepts("tihs") and not Filter.accepts("kcuf") and not Filter.accepts("kcufPip"),"Reversed terms and reversed embedded combinations are blocked")
	check(not Filter.accepts("pissdamn") and not Filter.accepts("poopcrap") and not Filter.accepts("xpissx") and not Filter.accepts("damn123"),"Short-word combinations and decorative padding cannot bypass whole-word checks")
	for name in ["Pip","Mochi","Pip Junior","Peanut","Nibbles","Snowball","Buttercup","Cassie","Cassidy","Scunthorpe","Penelope","Tucker","Dickens","Grape","Jasper","Coco","Cookie","José","Étoile","Zoë","O'Neil","Jean-Luc","Milo2","もち","团子","하늘","توت","WWWWWWWWWWWW"]:
		check(Names.validate(name).ok,"Friendly name remains usable: "+name)
	check(Names.clean(" ") == "Pip" and not Names.validate("a".repeat(300)).ok,"Blank names use Pip and oversized validation input is bounded")
	var start = Time.get_ticks_usec()
	for i in range(200): Filter.accepts("GardenPal"+str(i))
	var elapsed = Time.get_ticks_usec()-start
	print("FILTER BENCHMARK: 200 varied names in %d ms" % (elapsed/1000))
	check(elapsed < 5000000,"Validation stays responsive in the native runtime")
	root.size = Vector2i(1280,800)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(5)
	game.progress.sound = false
	set_name("sh1t")
	check(game.overlay.get_node("UsePetName").disabled and not game.name_preview.words.contains("sh1t") and game.name_preview.get_theme_color("default_color") == UI.INCORRECT,"Blocked input gets a friendly red message and never appears in the preview")
	await snap("name-filter-blocked")
	game.name_input.text_submitted.emit("sh1t")
	check(game.modal_name == "name_pet" and not game.progress.name_chosen and game.progress.pet_name == "Pip","Enter cannot commit a blocked first-play name")
	game._complete_pet_name("f u c k")
	check(game.modal_name == "name_pet" and game.progress.pet_name == "Pip","The name handler validates independently of the disabled button")
	await tap_button("KeepPip")
	check(game.progress.pet_name == "Pip" and game.tutorial.active,"Keep Pip remains available after a rejected attempt")
	game.tutorial.finish()
	game.progress.coins = 345
	game.open_name_prompt(false)
	set_name("Mochi")
	await tap_button("UsePetName")
	check(game.progress.pet_name == "Mochi" and game.modal_name == "settings","A friendly replacement is accepted and saved")
	game.open_name_prompt(false)
	set_name("b1tch")
	game.name_input.text_submitted.emit("b1tch")
	game.close_modal()
	check(game.progress.pet_name == "Mochi" and game.progress.coins == 345,"A rejected rename and Cancel preserve the existing name and progress")
	game.open_name_prompt(false)
	set_name("fu\u200bck")
	check(game.overlay.get_node("UsePetName").disabled,"Pasted invisible characters cannot bypass the naming form")
	for window in [Vector2i(1280,800),Vector2i(960,600)]:
		root.size = window
		await frames(3)
		check(game.name_preview.content_fits(),"The rejection message fits at %s" % window)
		await snap("name-filter-small" if window.x == 960 else "name-filter-large")
	game.close_modal()
	root.size = Vector2i(1280,800)
	var legacy = game.progress.snapshot()
	legacy.pet_name = "sh1t"
	legacy.name_chosen = true
	legacy.discovered = ["events"]
	legacy.pip_quotes = {"events":"IF sh1t is petted THEN happiness grows."}
	legacy.owned = ["leaf_hat"]
	legacy.equipped = {"pet:head":"leaf_hat"}
	var repaired = SaveData.new()
	repaired.apply_snapshot(legacy)
	check(repaired.pet_name == "Pip" and not repaired.name_chosen and repaired.coins == 345 and repaired.owned.has("leaf_hat"),"Old blocked names become Pip without losing money or purchases")
	check(repaired.pip_quotes.events == "IF Pip is petted THEN happiness grows.","A repaired name does not linger in its previously recorded quote")
	var allowed_quote = "IF Mochi is petted THEN happiness grows."
	check(Names.repair_quote(allowed_quote,"Mochi") == allowed_quote,"Unrelated historical teaching stays verbatim")
	repaired.pet_name = "shit"
	repaired.name_chosen = true
	check(repaired.snapshot().pet_name == "Pip" and not repaired.snapshot().name_chosen,"Persistence independently repairs an unsafe in-memory name")
	game.save_slots.base_path = "user://name_filter_slot_test.json"
	game.save_slots.delete_slot(0)
	game.open_save_slots()
	game._confirm_save_slot(0)
	game.slot_name_input.text = "f u c k"
	game.slot_name_input.text_changed.emit(game.slot_name_input.text)
	game.slot_name_input.text_submitted.emit(game.slot_name_input.text)
	check(game.modal_name == "save_slot" and game.overlay.get_node("ConfirmSlot").disabled and game.save_slots.read_slot(0).state == "empty","Save-slot names use the same filter and cannot be submitted with Enter")
	check(game.save_slots.save_slot(0,"shit",game.progress) == ERR_INVALID_DATA,"Slot persistence also rejects a blocked label directly")
	SaveData.write_json(game.save_slots.slot_path(0),{"slot_version":1,"label":"fuck","saved_at":"2026-10-15 12:00:00","progress":legacy})
	game.open_save_slots()
	check(game.overlay.get_node("SlotTitle0").words == "Slot 1 · My story","Old blocked slot labels never appear in slot titles")
	game._confirm_slot_action(0,"load")
	game._load_manual_slot(0)
	check(game.modal_name == "name_pet" and game.progress.pet_name == "Pip" and game.progress.coins == 345,"Loading a legacy slot requests a friendly name and preserves its story")
	game.save_slots.delete_slot(0)
	game._complete_pet_name("Pip")
	game._reset_progress()
	set_name("asscum")
	game._complete_pet_name("asscum")
	check(game.modal_name == "name_pet" and not game.progress.name_chosen,"Reset uses the same filter before the new tutorial")
	game.queue_free()
	await frames(3)
	print("NAME FILTER RESULT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
