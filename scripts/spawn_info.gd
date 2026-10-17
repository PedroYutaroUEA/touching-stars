class_name SpawnInfo
extends Control

@onready var panel: PanelContainer = %Panel
@onready var attempt_label: Label = %AttemptLabel
@onready var time_label: Label = %TimeLabel

func _ready() -> void:
	# Ensure clicks pass through to gameplay
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_attempt(attempt_num: int) -> void:
	if attempt_label:
		attempt_label.text = "Attempt %d" % attempt_num

func update_time(run_time: float) -> void:
	if time_label:
		var minutes := int(run_time) / 60
		var seconds := int(run_time) % 60
		var centiseconds := int((run_time - int(run_time)) * 100.0)
		time_label.text = "%02d:%02d.%02d" % [minutes, seconds, centiseconds]
