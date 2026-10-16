class_name ControlsModal
extends Control

signal closed

@onready var close_btn: Button = %CloseButton

func _ready() -> void:
	hide()
	close_btn.pressed.connect(_on_close_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause") and not event.is_echo():
		_on_close_pressed()
		get_viewport().set_input_as_handled()

func show_modal() -> void:
	show()
	close_btn.grab_focus()

func _on_close_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	hide()
	closed.emit()
