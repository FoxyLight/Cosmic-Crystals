extends Control
## Android-sized settings sheet. The board and scores remain behind it.
var game
var panel: Panel
var title: Label
var sliders: Dictionary = {}
var captions: Dictionary = {}
var toggles: Dictionary = {}
var back: Button
var status: Label
var preview: Label
var active_touch_index: int = -1
var active_touch_key: String = ""


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(.025, .03, .09, .94)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	panel = Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", game.hud._style(Color("#211C3B"), Color("#8E73AD")))
	add_child(panel)
	title = _label("Sound & comfort", 25)
	for key in ["master_volume", "music_volume", "sfx_volume"]:
		captions[key] = _label("", 14)
		var slider: HSlider = HSlider.new()
		slider.min_value = 0
		slider.max_value = 100
		slider.step = 5
		slider.focus_mode = Control.FOCUS_ALL
		slider.tooltip_text = key.replace("_volume", " volume").capitalize()
		slider.value_changed.connect(func(value: float): game.set_preference(key, value / 100.0))
		sliders[key] = slider
		add_child(slider)
	for key in ["muted", "reduced_motion", "large_text"]:
		var toggle: CheckButton = CheckButton.new()
		toggle.text = {"muted": "Mute all audio", "reduced_motion": "Reduced motion", "large_text": "Larger reading text"}[key]
		toggle.add_theme_font_override("font", game.hud.body_face)
		toggle.add_theme_font_size_override("font_size", 15)
		toggle.toggled.connect(func(value: bool): game.set_preference(key, value))
		toggles[key] = toggle
		add_child(toggle)
	preview = _label("The stars shine brighter.", 14)
	status = _label("", 12)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	back = Button.new()
	back.text = "Done"
	back.add_theme_font_override("font", game.hud.title_face)
	back.add_theme_font_size_override("font_size", 17)
	back.add_theme_stylebox_override("normal", game.hud._style(Color("#70509F"), Color("#C4A3FF")))
	back.pressed.connect(func(): game.close_settings())
	add_child(back)
	visible = false


## A Godot HSlider expects mouse motion, but Android touch-to-mouse emulation is
## disabled so native puzzle gestures are not duplicated. Capture touch drags here
## instead of changing the global input setting or intercepting other controls.
func _input(event: InputEvent) -> void:
	if not visible or game == null or not game.settings_open:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if active_touch_index >= 0:
				return
			for key in sliders:
				var slider: HSlider = sliders[key]
				if slider.get_global_rect().has_point(event.position):
					active_touch_index = event.index
					active_touch_key = key
					_move_touch_slider(event.position)
					get_viewport().set_input_as_handled()
					return
		elif event.index == active_touch_index:
			_move_touch_slider(event.position)
			cancel_touch_drag()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == active_touch_index:
		_move_touch_slider(event.position)
		get_viewport().set_input_as_handled()


func _move_touch_slider(pointer: Vector2) -> void:
	if active_touch_key.is_empty():
		return
	var slider: HSlider = sliders[active_touch_key]
	var bounds: Rect2 = slider.get_global_rect()
	var fraction: float = clampf((pointer.x - bounds.position.x) / maxf(1.0, bounds.size.x), 0.0, 1.0)
	var raw_value: float = lerpf(slider.min_value, slider.max_value, fraction)
	slider.value = clampf(snappedf(raw_value, slider.step), slider.min_value, slider.max_value)


func cancel_touch_drag() -> void:
	active_touch_index = -1
	active_touch_key = ""


func _label(text: String, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_override("font", game.hud.body_face)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("#F0EFFF"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func refresh(area: Rect2) -> void:
	var width: float = minf(400, area.size.x - 24)
	var height: float = minf(560, area.size.y - 16)
	var rect: Rect2 = Rect2(area.get_center() - Vector2(width, height) * .5, Vector2(width, height))
	panel.position = rect.position
	panel.size = rect.size
	var x: float = rect.position.x + 20
	var y: float = rect.position.y + 12
	var w: float = width - 40
	title.position = Vector2(x, y)
	title.size = Vector2(w, 34)
	y += 38
	var settings: Dictionary = game.progress.data["settings"]
	var large: bool = settings.get("large_text", false)
	title.add_theme_font_size_override("font_size", 27 if large else 25)
	back.add_theme_font_size_override("font_size", 19 if large else 17)
	preview.add_theme_font_size_override("font_size", 20 if large else 14)
	status.add_theme_font_size_override("font_size", 14 if large else 12)
	for key in sliders:
		var slider: HSlider = sliders[key]
		slider.set_value_no_signal(float(settings[key]) * 100)
		slider.position = Vector2(x, y + 20)
		slider.size = Vector2(w, 48)
		captions[key].add_theme_font_size_override("font_size", 17 if large else 14)
		captions[key].position = Vector2(x, y)
		captions[key].size = Vector2(w, 20)
		captions[key].text = "%s  %d%%" % [{"master_volume": "Master", "music_volume": "Music", "sfx_volume": "Sound effects"}[key], roundi(slider.value)]
		y += 68
	for key in toggles:
		toggles[key].add_theme_font_size_override("font_size", 18 if large else 15)
		toggles[key].set_pressed_no_signal(settings[key])
		toggles[key].position = Vector2(x, y)
		toggles[key].size = Vector2(w, 48)
		y += 48
	preview.position = Vector2(x, y)
	preview.size = Vector2(w, 32)
	status.position = Vector2(x, y + 34)
	status.size = Vector2(w, maxf(28, rect.end.y - 66 - y - 34))
	status.text = game.progress.notice if not game.progress.notice.is_empty() else "Preferences saved on this device.\nAudio pauses when the app loses focus."
	back.position = Vector2(x, rect.end.y - 60)
	back.size = Vector2(w, 48)
