class_name NumFormat extends Node

static func format_points(points: float) -> String:
	if points > 1_000_000_000_000_000.0:
		return Strings.scientific(points)
	return Strings.format_separators(points, "%0.0f")
