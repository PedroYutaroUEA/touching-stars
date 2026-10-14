class_name Player
extends CharacterBody2D

signal player_died

@onready var sprite: Sprite2D = $Visual
@onready var death_particles: CPUParticles2D = $DeathParticles

@export_group("Movement")
@export var max_speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 2500.0

@export_group("Ice Physics")
@export var ice_acceleration: float = 350.0
@export var ice_friction: float = 80.0
@export var ice_air_acceleration: float = 250.0
@export var always_ice: bool = false

@export_group("Jumping")
@export var jump_velocity: float = -450.0
@export var gravity_multiplier: float = 1.0

@export_group("Assists")
@export var coyote_time: float = 0.08
@export var jump_buffer_time: float = 0.01

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

var is_on_ice: bool = false
var was_on_ice_when_jumped: bool = false

func _ready() -> void:
	_check_floor_surface()

func _physics_process(delta: float) -> void:
	# Determine acceleration and friction based on surface and air state
	var current_accel: float = acceleration
	var current_friction: float = friction

	if is_on_floor():
		if is_on_ice:
			current_accel = ice_acceleration
			current_friction = ice_friction
	else:
		if was_on_ice_when_jumped:
			current_accel = ice_air_acceleration
			current_friction = 0.0 # Preserve horizontal slide inertia in mid-air

	# Handle Horizontal Movement
	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * max_speed, current_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_friction * delta)

	# Handle Jump Buffer Timer
	if Input.is_action_just_pressed("ui_up"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta

	# Handle Coyote Timer
	if is_on_floor():
		_coyote_timer = coyote_time
		was_on_ice_when_jumped = is_on_ice
	else:
		_coyote_timer -= delta
		# Add gravity
		velocity.y += gravity * gravity_multiplier * delta

	# Handle Jump Action
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		was_on_ice_when_jumped = is_on_ice

	# Variable Jump Height (release jump to fall faster)
	if Input.is_action_just_released("ui_up") and velocity.y < 0.0:
		velocity.y *= 0.5

	move_and_slide()
	_check_floor_surface()

func _check_floor_surface() -> void:
	if always_ice:
		is_on_ice = true
		return

	if not is_on_floor():
		return

	is_on_ice = false

	# 1. Slide collision check (exact physics contact point)
	for i in range(get_slide_collision_count()):
		var col: KinematicCollision2D = get_slide_collision(i)
		if col.get_normal().y < -0.6:
			var collider: Object = col.get_collider()
			if collider is TileMapLayer:
				var layer: TileMapLayer = collider as TileMapLayer
				var hit_point: Vector2 = col.get_position() - col.get_normal() * 4.0
				var map_pos: Vector2i = layer.local_to_map(layer.to_local(hit_point))
				if layer.get_cell_source_id(map_pos) == 7: # Source 7 is Ice
					is_on_ice = true
					return

	# 2. Direct probe check beneath player's feet (center, left foot, right foot)
	var parent_layer: TileMapLayer = get_parent().get_node_or_null("TileMapLayer") as TileMapLayer
	if parent_layer:
		for offset_x in [0.0, -6.0, 6.0]:
			var probe_pos: Vector2 = global_position + Vector2(offset_x, 4.0)
			var map_pos: Vector2i = parent_layer.local_to_map(parent_layer.to_local(probe_pos))
			if parent_layer.get_cell_source_id(map_pos) == 7:
				is_on_ice = true
				return

func die() -> void:
	if not is_physics_processing():
		return # Already dead

	player_died.emit()
	# Disable processing to avoid moving after death
	set_physics_process(false)

	# Visual feedback
	sprite.hide()
	death_particles.emitting = true
