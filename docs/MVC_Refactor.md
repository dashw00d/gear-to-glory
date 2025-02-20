To refactor your player script into an MVC architecture, let's break down the script into its Model, View, and Controller components. This will help structure your game logic more clearly, separating the concerns of data management, user interface, and the intermediary logic that manipulates data based on user input.

### Model

The Model part should encapsulate all the data-related logic. For the player, this includes health, total health, equipment, stats (attack, defense, crit, etc.), and actions. The Model is responsible for storing the state and any manipulation of this state.

```javascript
gdCopy code# player_model.gd
class_name PlayerModel
signal equipment_updated
signal damage_taken(damage: int, location: Vector2)

var total_health: float setget set_total_health
var health: float setget set_health
var current_character
var actions = {
	"attack": {...},
	"end_turn": {...}
}

func _init(character_key: String):
	current_character = GameState.get_character_state(character_key)
	set_total_health(current_character.state["total_stats"]["health"])
	set_health(current_character.state["total_stats"]["health"])

func set_total_health(value):
	total_health = value
	emit_signal("equipment_updated") # Assuming this signal now covers stat updates too

func set_health(value):
	health = value
	if health <= 0:
		emit_signal("damage_taken", health, Vector2.ZERO) # Simplification for MVC
		# Handle death in the controller

func apply_damage(damage: int):
	# Damage calculation and application logic here
	emit_signal("damage_taken", calculated_damage, Vector2.ZERO)
```

### View

The View should handle all UI related logic. This includes displaying health on a progress bar and updating the character's equipment visuals.

```javascript
gdCopy code# player_view.gd
extends Node2D
onready var health_bar = $ProgressBar

func _ready():
	# Connect model signals to view update methods
	pass

func update_health(health, total_health):
	health_bar.max_value = total_health
	health_bar.value = health

func update_equipment(equipment):
	# Update the character's visual representation based on the current equipment
	pass
```

### Controller

The Controller acts upon both the model and the view. It processes inputs (like attacks and damage application) and updates the model accordingly. The controller also updates the view when the model changes.

```javascript
gdCopy code# player_controller.gd
extends Node2D
onready var model = PlayerModel.new("player")
onready var view = $PlayerView

func _ready():
	model.connect("equipment_updated", self, "_on_model_equipment_updated")
	model.connect("damage_taken", self, "_on_model_damage_taken")

func _on_model_equipment_updated():
	view.update_equipment(model.current_character.state["equipment"])

func _on_model_damage_taken(damage: int, location: Vector2):
	view.update_health(model.health, model.total_health)
	if model.health <= 0:
		GameState.change_scene("main")

func apply_damage(damage: int):
	model.apply_damage(damage)

# Further logic for processing attacks, end turns, etc.
```

This breakdown simplifies the original script and separates concerns into distinct parts of the MVC architecture. The Model manages the state, the View displays the state, and the Controller updates the state based on inputs and interactions. Further adjustments may be necessary to fit the MVC model perfectly, such as properly handling animations and signals between components.