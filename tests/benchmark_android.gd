extends SceneTree
const Session = preload("res://scripts/game_session.gd")
const Levels = preload("res://scripts/level_catalog.gd")
const Solver = preload("res://tests/campaign_solver.gd")


func _initialize() -> void:
	var start: int = Time.get_ticks_usec()
	var loads: Array[int] = []
	var turns: int = 0
	var events: int = 0
	for repeat in range(4):
		for id in range(1, 6):
			var session = Session.new()
			var before: int = Time.get_ticks_usec()
			session.load_level(Levels.get_level(id))
			loads.append(Time.get_ticks_usec() - before)
			for turn in range(8):
				if session.finished: break
				var pair: Vector2i = session.board.find_legal_swap()
				var result: Dictionary = session.begin_swap(pair.x, pair.y)
				events += result.get("events", []).size()
				session.commit_outcome(result)
				turns += 1
				if not session.board.find_matches().is_empty():
					push_error("Benchmark ended with unsettled board")
					quit(1)
					return
	loads.sort()
	print("ANDROID_DEV_BENCHMARK ", JSON.stringify({"environment": OS.get_name(), "headless": true,
		"scope": "CPU session load/settlement; not Android FPS or audio hardware",
		"elapsed_ms": float(Time.get_ticks_usec() - start) / 1000,
		"load_median_ms": float(loads[loads.size()/2]) / 1000, "load_max_ms": float(loads[-1]) / 1000,
		"levels_loaded": loads.size(), "turns": turns, "events": events, "static_memory_bytes": OS.get_static_memory_usage()}))
	quit()
