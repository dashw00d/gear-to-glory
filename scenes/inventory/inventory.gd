extends Control
@onready var current_scene_difficulty = 5
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


## Adds new items to the first available slot.
func add_new_items(items: Array) -> void:
	for item in items:
		add_item_to_available_slot(item)


## Finds the first available slot in the inventory.
func get_available_slot() -> Dictionary:
	var grid_container = $PanelContainer/HBoxContainer/ScrollContainer/GridContainer
	for i in range(grid_container.get_child_count()):
		var slot = grid_container.get_child(i)
		if slot is InventorySlot and slot.get_child_count() == 0:
			return {"slot_id": i, "slot": slot}
	return {}


## Finds the first available slot in the inventory.
func get_slot_or_fail(slot_id) -> InventorySlot:
	var grid_container = $PanelContainer/HBoxContainer/ScrollContainer/GridContainer
	for slot in grid_container.get_children():
		if (
			int(slot.slot_id) == int(slot_id)
			and slot is InventorySlot
			and slot.get_child_count() == 0
		):
			return slot
	return


## Adds an item to the first available slot and updates character inventory.
func add_item_to_available_slot(item: InventoryItem) -> void:
	var open_slot_info = get_available_slot()
	if open_slot_info:
		var slot = open_slot_info["slot"]
		init_and_add_item(item, slot)
		current_character.add_inventory(open_slot_info["slot_id"], item.to_dict())


## Initializes and adds an item to a specific slot.
func init_and_add_item(item: InventoryItem, slot: InventorySlot) -> void:
	item.tooltip_text = "Item Info"  # Initialize tooltip
	item.size = slot.size
	item.slot_type = slot.type  # Use slot name or type as identifier
	item.make_background()
	slot.add_child(item)


## Repopulates the inventory UI from saved data.
func repopulate_inventory() -> void:
	var player_character = GameState.get_character_state("player")
	var equipment = player_character.state["equipment"]
	var inventory = player_character.state["inventory"]

	for key in equipment.keys():
		var item_data = equipment.get(key, null)
		if item_data:
			var item = EquipmentManager.load_item(item_data)  # Load or init InventoryItem
			var slot_path = get_slot_path(int(item_data["slot_type"]))
			if slot_path:
				var slot = get_node(slot_path)
				init_and_add_item(item, slot)

	for key in inventory.keys():
		var item_data = inventory.get(key, null)
		if item_data:
			var item = EquipmentManager.load_item(item_data)
			var slot = get_slot_or_fail(key)
			init_and_add_item(item, slot)


@onready var accessory_filled = false  # Track first accessory slot filling


## Determines the slot path based on the item type.
func get_slot_path(slot_type: int) -> String:
	var container_path = "PanelContainer/HBoxContainer/VBoxContainer2/"
	match slot_type:
		0:
			return container_path + "HBoxContainer4/HeadSlot"
		1:
			return container_path + "HBoxContainer4/ChestSlot"
		2:
			return container_path + "HBoxContainer/HandSlot"
		3:
			return container_path + "HBoxContainer/FeetSlot"
		4:
			return container_path + "HBoxContainer2/WeaponSlot"
		5:
			return container_path + "HBoxContainer2/ShieldSlot"
		6:
			return (
				container_path + "HBoxContainer3/AccessorySlot"
				if not accessory_filled
				else container_path + "HBoxContainer3/AccessorySlot2"
			)
	return ""


## Populate items from an action (like a button)
func add_demo_items() -> void:
	var random_item = EquipmentManager.generate_random_item(
		current_scene_difficulty, EquipmentManager.get_random_rarity(current_scene_difficulty)
	)
	var random_item2 = EquipmentManager.generate_random_item(
		current_scene_difficulty, EquipmentManager.get_random_rarity(current_scene_difficulty)
	)
	var random_item3 = EquipmentManager.generate_random_item(
		current_scene_difficulty, EquipmentManager.get_random_rarity(current_scene_difficulty)
	)
	add_new_items([random_item, random_item2, random_item3])


func _on_button_pressed() -> void:
	add_demo_items()
