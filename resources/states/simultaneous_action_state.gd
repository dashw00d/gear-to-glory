class_name SimultaneousActionState
extends State

var action_queue = []
var current_action_index = 0
var is_processing_action = false

func Enter() -> void:
	# Populate action_queue with actions from player and enemies
	# Example: action_queue = [player_action, enemy1_action, enemy2_action, ...]
	print('hi')

func Exit() -> void:
	action_queue.clear()
	current_action_index = 0

func Update(delta: float) -> void:
	if not is_processing_action and current_action_index < action_queue.size():
		is_processing_action = true
		var action = action_queue[current_action_index]
		print_debug(action['type'])
		if 'action_method' in action:
			action['action_method'].call(action)  # Call the action
		action_completed()

func queue_action(action: Dictionary) -> void:
	action_queue.append(action)

func action_completed():
	is_processing_action = false
	current_action_index += 1
	if current_action_index >= action_queue.size():
		Transitioned.emit(self, action_queue[current_action_index - 1]['transition'])

func handle_interrupt():
	# Logic for handling interrupts
	pass
