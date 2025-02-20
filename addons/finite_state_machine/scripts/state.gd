@icon("res://addons/finite_state_machine/icons/state_machine_state.svg")
class_name State
extends Node

signal Transitioned


# Base Enter function that enforces frame delay before state logic
func Enter():
	# Wait one frame to ensure state machine has fully processed the transition
	await get_tree().process_frame
	# Call the actual state logic
	_enter()


# Virtual method for actual state logic
func _enter():
	pass


func Exit():
	pass


func Update(_delta: float):
	pass


func Physics_Update(_delta: float):
	pass
