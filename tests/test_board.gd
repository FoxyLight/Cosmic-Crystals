extends SceneTree
## Run with: godot --headless --path . --script res://tests/test_board.gd

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
	_check(first.cells == second.cells, "Same seed must generate same board")
	for seed_value in range(100):
		var board = BoardScript.new(seed_value + 1)
		_check(board.cells.size() == 64, "Board must be 8 x 8")
		_check(board.find_matches().is_empty(), "Starting board must not contain matches")
		_check(board.has_legal_move(), "Starting board must have at least one legal move")
		for kind in board.cells:
			_check(kind >= 0 and kind < 6, "Starting board must contain only known kinds")
		var original: Array[int] = board.cells.duplicate()
		var rejected: Dictionary = board.play_swap(0, 63)
		_check(not rejected["valid"], "Non-adjacent swap must be rejected")
		_check(board.cells == original, "Rejected swap must preserve the board")
		var legal: Vector2i = board.find_legal_swap()
		_check(board.would_match(legal.x, legal.y), "Discovered legal swap must really match")
		var applied: Dictionary = board.play_swap(legal.x, legal.y)
		_check(applied["valid"], "Legal swap must be accepted")
		_check(int(applied["cleared"]) >= 3, "Accepted swap must clear at least three crystals")
		_check(int(applied["score"]) > 0, "Accepted swap must score")
		var summed: int = 0
		for value in applied["collected"].values():
			summed += int(value)
		_check(summed == int(applied["cleared"]), "Collected crystal totals must equal actual clears")
		_check(board.find_matches().is_empty(), "Resolved board must be stable")
		_check(board.has_legal_move(), "Resolved board must remain playable")
		for kind in board.cells:
			_check(kind >= 0 and kind < 6, "Refilled board must not contain empty or invalid cells")

	# A T-shaped intersection is five distinct cells, never six.
	var intersect = BoardScript.new(42)
	for row in range(8):
		for col in range(8):
			intersect.cells[row * 8 + col] = (row * 2 + col * 3) % 6
	for index in [3 * 8 + 4, 4 * 8 + 3, 4 * 8 + 4, 4 * 8 + 5, 5 * 8 + 4]:
		intersect.cells[index] = 0
	var matches: Array[int] = intersect.find_matches()
	_check(matches.has(4 * 8 + 4), "T-match must include center tile")
	var count: int = 0
	for index in [3 * 8 + 4, 4 * 8 + 3, 4 * 8 + 4, 4 * 8 + 5, 5 * 8 + 4]:
		if matches.has(index):
			count += 1
	_check(count == 5, "T-match must include all five unique tiles")
