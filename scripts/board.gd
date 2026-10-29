extends RefCounted
class_name CrystalBoard
## Pure, seeded 8x8 match-3 rules. No Godot scene/node dependencies.

const WIDTH: int = 8
const HEIGHT: int = 8
const KIND_COUNT: int = 6
const EMPTY: int = -1
const MAX_CASCADES: int = 80

var cells: Array[int] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(seed_value: int = 20261029) -> void:
	rng.seed = seed_value
	generate()


func generate() -> void:
	# Avoid initial matches and ensure the player always has a legal move.
	for attempt in range(512):
		cells.clear()
		cells.resize(WIDTH * HEIGHT)
		for i in range(cells.size()):
			var choices: Array[int] = []
			for kind in range(KIND_COUNT):
				if not _forms_starting_run(i, kind):
					choices.append(kind)
			cells[i] = choices[rng.randi_range(0, choices.size() - 1)]
		if has_legal_move():
			return
	push_error("Could not generate playable board with the allotted attempts.")


func _forms_starting_run(index: int, kind: int) -> bool:
	var row: int = int(index / WIDTH)
	var col: int = index % WIDTH
	if col >= 2 and cells[index - 1] == kind and cells[index - 2] == kind:
		return true
	if row >= 2 and cells[index - WIDTH] == kind and cells[index - WIDTH * 2] == kind:
		return true
	return false


func is_adjacent(a: int, b: int) -> bool:
	if a < 0 or b < 0 or a >= cells.size() or b >= cells.size():
		return false
	var ar: int = int(a / WIDTH)
	var br: int = int(b / WIDTH)
	return absi(ar - br) + absi((a % WIDTH) - (b % WIDTH)) == 1


func _swap(a: int, b: int) -> void:
	var temp: int = cells[a]
	cells[a] = cells[b]
	cells[b] = temp


func find_matches() -> Array[int]:
	# Union of all 3+ horizontal and vertical runs.
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
	var result: Array[int] = []
	for key in marked.keys():
		result.append(int(key))
	result.sort()
	return result


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
	return find_legal_swap().x >= 0


func play_swap(a: int, b: int) -> Dictionary:
	var outcome: Dictionary = {
		"valid": false,
		"cleared": 0,
		"cascades": 0,
		"score": 0,
		"collected": {},
		"reshuffled": false
	}
	if not is_adjacent(a, b) or cells[a] == cells[b]:
		return outcome
	_swap(a, b)
	if find_matches().is_empty():
		_swap(a, b)
		return outcome

	outcome["valid"] = true
	var chain: int = 0
	while chain < MAX_CASCADES:
		var matched: Array[int] = find_matches()
		if matched.is_empty():
			break
		chain += 1
		outcome["cascades"] = chain
		outcome["cleared"] = int(outcome["cleared"]) + matched.size()
		outcome["score"] = int(outcome["score"]) + matched.size() * 10 * chain
		var collected: Dictionary = outcome["collected"]
		for index in matched:
			var kind: int = cells[index]
			collected[kind] = int(collected.get(kind, 0)) + 1
			cells[index] = EMPTY
		_apply_gravity_and_refill()

	if chain == MAX_CASCADES and not find_matches().is_empty():
		# Defensive fallback: never leave an indefinitely cascading board.
		generate()
		outcome["reshuffled"] = true
	elif not has_legal_move():
		# Prototype has no blockers/special pieces yet; a fresh legal board is safe.
		generate()
		outcome["reshuffled"] = true
	return outcome


func _apply_gravity_and_refill() -> void:
	for col in range(WIDTH):
		var write_row: int = HEIGHT - 1
		for read_row in range(HEIGHT - 1, -1, -1):
			var kind: int = cells[read_row * WIDTH + col]
			if kind != EMPTY:
				cells[write_row * WIDTH + col] = kind
				write_row -= 1
		while write_row >= 0:
			cells[write_row * WIDTH + col] = rng.randi_range(0, KIND_COUNT - 1)
			write_row -= 1
