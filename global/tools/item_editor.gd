@tool
extends VBoxContainer
signal save_item(data: Dictionary, save_path: String)
var cosmetics_paths = []
var texture_path

@onready var data_file_path = "res://assets/data/item_database_test.json":
	set(new_value):
		data_file_path = new_value
		get_node("GridContainer5/DataPath").text = new_value.replace("res://assets/data/", "")
	get:
		return "res://assets/data/" + get_node("GridContainer5/DataPath").text

@onready var stats_ref = get_node("StatsContainer/StatsGrid").duplicate()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_save_button_pressed():
	save_item.emit(get_all_values(), data_file_path)
	_on_clear_all_button_button_up()


func get_all_values() -> Dictionary:
	print(data_file_path)
	var item = get_node("GridContainer/ItemName").text
	return {
		item:
		{
			"cosmetic_paths": cosmetics_paths,
			"possible_stats": get_all_stats(),
			"texture_path": texture_path,
			"type": get_node("GridContainer4/ItemType").selected,
		}
	}


func get_all_stats() -> Array:
	var possible_stats = []
	for child in get_node("StatsContainer").get_children():
		var temp_stat = {}
		temp_stat["name"] = child.get_child(0).get_item_text(child.selected)
		temp_stat["weight"] = child.get_child(1).value
		possible_stats.append(temp_stat)

	return possible_stats


func _on_add_stats_button_up():
	var container = get_node("StatsContainer")
	var new_node = get_node("StatsContainer/StatsGrid").duplicate()
	new_node.get_child(0).selected = -1
	new_node.get_child(1).value = 0
	new_node.get_child(2).text = "1"
	container.add_child(new_node)


func _on_remove_stats_button_up():
	var node = get_node("StatsContainer")
	var child = node.get_child(-1)
	node.remove_child(child)
	child.queue_free()  # Properly free the node


func _on_select_cosmetics_button_up():
	%FileDialog.mode = FileDialog.FILE_MODE_OPEN_FILES  # Allow multiple file selection
	%FileDialog.filters = ["*.png ; PNG Images", "*.jpg ; JPG Images", "*.jpeg ; JPEG Images"]
	%FileDialog.popup_centered_ratio()


func _on_file_dialog_files_selected(paths):
	for path in paths:
		print("Selected file: ", path)
		cosmetics_paths.append(path)
	update_cosmetics_list()


func update_cosmetics_list():
	var item_list = %CosmeticsList
	item_list.clear()
	for path in cosmetics_paths:
		item_list.add_item(path)


func _on_clear_cosmetics_button_up():
	var item_list = %CosmeticsList
	item_list.clear()
	cosmetics_paths = []


func reset_stats():
	var node = get_node("StatsContainer")
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
	node.add_child(stats_ref.duplicate())


func _on_clear_all_button_button_up():
	_on_clear_cosmetics_button_up()
	_on_clear_texture_button_up()
	reset_stats()
	get_node("GridContainer/ItemName").text = ""
	get_node("GridContainer4/ItemType").selected = -1


func _on_add_texture_button_up():
	%TextureFile.mode = FileDialog.FILE_MODE_OPEN_FILE  # Allow multiple file selection
	%TextureFile.filters = ["*.png ; PNG Images", "*.jpg ; JPG Images", "*.jpeg ; JPEG Images"]
	%TextureFile.popup_centered_ratio()


func _on_clear_texture_button_up():
	%ItemTexture.texture = preload("res://assets/sprites/Item__44.png")
	%ItemTexture.self_modulate.a = .1
	texture_path = ""


func _on_texture_file_file_selected(path):
	texture_path = path
	var texture = load(path)  # Load the texture at runtime
	if texture:  # Check if the texture was successfully loaded
		#$ItemTexture.texture = texture
		var item_texture = get_node("VBoxContainer/ItemTexture")
		item_texture.texture = load(path)
		item_texture.self_modulate.a = 1
	else:
		print("Failed to load texture from path:", path)


func _on_select_data_button_button_up():
	%DataFile.mode = FileDialog.FILE_MODE_OPEN_FILE  # Allow multiple file selection
	%DataFile.filters = ["*.json ; JSON Files"]
	%DataFile.popup_centered_ratio()


func _on_data_file_file_selected(path):
	data_file_path = path


func _on_weight_slider_value_changed(value):
	for child in get_node("StatsContainer").get_children():
		child.get_child(2).text = str(int(child.get_child(1).value))


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
		# make_item_data(data, path)
	return {}


func _on_stats_dropdown_focus_entered() -> void:
	var possible_stats = load_json("res://assets/data/possible_stats.json")
	for item in possible_stats:
		$StatsContainer/StatsGrid/StatsDropdown.add_item(item)
