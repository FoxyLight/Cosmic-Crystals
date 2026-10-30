extends Control
## Native Labels/Buttons, styled like the earlier web/Android visual direction.
## This view reads the controller; it never scores, resolves or mutates a board.
const TITLE_FONT = preload("res://assets/fonts/Outfit.ttf")
const BODY_FONT = preload("res://assets/fonts/DM-Sans.ttf")
const STAR_ICON = preload("res://assets/brand-star.svg")
const PAUSE_ICON = preload("res://assets/pause.svg")
const RETRY_ICON = preload("res://assets/retry-gem.svg")
const RATING_STAR = preload("res://assets/rating-star.svg")
const TEXT = Color("#F0EFFF")
const MUTED = Color("#B4B5D0")
const VIOLET = Color("#C4A3FF")
const GOLD = Color("#FFCF79")
var game
var labels: Dictionary = {}
var panels: Dictionary = {}
var buttons: Dictionary = {}
var tracks: Dictionary = {}
var fills: Dictionary = {}
var icons: Dictionary = {}
var shade: ColorRect
var last_modal: String = ""
var title_face: FontVariation
var body_face: FontVariation


func _ready() -> void:
	title_face = FontVariation.new()
	title_face.base_font = TITLE_FONT
	title_face.variation_opentype = {"weight": 550.0}
	body_face = FontVariation.new()
	body_face.base_font = BODY_FONT
	body_face.variation_opentype = {"weight": 450.0}
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel("goals")
	_panel("score")
	_panel("moves")
	_panel("nova", Color("#282142"), Color("#655083"))
	_label("brand", "COSMIC CRYSTALS", 16, TEXT, true)
	_icon("brand", STAR_ICON)
	_label("brand_sub", "A STARWEAVER'S JOURNEY", 9, MUTED)
	_label("eyebrow", "A LITTLE MATCH. A LITTLE MAGIC.", 10, VIOLET)
	_label("title", "Asteroid field", 28, TEXT, true)
	_label("crystal_name", "CRYSTALS", 10, MUTED)
	_label("crystal_count", "0 / 30", 22, TEXT, true)
	_label("rock_name", "ASTEROIDS", 10, MUTED)
	_label("rock_count", "6 left", 22, TEXT, true)
	_label("third_name", "USE NOVA", 10, MUTED)
	_label("third_count", "0 / 1", 22, TEXT, true)
	_icon("third", STAR_ICON)
	for group in ["crystal", "rock"]:
		var icon: TextureRect = TextureRect.new()
		icon.texture = preload("res://assets/crystal-goal.svg") if group == "crystal" else preload("res://assets/asteroid-goal.svg")
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icons[group] = icon
		add_child(icon)
	_label("score_name", "STARLIGHT SCORE", 10, MUTED)
	_label("score_count", "0", 27, TEXT, true)
	_label("moves_name", "MOVES LEFT", 10, MUTED)
	_label("moves_count", "18", 29, TEXT, true)
	_label("nova_name", "NOVA PULSE", 12, VIOLET, true)
	_icon("nova", STAR_ICON)
	_label("nova_charge", "GATHERING ENERGY · 0%", 9, MUTED)
	_label("caption", "Match beside asteroids to crack them", 11, MUTED)
	_label("aside", "Restore a little starlight.\n\nMatch three crystals. Crack the asteroids.\nUse your Nova when the stars align.", 15, MUTED)
	labels["aside"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_track("crystals", VIOLET)
	_track("rocks", GOLD)
	_track("nova", VIOLET)
	_track("third", VIOLET)
	_button("help", "?", func(): game.open_overlay("help"), true)
	_button("pause", "", func(): game.open_overlay("pause"), true)
	buttons["pause"].icon = PAUSE_ICON
	buttons["pause"].expand_icon = true
	buttons["pause"].icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	buttons["pause"].add_theme_constant_override("icon_max_width", 22)
	_button("nova", "Gathering…", func(): game.toggle_nova())
	shade = ColorRect.new()
	shade.color = Color(0.025, 0.03, 0.09, 0.86)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	_panel("dialog", Color("#211C3B"), Color("#70558F"))
	_icon("modal", STAR_ICON)
	for i in range(3):
		_icon("rating%d" % i, RATING_STAR)
	_label("modal_eyebrow", "A LITTLE STARLIGHT RESTORED", 10, VIOLET)
	_label("modal_title", "Beautifully done.", 32, TEXT, true)
	_label("modal_body", "", 15, MUTED)
	labels["modal_body"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label("modal_score", "", 26, GOLD, true)
	_button("replay", "Play again", func(): game._reset_game())
	_button("next", "Next level", func(): game.next_level())
	_button("map", "Return to map", func(): game.go_map())
	_button("restart", "Restart level", func(): game.request_restart())
	_button("confirm_leave", "Return to map", func(): game.go_map(true))
	_button("confirm_restart", "Restart level", func(): game._reset_game())
	_button("resume", "Keep playing", func(): game.close_overlay())
	_button("settings", "Sound & comfort", func(): game.open_settings())
	_button("guide", "How to play", func(): game.open_overlay("help"))
	_button("back", "Back to game", func(): game.close_overlay())
	_button("stress", "Run effects check", func(): game._toggle_stress_test(); game.close_overlay())
	for key in ["modal_eyebrow", "modal_title", "modal_body", "modal_score"]:
		labels[key].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		labels[key].vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _style(bg: Color, line: Color, radius: int = 16) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = line
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	return style


func _icon(key: String, texture: Texture2D) -> void:
	var icon: TextureRect = TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icons[key] = icon
	add_child(icon)


func _panel(key: String, bg: Color = Color("#1B1D35"), line: Color = Color("#39334F")) -> void:
	var panel: Panel = Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(bg, line))
	panels[key] = panel
	add_child(panel)


func _label(key: String, text: String, font_size: int, color: Color, heading: bool = false) -> void:
	var label: Label = Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", title_face if heading else body_face)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	labels[key] = label
	add_child(label)


func _button(key: String, text: String, action: Callable, quiet: bool = false) -> void:
	var button: Button = Button.new()
	button.text = text
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_override("font", title_face)
	button.tooltip_text = "How to play" if key == "help" else ("Pause" if key == "pause" else text)
	button.add_theme_font_size_override("font_size", 22 if quiet else 15)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_disabled_color", Color("#B0A3C5"))
	button.add_theme_stylebox_override("normal", _style(Color("#171A30") if quiet else Color("#8762C3"), Color("#3F3659") if quiet else Color("#BC99ED"), 12))
	button.add_theme_stylebox_override("hover", _style(Color("#302644") if quiet else Color("#9C78D6"), VIOLET, 12))
	button.add_theme_stylebox_override("pressed", _style(Color("#4D376D"), VIOLET, 12))
	button.add_theme_stylebox_override("disabled", _style(Color("#48365F"), Color("#625079"), 12))
	var focus: StyleBoxFlat = _style(Color.TRANSPARENT, Color("#CAF7FF"), 12)
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	button.pressed.connect(func(): game.ui_cue(key.begins_with("confirm")); action.call())
	buttons[key] = button
	add_child(button)


func _track(key: String, color: Color) -> void:
	var track: Panel = Panel.new()
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_theme_stylebox_override("panel", _style(Color("#353047"), Color.TRANSPARENT, 3))
	add_child(track)
	tracks[key] = track
	var fill: Panel = Panel.new()
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.add_theme_stylebox_override("panel", _style(color, Color.TRANSPARENT, 3))
	add_child(fill)
	fills[key] = fill


func _rect(control: Control, rect: Rect2) -> void:
	control.position = rect.position
	control.size = rect.size


func _place(key: String, rect: Rect2) -> void:
	_rect(labels[key], rect)


func _meter(key: String, rect: Rect2, fraction: float) -> void:
	_rect(tracks[key], rect)
	_rect(fills[key], Rect2(rect.position, Vector2(rect.size.x * clampf(fraction, 0, 1), rect.size.y)))
	fills[key].visible = fraction > 0


func refresh(layout: Dictionary) -> void:
	if game == null or game.board == null:
		return
	var large: bool = game.progress.data["settings"].get("large_text", false)
	labels["aside"].add_theme_font_size_override("font_size", 22 if large else 18)
	var modal: String = "result" if game.finished else game.overlay
	var blocked: bool = not modal.is_empty()
	var idle: bool = game.phase == "idle" or game.phase == "nova_targeting"
	for key in ["goals", "score", "moves", "nova"]:
		_rect(panels[key], layout[key])
	var header: Rect2 = layout["header"]
	_rect(icons["brand"], Rect2(header.position + Vector2(0, 3), Vector2(34, 44)))
	_place("brand", Rect2(header.position + Vector2(40, 7), Vector2(header.size.x - 156, 22)))
	_place("brand_sub", Rect2(header.position + Vector2(40, 30), Vector2(header.size.x - 156, 15)))
	labels["brand"].add_theme_font_size_override("font_size", 14 if header.size.x < 340 else 16)
	_rect(buttons["help"], layout["help_button"])
	_rect(buttons["pause"], layout["pause_button"])
	buttons["help"].disabled = blocked or not idle
	buttons["pause"].disabled = blocked or not idle
	var heading: Rect2 = layout["heading"]
	_place("eyebrow", Rect2(heading.position, Vector2(heading.size.x, 16)))
	_place("title", Rect2(heading.position + Vector2(0, 15), Vector2(heading.size.x, 34)))
	labels["title"].text = game.session.level["name"]
	labels["title"].add_theme_font_size_override("font_size", 24 if not game.practice_mode else 28)
	labels["eyebrow"].text = "LYRA / LEVEL %02d OF 05" % game.current_level_id if not game.practice_mode else "A LITTLE MATCH. A LITTLE MAGIC."
	var goals: Rect2 = layout["goals"]
	var objectives: Array = game.session.level["goals"]
	var count: int = objectives.size()
	var width: float = goals.size.x / count
	for i in range(3):
		var group: String = ["crystal", "rock", "third"][i]
		var track_key: String = ["crystals", "rocks", "third"][i]
		var active: bool = i < count
		for node in [icons[group], labels[group + "_name"], labels[group + "_count"], tracks[track_key], fills[track_key]]:
			node.visible = active
		if not active:
			continue
		var goal: Dictionary = objectives[i]
		var x: float = goals.position.x + width * i
		var icon_width: float = 22 if count == 3 else 30
		var indent: float = 36 if count == 3 else 46
		_rect(icons[group], Rect2(x + 8, goals.position.y + 10, icon_width, 32))
		icons[group].texture = preload("res://assets/asteroid-goal.svg") if goal["type"] == "asteroids" else (preload("res://assets/crystal-goal.svg") if goal["type"] == "collect" else STAR_ICON)
		_place(group + "_name", Rect2(x + indent, goals.position.y + 7, width - indent - 6, 16))
		_place(group + "_count", Rect2(x + indent, goals.position.y + 22, width - indent - 6, 28))
		labels[group + "_name"].text = game.session.goal_label(goal)
		labels[group + "_name"].add_theme_font_size_override("font_size", 9 if count == 3 else 10)
		labels[group + "_count"].add_theme_font_size_override("font_size", 19 if count == 3 else 22)
		var value: int = game.session.goal_progress(goal)
		var target: int = int(goal["target"])
		labels[group + "_count"].text = "%d/%d" % [mini(value, target), target] if count == 3 else "%d / %d" % [mini(value, target), target]
		if goal["type"] == "asteroids":
			labels[group + "_count"].text = "Clear" if value >= target else "%d left" % game._asteroids_remaining()
		labels[group + "_count"].modulate = Color("#AEF0CD") if value >= target else Color.WHITE
		_meter(track_key, Rect2(x + indent, goals.end.y - 6, width - indent - 10, 3), float(value) / target)
	for group in ["score", "moves"]:
		var card: Rect2 = layout[group]
		_place(group + "_name", Rect2(card.position + Vector2(12, 6), Vector2(card.size.x - 24, 16)))
		_place(group + "_count", Rect2(card.position + Vector2(12, 20), Vector2(card.size.x - 24, card.size.y - 20)))
	labels["score_count"].text = String.num_int64(game.score).pad_zeros(1)
	labels["moves_count"].text = str(game.moves_left)
	labels["moves_count"].modulate = Color("#FF9AB4") if game.moves_left <= 3 else Color.WHITE
	var nova: Rect2 = layout["nova"]
	var energy: int = game.board.nova_energy
	var charged: bool = game.board.can_use_nova()
	var nova_enabled: bool = game.board.nova_enabled
	_rect(icons["nova"], Rect2(nova.position + Vector2(12, 12), Vector2(12, 12)))
	_place("nova_name", Rect2(nova.position + Vector2(30, 8), Vector2(nova.size.x * 0.5 - 34, 20)))
	_place("nova_charge", Rect2(nova.position + Vector2(12, 30), Vector2(nova.size.x * 0.5 - 18, 16)))
	labels["nova_charge"].text = ("READY TO SHINE" if charged else "CHARGING · %d%%" % (energy * 100 / game.BoardScript.NOVA_MAX)) if nova_enabled else "AWAKENS IN LEVEL 5"
	_meter("nova", Rect2(nova.position + Vector2(12, nova.size.y - 12), Vector2(nova.size.x * 0.5 - 18, 4)), float(energy) / game.BoardScript.NOVA_MAX if nova_enabled else 0.0)
	_rect(buttons["nova"], layout["nova_button"])
	buttons["nova"].text = "Cancel Nova" if game.phase == "nova_targeting" else ("Unleash Nova" if charged else "Gathering…")
	buttons["nova"].disabled = blocked or not idle or not charged
	if not nova_enabled:
		buttons["nova"].text = "Nova rests"
	_place("caption", layout["caption"])
	labels["caption"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if not game.practice_mode else TextServer.AUTOWRAP_OFF
	labels["caption"].add_theme_font_size_override("font_size", (20 if large else 16) if not game.practice_mode else (17 if large else 14))
	labels["caption"].text = "Choose a tile for your Nova Pulse" if game.phase == "nova_targeting" else game.feedback
	labels["caption"].modulate = Color.WHITE if game.feedback_ok else Color("#FF9AB4")
	_place("aside", layout["aside"])
	labels["aside"].visible = layout["aside"].size.y > 0
	_refresh_modal(layout, modal)


func _refresh_modal(layout: Dictionary, modal: String) -> void:
	var large: bool = game.progress.data["settings"].get("large_text", false)
	var visible_modal: bool = not modal.is_empty()
	var campaign: bool = game.current_level_id > 0 and not game.practice_mode
	_rect(shade, Rect2(Vector2.ZERO, size))
	shade.visible = visible_modal
	panels["dialog"].visible = visible_modal
	icons["modal"].visible = visible_modal
	for i in range(3):
		icons["rating%d" % i].visible = visible_modal and modal == "result" and campaign and game.won
	for key in ["modal_eyebrow", "modal_title", "modal_body", "modal_score"]:
		labels[key].visible = visible_modal
	for key in ["replay", "resume", "guide", "back", "stress", "next", "map", "restart", "confirm_leave", "confirm_restart", "settings"]:
		if modal != last_modal or not visible_modal:
			buttons[key].visible = false
	if not visible_modal:
		last_modal = ""
		return
	var dialog: Rect2 = layout["dialog"]
	_rect(panels["dialog"], dialog)
	var x: float = dialog.position.x + 24
	var width: float = dialog.size.x - 48
	_rect(icons["modal"], Rect2(dialog.get_center().x - 26, dialog.position.y + 24, 52, 52))
	_place("modal_eyebrow", Rect2(x, dialog.position.y + 86, width, 20))
	_place("modal_title", Rect2(x, dialog.position.y + 109, width, 44))
	_place("modal_body", Rect2(x, dialog.position.y + 158, width, dialog.size.y - 303))
	_place("modal_score", Rect2(x, dialog.end.y - 145, width, 46))
	labels["modal_body"].add_theme_font_size_override("font_size", 14 if campaign else 15)
	labels["modal_score"].add_theme_font_size_override("font_size", 14 if modal == "help" else 26)
	labels["modal_score"].text = ""
	var order: Array = []
	if modal == "result":
		icons["modal"].texture = STAR_ICON if game.won else RETRY_ICON
		labels["modal_eyebrow"].text = "A LITTLE STARLIGHT RESTORED" if game.won else "THE STARS ARE STILL WITH YOU"
		labels["modal_title"].text = "Beautifully done." if game.won else "One more try?"
		labels["modal_body"].text = "Every little match brings the galaxy back to light." if game.won else game.session.goals_text()
		labels["modal_score"].text = "%s starlight" % str(game.score)
		buttons["replay"].text = "Replay" if game.won and campaign else ("Try again" if campaign else "Play again")
		if campaign:
			labels["modal_eyebrow"].text = "LYRA / LEVEL %d OF 5" % game.current_level_id
			if game.won:
				icons["modal"].visible = false
				for i in range(3):
					var icon: TextureRect = icons["rating%d" % i]
					_rect(icon, Rect2(dialog.get_center().x - 67 + i * 48, dialog.position.y + 30, 38, 38))
					icon.modulate = Color.WHITE if i < game.session.stars() else Color(0.25, 0.25, 0.32)
				labels["modal_title"].text = "Lyra is alight." if game.current_level_id == 5 else "A star restored."
				_place("modal_body", Rect2(x, dialog.position.y + 156, width, 50))
				labels["modal_body"].text = "Score %d + bonus %d" % [game.score, game.moves_left * game.session.MOVE_BONUS]
				_place("modal_score", Rect2(x, dialog.position.y + 210, width, 32))
				labels["modal_score"].text = "%d starlight" % game.session.rating_score()
				if game.current_level_id < 5:
					_rect(buttons["next"], Rect2(x, dialog.end.y - 184, width, 48))
					buttons["next"].visible = true
					order.append("next")
				_rect(buttons["replay"], Rect2(x, dialog.end.y - 128, width, 48))
			else:
				_place("modal_body", Rect2(x, dialog.position.y + 158, width, 82))
				_place("modal_score", Rect2(x, dialog.end.y - 190, width, 36))
				_rect(buttons["replay"], Rect2(x, dialog.end.y - 128, width, 48))
			_rect(buttons["map"], layout["replay"])
			buttons["map"].visible = true
			order.append("replay")
			order.append("map")
			if not game.progress.notice.is_empty():
				labels["modal_body"].text = game.progress.notice
		else:
			_rect(buttons["replay"], layout["replay"])
			order = ["replay"]
		buttons["replay"].visible = true
	elif modal == "help":
		icons["modal"].texture = STAR_ICON
		labels["modal_eyebrow"].text = "YOUR LITTLE FIELD GUIDE"
		labels["modal_title"].text = "Follow the stars."
		labels["modal_body"].text = game.session.level["tutorial"] if campaign else "Swap neighbors to match 3; match 4, 5 or T/L for powers. Solid rocks take two hits."
		labels["modal_score"].text = "Score +25 per unused move\n2 stars: %d / 3 stars: %d" % [game.session.level["star_scores"][1], game.session.level["star_scores"][2]] if campaign else "Fill Nova, then tap a tile. No move spent."
		_rect(buttons["back"], layout["replay"])
		buttons["back"].visible = true
		order = ["back"]
		_rect(icons["modal"], Rect2(dialog.get_center().x - 18, dialog.position.y + 16, 36, 36))
		_place("modal_eyebrow", Rect2(x, dialog.position.y + 54, width, 20))
		_place("modal_title", Rect2(x, dialog.position.y + 77, width, 42))
		_place("modal_body", Rect2(x, dialog.position.y + 124, width, dialog.size.y - 272))
		_place("modal_score", Rect2(x, dialog.end.y - 138, width, 54))
	elif modal == "tools":
		labels["modal_eyebrow"].text = "DEVELOPMENT TOOLS"
		labels["modal_title"].text = "Effects check"
		labels["modal_body"].text = "Synthetic drawing workload, not gameplay performance evidence.\n\n" + game.stress_report
		_rect(buttons["stress"], layout["replay"])
		buttons["stress"].visible = true
		order = ["stress"]
	elif modal in ["leave", "restart"]:
		icons["modal"].texture = RETRY_ICON
		labels["modal_eyebrow"].text = "YOUR EARNED STARS ARE SAFE"
		labels["modal_title"].text = "Leave this round?" if modal == "leave" else "Start fresh?"
		labels["modal_body"].text = "This unfinished round will be discarded. Your saved stars and best scores stay safe."
		var action: String = "confirm_leave" if modal == "leave" else "confirm_restart"
		_rect(buttons[action], Rect2(x, dialog.end.y - 128, width, 48))
		_rect(buttons["resume"], layout["replay"])
		buttons[action].visible = true
		buttons["resume"].visible = true
		order = ["resume", action]
	else:
		icons["modal"].texture = PAUSE_ICON
		labels["modal_eyebrow"].text = "THE GALAXY CAN WAIT"
		labels["modal_title"].text = "A little breather."
		labels["modal_body"].text = "Your crystals will be right here."
		if campaign:
			_place("modal_body", Rect2(x, dialog.position.y + 156, width, 24))
			order = ["resume", "guide", "settings", "restart", "map"]
			labels["modal_body"].visible = false
			for i in range(order.size()):
				_rect(buttons[order[i]], Rect2(x, dialog.end.y - 272 + i * 50, width, 48))
				buttons[order[i]].visible = true
		else:
			_rect(buttons["resume"], Rect2(x, dialog.end.y - 138, width, 48))
			_rect(buttons["guide"], layout["replay"])
			buttons["resume"].visible = true
			buttons["guide"].visible = true
			order = ["resume", "guide"]
	if modal != last_modal:
		for i in range(order.size()):
			var button: Button = buttons[order[i]]
			button.focus_next = button.get_path_to(buttons[order[(i + 1) % order.size()]])
			button.focus_previous = button.get_path_to(buttons[order[(i - 1 + order.size()) % order.size()]])
		if not order.is_empty():
			buttons[order[0]].grab_focus()
	# Restore the normal font size as well as enlarging it. Otherwise a prior
	# toggle remains stuck at the larger size after the player turns it off.
	labels["modal_body"].add_theme_font_size_override("font_size", (20 if large else 17) if campaign else (21 if large else 18))
	labels["modal_score"].add_theme_font_size_override("font_size", (20 if large else 17) if modal == "help" else 26)
	last_modal = modal
