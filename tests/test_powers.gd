extends SceneTree
## M2 deterministic rules and event-chain tests.
## godot --headless --path . --script res://tests/test_powers.gd

const Board = preload("res://scripts/cosmic_board.gd")
var assertions: int = 0
var failures: int = 0


func _initialize() -> void:
	_run()
	print("Cosmic powers: %d checks, %d failures" % [assertions, failures])
	quit(1 if failures > 0 else 0)


func _ok(value: bool, label: String) -> void:
	assertions += 1
	if not value:
		failures += 1
		push_error(label)


func _fixture(seed: int = 42):
	var board = Board.new(seed)
	board.cells.resize(64)
	for row in range(8):
		for col in range(8):
			board.cells[row * 8 + col] = (row * 2 + col) % 6
	board.specials.fill(Board.NONE)
	board.nova_energy = 0
	_ok(board.find_matches().is_empty(), "Fixture begins without matched lines")
	return board


func _events(before: Array[int], before_specials: Array[int], outcome: Dictionary, board, label: String) -> void:
	var current: Array[int] = before.duplicate()
	var power: Array[int] = before_specials.duplicate()
	var total_clears: int = 0
	var summed_score: int = 0
	for event in outcome["events"]:
		_ok(event["before"] == current, "%s event before state" % label)
		_ok(event["specials_before"] == power, "%s event before specials" % label)
		_ok(event["before"].size() == 64 and event["after"].size() == 64, "%s event length" % label)
		_ok(event["specials_after"].size() == 64, "%s specials event length" % label)
		if event["type"] == "clear":
			var unique: Dictionary = {}
			for index in event["indices"]:
				unique[int(index)] = true
			_ok(unique.size() == event["indices"].size(), "%s no duplicate cleared tiles" % label)
			total_clears += event["indices"].size()
			summed_score += int(event["score_delta"])
		current = event["after"].duplicate()
		power = event["specials_after"].duplicate()
	_ok(current == board.cells, "%s final gems agree" % label)
	_ok(power == board.specials, "%s final specials agree" % label)
	_ok(total_clears == int(outcome["cleared"]), "%s clear total agrees" % label)
	_ok(summed_score == int(outcome["score"]), "%s score agrees" % label)


