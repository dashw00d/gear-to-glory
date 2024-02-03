class_name CheckEndConditionsState
extends State

@export var player: Node2D

func Enter() -> void:
	#await get_tree().create_timer(.1).timeout 
	pass

func is_player_defeated() -> bool:
	return player.health <= 0

func are_enemies_defeated() -> bool:
	var enemies = get_tree().get_nodes_in_group('enemy')
	var total_enemy_health = sum_enemy_health(enemies)
	return total_enemy_health <= 0

func sum_enemy_health(enemies: Array) -> float:
	var total_health = 0.0
	for enemy in enemies:
		total_health += enemy.health
	return total_health
	
func Exit() -> void:
	pass
	
func Update(_delta: float) -> void:
	if is_player_defeated():
		Transitioned.emit(self, 'DefeatState')

	if are_enemies_defeated():
		Transitioned.emit(self, 'VictoryState')

	Transitioned.emit(self, "PlayerTurnState")
	
func Physics_Update(_delta: float) -> void:
	pass
