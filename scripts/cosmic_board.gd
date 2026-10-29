extends "res://scripts/board.gd"
class_name CosmicBoard
## M2 special-piece and Nova rules. Extends the proven seeded M1 board.
## Parallel integer arrays keep rules independent of Godot scenes and tweens.
## This is a blocker-free slice: asteroid rules are a separate M2 deliverable.

const NONE: int = 0
const BEAM_ROW: int = 1
const BEAM_COLUMN: int = 2
const BOMB: int = 3
const SUPERNOVA: int = 4
const NOVA_MAX: int = 20

var specials: Array[int] = []
var nova_energy: int = 0


func _init(seed_value: int = 20261029) -> void:
	super(seed_value)
	specials.resize(WIDTH * HEIGHT)
	specials.fill(NONE)


func _special_at(index: int) -> int:
	if index < 0 or index >= specials.size():
		return NONE
	return specials[index]


func _swap_both(a: int, b: int) -> void:
	_swap(a, b)
	var previous: int = specials[a]
	specials[a] = specials[b]
	specials[b] = previous


func would_match(a: int, b: int) -> bool:
	if not is_adjacent(a, b):
		return false
	# Specials are activated by swapping, even when colors do not match.
	if _special_at(a) != NONE or _special_at(b) != NONE:
		return true
	return super.would_match(a, b)


func play_swap(a: int, b: int) -> Dictionary:
	var result: Dictionary = _empty_result()
	if not is_adjacent(a, b):
		return result
	var before: Array[int] = cells.duplicate()
	var before_power: Array[int] = specials.duplicate()
	var original_a_kind: int = cells[a]
	var original_b_kind: int = cells[b]
	var original_a_special: int = specials[a]
	var original_b_special: int = specials[b]
	if original_a_kind == original_b_kind and original_a_special == NONE and original_b_special == NONE:
		return result

	_swap_both(a, b)
	_event(result["events"], "swap", before, before_power, {"a": a, "b": b})
	var matched: Array[int] = find_matches()
	var activating: bool = original_a_special != NONE or original_b_special != NONE
	if matched.is_empty() and not activating:
		var reversed_cells: Array[int] = cells.duplicate()
		var reversed_powers: Array[int] = specials.duplicate()
		_swap_both(a, b)
		_event_from(result["events"], "swap_back", reversed_cells, reversed_powers,
			{"a": a, "b": b})
		return result

	result["valid"] = true
	# A directly swapped Supernova targets the other piece's color.
	# A Supernova hit later by a beam/bomb targets its OWN color.
	var target_kind: int = -1
	var focus_index: int = -1
	if original_a_special == SUPERNOVA:
		target_kind = original_b_kind
		focus_index = b
	elif original_b_special == SUPERNOVA:
		target_kind = original_a_kind
		focus_index = a
	var full_board: bool = original_a_special == SUPERNOVA and original_b_special == SUPERNOVA
	var seeds: Array[int] = matched.duplicate()
	if activating:
		if specials[b] != NONE and not seeds.has(b):
			seeds.append(b)
		if specials[a] != NONE and not seeds.has(a):
			seeds.append(a)
		if full_board:
			for i in range(cells.size()):
				if not seeds.has(i):
					seeds.append(i)
	# Only regular player-caused matches may create a new power. Cascades do not.
	var reward: Dictionary = {}
	if not activating:
		reward = _find_reward(matched, a, b)
	if not reward.is_empty():
		seeds.erase(int(reward["index"]))
		# No accidental activation of a power created by this same turn.
	_resolve(seeds, result, reward, target_kind, false, focus_index)
	return result


func can_use_nova() -> bool:
	return nova_energy >= NOVA_MAX


func use_nova(target: int) -> Dictionary:
	var result: Dictionary = _empty_result()
	if not can_use_nova() or target < 0 or target >= cells.size():
		return result
	nova_energy = 0
	result["valid"] = true
	result["used_nova"] = true
	var seeds: Array[int] = []
	var col: int = target % WIDTH
	var row: int = int(target / WIDTH)
	for i in range(cells.size()):
		if int(i / WIDTH) == row or i % WIDTH == col:
			seeds.append(i)
	_resolve(seeds, result, {}, -1, true)
	return result


