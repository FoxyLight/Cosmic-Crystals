extends Control
## Animated Android-first match-3 prototype, with a clearly labeled synthetic
## 30-second drawing stress check. M2 adds specials and Nova Pulse.
## Asteroids, save data and level progression remain unimplemented.

const BoardScript = preload("res://scripts/cosmic_board.gd")
const Visuals = preload("res://scripts/crystal_visuals.gd")
const GOAL: int = 30
const STARTING_MOVES: int = 18

const SWAP_SECONDS: float = 0.17
const CLEAR_SECONDS: float = 0.19
const FALL_SECONDS: float = 0.27
const RESHUFFLE_SECONDS: float = 0.28

var board = null
var display_cells: Array[int] = []
var display_specials: Array[int] = []
var moves_left: int = STARTING_MOVES
var collected: int = 0
var score: int = 0
var selected: int = -1
var press_index: int = -1
var press_position: Vector2 = Vector2.ZERO

var phase: String = "idle"
var active_event: Dictionary = {}
var event_elapsed: float = 0.0
var event_duration: float = 0.01
var finished: bool = false
var won: bool = false
var feedback: String = "Swap adjacent crystals to rekindle the stars"
var feedback_ok: bool = true
var flash_time: float = 0.0
var elapsed: float = 0.0

# Synthetic 2D stress draw, not a claim about production particles or device FPS.
var stress_active: bool = false
var stress_elapsed: float = 0.0
var stress_samples: int = 0
var stress_fps_total: float = 0.0
var stress_min_fps: float = 100000.0
var stress_report: String = "Tap STRESS 30S to test effects rendering"


func _ready() -> void:
	_reset_game()


func _reset_game() -> void:
	board = BoardScript.new(20261029 + int(Time.get_ticks_msec() % 100000))
	display_cells = board.cells.duplicate()
	display_specials = board.specials.duplicate()
	moves_left = STARTING_MOVES
	collected = 0
	score = 0
	selected = -1
	press_index = -1
	phase = "idle"
	active_event = {}
	finished = false
	won = false
	feedback = "Drag or tap two neighboring crystals"
	feedback_ok = true
	flash_time = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	flash_time = maxf(0.0, flash_time - delta)
	if not active_event.is_empty():
		event_elapsed = minf(event_elapsed + delta, event_duration)
	if stress_active:
		stress_elapsed += delta
		if Engine.get_frames_per_second() > 0:
			var fps: float = float(Engine.get_frames_per_second())
			stress_samples += 1
			stress_fps_total += fps
			stress_min_fps = minf(stress_min_fps, fps)
		if stress_elapsed >= 30.0:
			stress_active = false
			var mean_fps: float = stress_fps_total / float(maxi(stress_samples, 1))
			stress_report = "Draw test: avg %.0f / min %.0f FPS" % [mean_fps, stress_min_fps if stress_samples > 0 else 0.0]
			print("COSMIC_STRESS: %s" % stress_report)
	queue_redraw()


func _board_rect() -> Rect2:
	# Reserve HUD + stress control space on portrait phones.
	var available_width: float = maxf(120.0, size.x - 28.0)
	var available_height: float = maxf(120.0, size.y - 345.0)
	var side: float = minf(minf(available_width, available_height), 640.0)
	var top: float = maxf(232.0, (size.y - side) * 0.52)
	top = minf(top, maxf(110.0, size.y - side - 76.0))
	return Rect2(Vector2((size.x - side) * 0.5, top), Vector2(side, side))


func _nova_rect() -> Rect2:
	return Rect2(Vector2(20.0, 178.0), Vector2(138.0, 36.0))


func _stress_rect() -> Rect2:
	return Rect2(Vector2(maxf(12.0, size.x - 158.0), 178.0), Vector2(140.0, 36.0))


