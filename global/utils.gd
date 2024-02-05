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

func save_json(item_data: Dictionary, path: String):
	if !path:
		path = "res://assets/data/default_save.json"
	
	# Initialize a variable to hold the existing data
	var data: Dictionary = {}
	
	# Open the file for reading
	var file = FileAccess.open(path, FileAccess.ModeFlags.READ_WRITE)
	if file:
		var content = file.get_as_text()  # Get the entire file content as text
		file.close()  # Close the file after reading
		
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			data = json.data
			if typeof(data) != TYPE_DICTIONARY:
				print("Unexpected data")
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())
	# Update the dictionary with the new item data
	for key in item_data.keys():
		data[key] = item_data[key]  # Update or add the new item
	# Open the file again, this time for writing
	file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	if file:
		var json_string = JSON.new().stringify(data, "\t")  # Convert the updated dictionary back to a JSON string
		file.store_string(json_string)  # Write the JSON string to the file
		file.close()  # Close the file

## Round to nearest .05
func round_to_05(num) -> float:
	var scaled = num / 0.05
	var rounded_scaled = floor(scaled + 0.5)  # GDScript's way to round
	return rounded_scaled * 0.05

