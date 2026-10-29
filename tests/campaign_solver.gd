extends RefCounted
## Test-only deterministic one-ply policy; never shipped as player assistance.
const Board = preload("res://scripts/cosmic_board.gd")


static func clone_board(source):
	var copy = Board.new(1)
	copy.cells = source.cells.duplicate()
	copy.specials = source.specials.duplicate()
	copy.asteroids = source.asteroids.duplicate()
	copy.kinds = source.kinds.duplicate()
	copy.enabled_powers = source.enabled_powers.duplicate()
	copy.nova_enabled = source.nova_enabled
	copy.nova_energy = source.nova_energy
	copy.rng.state = source.rng.state
	return copy


static func options(session) -> Array[Vector2i]:
	var choices: Array[Vector2i] = []
	for i in range(64):
		for neighbor in [i + 1, i + 8]:
			if session.board.would_match(i, neighbor):
				choices.append(Vector2i(i, neighbor))
	return choices


static func choose(session, rng: RandomNumberGenerator, greedy: bool = true) -> Vector2i:
	var choices: Array[Vector2i] = options(session)
	if session.board.can_use_nova():
		for i in range(64):
			choices.append(Vector2i(-1, i))
	if choices.is_empty():
		return Vector2i(-2, -2)
	if not greedy:
		# Charge is used promptly; ordinary swaps are chosen without lookahead.
		return Vector2i(-1, rng.randi_range(0, 63)) if session.board.can_use_nova() else choices[rng.randi_range(0, choices.size() - 1)]
	var best: float = -INF
	var chosen: Vector2i = choices[0]
	for choice in choices:
		var copy = clone_board(session.board)
		var outcome: Dictionary = copy.use_nova(choice.y) if choice.x == -1 else copy.play_swap(choice.x, choice.y)
		var value: float = float(outcome["cleared"]) + float(outcome["score"]) * 0.015
		for goal in session.level["goals"]:
			if session.goal_progress(goal) >= int(goal["target"]):
				continue
			match goal["type"]:
				"asteroids": value += int(outcome["asteroids_hit"]) * 35 + int(outcome["asteroids_destroyed"]) * 80
				"beams": value += 500 if outcome["created"] in [1, 2] else 0
				"powers": value += int(outcome["activated"]) * 100
				"nova": value += 500 if choice.x == -1 else 0
		if choice.x == -1:
			value += 15
		if value > best:
			best = value
			chosen = choice
	return chosen


static func play(session, move: Vector2i) -> Dictionary:
	return session.begin_nova(move.y) if move.x == -1 else session.begin_swap(move.x, move.y)