func _index_at(screen_pos: Vector2) -> int:
	var rect: Rect2 = _board_rect()
	if not rect.has_point(screen_pos):
		return -1
	var cell_size: float = rect.size.x / 8.0
	var col: int = clampi(int((screen_pos.x - rect.position.x) / cell_size), 0, 7)
	var row: int = clampi(int((screen_pos.y - rect.position.y) / cell_size), 0, 7)
	return row * 8 + col


func _center_of(index: int, rect: Rect2) -> Vector2:
	var tile: float = rect.size.x / 8.0
	return rect.position + Vector2(float(index % 8) + 0.5, float(int(index / 8)) + 0.5) * tile


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0B102A"))
	_draw_starfield()
	_draw_hud()
	if board == null:
		return
	var rect: Rect2 = _board_rect()
	draw_rect(rect.grow(8.0), Color(0.18, 0.12, 0.37, 0.9))
	draw_rect(rect.grow(3.0), Color("#29234E"))
	var tile: float = rect.size.x / 8.0
	for index in range(64):
		var origin: Vector2 = rect.position + Vector2(index % 8, int(index / 8)) * tile
		var selected_cell: bool = phase == "idle" and selected == index
		draw_rect(Rect2(origin + Vector2(2, 2), Vector2(tile - 4.0, tile - 4.0)),
			Color(0.13, 0.18, 0.33) if selected_cell else Color(0.08, 0.11, 0.23))
		if selected_cell:
			draw_rect(Rect2(origin + Vector2(2, 2), Vector2(tile - 4.0, tile - 4.0)),
				Color("#39D5FF"), false, 2.0)

	if active_event.is_empty():
		_draw_snapshot(display_cells, rect)
	else:
		_draw_animated_event(rect)

	if flash_time > 0.0:
		var tint: Color = Color(0.20, 0.90, 0.86, flash_time * 0.20) if feedback_ok else Color(1, 0.25, 0.40, flash_time * 0.23)
		draw_rect(rect, tint)
	if stress_active:
		_draw_stress_effects(rect)
	_draw_footer(rect)


func _draw_snapshot(snapshot: Array, rect: Rect2, powers: Array = []) -> void:
	var snapshot_powers: Array = display_specials if powers.is_empty() else powers
	for index in range(snapshot.size()):
		var kind: int = int(snapshot[index])
		if kind >= 0:
			_draw_crystal(_center_of(index, rect), rect.size.x / 8.0 * 0.34,
				kind, 1.0, int(snapshot_powers[index]))


func _draw_animated_event(rect: Rect2) -> void:
	var t: float = clampf(event_elapsed / event_duration, 0.0, 1.0)
	var eased: float = t * t * (3.0 - 2.0 * t)
	var kind: String = str(active_event["type"])
	var before: Array = active_event["before"]
	var before_powers: Array = active_event.get("specials_before", display_specials)
	var radius: float = rect.size.x / 8.0 * 0.34
	match kind:
		"swap", "swap_back":
			var a: int = int(active_event["a"])
			var b: int = int(active_event["b"])
			for index in range(before.size()):
				if index != a and index != b and int(before[index]) >= 0:
					_draw_crystal(_center_of(index, rect), radius, int(before[index]), 1.0, int(before_powers[index]))
			_draw_crystal(_center_of(a, rect).lerp(_center_of(b, rect), eased), radius, int(before[a]), 1.0, int(before_powers[a]))
			_draw_crystal(_center_of(b, rect).lerp(_center_of(a, rect), eased), radius, int(before[b]), 1.0, int(before_powers[b]))
		"clear":
			var marked: Dictionary = {}
			for index in active_event["indices"]:
				marked[int(index)] = true
			for index in range(before.size()):
				if int(before[index]) < 0:
					continue
				if marked.has(index):
					_draw_crystal(_center_of(index, rect), radius * (1.0 - t * 0.46), int(before[index]), 1.0 - t, int(before_powers[index]))
				else:
					_draw_crystal(_center_of(index, rect), radius, int(before[index]))
		"fall":
			for move in active_event["moves"]:
				var from_index: int = int(move["from"])
				var to_index: int = int(move["to"])
				_draw_crystal(_center_of(from_index, rect).lerp(_center_of(to_index, rect), eased),
					radius, int(move["kind"]), 1.0, int(move.get("special", 0)))
			for spawn in active_event["spawns"]:
				var to_index: int = int(spawn["to"])
				var start_row: int = int(spawn["from_row"])
				var start: Vector2 = _center_of(to_index, rect)
				start.y = rect.position.y + (float(start_row) + 0.5) * (rect.size.x / 8.0)
				_draw_crystal(start.lerp(_center_of(to_index, rect), eased), radius, int(spawn["kind"]), 1.0, int(spawn.get("special", 0)))
		"special_create":
			_draw_snapshot(active_event["after"], rect, active_event["specials_after"])
			var target: int = int(active_event["index"])
			var pulse_color: Color = Color("#FFE8A9", (1.0 - t) * 0.9)
			draw_arc(_center_of(target, rect), radius * (0.9 + t * 0.55),
				0.0, TAU, 24, pulse_color, 2.5, true)
		"reshuffle":
			if t < 0.5:
				_draw_snapshot(before, rect, before_powers)
			else:
				_draw_snapshot(active_event["after"], rect, active_event["specials_after"])
		_:
			_draw_snapshot(active_event["after"], rect, active_event["specials_after"])


