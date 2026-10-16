class_name LevelSelect
extends Control

@onready var path_line: Line2D = %PathLine
@onready var nodes_container: Control = %NodesContainer
@onready var back_btn: Button = %BackButton
@onready var reset_btn: Button = %ResetButton

const LEVEL_DATA = [
	{"num": 1, "title": "01: Lava Floor", "pos": Vector2(200, 520)},
	{"num": 2, "title": "02: Moon Gravity", "pos": Vector2(370, 420)},
	{"num": 3, "title": "03: Moving Blocks", "pos": Vector2(540, 500)},
	{"num": 4, "title": "04: Ice Floor", "pos": Vector2(710, 360)},
	{"num": 5, "title": "05: Spikes Everywhere", "pos": Vector2(880, 440)},
	{"num": 6, "title": "06: Saturn Gravity", "pos": Vector2(1050, 300)},
]

func _ready() -> void:
	if AudioManager:
		AudioManager.play_menu_music()

	back_btn.pressed.connect(_on_back_pressed)
	reset_btn.pressed.connect(_on_reset_pressed)
	
	if GameManager:
		GameManager.progress_updated.connect(_on_progress_updated)
		
	_build_path_and_nodes()

func _build_path_and_nodes() -> void:
	# Clear old points
	path_line.clear_points()
	for child in nodes_container.get_children():
		child.queue_free()

	var max_unlocked: int = 1
	if GameManager:
		max_unlocked = GameManager.max_unlocked_level

	# Build line points
	for data in LEVEL_DATA:
		path_line.add_point(data["pos"])

	# Create interactive level node buttons
	for data in LEVEL_DATA:
		var lvl_num: int = data["num"]
		var is_unlocked: bool = lvl_num <= max_unlocked
		var is_current: bool = lvl_num == max_unlocked
		
		var node_control := Control.new()
		node_control.position = data["pos"]
		nodes_container.add_child(node_control)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(68, 68)
		btn.position = Vector2(-34, -34) # Center on coordinate
		btn.focus_mode = Control.FOCUS_ALL
		
		# Styling node button
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(34) # Perfect circular badge
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		
		if is_unlocked:
			if is_current:
				# Highlight active/furthest level
				style.bg_color = Color(0.18, 0.55, 0.9, 0.95)
				style.border_color = Color(1.0, 0.85, 0.3, 1.0)
				btn.text = str(lvl_num)
			else:
				# Completed level
				style.bg_color = Color(0.12, 0.38, 0.65, 0.9)
				style.border_color = Color(0.4, 0.85, 1.0, 0.8)
				btn.text = str(lvl_num) + " ★"
			btn.disabled = false
			btn.pressed.connect(func(): _load_level(lvl_num))
			btn.mouse_entered.connect(_on_node_hover)
		else:
			# Locked level
			style.bg_color = Color(0.08, 0.1, 0.16, 0.7)
			style.border_color = Color(0.25, 0.3, 0.45, 0.4)
			btn.text = "🔒"
			btn.disabled = true
			
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("disabled", style)
		btn.add_theme_font_size_override("font_size", 20)
		btn.add_theme_color_override("font_color", Color.WHITE)
		node_control.add_child(btn)

		# Sub-label for level gimmick name
		var label := Label.new()
		label.text = data["title"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 14)
		if is_unlocked:
			label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 0.9))
		else:
			label.add_theme_color_override("font_color", Color(0.4, 0.45, 0.55, 0.6))
		label.custom_minimum_size = Vector2(180, 24)
		label.position = Vector2(-90, 38)
		node_control.add_child(label)

func _load_level(num: int) -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	var scene_path := "res://scenes/level_%02d.tscn" % num
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		print("Scene not found: ", scene_path)

func _on_node_hover() -> void:
	if AudioManager:
		AudioManager.play_test_beep(880.0, 0.03)

func _on_back_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_reset_pressed() -> void:
	if GameManager:
		GameManager.reset_progress()
	if AudioManager:
		AudioManager.play_ui_click()
	_build_path_and_nodes()

func _on_progress_updated(_unlocked: int) -> void:
	_build_path_and_nodes()
