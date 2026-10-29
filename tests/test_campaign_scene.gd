extends SceneTree
const Solver = preload("res://tests/campaign_solver.gd")
const Store = preload("res://scripts/progress_store.gd")
var checks: int = 0
var failures: int = 0
var save_path: String = "user://tests/lyra-scene-%d.json" % Time.get_ticks_usec()


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Campaign scene: " + message)


func _tap(position: Vector2) -> void:
	for pressed in [true, false]:
		var event: InputEventScreenTouch = InputEventScreenTouch.new()
		event.position = position
		event.pressed = pressed
		root.push_input(event, true)


func _fresh():
	var game = load("res://scenes/Prototype.tscn").instantiate()
	game.save_path = save_path
	root.add_child(game)
	return game


func _drain(game) -> void:
	for frame in range(500):
		if game.phase != "resolving":
			await process_frame
			return
		var board = game.board
		var moves: int = game.moves_left
		_check(not game.go_map(true), "No screen transition through active effects")
		_check(not game.start_level(1), "No level replacement through active effects")
		game._reset_game()
		_check(game.board == board and game.moves_left == moves, "Restart cannot discard an active turn")
		game._handle_touch(game._board_rect().get_center(), true)
		game._handle_touch(game._board_rect().get_center(), false)
		_check(game.phase == "resolving", "Extra touch cannot overlap a resolving turn")
		game.event_elapsed = game.event_duration
		await process_frame
	_check(false, "Animations must finish within event bound")


func _take_action(game, choice: Vector2i) -> void:
	if choice.x == -1:
		_tap(game._nova_rect().get_center())
		await process_frame
		_check(game.phase == "nova_targeting", "Campaign Nova enters target mode")
		_tap(game._center_of(choice.y, game._board_rect()))
	else:
		_tap(game._center_of(choice.x, game._board_rect()))
		_tap(game._center_of(choice.y, game._board_rect()))
	_check(game.phase == "resolving", "Real touch starts an animated campaign action")
	await _drain(game)


