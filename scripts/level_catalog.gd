extends RefCounted
## Authored data is separate from the board and session. Invalid data is rejected.
const DATA_PATH: String = "res://data/lyra_levels.json"
static var cache: Array[Dictionary] = []


static func all() -> Array[Dictionary]:
	if cache.is_empty():
		var data = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
		if not data is Dictionary or data.get("schema_version") != 1 or not data.get("levels") is Array or data["levels"].size() != 5:
			push_error("Invalid Lyra level catalog")
			return []
		for raw in data["levels"]:
			var level: Dictionary = normalize(raw)
			if level.is_empty() or level["id"] != cache.size() + 1:
				cache.clear()
				push_error("Invalid Lyra level definition")
				return []
			cache.append(level)
	return cache.duplicate(true)


static func get_level(id: int) -> Dictionary:
	if cache.is_empty():
		all()
	return cache[id - 1].duplicate(true) if id >= 1 and id <= cache.size() else {}


static func integer(value, low: int, high: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= low and value <= high


static func normalize(raw) -> Dictionary:
	if not raw is Dictionary:
		return {}
	for key in ["id", "seed", "moves"]:
		if not integer(raw.get(key), 1, 2147483647):
			return {}
	if raw["moves"] > 100 or not raw.get("name") is String or raw["name"].is_empty() or not raw.get("tutorial") is String:
		return {}
	if raw.has("caption") and (not raw["caption"] is String or raw["caption"].is_empty()):
		return {}
	if not raw.get("kinds") is Array or raw["kinds"].size() < 3 or raw["kinds"].size() > 6:
		return {}
	var level: Dictionary = raw.duplicate(true)
	var kinds: Array[int] = []
	for kind in raw["kinds"]:
		if not integer(kind, 0, 5) or kinds.has(int(kind)):
			return {}
		kinds.append(int(kind))
	level["kinds"] = kinds
	var powers: Array[int] = []
	if not raw.get("powers") is Array or not raw.get("nova") is bool:
		return {}
	for power in raw["powers"]:
		if not integer(power, 1, 4) or powers.has(int(power)):
			return {}
		powers.append(int(power))
	level["powers"] = powers
	var rocks: Dictionary = {}
	if not raw.get("asteroids") is Dictionary or not raw.get("star_scores") is Array or raw["star_scores"].size() != 3:
		return {}
	for key in raw["asteroids"]:
		if not str(key).is_valid_int() or not integer(int(key), 0, 63) or not integer(raw["asteroids"][key], 1, 2):
			return {}
		rocks[int(key)] = int(raw["asteroids"][key])
	level["asteroids"] = rocks
	var previous: int = -1
	for threshold in raw["star_scores"]:
		if not integer(threshold, 0, 1000000) or threshold <= previous:
			return {}
		previous = int(threshold)
	if raw["star_scores"][0] != 0:
		return {}
	if not raw.get("goals") is Array or raw["goals"].is_empty() or raw["goals"].size() > 3:
		return {}
	var types: Array[String] = []
	for goal in raw["goals"]:
		if not goal is Dictionary or not integer(goal.get("target"), 1, 1000):
			return {}
		var type_name: String = str(goal.get("type", ""))
		if type_name not in ["collect", "asteroids", "beams", "powers", "nova"] or types.has(type_name):
			return {}
		types.append(type_name)
		if type_name == "collect" and not integer(goal.get("kind", -1), -1, 5):
			return {}
		if type_name == "collect" and goal.get("kind", -1) >= 0 and not kinds.has(int(goal["kind"])):
			return {}
		if type_name == "asteroids" and goal["target"] != rocks.size():
			return {}
		if type_name == "beams" and not powers.has(1) and not powers.has(2):
			return {}
		if type_name == "powers" and powers.is_empty() or type_name == "nova" and not raw["nova"]:
			return {}
	if raw.get("opening", "") not in ["", "four_match"]:
		return {}
	if raw.get("opening", "") == "four_match" and kinds.size() != 6:
		return {}
	if not raw.get("starter_powers", {}) is Dictionary:
		return {}
	var starters: Dictionary = {}
	for key in raw.get("starter_powers", {}):
		if not str(key).is_valid_int() or not integer(int(key), 0, 63) or rocks.has(int(key)) or not integer(raw["starter_powers"][key], 1, 4) or not powers.has(int(raw["starter_powers"][key])):
			return {}
		starters[int(key)] = int(raw["starter_powers"][key])
	level["starter_powers"] = starters
	for key in ["id", "seed", "moves"]:
		level[key] = int(raw[key])
	return level


static func practice() -> Dictionary:
	return {"id": 0, "name": "Asteroid field", "seed": 20261029, "moves": 18,
		"kinds": [0, 1, 2, 3, 4, 5], "powers": [1, 2, 3, 4], "nova": true,
		"asteroids": {18: 2, 21: 2, 27: 1, 36: 1, 42: 2, 45: 2},
		"goals": [{"type": "collect", "kind": -1, "target": 30}, {"type": "asteroids", "target": 6}],
		"star_scores": [0, 1000, 1600], "tutorial": "Match beside asteroids to crack them", "starter_powers": {}}
