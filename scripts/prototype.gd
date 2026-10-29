extends Control
## Animated Android-first match-3 prototype, with a clearly labeled synthetic
## 30-second drawing stress check. M2 adds specials and Nova Pulse.
## M2 asteroids share the immutable event stream; progression remains M3.

const BoardScript = preload("res://scripts/cosmic_board.gd")
const Visuals = preload("res://scripts/crystal_visuals.gd")
const Layout = preload("res://scripts/game_layout.gd")
const Hud = preload("res://scripts/game_hud.gd")
const Session = preload("res://scripts/game_session.gd")
const Levels = preload("res://scripts/level_catalog.gd")
const Progress = preload("res://scripts/progress_store.gd")
const CampaignView = preload("res://scripts/campaign_view.gd")
# Legacy regression fixtures opt in; the actual app opens on Home.
var practice_mode: bool = false
var save_path: String = "user://lyra-progress.json"
var session = Session.new()
var progress
var campaign_view
var screen: String = "game"
var current_level_id: int = 0
var map_selection: int = 1
var pause_after_turn: bool = false

const SWAP_SECONDS: float = 0.17
const CLEAR_SECONDS: float = 0.19
const FALL_SECONDS: float = 0.27
const RESHUFFLE_SECONDS: float = 0.28

var board:
	get: return session.board
	set(value): session.board = value
var hud = null
var overlay: String = ""
var board_style: StyleBoxFlat
var tile_style: StyleBoxFlat
var selected_style: StyleBoxFlat
var display_cells: Array[int] = []
var display_specials: Array[int] = []
var display_asteroids: Array[int] = []
var moves_left: int:
	get: return session.moves_left
	set(value): session.moves_left = value
var collected: int:
	get: return session.collected
	set(value): session.collected = value
var score: int:
	get: return session.score
	set(value): session.score = value
var selected: int = -1
var press_index: int = -1
var press_position: Vector2 = Vector2.ZERO

var phase: String = "idle"
var active_event: Dictionary = {}
var event_elapsed: float = 0.0
var event_duration: float = 0.01
var finished: bool:
	get: return session.finished
	set(value): session.finished = value
var won: bool:
	get: return session.won
	set(value): session.won = value
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
	get_tree().quit_on_go_back = false
	board_style = _panel_style(Color("#191B32"), Color("#49405F"), 20)
	tile_style = _panel_style(Color("#202138"), Color("#38344E"), 7)
	selected_style = _panel_style(Color("#44365F"), Color("#CCAAFF"), 7)
	progress = Progress.new(save_path)
	if not practice_mode:
		progress.load_progress()
	hud = Hud.new()
	hud.game = self
	add_child(hud)
	campaign_view = CampaignView.new()
	campaign_view.game = self
	add_child(campaign_view)
	_reset_game()
	if not practice_mode:
		screen = "home"
		map_selection = int(progress.data["highest_unlocked"])
	_refresh_views()


func _reset_game() -> void:
	if phase == "resolving":
		return
	if not practice_mode and current_level_id > 0:
		start_level(current_level_id)
		return
	var definition: Dictionary = Levels.practice()
	definition["seed"] += int(Time.get_ticks_msec() % 100000)
	session.load_level(definition)
	_prepare_view()


func _prepare_view() -> void:
	pause_after_turn = false
	display_cells = board.cells.duplicate()
	display_specials = board.specials.duplicate()
	display_asteroids = board.asteroids.duplicate()
	selected = -1
	press_index = -1
	phase = "idle"
	overlay = ""
	active_event = {}
	feedback = str(session.level["tutorial"]) if not progress.data["tutorials_seen"].has(current_level_id) else "Complete every goal. Each little match adds starlight."
	feedback_ok = true
	flash_time = 0.0
	_refresh_views()
	queue_redraw()


func start_level(id: int) -> bool:
	if phase == "resolving" or not progress.can_play(id):
		return false
	var definition: Dictionary = Levels.get_level(id)
	if definition.is_empty():
		return false
	current_level_id = id
	map_selection = id
	session.load_level(definition)
	screen = "game"
	_prepare_view()
	return true


