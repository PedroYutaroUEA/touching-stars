class_name BaseLevel
extends Node2D

@export var next_level: PackedScene

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var ui_layer: CanvasLayer = $UILayer
@onready var level_clear_label: Label = $UILayer/LevelClearLabel

var _player_instance: Player = null
var _level_cleared: bool = false
var _player_scene: PackedScene = preload("res://entities/player.tscn")

func _ready() -> void:
	level_clear_label.hide()
	_spawn_player()

func _spawn_player() -> void:
	_player_instance = _player_scene.instantiate() as Player
	_player_instance.global_position = spawn_point.global_position
	# Connect death signal
	_player_instance.player_died.connect(_on_player_died)
	add_child(_player_instance)

func _process(_delta: float) -> void:
	# Manual instant restart
	if Input.is_action_just_pressed("restart_level") and not _level_cleared:
		_reload_level()
		
	# Proceed to next level if cleared
	if _level_cleared and Input.is_action_just_pressed("jump"):
		_go_to_next_level()

func _on_player_died() -> void:
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
		
	level_clear_label.show()

func _go_to_next_level() -> void:
	if next_level:
		get_tree().change_scene_to_packed(next_level)
	else:
		print("Fim de Jogo!")
