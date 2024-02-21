extends Node2D
@export var character_key = "player"
@onready var current_character = GameState.get_character_state(character_key)

var damage_number_2d_pool:Array[DamageNumber2D] = []

@onready var damage_number_2d_template = preload("res://scenes/ui/components/damage_number.tscn")
@onready var player = get_node("Player")
@onready var enemy = $Enemy

func _ready():
	player.damage_taken.connect(on_hit.bind())
	enemy.damage_taken.connect(on_hit.bind())
	# add equipment to character | Temp
	current_character.update_equipment_state()
	print(current_character.state["total_stats"]["attack"])
	$Player.get_node("ProgressBar").visible = true

func on_hit(damage, position):
	spawn_damage_number(damage, position[2])

func spawn_damage_number(value:float, pos: Vector2):
	var damage_number = get_damage_number()	
	var val = str(round(value))
	var height = 10
	var spread = 10
	add_child(damage_number, true)
	damage_number.set_values_and_animate(val, pos, height, spread)

func get_damage_number() -> DamageNumber2D:
	# get a damage number from the pool
	if damage_number_2d_pool.size() > 0:
		return damage_number_2d_pool.pop_front()
	
	# create a new damage number if the pool is empty
	else:
		var new_damage_number = damage_number_2d_template.instantiate()
		new_damage_number.tree_exiting.connect(
			func():damage_number_2d_pool.append(new_damage_number))
		return new_damage_number
