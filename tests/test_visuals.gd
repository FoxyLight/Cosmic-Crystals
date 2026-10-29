extends SceneTree
## Visual identity contract: each crystal must remain readable at small sizes.
## Run: godot --headless --path . --script res://tests/test_visuals.gd

const BoardScript = preload("res://scripts/board.gd")
const Visuals = preload("res://scripts/crystal_visuals.gd")

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run_checks()
	print("Crystal visuals: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)


func _luma(c: Color) -> float:
	return c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722


func _run_checks() -> void:
	_check(Visuals.FILL_HEX.size() == BoardScript.KIND_COUNT, "One visual for every crystal type")
	_check(Visuals.OUTLINE_HEX.size() == BoardScript.KIND_COUNT, "One outline for every crystal type")
	_check(Visuals.FACET_HEX.size() == BoardScript.KIND_COUNT, "One facet color for every crystal type")
	_check(Visuals.GLINT_HEX.size() == BoardScript.KIND_COUNT, "One glint color for every crystal type")
	_check(Visuals.NAMES.size() == BoardScript.KIND_COUNT, "One name for every crystal type")

	var amber: Color = Visuals.fill_color(1)
	var opal: Color = Visuals.fill_color(5)
	_check(amber.r > amber.g and amber.g > amber.b * 2.0, "Solar Amber is unmistakably warm")
	_check(opal.b > opal.g and opal.g > opal.r, "Lunar Opal is cool blue-white")
	_check(amber.r - amber.b > 0.65, "Solar Amber must stay far from blue")
	_check(opal.b - opal.r > 0.15, "Lunar Opal must have a blue cast")
	_check(Visuals.facet_color(1).r > Visuals.facet_color(1).b * 1.6,
		"Amber facet is warm, not white")
	_check(Visuals.facet_color(5).b > Visuals.facet_color(5).r,
		"Opal facet is cool, not yellow")

	var vertex_counts: Dictionary = {}
	for kind in range(BoardScript.KIND_COUNT):
		var fill: Color = Visuals.fill_color(kind)
		var edge: Color = Visuals.outline_color(kind)
		_check(_luma(fill) - _luma(edge) > 0.20,
			"Gem outline must be visibly darker than its fill: %d" % kind)
		_check(fill.a > 0.99, "Gem fill must be opaque: %d" % kind)
		var points: PackedVector2Array = Visuals.shape_points(kind, Vector2.ZERO, 20.0)
		_check(points.size() >= 4, "Gem must have a complete polygon: %d" % kind)
		_check(not vertex_counts.has(points.size()), "Every gem has a unique silhouette: %d" % kind)
		vertex_counts[points.size()] = true
		for point in points:
			_check(point.length() <= 25.0, "Gem silhouette remains within tile budget: %d" % kind)
		var shifted: PackedVector2Array = Visuals.shape_points(kind, Vector2(30.0, -10.0), 20.0)
		_check(shifted.size() == points.size(), "Moving a gem preserves its contour: %d" % kind)
		if points.size() > 0:
			_check(shifted[0].distance_to(points[0] + Vector2(30.0, -10.0)) < 0.01,
				"Gem contour translates correctly: %d" % kind)
	_check(Visuals.shape_points(-1, Vector2.ZERO, 20.0).is_empty(),
		"Invalid crystal kind renders no polygon")
	_check(Visuals.shape_points(0, Vector2.ZERO, 0.0).is_empty(),
		"Zero-radius gem renders no polygon")
	_check(Visuals.shape_points(1, Vector2.ZERO, 20.0).size() == 12,
		"Solar Amber is a twelve-vertex sunburst")
	_check(Visuals.shape_points(5, Vector2.ZERO, 20.0).size() == 8,
		"Lunar Opal is an eight-vertex ice shard")
