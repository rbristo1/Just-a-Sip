extends Node

func sortGroup(group: Array) -> Array:
	group.sort_custom(func(a, b): return getNumberFromName(a.name) < getNumberFromName(b.name))
	return group

func getNumberFromName(name) -> int:
	var result = RegEx.new()
	result.compile(r"\d+")
	var match = result.search(name)
	if (match):
		return int(match.get_string())
	else:
		return 0