func _run() -> void:
	var game = _fresh()
	await process_frame
	_check(game.screen == "home", "App starts at Home")
	_check(game.progress.data == Store.fresh(), "Isolated test starts with fresh progress")
	_tap(game.campaign_view.buttons["journey"].get_global_rect().get_center())
	await process_frame
	_check(game.screen == "map", "Home opens Lyra map by touch")
	_check(game.campaign_view.buttons["node2"].disabled, "Locked node cannot be tapped")
	_check(not game.start_level(2), "Controller also enforces locks")
	_tap(game.campaign_view.buttons["play"].get_global_rect().get_center())
	await process_frame
	_check(game.screen == "game" and game.current_level_id == 1, "Map starts First Starlight")
	# A real last-move defeat awards no progress and offers intentional retry.
	game.moves_left = 1
	game.session.level["goals"][0]["target"] = 1000
	var first: Vector2i = game.board.find_legal_swap()
	await _take_action(game, first)
	_check(game.finished and not game.won, "Unmet goals produce defeat after effects")
	_check(game.progress.data["completed"].count(true) == 0 and game.progress.data["highest_unlocked"] == 1, "Defeat grants no progression")
	_check(game.hud.buttons["map"].visible and game.hud.buttons["replay"].visible, "Defeat offers retry and map")
	_tap(game.hud.buttons["replay"].get_global_rect().get_center())
	await process_frame
	_check(not game.finished and game.moves_left == 18, "Try again restores authored level")
	# Android back during a real turn queues pause until the whole turn settles.
	var gentle: Vector2i = game.board.find_legal_swap()
	for option in Solver.options(game.session):
		var clone = Solver.clone_board(game.board)
		if clone.play_swap(option.x, option.y)["cleared"] < 24:
			gentle = option
			break
	game._take_turn(gentle.x, gentle.y)
	game._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	_check(game.pause_after_turn and game.overlay.is_empty(), "Back request waits for active animation")
	await _drain(game)
	_check(game.overlay == "pause" and game.moves_left == 17, "Back opens pause after stable committed turn")
	game.close_overlay()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 999
	# Full five-level end-to-end through the actual scene/controller, including
	# animated touch actions, result buttons, disk saving and a real scene reload.
	for id in range(1, 6):
		if game.current_level_id != id or game.screen != "game":
			_tap(game.campaign_view.buttons["node%d" % id].get_global_rect().get_center())
			await process_frame
			_tap(game.campaign_view.buttons["play"].get_global_rect().get_center())
			await process_frame
		_check(game.current_level_id == id and game.screen == "game", "Correct selected campaign level")
		_check(not game.next_level(), "Next unavailable before victory")
		var actions: int = 0
		while not game.finished and actions < 60:
			var choice: Vector2i = Solver.choose(game.session, rng)
			await _take_action(game, choice)
			actions += 1
		_check(game.finished and game.won, "Actual scene completes authored level %d" % id)
		_check(game.progress.data["completed"][id - 1], "Scene victory persisted")
		_check(game.progress.data["best_stars"][id - 1] == game.session.stars(), "Actual earned stars saved")
		_check(game.hud.buttons["map"].visible, "Results provide Return to Map")
		var result_board = game.board
		game._handle_touch(game._replay_rect().get_center(), true)
		game._handle_touch(game._replay_rect().get_center(), false)
		_check(game.board == result_board, "Unhandled result touches cannot replay the campaign")
		if id == 1:
			var earned: Dictionary = game.progress.data.duplicate(true)
			_tap(game.hud.buttons["replay"].get_global_rect().get_center())
			await process_frame
			_check(game.moves_left == 18 and game.progress.data == earned, "Replay cannot erase earned progress")
			# Pause -> restart confirmation -> cancel -> map confirmation.
			_tap(game.hud.buttons["pause"].get_global_rect().get_center())
			await process_frame
			_tap(game.hud.buttons["restart"].get_global_rect().get_center())
			await process_frame
			_check(game.overlay == "restart", "Mid-round restart requires deliberate confirmation")
			_tap(game.hud.buttons["resume"].get_global_rect().get_center())
			await process_frame
			_check(game.overlay.is_empty(), "Cancel restart resumes same round")
			game.go_map()
			_check(game.overlay == "leave", "Returning to map confirms unfinished-round discard")
			_tap(game.hud.buttons["confirm_leave"].get_global_rect().get_center())
			await process_frame
			_check(game.screen == "map" and game.progress.data == earned, "Map navigation preserves earned records")
			game.queue_free()
			await process_frame
			game = _fresh()
			await process_frame
			_check(game.progress.data == earned and game.screen == "home", "New scene restores disk progress")
			_tap(game.campaign_view.buttons["journey"].get_global_rect().get_center())
			await process_frame
			_check(not game.campaign_view.buttons["node2"].disabled, "Restarted map shows newly unlocked level")
		elif id < 5:
			_tap(game.hud.buttons["next"].get_global_rect().get_center())
			await process_frame
			_check(game.current_level_id == id + 1 and not game.finished, "Next Level advances exactly once")
	_check(game.progress.all_completed() and not game.hud.buttons["next"].visible, "Final level has a finite Lyra ending")
	_tap(game.hud.buttons["map"].get_global_rect().get_center())
	await process_frame
	_check(game.screen == "map" and "Lyra restored" in game.campaign_view.labels["map_progress"].text, "Map celebrates restored constellation")
	var final_records: Dictionary = game.progress.data.duplicate(true)
	game.show_home()
	_tap(game.campaign_view.motion.get_global_rect().get_center())
	await process_frame
	_check(game.reduced_motion(), "Reduced motion setting is an actual touch control")
	game.queue_free()
	await process_frame
	game = _fresh()
	await process_frame
	_check(game.reduced_motion() and game.progress.data["best_scores"] == final_records["best_scores"], "Settings and scores survive another restart")
	# Inspect real Control bounds on every main screen/modal at small and wide
	# sizes, including the three-goal final level.
	for viewport in [Vector2(320, 568), Vector2(376, 746), Vector2(1280, 720)]:
		game.size = viewport
		for screen in ["home", "map", "game"]:
			game.screen = screen
			if screen == "game":
				game.start_level(5)
			game._refresh_views()
			await process_frame
			var view: Control = game.hud if screen == "game" else game.campaign_view
			for node in view.get_children():
				if node is Control and node.is_visible_in_tree():
					_check(Rect2(Vector2.ZERO, viewport).encloses(node.get_rect()), "Actual campaign control fits: " + node.name)
		game.open_overlay("pause")
		await process_frame
		for key in ["resume", "guide", "restart", "map"]:
			_check(game._layout()["dialog"].encloses(game.hud.buttons[key].get_rect()), "Pause action fits dialog")
		game.close_overlay()
	game.queue_free()
	await process_frame
	for suffix in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(save_path + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path + suffix))
	print("Lyra scene end-to-end: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
