@tool
extends EditorPlugin
## Enabled by project.godot. Local F5 remains Godot's normal Play action.

const Builder = preload("res://tools/web_builder.gd")
const MENU_NAME = "Export CritterCare for itch.io"
var worker: Thread
var notice: AcceptDialog

func _enter_tree() -> void:
	add_tool_menu_item(MENU_NAME, _begin_browser_export)
	notice = AcceptDialog.new()
	notice.title = "CritterCare browser export"
	notice.min_size = Vector2i(610, 220)
	add_child(notice)

func _exit_tree() -> void:
	remove_tool_menu_item(MENU_NAME)
	if worker != null and worker.is_started():
		worker.wait_to_finish()
	if is_instance_valid(notice):
		notice.queue_free()

func _begin_browser_export() -> void:
	if worker != null and worker.is_started():
		return
	EditorInterface.save_all_scenes()
	notice.dialog_text = "Preparing Pip's browser adventure...\n\nThe export runs in the background. A message will appear when your itch.io ZIP is ready."
	notice.popup_centered()
	worker = Thread.new()
	var result = worker.start(_run_export.bind(ProjectSettings.globalize_path("res://"), OS.get_executable_path()))
	if result != OK:
		notice.dialog_text = "Could not start the export. Error: " + error_string(result)

func _run_export(project_dir: String, executable: String) -> void:
	var result = Builder.export_and_zip(project_dir, executable)
	_finish.call_deferred(result)

func _finish(result: Dictionary) -> void:
	if worker != null and worker.is_started():
		worker.wait_to_finish()
	notice.dialog_text = result.message
	if result.ok:
		notice.dialog_text += "\n\nUpload this ZIP as an HTML Game on itch.io.\nYour local game still runs with F5."
		print("CritterCare browser ZIP: ", result.zip_path)
	else:
		push_error(result.message)
	notice.popup_centered()
