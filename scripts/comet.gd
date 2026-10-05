class_name Comet
extends Area2D

signal comet_touched

@onready var sprite: Polygon2D = $Visual
@onready var idle_particles: CPUParticles2D = $IdleParticles
@onready var burst_particles: CPUParticles2D = $BurstParticles

var _has_been_touched: bool = false

func _ready() -> void:
	# Floating animation with Tween (senoidal)
	var tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var original_y = position.y
	tween.tween_property(self, "position:y", original_y - 15.0, 1.5)
	tween.tween_property(self, "position:y", original_y + 15.0, 1.5)
	
	# Connect to body_entered
	body_entered.connect(_on_body_entered)
	
	# Auto-connect to BaseLevel if possible
	var base_level = get_tree().current_scene
	if base_level and base_level is BaseLevel:
		comet_touched.connect(base_level.on_comet_touched)

func _on_body_entered(body: Node2D) -> void:
	if _has_been_touched:
		return
		
	if body is Player: # We assume player.gd is class_name Player
		_has_been_touched = true
		comet_touched.emit()
		
		# Visual feedback
		idle_particles.emitting = false
		burst_particles.emitting = true
		
		# Hide visual star gracefully
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
