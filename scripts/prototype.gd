extends Control
## Playable Android-first engine spike with touch/mouse input and procedural art.
## Deliberately no blockers, specials, save data, or native integrations yet.

const BoardScript = preload("res://scripts/board.gd")
const GOAL: int = 30
const STARTING_MOVES: int = 18

var crystal_colors: Array[Color] = [
	Color("#7C4DFF"), Color("#FFCB65"), Color("#39D5FF"),
	Color("#FF66BF"), Color("#44E3B2"), Color("#CDEBFF")
]
var board = null
var moves_left: int = STARTING_MOVES
var collected: int = 0
var score: int = 0
var selected: int = -1
var press_index: int = -1
var input_locked: bool = false
var finished: bool = false
var won: bool = false
var feedback: String = "Swap adjacent crystals to rekindle the stars"
var feedback_ok: bool = true
var flash_time: float = 0.0
var elapsed: float = 0.0


func _ready() -> void:
	_reset_game()


func _reset_game() -> void:
	board = BoardScript.new(20261029 + int(Time.get_ticks_msec() % 100000))
	moves_left = STARTING_MOVES
	collected = 0
	score = 0
	selected = -1
	press_index = -1
	input_locked = false
	finished = false
	won = false
	feedback = "Drag or tap two neighboring crystals"
	feedback_ok = true
	flash_time = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	flash_time = maxf(0.0, flash_time - delta)
	queue_redraw()


func _board_rect() -> Rect2:
	var side: float = minf(maxf(100.0, size.x - 32.0), maxf(100.0, size.y - 250.0))
	side = minf(side, 640.0)
	var top: float = maxf(115.0, (size.y - side) * 0.44)
	if top + side + 55.0 > size.y:
		top = maxf(92.0, size.y - side - 55.0)
	return Rect2(Vector2((size.x - side) * 0.5, top), Vector2(side, side))


func _index_at(screen_pos: Vector2) -> int:
	var rect: Rect2 = _board_rect()
	if not rect.has_point(screen_pos):
		return -1
	var cell_size: float = rect.size.x / 8.0
	var col: int = clampi(int((screen_pos.x - rect.position.x) / cell_size), 0, 7)
	var row: int = clampi(int((screen_pos.y - rect.position.y) / cell_size), 0, 7)
	return row * 8 + col


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
	for row in range(8):
		for col in range(8):
			var index: int = row * 8 + col
			var origin: Vector2 = rect.position + Vector2(col, row) * tile
			var chosen: bool = selected == index
			draw_rect(Rect2(origin + Vector2(2, 2), Vector2(tile - 4.0, tile - 4.0)),
				Color(0.13, 0.18, 0.33, 1.0) if chosen else Color(0.08, 0.11, 0.23, 1.0))
			if chosen:
				draw_rect(Rect2(origin + Vector2(2, 2), Vector2(tile - 4.0, tile - 4.0)),
					Color("#39D5FF"), false, 2.0)
			var kind: int = int(board.cells[index])
			if kind >= 0:
				_draw_crystal(origin + Vector2.ONE * tile * 0.5, tile * 0.34, kind)
	if flash_time > 0.0:
		var tint: Color = Color(0.20, 0.90, 0.86, flash_time * 0.23) if feedback_ok else Color(1, 0.25, 0.40, flash_time * 0.27)
		draw_rect(rect, tint)
	_draw_footer(rect)


func _draw_starfield() -> void:
	for i in range(85):
		var px: float = fposmod(float(i * 173 + 29), maxf(size.x, 1.0))
		var py: float = fposmod(float(i * 241 + 71), maxf(size.y, 1.0))
		var alpha: float = (0.17 + 0.30 * (0.5 + 0.5 * sin(elapsed * 0.7 + float(i)))) 
		draw_circle(Vector2(px, py), 0.6 + float(i % 3) * 0.42, Color(0.65, 0.8, 1.0, alpha))


