extends SceneTree
## Instantiate the REAL gameplay scene and exercise the same turn path as the UI.
## A parse failure must exit nonzero even if Godot's --headless process exits 0.
const CosmicBoardScript = preload("res://scripts/cosmic_board.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_validate.call_deferred()


func _check(test: bool, message: String) -> void:
	checks += 1
	if not test:
		failures += 1
		push_error("Scene smoke: " + message)


func _validate() -> void:
	var packed: PackedScene = load("res://scenes/Prototype.tscn")
	if packed == null:
		_check(false, "Prototype scene must load")
		quit(1)
		return
	var game: Node = packed.instantiate()
	game.set("practice_mode", true)
	_check(game.get_script() != null, "Prototype must have an attached, compiled script")
	if game.get_script() == null:
		game.free()
		quit(1)
		return
	root.add_child(game)
	await process_frame
	_check(game.has_method("_take_turn"), "Player turn entry point must exist")
	_check(game.has_method("_draw_power_icon"), "Special piece renderer must exist")
	_check(game.has_method("_take_nova"), "Nova target entry point must exist")
	_check(game.get("board") != null, "_ready must create a playable CosmicBoard")
	_check(game.get("display_specials") is Array, "View must keep special piece snapshots")
	if game.get("board") == null:
		quit(1)
		return

	# Exact horizontal four-match produced by a SWIPE (source row 3, destination row 2).
	# The scene itself, rather than a separate board test alone, must start a turn.
	var example = CosmicBoardScript.new(128)
	for row in range(8):
		for col in range(8):
			example.cells[row * 8 + col] = (row * 2 + col) % 6
	example.specials.fill(CosmicBoardScript.NONE)
	for col in [1, 2, 4]:
		example.cells[2 * 8 + col] = 1
	example.cells[2 * 8 + 3] = 2
	example.cells[3 * 8 + 3] = 1
	_check(example.find_matches().is_empty(), "Four-match fixture has no initial matches")
	game.set("board", example)
	game.set("display_cells", example.cells.duplicate())
	game.set("display_specials", example.specials.duplicate())
	game.call("_take_turn", 3 * 8 + 3, 2 * 8 + 3)
	_check(game.get("phase") == "resolving", "Swipe turn must lock UI during animations")
	_check(example.specials.has(CosmicBoardScript.BEAM_ROW),
		"Real gameplay turn must create a Star Beam from a horizontal four-match")
	var pending: Dictionary = game.get("active_event")
	_check(not pending.is_empty() and pending.get("type", "") == "swap",
		"Animated gameplay turn must begin playback of the swap")
	print("Cosmic scene smoke: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
