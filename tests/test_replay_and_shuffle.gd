extends SceneTree
## Regression for accidental touch restarts and non-destructive deadlock recovery.
## Run: godot --headless --path . --script res://tests/test_replay_and_shuffle.gd

const Board = preload("res://scripts/cosmic_board.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_test_ui.call_deferred()


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("Replay/shuffle: " + message)


func _deadlocked_board(seed_value: int):
	# Six-color diagonal pattern: no existing triples AND no legal swap.
	var b = Board.new(seed_value)
	for row in range(8):
		for col in range(8):
			b.cells[row * 8 + col] = (row * 2 + col) % 6
	b.specials.fill(Board.NONE)
	_check(b.find_matches().is_empty(), "Deadlock fixture starts without triples")
	_check(not b.has_legal_move(), "Deadlock fixture has no legal swaps")
	return b


func _histogram(cells: Array[int]) -> Dictionary:
	var result: Dictionary = {}
	for kind in cells:
		result[kind] = int(result.get(kind, 0)) + 1
	return result


func _test_shuffle() -> void:
	var first = _deadlocked_board(945)
	var second = _deadlocked_board(945)
	var before: Array[int] = first.cells.duplicate()
	var initial_counts: Dictionary = _histogram(before)
	first.nova_energy = 14
	second.nova_energy = 14
	var outcome: Dictionary = first._empty_result()
	first._resolve([], outcome, {}, -1, false)
	_check(bool(outcome["reshuffled"]), "Deadlock triggers an explicit reshuffle")
	_check(outcome["events"].size() == 1, "No cascade means one reshuffle event")
	if outcome["events"].size() == 1:
		var e: Dictionary = outcome["events"][0]
		_check(e["type"] == "reshuffle", "Deadlock is labeled reshuffle")
		_check(e.get("reason", "") == "no_legal_moves", "Reshuffle records its cause")
		_check(e["before"] == before, "Reshuffle before matches old board")
		_check(e["after"] == first.cells, "Reshuffle after matches new board")
		_check(e["specials_before"] == e["specials_after"],
			"Deadlock reshuffle preserves special inventory")
	_check(_histogram(first.cells) == initial_counts, "No gems created or lost during shuffle")
	_check(first.find_matches().is_empty(), "Shuffled board has no automatic matches")
	_check(first.has_legal_move(), "Shuffled board has at least one legal swap")
	_check(first.nova_energy == 14, "Deadlock recovery retains Nova energy")
	_check(first.cells != before, "Deadlock actually rearranges the board")
	_check(int(outcome["cleared"]) == 0 and int(outcome["score"]) == 0,
		"Shuffle creates no points or collections")
	var result2: Dictionary = second._empty_result()
	second._resolve([], result2, {}, -1, false)
	_check(first.cells == second.cells, "Seeded deadlock shuffle remains deterministic")

	# Even a nearly dead board with an earned special should never discard it.
	var powered = _deadlocked_board(211)
	powered.specials[17] = Board.BOMB
	var snapshot: Array[int] = powered.cells.duplicate()
	var powers: Array[int] = powered.specials.duplicate()
	var cannot_shuffle: Dictionary = powered._empty_result()
	powered._resolve([], cannot_shuffle, {}, -1, false)
	_check(not bool(cannot_shuffle["reshuffled"]), "Special provides a legal move, no shuffle")
	_check(powered.cells == snapshot and powered.specials == powers,
		"Existing special and gems survive no-op resolution")


func _test_ui() -> void:
	_test_shuffle()
	var packed: PackedScene = load("res://scenes/Prototype.tscn")
	_check(packed != null, "Playable scene must load")
	if packed == null:
		quit(1)
		return
	var game: Node = packed.instantiate()
	game.set("practice_mode", true)
	root.add_child(game)
	await process_frame
	_check(game.get_script() != null, "Playable script is attached")
	_check(game.get("board") != null, "Scene creates a board")
	if game.get("board") == null:
		quit(1)
		return

	var old_board = game.get("board")
	game.set("finished", true)
	game.set("won", true)
	game.set("phase", "finished")
	game.set("collected", 30)
	game.set("moves_left", 12)
	game.set("score", 650)
	game.set("feedback", "Victory")

	var grid: Rect2 = game.call("_board_rect")
	var elsewhere: Vector2 = grid.position + Vector2(28, 28)
	var play_button: Rect2 = game.call("_replay_rect")
	_check(not play_button.has_point(elsewhere), "Non-button board tap is outside replay target")
	game.call("_handle_touch", elsewhere, true)
	game.call("_handle_touch", elsewhere, false)
	_check(game.get("board") == old_board, "Random tap after win must NOT regenerate")
	_check(game.get("finished") and game.get("phase") == "finished",
		"Game remains on finish screen after random tap")
	_check(int(game.get("score")) == 650 and int(game.get("moves_left")) == 12,
		"Random tap does not reset score or moves")

	game.call("_handle_touch", play_button.get_center(), true)
	game.call("_handle_touch", elsewhere, false)
	_check(game.get("board") == old_board, "Drag off PLAY AGAIN does not restart")

	game.call("_handle_touch", elsewhere, true)
	game.call("_handle_touch", play_button.get_center(), false)
	_check(game.get("board") == old_board, "Release on PLAY AGAIN without button press does not restart")

	game.call("_handle_touch", play_button.get_center(), true)
	game.call("_handle_touch", play_button.get_center(), false)
	_check(game.get("board") != old_board, "Intentional PLAY AGAIN restarts with a new board")
	_check(game.get("phase") == "idle" and not game.get("finished"),
		"Replay returns to active game state")
	_check(int(game.get("score")) == 0 and int(game.get("collected")) == 0,
		"Replay resets score and collection, but only when requested")
	_check(int(game.get("moves_left")) == 18, "Replay restores move budget")

	print("Replay/deadlock tests: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
