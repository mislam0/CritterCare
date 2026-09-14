extends SceneTree
## Optional CLI: godot --headless --path . --script res://tools/export_web.gd
## The editor provides the same action under Project > Tools.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var result = preload("res://tools/web_builder.gd").export_and_zip(ProjectSettings.globalize_path("res://"), OS.get_executable_path())
	print(result.message)
	quit(0 if result.ok else 1)
