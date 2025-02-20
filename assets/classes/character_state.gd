extends Node
class_name CharacterState

signal equipment_updated

var data_path = "user://save.json"
var wearable_types = ["head", "chest", "hands", "feet", "weapon", "shield", "accessory"]

var state = {}
var stat_converter_script = preload("res://assets/classes/stat_conversion.gd")
var stat_converter


func _init():
	var loaded_data = Utils.load_encrypted_json(data_path)
	if loaded_data.is_empty():
		state = {
			"base_stats": {"attack": 5, "attack_speed": 5, "crit": 5, "health": 5, "defense": 5},
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
	else:
		state = loaded_data
		if not state.has("base_stats") or typeof(state["base_stats"]) != TYPE_DICTIONARY:
			state["base_stats"] = {"attack": 5, "attack_speed": 5, "crit": 5, "health": 5, "defense": 5}
		if not state.has("total_stats") or typeof(state["total_stats"]) != TYPE_DICTIONARY:
			state["total_stats"] = {}

	randomize()
	stat_converter = stat_converter_script.new(self)


func update_equipment_state():
	if calculate_final_stats():
		emit_signal("equipment_updated")
	Utils.save_json(state, data_path)  # Single save point


func add_ability(ability):
	state["active_abilities"].append(ability)


func add_inventory(slot_id: int, item: Dictionary):
	var uuid = item.get("uuid")
	if uuid in state["item_ids"]:
		remove_item_by_uuid(uuid)
	state["item_ids"].append(uuid)
	state["inventory"][slot_id] = item


func remove_inventory(slot_id: int):
	state["inventory"].erase(slot_id)


func add_gear(gear_id, gear):
	var uuid = gear.get("uuid")
	if uuid in state["item_ids"]:
		remove_item_by_uuid(uuid)
	state["item_ids"].append(uuid)
	state["equipment"][gear_id] = gear
	state["gear_modifiers"][gear_id] = gear["base_stats"]


func remove_gear(gear_id):
	state["equipment"].erase(gear_id)
	state["gear_modifiers"].erase(gear_id)


func remove_item_by_uuid(uuid: String):
	for slot_id in state["inventory"].keys():
		var item = state["inventory"][slot_id]
		if item and item.get("uuid") == uuid:
			state["inventory"].erase(slot_id)
			return
	for gear_id in state["equipment"].keys():
		var gear = state["equipment"][gear_id]
		if gear and gear.get("uuid") == uuid:
			state["equipment"].erase(gear_id)
			state["gear_modifiers"].erase(gear_id)
			return


func reset_inventory():
	state["inventory"] = {}
	state["item_ids"] = []


func calculate_final_stats():
	if not state.has("base_stats") or typeof(state["base_stats"]) != TYPE_DICTIONARY:
		state["base_stats"] = {
			"attack": 5,
			"attack_speed": 5,
			"crit": 5,
			"health": 5,
			"defense": 5,
		}

	state["total_stats"] = state["base_stats"].duplicate()
	var percent_modifiers = {
		"health_percent": 0,
		"crit_percent": 0,
		"attack_percent": 0,
		"defense_percent": 0,
	}

	for ability in state["active_abilities"]:
		ability.apply(state["total_stats"])

	for gear_id in state["gear_modifiers"]:
		var gear_stats = state["gear_modifiers"][gear_id]
		for gear_stat in gear_stats.keys():
			if gear_stat in percent_modifiers:
				percent_modifiers[gear_stat] += gear_stats[gear_stat]
			elif gear_stat in state["total_stats"]:
				state["total_stats"][gear_stat] += gear_stats[gear_stat]
			else:
				state["total_stats"][gear_stat] = gear_stats[gear_stat]

	for stat in percent_modifiers.keys():
		var base_stat = stat.replace("_percent", "")
		if base_stat in state["total_stats"]:
			state["total_stats"][base_stat] *= (1 + percent_modifiers[stat])

	return state["total_stats"]


func _ready():
	randomize()
