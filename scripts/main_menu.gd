class_name MainMenu
extends Control

@onready var play_btn: Button = %PlayButton
@onready var settings_btn: Button = %SettingsButton
@onready var exit_btn: Button = %ExitButton
@onready var help_btn: Button = %HelpButton
@onready var github_btn: Button = %GithubButton
@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var controls_modal: ControlsModal = %ControlsModal

func _ready() -> void:
	if AudioManager:
		AudioManager.play_menu_music()

	if settings_menu:
		settings_menu.hide()
		settings_menu.closed.connect(_on_settings_closed)

	if controls_modal:
		controls_modal.hide()
		controls_modal.closed.connect(_on_controls_closed)

	play_btn.pressed.connect(_on_play_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	help_btn.pressed.connect(_on_help_pressed)
	github_btn.pressed.connect(_on_github_pressed)

	play_btn.mouse_entered.connect(_on_button_hover)
	settings_btn.mouse_entered.connect(_on_button_hover)
	exit_btn.mouse_entered.connect(_on_button_hover)
	help_btn.mouse_entered.connect(_on_button_hover)
	github_btn.mouse_entered.connect(_on_button_hover)
	
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

func _on_help_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	if controls_modal:
		controls_modal.show_modal()

func _on_controls_closed() -> void:
	help_btn.grab_focus()

func _on_github_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	OS.shell_open("https://github.com/PedroYutaroUEA")

func _on_exit_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	get_tree().quit()

func _on_button_hover() -> void:
	if AudioManager:
		AudioManager.play_test_beep(1200.0, 0.02)
