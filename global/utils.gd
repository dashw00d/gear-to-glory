extends Node

## Safely returns a property without breaking
func safe_get_property(obj, prop_name, default_value):
	if obj and obj.has_method("has_property") and obj.has_property(prop_name):
		return obj.get(prop_name)
	else:
		return default_value

## Load a JSON file and return as Dict (returns empty dict on fail)
func load_json(path: String) -> Dictionary:
	# Attempt to open the file for reading to check if it exists and is not empty
	var file = FileAccess.open(path, FileAccess.ModeFlags.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	if error == OK:
		return json.get_data()
	else:
		print_debug("Failed to parse JSON data from file.")
	return {}

## Round to nearest .05
func round_to_05(num) -> float:
	var scaled = num / 0.05
	var rounded_scaled = floor(scaled + 0.5)  # GDScript's way to round
	return rounded_scaled * 0.05

