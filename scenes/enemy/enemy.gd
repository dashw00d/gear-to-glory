extends Node2D
class_name Enemy

@export var health: float = 100
@export var attack_speed: float = 50.0
@export var animator: AnimationPlayer
signal enemy_attack_hit
signal enemy_attack_finished
signal damage_taken(damage: int, location: Vector2)

func _ready():
	$AnimatedSprite2D.play()
	animator.animation_finished.connect(_on_animation_player_animation_finished)

func _process(delta):
	$AnimatedSprite2D/HealthBar.value = health

func get_stat(stat: String) -> float:
	match stat:
		"attack_speed":
			return attack_speed
		"health":
			return health
		_:
			return 0.0

func _attack_hit():
	emit_signal("enemy_attack_hit")

func _on_animation_player_animation_finished(anim_name):
	emit_signal("enemy_attack_finished")

func get_damage() -> float:
	var base_damage = 10.0  # @export var suggested for tuning
	var crit_chance = 10.0  # Adjustable via attributes
	return base_damage * (2.0 if randf() * 100.0 <= crit_chance else 1.0)

func apply_damage(damage: int):
	health = max(health - damage, 0)  # Clamp health to 0
	emit_signal("damage_taken", int(damage), %DamageTarget.global_position)
	if health <= 0:
		queue_free()
