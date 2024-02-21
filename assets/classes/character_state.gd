extends Node
class_name CharacterState

signal equipment_updated

var data_path
var wearable_types = [
	"head",
	"chest",
	"hands",
	"feet",
	"weapon",
	"shield",
	"accessory",
]

var state = {}  # Declare the state dictionary
var stat_converter_script = preload("res://assets/classes/stat_conversion.gd")
var stat_converter

func _init():
	# Initialize the state dictionary with default values
	data_path = "res://assets/data/default_save.json"
	var loaded_data = Utils.load_json(data_path)
	state = (
		loaded_data
		if loaded_data
		else {
			"base_stats":
			{
				"attack": 5,
				"attack_speed": 5,
				"crit": 5,
				"health": 5,
				"defense": 5,
			},
			"total_stats": {},
			"level": 1,
			"skill_points": 99,
			"experience": 0,
			"equipment": {},
			"inventory": {},
			"item_ids": [],
			"active_abilities": [],
			"gear_modifiers": {},
		}
	)

	# Additional initialization as needed
	randomize()  # If you want to randomize any values or selections
	stat_converter = stat_converter_script.new(self)


func update_equipment_state():
	if calculate_final_stats():
		emit_signal("equipment_updated")
	Utils.save_json(state, "res://assets/data/default_save.json")


# Function to add an ability
func add_ability(ability):
	state["active_abilities"].append(ability)


func add_inventory(slot_id: int, item: Dictionary):
	var uuid = item.get("uuid")
	if uuid in state["item_ids"]:
		remove_item_by_uuid(uuid)  # Call a function to remove the item by its UUID.
	state["item_ids"].append(uuid)  # Add the UUID to the list if it's not already there.

	state["inventory"][slot_id] = item
	Utils.save_json(state, "res://assets/data/default_save.json")


func remove_inventory(slot_id: int):
	state["inventory"].erase(slot_id)
	Utils.save_json(state, "res://assets/data/default_save.json")


# Function to add gear with stat modifiers
func add_gear(gear_id, gear):
	var uuid = gear.get("uuid")
	if uuid in state["item_ids"]:
		remove_item_by_uuid(uuid)
	state["item_ids"].append(uuid)
	state["equipment"][gear_id] = gear
	state["gear_modifiers"][gear_id] = gear["base_stats"]
	print(state["gear_modifiers"])
	Utils.save_json(state, "res://assets/data/default_save.json")


# Function to remove gear
func remove_gear(gear_id):
	state["equipment"].erase(gear_id)
	state["gear_modifiers"].erase(gear_id)
	Utils.save_json(state, "res://assets/data/default_save.json")


func remove_item_by_uuid(uuid: String):
	# Check inventory for the item and remove it if found.
	for slot_id in state["inventory"].keys():
		var item = state["inventory"][slot_id]
		if item and item.get("uuid") == uuid:
			state["inventory"].erase(slot_id)
			# state["item_ids"].erase(uuid)
			return  # Item found and removed, exit the function.

	# Check equipment for the item and remove it if found.
	for gear_id in state["equipment"].keys():
		var gear = state["equipment"][gear_id]
		if gear and gear.get("uuid") == uuid:
			state["equipment"].erase(gear_id)
			state["gear_modifiers"].erase(gear_id)
			# state["item_ids"].erase(uuid)
			return  # Item found and removed, exit the function.


func reset_inventory():
	state["inventory"] = {}
	state["item_ids"] = []
	Utils.save_json(state, "res://assets/data/default_save.json")


# Function to calculate final stats in real-time
func calculate_final_stats():
	state["total_stats"] = state["base_stats"].duplicate()

	# Create temporary variables to store percentage modifiers
	var percent_modifiers = {
		"health_percent": 0,
		"crit_percent": 0,
		"attack_percent": 0,
		"defense_percent": 0,
	}

	# Apply abilities
	for ability in state["active_abilities"]:
		# Assume each ability has a function that modifies stats
		ability.apply(state["total_stats"])

	# First pass: Apply flat modifiers and accumulate percent modifiers
	for gear_id in state["gear_modifiers"]:
		var gear_stats = state["gear_modifiers"][gear_id]
		for gear_stat in gear_stats.keys():
			if gear_stat in percent_modifiers:
				stat_converter.modify_stat(gear_stat, gear_stats[gear_stat])

	return state["total_stats"]

'''
{ "feet": { "block_chance": 0.25, "mana": 20 }, "hands": { "aura_range": 0.4, "critical_hit_resistance": 0.6, "skill_cooldown_reduction": 0.65, "stun_chance": 4.5 }, "head": { "aura_range": 0.45, "chain_hit_chance": 0.4 }, "chest": { "projectile_count": 10, "defense_percent": 0.75 } }
'''
# Called when the node enters the scene tree for the first time.
func _ready():
	# calls the randomizer in the project
	randomize()
