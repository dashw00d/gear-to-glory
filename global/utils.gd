extends Node

# Secret key as a string (matching the working example's approach)
const ENCRYPTION_KEY = "my_secret_key_12345_padding_to_32_chars"

## Safely returns a property without breaking
func safe_get_property(obj, prop_name, default_value):
	if obj and obj.has_method("has_property") and obj.has_property(prop_name):
		return obj.get(prop_name)
	else:
		return default_value

## Load an unencrypted JSON file and return as Dict (for resource files)
func load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.ModeFlags.READ)
	if file == null:
		print_debug("File not found: ", path)
		return {}
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		return json.get_data()
	else:
		print_debug("Failed to parse JSON data from file: ", json.get_error_message())
		return {}

## Load an encrypted JSON file and return as Dict (for save files)
func load_encrypted_json(path: String) -> Dictionary:
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.ModeFlags.READ, ENCRYPTION_KEY)
	if file == null:
		print_debug("File not found or failed to decrypt: ", path)
		return {}
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		return json.get_data()
	else:
		print_debug("Failed to parse JSON data from file: ", json.get_error_message())
		return {}

## Save a JSON file with the provided data, encrypting it
func save_json(data: Dictionary, path: String):
	print("save_json called with path: ", path)
	if !path:
		path = "user://save.json"
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.ModeFlags.WRITE, ENCRYPTION_KEY)
	if file:
		var json_string = JSON.new().stringify(data, "\t")
		file.store_string(json_string)
		file.flush()  # Ensure data is written
		file.close()
	else:
		var error = FileAccess.get_open_error()
		print_debug("Failed to open file for encrypted writing: ", path, " Error: ", error)

## Load an unencrypted JSON file and return as Array (for resource files)
func load_json_array(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.ModeFlags.READ)
	if file == null:
		print_debug("File not found: ", path)
		return []
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		return json.get_data()
	else:
		print_debug("Failed to parse JSON data from file: ", json.get_error_message())
		return []

## Round to nearest .05
func round_to_05(num) -> float:
	var scaled = num / 0.05
	var rounded_scaled = floor(scaled + 0.5)
	return rounded_scaled * 0.05

func is_value_empty(value) -> bool:
	if value == null:
		return true
	elif typeof(value) == TYPE_STRING and value.strip() == "":
		return true
	elif typeof(value) in [TYPE_ARRAY, TYPE_DICTIONARY] and value.size() == 0:
		return true
	return false
