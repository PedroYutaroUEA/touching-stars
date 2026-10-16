class_name Player
extends CharacterBody2D

signal player_died

@onready var sprite: Sprite2D = $Visual
@onready var death_particles: CPUParticles2D = $DeathParticles
@onready var run_particles: CPUParticles2D = $RunParticles
@onready var land_particles: CPUParticles2D = $LandParticles

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
var _was_on_floor: bool = false

var is_on_ice: bool = false
var was_on_ice_when_jumped: bool = false

func _ready() -> void:
	_check_hazards_and_surface()

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
		sprite.flip_h = direction < 0.0
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
		if AudioManager:
			AudioManager.play_jump()

	# Variable Jump Height (release jump to fall faster)
	if Input.is_action_just_released("ui_up") and velocity.y < 0.0:
		velocity.y *= 0.5

	var prev_vy: float = velocity.y
	move_and_slide()
	_check_hazards_and_surface()
	_handle_movement_particles(prev_vy)
	_was_on_floor = is_on_floor()

func _get_player_world_rect() -> Rect2:
	# 16x16 player bounding box centered at (0, -8) relative to global_position
	return Rect2(global_position.x - 8.0, global_position.y - 16.0, 16.0, 16.0)

func _get_spike_world_rect(layer: TileMapLayer, cell: Vector2i) -> Rect2:
	var center: Vector2 = layer.to_global(layer.map_to_local(cell))
	var alt: int = layer.get_cell_alternative_tile(cell)
	var local_rect: Rect2
	match alt:
		1, 12288: # Downward spike (hanging from ceiling)
			local_rect = Rect2(-2.0, -3.0, 4.0, 7.0)
		20480: # Rightward spike (protruding right from left wall)
			local_rect = Rect2(-3.0, -2.0, 7.0, 4.0)
		2, 3, 24576: # Leftward spike (protruding left from right wall)
			local_rect = Rect2(-4.0, -2.0, 7.0, 4.0)
		_: # Upward spike (0, sitting on floor)
			local_rect = Rect2(-2.0, -4.0, 4.0, 7.0)
	return Rect2(center + local_rect.position, local_rect.size)

func _check_hazards_and_surface() -> void:
	var parent_layer: TileMapLayer = get_parent().get_node_or_null("TileMapLayer") as TileMapLayer

	# 1. Slide collision check for lethal tiles and hazard objects
	for i in range(get_slide_collision_count()):
		var col: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = col.get_collider()
		if collider and collider.is_in_group("hazards"):
			die()
			return

		if collider is TileMapLayer:
			var layer: TileMapLayer = collider as TileMapLayer
			for offset in [Vector2.ZERO, -col.get_normal() * 2.0]:
				var cell: Vector2i = layer.local_to_map(layer.to_local(col.get_position() + offset))
				var src_id: int = layer.get_cell_source_id(cell)
				if src_id == 5: # Lava: full cell hazard
					die()
					return
				elif src_id == 6: # Spike: verify contact point is actually on the spike hitbox
					var spike_rect: Rect2 = _get_spike_world_rect(layer, cell)
					if spike_rect.grow(2.0).has_point(col.get_position()):
						die()
						return

	# 2. Precise bounding-box intersection check against lethal tiles in TileMapLayer
	if parent_layer:
		var p_rect: Rect2 = _get_player_world_rect()
		var min_cell: Vector2i = parent_layer.local_to_map(parent_layer.to_local(p_rect.position))
		var max_cell: Vector2i = parent_layer.local_to_map(parent_layer.to_local(p_rect.end))

		for cx in range(min_cell.x, max_cell.x + 1):
			for cy in range(min_cell.y, max_cell.y + 1):
				var cell := Vector2i(cx, cy)
				var src_id: int = parent_layer.get_cell_source_id(cell)
				if src_id == 5: # Lava
					die()
					return
				elif src_id == 6: # Spike
					var spike_rect: Rect2 = _get_spike_world_rect(parent_layer, cell)
					if p_rect.intersects(spike_rect):
						die()
						return

	if always_ice:
		is_on_ice = true
		return

	if not is_on_floor():
		return

	is_on_ice = false

	# Check floor slide collisions for Ice (Source 7)
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

	# Direct probe check beneath player's feet
	if parent_layer:
		for offset_x in [0.0, -6.0, 6.0]:
			var probe_pos: Vector2 = global_position + Vector2(offset_x, 4.0)
			var map_pos: Vector2i = parent_layer.local_to_map(parent_layer.to_local(probe_pos))
			if parent_layer.get_cell_source_id(map_pos) == 7:
				is_on_ice = true
				return

func _handle_movement_particles(fall_speed: float) -> void:
	if not run_particles or not land_particles:
		return

	# 1. Landing particles (Geometry Dash impact burst on touching floor)
	if is_on_floor() and not _was_on_floor:
		if fall_speed > 60.0:
			if is_on_ice:
				land_particles.color = Color(0.65, 0.92, 1.0, 0.85)
			else:
				land_particles.color = Color(0.92, 0.98, 1.0, 0.8)
			land_particles.restart()
			land_particles.emitting = true

	# 2. Running particles (Geometry Dash trail puffs emitted behind feet)
	if is_on_floor() and abs(velocity.x) > 30.0:
		run_particles.emitting = true
		if velocity.x > 0.0:
			run_particles.direction = Vector2(-1.0, -0.3)
		else:
			run_particles.direction = Vector2(1.0, -0.3)

		if is_on_ice:
			run_particles.color = Color(0.65, 0.9, 1.0, 0.75) # Icy skid dust
		else:
			run_particles.color = Color(0.88, 0.95, 1.0, 0.6) # Standard GD dust puff
	else:
		run_particles.emitting = false

func die() -> void:
	if not is_physics_processing():
		return # Already dead

	player_died.emit()
	# Disable processing to avoid moving after death
	set_physics_process(false)

	# Visual feedback
	if run_particles:
		run_particles.emitting = false
	sprite.hide()
	death_particles.emitting = true

