class_name EnemyTurnState
extends State

@export var actor: Node2D  # Set by DetermineTurnState
var player: Node2D


func _enter() -> void:
	if not is_instance_valid(actor):
		Transitioned.emit(self, "CheckEndConditionsState")
		return
	player = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(player):
		Transitioned.emit(self, "CheckEndConditionsState")
		return
	actor.enemy_attack_hit.connect(_on_attack_hit, CONNECT_ONE_SHOT)
	actor.enemy_attack_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
	actor.animator.play("attack")


func _on_attack_hit():
	if is_instance_valid(player):
		var damage = actor.get_damage()
		player.apply_damage(damage)


func _on_attack_finished():
	Transitioned.emit(self, "CheckEndConditionsState")

# Remove Update, wait_time, and actions dictionary
