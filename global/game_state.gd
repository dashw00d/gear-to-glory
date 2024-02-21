extends Node

var settings = {}
var character_states = {}
@onready var character_state = load("res://assets/classes/character_state.gd")

var stat_generators = Utils.load_json("res://assets/data/possible_stats.json")

signal go_to_scene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func create_character(name: String):
	character_states[name] = character_state.new()


func change_scene(scene):
	emit_signal("go_to_scene", scene)


func get_character_state(character_key):
	return character_states.get(character_key)
