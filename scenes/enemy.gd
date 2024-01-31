extends Node2D
@export var health: float = 100
@export var animator: AnimationPlayer
signal enemy_attack_hit
signal enemy_attack_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AnimatedSprite2D/HealthBar.value = health

func _attack_hit():
	emit_signal("enemy_attack_hit")

func _on_animation_player_animation_finished(anim_name):
	emit_signal("enemy_attack_finished")

func apply_damage(damage: int):
	health -= damage
	if health <= 0:
		queue_free()