func _empty_result() -> Dictionary:
	return {
		"valid": false, "cleared": 0, "score": 0, "cascades": 0,
		"collected": {}, "reshuffled": false, "events": [],
		"used_nova": false, "nova_gain": 0, "created": NONE,
		"activated": 0
	}


func _event(events: Array, type_name: String, before: Array[int],
		before_power: Array[int], details: Dictionary = {}) -> void:
	_event_from(events, type_name, before, before_power, details)


func _event_from(events: Array, type_name: String, before: Array[int],
		before_power: Array[int], details: Dictionary = {}) -> void:
	var event: Dictionary = {
		"type": type_name,
		"before": before.duplicate(),
		"after": cells.duplicate(),
		"specials_before": before_power.duplicate(),
		"specials_after": specials.duplicate()
	}
	for key in details:
		event[key] = details[key]
	events.append(event)


func _run_length(index: int, horizontal: bool) -> int:
	var kind: int = cells[index]
	if kind == EMPTY:
		return 0
	var row: int = int(index / WIDTH)
	var col: int = index % WIDTH
	var count: int = 1
	if horizontal:
		var x: int = col - 1
		while x >= 0 and cells[row * WIDTH + x] == kind:
			count += 1
			x -= 1
		x = col + 1
		while x < WIDTH and cells[row * WIDTH + x] == kind:
			count += 1
			x += 1
	else:
		var y: int = row - 1
		while y >= 0 and cells[y * WIDTH + col] == kind:
			count += 1
			y -= 1
		y = row + 1
		while y < HEIGHT and cells[y * WIDTH + col] == kind:
			count += 1
			y += 1
	return count


func _find_reward(matched: Array[int], a: int, b: int) -> Dictionary:
	var best_score: int = 0
	var best_kind: int = NONE
	var best_index: int = -1
	# The swapped destination wins ties; then source, then row-major.
	var ordered: Array[int] = []
	for i in [b, a]:
		if matched.has(i) and not ordered.has(i):
			ordered.append(i)
	for i in matched:
		if not ordered.has(i):
			ordered.append(i)
	for index in ordered:
		var h: int = _run_length(index, true)
		var v: int = _run_length(index, false)
		var score: int = 0
		var kind: int = NONE
		if h >= 5 or v >= 5:
			score = 3
			kind = SUPERNOVA
		elif h >= 3 and v >= 3:
			score = 2
			kind = BOMB
		elif h >= 4 or v >= 4:
			score = 1
			kind = BEAM_ROW if h >= 4 else BEAM_COLUMN
		if score > best_score:
			best_score = score
			best_kind = kind
			best_index = index
	if best_index == -1:
		return {}
	return {"index": best_index, "kind": best_kind}


func _expand_seeds(initial: Array[int], result: Dictionary,
		target_kind: int, focus_index: int) -> Array[int]:
	# All effect areas are unioned BEFORE clearing. Chains are evaluated once.
	var marked: Dictionary = {}
	var pending: Array[int] = initial.duplicate()
	var head: int = 0
	while head < pending.size():
		var index: int = pending[head]
		head += 1
		if index < 0 or index >= cells.size() or marked.has(index):
			continue
		if cells[index] == EMPTY:
			continue
		marked[index] = true
		var special: int = specials[index]
		if special == NONE:
			continue
		result["activated"] = int(result["activated"]) + 1
		var row: int = int(index / WIDTH)
		var col: int = index % WIDTH
		match special:
			BEAM_ROW:
				for c in range(WIDTH):
					pending.append(row * WIDTH + c)
			BEAM_COLUMN:
				for r in range(HEIGHT):
					pending.append(r * WIDTH + col)
			BOMB:
				for r in range(maxi(0, row - 1), mini(HEIGHT, row + 2)):
					for c in range(maxi(0, col - 1), mini(WIDTH, col + 2)):
						pending.append(r * WIDTH + c)
			SUPERNOVA:
				var wanted: int = target_kind if index == focus_index and target_kind >= 0 else cells[index]
				for i in range(cells.size()):
					if cells[i] == wanted:
						pending.append(i)
	var cleared: Array[int] = []
	for index in marked:
		cleared.append(int(index))
	cleared.sort()
	return cleared


