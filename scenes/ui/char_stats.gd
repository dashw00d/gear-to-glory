extends Control
signal stats_updated
var character_key = "player"
var current_character = GameState.get_character_state(character_key)

var stat_elements = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	current_character.equipment_updated.connect(_on_equipment_updated.bind())
	current_character.calculate_final_stats()
	refresh_skill_points()

	# Storing references to UI elements
	stat_elements = {
		"attack": %AttackTotal,
		"attack_speed": %AttackSpeedTotal,
		"crit": %CritTotal,
		"health": %HealthTotal,
		"defense": %DefenseTotal,
	}

	# initialize manually (to display initial data)
	_on_equipment_updated()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


## Updates total skill points
func refresh_skill_points() -> void:
	%SkillPoints.text = str(current_character.state["skill_points"])


## If skillpoint available, remove one
func remove_skill_point() -> bool:
	if current_character.state["skill_points"] < 1:
		return false

	current_character.state["skill_points"] -= 1
	refresh_skill_points()
	return true


func _on_equipment_updated() -> void:
	for stat_name in stat_elements.keys():
		stat_elements[stat_name].text = str(current_character.state["total_stats"][stat_name])


func _on_add_attack_pressed() -> void:
	if remove_skill_point():
		current_character.state["base_stats"]["attack"] += 5
		current_character.update_equipment_state()


func _on_add_attack_speed_pressed() -> void:
	if remove_skill_point():
		current_character.state["base_stats"]["attack_speed"] += 5
		current_character.update_equipment_state()


func _on_add_crit_pressed() -> void:
	if remove_skill_point():
		current_character.state["base_stats"]["crit"] += 5
		current_character.update_equipment_state()


func _on_add_health_pressed() -> void:
	if remove_skill_point():
		current_character.state["base_stats"]["health"] += 5
		current_character.update_equipment_state()


func _on_add_defense_pressed() -> void:
	if remove_skill_point():
		current_character.state["base_stats"]["defense"] += 5
		current_character.update_equipment_state()
