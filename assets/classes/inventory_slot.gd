extends PanelContainer
class_name InventorySlot

@export var type: EquipmentManager.Type
@export var character_key = "player"
@onready var slot_id = get_index()


func init(t: EquipmentManager.Type, cms: Vector2) -> void:
	type = t
	custom_minimum_size = cms


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is InventoryItem:
		if data.get_parent() == self:
			return true
		if type == EquipmentManager.Type.MAIN:
			return true
		else:
			return data.type == type
	return false


func update_equipment_state(slot, data, action):
	var equipment_key = EquipmentManager.equipment_map[slot.type]
	var current_character = GameState.get_character_state(character_key)
	if equipment_key:
		match action:
			"add":
				match slot.type:
					EquipmentManager.Type.MAIN:
						current_character.add_inventory(slot.slot_id, data.to_dict())
					_:
						current_character.add_gear(equipment_key, data.to_dict())
			"remove":
				match slot.type:
					EquipmentManager.Type.MAIN:
						current_character.remove_inventory(slot.slot_id)
					_:
						current_character.remove_gear(equipment_key)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data.get_parent() == self:
		return

	var selected_slot = data.get_parent()
	var current_character = GameState.get_character_state(character_key)
	var children_offset = 1 if type != EquipmentManager.Type.MAIN else 0

	# Perform all state changes in memory
	if get_child_count() > children_offset:
		var item = get_child(children_offset)
		update_equipment_state(self, null, "remove")  # Remove current item
		item.slot_type = selected_slot.type
		selected_slot.add_child(item)
		update_equipment_state(selected_slot, item, "add")  # Add to old slot
		remove_child(item)

	update_equipment_state(selected_slot, null, "remove")  # Remove dragged item from source
	selected_slot.remove_child(data)
	data.slot_type = type
	add_child(data)
	update_equipment_state(self, data, "add")  # Add dragged item to new slot

	# Single save after all changes
	current_character.update_equipment_state()
