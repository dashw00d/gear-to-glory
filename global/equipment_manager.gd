extends Node

@onready var item_data = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	if item_data.size() < 1:
		item_data = get_item_data(example_data, "res://assets/data/item_database_test.json")

enum Type {HEAD, CHEST, HANDS, FEET, WEAPON, SHIELD, ACCESSORY, MAIN}

var data_file_path = "res://assets/data/item_database_test.json"

@onready var example_data = {
	"sword_of_truth": {
		"texture_path": "res://assets/sprites/Item__01.png",
		'cosmetic_paths': [],
		"possible_stats": [
			{"name": "attack", "weight": 2},
			{"name": "defense", "weight": 1}
		],
		"type": Type.WEAPON
	},
	"helmet_of_valor": {
		"texture_path": "res://assets/sprites/gear/bone_armor_1/Helmet_i.png",
		'cosmetic_paths': ["res://assets/sprites/gear/bone_armor_1/Helmet.png"],
		"possible_stats": [
			{"name": "defense", "weight": 2},
			{"name": "health", "weight": 1}
		],
		"type": Type.HEAD
	},
	"amulet_of_luck": {
		"texture_path": "res://assets/sprites/Item__32.png",
		'cosmetic_paths': [],
		"possible_stats": [
			{"name": "crit_percent", "weight": 2},
			{"name": "health_percent", "weight": 1}
		],
		"type": Type.ACCESSORY
	}
}

