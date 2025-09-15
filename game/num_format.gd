class_name NumFormat extends Node

static func format_points(points: float) -> String:
	if points > 1_000_000_000_000_000.0:
		return Strings.scientific(points)
	# TODO: Avoid ints
	return Strings.format_int(floori(points))
