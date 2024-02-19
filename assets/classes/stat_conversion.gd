extends Node
class_name stat_conversion
var character_state:
	set(_character_state):
		character_state = _character_state
		base_stats = character_state.state["base_stats"]
	get:
		return character_state

var base_stats

func _init(_character_state: CharacterState):
	character_state = _character_state

func call_function_by_name(function_name: String):
	if has_method(function_name):
		call(function_name)
	else:
		print("Function does not exist:", function_name)


func modify_stat(stat_name: String, value: float):
	if base_stats.has(stat_name):
		if GameState.stat_generators[stat_name]["Type"] == "float":
			var mod_name = stat_name
			if "_percent" in stat_name:
				mod_name.replace("_percent", "")
			base_stats[mod_name] *= 1 + value / 100
		else:
			base_stats[stat_name] += value
	else:
		print("Stat does not exist:", stat_name)


func health(value: float):
	if "health" in base_stats:
		base_stats["health"] += value
	else:
		base_stats["health"] = value



func health_percent(value: float):
	# If health does not exist, initialize it with a default value
	if "health" not in base_stats:
		base_stats["health"] = 5  # Default health value
	# Apply the percentage increase
	base_stats["health"] *= 1 + value / 100



func crit_percent(value: float):
	character_state.state["base_stats"]["crit"] *= 1 + value / 100


func attack(value: float):
	character_state.state["base_stats"]["attack"] += value


func attack_percent(value: float):
	character_state.state["base_stats"]["attack"] *= 1 + value / 100


func accuracy():
	pass


func defense():
	pass


func defense_percent():
	pass


func attack_speed():
	pass


func stun_chance():
	pass


func poison_damage():
	pass


func poison_resistance():
	pass


func fire_damage(target: Node2D, damage: float) -> float:
	var total_resistance := 0.0
	for gear in target.current_character.state["gear_modifiers"]:
		if gear.has_key("fire_resistance"):
			total_resistance += gear["fire_resistance"]
	return damage - (damage * total_resistance)


func fire_resistance():
	pass


func skill_damage_increase():
	pass


func ice_damage():
	pass


func ice_resistance():
	pass


func lightning_damage():
	pass


func lightning_resistance():
	pass


func wind_damage():
	pass


func wind_resistance():
	pass


func earth_damage():
	pass


func earth_resistance():
	pass


func magic_damage():
	pass


func magic_resistance():
	pass


func life_steal():
	pass


func mana_steal():
	pass


func mana():
	pass


func mana_regen():
	pass


func cooldown_reduction():
	pass


func dodge_chance():
	pass


func block_chance():
	pass


func damage_reflection():
	pass


func exp_bonus():
	pass


func critical_damage():
	pass


func bleed_chance():
	pass


func bleed_damage():
	pass


func healing_effectiveness():
	pass


func mana_cost_reduction():
	pass


func spell_penetration():
	pass


func physical_penetration():
	pass


func spell_vamp():
	pass


func bonus_armor():
	pass


func bonus_magic_resist():
	pass


func crowd_control_reduction():
	pass


func bonus_exp_per_kill():
	pass


func resurrection_chance():
	pass


func aura_range():
	pass


func aura_effectiveness():
	pass


func damage_over_time_reduction():
	pass


func knockback_resistance():
	pass


func knockback_power():
	pass


func thorns_damage():
	pass


func resource_regeneration():
	pass


func projectile_speed():
	pass


func critical_hit_resistance():
	pass


func spell_cast_speed():
	pass


func area_of_effect_expansion():
	pass


func projectile_count():
	pass


func chain_hit_chance():
	pass


func status_effect_duration():
	pass


func status_effect_resistance():
	pass


func invulnerability_chance():
	pass


func life_on_hit():
	pass


func mana_on_hit():
	pass


func reflect_chance():
	pass


func loot_quality_increase():
	pass


func loot_quantity_increase():
	pass


func potion_effectiveness():
	pass


func crafting_quality():
	pass


func enchantment_success_rate():
	pass
