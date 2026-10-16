class_name AudioManagerNode
extends Node

## Centralized audio manager managing background music and sound effects.
## Routes music to the "Music" bus and SFX to the "SFX" bus.

# Preloaded Music Streams
const MUSIC_MENU: AudioStream = preload("res://audio/music/menu_loop.mp3")
const MUSIC_LEVEL_01: AudioStream = preload("res://audio/music/level_01.mp3")
const MUSIC_LEVEL_02: AudioStream = preload("res://audio/music/level_02.mp3")
const MUSIC_LEVEL_03: AudioStream = preload("res://audio/music/level_03.mp3")
const MUSIC_LEVEL_04: AudioStream = preload("res://audio/music/level_04.mp3")
const MUSIC_LEVEL_05: AudioStream = preload("res://audio/music/level_05.mp3")
const MUSIC_LEVEL_06: AudioStream = preload("res://audio/music/level_06.mp3")

# Preloaded SFX Streams
const SFX_JUMP: AudioStream = preload("res://audio/sfx/jump.mp3")
const SFX_DEATH: AudioStream = preload("res://audio/sfx/death.mp3")
const SFX_LEVEL_COMPLETE: AudioStream = preload("res://audio/sfx/level_complete.wav")
const SFX_CHOOSE: AudioStream = preload("res://audio/sfx/choose.mp3")
const SFX_SELECTING: AudioStream = preload("res://audio/sfx/selecting.mp3")

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var jump_sfx: AudioStreamPlayer = $JumpSFX
@onready var death_sfx: AudioStreamPlayer = $DeathSFX
@onready var win_sfx: AudioStreamPlayer = $WinSFX
@onready var ui_choose_sfx: AudioStreamPlayer = $UIChooseSFX
@onready var ui_select_sfx: AudioStreamPlayer = $UISelectSFX

var _current_music_key: String = ""

func _ready() -> void:
	# Configure defensive node instantiations if loaded outside scene
	if not music_player:
		music_player = AudioStreamPlayer.new()
		music_player.name = "MusicPlayer"
		music_player.bus = &"Music"
		add_child(music_player)
	else:
		music_player.bus = &"Music"

	_setup_sfx_player(jump_sfx, "JumpSFX")
	_setup_sfx_player(death_sfx, "DeathSFX")
	_setup_sfx_player(win_sfx, "WinSFX")
	_setup_sfx_player(ui_choose_sfx, "UIChooseSFX")
	_setup_sfx_player(ui_select_sfx, "UISelectSFX")

	# Ensure SFX one-shot streams do not loop
	_set_stream_loop(SFX_JUMP, false)
	_set_stream_loop(SFX_DEATH, false)
	_set_stream_loop(SFX_CHOOSE, false)
	_set_stream_loop(SFX_SELECTING, false)

func _setup_sfx_player(player: AudioStreamPlayer, player_name: String) -> AudioStreamPlayer:
	if not player:
		player = AudioStreamPlayer.new()
		player.name = player_name
		player.bus = &"SFX"
		add_child(player)
	else:
		player.bus = &"SFX"
	return player

func _set_stream_loop(stream: AudioStream, enable_loop: bool) -> void:
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = enable_loop

## Plays the menu loop music seamlessly across menu/level-select screens.
func play_menu_music() -> void:
	if _current_music_key == "menu" and music_player and music_player.playing:
		return
	
	_current_music_key = "menu"
	_set_stream_loop(MUSIC_MENU, true)
	if music_player:
		music_player.stream = MUSIC_MENU
		music_player.play()

## Plays the background music for the given level (1 to 6) in loop.
## If the same level music is already playing, continues without interruption.
func play_level_music(level_num: int) -> void:
	var key: String = "level_%02d" % level_num
	if _current_music_key == key and music_player and music_player.playing:
		return

	_current_music_key = key
	var stream: AudioStream = _get_level_stream(level_num)
	if stream:
		_set_stream_loop(stream, true)
		if music_player:
			music_player.stream = stream
			music_player.play()
	else:
		stop_music()

## Stops any currently playing background music.
func stop_music() -> void:
	_current_music_key = ""
	if music_player:
		music_player.stop()

## SFX: Player Jump
func play_jump() -> void:
	if jump_sfx:
		jump_sfx.stream = SFX_JUMP
		jump_sfx.play()

## SFX: Player Death
func play_death() -> void:
	if death_sfx:
		death_sfx.stream = SFX_DEATH
		death_sfx.play()

## SFX: Level Complete.
## Per requirements: Stops level music immediately and plays level_complete.wav.
func play_win() -> void:
	stop_music()
	if win_sfx:
		win_sfx.stream = SFX_LEVEL_COMPLETE
		win_sfx.play()

## SFX: UI button confirm / click / selection
func play_ui_click() -> void:
	if ui_choose_sfx:
		ui_choose_sfx.stream = SFX_CHOOSE
		ui_choose_sfx.play()

## SFX: UI hover / navigation / option selecting
func play_ui_hover() -> void:
	if ui_select_sfx:
		ui_select_sfx.stream = SFX_SELECTING
		ui_select_sfx.play()

## Backward-compatible method for tests and UI sliders
func play_test_beep(_freq: float = 659.25, _duration: float = 0.1) -> void:
	play_ui_hover()

func is_music_playing() -> bool:
	return music_player != null and music_player.playing

func get_current_music_key() -> String:
	return _current_music_key

func _get_level_stream(level_num: int) -> AudioStream:
	match level_num:
		1: return MUSIC_LEVEL_01
		2: return MUSIC_LEVEL_02
		3: return MUSIC_LEVEL_03
		4: return MUSIC_LEVEL_04
		5: return MUSIC_LEVEL_05
		6: return MUSIC_LEVEL_06
		_: return null
