# Base Attack Class
class_name BaseAttack
extends Node2D

var targets: Array
var damage: int
var animation_name: String
var actor: Node2D

func _init(_targets, _damage, _animation_name):
	targets = _targets
	damage = _damage
	animation_name = _animation_name

func execute(_actor: Node2D, state: State):
	actor = _actor
	actor.attack_hit.connect(apply_damage.bind())
	actor.play_attack_animation(self)
	
func apply_damage():
	for target in targets:
		target.apply_damage(damage)

	# Disconnect the signal to prevent calling on a freed object
	if actor and is_instance_valid(actor):
		actor.attack_hit.disconnect(apply_damage.bind())
	queue_free()
