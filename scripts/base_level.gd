class_name BaseLevel
extends Node2D

@export_group("Physics")
@export var level_gravity_multiplier: float = 1.0

@export_group("Environment & Theme")
@export var level_theme_color: Color = Color(0.75, 0.85, 1.0, 1.0)
@export var has_lava_particles: bool = false
@export var has_ice_particles: bool = false

@export_group("Level Info")
@export var level_title: String = ""

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var comet_point: Marker2D = $CometPoint
@onready var ui_layer: CanvasLayer = $UILayer
@onready var level_clear_label: Label = $UILayer/LevelClearLabel
@onready var background_stars: CPUParticles2D = $BackgroundLayer/BackgroundStars
@onready var lava_particles: CPUParticles2D = $LavaParticles
@onready var ice_particles: CPUParticles2D = $IceParticles

var _player_instance: Player = null
var _comet_instance: Comet = null
var _level_cleared: bool = false
var _all_levels_completed: bool = false
var _player_scene: PackedScene = preload("res://entities/player.tscn")
var _comet_scene: PackedScene = preload("res://entities/comet.tscn")
var _pause_menu_scene: PackedScene = preload("res://scenes/pause_menu.tscn")
var _pause_menu_instance: PauseMenu = null
var _level_complete_modal_scene: PackedScene = preload("res://scenes/level_complete_modal.tscn")
var _level_complete_modal_instance: LevelCompleteModal = null

var _level_num: int = 1
var _run_time: float = 0.0
var _jumps_count: int = 0

func _ready() -> void:
	level_clear_label.hide()
	
	# Determine level number from scene path and initialize session
	var regex := RegEx.new()
	regex.compile("level_(\\d+)")
	var match := regex.search(scene_file_path)
	if match:
		_level_num = int(match.get_string(1))
	if GameManager:
		GameManager.start_level_session(_level_num)

	_spawn_player()
	_spawn_comet()
	_setup_pause_menu()
	_setup_level_complete_modal()
	call_deferred("_setup_environment_particles")

func _setup_environment_particles() -> void:
	if background_stars:
		background_stars.modulate = level_theme_color

	var layer: TileMapLayer = get_node_or_null("TileMapLayer") as TileMapLayer
	var found_lava: bool = has_lava_particles
	var found_ice: bool = has_ice_particles

	if layer and (not found_lava or not found_ice):
		for cell in layer.get_used_cells():
			var src: int = layer.get_cell_source_id(cell)
			if src == 5: # Lava
				found_lava = true
			elif src == 7: # Ice
				found_ice = true
			if found_lava and found_ice:
				break

	if lava_particles:
		lava_particles.emitting = found_lava
		lava_particles.visible = found_lava

	if ice_particles:
		ice_particles.emitting = found_ice
		ice_particles.visible = found_ice

func _setup_pause_menu() -> void:
	if ui_layer and _pause_menu_scene:
		_pause_menu_instance = _pause_menu_scene.instantiate() as PauseMenu
		ui_layer.add_child(_pause_menu_instance)

func _setup_level_complete_modal() -> void:
	if ui_layer and _level_complete_modal_scene:
		_level_complete_modal_instance = _level_complete_modal_scene.instantiate() as LevelCompleteModal
		_level_complete_modal_instance.restart_requested.connect(_reload_level)
		_level_complete_modal_instance.next_level_requested.connect(_go_to_next_level)
		_level_complete_modal_instance.level_select_requested.connect(_go_to_level_select)
		ui_layer.add_child(_level_complete_modal_instance)

func _spawn_comet() -> void:
	if comet_point:
		_comet_instance = _comet_scene.instantiate() as Comet
		_comet_instance.global_position = comet_point.global_position
		add_child(_comet_instance)
		
		if not _comet_instance.comet_touched.is_connected(on_comet_touched):
			_comet_instance.comet_touched.connect(on_comet_touched)

func _spawn_player() -> void:
	_player_instance = _player_scene.instantiate() as Player
	_player_instance.gravity_multiplier = level_gravity_multiplier
	_player_instance.global_position = spawn_point.global_position
	_player_instance.player_died.connect(_on_player_died)
	_player_instance.player_jumped.connect(_on_player_jumped)
	add_child(_player_instance)

func _on_player_jumped() -> void:
	if not _level_cleared:
		_jumps_count += 1

func _process(delta: float) -> void:
	if not _level_cleared:
		_run_time += delta
		# Manual instant restart
		if Input.is_action_just_pressed("restart_level"):
			if GameManager:
				GameManager.register_death_or_restart()
			_reload_level()

func _on_player_died() -> void:
	if GameManager:
		GameManager.register_death_or_restart()
	if AudioManager:
		AudioManager.play_death()
	# Short pause (0.4s) before reloading
	await get_tree().create_timer(0.4).timeout
	_reload_level()

func _reload_level() -> void:
	get_tree().reload_current_scene()

func on_comet_touched() -> void:
	if _level_cleared:
		return
	
	_level_cleared = true
	
	# Freeze player movement on clear (physics disabled, scene continues running)
	if is_instance_valid(_player_instance):
		_player_instance.set_physics_process(false)
		
	if AudioManager:
		AudioManager.play_win()
		
	# Record stats and best attempts in GameManager
	var record_info := {}
	if GameManager:
		record_info = GameManager.record_completion(_level_num)
	
	var attempts: int = record_info.get("attempts", 1)
	var best_attempts: int = record_info.get("best_attempts", attempts)
	var is_new_best: bool = record_info.get("is_new_best", false)

	var next_num := _level_num + 1
	var next_path := "res://scenes/level_%02d.tscn" % next_num
	var has_next: bool = ResourceLoader.exists(next_path)

	if _level_complete_modal_instance:
		_level_complete_modal_instance.setup(
			_level_num,
			_get_level_title(),
			_run_time,
			attempts,
			best_attempts,
			is_new_best,
			_jumps_count,
			has_next
		)

func _get_level_title() -> String:
	if not level_title.is_empty():
		return level_title
	match _level_num:
		1: return "The floor is lava"
		2: return "Moon gravity"
		3: return "Moving platforms"
		4: return "Floor is ice"
		5: return "Spikes everywhere"
		6: return "Saturn gravity"
		_: return "Level %02d" % _level_num

func _go_to_level_select() -> void:
	if GameManager:
		GameManager.reset_session_attempts()
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _go_to_next_level() -> void:
	var next_num := _level_num + 1
	var next_path := "res://scenes/level_%02d.tscn" % next_num
	
	if ResourceLoader.exists(next_path):
		get_tree().change_scene_to_file(next_path)
	else:
		_go_to_level_select()

