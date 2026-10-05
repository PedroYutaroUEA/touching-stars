class_name Hazard
extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Duck typing: se o corpo tiver o método "die", ele morre ao tocar no hazard
	if body.has_method("die"):
		body.die()
