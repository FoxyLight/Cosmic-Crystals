extends SceneTree
## Native events and lifecycle regressions; isolated save, never player data.
const Store = preload("res://scripts/progress_store.gd")
var checks: int = 0
var failures: int = 0
var path: String = "user://tests/android-rc-%d.json" % Time.get_ticks_usec()


func _initialize() -> void:
	_run.call_deferred()


func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Android RC: " + message)


func touch(point: Vector2, down: bool, finger: int = 0, cancelled: bool = false) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.position = point
	event.pressed = down
	event.index = finger
	event.canceled = cancelled
	root.push_input(event, true)


func tap(point: Vector2, finger: int = 0) -> void:
	touch(point, true, finger)
	touch(point, false, finger)


func _run() -> void:
	var game = load("res://scenes/Prototype.tscn").instantiate()
	game.save_path = path
	root.add_child(game)
	await process_frame
	# Done must work through Android screen events, not pressed.emit().
	for i in range(8):
		game.open_settings()
		await process_frame
		tap(game.settings_view.back.get_global_rect().get_center())
		await process_frame
		check(not game.settings_open and game.screen == "home", "Native Done closes settings without navigating underneath")
		game.close_settings()
	game.open_settings()
	await process_frame
	var done_point: Vector2 = game.settings_view.back.get_global_rect().get_center()
	touch(done_point, true)
	touch(done_point, false, 0, true)
	check(game.settings_open and not game.settings_view.back.is_pressed(), "Cancelled native Done resets without closing")
	var toggle: CheckButton = game.settings_view.toggles["large_text"]
	var point: Vector2 = toggle.get_global_rect().get_center()
	var before: bool = game.progress.data["settings"]["large_text"]
	touch(point, true)
	touch(point, false, 0, true)
	check(game.progress.data["settings"]["large_text"] == before, "Cancelled toggle release changes no preference")
	check(game.settings_view.active_touch_index == -1, "Cancelled gesture releases its finger")
	# A second finger cannot steal or release a captured setting gesture.
	touch(point, true, 2)
	tap(point, 3)
	check(game.settings_view.active_touch_index == 2, "Second finger cannot steal setting capture")
	touch(point, false, 2)
	check(game.progress.data["settings"]["large_text"] != before, "Original finger toggles exactly once")
	var slider: HSlider = game.settings_view.sliders["music_volume"]
	var bounds: Rect2 = slider.get_global_rect()
	touch(bounds.get_center(), true)
	var volume: float = game.progress.data["settings"]["music_volume"]
	touch(bounds.end, false, 0, true)
	check(game.progress.data["settings"]["music_volume"] == volume, "Cancelled slider does not jump to cancellation coordinates")
	touch(point, true, 4)
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(game.settings_view.active_touch_index == -1, "Focus loss cancels setting capture")
	var preferences: Dictionary = game.progress.data["settings"].duplicate(true)
	tap(point, 5)
	check(game.progress.data["settings"] == preferences, "Background setting gestures are ignored")
	game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(game.app_backgrounded and game.audio.blocked(), "Focus return alone cannot resume a paused app")
	game._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	touch(point, false, 4)
	check(game.progress.data["settings"] == preferences, "Release from interrupted gesture is inert after resume")
	touch(bounds.get_center(), true)
	game._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(not game.settings_open and game.settings_view.active_touch_index == -1, "Android Back closes settings and cancels its gesture")
	game.progress.data["completed"][0] = true
	game.progress.data["best_stars"][0] = 1
	game.progress.data["best_scores"][0] = 100
	game.progress.data["highest_unlocked"] = 2
	# Real authored four-match, repeated input and pause/focus loss mid-animation.
	for reduced in [false, true]:
		game.set_preference("reduced_motion", reduced)
		game.start_level(2)
		await process_frame
		var a: Vector2 = game._center_of(27, game._board_rect())
		var b: Vector2 = game._center_of(19, game._board_rect())
		# A cancelled release must not select, swap, spend or trigger Nova.
		var cells: Array = game.board.cells.duplicate()
		touch(a, true)
		touch(b, false, 0, true)
		check(game.phase == "idle" and game.selected == -1 and game.board.cells == cells, "Cancelled board swipe never begins a turn")
		# Reset only the test fixture if demonstrating the old cancellation defect.
		if game.phase == "resolving":
			await drain(game)
			game.start_level(2)
		touch(a, true)
		touch(b, false)
		check(game.phase == "resolving", "Native swipe begins authored Beam turn")
		var pending: Dictionary = game.session.pending.duplicate(true)
		var turn: int = game.session.turn_id
		for i in range(40):
			tap(a)
			tap(b, 1)
			game.request_restart()
			check(not game.go_map(true) and not game.start_level(1), "Rapid navigation cannot replace an animating board")
		check(game.session.turn_id == turn and game.session.pending == pending, "Rapid gestures cannot create duplicate turns")
		game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
		var elapsed: float = game.event_elapsed
		var score: int = game.score
		var moves: int = game.moves_left
		for i in range(5):
			game._process(1.0)
			await process_frame
		check(game.event_elapsed == elapsed and game.score == score and game.moves_left == moves, "Background freezes animation and uncommitted totals")
		game._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
		check(game.app_backgrounded, "Resume waits for focus")
		game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
		await drain(game)
		check(game.moves_left == moves - 1 and game.session.pending.is_empty(), "Interrupted turn commits exactly one move")
		check(game.overlay == "pause" and game.session.beams == 1, "Completed interrupted turn waits at pause with Beam award")
		var snapshot: Dictionary = game.progress.data.duplicate(true)
		check(not game.session.commit_outcome(pending), "Duplicate interrupted outcome cannot award twice")
		check(game.progress.data == snapshot, "Duplicate outcome leaves saved records alone")
		game.close_overlay()
		# Explicit charged-Nova fixture: a cancelled target release spends nothing.
		game.board.nova_enabled = true
		game.board.nova_energy = game.board.NOVA_MAX
		game.toggle_nova()
		touch(a, true)
		touch(a, false, 0, true)
		check(game.phase == "nova_targeting" and game.board.can_use_nova(), "Cancelled Nova target preserves its charge")
		check(game.session.nova_uses == 0 and game.session.pending.is_empty(), "Cancelled Nova queues no turn or objective credit")
		game.toggle_nova()
		game.go_map(true)
	# Restart scene from the same isolated disk save, preserving all preferences.
	game.set_preference("large_text", true)
	game.set_preference("music_volume", .35)
	game.set_preference("muted", true)
	var expected: Dictionary = game.progress.data.duplicate(true)
	game.queue_free()
	await process_frame
	game = load("res://scenes/Prototype.tscn").instantiate()
	game.save_path = path
	root.add_child(game)
	await process_frame
	check(game.progress.data == expected and game.audio.blocked(), "Scene restart restores volume, text and mute preferences")
	game.open_settings()
	await process_frame
	tap(game.settings_view.back.get_global_rect().get_center())
	await process_frame
	check(not game.settings_open, "Done works after persisted Larger Text reload")
	game.queue_free()
	await process_frame
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	print("Android RC: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func drain(game) -> void:
	for i in range(500):
		if game.phase != "resolving": return
		game.event_elapsed = game.event_duration
		await process_frame
	check(false, "Animation completes within bounded frames")
