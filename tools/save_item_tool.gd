@tool
extends EditorPlugin

var item_editor
var set_editor

func _enter_tree():
	item_editor = preload("res://tools/item_editor.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, item_editor)
	item_editor.connect("save_item", Callable(self, "_on_save_item"), CONNECT_PERSIST)

	set_editor = preload("res://tools/set_editor.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, set_editor)
	set_editor.connect("save_item", Callable(self, "_on_save_item"), CONNECT_PERSIST)
	
func _exit_tree():
	remove_control_from_docks(item_editor)
	item_editor.free()
	
	remove_control_from_docks(set_editor)
	set_editor.free()

func _on_save_item(item_data: Dictionary, path: String):
	if !path:
		path = "res://resources/data/item_database_test.json"
	
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
			if typeof(data) == TYPE_DICTIONARY:
				print(data) # Prints array
			else:
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

