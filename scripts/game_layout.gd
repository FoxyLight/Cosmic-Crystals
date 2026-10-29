extends RefCounted
## Shared geometry for the board, real HUD controls and pointer hit tests.
## Coordinates are viewport units; safe-area conversion is owned by the scene.


static func calculate(view_size: Vector2, insets: Vector4 = Vector4.ZERO, campaign: bool = false) -> Dictionary:
	var caption_height: float = 40.0 if campaign else 24.0
	var area: Rect2 = Rect2(Vector2(insets.x, insets.y),
		view_size - Vector2(insets.x + insets.z, insets.y + insets.w))
	var desktop: bool = area.size.x >= 760.0 and area.size.x > area.size.y * 1.15
	var result: Dictionary = {"safe": area, "desktop": desktop}
	if desktop:
		var side: float = minf(area.size.y - 204.0, 560.0)
		var width: float = minf(area.size.x - 64.0, side + 340.0)
		var x: float = area.position.x + (area.size.x - width) * 0.5
		var y: float = area.position.y + 20.0
		var column_x: float = x + side + 28.0
		var column_width: float = width - side - 28.0
		result["header"] = Rect2(x, y, width, 48)
		result["heading"] = Rect2(x, y + 70, width, 54)
		result["board"] = Rect2(x + 8, y + 144, side - 16, side - 16)
		result["goals"] = Rect2(column_x, y + 136, column_width, 76)
		result["score"] = Rect2(column_x, y + 224, (column_width - 10) * 0.5, 76)
		result["moves"] = Rect2(column_x + (column_width + 10) * 0.5, y + 224, (column_width - 10) * 0.5, 76)
		result["nova"] = Rect2(column_x, y + 312, column_width, 82)
		result["caption"] = Rect2(x, y + 136 + side + 6, side, caption_height)
		result["aside"] = Rect2(column_x, y + 416, column_width, 110) if area.size.y >= 580 else Rect2()
	else:
		var width: float = minf(area.size.x - 24.0, 440.0)
		var x: float = area.position.x + (area.size.x - width) * 0.5
		var y: float = area.position.y + 8.0
		var compact: bool = area.size.y < 730.0
		var gap: float = 6.0 if compact else 8.0
		result["header"] = Rect2(x, y, width, 52)
		y += 52.0 + gap
		result["heading"] = Rect2(x, y, width, 46)
		y += 46.0 + gap
		result["goals"] = Rect2(x, y, width, 58)
		y += 58.0 + gap
		var bottom: float = area.end.y - 10.0
		result["nova"] = Rect2(x, bottom - 64.0, width, 64)
		result["score"] = Rect2(x, bottom - 64.0 - gap - 56.0, (width - gap) * 0.5, 56)
		result["moves"] = Rect2(x + (width + gap) * 0.5, bottom - 64.0 - gap - 56.0, (width - gap) * 0.5, 56)
		var available: float = result["score"].position.y - gap - caption_height - 2.0 - y
		var side: float = minf(width - 16.0, available - 16.0)
		var region_y: float = y + (available - side - 16.0) * 0.5
		result["board"] = Rect2(x + (width - side) * 0.5, region_y + 8.0, side, side)
		result["caption"] = Rect2(x, result["score"].position.y - gap - caption_height, width, caption_height)
		result["aside"] = Rect2()
	var nova: Rect2 = result["nova"]
	result["nova_button"] = Rect2(nova.position + Vector2(nova.size.x * 0.52, 6), Vector2(nova.size.x * 0.48 - 12, nova.size.y - 12))
	var header: Rect2 = result["header"]
	result["help_button"] = Rect2(header.end.x - 108, header.position.y, 52, 52)
	result["pause_button"] = Rect2(header.end.x - 52, header.position.y, 52, 52)
	var modal_width: float = minf(area.size.x - 32.0, 376.0)
	var modal_height: float = minf(area.size.y - 32.0, 430.0)
	result["dialog"] = Rect2(area.get_center() - Vector2(modal_width, modal_height) * 0.5,
		Vector2(modal_width, modal_height))
	var dialog: Rect2 = result["dialog"]
	result["replay"] = Rect2(dialog.position.x + 24, dialog.end.y - 72, dialog.size.x - 48, 48)
	return result
