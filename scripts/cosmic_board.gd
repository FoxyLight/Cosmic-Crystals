extends "res://scripts/board.gd"
class_name CosmicBoard
## M2 special-piece and Nova rules. Extends the proven seeded M1 board.
## Parallel integer arrays keep rules independent of Godot scenes and tweens.
## Fixed asteroid durability is independent of crystal colors and powers.

const NONE: int = 0
const BEAM_ROW: int = 1
const BEAM_COLUMN: int = 2
const BOMB: int = 3
const SUPERNOVA: int = 4
const NOVA_MAX: int = 20

var specials: Array[int] = []
var nova_energy: int = 0
var asteroids: Array[int] = []


func _init(seed_value: int = 20261029) -> void:
	super(seed_value)
	specials.resize(WIDTH * HEIGHT)
	specials.fill(NONE)
	asteroids.resize(WIDTH * HEIGHT)
	asteroids.fill(0)


func is_blocked(index: int) -> bool:
	return index >= 0 and index < asteroids.size() and asteroids[index] > 0


func place_asteroids(layout: Dictionary) -> bool:
	# Explicit setup operation, never called during turns or deadlock recovery.
	# Reject the complete layout before mutation, including occupied powers.
	for key in layout:
		if not key is int or key < 0 or key >= cells.size():
			return false
		if not layout[key] is int or layout[key] < 1 or layout[key] > 2:
			return false
		if is_blocked(key) or specials[key] != NONE:
			return false
	for key in layout:
		asteroids[key] = int(layout[key])
		cells[key] = EMPTY
	return true


func _swappable(a: int, b: int) -> bool:
	return is_adjacent(a, b) and not is_blocked(a) and not is_blocked(b) \
		and cells[a] != EMPTY and cells[b] != EMPTY


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
	if not _swappable(a, b):
		return false
	# Specials are activated by swapping, even when colors do not match.
	if _special_at(a) != NONE or _special_at(b) != NONE:
		return true
	return super.would_match(a, b)


func play_swap(a: int, b: int) -> Dictionary:
	var result: Dictionary = _empty_result()
	if not _swappable(a, b):
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
		"activated": 0, "asteroids_hit": 0, "asteroids_destroyed": 0
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
		"specials_after": specials.duplicate(),
		"asteroids_before": asteroids.duplicate(),
		"asteroids_after": asteroids.duplicate()
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
		if cells[index] == EMPTY and not is_blocked(index):
			continue
		marked[index] = true
		if is_blocked(index):
			continue
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
		var hits: Dictionary = {}
		var gems: Array[int] = []
		for index in cleared:
			if is_blocked(index):
				hits[index] = true
			else:
				gems.append(index)
				_mark_adjacent_asteroids(index, hits)
		# The retained reward is still part of the matching group.
		if chain == 1 and not reward.is_empty():
			_mark_adjacent_asteroids(int(reward["index"]), hits)
		cleared = gems
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
		_damage_asteroids(hits, result, chain)
		_fall_with_powers(result["events"])
		pending = find_matches()

	if not is_nova:
		var gain: int = int(result["cleared"]) + int(result["activated"]) * 4
		result["nova_gain"] = mini(NOVA_MAX - nova_energy, gain)
		nova_energy = mini(NOVA_MAX, nova_energy + gain)
	# A deadlocked board must shuffle existing crystals, not generate 64 new
	# colors. Score, move budget, Nova energy and surviving powers stay intact.
	if not find_matches().is_empty():
		# Pathological MAX_CASCADES guard; do not hide unresolved effects by
		# silently replacing the whole board.
		push_warning("Maximum cascade count reached before the board settled")
	elif not has_legal_move():
		var before: Array[int] = cells.duplicate()
		var before_power: Array[int] = specials.duplicate()
		if _shuffle_deadlocked_board():
			result["reshuffled"] = true
			_event(result["events"], "reshuffle", before, before_power,
				{"reason": "no_legal_moves"})
		else:
			push_error("Could not reshuffle existing crystals into a playable board")


