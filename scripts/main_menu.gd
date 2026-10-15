class_name MainMenu
extends Control

@onready var play_btn: Button = %PlayButton
@onready var settings_btn: Button = %SettingsButton
@onready var exit_btn: Button = %ExitButton
@onready var settings_menu: SettingsMenu = %SettingsMenu

func _ready() -> void:
	if settings_menu:
		settings_menu.hide()
		settings_menu.closed.connect(_on_settings_closed)

	play_btn.pressed.connect(_on_play_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

	play_btn.mouse_entered.connect(_on_button_hover)
	settings_btn.mouse_entered.connect(_on_button_hover)
	exit_btn.mouse_entered.connect(_on_button_hover)
	
	play_btn.grab_focus()

func _on_play_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_settings_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	if settings_menu:
		settings_menu.show()

func _on_settings_closed() -> void:
	play_btn.grab_focus()

func _on_exit_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	get_tree().quit()

func _on_button_hover() -> void:
	if AudioManager:
		AudioManager.play_test_beep(1200.0, 0.02)
