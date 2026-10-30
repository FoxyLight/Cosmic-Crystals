extends Control
## Home and five-node constellation map. Presentation delegates to the controller.
const Levels = preload("res://scripts/level_catalog.gd")
const STAR = preload("res://assets/rating-star.svg")
const BRAND = preload("res://assets/brand-star.svg")
const CRYSTAL = preload("res://assets/crystal-goal.svg")
var game
var labels: Dictionary = {}
var buttons: Dictionary = {}
var icons: Dictionary = {}
var groups: Dictionary = {}
var lines: Array[Vector2] = []
var preview: Panel
var motion: CheckButton
var node_styles: Dictionary = {}
var cached_states: Dictionary = {}
var last_screen: String = ""


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label("brand", "COSMIC CRYSTALS", 18, true, "both")
	_label("subtitle", "A STARWEAVER'S JOURNEY", 9, false, "both")
	_icon("brand", BRAND, "both")
	_icon("hero", CRYSTAL, "home")
	_label("home_title", "Bring the galaxy\nback to light.", 34, true, "home")
	_label("home_body", "Five little stars.\nA constellation waiting for your light.", 15, false, "home")
	_label("home_progress", "", 12, false, "home")
	_button("journey", "Begin your journey", func(): game.go_map(true), "home")
	_button("settings", "Settings", func(): game.open_settings(), "home")
	_label("map_title", "The Lyra constellation", 27, true, "map")
	_label("map_progress", "", 12, false, "map")
	_button("home", "Home", func(): game.show_home(), "map")
	preview = Panel.new()
	preview.add_theme_stylebox_override("panel", game.hud._style(Color("#201D36"), Color("#49405F")))
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(preview)
	groups[preview] = "map"
	_label("level_name", "", 21, true, "map")
	_label("level_goals", "", 12, false, "map")
	_label("level_tip", "", 12, false, "map")
	labels["level_goals"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	labels["level_tip"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_button("play", "Play level", func(): game.start_level(game.map_selection), "map")
	_label("notice", "", 11, false, "both")
	labels["notice"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	labels["notice"].add_theme_color_override("font_color", Color("#FFCF79"))
	motion = CheckButton.new()
	motion.text = "Reduced motion"
	motion.add_theme_font_override("font", game.hud.body_face)
	motion.add_theme_font_size_override("font_size", 13)
	motion.add_theme_color_override("font_color", Color("#C0BBD4"))
	motion.toggled.connect(func(value: bool): game.set_preference("reduced_motion", value))
	add_child(motion)
	groups[motion] = "home"
	for key in ["home_title", "home_body", "home_progress"]:
		labels[key].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node_styles["next"] = game.hud._style(Color("#675092"), Color("#D9BAFF"), 28)
	node_styles["selected"] = game.hud._style(Color("#584471"), Color("#E6D2FF"), 28)
	node_styles["done"] = game.hud._style(Color("#393B52"), Color("#B29A72"), 28)
	node_styles["open"] = game.hud._style(Color("#2B2843"), Color("#88749E"), 28)
	node_styles["locked"] = game.hud._style(Color("#181A30"), Color("#38354A"), 28)
	for i in range(1, 6):
		var id: int = i
		_button("node%d" % i, str(i), func(): game.map_selection = id; refresh(game._layout()), "map")
		buttons["node%d" % i].add_theme_font_size_override("font_size", 23)
		buttons["node%d" % i].add_theme_stylebox_override("disabled", node_styles["locked"])
		_label("state%d" % i, "LOCKED", 9, false, "map")
		labels["state%d" % i].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		for star in range(3):
			_icon("star%d_%d" % [i, star], STAR, "map")


func _label(key: String, text: String, font_size: int, title: bool, group: String) -> void:
	var node: Label = Label.new()
	node.text = text
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	node.add_theme_font_override("font", game.hud.title_face if title else game.hud.body_face)
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", Color("#F0EFFF") if title else Color("#B9B8D1"))
	add_child(node)
	labels[key] = node
	groups[node] = group


func _button(key: String, text: String, action: Callable, group: String) -> void:
	var node: Button = Button.new()
	node.text = text
	node.add_theme_font_override("font", game.hud.title_face)
	node.add_theme_font_size_override("font_size", 16)
	node.add_theme_color_override("font_color", Color("#F0EFFF"))
	node.add_theme_stylebox_override("normal", game.hud._style(Color("#8762C3"), Color("#BC99ED"), 12))
	node.add_theme_stylebox_override("hover", game.hud._style(Color("#9C78D6"), Color("#DDC4FF"), 12))
	node.add_theme_stylebox_override("pressed", game.hud._style(Color("#523971"), Color("#DDC4FF"), 12))
	node.add_theme_stylebox_override("focus", game.hud._style(Color.TRANSPARENT, Color("#CAF7FF"), 12))
	node.pressed.connect(func(): game.ui_cue(); action.call())
	add_child(node)
	buttons[key] = node
	groups[node] = group


func _icon(key: String, texture: Texture2D, group: String) -> void:
	var node: TextureRect = TextureRect.new()
	node.texture = texture
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(node)
	icons[key] = node
	groups[node] = group


func _rect(node: Control, rect: Rect2) -> void:
	node.position = rect.position
	node.size = rect.size


func refresh(layout: Dictionary) -> void:
	if game.progress == null:
		return
	for node in groups:
		node.visible = groups[node] == "both" or groups[node] == game.screen
	var area: Rect2 = layout["safe"]
	var large: bool = game.progress.data["settings"].get("large_text", false)
	labels["home_body"].add_theme_font_size_override("font_size", 19 if large else 15)
	labels["home_progress"].add_theme_font_size_override("font_size", 15 if large else 12)
	labels["map_progress"].add_theme_font_size_override("font_size", 14 if large else 12)
	var width: float = minf(480, area.size.x - 24)
	var x: float = area.get_center().x - width * 0.5
	var top: float = area.position.y + 8
	_rect(icons["brand"], Rect2(x, top, 32, 44))
	_rect(labels["brand"], Rect2(x + 42, top + 4, width - 120, 24))
	_rect(labels["subtitle"], Rect2(x + 42, top + 29, width - 120, 16))
	labels["notice"].text = game.progress.notice
	labels["notice"].visible = game.screen == "home" and not game.progress.notice.is_empty()
	_rect(labels["notice"], Rect2(x, area.end.y - 92, width, 36))
	if game.screen == "home":
		var middle: float = area.get_center().y
		var side: float = 72.0 if area.size.y < 650 else 92.0
		_rect(icons["hero"], Rect2(area.get_center().x - side * 0.5, middle - 196, side, side))
		_rect(labels["home_title"], Rect2(x, middle - 102, width, 92))
		_rect(labels["home_body"], Rect2(x, middle, width, 60))
		_rect(buttons["journey"], Rect2(x + 16, middle + 82, width - 32, 52))
		_rect(labels["home_progress"], Rect2(x, middle + 150, width, 24))
		labels["home_progress"].text = "%d / 15 stars · %d / 5 restored" % [game.progress.total_stars(), game.progress.data["completed"].count(true)]
		buttons["journey"].text = "Revisit the stars" if game.progress.all_completed() else ("Continue your journey" if game.progress.data["highest_unlocked"] > 1 else "Begin your journey")
		_rect(motion, Rect2(x, area.end.y - 56, width - 110, 48))
		_rect(buttons["settings"], Rect2(x + width - 104, area.end.y - 56, 104, 48))
		motion.set_pressed_no_signal(game.reduced_motion())
	else:
		_rect(buttons["home"], Rect2(x + width - 76, top, 76, 48))
		_rect(labels["map_title"], Rect2(x, top + 64, width, 36))
		_rect(labels["map_progress"], Rect2(x, top + 103, width, 22))
		labels["map_progress"].text = "Lyra restored · %d / 15 stars" % game.progress.total_stars() if game.progress.all_completed() else ("%d / 15 stars · Choose a star" if large else "%d / 15 stars · Choose a star to awaken") % game.progress.total_stars()
		var play: Rect2 = Rect2(x, area.end.y - 62, width, 50)
		var enlarged: bool = game.progress.data["settings"].get("large_text", false)
		var preview_rect: Rect2 = Rect2(x, play.position.y - (188 if enlarged else 156), width, 176 if enlarged else 144)
		_rect(preview, preview_rect)
		_rect(buttons["play"], play)
		_rect(labels["level_name"], Rect2(preview_rect.position + Vector2(14, 8), Vector2(width - 28, 30)))
		_rect(labels["level_goals"], Rect2(preview_rect.position + Vector2(14, 42), Vector2(width - 28, 38 if enlarged else 26)))
		_rect(labels["level_tip"], Rect2(preview_rect.position + Vector2(14, 86 if enlarged else 75), Vector2(width - 28, 82 if enlarged else 62)))
		var level: Dictionary = Levels.get_level(game.map_selection)
		labels["level_name"].text = "%d · %s" % [level["id"], level["name"]]
		var targets: PackedStringArray = []
		for goal in level["goals"]:
			match goal["type"]:
				"collect": targets.append("%d crystals" % goal["target"])
				"asteroids": targets.append("%d rocks" % goal["target"])
				"beams": targets.append("forge a Beam")
				"powers": targets.append("use %d powers" % goal["target"])
				"nova": targets.append("use Nova")
		labels["level_goals"].text = "%d moves · %s" % [level["moves"], ", ".join(targets)]
		labels["level_tip"].text = ("Best %d starlight / %d stars.\n2 stars: %d / 3 stars: %d" % [game.progress.data["best_scores"][game.map_selection - 1], game.progress.data["best_stars"][game.map_selection - 1], level["star_scores"][1], level["star_scores"][2]]) if game.progress.data["tutorials_seen"].has(game.map_selection) else level["tutorial"]
		if not game.progress.notice.is_empty():
			labels["level_tip"].text = game.progress.notice
		buttons["play"].text = "Replay level %d" % game.map_selection if game.progress.data["completed"][game.map_selection - 1] else "Play level %d" % game.map_selection
		buttons["play"].disabled = not game.progress.can_play(game.map_selection)
		var node_top: float = top + 140
		var node_height: float = preview_rect.position.y - 12 - node_top
		lines.clear()
		var heights: Array[float] = [0.65, 0.25, 0.75, 0.10, 0.50]
		for i in range(1, 6):
			var center: Vector2 = Vector2(x + width * (0.10 + 0.20 * (i - 1)), node_top + 28 + heights[i - 1] * maxf(0, node_height - 90))
			lines.append(center)
			var button: Button = buttons["node%d" % i]
			_rect(button, Rect2(center - Vector2(26, 26), Vector2(52, 52)))
			var unlocked: bool = game.progress.can_play(i)
			var done: bool = game.progress.data["completed"][i - 1]
			var state: String = "locked" if not unlocked else ("selected" if i == game.map_selection else ("done" if done else ("next" if i == game.progress.data["highest_unlocked"] else "open")))
			if cached_states.get(i, "") != state:
				button.add_theme_stylebox_override("normal", node_styles[state])
				cached_states[i] = state
			button.disabled = not unlocked
			button.tooltip_text = str(i) + ": " + Levels.get_level(i)["name"] + (" (complete the previous level)" if not unlocked else "")
			_rect(labels["state%d" % i], Rect2(center + Vector2(-34, 40), Vector2(68, 16)))
			labels["state%d" % i].text = "LOCKED" if not unlocked else ("DONE" if done else "NEXT")
			for star in range(3):
				var icon: TextureRect = icons["star%d_%d" % [i, star]]
				_rect(icon, Rect2(center + Vector2(-16 + star * 12, 28), Vector2(10, 10)))
				icon.modulate = Color.WHITE if star < game.progress.data["best_stars"][i - 1] else Color(0.26, 0.26, 0.32)
		_rect(labels["notice"], Rect2(x, play.position.y - 38, width, 36))
	if last_screen != game.screen:
		buttons["journey" if game.screen == "home" else "play"].grab_focus()
	labels["level_tip"].add_theme_font_size_override("font_size", 16 if large else 12)
	labels["level_goals"].add_theme_font_size_override("font_size", 15 if large else 12)
	last_screen = game.screen
	queue_redraw()


func _draw() -> void:
	if game != null and game.screen == "map":
		for i in range(lines.size() - 1):
			var color: Color = Color("#89739F") if game.progress.data["completed"][i] else Color("#393650")
			draw_line(lines[i], lines[i + 1], color, 1.5, true)
