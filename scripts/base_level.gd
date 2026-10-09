class_name BaseLevel
extends Node2D

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var comet_point: Marker2D = $CometPoint
@onready var ui_layer: CanvasLayer = $UILayer
@onready var level_clear_label: Label = $UILayer/LevelClearLabel

var _player_instance: Player = null
var _comet_instance: Comet = null
var _level_cleared: bool = false
var _player_scene: PackedScene = preload("res://entities/player.tscn")
var _comet_scene: PackedScene = preload("res://entities/comet.tscn")

func _ready() -> void:
	level_clear_label.hide()
	_spawn_player()
	_spawn_comet()

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
	var current_path = get_tree().current_scene.scene_file_path
	# Ex: res://scenes/level_01.tscn -> res://scenes/level_02.tscn
	var regex = RegEx.new()
	regex.compile("level_(\\d+)")
	var match = regex.search(current_path)
	
	if match:
		var current_num = int(match.get_string(1))
		var next_num = current_num + 1
		# Format as 2 digits
		var next_name = "level_%02d" % next_num
		var next_path = current_path.replace("level_%02d" % current_num, next_name)
		
		if ResourceLoader.exists(next_path):
			get_tree().change_scene_to_file(next_path)
		else:
			print("Próximo nível não encontrado: ", next_path)
			level_clear_label.text = "YOU BEAT THE GAME!"
	else:
		print("Nome do nível atual não segue o padrão 'level_XX'")
