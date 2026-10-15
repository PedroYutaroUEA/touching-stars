extends Node

signal progress_updated(unlocked_level: int)
signal settings_updated

const SAVE_PATH: String = "user://save.cfg"
const TOTAL_AVAILABLE_LEVELS: int = 6

var max_unlocked_level: int = 1
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9

func _ready() -> void:
	load_save()
	apply_all_audio_buses()

func load_save() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err == OK:
		max_unlocked_level = config.get_value("progress", "max_unlocked_level", 1)
		master_volume = config.get_value("audio", "master_volume", 1.0)
		music_volume = config.get_value("audio", "music_volume", 0.8)
		sfx_volume = config.get_value("audio", "sfx_volume", 0.9)
	else:
		# First run: initialize default save
		max_unlocked_level = 1
		master_volume = 1.0
		music_volume = 0.8
		sfx_volume = 0.9
		save_data()

func save_data() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "max_unlocked_level", max_unlocked_level)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save(SAVE_PATH)

func unlock_level(level_number: int) -> void:
	if level_number > max_unlocked_level:
		max_unlocked_level = clampi(level_number, 1, TOTAL_AVAILABLE_LEVELS)
		save_data()
		progress_updated.emit(max_unlocked_level)

func is_level_unlocked(level_number: int) -> bool:
	return level_number <= max_unlocked_level

func reset_progress() -> void:
	max_unlocked_level = 1
	save_data()
	progress_updated.emit(max_unlocked_level)

func set_bus_volume(bus_name: String, linear_val: float) -> void:
	linear_val = clampf(linear_val, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		if linear_val <= 0.001:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			# Convert linear (0.0 .. 1.0) to decibels (-60 dB .. 0 dB)
			var db := linear_to_db(linear_val)
			AudioServer.set_bus_volume_db(bus_idx, db)

	match bus_name:
		"Master":
			master_volume = linear_val
		"Music":
			music_volume = linear_val
		"SFX":
			sfx_volume = linear_val

	save_data()
	settings_updated.emit()

func get_bus_volume(bus_name: String) -> float:
	match bus_name:
		"Master":
			return master_volume
		"Music":
			return music_volume
		"SFX":
			return sfx_volume
		_:
			return 1.0

func apply_all_audio_buses() -> void:
	set_bus_volume("Master", master_volume)
	set_bus_volume("Music", music_volume)
	set_bus_volume("SFX", sfx_volume)
