class_name DefeatState
extends State


func Enter() -> void:
	await get_tree().process_frame
	print('you suck')
	
func Exit() -> void:
	pass
	
func Update(_delta: float) -> void:
	pass
	
func Physics_Update(_delta: float) -> void:
	pass
