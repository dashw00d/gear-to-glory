extends PanelContainer
class_name InventorySlot


@export var type: EquipmentManager.Type
@export var character_key = "player"
@onready var slot_id = get_index()
var current_character = GameState.get_character_state(character_key)

# Custom init function so that it doesn't error
func init(t: EquipmentManager.Type, cms: Vector2) -> void:
	type = t
	custom_minimum_size = cms

# _at_position is not used because it doesn't matter where on the panel
# the item is dropped
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is InventoryItem:
		# Allow moving back to the original slot
		if data.get_parent() == self:
			return true

		# For MAIN type slots, allow any item type if the slot is empty
		# or even if it is not empty, allow swapping of any type
		if type == EquipmentManager.Type.MAIN:
			return true
		else:
			# For other slots, only allow the specified type
			return data.type == type

	return false

# Helper function for updating equipment state
func update_equipment_state(slot, data, action):
	var equipment_key = EquipmentManager.equipment_map[slot.type]
	if equipment_key:
		if action == "add":
			if slot.type == EquipmentManager.Type.MAIN:
				current_character.add_inventory(slot.slot_id, data.to_dict())
			else:
				current_character.add_gear(equipment_key, data.to_dict())
		elif action == "remove":
			if slot.type == EquipmentManager.Type.MAIN:
				current_character.remove_inventory(slot.slot_id)
			else:
				current_character.remove_gear(equipment_key)
		current_character.update_equipment_state()

# _drop_data function
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data.get_parent() == self:
		return  # Do nothing if moving to the original slot
	
	var selected_slot = data.get_parent()
	# Account for equipment slot icon children
	var children: int = 0
	if type != EquipmentManager.Type.MAIN:
		children = 1
	
	# Swap item if one already in slot
	if get_child_count() > children:
		# this assumes child order stays the same, may need groups
		var item := get_child(children)
		update_equipment_state(self, null, "remove")
		remove_child(item)
		
		# Change type and add to new slot
		item.slot_type = selected_slot.type
		selected_slot.add_child(item)
		update_equipment_state(selected_slot, item, "add")

	# Remove current item and add new one
	update_equipment_state(selected_slot, null, "remove")
	selected_slot.remove_child(data)
	
	# Update InventoryItem slot type
	data.slot_type = type
	add_child(data)
	update_equipment_state(self, data, "add")
