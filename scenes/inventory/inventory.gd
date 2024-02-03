extends Control
var current_scene_difficulty

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_demo_items()

## Iterate through list of InventoryItem's and send to slot adder
func add_new_items(items: Array) -> void:
	for item in items:
		add_item_to_available_slot(item)

## Iterate through inventory and add item to available slot
func add_item_to_available_slot(item_resource: InventoryItem) -> void:
	for i in range($PanelContainer/HBoxContainer/ScrollContainer/GridContainer.get_child_count()):
		var slot = $PanelContainer/HBoxContainer/ScrollContainer/GridContainer.get_child(i)
		if slot is InventorySlot and slot.get_child_count() == 0 and slot.type == EquipmentManager.Type.MAIN:
			# slot.modulate = Color(item_resource.get_rarity_color()) # needs to be on item
			# Finally, add item_resource to the slot.
			init_item(item_resource, slot)
			slot.add_child(item_resource)
			CharacterState.state['inventory'][i] = item_resource
			return

## Repopulate saved inventory from ChracterState inventory Dictionary
func repopulate_inventory() -> void:
	for key in CharacterState.state['inventory'].keys():
		var slot = $PanelContainer/HBoxContainer/ScrollContainer/GridContainer.get_child(key)
		var item_resource = CharacterState.state['inventory'][key]
		init_item(item_resource, slot)
		slot.add_child(item_resource)
		return

## Create InventoryItem Object
func init_item(item_resource, slot) -> void:
	item_resource.tooltip_text = 'Item Info' # initialize tooltip
	item_resource.size = slot.size
	# Make sure to set the type of slot into the item itself
	item_resource.slot_type = slot.type
	item_resource.make_background()
	item_resource._get_drag_data(item_resource.position)
	
## Populate items from an action (like a button)
func add_demo_items() -> void:
	var current_scene_difficulty = 5
	if CharacterState.state['inventory'].size() < 1:
		var random_item = EquipmentManager.generate_random_item(current_scene_difficulty, EquipmentManager.get_random_rarity(current_scene_difficulty))
		var random_item2 = EquipmentManager.generate_random_item(current_scene_difficulty, EquipmentManager.get_random_rarity(current_scene_difficulty))
		var random_item3 = EquipmentManager.generate_random_item(current_scene_difficulty, EquipmentManager.get_random_rarity(current_scene_difficulty))
		add_new_items([random_item, random_item2, random_item3])

## Populate some sample items on scene load
func init_demo_items() -> void:
	var current_scene_difficulty = 5
	var random_item = EquipmentManager.generate_random_item(current_scene_difficulty, EquipmentManager.get_random_rarity(current_scene_difficulty))
	var random_item2 = EquipmentManager.generate_random_item(current_scene_difficulty, EquipmentManager.get_random_rarity(current_scene_difficulty))
	var random_item3 = EquipmentManager.generate_random_item(current_scene_difficulty, EquipmentManager.get_random_rarity(current_scene_difficulty))
	add_new_items([random_item, random_item2, random_item3])
	
func _on_button_pressed() -> void:
	init_demo_items()
