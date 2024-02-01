# Enable tool mode
@tool
extends EditorPlugin

var item_editor

func _enter_tree():
	item_editor = preload("res://tools/item_editor.tscn").instance()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, item_editor)
	item_editor.connect("save_item", self, "_on_save_item")

func _exit_tree():
	remove_control_from_docks(item_editor)
	item_editor.free()
	
func _on_save_item(item_data: Dictionary):
	var path = "res://resources/data/item_database_test.json"
	var json = JSON.new()
	var data: Dictionary = {}

	# Open the file for reading to check if it exists and to read its content
	var file = FileAccess.open(path, FileAccess.ModeFlags.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		# Parse the existing JSON content
		var result = json.parse(content)
		if result.error == OK:
			data = result.result

	# Update the dictionary with the new item data
	data[item_data["id"]] = item_data  # Assuming 'id' is part of your item_data

	# Open the file again, this time for writing
	file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	if file:
		var json_string = json.print(data)
		file.store_string(json_string)
		file.close()

