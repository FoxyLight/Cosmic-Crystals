extends Control
## Native Labels/Buttons, styled like the earlier web/Android visual direction.
## This view reads the controller; it never scores, resolves or mutates a board.
const TITLE_FONT = preload("res://assets/fonts/Outfit.ttf")
const BODY_FONT = preload("res://assets/fonts/DM-Sans.ttf")
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
	_label("brand_mark", "✧", 36, VIOLET, true)
	_label("brand_sub", "A STARWEAVER'S JOURNEY", 9, MUTED)
	_label("eyebrow", "A LITTLE MATCH. A LITTLE MAGIC.", 10, VIOLET)
	_label("title", "Asteroid field", 28, TEXT, true)
	_label("crystal_name", "CRYSTALS", 10, MUTED)
	_label("crystal_count", "0 / 30", 22, TEXT, true)
	_label("rock_name", "ASTEROIDS", 10, MUTED)
	_label("rock_count", "6 left", 22, TEXT, true)
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
	_label("nova_name", "✧  NOVA PULSE", 12, VIOLET, true)
	_label("nova_charge", "GATHERING ENERGY · 0%", 9, MUTED)
	_label("caption", "Match beside asteroids to crack them", 11, MUTED)
	_label("aside", "Restore a little starlight.\n\nMatch three crystals. Crack the asteroids.\nUse your Nova when the stars align.", 15, MUTED)
	labels["aside"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_track("crystals", VIOLET)
	_track("rocks", GOLD)
	_track("nova", VIOLET)
	_button("help", "?", func(): game.open_overlay("help"), true)
	_button("pause", "Ⅱ", func(): game.open_overlay("pause"), true)
	_button("nova", "Gathering…", func(): game.toggle_nova())
	shade = ColorRect.new()
	shade.color = Color(0.025, 0.03, 0.09, 0.86)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	_panel("dialog", Color("#211C3B"), Color("#70558F"))
	_label("modal_mark", "✧", 52, VIOLET, true)
	_label("modal_eyebrow", "A LITTLE STARLIGHT RESTORED", 10, VIOLET)
	_label("modal_title", "Beautifully done.", 32, TEXT, true)
	_label("modal_body", "", 15, MUTED)
	labels["modal_body"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label("modal_score", "", 26, GOLD, true)
	_button("replay", "Play again", func(): game._reset_game())
	_button("resume", "Keep playing", func(): game.close_overlay())
	_button("guide", "How to play", func(): game.open_overlay("help"))
	_button("back", "Back to game", func(): game.close_overlay())
	_button("stress", "Run effects check", func(): game._toggle_stress_test(); game.close_overlay())
	for key in ["modal_mark", "modal_eyebrow", "modal_title", "modal_body", "modal_score"]:
		labels[key].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		labels[key].vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _style(bg: Color, line: Color, radius: int = 16) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = line
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	return style


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
	button.pressed.connect(action)
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
	var modal: String = "result" if game.finished else game.overlay
	var blocked: bool = not modal.is_empty()
	var idle: bool = game.phase == "idle" or game.phase == "nova_targeting"
	for key in ["goals", "score", "moves", "nova"]:
		_rect(panels[key], layout[key])
	var header: Rect2 = layout["header"]
	_place("brand_mark", Rect2(header.position + Vector2(0, 3), Vector2(34, 44)))
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
	var goals: Rect2 = layout["goals"]
	var half: float = goals.size.x * 0.5
	for group in ["crystal", "rock"]:
		var x: float = goals.position.x + (half if group == "rock" else 0)
		_rect(icons[group], Rect2(x + 10, goals.position.y + 10, 30, 38))
		_place(group + "_name", Rect2(x + 46, goals.position.y + 7, half - 56, 16))
		_place(group + "_count", Rect2(x + 46, goals.position.y + 22, half - 56, 28))
	labels["crystal_count"].text = "%d / %d" % [mini(game.collected, game.GOAL), game.GOAL]
	var remaining: int = game._asteroids_remaining()
	labels["rock_count"].text = "All clear" if remaining == 0 else "%d left" % remaining
	labels["crystal_count"].modulate = Color("#AEF0CD") if game.collected >= game.GOAL else Color.WHITE
	labels["rock_count"].modulate = Color("#AEF0CD") if remaining == 0 else Color.WHITE
	_meter("crystals", Rect2(goals.position.x + 46, goals.end.y - 6, half - 60, 3), float(game.collected) / game.GOAL)
	_meter("rocks", Rect2(goals.position.x + half + 46, goals.end.y - 6, half - 60, 3), float(game.ASTEROID_LAYOUT.size() - remaining) / game.ASTEROID_LAYOUT.size())
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
	_place("nova_name", Rect2(nova.position + Vector2(12, 8), Vector2(nova.size.x * 0.5 - 16, 20)))
	_place("nova_charge", Rect2(nova.position + Vector2(12, 30), Vector2(nova.size.x * 0.5 - 18, 16)))
	labels["nova_charge"].text = "READY TO SHINE" if charged else "CHARGING · %d%%" % (energy * 100 / game.BoardScript.NOVA_MAX)
	_meter("nova", Rect2(nova.position + Vector2(12, nova.size.y - 12), Vector2(nova.size.x * 0.5 - 18, 4)), float(energy) / game.BoardScript.NOVA_MAX)
	_rect(buttons["nova"], layout["nova_button"])
	buttons["nova"].text = "Cancel Nova" if game.phase == "nova_targeting" else ("Unleash Nova" if charged else "Gathering…")
	buttons["nova"].disabled = blocked or not idle or not charged
	_place("caption", layout["caption"])
	labels["caption"].text = "Choose a tile for your Nova Pulse" if game.phase == "nova_targeting" else game.feedback
	labels["caption"].modulate = Color.WHITE if game.feedback_ok else Color("#FF9AB4")
	_place("aside", layout["aside"])
	labels["aside"].visible = layout["aside"].size.y > 0
	_refresh_modal(layout, modal)


func _refresh_modal(layout: Dictionary, modal: String) -> void:
	var visible_modal: bool = not modal.is_empty()
	_rect(shade, Rect2(Vector2.ZERO, size))
	shade.visible = visible_modal
	panels["dialog"].visible = visible_modal
	for key in ["modal_mark", "modal_eyebrow", "modal_title", "modal_body", "modal_score"]:
		labels[key].visible = visible_modal
	for key in ["replay", "resume", "guide", "back", "stress"]:
		if modal != last_modal or not visible_modal:
			buttons[key].visible = false
	if not visible_modal:
		last_modal = ""
		return
	var dialog: Rect2 = layout["dialog"]
	_rect(panels["dialog"], dialog)
	var x: float = dialog.position.x + 24
	var width: float = dialog.size.x - 48
	_place("modal_mark", Rect2(x, dialog.position.y + 18, width, 64))
	_place("modal_eyebrow", Rect2(x, dialog.position.y + 86, width, 20))
	_place("modal_title", Rect2(x, dialog.position.y + 109, width, 44))
	_place("modal_body", Rect2(x, dialog.position.y + 158, width, dialog.size.y - 303))
	_place("modal_score", Rect2(x, dialog.end.y - 145, width, 46))
	labels["modal_score"].text = ""
	if modal == "result":
		labels["modal_mark"].text = "✧" if game.won else "◇"
		labels["modal_eyebrow"].text = "A LITTLE STARLIGHT RESTORED" if game.won else "THE STARS ARE STILL WITH YOU"
		labels["modal_title"].text = "Beautifully done." if game.won else "One more try?"
		labels["modal_body"].text = "Every little match brings the galaxy back to light." if game.won else "%d / %d crystals collected\n%d asteroids still to clear" % [mini(game.collected, game.GOAL), game.GOAL, game._asteroids_remaining()]
		labels["modal_score"].text = "%s starlight" % str(game.score)
		_rect(buttons["replay"], layout["replay"])
		buttons["replay"].visible = true
	elif modal == "help":
		labels["modal_mark"].text = "✧"
		labels["modal_eyebrow"].text = "YOUR LITTLE FIELD GUIDE"
		labels["modal_title"].text = "Follow the stars."
		labels["modal_body"].text = "Match 3 by swapping neighbors. Match 4, 5 or a T/L for powers.\n\nMatch beside rocks or blast them. Two pips → one → clear."
		labels["modal_score"].add_theme_font_size_override("font_size", 14)
		labels["modal_score"].text = "Fill Nova, then tap a tile. No move spent."
		_rect(buttons["back"], layout["replay"])
		buttons["back"].visible = true
	elif modal == "tools":
		labels["modal_eyebrow"].text = "DEVELOPMENT TOOLS"
		labels["modal_title"].text = "Effects check"
		labels["modal_body"].text = "Synthetic drawing workload, not gameplay performance evidence.\n\n" + game.stress_report
		_rect(buttons["stress"], layout["replay"])
		buttons["stress"].visible = true
	else:
		labels["modal_mark"].text = "Ⅱ"
		labels["modal_eyebrow"].text = "THE GALAXY CAN WAIT"
		labels["modal_title"].text = "A little breather."
		labels["modal_body"].text = "Your crystals will be right here."
		_rect(buttons["resume"], Rect2(x, dialog.end.y - 138, width, 48))
		_rect(buttons["guide"], layout["replay"])
		buttons["resume"].visible = true
		buttons["guide"].visible = true
	labels["modal_score"].add_theme_font_size_override("font_size", 14 if modal == "help" else 26)
	# Keep keyboard focus inside the current modal's real controls.
	if modal != last_modal:
		var order: Array = ["replay"] if modal == "result" else (["resume", "guide"] if modal == "pause" else (["back"] if modal == "help" else ["stress"]))
		for i in range(order.size()):
			var button: Button = buttons[order[i]]
			button.focus_next = button.get_path_to(buttons[order[(i + 1) % order.size()]])
			button.focus_previous = button.get_path_to(buttons[order[(i - 1 + order.size()) % order.size()]])
		buttons[order[0]].grab_focus()
	last_modal = modal
