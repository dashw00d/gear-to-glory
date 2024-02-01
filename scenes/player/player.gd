extends Node2D

@export var health: float = 100
@export var animator: AnimationPlayer
signal attack_hit
signal player_attack_finished

@onready var paths = {
	'head': ['Skeleton2D/torso/Head/Head/Helmet'],
	'chest': ['Skeleton2D/torso/Torso/Armor', 'Skeleton2D/torso/Torso/ShoulderL', 'Skeleton2D/RShoulder'],
	'weapon': ['Skeleton2D/torso/RightArm/Bone2D/LarmR/Weapon'],
	'hands': ['Skeleton2D/LarmL/GreaveL', 'Skeleton2D/torso/RightArm/Bone2D/LarmR/GreaveR'],
	'feet': ['Skeleton2D/torso/Legs/Bone2D/Bone2D/LlegR/BootR', 'Skeleton2D/LlegL/BootL'],  # Example for two feet
	'accessory': [],
}

@onready var actions = {
	'attack': {
		"type": "base_attack",
		'target_type': 'enemy',
		"targets": 1,
		"damage": 1,
		'action_method': "choose_attack",  # Store the method name as a string
		'transition': 'EnemyTurnState'
	},
	'end_turn': {
		'type': 'end_turn',
		# Other relevant info
	}
}

func _ready():
	CharacterState.equipment_updated.connect(_on_equipment_updated.bind())
	# animator.play("basic_attack")
	
func _process(delta):
	$ProgressBar.value = health

func play_attack_animation(attack: BaseAttack):
	animator.clear_queue()
	animator.speed_scale = 1.0 + (CharacterState.state['total_stats']['attack_speed'] * 0.01)
	animator.play(attack.animation_name)

func _attack_hit() -> void:
	emit_signal('attack_hit')

func get_damage():
	return CharacterState.state["total_stats"]["attack"]

func get_actions():
	return actions

func apply_damage(damage: int):
	# CharacterState.calculate_final_stats()
	# Example formula with diminishing returns
	var defense = CharacterState.state['total_stats']['defense']
	var reducible_damage = min(defense, damage)  # Damage that can be reduced
	var reduced_damage = reducible_damage * .8  # Apply reduction

	var overflow_damage = max(damage - defense, 0)  # Damage exceeding defense cap

	var total_damage_taken = (reducible_damage - reduced_damage) + overflow_damage

	health -= int(total_damage_taken)
	if health <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://scenes/main.tscn")
		
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "basic_attack":
		emit_signal('player_attack_finished')
		animator.speed_scale = 1
		animator.play("idle")
		
func _on_equipment_updated():
	for key in CharacterState.wearable_types:
		var equipment_paths = paths[key]
		if CharacterState.state['equipment'].has(key) and is_instance_valid(CharacterState.state['equipment'][key]):
			var equipment = CharacterState.state['equipment'][key].duplicate()
			if equipment:
				if 'cosmetics' in equipment and equipment.cosmetics.size() == equipment_paths.size():
					for i in range(equipment_paths.size()):
						var resource_node = get_node_or_null(equipment_paths[i])
						if resource_node:
							var cosmetic_texture = load(equipment.cosmetics[i]) # Load the cosmetic texture
							resource_node.texture = cosmetic_texture
							resource_node.visible = true

				elif equipment.texture:
					for path in equipment_paths:
						var resource_node = get_node_or_null(path)
						if resource_node:
							resource_node.texture = equipment.texture
							resource_node.visible = true
				
				print(CharacterState.state['equipment'][key]['base_stats'])
				# Add gear stats to player state
				# CharacterState.add_gear(key, CharacterState.state['equipment'][key]['base_stats'])
		else:
			for path in equipment_paths:
				var resource_node = get_node(path)
				resource_node.visible = false
				print('hi')

			# Remove gear stats from player state if item is unequipped
			if key in CharacterState.state['gear_modifiers']:
				pass
				# CharacterState.remove_gear(key)

