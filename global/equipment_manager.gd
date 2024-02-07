extends Node

@onready var item_data = {}
@onready var stat_generators = Utils.load_json("res://assets/data/possible_stats.json")


# Called when the node enters the scene tree for the first time.
func _ready():
	if item_data.size() < 1:
		item_data = Utils.load_json("res://assets/data/item_database_test.json")


enum Type { HEAD, CHEST, HANDS, FEET, WEAPON, SHIELD, ACCESSORY, MAIN }


func generate_unique_id() -> String:
	var time = Time.get_ticks_msec()  # Get the current time in milliseconds since the engine started
	var random_number = randi()  # Generate a random integer
	var unique_id = str(time) + str(random_number)  # Combine them to form a unique ID
	return unique_id


var equipment_map = {
	Type.HEAD: "head",
	Type.CHEST: "chest",
	Type.HANDS: "hands",
	Type.FEET: "feet",
	Type.WEAPON: "weapon",
	Type.SHIELD: "shield",
	Type.ACCESSORY: "accessory",
	Type.MAIN: "main"
}

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

var rarity_multipliers = {
	Rarity.COMMON: 1.0,
	Rarity.UNCOMMON: 1.02,
	Rarity.RARE: 1.04,
	Rarity.EPIC: 1.08,
	Rarity.LEGENDARY: 1.1
}


func load_item(data: Dictionary) -> InventoryItem:
	var new_item = InventoryItem.new()
	new_item.set_meta("texture_path", data["texture_path"])

	# Assuming InventoryItem has properties or setters for these values
	new_item.type = data["type"]
	new_item.uuid = data["uuid"]
	new_item.item_name = data["item_name"]
	new_item.base_stats = data["base_stats"]
	new_item.rarity = data["rarity"]
	new_item.rarity_multiplier = data["rarity_multiplier"]
	new_item.cosmetics = data["cosmetics"]
	new_item.slot_type = data["slot_type"]
	new_item.item_power = data["item_power"]
	new_item.character_key = data["character_key"]
	new_item.texture = load(new_item.get_meta("texture_path"))

	return new_item


func pick_weighted_random_stat(specific_stats, all_stats):
	var combined_stats = specific_stats.duplicate()  # Ensure we don't modify the original list

	# Iterate through all possible stats and add them with a default weight if they're not already in specific_stats
	for stat_name in all_stats.keys():
		var found = false
		for specific_stat in specific_stats:
			if specific_stat["name"] == stat_name:
				found = true
				break
		if not found:
			combined_stats.append({"name": stat_name, "weight": 1})  # Add with default weight

	var total_weight = 0
	for stat in combined_stats:
		total_weight += stat["weight"]

	var rand_num = randf() * total_weight
	var weight_sum = 0

	# Select a stat based on weighted randomness
	for stat in combined_stats:
		weight_sum += stat["weight"]
		if rand_num < weight_sum:
			return stat["name"]

	return null


func generate_stat(stat_name: String, difficulty: int) -> Variant:
	var config = stat_generators[stat_name]
	var value = 0

	# Adjust the calculation based on the stat type
	if config["type"] == "int":
		# Calculate an integer value within the specified range
		value = randi() % (int(config["range"]) + 1) + int(config["base"])
		value *= max(difficulty, 1)  # Ensure difficulty is at least 1
		value = round(max(value, 1))
	elif config["type"] == "float":
		# Calculate a float value within the specified range
		value = randf() * config["range"] + config["base"]
		value *= max(difficulty, 1)  # Ensure difficulty is at least 1
		if "offset" in config:
			value += config["offset"]
		value = max(value, .05)

	return value


