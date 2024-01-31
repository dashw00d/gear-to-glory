class_name IdleState
extends State

func Enter() -> void:
	# randomize_time()
	await get_tree().create_timer(.1).timeout 
	Transitioned.emit(self, "EnemyTurnState")
	
func Exit() -> void:
	pass

