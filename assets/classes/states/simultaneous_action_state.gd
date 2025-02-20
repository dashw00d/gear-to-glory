class_name SimultaneousActionState
extends State

var action_queue: Array = []
var current_action_index: int = 0
var is_processing_action: bool = false


func queue_action(action: Dictionary) -> void:
	action_queue.append(action)


func Enter() -> void:
	current_action_index = 0
	is_processing_action = false


func Update(_delta: float) -> void:
	if not is_processing_action and current_action_index < action_queue.size():
		is_processing_action = true
		var action = action_queue[current_action_index]
		if "action_method" in action and action["action_method"] is Callable:
			action["action_method"].call(action)  # Call the Callable with the action
		else:
			print("Error: action_method is not a Callable or missing in ", action)
		action_completed()
	elif current_action_index >= action_queue.size():
		action_queue.clear()
		Transitioned.emit(self, "CheckEndConditionsState")


func action_completed():
	current_action_index += 1
	is_processing_action = false
