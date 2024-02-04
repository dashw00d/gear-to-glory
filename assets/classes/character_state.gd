extends Node
class_name CharacterState

signal equipment_updated

var wearable_types = [
	'head',
	'chest',
	'hands',
	'feet',
	'weapon',
	'shield',
	'accessory',
]

var state = {}  # Declare the state dictionary

func _init():
	# Initialize the state dictionary with default values
	state = {
		"base_stats": {
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
		"active_abilities": [],
		"gear_modifiers": {},
	}
	# Additional initialization as needed
	randomize()  # If you want to randomize any values or selections


func update_equipment_state():
	calculate_final_stats()
	emit_signal("equipment_updated")

# Function to add an ability
func add_ability(ability):
	state["active_abilities"].append(ability)

# Function to add gear with stat modifiers
func add_gear(gear_id, gear):
	state['equipment'][gear_id] = gear
	state["gear_modifiers"][gear_id] = gear['base_stats']

# Function to remove gear
func remove_gear(gear_id):
	state['equipment'][gear_id] = null
	state["gear_modifiers"].erase(gear_id)

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
				percent_modifiers[gear_stat] += gear_stats[gear_stat]
			elif gear_stat in state["total_stats"]:
				state["total_stats"][gear_stat] += gear_stats[gear_stat]

	# Second pass: Apply percentage modifiers
	for percent_stat in percent_modifiers.keys():
		var base_stat = percent_stat.replace("_percent", "")
		if base_stat in state["total_stats"]:
			state["total_stats"][base_stat] *= 1 + percent_modifiers[percent_stat] / 100.0

	# Signal that the total_stats have been updated (if needed)
	emit_signal("equipment_updated")

	return state["total_stats"]

# Called when the node enters the scene tree for the first time.
func _ready():
	# calls the randomizer in the project
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass