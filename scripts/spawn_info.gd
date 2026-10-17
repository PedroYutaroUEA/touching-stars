class_name SpawnInfo
extends Control

## In-world floating banner showing current attempt number and real-time run stopwatch.
## Fully customizable in position, font sizes, scale, and background per level.

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

func set_banner_position(pos: Vector2) -> void:
	position = pos

func set_font_sizes(attempt_size: int = 12, time_size: int = 10) -> void:
	if attempt_label:
		attempt_label.add_theme_font_size_override("font_size", attempt_size)
	if time_label:
		time_label.add_theme_font_size_override("font_size", time_size)

func set_scale_factor(factor: float) -> void:
	scale = Vector2(factor, factor)

func set_has_background(enabled: bool) -> void:
	if not panel:
		return
	if enabled:
		panel.self_modulate = Color(1, 1, 1, 1)
	else:
		panel.self_modulate = Color(1, 1, 1, 0)

## Quick one-call configuration for any level script
func configure(
	pos: Vector2 = Vector2.ZERO,
	attempt_size: int = 12,
	time_size: int = 10,
	scale_val: float = 1.0,
	has_bg: bool = true
) -> void:
	if pos != Vector2.ZERO:
		set_banner_position(pos)
	set_font_sizes(attempt_size, time_size)
	set_scale_factor(scale_val)
	set_has_background(has_bg)
