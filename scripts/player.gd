class_name Player
extends CharacterBody2D

signal player_died

@onready var sprite: Sprite2D = $Visual
@onready var death_particles: CPUParticles2D = $DeathParticles

@export_group("Movement")
@export var max_speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 2500.0

@export_group("Jumping")
@export var jump_velocity: float = -450.0
@export var gravity_multiplier: float = 1.0

@export_group("Assists")
@export var coyote_time: float = 0.08
@export var jump_buffer_time: float = 0.2

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# Handle Jump Buffer Timer
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta

	# Handle Coyote Timer
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer -= delta
		# Add gravity
		velocity.y += gravity * gravity_multiplier * delta

	# Handle Jump Action
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	# Variable Jump Height (release jump to fall faster)
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

	# Handle Horizontal Movement
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()

func die() -> void:
	if not is_physics_processing():
		return # Already dead
		
	player_died.emit()
	# Disable processing to avoid moving after death
	set_physics_process(false)
	
	# Visual feedback
	sprite.hide()
	death_particles.emitting = true
