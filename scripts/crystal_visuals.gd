extends RefCounted
class_name CrystalVisuals
## Centralized, device-readable crystal palette and silhouettes.
## Keep the indices in sync with CrystalBoard (0..5); these are purely visual.
## A separate shape and outline distinguish each crystal without relying on hue.

const NAMES = [
	"Nebula Amethyst", "Solar Amber", "Quantum Sapphire",
	"Plasma Ruby", "Aurora Emerald", "Lunar Opal"
]

# Warm deep-orange amber versus a COOL blue-white opal, not two pale yellows.
const FILL_HEX = [
	"#824CF1", "#ED9B18", "#13B5EB",
	"#F849A9", "#24CF87", "#D0EDFF"
]
const OUTLINE_HEX = [
	"#371570", "#733907", "#075176",
	"#792354", "#075B3C", "#2F5C88"
]
const FACET_HEX = [
	"#C09BFF", "#FFD26A", "#70E6FF",
	"#FFA0D4", "#93FFD1", "#83C9F6"
]
const GLINT_HEX = [
	"#E0D0FF", "#FFE19B", "#C1F5FF",
	"#FFD0E8", "#C9FFE9", "#EDF9FF"
]


static func fill_color(kind: int) -> Color:
	return Color(FILL_HEX[kind]) if _valid_kind(kind) else Color.TRANSPARENT


static func outline_color(kind: int) -> Color:
	return Color(OUTLINE_HEX[kind]) if _valid_kind(kind) else Color.TRANSPARENT


static func facet_color(kind: int) -> Color:
	return Color(FACET_HEX[kind]) if _valid_kind(kind) else Color.TRANSPARENT


static func glint_color(kind: int) -> Color:
	return Color(GLINT_HEX[kind]) if _valid_kind(kind) else Color.TRANSPARENT


static func _valid_kind(kind: int) -> bool:
	return kind >= 0 and kind < FILL_HEX.size()


static func shape_points(kind: int, center: Vector2, radius: float) -> PackedVector2Array:
	# Vertex counts are intentionally distinct: 4, 12, 6, 10, 7, 8.
	# 0 diamond; 1 sunburst; 2 hexagon; 3 five-point star;
	# 4 tapered emerald; 5 elongated ice shard.
	var points: PackedVector2Array = PackedVector2Array()
	if radius <= 0.0 or not _valid_kind(kind):
		return points
	match kind:
		0:
			# Tall amethyst diamond.
			for p in [Vector2(0.0, -1.09), Vector2(0.91, 0.0),
					Vector2(0.0, 1.09), Vector2(-0.91, 0.0)]:
				points.append(center + p * radius)
		1:
			# Amber is the ONLY radial sunburst: warm and serrated.
			for i in range(12):
				var theta: float = -PI * 0.5 + TAU * float(i) / 12.0
				var r: float = radius * (1.04 if i % 2 == 0 else 0.78)
				points.append(center + Vector2(cos(theta), sin(theta)) * r)
		2:
			# A wider, cyan sapphire hexagon.
			for i in range(6):
				var theta: float = TAU * float(i) / 6.0
				points.append(center + Vector2(cos(theta), sin(theta) * 0.88) * radius)
		3:
			for i in range(10):
				var theta: float = -PI * 0.5 + TAU * float(i) / 10.0
				var r: float = radius * (1.0 if i % 2 == 0 else 0.70)
				points.append(center + Vector2(cos(theta), sin(theta)) * r)
		4:
			for p in [Vector2(0.0, -1.13), Vector2(0.61, -0.58),
					Vector2(0.92, 0.22), Vector2(0.49, 0.88),
					Vector2(0.0, 1.02), Vector2(-0.73, 0.58),
					Vector2(-0.83, -0.32)]:
				points.append(center + p * radius)
		5:
			# Long icy shard, NOT a white/yellow sun or a cyan hexagon.
			for p in [Vector2(0.0, -1.16), Vector2(0.36, -0.73),
					Vector2(0.58, 0.16), Vector2(0.28, 0.91),
					Vector2(0.0, 1.16), Vector2(-0.42, 0.73),
					Vector2(-0.58, 0.04), Vector2(-0.32, -0.64)]:
				points.append(center + p * radius)
	return points
