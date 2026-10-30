extends RefCounted
## Rolling bounded frame-time samples. Reports observed environment, never a
## synthetic workload as physical-device performance.
const LIMIT: int = 600
var frames: PackedFloat32Array = PackedFloat32Array()
var cursor: int = 0
var loading_ms: float = 0
var turns: int = 0
var events: Dictionary = {}
var startup_ms: int = Time.get_ticks_msec()


func sample(delta: float) -> void:
	if delta <= 0: return
	if frames.size() < LIMIT: frames.append(delta * 1000)
	else:
		frames[cursor] = delta * 1000
		cursor = (cursor + 1) % LIMIT


func report() -> Dictionary:
	var ordered: PackedFloat32Array = frames.duplicate()
	ordered.sort()
	var total: float = 0
	for value in ordered: total += value
	return {"environment": OS.get_name(), "renderer": RenderingServer.get_current_rendering_method(),
		"samples": frames.size(), "mean_frame_ms": total / maxf(1, frames.size()),
		"p95_frame_ms": ordered[mini(ordered.size() - 1, int(ordered.size() * .95))] if not ordered.is_empty() else 0,
		"fps": Engine.get_frames_per_second(), "static_memory_bytes": OS.get_static_memory_usage(),
		"startup_ms": startup_ms, "last_level_load_ms": loading_ms, "turns": turns, "events": events.duplicate()}
