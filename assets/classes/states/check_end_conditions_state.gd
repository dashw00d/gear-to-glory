class_name CheckEndConditionsState
extends State

@export var player: Node2D


func _enter() -> void:
	print("Entering CheckEndConditionsState (self: ", self.name, ")")
	print("Current state name: ", get_parent().current_state.name)
	print("Player valid: ", is_instance_valid(player), " Health: ", player.health if is_instance_valid(player) else "N/A")

	var enemies = get_tree().get_nodes_in_group("enemy")
	print("Enemies: ", enemies.size())
	if not is_instance_valid(player) or player.health <= 0:
		print("Emitting defeatstate from ", self.name)
		Transitioned.emit(self, "defeatstate")
		return
	if enemies.all(func(e): return not is_instance_valid(e) or e.health <= 0):
		print("Emitting victorystate from ", self.name)
		Transitioned.emit(self, "victorystate")
		return
	print("Emitting determineturnstate from ", self.name)
	Transitioned.emit(self, "DetermineTurnState")