func _draw_hud() -> void:
	var font: Font = ThemeDB.fallback_font
	var header_size: int = 29 if size.x >= 420.0 else 23
	draw_string(font, Vector2(20, 48), "COSMIC CRYSTALS", HORIZONTAL_ALIGNMENT_LEFT, -1, header_size, Color("#DDEAFF"))
	draw_string(font, Vector2(22, 77), "A STARWEAVER'S JOURNEY  /  GODOT ENGINE SPIKE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#97A4CA"))
	draw_string(font, Vector2(22, 116), "CRYSTALS  %d / %d" % [collected, GOAL], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#39D5FF"))
	draw_string(font, Vector2(22, 144), "MOVES  %d     SCORE  %d" % [moves_left, score], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#FFCB65"))
	var progress_width: float = minf(size.x - 44.0, 360.0)
	draw_rect(Rect2(Vector2(22, 159), Vector2(progress_width, 7)), Color("#282A51"))
	draw_rect(Rect2(Vector2(22, 159), Vector2(progress_width * minf(float(collected) / float(GOAL), 1.0), 7)), Color("#39D5FF"))


func _draw_crystal(center: Vector2, radius: float, kind: int) -> void:
	var base: Color = crystal_colors[kind]
	draw_circle(center, radius * 1.07, Color(base.r, base.g, base.b, 0.13))
	var sides: int = 5
	match kind:
		0: sides = 4
		1: sides = 8
		2: sides = 6
		3: sides = 5
		4: sides = 3
		5: sides = 7
	var polygon: PackedVector2Array = PackedVector2Array()
	for i in range(sides):
		var angle: float = -PI * 0.5 + TAU * float(i) / float(sides)
		var modulation: float = 0.92 if i % 2 == 0 else 1.0
		polygon.append(center + Vector2(cos(angle), sin(angle)) * radius * modulation)
	draw_colored_polygon(polygon, base)
	for j in range(sides):
		draw_line(polygon[j], polygon[(j + 1) % sides], base.lightened(0.35), 1.4, true)
	draw_circle(center - Vector2(radius * 0.20, radius * 0.23), radius * 0.19, Color(1, 1, 1, 0.66))
	draw_line(center - Vector2(radius * 0.33, radius * 0.37), center + Vector2(radius * 0.38, radius * 0.29), Color(1, 1, 1, 0.16), 1.0, true)


func _draw_footer(rect: Rect2) -> void:
	var font: Font = ThemeDB.fallback_font
	var footer_y: float = minf(size.y - 28.0, rect.end.y + 36.0)
	if finished:
		var message: String = "CONSTELLATION RESTORED!" if won else "OUT OF MOVES"
		draw_string(font, Vector2(rect.position.x, footer_y), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#FFCB65") if won else Color("#FF8FAE"))
		draw_string(font, Vector2(rect.position.x, footer_y + 25.0), "Tap anywhere to try again", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#DDEAFF"))
	else:
		draw_string(font, Vector2(rect.position.x, footer_y), feedback, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#9DE3E2") if feedback_ok else Color("#FF8FAE"))


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event.position, event.pressed)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_touch(event.position, event.pressed)
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		if not input_locked:
			_reset_game()


func _handle_touch(pointer: Vector2, pressed: bool) -> void:
	if input_locked:
		return
	if finished:
		if not pressed:
			_reset_game()
		return
	if pressed:
		press_index = _index_at(pointer)
		return
	var release_index: int = _index_at(pointer)
	var start_index: int = press_index
	press_index = -1
	if start_index < 0 or release_index < 0:
		return
	if start_index != release_index and board.is_adjacent(start_index, release_index):
		selected = -1
		_take_turn(start_index, release_index)
	elif start_index == release_index:
		if selected >= 0 and selected != release_index and board.is_adjacent(selected, release_index):
			var first: int = selected
			selected = -1
			_take_turn(first, release_index)
		else:
			selected = release_index
			queue_redraw()


func _take_turn(a: int, b: int) -> void:
	input_locked = true
	var result: Dictionary = board.play_swap(a, b)
	if bool(result["valid"]):
		moves_left -= 1
		collected += int(result["cleared"])
		score += int(result["score"])
		feedback_ok = true
		feedback = "CASCADE x%d  +%d points" % [int(result["cascades"]), int(result["score"])]
		if bool(result["reshuffled"]):
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
	flash_time = 0.55
	queue_redraw()
	await get_tree().create_timer(0.22).timeout
	input_locked = false
