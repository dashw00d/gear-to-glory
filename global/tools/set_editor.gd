@tool
extends VBoxContainer
signal save_item(data: Dictionary, save_path: String)
var cosmetics_paths = []
var texture_path

var image_names = {
	'Armor': {
		'Cosmetics': ['Armor', 'LShoulder', 'RShoulder'],
		'Icon': "Armor",
		'Type': 1,
		},
	'Helmet': {
		'Cosmetics': ['Helmet'],
		'Icon': "Helmet",
		'Type': 0,
		},
	'Boots': {
		'Cosmetics': ['RBoot', 'LBoot'],
		'Icon': "LBoot",
		'Type': 3,
		},
	'Gloves': {
		'Cosmetics': ['LGeave', 'RGreave'],
		'Icon': "RGreave",
		'Type': 2,
		}
}

func make_icon(item: String):
	var image_path = "%s/%s.png" % [set_folder_path, image_names[item]["Icon"]]
	var image = Image.new()
	var error = image.load(image_path)
	if error != OK:
		print("Failed to load image:", image_path)
		return

	# Calculate the scale factor to ensure the longest side does not exceed 96 pixels
	var scale_factor = 96.0 / max(image.get_width(), image.get_height())
	var new_width = int(image.get_width() * scale_factor)
	var new_height = int(image.get_height() * scale_factor)

	# Resize the image
	image.resize(new_width, new_height)

	# Attempt to save the final image
	var save_path = "%s/%s_i.png" % [set_folder_path, item]
	error = image.save_png(save_path)
	if error != OK:
		print("Failed to save the final image:", save_path, ", Error:", error)
	else:
		print("Icon saved successfully:", save_path)


@onready var data_file_path = "res://assets/data/item_database_test.json":
	set(new_value):
		data_file_path = new_value
		get_node("GridContainer5/DataPath").text = new_value.replace("res://assets/data/", "")
	get:
		return "res://assets/data/" + get_node("GridContainer5/DataPath").text

@onready var set_folder_path = "":
	set(new_value):
		set_folder_path = new_value
		get_node("GridContainer4/FolderPath").text = new_value
		
@onready var stats_ref = get_node("StatsContainer/StatsGrid").duplicate()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_save_button_pressed():
	save_item.emit(get_all_values(), data_file_path)
	_on_clear_all_button_button_up()

func get_all_values() -> Dictionary:
	var set_dict = {}
	var possible_stats = get_all_stats()
	for key in image_names:
		make_icon(key)
		set_dict[get_node("GridContainer/ItemName").text + '_' + key] = {
			"cosmetic_paths": get_cosmetic_paths(key),
			"possible_stats": possible_stats,
			"texture_path": set_folder_path + '/' + key + '_i.png',
			"type": image_names[key]["Type"],
		}
	return set_dict

func get_cosmetic_paths(item: String):
	var cosmetic_paths = []
	for cosmetic in image_names[item]['Cosmetics']:
		cosmetic_paths.append(set_folder_path + '/' + cosmetic + '.png')
	return cosmetic_paths
	
func get_all_stats() -> Array:
	var possible_stats = []
	for child in get_node("StatsContainer").get_children():
		var temp_stat = {}
		temp_stat['name'] = child.get_child(0).get_item_text(child.get_child(0).selected)
		temp_stat['weight'] = child.get_child(1).value
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

func reset_stats():
	var node = get_node("StatsContainer")
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
	node.add_child(stats_ref.duplicate())
		
func _on_clear_all_button_button_up():
	reset_stats()
	get_node("GridContainer/ItemName").text = ""

func _on_select_data_button_button_up():
	%DataFile.mode = FileDialog.FILE_MODE_OPEN_FILE  # Allow multiple file selection
	%DataFile.filters = ["*.json ; JSON Files"]
	%DataFile.popup_centered_ratio()

func _on_data_file_file_selected(path):
	data_file_path = path

func _on_weight_slider_value_changed(value):
	for child in get_node("StatsContainer").get_children():
		child.get_child(2).text = str(int(child.get_child(1).value))


func _on_set_file_dir_selected(dir):
	set_folder_path = dir


func _on_select_folder_button_button_up():
	%SetFile.popup_centered_ratio()
