extends SceneTree
## Play the real scene's ordered events to completion, with a controlled clock.
const Board = preload("res://scripts/cosmic_board.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Asteroid scene: " + message)


func _fixture():
	var b = Board.new(911)
	for r in range(8):
		for c in range(8):
			b.cells[r * 8 + c] = (r * 2 + c) % 6
	return b


func _inject(game: Node, b) -> void:
	game.set("board", b)
	game.set("display_cells", b.cells.duplicate())
	game.set("display_specials", b.specials.duplicate())
	game.set("display_asteroids", b.asteroids.duplicate())
	game.set("phase", "idle")
	game.set("finished", false)
	game.set("won", false)
	game.set("collected", 0)
	game.set("score", 0)
	game.set("moves_left", 18)


func _drain(game: Node) -> Array[String]:
	var types: Array[String] = []
	for frame in range(400):
		if game.get("phase") != "resolving":
			return types
		var e: Dictionary = game.get("active_event")
		if not e.is_empty():
			types.append(str(e["type"]))
			_check(game.get("display_asteroids") == e["asteroids_before"], "Renderer uses event durability, not final model")
			# No second turn can enter while animations are active.
			var gems: Array = game.get("board").cells.duplicate()
			game.call("_take_turn", 0, 1)
			_check(gems == game.get("board").cells, "Input locked through damage/fall")
			game.set("event_elapsed", game.get("event_duration"))
		await process_frame
	_check(false, "Playback completes without hanging")
	return types


func _run() -> void:
	var packed: PackedScene = load("res://scenes/Prototype.tscn")
	var game: Node = packed.instantiate()
	root.add_child(game)
	await process_frame
	_check(game.get("board").asteroids.count(2) == 4 and game.get("board").asteroids.count(1) == 2, "Playable prototype includes six test asteroids")
	_check(game.has_method("_draw_asteroid") and game.has_method("_draw_asteroids"), "Damage renderer compiled")
	# Invalid blocker swap spends no move and does not alter goals/energy.
	var b = _fixture()
	b.place_asteroids({27: 2})
	_inject(game, b)
	game.call("_take_turn", 26, 27)
	await _drain(game)
	_check(game.get("moves_left") == 18 and game.get("score") == 0 and game.get("collected") == 0, "Blocked scene swap has no cost")
	_check(b.nova_energy == 0 and b.asteroids[27] == 2, "Blocked scene swap preserves charge/durability")

	# The controller shows hit/crack then fall and settles its own view.
	b = _fixture()
	b.place_asteroids({27: 2, 63: 2})
	b.specials[24] = Board.BEAM_ROW
	_inject(game, b)
	game.call("_take_turn", 24, 25)
	var seen: Array[String] = await _drain(game)
	_check(seen.has("clear") and seen.has("asteroid_hit") and seen.has("fall"), "Clear, rock impact and fall all played")
	_check(seen.find("clear") < seen.find("asteroid_hit") and seen.find("asteroid_hit") < seen.find("fall"), "Scene orders impact before refill")
	_check(game.get("display_asteroids") == b.asteroids and game.get("display_cells") == b.cells, "Settled scene matches model")
	_check(game.get("moves_left") == 17, "Valid special swap spends exactly one move")
	_check(not game.get("finished"), "Collection alone cannot win while rocks remain")

	# Nova can target a rock, leaves moves unchanged, and last-rock destruction
	# wins even with a zero remaining move budget (after full playback).
	b = _fixture()
	b.place_asteroids({27: 1})
	b.nova_energy = Board.NOVA_MAX
	_inject(game, b)
	game.set("collected", 29)
	game.set("moves_left", 0)
	game.set("phase", "nova_targeting")
	game.call("_take_nova", 27)
	seen = await _drain(game)
	_check(seen.has("asteroid_hit") and b.asteroids[27] == 0, "Nova destruction rendered")
	_check(game.get("moves_left") == 0 and b.nova_energy == 0, "Nova zero move and no recharge")
	_check(game.get("finished") and game.get("won"), "Victory after final asteroid beats exhausted move budget")

	# A valid last regular move can win; incomplete asteroid goal loses.
	for health in [1, 2]:
		b = _fixture()
		b.place_asteroids({27: health, 63: 2} if health == 2 else {27: 1})
		b.specials[24] = Board.BEAM_ROW
		_inject(game, b)
		game.set("collected", 29)
		game.set("moves_left", 1)
		game.call("_take_turn", 24, 25)
		await _drain(game)
		_check(game.get("moves_left") == 0 and game.get("finished"), "Last move reaches a terminal result")
		_check(game.get("won") == (health == 1), "All goals required, victory priority correct")

	# A remaining rock is drawn on the normal scene (and a later damaged frame)
	# when running with a renderer; headless mode still checks state integration.
	b = _fixture()
	b.place_asteroids({18: 2, 21: 1, 27: 2})
	_inject(game, b)
	game.size = root.get_visible_rect().size
	game.set("feedback", "Match beside asteroids to crack them")
	await process_frame
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		DirAccess.make_dir_recursive_absolute("res://build/qa")
		root.get_texture().get_image().save_png("res://build/qa/asteroid-scene.png")
	game.queue_free()
	await process_frame
	print("M2 asteroid scene: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
