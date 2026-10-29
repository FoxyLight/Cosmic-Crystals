extends SceneTree
## Exercises special creation and targeting via the REAL game controller/scene,
## not just its underlying Board rules. All turns are started in the same frame;
## the model resolves synchronously while visual playback is asynchronous.
const Board = preload("res://scripts/cosmic_board.gd")

var assertions: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures += 1
		push_error(message)


func _fixture(seed: int):
	var board = Board.new(seed)
	for row in range(8):
		for col in range(8):
			board.cells[row * 8 + col] = (row * 2 + col) % 6
	board.specials.fill(Board.NONE)
	return board


func _fresh_game(scene: PackedScene) -> Node:
	var game: Node = scene.instantiate()
	root.add_child(game)
	_ok(game.get_script() != null, "Game scene script must be compiled and attached")
	_ok(game.get("board") != null, "Game scene must initialize a board")
	return game


func _inject(game: Node, board) -> void:
	game.set("board", board)
	game.set("display_cells", board.cells.duplicate())
	game.set("display_specials", board.specials.duplicate())


func _test_creation(scene: PackedScene, board, from_index: int,
		to_index: int, expected_kind: int, name: String) -> void:
	var game: Node = _fresh_game(scene)
	_ok(board.find_matches().is_empty(), name + " fixture begins without matches")
	_inject(game, board)
	game.call("_take_turn", from_index, to_index)
	_ok(game.get("phase") == "resolving", name + " locks input for animation")
	_ok(board.specials.has(expected_kind), name + " creates expected power in game model")
	_ok(not game.get("active_event").is_empty(), name + " begins animated events")
	_ok(int(game.get("moves_left")) == 18, name + " move budget waits for animations")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/Prototype.tscn")
	_ok(scene != null, "Playable scene must load")
	if scene == null:
		quit(1)
		return
	# Horizontal 4 (row Beam).
	var four = _fixture(121)
	for col in [1, 2, 4]:
		four.cells[2 * 8 + col] = 1
	four.cells[2 * 8 + 3] = 2
	four.cells[3 * 8 + 3] = 1
	_test_creation(scene, four, 3 * 8 + 3, 2 * 8 + 3,
		Board.BEAM_ROW, "Horizontal four")

	# Vertical 4 (column Beam).
	var vertical = _fixture(122)
	for row in [1, 2, 4]:
		vertical.cells[row * 8 + 3] = 4
	vertical.cells[3 * 8 + 3] = 0
	vertical.cells[3 * 8 + 4] = 4
	_test_creation(scene, vertical, 3 * 8 + 4, 3 * 8 + 3,
		Board.BEAM_COLUMN, "Vertical four")

	# Horizontal 5 (Supernova).
	var five = _fixture(123)
	for col in [0, 1, 3, 4]:
		five.cells[2 * 8 + col] = 2
	five.cells[2 * 8 + 2] = 3
	five.cells[3 * 8 + 2] = 2
	_test_creation(scene, five, 3 * 8 + 2, 2 * 8 + 2,
		Board.SUPERNOVA, "Straight five")

	# Real T junction (Cosmic Bomb).
	var tee = _fixture(124)
	for index in [2 * 8 + 2, 2 * 8 + 4, 1 * 8 + 3, 3 * 8 + 3, 4 * 8 + 3]:
		tee.cells[index] = 0
	tee.cells[2 * 8 + 3] = 3
	_test_creation(scene, tee, 1 * 8 + 3, 2 * 8 + 3,
		Board.BOMB, "T junction")

	# A special+special swap, initiated via the scene controller.
	var combo = _fixture(125)
	combo.specials[3 * 8 + 3] = Board.BEAM_ROW
	combo.specials[3 * 8 + 4] = Board.BOMB
	var combos: Node = _fresh_game(scene)
	_inject(combos, combo)
	combos.call("_take_turn", 3 * 8 + 3, 3 * 8 + 4)
	_ok(combos.get("phase") == "resolving", "Combo locks user input")
	_ok(not combo.specials.has(Board.BEAM_ROW) and not combo.specials.has(Board.BOMB),
		"Beam+Bomb triggers both pieces instead of leaving them idle")

	# Target mode and cancellation are wired to the actual touch handler.
	var nova = _fixture(126)
	nova.nova_energy = Board.NOVA_MAX
	var game: Node = _fresh_game(scene)
	_inject(game, nova)
	var button: Rect2 = game.call("_nova_rect")
	var tap: Vector2 = button.get_center()
	game.call("_handle_touch", tap, true)
	game.call("_handle_touch", tap, false)
	_ok(game.get("phase") == "nova_targeting", "Nova HUD accepts targeting tap")
	game.call("_handle_touch", tap, true)
	game.call("_handle_touch", tap, false)
	_ok(game.get("phase") == "idle", "Nova HUD second tap cancels targeting")
	_ok(nova.nova_energy == Board.NOVA_MAX, "Cancelling Nova preserves charge")
	game.call("_handle_touch", tap, true)
	game.call("_handle_touch", tap, false)
	_ok(game.get("phase") == "nova_targeting", "Nova target can be restarted")
	game.call("_take_nova", 3 * 8 + 3)
	_ok(game.get("phase") == "resolving", "Nova pulse locks input")
	_ok(nova.nova_energy == 0, "Nova pulse consumes energy")
	_ok(game.get("moves_left") == 18, "Nova pulse spends no regular move on start")
	print("M2 gameplay integration: %d checks, %d failures" % [assertions, failures])
	quit(1 if failures > 0 else 0)
