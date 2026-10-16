class_name PauseMenu
extends Control

@onready var resume_btn: Button = %ResumeButton
@onready var restart_btn: Button = %RestartButton
@onready var settings_btn: Button = %SettingsButton
@onready var menu_btn: Button = %MenuButton
@onready var settings_menu: SettingsMenu = %SettingsMenu

func _ready() -> void:
	hide()
	if settings_menu:
		settings_menu.hide()
		settings_menu.closed.connect(_on_settings_closed)
		
	resume_btn.pressed.connect(_on_resume_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		if settings_menu and settings_menu.visible:
			settings_menu.hide()
			get_viewport().set_input_as_handled()
			return
			
		if visible:
			resume_game()
		else:
			pause_game()
		get_viewport().set_input_as_handled()

func pause_game() -> void:
	get_tree().paused = true
	show()
	resume_btn.grab_focus()
	if AudioManager:
		AudioManager.play_ui_click()

func resume_game() -> void:
	if settings_menu:
		settings_menu.hide()
	get_tree().paused = false
	hide()
	if AudioManager:
		AudioManager.play_ui_click()

func _on_resume_pressed() -> void:
	resume_game()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	if AudioManager:
		AudioManager.play_ui_click()
	get_tree().reload_current_scene()

func _on_settings_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	if settings_menu:
		settings_menu.show()

func _on_settings_closed() -> void:
	resume_btn.grab_focus()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	if AudioManager:
		AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
