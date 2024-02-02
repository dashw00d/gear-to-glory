@tool
extends EditorPlugin

var docked_scene

func _enter_tree():
	docked_scene = preload("res://tools/item_editor.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, docked_scene)
	docked_scene.connect("save_item", Callable(self, "_on_save_item"), CONNECT_PERSIST)

func _exit_tree():
	remove_control_from_docks(docked_scene)
	docked_scene.free()

func _on_save_item(item_data: Dictionary, path: String):
	if !path:
		path = "res://resources/data/item_database_test.json"
	
	# Assuming 'item_data' contains an ID or unique name at the top level, like "test6" in your example.
	# Extracting the ID or name from 'item_data'
	var item_id = item_data.keys()[0]  # This assumes the first key in 'item_data' is the unique ID/name of the item.
	
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
	data[item_id] = item_data[item_id]  # Update or add the new item

	# Open the file again, this time for writing
	file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	if file:
		var json_string = JSON.new().stringify(data, "\t")  # Convert the updated dictionary back to a JSON string
		file.store_string(json_string)  # Write the JSON string to the file
		file.close()  # Close the file

