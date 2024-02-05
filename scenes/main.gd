extends Control
var current_scene_difficulty

@onready var character_key = "player"
var battle_scene
var battle_instance
var current_character 

# Called when the node enters the scene tree for the first time.
func _ready():
	# GameState.connect("scene_changed", Callable(self, "_on_scene_changed"), CONNECT_PERSIST)
	GameState.go_to_scene.connect(switch_scenes.bind())
	battle_scene = preload("res://scenes/battle.tscn")
	current_character = GameState.get_character_state(character_key)
	$MainScene/Player.animator.speed_scale = 0.5
	$MainScene/Player.animator.play("idle")
	current_character.update_equipment_state()
	$MainScene/Inventory.repopulate_inventory()

func _on_fight_button_pressed():
	# Instantiate the battle scene
	battle_instance = battle_scene.instantiate()

	# Add the battle scene instance to the scene tree
	get_tree().root.add_child(battle_instance)

	# Optionally, to make the battle scene the current scene
	get_tree().current_scene = battle_instance

	# Hide or disable elements of the current scene
	hide_current_scene_elements()
	current_character.update_equipment_state()

func switch_scenes(scene):
	if scene == 'main':
		_switch_to_main()
	
func hide_current_scene_elements():
	$MainScene.visible = false
	$MainScene.process_mode = PROCESS_MODE_DISABLED
	
func _switch_to_main():
	battle_instance.queue_free()
	$MainScene.visible = true
	$MainScene.process_mode = PROCESS_MODE_INHERIT
	get_tree().current_scene = $MainScene
	$MainScene/Inventory.repopulate_inventory()