func _draw_starfield() -> void:
	for i in range(85):
		var px: float = fposmod(float(i * 173 + 29), maxf(size.x, 1.0))
		var py: float = fposmod(float(i * 241 + 71), maxf(size.y, 1.0))
		var alpha: float = 0.17 + 0.30 * (0.5 + 0.5 * sin(elapsed * 0.7 + float(i)))
		draw_circle(Vector2(px, py), 0.6 + float(i % 3) * 0.42, Color(0.65, 0.8, 1.0, alpha))


func _draw_hud() -> void:
	var font: Font = ThemeDB.fallback_font
	var header_size: int = 29 if size.x >= 420.0 else 23
	draw_string(font, Vector2(20, 48), "COSMIC CRYSTALS", HORIZONTAL_ALIGNMENT_LEFT, -1, header_size, Color("#DDEAFF"))
	draw_string(font, Vector2(22, 77), "A STARWEAVER'S JOURNEY  /  ENGINE SPIKE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#97A4CA"))
	draw_string(font, Vector2(22, 116), "CRYSTALS  %d / %d" % [collected, GOAL], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#39D5FF"))
	draw_string(font, Vector2(22, 144), "MOVES  %d     SCORE  %d" % [moves_left, score], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#FFCB65"))
	var progress_width: float = minf(size.x - 44.0, 360.0)
	draw_rect(Rect2(Vector2(22, 159), Vector2(progress_width, 7)), Color("#282A51"))
	draw_rect(Rect2(Vector2(22, 159), Vector2(progress_width * minf(float(collected) / float(GOAL), 1.0), 7)), Color("#39D5FF"))
	var nova: Rect2 = _nova_rect()
	var charged: bool = board != null and board.can_use_nova()
	draw_rect(nova, Color("#296D83") if phase == "nova_targeting" else
		(Color("#4A3488") if charged else Color("#202947")))
	draw_rect(nova, Color("#B9F4FF") if charged else Color("#485879"), false, 1.2)
	var fraction: float = float(board.nova_energy) / float(BoardScript.NOVA_MAX) if board != null else 0.0
	draw_rect(Rect2(nova.position + Vector2(3, 31), Vector2((nova.size.x - 6.0) * fraction, 3)), Color("#89E8FF"))
	var energy: int = board.nova_energy if board != null else 0
	draw_string(font, nova.position + Vector2(8, 23),
		"NOVA %d/%d" % [energy, BoardScript.NOVA_MAX],
		HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#FFFFFF") if charged else Color("#AAB9DA"))
	var button: Rect2 = _stress_rect()
	draw_rect(button, Color("#3A2D6A"))
	draw_rect(button, Color("#39D5FF"), false, 1.0)
	draw_string(font, button.position + Vector2(8, 24), "STRESS 30S", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#DDEAFF"))
	if stress_active:
		draw_string(font, Vector2(22, 204), "STRESS %.0f s  •  FPS %d" % [maxf(0.0, 30.0 - stress_elapsed), Engine.get_frames_per_second()],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#FFCB65"))


func _draw_crystal(center: Vector2, radius: float, kind: int, opacity: float = 1.0, power: int = 0) -> void:
	if kind < 0 or kind >= Visuals.FILL_HEX.size():
		return

	# Dark, GEM-SPECIFIC backing gives a visible edge even on bright screens.
	# Outer contour and smaller inner fill keep the edge thickness proportional
	# to the crystal, including during animated shrinking/fading.
	var base: Color = Visuals.fill_color(kind)
	var outline: Color = Visuals.outline_color(kind)
	var facet: Color = Visuals.facet_color(kind)
	var glint: Color = Visuals.glint_color(kind)
	base.a = opacity
	outline.a = opacity
	facet.a = opacity * 0.86
	glint.a = opacity * 0.95

	# Soft glow is intentionally weak, so pale opal never bleaches into amber.
	draw_circle(center, radius * 1.13, Color(base.r, base.g, base.b, opacity * 0.09))
	draw_colored_polygon(Visuals.shape_points(kind, center, radius * 1.06), outline)
	draw_colored_polygon(Visuals.shape_points(kind, center, radius * 0.91), base)

	# Small interior facets carry each kind's own hue, instead of a shared
	# white sparkle that makes bright pieces hard to identify on phones.
	var facets: PackedVector2Array = PackedVector2Array([
		center + Vector2(-0.25, -0.21) * radius,
		center + Vector2(0.00, -0.58) * radius,
		center + Vector2(0.27, -0.20) * radius,
		center + Vector2(-0.08, 0.20) * radius
	])
	draw_colored_polygon(facets, facet)

	if kind == 1:
		# Solar Amber: glowing golden nucleus inside SIX pointed solar rays.
		draw_circle(center + Vector2(0.04, 0.13) * radius, radius * 0.25, facet)
		draw_circle(center + Vector2(-0.06, -0.09) * radius, radius * 0.08, glint)
	elif kind == 5:
		# Lunar Opal: icy vertical fracture; clearly not a yellow sunburst.
		draw_line(center + Vector2(-0.17, -0.52) * radius,
			center + Vector2(0.16, 0.58) * radius, facet, maxf(1.0, radius * 0.075), true)
		draw_line(center + Vector2(0.16, 0.58) * radius,
			center + Vector2(0.36, 0.21) * radius, glint, maxf(1.0, radius * 0.045), true)
	else:
		draw_circle(center + Vector2(-0.12, -0.23) * radius, radius * 0.11, glint)
	_draw_power_icon(center, radius, power, opacity)


func _draw_power_icon(center: Vector2, radius: float, power: int, opacity: float) -> void:
	if power == BoardScript.NONE:
		return
	var ink: Color = Color(1.0, 1.0, 1.0, opacity)
	var shadow: Color = Color(0.05, 0.09, 0.24, opacity * 0.80)
	if power == BoardScript.BEAM_ROW or power == BoardScript.BEAM_COLUMN:
		var direction: Vector2 = Vector2(1, 0) if power == BoardScript.BEAM_ROW else Vector2(0, 1)
		var start: Vector2 = center - direction * radius * 0.59
		var finish: Vector2 = center + direction * radius * 0.59
		draw_line(start, finish, shadow, maxf(2.5, radius * 0.23), true)
		draw_line(start, finish, Color(1, 0.98, 0.72, opacity), maxf(1.5, radius * 0.12), true)
	elif power == BoardScript.BOMB:
		draw_arc(center, radius * 0.43, 0, TAU, 20, shadow, maxf(2.5, radius * 0.20), true)
		draw_arc(center, radius * 0.43, 0, TAU, 20, ink, maxf(1.5, radius * 0.10), true)
		draw_circle(center, radius * 0.16, Color(1.0, 0.72, 0.35, opacity))
	elif power == BoardScript.SUPERNOVA:
		draw_arc(center, radius * 0.46, 0, TAU, 24, ink, maxf(1.5, radius * 0.10), true)
		for i in range(4):
			var theta: float = TAU * float(i) / 4.0
			var ray: Vector2 = Vector2(cos(theta), sin(theta))
			draw_line(center + ray * radius * 0.20, center + ray * radius * 0.75,
				Color(1.0, 0.89, 0.36, opacity), maxf(1.5, radius * 0.12), true)


func _draw_stress_effects(rect: Rect2) -> void:
	# Synthetic visual workload to compare drawing FPS on different devices.
	# These effects do not represent finished particle art or GPU benchmarks.
	for i in range(260):
		var index: float = float(i)
		var phase_angle: float = elapsed * (0.75 + float(i % 7) * 0.10) + index * 2.39996
		var radial: float = (0.08 + 0.88 * float((i * 73) % 257) / 257.0) * rect.size.x * 0.46
		var point: Vector2 = rect.get_center() + Vector2(cos(phase_angle), sin(phase_angle)) * radial
		var color: Color = Visuals.fill_color(i % Visuals.FILL_HEX.size())
		color.a = 0.25 + 0.40 * (0.5 + 0.5 * sin(elapsed * 2.1 + index))
		draw_circle(point, 1.5 + float(i % 5), color)


func _draw_footer(rect: Rect2) -> void:
	var font: Font = ThemeDB.fallback_font
	var footer_y: float = minf(size.y - 32.0, rect.end.y + 37.0)
	if finished:
		var message: String = "CONSTELLATION RESTORED!" if won else "OUT OF MOVES"
		draw_string(font, Vector2(rect.position.x, footer_y), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#FFCB65") if won else Color("#FF8FAE"))
		if footer_y + 24 < size.y:
			draw_string(font, Vector2(rect.position.x, footer_y + 24.0), "Tap anywhere to replay", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#DDEAFF"))
	else:
		draw_string(font, Vector2(rect.position.x, footer_y), feedback, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#9DE3E2") if feedback_ok else Color("#FF8FAE"))
	if not stress_active and stress_samples > 0:
		draw_string(font, Vector2(rect.position.x, minf(size.y - 8.0, footer_y + 24.0)), stress_report, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#DDEAFF"))


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.index == 0:
			_handle_touch(event.position, event.pressed)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_touch(event.position, event.pressed)
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		if phase == "idle" or phase == "finished":
			_reset_game()


func _handle_touch(pointer: Vector2, pressed: bool) -> void:
	if phase != "idle" and phase != "nova_targeting" and phase != "finished":
		return
	if pressed:
		if _nova_rect().has_point(pointer):
			press_index = -3
			return
		if phase == "idle" and _stress_rect().has_point(pointer):
			press_index = -2
			return
		press_index = _index_at(pointer)
		press_position = pointer
		return
	if press_index == -3:
		press_index = -1
		if _nova_rect().has_point(pointer):
			if phase == "nova_targeting":
				phase = "idle"
				feedback = "Nova cancelled. Charge saved."
			elif phase == "idle" and board.can_use_nova():
				phase = "nova_targeting"
				feedback = "Tap any crystal to blast its row and column"
			queue_redraw()
		return
	if press_index == -2:
		press_index = -1
		if phase == "idle" and _stress_rect().has_point(pointer):
			_toggle_stress_test()
		return
	if phase == "finished":
		_reset_game()
		return
	var start_index: int = press_index
	press_index = -1
	if start_index < 0:
		if phase == "nova_targeting":
			phase = "idle"
			feedback = "Nova cancelled. Charge saved."
		return
	var release_index: int = _index_at(pointer)
	if phase == "nova_targeting":
		var target: int = release_index if release_index >= 0 else start_index
		_take_nova(target)
		return
	var drag: Vector2 = pointer - press_position
	var threshold: float = _board_rect().size.x / 8.0 * 0.28
	if drag.length() >= threshold:
		# Long/fast swipes still pick exactly one orthogonal neighboring cell.
		var col: int = start_index % 8
		var row: int = int(start_index / 8)
		var target: int = -1
		if absf(drag.x) > absf(drag.y):
			if drag.x > 0.0 and col < 7:
				target = start_index + 1
			elif drag.x < 0.0 and col > 0:
				target = start_index - 1
		else:
			if drag.y > 0.0 and row < 7:
				target = start_index + 8
			elif drag.y < 0.0 and row > 0:
				target = start_index - 8
		if target >= 0:
			selected = -1
			_take_turn(start_index, target)
		return
	if release_index == start_index:
		if selected >= 0 and selected != start_index and board.is_adjacent(selected, start_index):
			var first: int = selected
			selected = -1
			_take_turn(first, start_index)
		else:
			selected = start_index
			queue_redraw()


func _toggle_stress_test() -> void:
	if stress_active:
		stress_active = false
		stress_report = "Stress test stopped before 30s"
	else:
		stress_active = true
		stress_elapsed = 0.0
		stress_samples = 0
		stress_fps_total = 0.0
		stress_min_fps = 100000.0
		stress_report = "Synthetic draw test running"
	queue_redraw()


func _event_duration(kind: String) -> float:
	match kind:
		"swap", "swap_back":
			return SWAP_SECONDS
		"clear":
			return CLEAR_SECONDS
		"fall":
			return FALL_SECONDS
		"reshuffle":
			return RESHUFFLE_SECONDS
	return 0.05


func _animate_event(event: Dictionary) -> void:
	active_event = event
	event_elapsed = 0.0
	event_duration = _event_duration(str(event["type"]))
	display_cells = event["before"].duplicate()
	display_specials = event["specials_before"].duplicate()
	queue_redraw()
	while event_elapsed < event_duration:
		await get_tree().process_frame
	display_cells = event["after"].duplicate()
	display_specials = event["specials_after"].duplicate()
	active_event = {}
	queue_redraw()


func _take_turn(a: int, b: int) -> void:
	if phase != "idle":
		return
	phase = "resolving"
	selected = -1
	press_index = -1
	var outcome: Dictionary = board.play_swap(a, b)
	await _apply_outcome(outcome, true)


func _take_nova(target: int) -> void:
	if phase != "nova_targeting" or not board.can_use_nova():
		return
	phase = "resolving"
	selected = -1
	press_index = -1
	var outcome: Dictionary = board.use_nova(target)
	await _apply_outcome(outcome, false)


func _apply_outcome(outcome: Dictionary, use_move: bool) -> void:
	for event in outcome["events"]:
		await _animate_event(event)
	display_cells = board.cells.duplicate()
	display_specials = board.specials.duplicate()
	if bool(outcome["valid"]):
		if use_move:
			moves_left -= 1
		collected += int(outcome["cleared"])
		score += int(outcome["score"])
		feedback_ok = true
		if bool(outcome["used_nova"]):
			feedback = "NOVA PULSE!  +%d points (no move spent)" % int(outcome["score"])
		elif int(outcome["created"]) != BoardScript.NONE:
			feedback = "SPECIAL FORGED!  +%d points" % int(outcome["score"])
		elif int(outcome["activated"]) > 0:
			feedback = "COSMIC CHAIN!  +%d points" % int(outcome["score"])
		else:
			feedback = "CASCADE x%d  +%d points" % [int(outcome["cascades"]), int(outcome["score"])]
		if bool(outcome["reshuffled"]):
			feedback = "Stars realigned. New moves available!"
		if collected >= GOAL:
			finished = true
			won = true
		elif moves_left <= 0:
			finished = true
			won = false
	else:
		feedback_ok = false
		feedback = "That swap doesn't make a match"
	flash_time = 0.45
	phase = "finished" if finished else "idle"
	queue_redraw()
