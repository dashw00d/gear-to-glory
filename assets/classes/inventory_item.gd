extends TextureRect
class_name InventoryItem

@export var type: EquipmentManager.Type
@export var uuid: String
@export var item_name: String
@export var base_stats: Dictionary
@export var rarity: int
@export var rarity_multiplier: float
@export var cosmetics: Array
@export var slot_type: EquipmentManager.Type
@export var item_power: int
@export var character_key = "player"
var _texture_path = ""
var texture_path: String:
	set(new_value):
		_texture_path = new_value
	get:
		return _texture_path

var bg_color_rect: ColorRect
var current_character = GameState.get_character_state(character_key)


func to_dict() -> Dictionary:
	return {
		"type": type,
		"uuid": uuid,
		"item_name": item_name,
		"base_stats": base_stats,
		"rarity": rarity,
		"rarity_multiplier": rarity_multiplier,
		"cosmetics": cosmetics,
		"slot_type": slot_type,
		"item_power": item_power,
		"character_key": character_key,
		"texture_path": self.get_meta("texture_path")
	}


func make_background() -> void:
	# Configure the TextureRect properties
	self.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	self.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	# Initialize and configure the background ColorRect
	var bg_color_rect: ColorRect = ColorRect.new()
	configure_bg_color_rect(bg_color_rect)

	# Initialize and configure the border TextureRect
	var border: TextureRect = TextureRect.new()
	configure_border(border)


func configure_bg_color_rect(bg_color_rect: ColorRect) -> void:
	# Set the size to match the TextureRect and configure properties
	bg_color_rect.custom_minimum_size = self.size
	bg_color_rect.show_behind_parent = true
	bg_color_rect.color = get_rarity_color(rarity)  # Assuming `rarity` is defined elsewhere
	bg_color_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	self.add_child(bg_color_rect)


func configure_border(border: TextureRect) -> void:
	# Load and configure border properties
	border.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	border.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	border.custom_minimum_size = self.size
	border.texture = preload("res://assets/sprites/faded_border.png")
	# You can add a shader here if u want 2
	border.self_modulate.a = .5  # lighten it up if u want 2
	border.z_index = 10  # Position it above the item (relative to the parent's z_index)
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


func set_rarity_background(container: ColorRect, rarity: int) -> void:
	var rarity_color = get_rarity_color(rarity)
	container.color = rarity_color
	if rarity > 1:
		var shader_material = ShaderMaterial.new()
		shader_material.shader = preload("res://assets/shaders/nubula.gdshader")

		# Correctly adjust alpha and set shader parameters
		shader_material.set_shader_parameter(
			"CLOUD1_COL", Vector4(rarity_color.r, rarity_color.g, rarity_color.b, 0.4)
		)
		shader_material.set_shader_parameter(
			"CLOUD2_COL", Vector4(rarity_color.r, rarity_color.g, rarity_color.b, 0.2)
		)
		shader_material.set_shader_parameter(
			"CLOUD3_COL", Vector4(rarity_color.r, rarity_color.g, rarity_color.b, 0.8)
		)
		shader_material.set_shader_parameter(
			"CLOUD4_COL", Vector4(rarity_color.r, rarity_color.g, rarity_color.b, 1.0)
		)
		shader_material.set_shader_parameter(
			"SPACE", Vector4(rarity_color.r, rarity_color.g, rarity_color.b, 0.2)
		)

		container.material = shader_material


func count_labels_in_container(container: Control) -> int:
	var label_count = -1
	for child in container.get_children():
		if child is Label:
			label_count += 1
	return label_count


func adjust_font_size_to_fit(label: Label, max_width: int, min_font_size: int) -> void:
	var text_width = (
		(
			label
			. get_theme_font("font")
			. get_string_size(
				label.text, HORIZONTAL_ALIGNMENT_CENTER, -1, label.get_theme_font_size("font_size")
			)
			. x
		)
		+ 75
	)
	var font_size = 12
	while text_width > max_width and font_size > min_font_size:
		font_size -= 1  # Decrease font size
		label.add_theme_font_size_override("font_size", font_size)
		text_width = (
			(
				label
				. get_theme_font("font")
				. get_string_size(
					label.text,
					HORIZONTAL_ALIGNMENT_CENTER,
					-1,
					label.get_theme_font_size("font_size")
				)
				. x
			)
			+ 75
		)


## Start HERE
## --------------------
## --------------------
## --------------------
func _make_custom_tooltip(_tooltip: String) -> Object:
	var tooltip_instance = create_tooltip_instance()
	populate_tooltip(tooltip_instance)
	return tooltip_instance


func create_tooltip_instance() -> Object:
	return preload("res://scenes/inventory/equipped_item_tooltip.tscn").instantiate()


func populate_tooltip(tooltip_instance: Object) -> Object:
	# Set up containers
	var stored_item_container = tooltip_instance.get_node("StoredItemContainer/Item")
	var equipped_item_container = tooltip_instance.get_node("ComparedItemContainer/Item")
	var compare_item = null

	# Check and populate equipped item details if applicable
	if slot_type == EquipmentManager.Type.MAIN:
		compare_item = process_equipped_item(tooltip_instance, stored_item_container)
	else:
		stored_item_container.get_node("RarityColorRect/EquippedLabel").visible = true

	if compare_item:
		populate_item_details(equipped_item_container, self)
	else:
		populate_item_details(stored_item_container, self)

	populate_stat_labels(tooltip_instance, self, compare_item)
	# Adjust tooltip size based on content
	adjust_tooltip_size(
		tooltip_instance, stored_item_container, equipped_item_container, compare_item
	)

	return tooltip_instance


