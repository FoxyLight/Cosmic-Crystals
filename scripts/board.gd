extends RefCounted
class_name CrystalBoard
## Seeded board rules. This class has no scene, animation or input dependencies.

const WIDTH: int = 8
const HEIGHT: int = 8
const KIND_COUNT: int = 6
const EMPTY: int = -1
const MAX_CASCADES: int = 80

var cells: Array[int] = []
var kinds: Array[int] = [0, 1, 2, 3, 4, 5]
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(seed_value: int = 20261029) -> void:
	rng.seed = seed_value
	generate()


func generate() -> void:
	# Never start with automatic matches or an unplayable board.
	for _attempt in range(512):
		cells.clear()
		cells.resize(WIDTH * HEIGHT)
		for i in range(cells.size()):
			var choices: Array[int] = []
			for kind in kinds:
				if not _forms_starting_run(i, kind):
					choices.append(kind)
			cells[i] = choices[rng.randi_range(0, choices.size() - 1)]
		if has_legal_move():
			return
	push_error("Could not generate playable board within 512 attempts")


func _forms_starting_run(index: int, kind: int) -> bool:
	var row: int = int(index / WIDTH)
	var col: int = index % WIDTH
	return (
		(col >= 2 and cells[index - 1] == kind and cells[index - 2] == kind)
		or (row >= 2 and cells[index - WIDTH] == kind and cells[index - WIDTH * 2] == kind)
	)


func is_adjacent(a: int, b: int) -> bool:
	if a < 0 or b < 0 or a >= cells.size() or b >= cells.size():
		return false
	var ar: int = int(a / WIDTH)
	var br: int = int(b / WIDTH)
	return absi(ar - br) + absi(a % WIDTH - b % WIDTH) == 1


func _swap(a: int, b: int) -> void:
	var temp: int = cells[a]
	cells[a] = cells[b]
	cells[b] = temp


func find_matches() -> Array[int]:
	# A union of all horizontal and vertical runs. Intersections count only once.
	var marked: Dictionary = {}
	for row in range(HEIGHT):
		var start: int = 0
		while start < WIDTH:
			var kind: int = cells[row * WIDTH + start]
			var finish: int = start + 1
			while finish < WIDTH and cells[row * WIDTH + finish] == kind:
				finish += 1
			if kind != EMPTY and finish - start >= 3:
				for col in range(start, finish):
					marked[row * WIDTH + col] = true
			start = finish
	for col in range(WIDTH):
		var start: int = 0
		while start < HEIGHT:
			var kind: int = cells[start * WIDTH + col]
			var finish: int = start + 1
			while finish < HEIGHT and cells[finish * WIDTH + col] == kind:
				finish += 1
			if kind != EMPTY and finish - start >= 3:
				for row in range(start, finish):
					marked[row * WIDTH + col] = true
			start = finish
	var found: Array[int] = []
	for key in marked:
		found.append(int(key))
	found.sort()
	return found


func would_match(a: int, b: int) -> bool:
	if not is_adjacent(a, b) or cells[a] == cells[b]:
		return false
	_swap(a, b)
	var valid: bool = not find_matches().is_empty()
	_swap(a, b)
	return valid


func find_legal_swap() -> Vector2i:
	for row in range(HEIGHT):
		for col in range(WIDTH):
			var a: int = row * WIDTH + col
			if col + 1 < WIDTH and would_match(a, a + 1):
				return Vector2i(a, a + 1)
			if row + 1 < HEIGHT and would_match(a, a + WIDTH):
				return Vector2i(a, a + WIDTH)
	return Vector2i(-1, -1)


func has_legal_move() -> bool:
	return find_legal_swap().x != -1


func play_swap(a: int, b: int) -> Dictionary:
	# 'events' encode sequential, immutable before/after snapshots for the renderer.
	# The entire turn is resolved synchronously; animation never changes game rules.
	var outcome: Dictionary = {
		"valid": false,
		"cleared": 0,
		"cascades": 0,
		"score": 0,
		"collected": {},
		"reshuffled": false,
		"events": []
	}
	if not is_adjacent(a, b) or cells[a] == cells[b]:
		return outcome

	var before_swap: Array[int] = cells.duplicate()
	_swap(a, b)
	var after_swap: Array[int] = cells.duplicate()
	outcome["events"].append({
		"type": "swap",
		"before": before_swap,
		"after": after_swap,
		"a": a,
		"b": b
	})
	if find_matches().is_empty():
		_swap(a, b)
		outcome["events"].append({
			"type": "swap_back",
			"before": after_swap,
			"after": before_swap,
			"a": a,
			"b": b
		})
		return outcome

	outcome["valid"] = true
	for chain in range(1, MAX_CASCADES + 1):
		var matched: Array[int] = find_matches()
		if matched.is_empty():
			break
		var before_clear: Array[int] = cells.duplicate()
		var collected: Dictionary = outcome["collected"]
		for index in matched:
			var kind: int = cells[index]
			collected[kind] = int(collected.get(kind, 0)) + 1
			cells[index] = EMPTY

		var score_delta: int = matched.size() * 10 * chain
		outcome["cascades"] = chain
		outcome["cleared"] = int(outcome["cleared"]) + matched.size()
		outcome["score"] = int(outcome["score"]) + score_delta
		outcome["events"].append({
			"type": "clear",
			"before": before_clear,
			"after": cells.duplicate(),
			"indices": matched.duplicate(),
			"chain": chain,
			"score_delta": score_delta
		})
		_apply_gravity_and_refill(outcome["events"])

	# Defensive escape from a pathological chain that fails to settle.
	if not find_matches().is_empty() or not has_legal_move():
		var prior: Array[int] = cells.duplicate()
		generate()  # Safe only in the current blocker-free prototype.
		outcome["reshuffled"] = true
		outcome["events"].append({
			"type": "reshuffle",
			"before": prior,
			"after": cells.duplicate()
		})
	return outcome


func _apply_gravity_and_refill(events: Array) -> void:
	var before_drop: Array[int] = cells.duplicate()
	var moves: Array[Dictionary] = []
	var spawns: Array[Dictionary] = []
	for col in range(WIDTH):
		var write_row: int = HEIGHT - 1
		for read_row in range(HEIGHT - 1, -1, -1):
			var from_index: int = read_row * WIDTH + col
			var kind: int = before_drop[from_index]
			if kind != EMPTY:
				var to_index: int = write_row * WIDTH + col
				cells[to_index] = kind
				moves.append({"from": from_index, "to": to_index, "kind": kind})
				write_row -= 1
		# Each new piece starts above the board, with its own offset.
		var remaining: int = write_row + 1
		while write_row >= 0:
			var to_index: int = write_row * WIDTH + col
			var kind: int = random_kind()
			cells[to_index] = kind
			spawns.append({
				"from_row": write_row - remaining,
				"to": to_index,
				"kind": kind
			})
			write_row -= 1
	events.append({
		"type": "fall",
		"before": before_drop,
		"after": cells.duplicate(),
		"moves": moves,
		"spawns": spawns
	})


func random_kind() -> int:
	return kinds[rng.randi_range(0, kinds.size() - 1)]
