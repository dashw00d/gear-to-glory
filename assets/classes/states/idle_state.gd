class_name IdleState
extends State

func _enter() -> void:
	Transitioned.emit(self, "DetermineTurnState")  # Use new turn order state