# Assuming Utils.safe_get_property safely retrieves a property or returns a default value if not found.


func populate_stat_labels(
	tooltip_instance: Object, stash_item: InventoryItem, equipped_item: InventoryItem = null
) -> void:
	# Containers setup
	var equipped_item_container := (
		tooltip_instance.get_node("StoredItemContainer/Item") as VBoxContainer
	)
	var stash_item_container := (
		tooltip_instance.get_node("ComparedItemContainer/Item") as VBoxContainer
	)
	# Always populate stats for stash_item
	var stash_stats = stash_item.base_stats
	var comparison_stats := equipped_item.base_stats if equipped_item else {}
	var equipped_power = equipped_item_container.get_node("RarityColorRect/ItemPower")
	var stored_power = stash_item_container.get_node("RarityColorRect/ItemPower")

	# Check and populate stats for equipped_item if present
	if equipped_item:
		var equipped_stats := equipped_item.base_stats if equipped_item else {}
		populate_container_with_stats(equipped_item_container, equipped_stats, stash_stats)
		populate_container_with_stats(stash_item_container, stash_stats, comparison_stats)

		equipped_power.text = str(equipped_item["item_power"])
		stored_power.text = str(stash_item["item_power"])

		if stash_item["item_power"] > equipped_item["item_power"]:
			stored_power.add_theme_color_override("font_color", Color.LIGHT_GREEN)
			equipped_power.add_theme_color_override("font_color", Color.INDIAN_RED)
		elif stash_item["item_power"] < equipped_item["item_power"]:
			stored_power.add_theme_color_override("font_color", Color.INDIAN_RED)
			equipped_power.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		elif stash_item["item_power"] == equipped_item["item_power"]:
			stored_power.add_theme_color_override("font_color", Color.LIGHT_CYAN)
			equipped_power.add_theme_color_override("font_color", Color.CYAN)
	else:
		populate_container_with_stats(equipped_item_container, stash_stats, comparison_stats)
		equipped_power.text = str(stash_item["item_power"])


func populate_container_with_stats(
	container: VBoxContainer, primary_stats, comparison_stats
) -> void:
	var labels_with_comparison = []
	var labels_without_comparison = []
	for stat_name in primary_stats.keys():
		var primary_stat_value = primary_stats[stat_name]
		var comparison_stat_value = comparison_stats.get(stat_name, null)
		var new_label = Label.new()
		new_label.text = (
			"%s: %s" % [stat_name.replace("_", " ").capitalize(), str(primary_stat_value)]
		)
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.add_theme_font_size_override("font_size", 12)
		adjust_font_size_to_fit(new_label, 240, 8)
		new_label.uppercase = true

		# Check for comparison and adjust font color accordingly
		if comparison_stat_value != null:
			if primary_stat_value > comparison_stat_value:
				new_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)  # Better
			elif primary_stat_value < comparison_stat_value:
				new_label.add_theme_color_override("font_color", Color.INDIAN_RED)  # Worse
			elif primary_stat_value == comparison_stat_value:
				new_label.add_theme_color_override("font_color", Color.CYAN)
			labels_with_comparison.append(new_label)
		else:
			labels_without_comparison.append(new_label)

	labels_with_comparison.sort()
	labels_without_comparison.sort()
	# First, add labels with comparison
	for label in labels_with_comparison:
		container.add_child(label)

	# Then, add labels without comparison
	for label in labels_without_comparison:
		container.add_child(label)
	var new_hrule = HSeparator.new()
	container.add_child(new_hrule)


func populate_item_details(container: Control, inventory_item) -> void:
	# print_debug(str(inventory_item['rarity']) + ' --- ' + inventory_item['item_name'])
	var label_node = container.get_node("ItemNameLabel")
	label_node.text = inventory_item["item_name"].replace("_", " ")
	adjust_font_size_to_fit(label_node, 240, 12)
	container.get_node("RarityColorRect/PanelContainer/RarityLabel").text = get_rarity_string(
		inventory_item["rarity"]
	)
	set_rarity_background(container.get_node("RarityColorRect"), inventory_item["rarity"])
	if inventory_item.texture:
		container.get_node("RarityColorRect/TextureRect").texture = inventory_item.texture
	else:
		container.get_node("RarityColorRect/TextureRect").texture = load(
			inventory_item.texture_path
		)
	container.get_node("RarityColorRect/TextureRect").stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	)


func process_equipped_item(tooltip_instance: Object, container: Control) -> InventoryItem:
	for key in current_character.state["equipment"].keys():
		var item = current_character.state["equipment"][key]
		if item:
			if int(item["type"]) == int(type):
				var loaded_item = EquipmentManager.load_item(item)
				tooltip_instance.get_node("ComparedItemContainer").visible = true
				container.get_node("RarityColorRect/EquippedLabel").visible = true
				populate_item_details(container, loaded_item)
				loaded_item.set_meta("result", true)
				return loaded_item
	return


## Scales the tooltip so it appears in the right place
func adjust_tooltip_size(
	tooltip_instance: Object, stored_container: Control, equipped_container: Control, compare_item
) -> void:
	var stored_item_label_count = count_labels_in_container(stored_container)
	var equipped_item_label_count = count_labels_in_container(equipped_container)
	var max_label_count = max(stored_item_label_count, equipped_item_label_count)
	# make sure the root container has room
	tooltip_instance.custom_minimum_size = Vector2(
		420 if compare_item else 200, 240 + (max_label_count * 30)
	)


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
	t.z_index = self.z_index + 10

	return t
