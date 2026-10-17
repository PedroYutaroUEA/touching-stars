extends Node

signal progress_updated(unlocked_level: int)
signal settings_updated

const SAVE_PATH: String = "user://save.cfg"
const TOTAL_AVAILABLE_LEVELS: int = 6

var max_unlocked_level: int = 1
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9

var current_level_num: int = 1
var current_attempts: int = 1

func _ready() -> void:
	DisplayServer.window_set_title("Touching Stars")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	
	load_save()
	apply_all_audio_buses()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			toggle_fullscreen()

func toggle_fullscreen() -> void:
	var current_mode := DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN or current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

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

func start_level_session(level_number: int) -> int:
	if level_number != current_level_num:
		current_level_num = level_number
		current_attempts = 1
	return current_attempts

func register_death_or_restart() -> void:
	current_attempts += 1

func reset_session_attempts() -> void:
	current_attempts = 1

func get_best_attempts(level_number: int) -> int:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err == OK:
		return config.get_value("records", "best_attempts_" + str(level_number), -1)
	return -1

func record_completion(level_number: int) -> Dictionary:
	unlock_level(level_number + 1)

	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	var key := "best_attempts_" + str(level_number)
	var prev_best: int = config.get_value("records", key, -1)
	var is_new_best: bool = false
	var final_best: int = prev_best

	if prev_best == -1 or current_attempts < prev_best:
		is_new_best = true
		final_best = current_attempts
		config.set_value("records", key, final_best)
		config.save(SAVE_PATH)

	var result := {
		"attempts": current_attempts,
		"best_attempts": final_best,
		"is_new_best": is_new_best
	}
	
	# Prepare session for future attempts
	current_attempts = 1
	return result

func reset_progress() -> void:
	max_unlocked_level = 1
	current_attempts = 1
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
