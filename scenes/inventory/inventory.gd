extends Control
var current_scene_difficulty
@export var character_key = "player"
var current_character = GameState.get_character_state(character_key)

var slot_map = {
	EquipmentManager.Type.HEAD: "HBoxContainer4/HeadSlot",
	EquipmentManager.Type.CHEST: "HBoxContainer4/ChestSlot",
	EquipmentManager.Type.HANDS: "HBoxContainer/HandSlot",
	EquipmentManager.Type.FEET: "HBoxContainer/FeetSlot",
	EquipmentManager.Type.WEAPON: "HBoxContainer2/WeaponSlot",
	EquipmentManager.Type.SHIELD: "HBoxContainer2/ShieldSlot",
	EquipmentManager.Type.ACCESSORY: "HBoxContainer3/AccessorySlot"
}
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
			current_character.state['inventory'][i] = item_resource
			return

## Repopulate saved inventory from CharacterState inventory Dictionary
func repopulate_inventory() -> void:
	var player_character = GameState.get_character_state("player")
	var equipment = player_character.state['equipment']
	var inventory = player_character.state['inventory']

	var container_path = 'PanelContainer/HBoxContainer/VBoxContainer2/'
	var accessory_filled = false  # Keep track of whether the first accessory slot is filled

	for key in equipment.keys():
		var item = inventory[key]  # Assuming you meant to loop through equipment but use items from inventory
		var slot_path: String

		match item['slot_type']:
			EquipmentManager.Type.HEAD: slot_path = container_path + "HBoxContainer4/HeadSlot"
			EquipmentManager.Type.CHEST: slot_path = container_path + "HBoxContainer4/ChestSlot"
			EquipmentManager.Type.HANDS: slot_path = container_path + "HBoxContainer/HandSlot"
			EquipmentManager.Type.FEET: slot_path = container_path + "HBoxContainer/FeetSlot"
			EquipmentManager.Type.WEAPON: slot_path = container_path + "HBoxContainer2/WeaponSlot"
			EquipmentManager.Type.SHIELD: slot_path = container_path + "HBoxContainer2/ShieldSlot"
			EquipmentManager.Type.ACCESSORY:
				if accessory_filled:
					slot_path = container_path + "HBoxContainer3/AccessorySlot2"
				else:
					slot_path = container_path + "HBoxContainer3/AccessorySlot"
					accessory_filled = true  # Mark the first accessory slot as filled
			_: continue  # Skip if no match is found

		var slot = get_node(slot_path)
		init_item(item, slot)
	
	# Assuming the below loop is for populating items in a general inventory UI component
	for key in inventory.keys():
		var slot = $PanelContainer/HBoxContainer/ScrollContainer/GridContainer.get_child(key)
		var item_resource = inventory[key]
		init_item(item_resource, slot)
		slot.add_child(item_resource)
		# Removed the return statement to ensure all items are processed

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
	if current_character.state['inventory'].size() < 1:
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
