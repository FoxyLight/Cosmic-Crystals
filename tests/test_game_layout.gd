extends SceneTree
## Geometry and actual GUI input checks for the responsive presentation pass.
const Layout = preload("res://scripts/game_layout.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Game layout: " + message)


func _geometry() -> void:
	for viewport in [Vector2(320, 568), Vector2(360, 640), Vector2(376, 746),
		Vector2(400, 760), Vector2(430, 932), Vector2(768, 1024),
		Vector2(1280, 720), Vector2(1440, 900), Vector2(900, 480)]:
		for safe in [Vector4.ZERO, Vector4(0, 24, 0, 24), Vector4(18, 32, 18, 20)]:
			var layout: Dictionary = Layout.calculate(viewport, safe)
			var area: Rect2 = layout["safe"]
			for key in ["header", "heading", "goals", "board", "caption", "score", "moves", "nova", "nova_button", "dialog", "replay", "help_button", "pause_button"]:
				var rect: Rect2 = layout[key]
				_check(rect.size.x > 0 and rect.size.y > 0, "Positive size: " + key)
				_check(area.encloses(rect), "Fits without scroll / respects safe area: " + key)
			var board: Rect2 = layout["board"]
			_check(is_equal_approx(board.size.x, board.size.y), "Board stays square")
			for key in ["header", "heading", "goals", "caption", "score", "moves", "nova"]:
				_check(not board.intersects(layout[key]), "Board does not overlap " + key)
			_check(layout["nova"].encloses(layout["nova_button"]), "Nova touch target inside its card")
			_check(layout["dialog"].encloses(layout["replay"]), "Replay target inside dialog")
			_check(layout["replay"].size.y >= 44, "Replay is a large touch target")
			_check(layout["nova_button"].size.y >= 44, "Nova is a large touch target")


func _tap(position: Vector2, touch: bool = false) -> void:
	if touch:
		var down: InputEventScreenTouch = InputEventScreenTouch.new()
		down.position = position
		down.pressed = true
		root.push_input(down, true)
		var up: InputEventScreenTouch = InputEventScreenTouch.new()
		up.position = position
		up.pressed = false
		root.push_input(up, true)
	else:
		var motion: InputEventMouseMotion = InputEventMouseMotion.new()
		motion.position = position
		root.push_input(motion, true)
		var down: InputEventMouseButton = InputEventMouseButton.new()
		down.position = position
		down.button_index = MOUSE_BUTTON_LEFT
		down.pressed = true
		root.push_input(down, true)
		var up: InputEventMouseButton = InputEventMouseButton.new()
		up.position = position
		up.button_index = MOUSE_BUTTON_LEFT
		up.pressed = false
		root.push_input(up, true)


func _run() -> void:
	_geometry()
	var game = load("res://scenes/Prototype.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var hud = game.hud
	_check(hud != null and hud.labels["crystal_count"] is Label, "HUD uses actual labels")
	_check(hud.labels["rock_count"].text == "6 left", "Both objectives visible")
	_check(not hud.buttons["stress"].visible, "Diagnostics hidden during normal play")
	for viewport in [Vector2(320, 568), Vector2(376, 746), Vector2(1280, 720)]:
		game.size = viewport
		await process_frame
		for mode in ["", "pause", "help", "result"]:
			game.overlay = mode if mode != "result" else ""
			game.finished = mode == "result"
			hud.refresh(game._layout())
			await process_frame
			for node in hud.get_children():
				if node is Control and node.visible and node != hud.shade:
					_check(Rect2(Vector2.ZERO, viewport).encloses(node.get_rect()), "Actual UI control fits viewport: " + node.name)
			if mode == "help":
				_check(hud.labels["modal_body"].get_visible_line_count() == hud.labels["modal_body"].get_line_count(), "Full field guide text fits without scrolling")
	game.size = root.get_visible_rect().size
	game.overlay = ""
	game.finished = false
	hud.refresh(game._layout())
	await process_frame
	var snapshot: Array = game.board.cells.duplicate()
	# Real GUI mouse and touch dispatch, rather than directly invoking callbacks.
	for touch in [false, true]:
		_tap(game._layout()["help_button"].get_center(), touch)
		await process_frame
		_check(game.overlay == "help", "Help opens via real pointer input")
		_check(hud.buttons["back"].has_focus(), "Dialog receives keyboard focus")
		_tap(game._board_rect().get_center(), touch)
		_check(game.board.cells == snapshot, "Help blocks board input")
		_tap(game._replay_rect().get_center(), touch)
		await process_frame
		_check(game.overlay.is_empty(), "Help back control closes via pointer")
		_tap(game._layout()["pause_button"].get_center(), touch)
		await process_frame
		_check(game.overlay == "pause" and hud.buttons["resume"].visible, "Pause opens via pointer")
		_tap(hud.buttons["resume"].get_global_rect().get_center(), touch)
		await process_frame
		_check(game.overlay.is_empty() and game.board.cells == snapshot, "Resume preserves exact board")
		game.board.nova_energy = game.BoardScript.NOVA_MAX
		hud.refresh(game._layout())
		_tap(game._nova_rect().get_center(), touch)
		await process_frame
		_check(game.phase == "nova_targeting", "Nova button toggles exactly once")
		_tap(game._nova_rect().get_center(), touch)
		await process_frame
		_check(game.phase == "idle" and game.board.nova_energy == game.BoardScript.NOVA_MAX, "Cancel keeps Nova charge")
	# Result screen needs an intentional button, not a board tap.
	game.finished = true
	game.phase = "finished"
	game.won = false
	game.score = 1234
	hud.refresh(game._layout())
	_check(hud.labels["modal_title"].text == "One more try?", "Defeat has a distinct result")
	_check(hud.labels["modal_score"].text == "1234 starlight", "Result keeps final score")
	_tap(game._board_rect().position + Vector2(10, 10))
	_check(game.finished, "Incidental result tap never replays")
	game.won = true
	hud.refresh(game._layout())
	_check(hud.labels["modal_title"].text == "Beautifully done.", "Victory has a distinct result")
	_tap(game._replay_rect().get_center())
	await process_frame
	_check(not game.finished and game.moves_left == 18, "Intentional result button replays")
	game.queue_free()
	await process_frame
	print("Responsive game layout: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