func generate_random_item(difficulty: int, rarity: int) -> InventoryItem:
	var new_item = InventoryItem.new()

	# Randomly select an item type from available data
	var item_keys = item_data.keys()
	var item_type = item_keys[randi() % item_keys.size()]
	var selected_item_data = item_data[item_type]

	# Set meta to avoid refcount bug
	new_item.set_meta("texture_path", selected_item_data["texture_path"])
	var texture_path = selected_item_data["texture_path"]

	# Assign basic attributes from selected item data
	new_item.item_name = item_type
	new_item.type = selected_item_data["type"]
	new_item.uuid = generate_unique_id()
	new_item.texture = load(new_item.get_meta("texture_path"))
	new_item.texture_path = texture_path
	new_item.cosmetics = selected_item_data["cosmetic_paths"].duplicate()  # Ensure a copy is made if necessary
	new_item.rarity = rarity
	new_item.rarity_multiplier = rarity_multipliers[rarity]

	# Initialize selected stats with potential stats and apply difficulty and rarity
	var max_stat_types = rarity + 2  # Determines the maximum number of stats based on rarity
	var selected_stats = {}
	for i in range(max_stat_types):
		var stat_name = pick_weighted_random_stat(
			selected_item_data["possible_stats"], stat_generators
		)
		if stat_name in stat_generators:
			var initial_value = generate_stat(stat_name, difficulty)
			selected_stats[stat_name] = (
				(selected_stats.get(stat_name, 0) + initial_value) * new_item.rarity_multiplier
			)
			selected_stats[stat_name] = snapped(selected_stats[stat_name], 0.05)  # Apply snapping to the final value

	new_item.base_stats = selected_stats
	new_item.item_power = calculate_item_power(new_item)

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
	var uncommon_chance = (
		uncommon_start + (uncommon_end - uncommon_start) * (min(difficulty, 100) / 100)
	)

	# Calculate common_chance for documentation purposes, but it's not used directly.
	# var common_chance = 1 - (legendary_chance + epic_chance + rare_chance + uncommon_chance)

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
		"health": 1.0,
		"health_percent": 3.0,
		"crit_percent": 4.0,
		"attack": 1.0,
		"attack_percent": 3.0,
		"accuracy": 2.5,
		"defense": 1.0,
		"defense_percent": 3.0,
		"attack_speed": 3.5,
		"poison_damage": 4.0,
		"stun_chance": 4.5,
		"fire_damage": 4.0,
		"fire_resistance": 3.5,
		"skill_damage_increase": 4.5,
		"ice_damage": 4.0,
		"ice_resistance": 3.5,
		"lightning_damage": 4.0,
		"lightning_resistance": 3.5,
		"wind_damage": 4.0,
		"wind_resistance": 3.5,
		"earth_damage": 4.0,
		"earth_resistance": 3.5,
		"magic_damage": 4.5,
		"magic_resistance": 4.0,
		"life_steal": 4.0,
		"mana_steal": 4.0,
		"mana": 2.0,
		"mana_regen": 3.0,
		"cooldown_reduction": 4.5,
		"dodge_chance": 4.0,
		"block_chance": 4.0,
		"damage_reflection": 4.5,
		"exp_bonus": 2.5,
		"critical_damage": 4.5,
		"bleed_chance": 4.0,
		"bleed_damage": 4.0,
		"healing_effectiveness": 3.5,
		"mana_cost_reduction": 3.5,
		"spell_penetration": 4.5,
		"physical_penetration": 4.5,
		"spell_vamp": 4.0,
		"bonus_armor": 2.5,
		"bonus_magic_resist": 2.5,
		"crowd_control_reduction": 4.5,
		"bonus_exp_per_kill": 2.5,
		"resurrection_chance": 5.0,  # Particularly impactful
		"aura_range": 3.0,
		"aura_effectiveness": 3.5,
		"damage_over_time_reduction": 4.0,
		"knockback_resistance": 3.0,
		"knockback_power": 3.5,
		"thorns_damage": 4.0,
		"resource_regeneration": 3.0,
		"projectile_speed": 3.0,
		"critical_hit_resistance": 4.0,
		"spell_cast_speed": 4.0,
		"area_of_effect_expansion": 3.5,
		"projectile_count": 4.5,
		"chain_hit_chance": 4.5,
		"status_effect_duration": 4.0,
		"status_effect_resistance": 4.0,
		"invulnerability_chance": 5.0,
		"life_on_hit": 4.0,
		"mana_on_hit": 4.0,
		"reflect_chance": 4.5,
		"loot_quality_increase": 3.0,
		"loot_quantity_increase": 3.0,
		"potion_effectiveness": 3.0,
		"crafting_quality": 2.0,
		"enchantment_success_rate": 3.5
	}

	# Calculate power
	for stat in item.base_stats.keys():
		if stat in stat_weights:
			power += item.base_stats[stat] * stat_weights[stat]

	# Multiply by rarity multiplier
	power *= item.rarity_multiplier

	return int(round(power))
