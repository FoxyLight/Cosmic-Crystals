extends SceneTree
const Store = preload("res://scripts/progress_store.gd")
const Session = preload("res://scripts/game_session.gd")
const Levels = preload("res://scripts/level_catalog.gd")
const Solver = preload("res://tests/campaign_solver.gd")
var checks: int = 0
var failures: int = 0
var save_path: String = "user://tests/lyra-progress-%d.json" % Time.get_ticks_usec()


func _initialize() -> void:
	_run()
	for suffix in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(save_path + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path + suffix))
	print("Lyra persistence: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Save: " + message)


func _write(text: String) -> void:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _run() -> void:
	var store = Store.new(save_path)
	store.load_progress()
	_check(store.data == Store.fresh(), "Missing save starts fresh")
	_check(store.can_play(1) and not store.can_play(2) and not store.can_play(0), "Only first level initially unlocked")
	_check(store.save_progress(), "First safe write succeeds")
	_check(not FileAccess.file_exists(save_path + ".tmp"), "Temporary file atomically promoted")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 888
	# Real end-to-end model playthrough with disk reload after every win.
	for id in range(1, 6):
		var session = Session.new()
		session.load_level(Levels.get_level(id))
		_check(not store.record_victory(session), "No award before terminal victory")
		while not session.finished:
			var choice: Vector2i = Solver.choose(session, rng)
			var outcome: Dictionary = Solver.play(session, choice)
			_check(not store.record_victory(session), "Pending animations cannot award progression")
			session.commit_outcome(outcome)
		_check(session.won, "Authored campaign plan wins")
		_check(store.record_victory(session), "Victory persists")
		store.mark_tutorial(id)
		var reopened = Store.new(save_path)
		reopened.load_progress()
		_check(reopened.data == store.data, "Restart retains every earned record/tutorial")
		_check(reopened.can_play(mini(5, id + 1)), "Win unlocks exactly the next level")
		_check(reopened.data["best_scores"][id - 1] == session.rating_score(), "Score bonus saved consistently")
		_check(reopened.data["best_stars"][id - 1] == session.stars(), "Star rating saved consistently")
		var best: Dictionary = store.data.duplicate(true)
		session.score = 0
		session.moves_left = 0
		store.record_victory(session)
		_check(store.data == best, "Lower replay cannot erase stars or high score")
		session.won = false
		_check(not store.record_victory(session) and store.data == best, "Defeat grants nothing")
	_check(store.total_stars() <= 15 and store.all_completed(), "Five-level ending, no sixth level")
	_check(not store.can_play(6), "Expansion remains locked/out of scope")
	store.set_reduced_motion(true)
	var reopened = Store.new(save_path)
	reopened.load_progress()
	_check(reopened.data["settings"]["reduced_motion"], "Settings persist")
	var backup: Dictionary = Store.normalize(JSON.parse_string(FileAccess.get_file_as_string(save_path + ".bak")))
	_write("{truncated")
	reopened.load_progress()
	_check(reopened.data == backup and not reopened.notice.is_empty(), "Corruption recovers known-good prior checkpoint")
	_check(reopened.save_progress(), "Recovered checkpoint can be promoted")
	_check(Store.normalize(JSON.parse_string(FileAccess.get_file_as_string(save_path))) == backup, "Corrupt main cannot poison recovery")
	_write(JSON.stringify({"schema_version": 99, "precious_future_data": true}))
	var future: String = FileAccess.get_file_as_string(save_path)
	reopened.load_progress()
	_check(reopened.read_only and not reopened.save_progress(), "Future schema opens safely read-only")
	_check(FileAccess.get_file_as_string(save_path) == future, "Unknown future data never overwritten")
	# Unsupported legacy schema has no migration because no earlier Godot save
	# schema existed. Backup can recover it; otherwise default safely.
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path + ".bak"))
	_write(JSON.stringify({"schema_version": 0}))
	reopened.load_progress()
	_check(reopened.data == Store.fresh(), "Unknown legacy schema safely defaults")
	_write("[]")
	reopened.load_progress()
	_check(reopened.data == Store.fresh(), "Wrong root type safely defaults")
	var forged: Dictionary = Store.fresh()
	forged["highest_unlocked"] = 5
	_check(Store.normalize(forged)["highest_unlocked"] == 1, "Unlock counter cannot bypass completions")
	forged["best_scores"][0] = -2
	_check(Store.normalize(forged).is_empty(), "Negative scores rejected")
	forged = Store.fresh()
	forged["completed"][0] = true
	_check(Store.normalize(forged).is_empty(), "Inconsistent completed record rejected")
	_check(Store.normalize({"schema_version": 1}).is_empty(), "Partial writes rejected")
	var blocked = Store.new("res://project.godot/cannot-write.json")
	_check(not blocked.save_progress() and not blocked.notice.is_empty(), "Write failure reports unsaved progress")
