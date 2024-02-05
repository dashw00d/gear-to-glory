extends Node

var settings = {}
var character_states = {}
@onready var CharacterState = load("res://assets/classes/character_state.gd")

signal go_to_scene
	
# Called when the node enters the scene tree for the first time.
func _ready():
	character_states["player"] = CharacterState.new()
		
func change_scene(scene):
	emit_signal("go_to_scene", scene)
	
func get_character_state(character_key):
	return character_states.get(character_key)
