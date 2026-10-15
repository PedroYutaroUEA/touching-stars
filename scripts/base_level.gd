class_name BaseLevel
extends Node2D

@export var level_gravity_multiplier: float = 1.0

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var comet_point: Marker2D = $CometPoint
@onready var ui_layer: CanvasLayer = $UILayer
@onready var level_clear_label: Label = $UILayer/LevelClearLabel

var _player_instance: Player = null
var _comet_instance: Comet = null
var _level_cleared: bool = false
var _all_levels_completed: bool = false
var _player_scene: PackedScene = preload("res://entities/player.tscn")
var _comet_scene: PackedScene = preload("res://entities/comet.tscn")
var _pause_menu_scene: PackedScene = preload("res://scenes/pause_menu.tscn")
var _pause_menu_instance: PauseMenu = null

func _ready() -> void:
	level_clear_label.hide()
	_spawn_player()
	_spawn_comet()
	_setup_pause_menu()

func _setup_pause_menu() -> void:
	if ui_layer and _pause_menu_scene:
		_pause_menu_instance = _pause_menu_scene.instantiate() as PauseMenu
		ui_layer.add_child(_pause_menu_instance)

func _spawn_comet() -> void:
	if comet_point:
		_comet_instance = _comet_scene.instantiate() as Comet
		_comet_instance.global_position = comet_point.global_position
		add_child(_comet_instance)
		
		# Auto-connect if not done already, comet.gd does it but just to be safe:
		if not _comet_instance.comet_touched.is_connected(on_comet_touched):
			_comet_instance.comet_touched.connect(on_comet_touched)

func _spawn_player() -> void:
	_player_instance = _player_scene.instantiate() as Player
	_player_instance.gravity_multiplier = level_gravity_multiplier
	_player_instance.global_position = spawn_point.global_position
	# Connect death signal
	_player_instance.player_died.connect(_on_player_died)
	add_child(_player_instance)

func _process(_delta: float) -> void:
	# Manual instant restart
	if Input.is_action_just_pressed("restart_level") and not _level_cleared:
		_reload_level()
		
	# Proceed to next level or return to level selector if cleared
	if _level_cleared and Input.is_action_just_pressed("jump"):
		_go_to_next_level()

func _on_player_died() -> void:
	if AudioManager:
		AudioManager.play_death()
	# Pausa curta (0.4s) antes de recarregar
	await get_tree().create_timer(0.4).timeout
	_reload_level()

func _reload_level() -> void:
	get_tree().reload_current_scene()

func on_comet_touched() -> void:
	if _level_cleared:
		return
	
	_level_cleared = true
	
	# Freeze player movement on clear
	if is_instance_valid(_player_instance):
		_player_instance.set_physics_process(false)
		
	if AudioManager:
		AudioManager.play_win()
		
	# Unlock next level in progression save
	var current_path: String = scene_file_path
	var regex := RegEx.new()
	regex.compile("level_(\\d+)")
	var match := regex.search(current_path)
	if match and GameManager:
		var current_num := int(match.get_string(1))
		GameManager.unlock_level(current_num + 1)
		
	level_clear_label.show()

func _go_to_next_level() -> void:
	if _all_levels_completed:
		get_tree().change_scene_to_file("res://scenes/level_select.tscn")
		return

	var current_path: String = scene_file_path
	var regex := RegEx.new()
	regex.compile("level_(\\d+)")
	var match := regex.search(current_path)
	
	if match:
		var current_num := int(match.get_string(1))
		var next_num := current_num + 1
		var next_name := "level_%02d" % next_num
		var next_path := current_path.replace("level_%02d" % current_num, next_name)
		
		if ResourceLoader.exists(next_path):
			get_tree().change_scene_to_file(next_path)
		else:
			level_clear_label.text = "PARABÉNS!\nVOCÊ COMPLETOU TODAS AS FASES DISPONÍVEIS!\nPressione PULO para voltar ao Seletor de Fases"
			_all_levels_completed = true
	else:
		get_tree().change_scene_to_file("res://scenes/level_select.tscn")
