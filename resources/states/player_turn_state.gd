class_name PlayerTurnState
extends State

@export var wait_time: float = 1.8
@export var actor: Node2D

var enemy: Node2D
var StateQueue
var actions

func _ready():
	actions = actor.get_actions()
	StateQueue = get_parent().get_node('SimultaneousActionState') as SimultaneousActionState
	if actor:
		actor.player_attack_finished.connect(attack_finished.bind())
	else:
		print("Actor is not set or does not exist")
	reconstruct_callables()

func Enter() -> void:
	StateQueue.queue_action(create_action(actions['attack']))
	
# Convert stringified actions to callable refs
func reconstruct_callables():
	for action_key in actions.keys():
		if "action_method" in actions[action_key]:
			actions[action_key]["action_method"] = Callable(self, actions[action_key]["action_method"])

func get_targets(action: Dictionary):
	var targets = []
	var group_name = "player" if action['target_type'] == 'player' else "enemy"
	var nodes_in_group = get_tree().get_nodes_in_group(group_name)

	for i in action['targets']:
		if i < nodes_in_group.size():
			targets.append(nodes_in_group[i])
	return targets
	
func choose_attack(action: Dictionary):
	# Here we can switch attack types based on an array of strings
	var attack_types = {
		'base_attack': BaseAttack,
	}
	
	# get player attack and multiply by attack type modifier
	var attack_damage = action['damage'] * actor.get_damage()
	attack_types[action['type']].new(get_targets(action), attack_damage, "basic_attack").execute(actor, self)
	
func start_attack(attack: BaseAttack):
	actor.get_node("AnimationPlayer").play(attack.animation_name)  # Play the attack animation
	
func create_action(action: Dictionary) -> Dictionary:
	return action

func attack_finished():
	StateQueue.queue_action(create_action(actions['attack']))

func Update(_delta: float) -> void:
	# actions['attack']['action'].call()
	Transitioned.emit(self, "SimultaneousActionState")

func Physics_Update(_delta: float) -> void:
	pass