func _shuffle_deadlocked_board() -> bool:
	# Fisher-Yates over the existing inventory, so kind totals cannot change.
	# Fixed blockers never enter the movable inventory. Powers travel with gems.
	if not find_matches().is_empty() or has_legal_move():
		return false
	var original: Array[int] = cells.duplicate()
	var original_specials: Array[int] = specials.duplicate()
	var movable: Array[int] = []
	for index in range(cells.size()):
		if not is_blocked(index) and cells[index] != EMPTY:
			movable.append(index)
	for _attempt in range(2048):
		cells = original.duplicate()
		specials = original_specials.duplicate()
		for slot in range(movable.size() - 1, 0, -1):
			var i: int = movable[slot]
			var j: int = movable[rng.randi_range(0, slot)]
			var tmp: int = cells[i]
			cells[i] = cells[j]
			cells[j] = tmp
			var special_tmp: int = specials[i]
			specials[i] = specials[j]
			specials[j] = special_tmp
		if find_matches().is_empty() and has_legal_move():
			return true
	# Preserve the original board rather than fabricating a new gem inventory.
	cells = original
	specials = original_specials
	return false


func _fall_with_powers(events: Array) -> void:
	var before: Array[int] = cells.duplicate()
	var before_power: Array[int] = specials.duplicate()
	var moves: Array[Dictionary] = []
	var spawns: Array[Dictionary] = []
	for col in range(WIDTH):
		var bottom: int = HEIGHT - 1
		while bottom >= 0:
			if is_blocked(bottom * WIDTH + col):
				bottom -= 1
				continue
			var top: int = bottom
			while top > 0 and not is_blocked((top - 1) * WIDTH + col):
				top -= 1
			_fall_segment(col, top, bottom, before, before_power, moves, spawns)
			bottom = top - 1
	_event(events, "fall", before, before_power, {"moves": moves, "spawns": spawns})


func _fall_segment(col: int, top: int, bottom: int, before: Array[int],
		before_power: Array[int], moves: Array[Dictionary], spawns: Array[Dictionary]) -> void:
	var write_row: int = bottom
	for read_row in range(bottom, top - 1, -1):
		var src: int = read_row * WIDTH + col
		if before[src] == EMPTY:
			continue
		var dst: int = write_row * WIDTH + col
		cells[dst] = before[src]
		specials[dst] = before_power[src]
		moves.append({"from": src, "to": dst, "kind": before[src], "special": before_power[src]})
		write_row -= 1
	var remaining: int = write_row - top + 1
	while write_row >= top:
		var dst: int = write_row * WIDTH + col
		cells[dst] = rng.randi_range(0, KIND_COUNT - 1)
		specials[dst] = NONE
		spawns.append({"from_row": write_row - remaining, "to": dst,
			"kind": cells[dst], "special": NONE, "segment_top": top})
		write_row -= 1


func _mark_adjacent_asteroids(index: int, hits: Dictionary) -> void:
	for neighbor in [index - WIDTH, index + WIDTH, index - 1, index + 1]:
		if is_adjacent(index, neighbor) and is_blocked(neighbor):
			hits[neighbor] = true


func _damage_asteroids(hits: Dictionary, result: Dictionary, chain: int) -> void:
	if hits.is_empty():
		return
	var before: Array[int] = asteroids.duplicate()
	var indices: Array[int] = []
	var destroyed: Array[int] = []
	for key in hits:
		var index: int = int(key)
		asteroids[index] -= 1
		indices.append(index)
		if asteroids[index] == 0:
			destroyed.append(index)
	indices.sort()
	destroyed.sort()
	result["asteroids_hit"] = int(result["asteroids_hit"]) + indices.size()
	result["asteroids_destroyed"] = int(result["asteroids_destroyed"]) + destroyed.size()
	_event(result["events"], "asteroid_hit", cells, specials,
		{"asteroids_before": before, "indices": indices, "destroyed": destroyed, "chain": chain})
