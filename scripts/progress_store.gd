extends RefCounted
## Schema-versioned local progression. No active/half-resolved board is saved.
const SCHEMA: int = 1
const COUNT: int = 5
var path: String
var data: Dictionary = fresh()
var notice: String = ""
var read_only: bool = false


func _init(save_path: String = "user://lyra-progress.json") -> void:
	path = save_path


static func fresh() -> Dictionary:
	return {"schema_version": SCHEMA, "highest_unlocked": 1,
		"completed": [false, false, false, false, false],
		"best_scores": [0, 0, 0, 0, 0], "best_stars": [0, 0, 0, 0, 0],
		"tutorials_seen": [], "settings": {"reduced_motion": false}}


static func normalize(raw) -> Dictionary:
	if not raw is Dictionary or raw.get("schema_version") != SCHEMA:
		return {}
	for key in ["completed", "best_scores", "best_stars"]:
		if not raw.get(key) is Array or raw[key].size() != COUNT:
			return {}
	var clean: Dictionary = fresh()
	for i in range(COUNT):
		if not raw["completed"][i] is bool:
			return {}
		for key in ["best_scores", "best_stars"]:
			var value = raw[key][i]
			if not (value is int or value is float) or not is_finite(float(value)) or value != floor(value) or value < 0 or value > 1000000000:
				return {}
		if raw["best_stars"][i] > 3 or raw["completed"][i] and raw["best_stars"][i] < 1:
			return {}
		if raw["completed"][i]:
			clean["completed"][i] = true
			clean["best_scores"][i] = int(raw["best_scores"][i])
			clean["best_stars"][i] = int(raw["best_stars"][i])
	# Never trust an unlocked counter that disagrees with completed levels.
	for i in range(COUNT - 1):
		if not clean["completed"][i]:
			break
		clean["highest_unlocked"] = i + 2
	if raw.get("tutorials_seen") is Array:
		for id in raw["tutorials_seen"]:
			if (id is int or id is float) and id == floor(id) and id >= 1 and id <= COUNT and not clean["tutorials_seen"].has(int(id)):
				clean["tutorials_seen"].append(int(id))
	if raw.get("settings") is Dictionary and raw["settings"].get("reduced_motion") is bool:
		clean["settings"]["reduced_motion"] = raw["settings"]["reduced_motion"]
	return clean


func _read(file_path: String):
	if not FileAccess.file_exists(file_path):
		return null
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null or file.get_length() > 65536:
		return null
	var parser: JSON = JSON.new()
	return parser.data if parser.parse(file.get_as_text()) == OK else null


func load_progress() -> Dictionary:
	read_only = false
	notice = ""
	var raw = _read(path)
	if raw is Dictionary and (raw.get("schema_version") is int or raw.get("schema_version") is float) and raw["schema_version"] > SCHEMA:
		read_only = true
		notice = "Newer save found. This version will not overwrite it."
		data = fresh()
		return data
	var valid: Dictionary = normalize(raw)
	if not valid.is_empty():
		data = valid
		return data
	valid = normalize(_read(path + ".bak"))
	if not valid.is_empty():
		data = valid
		notice = "Progress recovered from the previous save."
	else:
		data = fresh()
		if FileAccess.file_exists(path):
			notice = "Save could not be read. Starting safely with fresh progress."
	return data


func save_progress() -> bool:
	if read_only:
		return false
	if OS.has_feature("web") and not OS.is_userfs_persistent():
		notice = "Browser storage is unavailable. Progress lasts for this visit."
		return false
	var valid: Dictionary = normalize(data)
	if valid.is_empty():
		notice = "Progress could not be saved. Your previous save is intact."
		return false
	var directory: String = ProjectSettings.globalize_path(path.get_base_dir())
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		notice = "Progress could not be saved. Check storage space."
		return false
	var temporary: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		notice = "Progress could not be saved. Check storage space."
		return false
	file.store_string(JSON.stringify(valid))
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK or normalize(_read(temporary)) != valid:
		notice = "Progress could not be saved. Your previous save is intact."
		return false
	# Back up only a known-good file: a corrupt primary must not replace a
	# recovered backup. Rename the verified temporary file over the primary.
	if not normalize(_read(path)).is_empty():
		if DirAccess.copy_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(path + ".bak")) != OK:
			notice = "Progress could not be backed up. Previous save kept."
			return false
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(path)) != OK:
		notice = "Progress could not be saved. Your previous save is intact."
		return false
	data = valid
	notice = ""
	return true


func can_play(id: int) -> bool:
	return id >= 1 and id <= COUNT and id <= int(data["highest_unlocked"])


func record_victory(session) -> bool:
	var id: int = int(session.level["id"])
	if not session.finished or not session.won or not session.pending.is_empty() or not can_play(id):
		return false
	data["completed"][id - 1] = true
	data["best_scores"][id - 1] = maxi(int(data["best_scores"][id - 1]), session.rating_score())
	data["best_stars"][id - 1] = maxi(int(data["best_stars"][id - 1]), session.stars())
	data = normalize(data)
	return save_progress()


func mark_tutorial(id: int) -> void:
	if id >= 1 and id <= COUNT and not data["tutorials_seen"].has(id):
		data["tutorials_seen"].append(id)
		save_progress()


func set_reduced_motion(enabled: bool) -> void:
	data["settings"]["reduced_motion"] = enabled
	save_progress()


func total_stars() -> int:
	var total: int = 0
	for value in data["best_stars"]:
		total += int(value)
	return total


func all_completed() -> bool:
	return not data["completed"].has(false)
