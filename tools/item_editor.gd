@tool
extends VBoxContainer
signal save_item(data: Dictionary)
var cosmetics_paths = []

@onready var stats_ref = get_node("StatsContainer/StatsDropdown").duplicate()
@onready var weight_ref = get_node ("StatsContainer/WeightSlider").duplicate()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_save_button_pressed():
	print('emitting')
	save_item.emit({"test":"test1"})

func _on_add_stats_button_up():
	var node = get_node("StatsContainer")
	var children = node.get_child_count()
	var stats_dropdown = node.get_child(children - 2)
	var weight_slider = node.get_child(children - 1)
	var stats_duplicate = stats_dropdown.duplicate()
	var weight_duplicate = weight_slider.duplicate()
	
	stats_duplicate.selected = -1
	weight_duplicate.value = 0
	node.add_child(stats_duplicate)
	node.add_child(weight_duplicate)

func _on_remove_stats_button_up():
	var node = get_node("StatsContainer")
	var children = node.get_child_count()
	
	var stats_dropdown = node.get_child(children - 2)
	var weight_slider = node.get_child(children - 1)
	if children > 2:
		node.remove_child(stats_dropdown)
		stats_dropdown.queue_free()  # Properly free the node
		
		node.remove_child(weight_slider)
		weight_slider.queue_free()  # Properly free the node
	else:
		stats_dropdown.selected = -1
		weight_slider.value = 0
		
		
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
	node.add_child(weight_ref.duplicate())
		
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
	%ItemTexture.texture = preload("res://resources/sprites/Item__44.png")

func _on_texture_file_file_selected(path):
	var texture = load(path)  # Load the texture at runtime
	if texture:  # Check if the texture was successfully loaded
		#$ItemTexture.texture = texture
		get_node("VBoxContainer/ItemTexture").texture = load(path)
	else:
		print("Failed to load texture from path:", path)
