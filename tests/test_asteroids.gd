extends SceneTree
## Deterministic blocker regression, complete event replay and seeded turns.
const Board = preload("res://scripts/cosmic_board.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run()
	print("M2 asteroids: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Asteroids: " + message)


func _fixture(seed_value: int = 401):
	var b = Board.new(seed_value)
	for r in range(8):
		for c in range(8):
			b.cells[r * 8 + c] = (r * 2 + c) % 6
	return b


func _first_hit(outcome: Dictionary) -> Dictionary:
	for e in outcome["events"]:
		if e["type"] == "asteroid_hit":
			return e
	return {}


func _inventory(b) -> Dictionary:
	var counts: Dictionary = {}
	for i in range(64):
		if b.cells[i] >= 0:
			var key: String = "%d:%d" % [b.cells[i], b.specials[i]]
			counts[key] = int(counts.get(key, 0)) + 1
	return counts


func _verify_events(b, outcome: Dictionary, gems: Array, powers: Array, rocks: Array) -> void:
	var total: int = 0
	var points: int = 0
	var destroyed: int = 0
	var hit_count: int = 0
	var previous_type: String = ""
	for e in outcome["events"]:
		_check(e["before"] == gems and e["specials_before"] == powers
			and e["asteroids_before"] == rocks, "All three event snapshots are continuous")
		if e["type"] == "asteroid_hit":
			_check(previous_type == "clear" or previous_type == "special_create", "Damage follows clearing/reward, before gravity")
			var unique: Dictionary = {}
			for i in e["indices"]:
				unique[i] = true
			_check(e["indices"].size() == unique.size(), "Damage indices unique")
			for i in e["indices"]:
				_check(e["asteroids_after"][i] == rocks[i] - 1, "Exactly one hit per wave")
			destroyed += e["destroyed"].size()
			hit_count += e["indices"].size()
		elif e["type"] == "clear":
			total += e["indices"].size()
			points += e["score_delta"]
			_check(e["score_delta"] == e["indices"].size() * 10 * e["chain"], "Only crystals score")
			for i in e["indices"]:
				_check(rocks[i] == 0 and gems[i] >= 0, "Rocks never counted as crystal clears")
		elif e["type"] == "fall":
			for move in e["moves"]:
				var src: int = int(move["from"])
				var dst: int = int(move["to"])
				_check(src % 8 == dst % 8 and dst >= src, "Gravity stays in its column and moves down")
				for i in range(src, dst + 1, 8):
					_check(rocks[i] == 0, "Falling gems cannot cross a blocker")
				_check(gems[src] == e["after"][dst] and powers[src] == e["specials_after"][dst], "Gravity preserves gem/power pair")
			for spawn in e["spawns"]:
				_check(rocks[spawn["to"]] == 0, "Never refill an occupied blocker cell")
		gems = e["after"]
		powers = e["specials_after"]
		rocks = e["asteroids_after"]
		for i in range(64):
			_check(rocks[i] == 0 or (gems[i] == Board.EMPTY and powers[i] == Board.NONE), "Blocker occupancy invariant in every frame")
		previous_type = e["type"]
	_check(gems == b.cells and powers == b.specials and rocks == b.asteroids, "Replay reaches model")
	_check(total == outcome["cleared"] and points == outcome["score"], "Score/collection exact")
	_check(destroyed == outcome["asteroids_destroyed"] and hit_count == outcome["asteroids_hit"], "Damage totals exact")
	_check(b.find_matches().is_empty() and b.has_legal_move(), "Turn settles playable")
	for i in range(64):
		_check(b.is_blocked(i) or b.cells[i] >= 0, "No empty playable cell after refill")


func _blast(b, seeds: Array[int]) -> Dictionary:
	var gems: Array = b.cells.duplicate()
	var powers: Array = b.specials.duplicate()
	var rocks: Array = b.asteroids.duplicate()
	var outcome: Dictionary = b._empty_result()
	b._resolve(seeds, outcome, {}, -1, false)
	_verify_events(b, outcome, gems, powers, rocks)
	return outcome


func _run() -> void:
	var b = _fixture()
	_check(b.place_asteroids({27: 2, 28: 1}), "Place supported durability states")
	_check(b.cells[27] == Board.EMPTY and b.specials[27] == Board.NONE, "Blocker state separate from colors and powers")
	var before: Array = b.cells.duplicate()
	_check(not b.place_asteroids({1: 1, 64: 2}) and before == b.cells, "Invalid layout is atomic")
	b.specials[1] = Board.BOMB
	_check(not b.place_asteroids({1: 1}), "Setup never deletes an earned power")
	_check(not b.would_match(26, 27) and not b.would_match(27, 28), "Blockers never swappable")
	var bad: Dictionary = b.play_swap(26, 27)
	_check(not bad["valid"] and bad["events"].is_empty() and before == b.cells, "Blocked swap is no-op")
	_check(bad["score"] == 0 and bad["nova_gain"] == 0, "Blocked swap gives no score/energy")
	b.cells[25] = 3
	b.cells[26] = 3
	b.cells[29] = 3
	_check(not b.find_matches().has(25) and not b.find_matches().has(26), "A blocker interrupts a potential same-color run")
	for i in [24, 25, 26, 29, 30, 31]:
		b.cells[i] = 3
	_check(not b.find_matches().has(27) and not b.find_matches().has(28), "No matching through blockers")

	# Three matched crystals against one rock still cause only one damage.
	var adjacent = _fixture(402)
	adjacent.place_asteroids({27: 2})
	for i in [18, 19, 20]:
		adjacent.cells[i] = 1
	var adjacent_out: Dictionary = _blast(adjacent, [18, 19, 20])
	var hit: Dictionary = _first_hit(adjacent_out)
	_check(hit["asteroids_before"][27] == 2 and hit["asteroids_after"][27] == 1, "Adjacent clear damages armored rock")
	# Direct second wave destroys whatever durability remains; use fresh fixture
	# so cascades from the first test cannot obscure the exact expectation.
	var damaged = _fixture(403)
	damaged.place_asteroids({27: 1})
	var damage_out: Dictionary = _blast(damaged, [27])
	_check(_first_hit(damage_out)["destroyed"] == [27], "Second durability state destroys and refills")
	_check(damage_out["events"][0]["indices"].is_empty(), "Rock-only hit earns zero crystal points in that wave")
	_check(damage_out["events"][0]["score_delta"] == 0, "No blocker score inflation")
	var repeated = _fixture(404)
	repeated.place_asteroids({27: 2})
	_blast(repeated, [27])
	_check(repeated.asteroids[27] == 1, "First independent wave cracks armored rock")
	_blast(repeated, [27])
	_check(repeated.asteroids[27] == 0, "Later wave destroys the same rock")
	var edges = _fixture(405)
	edges.place_asteroids({8: 2, 17: 2})
	var edge_out: Dictionary = _blast(edges, [7])
	_check(_first_hit(edge_out).is_empty(), "Adjacency never wraps a row or hits diagonally")
	var matched = _fixture(406)
	matched.place_asteroids({11: 2})
	matched.cells[18] = 1
	matched.cells[19] = 2
	matched.cells[20] = 1
	matched.cells[27] = 1
	var normal: Dictionary = matched.play_swap(27, 19)
	_check(normal["valid"] and _first_hit(normal)["indices"].has(11), "Actual adjacent player match damages blocker")
	for power in [Board.BEAM_ROW, Board.BEAM_COLUMN]:
		var line = _fixture(407 + power)
		line.place_asteroids({25: 2, 31: 2} if power == Board.BEAM_ROW else {11: 2, 59: 2})
		line.specials[27] = power
		var out: Dictionary = _blast(line, [27])
		_check(_first_hit(out)["indices"] == ([25, 31] if power == Board.BEAM_ROW else [11, 59]), "Beam reaches distant rocks and continues past them")

	for power in [Board.BEAM_ROW, Board.BEAM_COLUMN, Board.BOMB, Board.SUPERNOVA]:
		var powered = _fixture(410 + power)
		powered.place_asteroids({26: 2, 28: 2, 19: 2, 35: 2})
		powered.specials[27] = power
		var out: Dictionary = _blast(powered, [27])
		var hits: Dictionary = _first_hit(out)
		_check(not hits.is_empty() and hits["indices"].has(26), "Every power interacts with adjacent blockers")
		_check(out["activated"] >= 1, "Power still activates")

	# Exhaustive ordered pairs with rocks in both direct and adjacent footprints.
	for left in range(1, 5):
		for right in range(1, 5):
			var combo = _fixture(500 + left * 4 + right)
			combo.place_asteroids({19: 2, 20: 2, 26: 2, 29: 2, 35: 2, 36: 2})
			combo.specials[27] = left
			combo.specials[28] = right
			var gems: Array = combo.cells.duplicate()
			var powers: Array = combo.specials.duplicate()
			var rocks: Array = combo.asteroids.duplicate()
			var out: Dictionary = combo.play_swap(27, 28)
			_check(out["valid"] and out["activated"] >= 2, "All ordered combos still activate with blockers")
			_verify_events(combo, out, gems, powers, rocks)
			var first: Dictionary = _first_hit(out)
			_check(not first.is_empty(), "Combo damages blockers")
			for i in first["indices"]:
				_check(first["asteroids_after"][i] == 1, "Overlapping combo/adjacency not multi-hit")

	var nova = _fixture(601)
	nova.place_asteroids({27: 2, 3: 2, 24: 1, 63: 2})
	nova.specials[29] = Board.BOMB
	nova.specials[21] = Board.BEAM_COLUMN
	nova.nova_energy = Board.NOVA_MAX
	var ng: Array = nova.cells.duplicate()
	var np: Array = nova.specials.duplicate()
	var nr: Array = nova.asteroids.duplicate()
	var no: Dictionary = nova.use_nova(27)
	_verify_events(nova, no, ng, np, nr)
	_check(no["valid"] and nova.nova_energy == 0 and no["nova_gain"] == 0, "Nova targets a rock without recharging")
	_check(_first_hit(no)["indices"].has(3) and _first_hit(no)["indices"].has(27), "Nova passes through blockers in cross")
	_check(_first_hit(no)["destroyed"].has(24), "Nova destroys cracked blocker")
	_check(no["activated"] >= 2, "Nova chains powers around blockers")

	# Dense adversarial chain: every movable gem is a power; all 58 powers
	# trigger once, while six direct/adjacent rock overlaps remain single hits.
	var dense = _fixture(650)
	dense.place_asteroids({18: 2, 21: 2, 27: 2, 36: 2, 42: 2, 45: 2})
	for i in range(64):
		if not dense.is_blocked(i):
			dense.specials[i] = Board.BEAM_ROW
	dense.specials[0] = Board.BEAM_COLUMN
	dense.specials[9] = Board.BEAM_COLUMN
	var dense_out: Dictionary = _blast(dense, [0])
	_check(dense_out["activated"] == 58, "Long chain activates each of 58 powers exactly once")
	_check(dense_out["events"][0]["indices"].size() == 58 and dense_out["events"][0]["score_delta"] == 580, "Dense blast counts only 58 unique crystals")
	_check(_first_hit(dense_out)["indices"].size() == 6, "Dense chain hits all six blockers in one wave")
	for i in _first_hit(dense_out)["indices"]:
		_check(_first_hit(dense_out)["asteroids_after"][i] == 1, "Many overlapping powers still cause one damage")

	# Segmented physics: no piece crosses row 3's rock, a power falls within
	# the lower region, and new pieces refill both regions independently.
	var gravity = _fixture(701)
	gravity.place_asteroids({27: 2, 51: 1})
	gravity.cells[19] = Board.EMPTY
	gravity.cells[43] = Board.EMPTY
	gravity.specials[35] = Board.BOMB
	var events: Array = []
	gravity._fall_with_powers(events)
	_check(gravity.asteroids[27] == 2 and gravity.cells[27] == Board.EMPTY, "Gravity keeps fixed rock")
	_check(gravity.specials[43] == Board.BOMB, "Power falls within its segment")
	for move in events[0]["moves"]:
		if int(move["from"]) % 8 == 3:
			_check(not (int(move["from"]) < 27 and int(move["to"]) > 27), "Upper gems cannot cross rock")
	_check(events[0]["spawns"].size() == 2, "Refill only actual holes")
	var lower_spawn: bool = false
	for spawn in events[0]["spawns"]:
		if spawn["to"] == 35:
			lower_spawn = spawn["segment_top"] == 4
	_check(lower_spawn, "Lower refill carries region boundary for renderer")

	var dead = _fixture(801)
	dead.place_asteroids({18: 2, 21: 2, 27: 1, 36: 1, 42: 2, 45: 2})
	var inventory: Dictionary = _inventory(dead)
	var fixed: Array = dead.asteroids.duplicate()
	dead.nova_energy = 13
	_check(not dead.has_legal_move(), "Blocked deadlock fixture is real")
	var recovery: Dictionary = _blast(dead, [])
	_check(recovery["reshuffled"] and _inventory(dead) == inventory, "Recovery preserves exact inventory")
	_check(dead.asteroids == fixed and dead.nova_energy == 13, "Recovery retains durability/energy")
	# Shuffle retains an isolated earned special too, without manufacturing colors.
	var isolated = _fixture(802)
	isolated.place_asteroids({1: 2, 8: 2})
	isolated.specials[0] = Board.BOMB
	var earned: Dictionary = _inventory(isolated)
	_check(not isolated.has_legal_move(), "Isolated power does not create an illegal move")
	_check(isolated._shuffle_deadlocked_board() and _inventory(isolated) == earned, "Recovery preserves earned power/color pairs")

	# 125 seeds x 12 turns, paired determinism, event replay and blockers.
	for seed_value in range(125):
		var first = Board.new(1000 + seed_value)
		var second = Board.new(1000 + seed_value)
		var layout: Dictionary = {18: 2, 21: 2, 27: 1, 36: 1, 42: 2, 45: 2}
		first.place_asteroids(layout)
		second.place_asteroids(layout)
		if not first.has_legal_move():
			first._shuffle_deadlocked_board()
			second._shuffle_deadlocked_board()
		_check(first.find_matches().is_empty() and first.has_legal_move(), "Authored blocker layout starts stable/playable")
		for turn in range(12):
			var swap: Vector2i = first.find_legal_swap()
			var gems: Array = first.cells.duplicate()
			var powers: Array = first.specials.duplicate()
			var rocks: Array = first.asteroids.duplicate()
			var out: Dictionary = first.play_swap(swap.x, swap.y)
			var same: Dictionary = second.play_swap(swap.x, swap.y)
			_check(out == same and first.asteroids == second.asteroids and first.cells == second.cells, "Seeded turns deterministic")
			_verify_events(first, out, gems, powers, rocks)
