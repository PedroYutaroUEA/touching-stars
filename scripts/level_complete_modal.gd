class_name LevelCompleteModal
extends Control

signal restart_requested
signal next_level_requested
signal level_select_requested

@onready var title_label: Label = %TitleLabel
@onready var level_name_label: Label = %LevelNameLabel
@onready var time_value_label: Label = %TimeValueLabel
@onready var attempts_value_label: Label = %AttemptsValueLabel
@onready var jumps_value_label: Label = %JumpsValueLabel
@onready var record_badge: Label = %RecordBadge

@onready var replay_btn: Button = %ReplayButton
@onready var next_btn: Button = %NextButton
@onready var level_select_btn: Button = %LevelSelectButton

var _has_next_level: bool = true

func _ready() -> void:
	hide()
	replay_btn.pressed.connect(_on_replay_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	level_select_btn.pressed.connect(_on_level_select_pressed)

	replay_btn.mouse_entered.connect(_on_button_hover)
	next_btn.mouse_entered.connect(_on_button_hover)
	level_select_btn.mouse_entered.connect(_on_button_hover)

func setup(
	level_num: int,
	level_title: String,
	run_time: float,
	attempts: int,
	best_attempts: int,
	is_new_best: bool,
	jumps: int,
	has_next: bool
) -> void:
	_has_next_level = has_next
	
	title_label.text = "★ LEVEL COMPLETE! ★"
	level_name_label.text = "Dia %02d • %s" % [level_num, level_title]
	
	# Format time: MM:SS.cc
	var minutes := int(run_time) / 60
	var seconds := int(run_time) % 60
	var centiseconds := int((run_time - int(run_time)) * 100.0)
	time_value_label.text = "%02d:%02d.%02d" % [minutes, seconds, centiseconds]
	
	attempts_value_label.text = "%d" % attempts
	jumps_value_label.text = "%d" % jumps
	
	# Display record badge
	if is_new_best:
		record_badge.text = "✨ NOVO RECORDE!"
		record_badge.modulate = Color(1.0, 0.88, 0.35, 1.0)
		record_badge.show()
	elif best_attempts > 0:
		record_badge.text = "🏆 Melhor: %d att" % best_attempts
		record_badge.modulate = Color(0.65, 0.85, 1.0, 0.85)
		record_badge.show()
	else:
		record_badge.hide()

	# Configure next button depending on whether next level exists
	if _has_next_level:
		next_btn.disabled = false
		next_btn.text = "PRÓXIMO NÍVEL ▶"
		next_btn.grab_focus()
	else:
		next_btn.disabled = true
		next_btn.text = "NOVAS FASES EM BREVE"
		replay_btn.grab_focus()

	show()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("restart_level") and not event.is_echo():
		_on_replay_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause") and not event.is_echo():
		_on_level_select_pressed()
		get_viewport().set_input_as_handled()

func _on_replay_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	hide()
	restart_requested.emit()

func _on_next_pressed() -> void:
	if not _has_next_level:
		return
	if AudioManager:
		AudioManager.play_ui_click()
	hide()
	next_level_requested.emit()

func _on_level_select_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	hide()
	level_select_requested.emit()

func _on_button_hover() -> void:
	if AudioManager:
		AudioManager.play_test_beep(1200.0, 0.02)
