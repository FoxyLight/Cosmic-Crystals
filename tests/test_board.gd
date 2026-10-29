extends SceneTree
## Run: godot --headless --path . --script res://tests/test_board.gd
## Seeded model tests, including sequential event replay invariants.

const BoardScript = preload("res://scripts/board.gd")

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run_tests()
	print("Cosmic Crystals: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)


func _run_tests() -> void:
	var first = BoardScript.new(12345)
	var second = BoardScript.new(12345)
	_check(first.cells == second.cells, "Same seed generates the same board")

	for seed_value in range(125):
		var board = BoardScript.new(seed_value + 1)
		_check(board.cells.size() == 64, "Board size is 8x8")
		_check(board.find_matches().is_empty(), "Initial board has no matches")
		_check(board.has_legal_move(), "Initial board has a legal move")
		for kind in board.cells:
			_check(kind >= 0 and kind < 6, "Known crystal kind")

		var original: Array[int] = board.cells.duplicate()
		var rejected: Dictionary = board.play_swap(0, 63)
		_check(not rejected["valid"], "Non-adjacent move is rejected")
		_check(board.cells == original, "Rejected non-adjacent move is a no-op")
		_check(rejected["events"].is_empty(), "Illegal non-adjacent moves emit no effects")

		var invalid: Vector2i = _find_invalid_neighbor(board)
		_check(invalid.x >= 0, "Test board contains an invalid neighboring pair")
		if invalid.x >= 0:
			var bad: Dictionary = board.play_swap(invalid.x, invalid.y)
			_check(not bad["valid"], "Adjacent non-matching swap is rejected")
			_check(board.cells == original, "Rejected neighbor swap restores initial cells")
			_check(bad["events"].size() == 2, "Rejected neighbor animates swap and rollback")
			if bad["events"].size() == 2:
				_check(bad["events"][0]["type"] == "swap", "Bad swap first animates outward")
				_check(bad["events"][1]["type"] == "swap_back", "Bad swap then animates backward")
				_assert_event_chain(original, bad["events"], board.cells, "rejected")

		var legal: Vector2i = board.find_legal_swap()
		_check(board.would_match(legal.x, legal.y), "Enumerated swap truly matches")
		var applied: Dictionary = board.play_swap(legal.x, legal.y)
		_check(applied["valid"], "Legal swap accepted")
		_check(int(applied["cleared"]) >= 3, "Accepted swap clears at least 3")
		_check(int(applied["score"]) >= 30, "Accepted swap scores")
		_check(applied["events"].size() >= 3, "Accepted swap contains swap/clear/fall events")
		_assert_event_chain(original, applied["events"], board.cells, "accepted")
		var clear_events: int = 0
		var fall_events: int = 0
		var cleared_in_events: int = 0
		var score_in_events: int = 0
		for event in applied["events"]:
			if event["type"] == "clear":
				clear_events += 1
				cleared_in_events += event["indices"].size()
				score_in_events += int(event["score_delta"])
				var unique: Dictionary = {}
				for index in event["indices"]:
					unique[index] = true
				_check(unique.size() == event["indices"].size(), "Clear event has no duplicates")
			if event["type"] == "fall":
				fall_events += 1
				for move in event["moves"]:
					_check(int(move["to"]) >= int(move["from"]), "Gravity never sends a piece upward")
					_check(int(event["before"][move["from"]]) == int(move["kind"]), "Gravity piece kind matches source")
				for spawn in event["spawns"]:
					_check(int(spawn["from_row"]) < 0, "Refill begins above the board")
		_check(clear_events == int(applied["cascades"]), "Cascade count matches clear events")
		_check(clear_events == fall_events, "Each clearing phase has a falling phase")
		_check(cleared_in_events == int(applied["cleared"]), "Event clear count matches result")
		_check(score_in_events == int(applied["score"]), "Event score matches result")
		var collected_total: int = 0
		for amount in applied["collected"].values():
			collected_total += int(amount)
		_check(collected_total == int(applied["cleared"]), "Collected count equals clear count")
		_check(board.find_matches().is_empty(), "Turn finishes with stable board")
		_check(board.has_legal_move(), "Turn finishes with a playable board")
		for kind in board.cells:
			_check(kind >= 0 and kind < 6, "No empty or unknown crystals after turn")

	# A T-shaped intersection has five unique cells.
	var intersect = BoardScript.new(42)
	for row in range(8):
		for col in range(8):
			intersect.cells[row * 8 + col] = (row * 2 + col * 3) % 6
	for index in [3 * 8 + 4, 4 * 8 + 3, 4 * 8 + 4, 4 * 8 + 5, 5 * 8 + 4]:
		intersect.cells[index] = 0
	var matches: Array[int] = intersect.find_matches()
	for index in [3 * 8 + 4, 4 * 8 + 3, 4 * 8 + 4, 4 * 8 + 5, 5 * 8 + 4]:
		_check(matches.has(index), "T match includes all members")
	var unique_match: Dictionary = {}
	for index in matches:
		unique_match[index] = true
	_check(unique_match.size() == matches.size(), "Intersecting runs deduplicated")
	_check(not intersect.is_adjacent(7, 8), "Board edge does not wrap a swap")


func _find_invalid_neighbor(board) -> Vector2i:
	for row in range(8):
		for col in range(8):
			var a: int = row * 8 + col
			if col < 7 and board.cells[a] != board.cells[a + 1] and not board.would_match(a, a + 1):
				return Vector2i(a, a + 1)
			if row < 7 and board.cells[a] != board.cells[a + 8] and not board.would_match(a, a + 8):
				return Vector2i(a, a + 8)
	return Vector2i(-1, -1)


func _assert_event_chain(start: Array[int], events: Array, ending: Array[int], label: String) -> void:
	var cursor: Array[int] = start.duplicate()
	for event in events:
		_check(event.has("type") and event.has("before") and event.has("after"), "%s event fields" % label)
		_check(event["before"] == cursor, "%s event sequence matches previous outcome" % label)
		_check(event["before"].size() == 64 and event["after"].size() == 64, "%s event board size" % label)
		cursor = event["after"].duplicate()
	_check(cursor == ending, "%s event playback reproduces final model state" % label)