func get_item_data(data: Dictionary, path: String) -> Dictionary:
	# Attempt to open the file for reading to check if it exists and is not empty
	var file = FileAccess.open(path, FileAccess.ModeFlags.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	if error == OK:
		return json.get_data()
	else:
		print_debug("Failed to parse JSON data from file.")
		# make_item_data(data, path)
	return data

func make_item_data(data, path: String) -> void:
	var file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	if file: 
		var json_string = JSON.new().stringify(data, "\t")
		file.store_string(json_string)
		file.close()

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

var rarity_multipliers = {
	Rarity.COMMON: 1.0,
	Rarity.UNCOMMON: 1.02,
	Rarity.RARE: 1.04,
	Rarity.EPIC: 1.08,
	Rarity.LEGENDARY: 1.1
}

func pick_weighted_random_stat(stats):
	var total_weight = 0
	for stat in stats:
		total_weight += stat["weight"]

	var rand_num = randf() * total_weight
	var weight_sum = 0

	for stat in stats:
		weight_sum += stat["weight"]
		if rand_num < weight_sum:
			return stat["name"]

	return null

var stat_generators = {
	"health": "generate_health",
	"health_percent": "generate_health_percent",
	"crit_percent": "generate_crit_percent",
	"attack": "generate_attack",
	"attack_percent": "generate_attack_percent",
	"defense": "generate_defense",
	"defense_percent": "generate_defense_percent",
	"attack_speed": "generate_attack_speed"
}

func generate_health(difficulty: int) -> int:
	return (randi() % 2 + 2) * difficulty

func generate_health_percent(difficulty: int) -> float:
	return int(round(((randf() * 0.1 + 0.05)) * difficulty) + 1)

func generate_crit_percent(difficulty: int) -> float:
	return int(round(((randf() * 0.1 + 0.05)) * difficulty) + 1)

func generate_attack(difficulty: int) -> int:
	return (randi() % 2 + 2) * difficulty

func generate_attack_percent(difficulty: int) -> float:
	return int(round(((randf() * 0.1 + 0.05)) * difficulty) + 1)

func generate_defense(difficulty: int) -> int:
	return (randi() % 2 + 2) * difficulty

func generate_defense_percent(difficulty: int) -> float:
	return int(round(((randf() * 0.1 + 0.05)) * difficulty) + 1)

func generate_attack_speed(difficulty: int) -> float:
	return int(round(((randf() * 0.1 + 0.05)) * difficulty) + 1)

func generate_stat_values(difficulty: int):
	var generated_stats = {}
	for stat_name in stat_generators.keys():
		generated_stats[stat_name] = call(stat_generators[stat_name], difficulty)
	return generated_stats
	
func generate_random_item(difficulty: int, rarity: int):
	
	var new_item = InventoryItem.new()
	
	# Choose an item type and get its possible stats
	var item_keys = item_data.keys()
	var random_index = randi() % item_keys.size()
	var item_type = item_keys[random_index]

	var selected_item_data = item_data[item_type]

	# Access item attributes
	var texture_path = selected_item_data["texture_path"]
	var cosmetic_paths = []

	cosmetic_paths += selected_item_data["cosmetic_paths"]

		
	var possible_stats = selected_item_data["possible_stats"]
	var item_type_enum = selected_item_data["type"]
	
	new_item.item_name = item_type
	new_item.type = item_type_enum

	# Initialize an empty dictionary to hold the selected stats with initial values
	var selected_stats = {}

	# The maximum number of different stats is determined by rarity
	var max_stat_types = rarity + 2  # For example

	# Choose stats
	for i in range(max_stat_types):
		var stat_name = pick_weighted_random_stat(possible_stats)
		
		if stat_name in stat_generators:
			# Dynamically call the stat-generating function
			var initial_value = call(stat_generators[stat_name], difficulty)
			
			# Initialize or update the stat in selected_stats
			if stat_name in selected_stats:
				selected_stats[stat_name] += initial_value  # Update
			else:
				selected_stats[stat_name] = initial_value  # Initialize

		# Apply rarity multiplier
		new_item.rarity_multiplier = rarity_multipliers[rarity]
		for stat in selected_stats.keys():
			selected_stats[stat] = int(selected_stats[stat] * new_item.rarity_multiplier)  # Apply rarity multiplier to each stat

			
	# Load a texture and assign it to new_item
	new_item.texture = load(texture_path)
	
	new_item.cosmetics = cosmetic_paths
	
	new_item.base_stats = selected_stats

	new_item.rarity = rarity

	return new_item
	
func get_random_rarity(difficulty):
	var rand_num = randf()
	
	var legendary_chance = 0.01  # 1% chance for a Legendary, doesn't change
	
	var epic_start = 0.01  # At difficulty 1
	var epic_end = 0.15  # At difficulty 100
	var epic_chance = epic_start + (epic_end - epic_start) * (min(difficulty, 100) / 100)
	
	var rare_start = 0.05  # At difficulty 1
	var rare_end = 0.3  # At difficulty 100
	var rare_chance = rare_start + (rare_end - rare_start) * (min(difficulty, 100) / 100)
	
	var uncommon_start = 0.2  # At difficulty 1
	var uncommon_end = 0.35  # At difficulty 100
	var uncommon_chance = uncommon_start + (uncommon_end - uncommon_start) * (min(difficulty, 100) / 100)
	
	# Whatever is left goes to COMMON
	var common_chance = 1 - (legendary_chance + epic_chance + rare_chance + uncommon_chance)
	
	if rand_num < legendary_chance:
		return Rarity.LEGENDARY
	elif rand_num < legendary_chance + epic_chance:
		return Rarity.EPIC
	elif rand_num < legendary_chance + epic_chance + rare_chance:
		return Rarity.RARE
	elif rand_num < legendary_chance + epic_chance + rare_chance + uncommon_chance:
		return Rarity.UNCOMMON
	else:
		return Rarity.COMMON

# Function to calculate the overall power of an item
func calculate_item_power(item):
	var power = 0
	
	# Assign weight for each stat type based on the average values generated by their functions
	var stat_weights = {
		"health": 1.0,  # average = 25
		"health_percent": 16.7,  # average = 1.5
		"crit_percent": 16.7,  # average = 1.5
		"attack": 1.0,  # average = 25
		"attack_percent": 16.7,  # average = 1.5
		"defense": 1.0,  # average = 25
		"defense_percent": 16.7,  # average = 1.5
		"attack_speed": 16.7  # average = 1.5
	}
	
	# Calculate power
	for stat in item.base_stats.keys():
		if stat in stat_weights:
			power += item.base_stats[stat] * stat_weights[stat]
	
	# Multiply by rarity multiplier
	power *= item.rarity_multiplier
	
	return int(round(power))
