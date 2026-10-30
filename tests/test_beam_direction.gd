extends SceneTree
const Board = preload("res://scripts/cosmic_board.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Beam direction: " + message)


func fixture(seed: int):
	var board = Board.new(seed)
	for row in range(8):
		for col in range(8): board.cells[row * 8 + col] = (row * 2 + col) % 6
	board.specials.fill(Board.NONE)
	return board


func touch(point: Vector2, pressed: bool) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.position = point
	event.pressed = pressed
	root.push_input(event, true)


func _run() -> void:
	for direction in ["left", "right", "up", "down"]:
		for swipe in [false, true]:
			var board = fixture(821)
			var horizontal: bool = direction in ["left", "right"]
			var source: int = 28 if horizontal else 27
			var target: int = 27 if horizontal else 19
			if horizontal:
				for row in [1, 2, 4]: board.cells[row * 8 + 3] = 4
				board.cells[27] = 0
				board.cells[28] = 4
			else:
				for col in [1, 2, 4]: board.cells[16 + col] = 1
				board.cells[19] = 2
				board.cells[27] = 1
			# Reflect the same stable fixtures to exercise positive-axis gestures.
			if direction in ["right", "down"]:
				var before: Array[int] = board.cells.duplicate()
				for i in range(64):
					var mirrored: int = int(i / 8) * 8 + 7 - i % 8 if horizontal else (7 - int(i / 8)) * 8 + i % 8
					board.cells[mirrored] = before[i]
				source = int(source / 8) * 8 + 7 - source % 8 if horizontal else (7 - int(source / 8)) * 8 + source % 8
				target = int(target / 8) * 8 + 7 - target % 8 if horizontal else (7 - int(target / 8)) * 8 + target % 8
			var expected: int = Board.BEAM_ROW if horizontal else Board.BEAM_COLUMN
			var label: String = direction + (" swipe" if swipe else " two taps")
			check(board.find_matches().is_empty(), label + " starts stable")
			var game = load("res://scenes/Prototype.tscn").instantiate()
			game.practice_mode = true
			root.add_child(game)
			game.board = board
			game.display_cells = board.cells.duplicate()
			game.display_specials = board.specials.duplicate()
			game.display_asteroids = board.asteroids.duplicate()
			var rect: Rect2 = game._board_rect()
			var a: Vector2 = game._center_of(source, rect)
			var b: Vector2 = game._center_of(target, rect)
			touch(a, true)
			touch(b if swipe else a, false)
			if not swipe:
				touch(b, true)
				touch(b, false)
			check(game.phase == "resolving", label + " starts a real scene turn")
			var created: Array = game.session.pending["events"].filter(func(event): return event["type"] == "special_create")
			check(not created.is_empty() and created[0]["kind"] == expected, label + " forges matching-axis Beam")
			var saw_marker: bool = false
			for frame in range(500):
				if game.phase != "resolving": break
				if game.active_event.get("type", "") == "special_create":
					var event: Dictionary = game.active_event
					saw_marker = int(event["specials_after"][event["index"]]) == expected
				game.event_elapsed = game.event_duration
				await process_frame
			check(saw_marker, label + " presents the matching forged glyph")
			check(game.phase != "resolving" and game.moves_left == 17, label + " settles exactly one move")
			check(game.display_specials == board.specials, label + " preserves displayed orientation through gravity")
			game.queue_free()
			await process_frame
		# Existing powers keep their orientation when activated by another axis.
		var activation = fixture(822)
		activation.specials[27] = Board.BEAM_ROW if direction in ["left", "right"] else Board.BEAM_COLUMN
		var outcome: Dictionary = activation.play_swap(27, 28)
		var cleared: Array = outcome["events"].filter(func(event): return event["type"] == "clear")[0]["indices"].duplicate()
		cleared.sort()
		var expected_area: Array[int] = []
		for i in range(8): expected_area.append(24 + i if direction in ["left", "right"] else i * 8 + 4)
		check(cleared == expected_area, direction + " Beam fires its stored full-line footprint")
	# Do not create an orientation a level explicitly disables.
	var restricted = fixture(823)
	restricted.enabled_powers.assign([Board.BEAM_COLUMN])
	for row in [1, 2, 4]: restricted.cells[row * 8 + 3] = 4
	restricted.cells[27] = 0
	restricted.cells[28] = 4
	check(restricted.play_swap(28, 27)["created"] == Board.NONE, "Disabled swap-axis reward stays disabled")
	print("Beam direction: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
