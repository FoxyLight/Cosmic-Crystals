extends SceneTree
const Store = preload("res://scripts/progress_store.gd")
const Audio = preload("res://scripts/game_audio.gd")
const Layout = preload("res://scripts/game_layout.gd")
const Metrics = preload("res://scripts/performance_monitor.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Android polish: " + message)


func tap(point: Vector2) -> void:
	for down in [true, false]:
		var event: InputEventScreenTouch = InputEventScreenTouch.new()
		event.position = point
		event.pressed = down
		root.push_input(event, true)


func _run() -> void:
	var path: String = "user://tests/android-polish-%d.json" % Time.get_ticks_usec()
	var store = Store.new(path)
	var old: Dictionary = Store.fresh()
	old["settings"] = {"reduced_motion": true}
	old["completed"][0] = true
	old["best_stars"][0] = 3
	old["best_scores"][0] = 835
	store.data = Store.normalize(old)
	check(store.data["highest_unlocked"] == 2 and store.data["best_scores"][0] == 835, "M3 records survive additive preferences")
	for key in ["master_volume", "music_volume", "sfx_volume"]:
		check(store.set_preference(key, .35), "Volume saves safely")
	for key in ["muted", "large_text", "reduced_motion"]:
		check(store.set_preference(key, true), "Comfort toggle saves")
	var loaded = Store.new(path)
	loaded.load_progress()
	check(loaded.data == store.data, "All preferences and earned records survive disk reload")
	var malformed: Dictionary = loaded.data.duplicate(true)
	malformed["settings"]["music_volume"] = "loud"
	malformed["settings"]["master_volume"] = -2
	malformed["settings"]["sfx_volume"] = 5
	var normalized: Dictionary = Store.normalize(malformed)
	check(normalized["settings"]["music_volume"] == .45, "Malformed volume uses safe default")
	check(normalized["settings"]["master_volume"] == 0 and normalized["settings"]["sfx_volume"] == 1, "Volumes clamp safely")
	var audio = Audio.new()
	root.add_child(audio)
	check(audio.streams.size() == 22 and audio.effects.size() == 6 and audio.music.size() == 2, "All audio decoded once into bounded pools")
	for name in Audio.EFFECTS:
		check(audio.streams[name].get_length() > 0 and audio.streams[name].get_length() < 1.1, "Short original effect: " + name)
	for name in Audio.MUSIC:
		var stream = audio.streams["music_" + name]
		check(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and stream.loop_end > 0, "Music loops: " + name)
	audio.set_context("home")
	var starts: int = audio.music_starts
	for i in range(30): audio.set_context("home")
	check(audio.music_starts == starts, "Refresh does not restart soundtrack")
	audio.set_context("map")
	audio._process(.4)
	check(audio.gains[audio.target_voice] > 0 and audio.gains[audio.target_voice] < 1, "Music crossfades")
	audio.suspend("focus", true)
	audio.suspend("paused", true)
	check(not audio.cue("match") and audio.blocked(), "Background blocks audio and new effects")
	audio.suspend("focus", false)
	check(audio.blocked(), "Focus-in cannot override application-paused")
	audio.suspend("paused", false)
	check(not audio.blocked(), "Both resume conditions restore audio")
	audio.configure({"muted": true})
	check(audio.blocked() and not audio.cue("menu"), "Mute gates all effects/music")
	audio.configure({"muted": false, "master_volume": .5, "music_volume": .3, "sfx_volume": .5})
	check(not audio.blocked(), "Unmute restores preference levels")
	for name in Audio.EFFECTS: audio.cue(name)
	check(audio.dropped > 0 and audio.effects.size() == 6, "Heavy effects obey concurrency cap")
	check(audio.event_cues({"type": "swap_back"}) == ["invalid"], "Invalid swap sound at rollback")
	var cues: Array[String] = audio.event_cues({"type": "clear", "chain": 3, "indices": [0, 1, 2, 3], "specials_before": [1, 2, 3, 4]})
	check(cues == ["cascade", "beam", "bomb", "supernova"], "Special cue layers deduplicate Beams")
	check(audio.event_cues({"type": "asteroid_hit", "destroyed": []}) == ["rock_hit"], "Rock crack cue")
	check(audio.event_cues({"type": "asteroid_hit", "destroyed": [2]}) == ["rock_break"], "Rock destruction cue")
	audio.queue_free()
	var game = load("res://scenes/Prototype.tscn").instantiate()
	game.save_path = path
	root.add_child(game)
	await process_frame
	var records: Dictionary = game.progress.data.duplicate(true)
	tap(game.campaign_view.buttons["settings"].get_global_rect().get_center())
	await process_frame
	check(game.settings_open and game.settings_view.visible, "Home settings opens through real Android touch")
	game.set_preference("muted", false)
	game.set_preference("music_volume", .25)
	for dimension in [Vector2(320, 568), Vector2(376, 746), Vector2(600, 960), Vector2(800, 1280)]:
		game.size = dimension
		game._refresh_views()
		var safe: Rect2 = game._layout()["safe"]
		for control in game.settings_view.sliders.values() + game.settings_view.toggles.values() + [game.settings_view.back]:
			check(control.size.y >= 48, "Settings target is 48 logical pixels high")
			check(safe.grow(.5).encloses(control.get_rect()), "Settings controls avoid screen edges")
		var cutout: Dictionary = Layout.calculate(dimension, Vector4(12, 32, 12, 24), true)
		for key in ["board", "goals", "score", "moves", "nova", "help_button", "pause_button"]:
			check(cutout["safe"].grow(.5).encloses(cutout[key]), "Android cutout/navigation-safe " + key)
	game.size = root.get_visible_rect().size
	game.close_settings()
	check(game.start_level(2), "Earned unlock survives settings changes")
	for repeat in range(25):
		game.go_map(true)
		game.show_home()
		game.go_map(true)
		check(game.start_level(2), "Repeated navigation keeps selected level playable")
	game.set_preference("reduced_motion", true)
	game._take_turn(27, 19)
	for frame in range(500):
		if game.phase != "resolving": break
		game.event_elapsed = game.event_duration
		await process_frame
	check(game.phase != "resolving" and game.metrics.events.get("special_create", 0) > 0, "Real Beam turn dispatches immutable animation events")
	check(game.audio.dispatched.get("swap", 0) > 0 and game.audio.dispatched.get("match", 0) > 0, "Real scene turn dispatches sound alongside effects")
	var before_score: int = game.score
	game.open_overlay("pause")
	game.open_settings()
	game._handle_touch(game._board_rect().get_center(), true)
	game._handle_touch(game._board_rect().get_center(), false)
	check(game.score == before_score and game.selected == -1, "Settings sheet intercepts board input")
	game.close_settings()
	game.close_overlay()
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(game.app_backgrounded and game.overlay == "pause" and game.audio.blocked(), "Android interruption clears gestures, pauses view and audio")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(not game.app_backgrounded and game.overlay == "pause", "Foreground keeps intentional pause")
	game.close_overlay()
	# Compare identical seeded rules via two independent sessions, never motion.
	var session_script = load("res://scripts/game_session.gd")
	var a = session_script.new()
	var b = session_script.new()
	a.load_level(game.session.level)
	b.load_level(game.session.level)
	var outcome_a: Dictionary = a.begin_swap(27, 19)
	game.set_preference("reduced_motion", false)
	check(game._event_duration("clear") > .01, "Standard effects retain readable timing")
	game.set_preference("reduced_motion", true)
	check(game._event_duration("clear") == .01 and game._event_duration("asteroid_hit") == .01, "Reduced motion shortens all effects")
	var outcome_b: Dictionary = b.begin_swap(27, 19)
	a.commit_outcome(outcome_a)
	b.commit_outcome(outcome_b)
	check(a.score == b.score and a.goal_progress(a.level["goals"][0]) == b.goal_progress(b.level["goals"][0]) and a.board.cells == b.board.cells, "Comfort mode cannot change rules or scores")
	check(game.progress.data["best_scores"][0] == records["best_scores"][0] and game.progress.data["best_stars"][0] == 3, "Preferences never erase earned records")
	var monitor = Metrics.new()
	for i in range(1200): monitor.sample(.016)
	check(monitor.frames.size() == 600 and absf(monitor.report()["mean_frame_ms"] - 16) < .01, "Bounded frame diagnostics compute reproducibly")
	game.queue_free()
	await process_frame
	await process_frame
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	print("Android polish: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
