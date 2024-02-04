extends Node

var settings = {}
var character_states = {}
@onready var CharacterState = load("res://assets/classes/character_state.gd")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	character_states["player"] = CharacterState.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_character_state(character_key):
	return character_states.get(character_key)
