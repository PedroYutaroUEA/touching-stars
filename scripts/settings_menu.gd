class_name SettingsMenu
extends Control

signal closed

@onready var master_slider: HSlider = %MasterSlider
@onready var master_value_label: Label = %MasterValueLabel
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value_label: Label = %MusicValueLabel
@onready var sfx_slider: HSlider = %SFXSlider
@onready var sfx_value_label: Label = %SFXValueLabel
@onready var test_sfx_btn: Button = %TestSFXButton
@onready var close_btn: Button = %CloseButton

func _ready() -> void:
	_sync_ui_with_settings()
	
	master_slider.value_changed.connect(_on_master_value_changed)
	music_slider.value_changed.connect(_on_music_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_value_changed)
	
	test_sfx_btn.pressed.connect(_on_test_sfx_pressed)
	close_btn.pressed.connect(_on_close_pressed)

func _sync_ui_with_settings() -> void:
	if not GameManager:
		return
		
	var m_vol: float = GameManager.get_bus_volume("Master") * 100.0
	master_slider.value = m_vol
	master_value_label.text = "%d%%" % int(m_vol)
	
	var mus_vol: float = GameManager.get_bus_volume("Music") * 100.0
	music_slider.value = mus_vol
	music_value_label.text = "%d%%" % int(mus_vol)
	
	var s_vol: float = GameManager.get_bus_volume("SFX") * 100.0
	sfx_slider.value = s_vol
	sfx_value_label.text = "%d%%" % int(s_vol)

func _on_master_value_changed(val: float) -> void:
	master_value_label.text = "%d%%" % int(val)
	if GameManager:
		GameManager.set_bus_volume("Master", val / 100.0)

func _on_music_value_changed(val: float) -> void:
	music_value_label.text = "%d%%" % int(val)
	if GameManager:
		GameManager.set_bus_volume("Music", val / 100.0)

func _on_sfx_value_changed(val: float) -> void:
	sfx_value_label.text = "%d%%" % int(val)
	if GameManager:
		GameManager.set_bus_volume("SFX", val / 100.0)

func _on_test_sfx_pressed() -> void:
	if AudioManager:
		AudioManager.play_test_beep()

func _on_close_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	closed.emit()
	hide()
