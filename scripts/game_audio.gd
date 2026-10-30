extends Node
## Bounded SFX pool, two crossfading music voices, no per-event resource loads.
const EFFECTS = ["select", "swap", "invalid", "match", "cascade", "beam", "bomb",
	"supernova", "nova", "rock_hit", "rock_break", "victory", "defeat", "star", "unlock", "menu", "confirm"]
const MUSIC = ["home", "map", "game", "win", "lose"]
const VOICES: int = 6
var streams: Dictionary = {}
var effects: Array[AudioStreamPlayer] = []
var music: Array[AudioStreamPlayer] = []
var gains: Array[float] = [0.0, 0.0]
var target_voice: int = 0
var context: String = ""
var prefs: Dictionary = {"master_volume": 0.8, "music_volume": 0.45, "sfx_volume": 0.7, "muted": false}
var blockers: Dictionary = {}
var recent: Dictionary = {}
var dispatched: Dictionary = {}
var music_starts: int = 0
var dropped: int = 0
var silent_test: bool = DisplayServer.get_name() == "headless"
var busy_until: Array[int] = []


func _ready() -> void:
	for name in EFFECTS + MUSIC.map(func(item): return "music_" + item):
		var stream = load("res://assets/audio/%s.wav" % name)
		if stream is AudioStreamWAV and name.begins_with("music_"):
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_end = int(round(stream.get_length() * stream.mix_rate))
		streams[name] = stream
	for i in range(VOICES):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(player)
		effects.append(player)
		busy_until.append(0)
	for i in range(2):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(player)
		music.append(player)


func configure(settings: Dictionary) -> void:
	for key in prefs:
		if settings.has(key): prefs[key] = settings[key]
	_apply_gains()


func blocked() -> bool:
	return not blockers.is_empty() or bool(prefs["muted"]) or float(prefs["master_volume"]) <= 0


func suspend(reason: String, value: bool) -> void:
	if value: blockers[reason] = true
	else: blockers.erase(reason)
	_apply_gains()


func _apply_gains() -> void:
	for i in range(music.size()):
		music[i].stream_paused = blocked() or float(prefs["music_volume"]) <= 0
		music[i].volume_db = linear_to_db(maxf(.0001, gains[i] * float(prefs["master_volume"]) * float(prefs["music_volume"])))
	for player in effects:
		player.volume_db = linear_to_db(maxf(.0001, float(prefs["master_volume"]) * float(prefs["sfx_volume"]))) - 9.0
		if blocked() or float(prefs["sfx_volume"]) <= 0: player.stop()
	if blocked() or float(prefs["sfx_volume"]) <= 0: busy_until.fill(0)


func set_context(value: String) -> void:
	if value == context or not value in MUSIC: return
	context = value
	target_voice = 1 - target_voice
	music[target_voice].stream = streams["music_" + value]
	gains[target_voice] = 0.0
	music[target_voice].volume_db = -80
	if not silent_test: music[target_voice].play()
	music_starts += 1
	_apply_gains()


func _process(delta: float) -> void:
	if blocked(): return
	for i in range(music.size()):
		gains[i] = move_toward(gains[i], 1.0 if i == target_voice else 0.0, delta / .8)
		if i != target_voice and gains[i] == 0.0: music[i].stop()
	_apply_gains()


func cue(name: String, pitch: float = 1.0) -> bool:
	if not streams.has(name) or blocked() or float(prefs["sfx_volume"]) <= 0: return false
	var now: int = Time.get_ticks_msec()
	if now - int(recent.get(name, -1000)) < 70:
		dropped += 1
		return false
	for i in range(effects.size()):
		var player: AudioStreamPlayer = effects[i]
		if (silent_test and now >= busy_until[i]) or (not silent_test and not player.playing):
			player.stream = streams[name]
			player.pitch_scale = clampf(pitch, .85, 1.25)
			if not silent_test: player.play()
			busy_until[i] = now + int(player.stream.get_length() * 1000 / player.pitch_scale)
			recent[name] = now
			dispatched[name] = int(dispatched.get(name, 0)) + 1
			return true
	dropped += 1
	return false


func event_cues(event: Dictionary) -> Array[String]:
	var result: Array[String] = []
	match str(event.get("type", "")):
		"swap": result.append("swap")
		"swap_back": result.append("invalid")
		"nova": result.append("nova")
		"clear":
			result.append("cascade" if int(event.get("chain", 1)) > 1 else "match")
			# The immutable before snapshot identifies activated powers exactly.
			var before: Array = event.get("specials_before", [])
			for index in event.get("indices", []):
				if index < before.size():
					var power: int = int(before[index])
					var cue_name: String = "supernova" if power == 4 else ("bomb" if power == 3 else ("beam" if power > 0 else ""))
					if not cue_name.is_empty() and not result.has(cue_name): result.append(cue_name)
		"asteroid_hit": result.append("rock_break" if not event.get("destroyed", []).is_empty() else "rock_hit")
	return result


func dispatch_event(event: Dictionary) -> void:
	for name in event_cues(event): cue(name, minf(1.2, 1.0 + .025 * int(event.get("chain", 1))))


func _exit_tree() -> void:
	for player in music + effects:
		player.stop()
		player.stream = null
	streams.clear()