func next_level() -> bool:
	if not finished or not won or current_level_id >= 5:
		return false
	return start_level(current_level_id + 1)


func go_map(confirmed: bool = false) -> bool:
	if phase == "resolving":
		return false
	if screen == "game" and not finished and not confirmed:
		open_overlay("leave")
		return false
	screen = "map"
	overlay = ""
	selected = -1
	press_index = -1
	_refresh_views()
	return true


func show_home() -> void:
	if phase == "resolving":
		return
	screen = "home"
	overlay = ""
	press_index = -1
	_refresh_views()


func request_restart() -> void:
	if phase == "resolving":
		return
	open_overlay("restart")


func reduced_motion() -> bool:
	return progress != null and progress.data["settings"]["reduced_motion"]


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if phase == "resolving":
			pause_after_turn = true
		elif screen == "map":
			show_home()
		elif screen == "game":
			if not overlay.is_empty(): close_overlay()
			elif finished: go_map(true)
			elif phase == "nova_targeting": toggle_nova()
			else: open_overlay("pause")
		elif is_inside_tree():
			get_tree().quit()


func _refresh_views() -> void:
	if hud != null:
		hud.visible = screen == "game"
		if hud.visible:
			hud.refresh(_layout())
	if campaign_view != null:
		campaign_view.visible = screen != "game"
		if campaign_view.visible:
			campaign_view.refresh(_layout())


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
	_refresh_views()
	queue_redraw()


func _safe_insets() -> Vector4:
	if OS.get_name() not in ["Android", "iOS"]:
		return Vector4.ZERO
	var pixels: Vector2 = Vector2(DisplayServer.window_get_size())
	if pixels.x <= 0 or pixels.y <= 0:
		return Vector4.ZERO
	var safe: Rect2 = Rect2(DisplayServer.get_display_safe_area())
	if safe.size.x <= 0 or safe.size.y <= 0:
		return Vector4.ZERO
	var origin: Vector2 = Vector2(DisplayServer.window_get_position())
	var ratio: Vector2 = size / pixels
	return Vector4(maxf(0, safe.position.x - origin.x) * ratio.x,
		maxf(0, safe.position.y - origin.y) * ratio.y,
		maxf(0, pixels.x - (safe.end.x - origin.x)) * ratio.x,
		maxf(0, pixels.y - (safe.end.y - origin.y)) * ratio.y)


func _layout() -> Dictionary:
	return Layout.calculate(size, _safe_insets(), not practice_mode)


func _board_rect() -> Rect2:
	return _layout()["board"]


func _nova_rect() -> Rect2:
	return _layout()["nova_button"]


func _replay_rect() -> Rect2:
	return _layout()["replay"]


func _stress_rect() -> Rect2:
	return _replay_rect() if overlay == "tools" else Rect2(-100, -100, 0, 0)