func _run() -> void:
	var initial = Board.new(1109)
	_ok(initial.specials.size() == 64, "Special parallel array has 64 entries")
	_ok(not initial.can_use_nova(), "Nova starts uncharged")
	_ok(initial.find_matches().is_empty(), "Seeded startup has no matches")
	for value in initial.specials:
		_ok(value == Board.NONE, "No premade starting specials")

	# Deterministic four match: move a 1 from row 3 c3 into row 2 c3.
	var beam = _fixture()
	for col in [1, 2, 4]:
		beam.cells[2 * 8 + col] = 1
	beam.cells[2 * 8 + 3] = 2
	beam.cells[3 * 8 + 3] = 1
	_ok(beam.find_matches().is_empty(), "Four-match fixture is stable before swap")
	var old: Array[int] = beam.cells.duplicate()
	var old_power: Array[int] = beam.specials.duplicate()
	var made: Dictionary = beam.play_swap(3 * 8 + 3, 2 * 8 + 3)
	_ok(made["valid"], "Four-match swap is legal")
	_ok(int(made["created"]) == Board.BEAM_ROW, "Horizontal four creates row beam")
	_ok(beam.specials.has(Board.BEAM_ROW), "New beam survives gravity")
	_ok(made["nova_gain"] > 0, "Matches charge Nova")
	_events(old, old_power, made, beam, "beam formation")

	# Reward-precedence: straight five outranks any straight four.
	var reward_board = _fixture(73)
	for col in range(1, 6):
		reward_board.cells[2 * 8 + col] = 3
	var reward: Dictionary = reward_board._find_reward(reward_board.find_matches(), 2 * 8 + 2, 2 * 8 + 3)
	_ok(int(reward.get("kind", 0)) == Board.SUPERNOVA, "Straight five creates supernova")

	# A T intersection outranks a four, even if multiple patterns overlap.
	var cross = _fixture(12)
	for index in [2 * 8 + 1, 2 * 8 + 2, 2 * 8 + 3, 1 * 8 + 2, 3 * 8 + 2]:
		cross.cells[index] = 5
	reward = cross._find_reward(cross.find_matches(), 2 * 8 + 1, 2 * 8 + 2)
	_ok(int(reward.get("kind", 0)) == Board.BOMB, "T intersection creates bomb")

	# A row beam can be triggered without an ordinary 3-match.
	var triggered = _fixture(81)
	triggered.specials[3 * 8 + 2] = Board.BEAM_ROW
	old = triggered.cells.duplicate()
	old_power = triggered.specials.duplicate()
	var burst: Dictionary = triggered.play_swap(3 * 8 + 2, 3 * 8 + 3)
	_ok(burst["valid"], "Special + normal swap is valid")
	_ok(int(burst["activated"]) >= 1, "Beam fires on activation")
	_ok(int(burst["cleared"]) >= 8, "Beam clears full row")
	_events(old, old_power, burst, triggered, "beam activation")

	# Beam/Bomb and Bomb/Bomb combos union their effects with no double counts.
	for types in [[Board.BEAM_ROW, Board.BEAM_COLUMN], [Board.BEAM_ROW, Board.BOMB],
			[Board.BOMB, Board.BOMB], [Board.SUPERNOVA, Board.BEAM_ROW],
			[Board.SUPERNOVA, Board.SUPERNOVA]]:
		var combo = _fixture(330 + int(types[0]) * 10 + int(types[1]))
		combo.specials[3 * 8 + 3] = int(types[0])
		combo.specials[3 * 8 + 4] = int(types[1])
		old = combo.cells.duplicate()
		old_power = combo.specials.duplicate()
		var combo_result: Dictionary = combo.play_swap(3 * 8 + 3, 3 * 8 + 4)
		_ok(combo_result["valid"], "Special combo accepts adjacent swap")
		_ok(int(combo_result["activated"]) >= 2, "Both pieces trigger in combo")
		_ok(int(combo_result["cleared"]) >= 8, "Special combo has significant effect")
		_events(old, old_power, combo_result, combo, "special combo")
		_ok(combo.find_matches().is_empty(), "Combo settles to no matches")

	# Nova Pulse is a charged, zero-move row+column action.
	var nova = _fixture(120)
	var refuse = nova.use_nova(3 * 8 + 4)
	_ok(not refuse["valid"], "Uncharged Nova rejects target")
	_ok(nova.cells == _fixture(120).cells, "Uncharged Nova never mutates board")
	nova.nova_energy = Board.NOVA_MAX
	old = nova.cells.duplicate()
	old_power = nova.specials.duplicate()
	var nova_result: Dictionary = nova.use_nova(3 * 8 + 4)
	_ok(nova_result["valid"] and nova_result["used_nova"], "Charged Nova activates")
	_ok(int(nova_result["cleared"]) >= 15, "Nova clears row and column union")
	_ok(nova.nova_energy == 0, "Nova consumes charge but does not refill itself")
	_events(old, old_power, nova_result, nova, "nova pulse")
	_ok(nova.find_matches().is_empty(), "Nova resolves any cascades")

	# Randomized stress: both gem and power arrays stay aligned after normal turns.
	for seed_value in range(32):
		var board = Board.new(seed_value + 1000)
		var legal: Vector2i = board.find_legal_swap()
		old = board.cells.duplicate()
		old_power = board.specials.duplicate()
		var result: Dictionary = board.play_swap(legal.x, legal.y)
		_ok(result["valid"], "Seeded normal swap works with extended rules")
		_events(old, old_power, result, board, "seeded powers")
		_ok(board.cells.size() == board.specials.size(), "Specials remain aligned with board")
