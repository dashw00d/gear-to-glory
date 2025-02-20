class_name PlayerTurnState
extends State

@export var actor: Node2D


func _enter() -> void:
	if not is_instance_valid(actor):
		Transitioned.emit(self, "CheckEndConditionsState")
		return
	var target = actor.get_target_enemy()
	if not is_instance_valid(target):
		Transitioned.emit(self, "CheckEndConditionsState")
		return
	actor.turn_completed.connect(_on_turn_completed, CONNECT_ONE_SHOT)
	actor.execute_attack(target)


func _on_turn_completed() -> void:
	Transitioned.emit(self, "CheckEndConditionsState")


func get_target_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy):
			return enemy
	return null
