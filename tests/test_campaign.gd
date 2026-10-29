extends SceneTree
const Levels = preload("res://scripts/level_catalog.gd")
const Session = preload("res://scripts/game_session.gd")
const Solver = preload("res://tests/campaign_solver.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run()
	print("Lyra campaign: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Lyra: " + message)


func _run() -> void:
	_check(Levels.all().size() == 5, "Exactly five authored levels")
	_check(Levels.get_level(0).is_empty() and Levels.get_level(6).is_empty(), "Bounds reject nonexistent levels")
	var bad: Dictionary = Levels.get_level(1)
	bad["moves"] = -1
	_check(Levels.normalize(bad).is_empty(), "Bad move budget rejected")
	bad = Levels.get_level(3)
	bad["asteroids"] = {"64": 2}
	_check(Levels.normalize(bad).is_empty(), "Out-of-board rocks rejected")
	bad = Levels.get_level(1)
	bad["goals"] = [{"type": "nova", "target": 1}]
	_check(Levels.normalize(bad).is_empty(), "Impossible disabled-mechanic objective rejected")
	var unit = Session.new()
	unit.load_level(Levels.get_level(1))
	var move: Vector2i = unit.board.find_legal_swap()
	unit.moves_left = 1
	unit.level["goals"][0]["target"] = 1
	var probe_outcome: Dictionary = unit.begin_swap(move.x, move.y)
	_check(not unit.finished and unit.moves_left == 1 and unit.collected == 0, "No premature win/move count before full event playback")
	_check(unit.begin_swap(move.x, move.y).is_empty(), "Second turn locked while resolution is pending")
	_check(unit.commit_outcome(probe_outcome) and unit.won and unit.moves_left == 0, "Last-move victory beats defeat")
	var score: int = unit.score
	_check(not unit.commit_outcome(probe_outcome) and unit.score == score, "Duplicate callback cannot award twice")
	_check(unit.begin_swap(0, 1).is_empty(), "Finished level rejects further actions")
	for value in [0, 499, 500, 699, 700]:
		unit.score = value
		_check(unit.stars() == (3 if value >= 700 else (2 if value >= 500 else 1)), "Star threshold boundary")
	unit.load_level(Levels.get_level(1))
	unit.moves_left = 1
	unit.level["goals"][0]["target"] = 1000
	move = unit.board.find_legal_swap()
	probe_outcome = unit.begin_swap(move.x, move.y)
	unit.commit_outcome(probe_outcome)
	_check(unit.finished and not unit.won and unit.stars() == 0, "Unmet goals at zero moves lose")
	unit.load_level(Levels.get_level(2))
	probe_outcome = unit.begin_swap(27, 19)
	unit.commit_outcome(probe_outcome)
	_check(unit.beams == 1, "Authored opening teaches actual four-match formation")
	_check(unit.goal_progress({"type": "collect", "kind": 1, "target": 1}) >= 3, "Per-color collection counts are retained")
	_check(not unit.board.can_use_nova(), "Nova unavailable before introduction")
	unit.load_level(Levels.get_level(1))
	probe_outcome = unit.begin_swap(-1, 8)
	unit.commit_outcome(probe_outcome)
	_check(unit.moves_left == 18 and unit.score == 0 and unit.collected == 0, "Invalid swap costs no move/score")
	unit.load_level(Levels.get_level(5))
	unit.board.nova_energy = unit.board.NOVA_MAX
	var budget: int = unit.moves_left
	probe_outcome = unit.begin_nova(18)
	unit.commit_outcome(probe_outcome)
	_check(unit.moves_left == budget and unit.nova_uses == 1 and unit.board.nova_energy == 0, "Campaign Nova preserves zero-move/no-recharge behavior")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 777
	for level in Levels.all():
		var random_wins: int = 0
		var greedy_wins: int = 0
		for policy in [false, true]:
			for variant in range(12):
				var definition: Dictionary = level.duplicate(true)
				definition["seed"] += variant * 71
				var session = Session.new()
				session.load_level(definition)
				_check(session.board.find_matches().is_empty(), "No initial triples")
				_check(session.board.has_legal_move(), "Every level starts playable")
				for i in range(64):
					_check(session.board.is_blocked(i) or session.board.kinds.has(session.board.cells[i]), "Only allowed kinds generated")
				var actions: int = 0
				while not session.finished and actions < 60:
					var choice: Vector2i = Solver.choose(session, rng, policy)
					var outcome: Dictionary = Solver.play(session, choice)
					_check(not outcome.is_empty() and outcome["valid"], "Policy chooses a valid action")
					_check(not session.finished, "No terminal result before committed playback")
					session.commit_outcome(outcome)
					_check(session.board.find_matches().is_empty() and session.board.has_legal_move(), "Turn settles stable and playable")
					actions += 1
				_check(session.finished, "Finite campaign round")
				if session.won:
					if policy: greedy_wins += 1
					else: random_wins += 1
				_check(session.stars() >= 1 if session.won else session.stars() == 0, "Only victories award stars")
		print("Level %d (%s): random %d/12, one-ply %d/12" % [level["id"], level["name"], random_wins, greedy_wins])
		_check(greedy_wins >= 10, "Objective-aware policy can reasonably win each level")
