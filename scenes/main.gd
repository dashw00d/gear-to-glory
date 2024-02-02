extends Control
var current_scene_difficulty

var battle_scene = preload("res://scenes/battle.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$MainScene/Player.animator.speed_scale = 0.5
	$MainScene/Player.animator.play("idle")
	CharacterState.update_equipment_state()
	$MainScene/Inventory.repopulate_inventory()

func _on_fight_button_pressed():
	# Instantiate the battle scene
	var battle_instance = battle_scene.instantiate()

	# Add the battle scene instance to the scene tree
	get_tree().root.add_child(battle_instance)

	# Optionally, to make the battle scene the current scene
	get_tree().current_scene = battle_instance

	# Hide or disable elements of the current scene
	hide_current_scene_elements()
	CharacterState.update_equipment_state()


func hide_current_scene_elements():
	$MainScene.visible = false
	$MainScene.set_process_mode(4)
	
func _on_big_test_button_pressed():
	# Re-enable the main scene
	#$MainScene.visible = true
	#$MainScene.set_process_mode(2)  # PROCESS_MODE_INHERIT

	# Remove the battle scene instance from the scene tree
	#if get_tree().current_scene != $MainScene:
		#get_tree().current_scene.queue_free()

	# Set the main scene as the current scene
	#get_tree().current_scene = $MainScene
	get_tree().change_scene_to_file("res://scenes/main.tscn")
