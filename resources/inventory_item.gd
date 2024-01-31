extends TextureRect
class_name InventoryItem

@export var type: EquipmentManager.Type
@export var item_name: String
@export var base_stats: Dictionary
@export var rarity: int
@export var rarity_multiplier: float
@export var cosmetics: Array
@export var slot_type: EquipmentManager.Type

var bg_color_rect: ColorRect

func make_background():
	# Initialize the ColorRect
	bg_color_rect = ColorRect.new()
	bg_color_rect.custom_minimum_size = self.size  # Set the size to match the TextureRect
	bg_color_rect.show_behind_parent = true
	bg_color_rect.color = get_rarity_color(rarity)  # Set the color based on rarity
	bg_color_rect.mouse_filter = MOUSE_FILTER_PASS # cant drag even though the z-index is -1
	self.add_child(bg_color_rect)  # Add it as a child of InventoryItem
	
	# Create and configure the border NinePatchRect
	var border = TextureRect.new()
	border.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	border.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	border.custom_minimum_size = self.size
	border.texture = preload("res://resources/sprites/border.png")  # Load your border texture
	#border.draw_center = false  # Don't draw the center of the nine patch
	border.z_index = self.z_index + 5  # Ensure it's drawn over the item
	self.add_child(border)

func get_rarity_color(rarity_int) -> Color:
	var rarity_color = Color(1, 1, 1)  # Default to white
	if rarity_int != null:
		match rarity_int:
			0:
				rarity_color = Color(0.3, 0.3, 0.3)  # Gray for Common
			1:
				rarity_color = Color.html("507d50")  # Adjusted Green for Uncommon
			2:
				rarity_color = Color.html("50789d")  # Adjusted Blue for Rare
			3:
				rarity_color = Color.html("7d5079")  # Adjusted Purple for Epic
			4:
				rarity_color = Color.html("d1b456")  # Adjusted Yellow for Legendary
	return rarity_color

	
func get_rarity_string(rarity_int) -> String:
	var rarity_string = "Unknown"
	if rarity_int != null:
		match rarity_int:
			0:
				rarity_string = "Common"
			1:
				rarity_string = "Uncommon"
			2:
				rarity_string = "Rare"
			3:
				rarity_string = "Epic"
			4:
				rarity_string = "Legendary"
			_:
				rarity_string = "Unknown"
	return rarity_string

func count_labels_in_container(container: Control) -> int:
	var label_count = -1
	for child in container.get_children():
		if child is Label:
			label_count += 1
	return label_count

func adjust_font_size_to_fit(label: Label, max_width: int, min_font_size: int):
	var text_width = label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_CENTER, -1, label.get_theme_font_size("font_size")).x + 75
	var font_size = 24
	while text_width > max_width and font_size > min_font_size:
		font_size -= 1  # Decrease font size
		label.add_theme_font_size_override("font_size", font_size)
		text_width = label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_CENTER, -1, label.get_theme_font_size("font_size")).x + 75
		
func _make_custom_tooltip(_tooltip: String) -> Object:
	var tooltip_instance = create_tooltip_instance()
	populate_tooltip(tooltip_instance)
	return tooltip_instance

func create_tooltip_instance() -> Object:
	return preload("res://scenes/ui/components/equipped_item_tooltip.tscn").instantiate()

func make_stat_labels(container: VBoxContainer, item_stats: Dictionary):
	for stat_name in item_stats.keys():
		var new_label = Label.new()
		new_label.text = str(stat_name) + ': ' + str(item_stats[stat_name])
		new_label.text = new_label.text.replace("_", " ")
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.uppercase = true
		container.add_child(new_label)
	
func populate_tooltip(tooltip_instance: Object):
	# Set up containers
	var stored_item_container = tooltip_instance.get_node("StoredItemContainer/Item")
	var equipped_item_container = tooltip_instance.get_node("EquippedItemContainer/Item")

	# Populate stored item details
	populate_item_details(stored_item_container, base_stats, item_name, rarity, texture)

	# Check and populate equipped item details if applicable
	if slot_type == EquipmentManager.Type.MAIN:
		process_equipped_item(tooltip_instance, equipped_item_container)

	# Adjust tooltip size based on content
	adjust_tooltip_size(tooltip_instance, stored_item_container, equipped_item_container)

	return tooltip_instance

func populate_item_details(container: Control, stats: Dictionary, name: String, rarity: int, texture: Texture):
	make_stat_labels(container, stats)
	print_debug(str(rarity) + ' --- ' + name)
	var label_node = container.get_node("ItemNameLabel")
	label_node.text = name.replace("_", " ")
	adjust_font_size_to_fit(label_node, 256, 12)
	container.get_node("RarityColorRect/PanelContainer/RarityLabel").text = get_rarity_string(rarity)
	container.get_node("RarityColorRect").color = get_rarity_color(rarity)
	container.get_node("RarityColorRect/TextureRect").texture = texture

func process_equipped_item(tooltip_instance: Object, container: Control):
	for key in CharacterState.state['equipment'].keys():
		var item = CharacterState.state['equipment'][key]
		if item == null:
			continue
		if int(item['type']) == int(type):
			tooltip_instance.get_node("EquippedItemContainer").visible = true
			populate_item_details(container, item['base_stats'], item['item_name'], item['rarity'], item['texture'])

func adjust_tooltip_size(tooltip_instance: Object, stored_container: Control, equipped_container: Control):
	var stored_item_label_count = count_labels_in_container(stored_container)
	var equipped_item_label_count = count_labels_in_container(equipped_container)
	tooltip_instance.get_node("StoredItemContainer").custom_minimum_size = Vector2(256, 296 + (stored_item_label_count * 28))
	tooltip_instance.get_node("EquippedItemContainer").custom_minimum_size = Vector2(256, 296 + (equipped_item_label_count * 28))
	var max_label_count = max(stored_item_label_count, equipped_item_label_count)
	tooltip_instance.custom_minimum_size = Vector2(548, 296 + (max_label_count * 28))

# Custom init function so that it doesn't error
func init(t: EquipmentManager.Type, i: Texture2D) -> void:
	type = t
	texture = i
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

# _at_position is not used because it doesn't matter where we click on
# the inventory item.
func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(make_drag_preview())
	return self

func make_drag_preview() -> TextureRect:
	var t := TextureRect.new()
	t.texture = texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size

	return t
