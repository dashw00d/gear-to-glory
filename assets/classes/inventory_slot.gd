extends PanelContainer
class_name InventorySlot


@export var type: EquipmentManager.Type
@export var character_key = "player"
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
func update_equipment_state(type, data, action):

	var equipment_key = EquipmentManager.equipment_map[type]
	if equipment_key:
		if action == "add":
			current_character.add_gear(equipment_key, data)
		elif action == "remove":
			current_character.remove_gear(equipment_key)
		current_character.update_equipment_state()

# _drop_data function
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	print_debug(data.type)
	if data.get_parent() == self:
		return  # Do nothing if moving to the original slot

	# Remove existing item from CharacterState if any
	if data.get_parent().type != EquipmentManager.Type.MAIN:
		update_equipment_state(data.get_parent().type, null, "remove")
		
	# Account for equipment slot icon children
	var children: int = 0
	if type != EquipmentManager.Type.MAIN:
		children = 1
	
	# Swap item if one already in slot
	if get_child_count() > children:
		# this assumes child order stays the same, may need groups
		var item := get_child(children)
		remove_child(item)
		item.slot_type = data.get_parent().type
		data.get_parent().add_child(item)

	# Remove current item and add new one
	data.get_parent().remove_child(data)
	data.slot_type = type
	add_child(data)

	# Add new item to CharacterState
	if type != EquipmentManager.Type.MAIN and data.type == type:
		update_equipment_state(type, data, "add")




