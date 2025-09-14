class_name Strings extends Node

static func format_int(n: int) -> String:
	var s := str(abs(n))
	var out := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		count += 1
		if count % 3 == 0 and i != 0:
			out = "," + out
	if n < 0:
		out = "-" + out
	return out

static func scientific(x: float, sig_figs: int = 4) -> String:
	var factor := pow(10.0, sig_figs - ceil(log(absf(x)) / log(10.0)))
	var rounded := roundf(x * factor) / factor
	return String.num_scientific(rounded)
