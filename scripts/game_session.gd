extends RefCounted
## Rules/session state independent of UI, animation clocks and persistence.
const Board = preload("res://scripts/cosmic_board.gd")
const MOVE_BONUS: int = 25
var level: Dictionary = {}
var board
var moves_left: int = 0
var collected: int = 0
var collections: Dictionary = {}
var score: int = 0
var beams: int = 0
var powers: int = 0
var nova_uses: int = 0
var finished: bool = false
var won: bool = false
var pending: Dictionary = {}
var turn_id: int = 0


func load_level(definition: Dictionary) -> void:
	level = definition.duplicate(true)
	board = Board.new(int(level["seed"]))
	board.kinds.assign(level["kinds"])
	board.rng.seed = int(level["seed"])
	board.generate()
	board.enabled_powers.assign(level["powers"])
	board.nova_enabled = level["nova"]
	if level.get("opening", "") == "four_match":
		for row in range(8):
			for col in range(8):
				board.cells[row * 8 + col] = (row * 2 + col) % 6
		for index in [17, 18, 20, 27]:
			board.cells[index] = 1
		board.cells[19] = 2
	board.place_asteroids(level["asteroids"])
	for index in level.get("starter_powers", {}):
		board.specials[int(index)] = int(level["starter_powers"][index])
	if not board.has_legal_move():
		board._shuffle_deadlocked_board()
	moves_left = int(level["moves"])
	collected = 0
	collections = {}
	score = 0
	beams = 0
	powers = 0
	nova_uses = 0
	finished = false
	won = false
	pending = {}
	turn_id += 1


func begin_swap(a: int, b: int) -> Dictionary:
	if finished or not pending.is_empty() or moves_left <= 0:
		return {}
	return _begin(board.play_swap(a, b))


func begin_nova(target: int) -> Dictionary:
	if finished or not pending.is_empty() or not board.can_use_nova():
		return {}
	return _begin(board.use_nova(target))


func _begin(outcome: Dictionary) -> Dictionary:
	turn_id += 1
	outcome["session_turn"] = turn_id
	pending = outcome.duplicate(true)
	return outcome


func commit_outcome(outcome: Dictionary) -> bool:
	# Final score/goals are published only after the view finishes all events.
	# A stale or repeated callback cannot award a turn twice.
	if pending.is_empty() or outcome.get("session_turn", -1) != pending["session_turn"]:
		return false
	var result: Dictionary = pending
	pending = {}
	if not result["valid"]:
		return false
	if result["used_nova"]:
		nova_uses += 1
	else:
		moves_left -= 1
	collected += int(result["cleared"])
	score += int(result["score"])
	for kind in result["collected"]:
		collections[int(kind)] = int(collections.get(int(kind), 0)) + int(result["collected"][kind])
	if result["created"] in [Board.BEAM_ROW, Board.BEAM_COLUMN]:
		beams += 1
	powers += int(result["activated"])
	var complete: bool = true
	for goal in level["goals"]:
		complete = complete and goal_progress(goal) >= int(goal["target"])
	if complete:
		finished = true
		won = true
	elif moves_left <= 0:
		finished = true
		won = false
	return true


func goal_progress(goal: Dictionary) -> int:
	match goal["type"]:
		"collect":
			return collected if int(goal.get("kind", -1)) == -1 else int(collections.get(int(goal["kind"]), 0))
		"asteroids":
			return int(goal["target"]) - remaining_asteroids()
		"beams":
			return beams
		"powers":
			return powers
		"nova":
			return nova_uses
	return 0


func remaining_asteroids() -> int:
	var count: int = 0
	for health in board.asteroids:
		if health > 0:
			count += 1
	return count


func rating_score() -> int:
	return score + maxi(0, moves_left) * MOVE_BONUS if won else score


func stars() -> int:
	if not won:
		return 0
	var value: int = 1
	for i in range(1, 3):
		if rating_score() >= int(level["star_scores"][i]):
			value = i + 1
	return value


func goal_label(goal: Dictionary) -> String:
	match goal["type"]:
		"collect": return "CRYSTALS" if int(goal.get("kind", -1)) == -1 else ["AMETHYST", "AMBER", "SAPPHIRE", "RUBY", "EMERALD", "OPAL"][int(goal["kind"])]
		"asteroids": return "ASTEROIDS"
		"beams": return "FORGE BEAM"
		"powers": return "USE POWERS"
		"nova": return "USE NOVA"
	return "GOAL"


func goals_text() -> String:
	var lines: PackedStringArray = []
	for goal in level["goals"]:
		lines.append("%s  %d / %d" % [goal_label(goal).capitalize(), mini(goal_progress(goal), int(goal["target"])), goal["target"]])
	return "\n".join(lines)