func _panel_style(bg: Color, edge: Color, radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = edge
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	return style


func open_overlay(kind: String) -> void:
	if screen != "game" or phase not in ["idle", "nova_targeting"] or finished:
		return
	overlay = kind
	selected = -1
	press_index = -1
	hud.refresh(_layout())


func close_overlay() -> void:
	overlay = ""
	press_index = -1
	hud.refresh(_layout())
	hud.buttons["pause"].grab_focus()


func toggle_nova() -> void:
	if screen != "game" or not overlay.is_empty() or finished:
		return
	if phase == "nova_targeting":
		phase = "idle"
		feedback = "Nova cancelled. Charge saved."
	elif phase == "idle" and board.can_use_nova():
		phase = "nova_targeting"
		feedback = "Choose a tile for your Nova Pulse"
	hud.refresh(_layout())
	queue_redraw()


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
	draw_rect(Rect2(Vector2.ZERO, size), Color("#090D20"))
	# Layered, restrained nebula/planet glow; no external bitmap or full-screen blur.
	for layer in range(12, 0, -1):
		var radius: float = minf(size.x * 0.95, 560.0) * float(layer) / 12.0
		draw_circle(Vector2(size.x * 0.93, size.y * 0.44), radius,
			Color(0.28, 0.20, 0.43, 0.022))
	_draw_starfield()
	if board == null or screen != "game":
		return
	var rect: Rect2 = _board_rect()
	draw_style_box(board_style, rect.grow(8.0))
	var tile: float = rect.size.x / 8.0
	for index in range(64):
		var origin: Vector2 = rect.position + Vector2(index % 8, int(index / 8)) * tile
		var selected_cell: bool = phase == "idle" and selected == index
		if not practice_mode and collected == 0 and selected == -1 and not progress.data["tutorials_seen"].has(current_level_id) and session.level.get("hint", []).has(index):
			selected_cell = true
		draw_style_box(selected_style if selected_cell else tile_style,
			Rect2(origin + Vector2(2, 2), Vector2(tile - 4.0, tile - 4.0)))

	if active_event.is_empty():
		_draw_snapshot(display_cells, rect)
	else:
		_draw_animated_event(rect)
	_draw_asteroids(rect)

	if flash_time > 0.0 and not reduced_motion():
		var tint: Color = Color(0.20, 0.90, 0.86, flash_time * 0.20) if feedback_ok else Color(1, 0.25, 0.40, flash_time * 0.23)
		draw_rect(rect, tint)
	if stress_active:
		_draw_stress_effects(rect)


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
					# Unaffected special crystals must remain visibly marked
					# while another group clears (not only on settled frames).
					_draw_crystal(_center_of(index, rect), radius,
						int(before[index]), 1.0, int(before_powers[index]))
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
				var segment_top: int = int(spawn.get("segment_top", 0))
				# Refill appears inside its region, never flying through a rock.
				if segment_top > 0:
					start_row = maxi(segment_top, start_row)
				start.y = rect.position.y + (float(start_row) + 0.5) * (rect.size.x / 8.0)
				_draw_crystal(start.lerp(_center_of(to_index, rect), eased), radius,
					int(spawn["kind"]), t if segment_top > 0 else 1.0, int(spawn.get("special", 0)))
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


func _draw_asteroids(rect: Rect2) -> void:
	var snapshot: Array = display_asteroids
	var hitting: bool = active_event.get("type", "") == "asteroid_hit"
	if not active_event.is_empty():
		snapshot = active_event.get("asteroids_before", display_asteroids)
	var t: float = clampf(event_elapsed / event_duration, 0.0, 1.0) if hitting else 0.0
	var radius: float = rect.size.x / 8.0 * 0.37
	for index in range(snapshot.size()):
		var health: int = int(snapshot[index])
		if health <= 0:
			continue
		var center: Vector2 = _center_of(index, rect)
		var opacity: float = 1.0
		var scale_factor: float = 1.0
		if hitting and active_event["indices"].has(index):
			center.x += sin(t * TAU * 2.0) * radius * 0.09 * (1.0 - t)
			if active_event["destroyed"].has(index):
				opacity = 1.0 - t
				scale_factor = 1.0 - t * 0.45
			elif t >= 0.5:
				health = int(active_event["asteroids_after"][index])
			draw_arc(center, radius * (1.0 + t * 0.5), 0.0, TAU, 20,
				Color(1.0, 0.65, 0.31, 1.0 - t), 2.0, true)
			for shard in range(5):
				var direction: Vector2 = Vector2.from_angle(TAU * float(shard) / 5.0)
				draw_circle(center + direction * radius * (0.7 + t * 1.0),
					radius * 0.10 * (1.0 - t), Color(0.88, 0.66, 0.43, 1.0 - t))
		_draw_asteroid(center, radius * scale_factor, health, opacity)


func _draw_asteroid(center: Vector2, radius: float, health: int, opacity: float) -> void:
	# Original procedural rock: irregular, desaturated bronze/slate with craters.
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(9):
		var angle: float = -PI * 0.5 + TAU * float(i) / 9.0
		var edge: float = 1.0 if i % 3 == 0 else 0.86
		points.append(center + Vector2.from_angle(angle) * radius * edge)
	draw_colored_polygon(points, Color(0.54, 0.45, 0.38, opacity))
	var border: PackedVector2Array = points.duplicate()
	border.append(points[0])
	draw_polyline(border, Color(0.78, 0.65, 0.49, opacity), maxf(1.5, radius * 0.06), true)
	draw_circle(center + Vector2(-0.29, -0.23) * radius, radius * 0.22,
		Color(0.25, 0.23, 0.28, opacity))
	draw_circle(center + Vector2(0.32, 0.24) * radius, radius * 0.14,
		Color(0.31, 0.27, 0.30, opacity))
	if health == 1:
		var crack: PackedVector2Array = PackedVector2Array([
			center + Vector2(0.1, -0.78) * radius, center + Vector2(-0.16, -0.1) * radius,
			center + Vector2(0.18, 0.18) * radius, center + Vector2(-0.13, 0.79) * radius])
		draw_polyline(crack, Color(0.10, 0.09, 0.17, opacity), maxf(2.0, radius * 0.13), true)
		draw_polyline(crack, Color(1.0, 0.64, 0.30, opacity), maxf(1.0, radius * 0.045), true)
	# One/two bright durability pips remain legible at small phone sizes.
	for pip in range(health):
		draw_circle(center + Vector2((float(pip) - float(health - 1) * 0.5) * 0.30, 0.52) * radius,
			radius * 0.075, Color(1.0, 0.87, 0.62, opacity))


func _asteroids_remaining() -> int:
	var count: int = 0
	for durability in board.asteroids:
		if durability > 0:
			count += 1
	return count


func _draw_starfield() -> void:
	for i in range(85):
		var px: float = fposmod(float(i * 173 + 29), maxf(size.x, 1.0))
		var py: float = fposmod(float(i * 241 + 71), maxf(size.y, 1.0))
		var alpha: float = 0.17 + 0.30 * (0.5 + 0.5 * sin((0.0 if reduced_motion() else elapsed) * 0.7 + float(i)))
		draw_circle(Vector2(px, py), 0.6 + float(i % 3) * 0.42, Color(0.65, 0.8, 1.0, alpha))


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
	var contour: PackedVector2Array = Visuals.shape_points(kind, center, radius * 0.91)
	draw_colored_polygon(contour, base)
	for i in range(contour.size()):
		var light: Color = Color(base.lerp(facet, 0.55) if i % 3 == 0 else base.darkened(0.16))
		light.a = opacity * 0.68
		draw_colored_polygon(PackedVector2Array([center + Vector2(-0.08, -0.08) * radius,
			contour[i], contour[(i + 1) % contour.size()]]), light)

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
		# A persistent cyan halo makes the newly forged Beam recognizable
		# against every gem color, not just during the short creation pulse.
		draw_arc(center, radius * 0.78, 0.0, TAU, 24,
			Color(0.38, 0.96, 1.0, opacity * 0.98),
			maxf(1.7, radius * 0.11), true)
		var start: Vector2 = center - direction * radius * 0.64
		var finish: Vector2 = center + direction * radius * 0.64
		draw_line(start, finish, shadow, maxf(3.0, radius * 0.29), true)
		draw_line(start, finish, Color(1.0, 0.99, 0.75, opacity),
			maxf(2.0, radius * 0.17), true)
		draw_circle(center, radius * 0.11, Color(1, 1, 1, opacity))
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
		var phase_angle: float = (0.0 if reduced_motion() else elapsed) * (0.75 + float(i % 7) * 0.10) + index * 2.39996
		var radial: float = (0.08 + 0.88 * float((i * 73) % 257) / 257.0) * rect.size.x * 0.46
		var point: Vector2 = rect.get_center() + Vector2(cos(phase_angle), sin(phase_angle)) * radial
		var color: Color = Visuals.fill_color(i % Visuals.FILL_HEX.size())
		color.a = 0.25 + 0.40 * (0.5 + 0.5 * sin(elapsed * 2.1 + index))
		draw_circle(point, 1.5 + float(i % 5), color)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.index == 0:
			_handle_touch(event.position, event.pressed)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_touch(event.position, event.pressed)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if screen == "map":
				show_home()
			elif screen == "home":
				return
			elif not overlay.is_empty():
				close_overlay()
			elif phase == "nova_targeting":
				toggle_nova()
			else:
				open_overlay("pause")
		elif event.keycode == KEY_F9:
			open_overlay("tools")
		elif event.keycode == KEY_R and (phase == "idle" or phase == "finished") and overlay.is_empty() and screen == "game":
			_reset_game()


func _handle_touch(pointer: Vector2, pressed: bool) -> void:
	if screen != "game" or not overlay.is_empty():
		return
	if phase != "idle" and phase != "nova_targeting" and phase != "finished":
		return
	if phase == "finished":
		if not practice_mode:
			return  # Campaign results are owned exclusively by their GUI buttons.
		if pressed:
			# Arm replay only if the initial touch is on the explicit button.
			press_index = -4 if _replay_rect().has_point(pointer) else -1
		else:
			var should_replay: bool = press_index == -4 and _replay_rect().has_point(pointer)
			press_index = -1
			if should_replay:
				_reset_game()
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
			toggle_nova()
		return
	if press_index == -2:
		press_index = -1
		if phase == "idle" and _stress_rect().has_point(pointer):
			_toggle_stress_test()
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
	if board.is_blocked(start_index):
		selected = -1
		feedback = "Asteroids stay put. Match beside or blast."
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
	if reduced_motion():
		return 0.01
	match kind:
		"swap", "swap_back":
			return SWAP_SECONDS
		"clear", "asteroid_hit":
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
	display_asteroids = event["asteroids_before"].duplicate()
	queue_redraw()
	while event_elapsed < event_duration:
		await get_tree().process_frame
	display_cells = event["after"].duplicate()
	display_specials = event["specials_after"].duplicate()
	display_asteroids = event["asteroids_after"].duplicate()
	active_event = {}
	queue_redraw()


func _take_turn(a: int, b: int) -> void:
	if phase != "idle":
		return
	phase = "resolving"
	selected = -1
	press_index = -1
	var outcome: Dictionary = session.begin_swap(a, b)
	await _apply_outcome(outcome, true)


func _take_nova(target: int) -> void:
	if phase != "nova_targeting" or not board.can_use_nova():
		return
	phase = "resolving"
	selected = -1
	press_index = -1
	var outcome: Dictionary = session.begin_nova(target)
	await _apply_outcome(outcome, false)


func _apply_outcome(outcome: Dictionary, _use_move: bool) -> void:
	if outcome.is_empty():
		phase = "idle"
		return
	for event in outcome["events"]:
		await _animate_event(event)
	display_cells = board.cells.duplicate()
	display_specials = board.specials.duplicate()
	display_asteroids = board.asteroids.duplicate()
	if bool(outcome["valid"]):
		session.commit_outcome(outcome)
		if current_level_id > 0:
			progress.mark_tutorial(current_level_id)
		feedback_ok = true
		if bool(outcome["used_nova"]):
			feedback = "NOVA PULSE!  +%d points (no move spent)" % int(outcome["score"])
		elif int(outcome["created"]) != BoardScript.NONE:
			var created_kind: int = int(outcome["created"])
			var power_name: String = "SPECIAL"
			if created_kind == BoardScript.BEAM_ROW or created_kind == BoardScript.BEAM_COLUMN:
				power_name = "STAR BEAM"
			elif created_kind == BoardScript.BOMB:
				power_name = "COSMIC BOMB"
			elif created_kind == BoardScript.SUPERNOVA:
				power_name = "SUPERNOVA"
			feedback = "%s FORGED!  +%d points" % [power_name, int(outcome["score"])]
		elif int(outcome["activated"]) > 0:
			feedback = "COSMIC CHAIN!  +%d points" % int(outcome["score"])
		else:
			feedback = "CASCADE x%d  +%d points" % [int(outcome["cascades"]), int(outcome["score"])]
		if bool(outcome["reshuffled"]):
			feedback = "Stars realigned. New moves available!"
		if finished and won and current_level_id > 0:
			progress.record_victory(session)
	else:
		session.commit_outcome(outcome)
		feedback_ok = false
		feedback = "That swap doesn't make a match"
	flash_time = 0.45
	phase = "finished" if finished else "idle"
	if pause_after_turn:
		pause_after_turn = false
		if not finished:
			open_overlay("pause")
	queue_redraw()
