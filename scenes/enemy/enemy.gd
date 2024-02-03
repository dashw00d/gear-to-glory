extends Node2D
@export var health: float = 100
@export var animator: AnimationPlayer
signal enemy_attack_hit
signal enemy_attack_finished
signal damage_taken(damage:int, location:Vector2)

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
	emit_signal("damage_taken", int(damage), %DamageTarget.get_global_transform_with_canvas())
	if health <= 0:
		queue_free()
