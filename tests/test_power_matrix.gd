extends SceneTree
## Deterministic M2 compatibility matrix. Every supported ordered special pair
## is swapped horizontally, vertically, near edges and at corners, then checked
## against an independent expected first-blast footprint and event replay.
## Usage: godot --headless --path . --script res://tests/test_power_matrix.gd

const Board = preload("res://scripts/cosmic_board.gd")
const POWER_TYPES = [Board.BEAM_ROW, Board.BEAM_COLUMN, Board.BOMB, Board.SUPERNOVA]

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run()
	print("Cosmic combination matrix: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)


func _fixture(seed: int):
	var board = Board.new(seed)
	for row in range(8):
		for col in range(8):
			board.cells[row * 8 + col] = (row * 2 + col) % 6
	board.specials.fill(Board.NONE)
	board.nova_energy = 0
	_check(board.find_matches().is_empty(), "Fixture must start stable")
	return board


func _first_clear(result: Dictionary) -> Array[int]:
	for event in result["events"]:
		if event["type"] == "clear":
			var cleared: Array[int] = event["indices"].duplicate()
			cleared.sort()
			return cleared
	return []


func _reference_blast(start_cells: Array[int], start_powers: Array[int],
		a: int, b: int) -> Array[int]:
	# Reference calculation is deliberately independent of Board._expand_seeds.
	var cells: Array[int] = start_cells.duplicate()
	var powers: Array[int] = start_powers.duplicate()
	cells[a] = start_cells[b]
	cells[b] = start_cells[a]
	powers[a] = start_powers[b]
	powers[b] = start_powers[a]

	if start_powers[a] == Board.SUPERNOVA and start_powers[b] == Board.SUPERNOVA:
		var all: Array[int] = []
		for i in range(64):
			all.append(i)
		return all

	var focus: int = -1
	var wanted: int = -1
	if start_powers[a] == Board.SUPERNOVA:
		focus = b
		wanted = start_cells[b]
	elif start_powers[b] == Board.SUPERNOVA:
		focus = a
		wanted = start_cells[a]

	var queue: Array[int] = [a, b]
	var visited: Dictionary = {}
	var at: int = 0
	while at < queue.size():
		var index: int = queue[at]
		at += 1
		if visited.has(index):
			continue
		visited[index] = true
		var r: int = int(index / 8)
		var c: int = index % 8
		match powers[index]:
			Board.BEAM_ROW:
				for x in range(8):
					queue.append(r * 8 + x)
			Board.BEAM_COLUMN:
				for y in range(8):
					queue.append(y * 8 + c)
			Board.BOMB:
				for y in range(maxi(0, r - 1), mini(8, r + 2)):
					for x in range(maxi(0, c - 1), mini(8, c + 2)):
						queue.append(y * 8 + x)
			Board.SUPERNOVA:
				var color: int = wanted if index == focus else cells[index]
				for j in range(64):
					if cells[j] == color:
						queue.append(j)

	var answer: Array[int] = []
	for key in visited:
		answer.append(int(key))
	answer.sort()
	return answer


func _validate_events(start_cells: Array[int], start_powers: Array[int],
		board, result: Dictionary, name: String) -> void:
	var cursor: Array[int] = start_cells.duplicate()
	var power_cursor: Array[int] = start_powers.duplicate()
	var total_cleared: int = 0
	var total_scored: int = 0
	for event in result["events"]:
		_check(event["before"] == cursor, name + " gem event chain continuous")
		_check(event["specials_before"] == power_cursor, name + " power event chain continuous")
		if event["type"] == "clear":
			var marked: Dictionary = {}
			for i in event["indices"]:
				marked[int(i)] = true
			_check(marked.size() == event["indices"].size(), name + " no duplicate clear")
			total_cleared += event["indices"].size()
			total_scored += int(event["score_delta"])
		if event["type"] == "fall":
			for move in event["moves"]:
				var from_index: int = int(move["from"])
				_check(int(event["specials_before"][from_index]) == int(move["special"]),
					name + " falling special must travel with the original gem")
			for spawn in event["spawns"]:
				_check(int(spawn["special"]) == Board.NONE, name + " spawned gems have no surprise powers")
		cursor = event["after"].duplicate()
		power_cursor = event["specials_after"].duplicate()
	_check(cursor == board.cells, name + " gem frames match final model")
	_check(power_cursor == board.specials, name + " power frames match final model")
	_check(total_cleared == int(result["cleared"]), name + " exact union clear count")
	_check(total_scored == int(result["score"]), name + " exact scored total")
	_check(board.find_matches().is_empty(), name + " all cascades settle")
	_check(board.cells.size() == 64 and board.specials.size() == 64,
		name + " aligned board and special arrays")


func _run() -> void:
	var positions = [
		[3 * 8 + 3, 3 * 8 + 4], # middle, horizontal
		[3 * 8 + 3, 4 * 8 + 3], # middle, vertical
		[0, 1], # top-left edge
		[0, 8], # top-left vertical
		[7 * 8 + 6, 7 * 8 + 7], # bottom-right edge
		[6 * 8 + 7, 7 * 8 + 7] # bottom-right vertical
	]
	var cases: int = 0
	for type_a in POWER_TYPES:
		for type_b in POWER_TYPES:
			for pair in positions:
				var a: int = int(pair[0])
				var b: int = int(pair[1])
				var board = _fixture(10000 + cases)
				board.specials[a] = int(type_a)
				board.specials[b] = int(type_b)
				var original_cells: Array[int] = board.cells.duplicate()
				var original_powers: Array[int] = board.specials.duplicate()
				var name: String = "%d+%d @ %d,%d" % [type_a, type_b, a, b]

				var expected: Array[int] = _reference_blast(original_cells, original_powers, a, b)
				var result: Dictionary = board.play_swap(a, b)
				_check(result["valid"], name + " valid special+special swap")
				_check(result["created"] == Board.NONE, name + " activation does not forge random special")
				_check(int(result["activated"]) == 2, name + " each original special activated exactly once")
				_check(_first_clear(result) == expected, name + " first blast covers exactly intended cells")
				_check(int(result["cleared"]) >= expected.size(), name + " cascades only increase clears")
				_validate_events(original_cells, original_powers, board, result, name)
				cases += 1

	# A power struck by Nova's cross fires, and its effects are counted once.
	var nova = _fixture(30022)
	nova.nova_energy = Board.NOVA_MAX
	nova.specials[3 * 8 + 5] = Board.BEAM_COLUMN
	nova.specials[1 * 8 + 3] = Board.BOMB
	nova.specials[5 * 8 + 3] = Board.SUPERNOVA
	var initial_cells: Array[int] = nova.cells.duplicate()
	var initial_powers: Array[int] = nova.specials.duplicate()
	var pulse: Dictionary = nova.use_nova(3 * 8 + 3)
	_check(pulse["valid"] and pulse["used_nova"], "Nova cross targets board")
	_check(nova.nova_energy == 0, "Nova clears its own charge without free refill")
	_check(int(pulse["activated"]) >= 3, "Nova triggers specials on its row and column")
	_check(int(pulse["cleared"]) >= 15, "Nova counts unique row/column targets")
	_validate_events(initial_cells, initial_powers, nova, pulse, "nova + three powers")
	print("Matrix exercised %d ordered pair / orientation / edge cases" % cases)