func _resolve(initial: Array[int], result: Dictionary, reward: Dictionary,
		target_kind: int, is_nova: bool, focus_index: int = -1) -> void:
	var pending: Array[int] = initial.duplicate()
	for chain in range(1, MAX_CASCADES + 1):
		if pending.is_empty():
			break
		var cleared: Array[int] = _expand_seeds(pending, result, target_kind, focus_index)
		if cleared.is_empty():
			break
		var before: Array[int] = cells.duplicate()
		var before_power: Array[int] = specials.duplicate()
		var totals: Dictionary = result["collected"]
		for index in cleared:
			var kind: int = cells[index]
			totals[kind] = int(totals.get(kind, 0)) + 1
			cells[index] = EMPTY
			specials[index] = NONE
		var points: int = cleared.size() * 10 * chain
		result["score"] = int(result["score"]) + points
		result["cleared"] = int(result["cleared"]) + cleared.size()
		result["cascades"] = chain
		_event(result["events"], "clear", before, before_power,
			{"indices": cleared.duplicate(), "chain": chain, "score_delta": points})

		if chain == 1 and not reward.is_empty():
			var anchor: int = int(reward["index"])
			if cells[anchor] != EMPTY:
				before = cells.duplicate()
				before_power = specials.duplicate()
				specials[anchor] = int(reward["kind"])
				result["created"] = int(reward["kind"])
				_event(result["events"], "special_create", before, before_power,
					{"index": anchor, "kind": int(reward["kind"])})
		_fall_with_powers(result["events"])
		pending = find_matches()

	if not is_nova:
		var gain: int = int(result["cleared"]) + int(result["activated"]) * 4
		result["nova_gain"] = mini(NOVA_MAX - nova_energy, gain)
		nova_energy = mini(NOVA_MAX, nova_energy + gain)
	# Existing special pieces are enough to make a swap legal. Never delete them
	# on deadlock recovery. With no powers left, original seeded fallback is safe.
	if not find_matches().is_empty() or not has_legal_move():
		var before: Array[int] = cells.duplicate()
		var before_power: Array[int] = specials.duplicate()
		if specials.has(BEAM_ROW) or specials.has(BEAM_COLUMN) or specials.has(BOMB) or specials.has(SUPERNOVA):
			# A spontaneous match after max cascade count can be retried later,
			# but do not destroy earned specials. This case should be unreachable
			# except an extreme MAX_CASCADES chain.
			push_warning("Cascade guard reached with special pieces still present")
		else:
			super.generate()
			specials.fill(NONE)
			result["reshuffled"] = true
			_event(result["events"], "reshuffle", before, before_power)


func _fall_with_powers(events: Array) -> void:
	var before: Array[int] = cells.duplicate()
	var before_power: Array[int] = specials.duplicate()
	var moves: Array[Dictionary] = []
	var spawns: Array[Dictionary] = []
	for col in range(WIDTH):
		var write_row: int = HEIGHT - 1
		for read_row in range(HEIGHT - 1, -1, -1):
			var src: int = read_row * WIDTH + col
			if before[src] == EMPTY:
				continue
			var dst: int = write_row * WIDTH + col
			cells[dst] = before[src]
			specials[dst] = before_power[src]
			moves.append({"from": src, "to": dst, "kind": before[src], "special": before_power[src]})
			write_row -= 1
		var remaining: int = write_row + 1
		while write_row >= 0:
			var dst: int = write_row * WIDTH + col
			cells[dst] = rng.randi_range(0, KIND_COUNT - 1)
			specials[dst] = NONE
			spawns.append({"from_row": write_row - remaining, "to": dst,
				"kind": cells[dst], "special": NONE})
			write_row -= 1
	_event(events, "fall", before, before_power, {"moves": moves, "spawns": spawns})
