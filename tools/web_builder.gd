@tool
extends RefCounted
## Shared by the editor menu and command-line packaging helper. Never shipped
## inside the playable Web PCK. Uses Godot itself; Python is not required.

const TARGET = "4.7.2"
const PRESET = "itch.io Web"

static func export_and_zip(project_dir: String, executable: String) -> Dictionary:
	var version = Engine.get_version_info()
	var current = "%d.%d.%d" % [version.major, version.minor, version.patch]
	if current != TARGET:
		return _error("The bundled browser templates are for Godot " + TARGET + ".\nOpen this project in Godot " + TARGET + " to export.\nLocal F5 play does not use export templates.")
	var output_dir = project_dir.path_join("builds/web")
	var directory_error = DirAccess.make_dir_recursive_absolute(output_dir)
	if directory_error != OK:
		return _error("Could not create the browser output folder: " + error_string(directory_error))
	var log: Array = []
	var status = OS.execute(executable, PackedStringArray(["--headless", "--path", project_dir, "--export-release", PRESET, output_dir.path_join("index.html")]), log, true)
	var log_text = "\n".join(log)
	var log_file = FileAccess.open(project_dir.path_join("builds/web-export.log"), FileAccess.WRITE)
	if log_file != null:
		log_file.store_string(log_text)
		log_file.close()
	if status != 0:
		return _error("The Web export did not finish.\nSee builds/web-export.log for the engine's error details.\nExit code: " + str(status))
	return package_web(project_dir)

static func package_web(project_dir: String) -> Dictionary:
	var output_dir = project_dir.path_join("builds/web")
	for required in ["index.html", "index.js", "index.wasm", "index.pck"]:
		var file = output_dir.path_join(required)
		if not FileAccess.file_exists(file):
			return _error("The Web export is missing " + required + ".")
		var opened = FileAccess.open(file, FileAccess.READ)
		if opened == null or opened.get_length() == 0:
			return _error("The Web export contains an empty or unreadable " + required + ".")
	var license_dir = output_dir.path_join("licenses")
	DirAccess.make_dir_recursive_absolute(license_dir)
	var notices = {
		"LICENSE":"CritterCare-MIT.txt",
		"assets/fonts/OFL.txt":"Nunito-OFL.txt",
		"assets/fonts/Code-LICENSE.txt":"DejaVu-LICENSE.txt",
		"export_templates/4.7.2/Godot-LICENSE.txt":"Godot-LICENSE.txt",
		"export_templates/4.7.2/Godot-COPYRIGHT.txt":"Godot-COPYRIGHT.txt"
	}
	for source in notices:
		var err = DirAccess.copy_absolute(project_dir.path_join(source), license_dir.path_join(notices[source]))
		if err != OK:
			return _error("Could not include license notice: " + source)
	var final_path = project_dir.path_join("builds/CritterCare-itchio.zip")
	var temp_path = final_path + ".tmp"
	var zip = ZIPPacker.new()
	var open_error = zip.open(temp_path)
	if open_error != OK:
		return _error("Could not create the itch.io ZIP: " + error_string(open_error))
	var names = DirAccess.get_files_at(output_dir)
	names.sort()
	for filename in names:
		# Godot's export uses the index prefix for the loader and companions.
		# Only generated game files are included, not unrelated local files.
		if filename.begins_with("index."):
			var err = _zip_file(zip, output_dir.path_join(filename), filename)
			if err != OK:
				zip.close()
				return _error("Could not package " + filename)
	for filename in DirAccess.get_files_at(license_dir):
		var err = _zip_file(zip, license_dir.path_join(filename), "licenses/" + filename)
		if err != OK:
			zip.close()
			return _error("Could not package a license notice.")
	var close_error = zip.close()
	if close_error != OK:
		return _error("Could not finish writing the itch.io ZIP.")
	var move_error = DirAccess.rename_absolute(temp_path, final_path)
	if move_error != OK:
		return _error("Could not replace the previous itch.io ZIP: " + error_string(move_error))
	return {"ok":true, "zip_path":final_path, "message":"Your itch.io browser build is ready.\n\n" + final_path}

static func _zip_file(zip: ZIPPacker, source: String, destination: String) -> Error:
	var file = FileAccess.open(source, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var err = zip.start_file(destination)
	if err != OK:
		return err
	err = zip.write_file(file.get_buffer(file.get_length()))
	if err != OK:
		return err
	return zip.close_file()

static func _error(message: String) -> Dictionary:
	return {"ok":false, "message":message}
