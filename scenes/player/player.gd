extends Node2D
@onready var character_key = "player"
var current_character

@onready var total_health: float:
	set(new_total_health):
		total_health = new_total_health
		get_node("ProgressBar").max_value = new_total_health

@onready var health: float:
	set(new_health):
		health = new_health
		get_node("ProgressBar").value = new_health

@export var animator: AnimationPlayer
signal attack_hit
signal player_attack_finished
signal damage_taken(damage: int, location: Vector2)

@onready var paths = {
	"head": ["Skeleton2D/torso/Head/Head/Helmet"],
	"chest": ["Skeleton2D/torso/Torso/Armor", "Skeleton2D/torso/Torso/ShoulderL", "Skeleton2D/RShoulder"],
	"weapon": ["Skeleton2D/torso/RightArm/Bone2D/LarmR/Weapon"],
	"shield": [],
	"hands": ["Skeleton2D/LarmL/GreaveL", "Skeleton2D/torso/RightArm/Bone2D/LarmR/GreaveR"],
	"feet": ["Skeleton2D/torso/Legs/Bone2D/Bone2D/LlegR/BootR", "Skeleton2D/LlegL/BootL"],
	"accessory": [],
}

@onready var actions = {
	"attack": {
		"type": "base_attack",
		"target_type": "enemy",
		"targets": 1,
		"damage": 1,
		"action_method": "choose_attack",
		"transition": "EnemyTurnState"
	},
	"end_turn": {
		"type": "end_turn",
	}
}

func _ready():
	GameState.create_character("player")
	current_character = GameState.get_character_state(character_key)
	current_character.equipment_updated.connect(_on_equipment_updated.bind())
	# Ensure total_stats is calculated before accessing it
	current_character.calculate_final_stats()
	total_health = current_character.state["total_stats"]["health"]
	health = current_character.state["total_stats"]["health"]

func _process(delta):
	$ProgressBar.value = health

func play_attack_animation(attack: BaseAttack):
	animator.clear_queue()
	animator.speed_scale = 1.0 + (current_character.state["total_stats"]["attack_speed"] * 0.01)
	animator.play(attack.animation_name)

func _attack_hit() -> void:
	emit_signal("attack_hit")

func get_damage() -> float:
	var base_damage = current_character.state["total_stats"]["attack"]
	var crit_chance = current_character.state["total_stats"]["crit"]
	var random_roll = randf() * 100.0
	if random_roll <= crit_chance:
		return base_damage * 2.0
	else:
		return base_damage

func get_actions():
	return actions

func apply_damage(damage: int):
	var defense = current_character.state["total_stats"]["defense"]
	var reducible_damage = min(defense, damage)
	var reduced_damage = reducible_damage * 0.8
	var overflow_damage = max(damage - defense, 0)
	var total_damage_taken = (reducible_damage - reduced_damage) + overflow_damage
	health -= int(total_damage_taken)
	emit_signal("damage_taken", int(total_damage_taken), %DamageTarget.get_global_transform_with_canvas())
	if health <= 0:
		queue_free()
		GameState.change_scene("main")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "basic_attack":
		emit_signal("player_attack_finished")
		animator.speed_scale = 1
		animator.play("idle")

func _on_equipment_updated():
	for key in current_character.wearable_types:
		var equipment_paths = paths[key]
		if current_character.state["equipment"].has(key):
			var equipment = current_character.state["equipment"][key]
			if equipment:
				equipment = EquipmentManager.load_item(equipment)
				if "cosmetics" in equipment and equipment.cosmetics.size() == equipment_paths.size():
					for i in range(equipment_paths.size()):
						var resource_node = get_node_or_null(equipment_paths[i])
						if resource_node:
							var cosmetic_texture = load(equipment.cosmetics[i])
							resource_node.texture = cosmetic_texture
							resource_node.visible = true
				elif equipment.texture:
					for path in equipment_paths:
						var resource_node = get_node_or_null(path)
						if resource_node:
							var texture = equipment.texture.duplicate()
							resource_node.texture = texture
							resource_node.visible = true
		else:
			for path in equipment_paths:
				var resource_node = get_node(path)
				resource_node.visible = false
