class_name DetermineTurnState
extends State

@export var player: Node2D
var combatants_to_act: Array = []


func _enter() -> void:
	print("determin turn state")
	if combatants_to_act.is_empty():
		combatants_to_act = get_combatants().duplicate()
		combatants_to_act.sort_custom(func(a, b): return a.get_stat("attack_speed") > b.get_stat("attack_speed"))

	while not combatants_to_act.is_empty():
		var next_actor = combatants_to_act.pop_front()
		if is_instance_valid(next_actor) and next_actor.health > 0:
			if next_actor == player:
				get_parent().get_node("PlayerTurnState").actor = next_actor
				Transitioned.emit(self, "PlayerTurnState")
			else:
				get_parent().get_node("EnemyTurnState").actor = next_actor
				Transitioned.emit(self, "EnemyTurnState")
			return

	Transitioned.emit(self, "CheckEndConditionsState")


func get_combatants() -> Array:
	var combatants = get_tree().get_nodes_in_group("enemy")
	combatants.append(player)
	return combatants.filter(func(c): return is_instance_valid(c) and c.health > 0)


func get_stat(stat: String) -> float:
	# Placeholder: Implement this in Player/Enemy scripts
	return 0.0
