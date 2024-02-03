class_name EnemyTurnState
extends State

@export var wait_time: float = 1
@export var actor: Node2D
var player: Node2D
var StateQueue: State

var actions = {
	'attack': {
		"type": "base_attack",
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
	StateQueue = get_parent().get_node('SimultaneousActionState') as SimultaneousActionState
	actor.enemy_attack_hit.connect(attack_hit.bind())
	actor.enemy_attack_finished.connect(attack_finished.bind())
	
func Enter() -> void:
	if not is_instance_valid(actor):
		Transitioned.emit(self, "CheckEndConditionsState")
		return
	actor.animator.play("attack")
	player = get_tree().get_first_node_in_group("player")
	#Transitioned.emit(self, "CheckEndConditionsState")
	
func attack_hit():
	player.apply_damage(5)

func attack_finished():
	#Transitioned.emit(self, "CheckEndConditionsState")
	pass
	
func Exit() -> void:
	pass
	
func Update(_delta: float) -> void:
	Transitioned.emit(self, "SimultaneousActionState")
	
func Physics_Update(_delta: float) -> void:
	pass
