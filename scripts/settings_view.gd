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
	for key in sliders:
		var slider: HSlider = sliders[key]
		slider.set_value_no_signal(float(settings[key]) * 100)
		slider.position = Vector2(x, y + 20)
		slider.size = Vector2(w, 48)
		captions[key].position = Vector2(x, y)
		captions[key].size = Vector2(w, 20)
		captions[key].text = "%s  %d%%" % [{"master_volume": "Master", "music_volume": "Music", "sfx_volume": "Sound effects"}[key], roundi(slider.value)]
		y += 68
	for key in toggles:
		toggles[key].set_pressed_no_signal(settings[key])
		toggles[key].position = Vector2(x, y)
		toggles[key].size = Vector2(w, 48)
		y += 48
	status.position = Vector2(x, y + 2)
	status.size = Vector2(w, maxf(36, rect.end.y - 66 - y))
	status.text = game.progress.notice if not game.progress.notice.is_empty() else "Preferences saved on this device.\nAudio pauses when the app loses focus."
	back.position = Vector2(x, rect.end.y - 60)
	back.size = Vector2(w, 48)
